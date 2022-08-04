CLASS zprl_task_runner DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_parameters,
        id                        TYPE zprl_task=>t_id,
        start_new_task_ind        TYPE abap_bool,
        task_class_name         TYPE seoclsname,
        object_selection_rng_list TYPE zprl_task=>t_object_selection_rng_list,
      END OF t_parameters .

    EVENTS completed .

    METHODS constructor
      IMPORTING parameters TYPE t_parameters.

    METHODS get_id
      RETURNING
        VALUE(id) TYPE zprl_task=>t_id .

    METHODS start.

    METHODS on_call_back_task
      IMPORTING
        !p_task TYPE c .

    METHODS get_result_list
      RETURNING VALUE(result_list) TYPE zprl_task=>t_result_list.
  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA m_parameters TYPE t_parameters .
    DATA m_result_list TYPE zprl_task=>t_result_list.

ENDCLASS.



CLASS ZPRL_TASK_RUNNER IMPLEMENTATION.


  METHOD constructor.

    me->m_parameters = parameters.

  ENDMETHOD.


  METHOD get_id.

    id = me->m_parameters-id.

  ENDMETHOD.


  METHOD get_result_list.

    result_list = me->m_result_list.

  ENDMETHOD.


  METHOD on_call_back_task.

    RECEIVE RESULTS FROM FUNCTION 'Z_PRL_task_RFC'
      TABLES result_list = m_result_list.

    RAISE EVENT completed.

  ENDMETHOD.


  METHOD start.

    IF me->m_parameters-start_new_task_ind = abap_true.

      DATA task_id_char TYPE c LENGTH 8.

      task_id_char = me->m_parameters-id.

      CALL FUNCTION 'Z_PRL_TASK_RFC'
        STARTING NEW TASK task_id_char
        CALLING me->on_call_back_task ON END OF TASK
        EXPORTING
          class_name         = me->m_parameters-task_class_name
          id                 = me->m_parameters-id
        TABLES
          object_selection_rng_list = me->m_parameters-object_selection_rng_list[].

    ELSE.

      CALL FUNCTION 'Z_PRL_TASK_RFC'
        EXPORTING
          class_name         = me->m_parameters-task_class_name
          id                 = me->m_parameters-id
        TABLES
          object_selection_rng_list = me->m_parameters-object_selection_rng_list[]
          result_list               = m_result_list.

      RAISE EVENT completed.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
