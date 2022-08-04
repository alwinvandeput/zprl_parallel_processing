CLASS zprl_parallel_process DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_parameters,

        process_parallel_ind        TYPE abap_bool,
        task_class_name             TYPE zprl_task=>t_task_class_name,
        max_parallel_task_count     TYPE i,
        min_free_work_process_count TYPE i,

        "Obligatory if GET_NEXT_task_SEL_LIST is not redefined is sub class.
        task_object_count           TYPE i,

      END OF t_parameters.

    METHODS constructor
      IMPORTING parameters TYPE t_parameters.

    METHODS start .

    METHODS get_task_result_list
      RETURNING VALUE(task_result_list) TYPE zprl_task=>t_result_list.

    METHODS get_duration_in_secs
      RETURNING VALUE(duration_secs) TYPE i.

  PROTECTED SECTION.

    TYPES t_object_selection TYPE zprl_object_selection_rng .
    TYPES:
      t_object_selection_rng_list TYPE STANDARD TABLE OF t_object_selection WITH EMPTY KEY .

    DATA m_parameters TYPE t_parameters .

    "By default a object selection list is used.
    "But you can redefine/override method GET_NEXT_task_SEL_LIST
    DATA m_object_selection_list TYPE t_object_selection_rng_list .
    DATA m_object_current_index TYPE i .

    DATA m_task_count TYPE i .
    DATA m_task_percentage TYPE i .
    DATA m_active_task_runner_list   TYPE STANDARD TABLE OF REF TO zprl_task_runner .
    DATA m_task_result_list TYPE zprl_task=>t_result_list.
    DATA m_active_task_runner_count TYPE i .
    DATA m_duration_secs TYPE i.

    METHODS select_objects .
    METHODS calculate_task_count
      RETURNING
        VALUE(task_count) TYPE i .
    METHODS start_task_runners
      IMPORTING
        !task_class_name TYPE zprl_task=>t_task_class_name .
    METHODS get_next_task_sel_list
      RETURNING
        VALUE(object_selection_list) TYPE t_object_selection_rng_list .

    METHODS on_task_runner_completed
      FOR EVENT completed OF zprl_task_runner
      IMPORTING
        !sender .

    METHODS get_free_task_count
      RETURNING VALUE(free_task_count) TYPE i.

    METHODS initialize_task_count.

    METHODS wait_till_min_free_tasks
      IMPORTING task_id                TYPE zprl_task=>t_id
      RETURNING VALUE(free_task_count) TYPE i.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZPRL_PARALLEL_PROCESS IMPLEMENTATION.


  METHOD select_objects.

    "This method can be used to fill table M_OBJECT_SELECTION_LIST

    "It is not mandatory to use this method.
    "If not used, than method get_next_task_object_SEL_list must be used.

  ENDMETHOD.


  METHOD start.

    select_objects( ).

    m_task_count = calculate_task_count( ).

    initialize_task_count( ).

    DATA(timer) = NEW zprl_timer( ).
    timer->start( ).

    start_task_runners(
      task_class_name =  me->m_parameters-task_class_name ).

    timer->stop( ).

    me->m_duration_secs = timer->get_duration_in_seconds( ).

  ENDMETHOD.


  METHOD calculate_task_count.

    IF me->m_object_selection_list[] IS INITIAL.
      RETURN.
    ENDIF.

    DATA(line_count) = lines( me->m_object_selection_list ).
    DATA(task_count_packed) = line_count / me->m_parameters-task_object_count.
    task_count = round( val = task_count_packed dec = 0 mode = cl_abap_math=>round_up ).

  ENDMETHOD.


  METHOD constructor.

    me->m_parameters = parameters.

  ENDMETHOD.


  METHOD get_duration_in_secs.

    duration_secs = me->m_duration_secs.

  ENDMETHOD.


  METHOD get_free_task_count.

    DATA max_pbt_wps TYPE i.
    DATA free_pbt_wps TYPE i.

    CALL FUNCTION 'SPBT_GET_CURR_RESOURCE_INFO'
      IMPORTING
        max_pbt_wps                 = max_pbt_wps
        free_pbt_wps                = free_pbt_wps
      EXCEPTIONS
        internal_error              = 1
        pbt_env_not_initialized_yet = 2
        OTHERS                      = 3.

    ASSERT sy-subrc = 0.

    free_task_count = free_pbt_wps.

  ENDMETHOD.


  METHOD get_next_task_sel_list.

    ASSERT me->m_parameters-task_object_count > 0.

    DATA(start_index) = m_object_current_index + 1.

    m_object_current_index = m_object_current_index + me->m_parameters-task_object_count.

    DATA(stop_index) = m_object_current_index.

    LOOP AT me->m_object_selection_list
      ASSIGNING FIELD-SYMBOL(<object_selection_list>)
      FROM start_index.

      IF sy-tabix > stop_index.
        EXIT.
      ENDIF.

      APPEND <object_selection_list> TO object_selection_list.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_task_result_list.

    task_result_list = me->m_task_result_list.

  ENDMETHOD.


  METHOD initialize_task_count.

    DATA max_pbt_wps TYPE i.
    DATA free_pbt_wps TYPE i.

    CALL FUNCTION 'SPBT_INITIALIZE'
      EXPORTING
        group_name                     = ' '
        max_wait_time                  = 0
      IMPORTING
        max_pbt_wps                    = max_pbt_wps
        free_pbt_wps                   = free_pbt_wps
      EXCEPTIONS
        invalid_group_name             = 1
        internal_error                 = 2
        pbt_env_already_initialized    = 3
        currently_no_resources_avail   = 4
        no_pbt_resources_found         = 5
        cant_init_different_pbt_groups = 6
        OTHERS                         = 7.

    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD on_task_runner_completed.

    "Get results
    DATA(task_return_list) = sender->get_result_list( ).

    APPEND LINES OF task_return_list TO me->m_task_result_list.

    "Delete task runner from active task runner list
    DATA(completed_task_id) = sender->get_id( ).

    LOOP AT m_active_task_runner_list
      ASSIGNING FIELD-SYMBOL(<task_runner>).

      IF <task_runner>->get_id( ) = completed_task_id.

        DELETE m_active_task_runner_list.
        EXIT.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD start_task_runners.

    DATA last_task_id TYPE zprl_task=>t_id.

    DO.

      DATA(object_key_list) = get_next_task_sel_list( ).

      IF object_key_list[] IS INITIAL.
        EXIT.
      ENDIF.

      "--------------------------------------------------
      "Create task runner
      "--------------------------------------------------
      last_task_id = last_task_id + 1.

      DATA(task_runner) = NEW zprl_task_runner(
        parameters =
          VALUE #(
            id                        = last_task_id
            start_new_task_ind        = me->m_parameters-process_parallel_ind
            task_class_name         = task_class_name
            object_selection_rng_list = object_key_list ) ).

      SET HANDLER on_task_runner_completed
        FOR task_runner.

      APPEND task_runner TO m_active_task_runner_list.

      me->m_active_task_runner_count = lines( m_active_task_runner_list ).

      DATA(free_task_count) = wait_till_min_free_tasks(
         task_id = last_task_id ).


      task_runner->start( ).

      IF me->m_parameters-process_parallel_ind = abap_true.

        ASSERT me->m_parameters-max_parallel_task_count > 0.
        WAIT UNTIL me->m_active_task_runner_count < me->m_parameters-max_parallel_task_count.

      ENDIF.

    ENDDO.

    IF me->m_parameters-process_parallel_ind = abap_true.
      WAIT UNTIL me->m_active_task_runner_count = 0.
    ENDIF.

  ENDMETHOD.


  METHOD wait_till_min_free_tasks.

    DO.

      free_task_count = get_free_task_count( ).

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = me->m_task_percentage
          text       = |Task number { task_id } started. Active tasks { me->m_active_task_runner_count }, free tasks { free_task_count }|.

      IF me->m_parameters-process_parallel_ind = abap_true.

        IF free_task_count > me->m_parameters-min_free_work_process_count.
          EXIT.
        ENDIF.

      ENDIF.

      WAIT UP TO 1 SECONDS.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
