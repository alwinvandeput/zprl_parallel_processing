CLASS zprl_demo2_object_mass_prc DEFINITION
  PUBLIC
  INHERITING FROM zprl_parallel_process
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_demo_parameters,
        process_parallel_ind        TYPE abap_bool,
        max_parallel_task_count     TYPE i,
        min_free_work_process_count TYPE i,
        task_object_count           TYPE zprl_demo2_object_mass_prc=>t_parameters-task_object_count,
        demo_selection_obj_count    TYPE i,
        demo_object_count           TYPE i,
      END OF t_demo_parameters.

    METHODS constructor
      IMPORTING demo_parameters TYPE t_demo_parameters.

  PROTECTED SECTION.

    DATA m_demo_parameters TYPE t_demo_parameters.

    METHODS select_objects
        REDEFINITION .

  PRIVATE SECTION.

ENDCLASS.



CLASS zprl_demo2_object_mass_prc IMPLEMENTATION.


  METHOD constructor.

    super->constructor(
      parameters =
        VALUE #(
          process_parallel_ind        = demo_parameters-process_parallel_ind
          max_parallel_task_count     = demo_parameters-max_parallel_task_count
          min_free_work_process_count = demo_parameters-min_free_work_process_count
          task_class_name             = 'ZPRL_DEMO2_TASK'
          task_object_count           = demo_parameters-task_object_count ) ).

    me->m_demo_parameters = demo_parameters.

  ENDMETHOD.


  METHOD select_objects.

    DATA count TYPE i.

    DO me->m_demo_parameters-demo_object_count TIMES.

      count = count + 1.

      IF count = 1.

        APPEND INITIAL LINE TO me->m_object_selection_list
          ASSIGNING FIELD-SYMBOL(<object_selection_line>).

        <object_selection_line>-object_type   = 'ZPRL_DEMO_OBJECT'.
        <object_selection_line>-object_action = 'DO_SOMETHING'.

        <object_selection_line>-sign          = 'I'.
        <object_selection_line>-option        = 'BT'.  "BT = Between
        WRITE sy-index TO <object_selection_line>-low LEFT-JUSTIFIED.

      ENDIF.

      IF count = me->m_demo_parameters-demo_selection_obj_count OR
         sy-index = me->m_demo_parameters-demo_object_count .

        WRITE sy-index TO <object_selection_line>-high LEFT-JUSTIFIED.

        count = 0.

      ENDIF.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
