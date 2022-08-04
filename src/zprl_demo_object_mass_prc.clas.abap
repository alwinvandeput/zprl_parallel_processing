CLASS zprl_demo_object_mass_prc DEFINITION
  PUBLIC
  INHERITING FROM zprl_parallel_process
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_demo_parameters,
        process_parallel_ind      TYPE abap_bool,
        max_parallel_task_count TYPE i,
        min_free_work_process_count     TYPE i,
        task_object_count       TYPE zprl_demo_object_mass_prc=>t_parameters-task_object_count,
        demo_object_count         TYPE i,
      END OF t_demo_parameters.

    METHODS constructor
      IMPORTING demo_parameters TYPE t_demo_parameters.

  PROTECTED SECTION.

    DATA m_demo_parameters TYPE t_demo_parameters.

    METHODS select_objects
        REDEFINITION .

  PRIVATE SECTION.

ENDCLASS.



CLASS ZPRL_DEMO_OBJECT_MASS_PRC IMPLEMENTATION.


  METHOD constructor.

    super->constructor(
      parameters =
        VALUE #(
          process_parallel_ind        = demo_parameters-process_parallel_ind
          max_parallel_task_count     = demo_parameters-max_parallel_task_count
          min_free_work_process_count = demo_parameters-min_free_work_process_count
          task_class_name             = 'ZPRL_DEMO_TASK'
          task_object_count           = demo_parameters-task_object_count ) ).

    me->m_demo_parameters = demo_parameters.

  ENDMETHOD.


  METHOD select_objects.

    DO me->m_demo_parameters-demo_object_count TIMES.

      APPEND INITIAL LINE TO me->m_object_selection_list
        ASSIGNING FIELD-SYMBOL(<object_selection_line>).

      <object_selection_line>-object_type   = 'ZPRL_DEMO_OBJECT'.
      <object_selection_line>-object_action = 'DO_SOMETHING'.

      <object_selection_line>-sign          = 'I'.
      <object_selection_line>-option        = 'EQ'.
      WRITE sy-index TO <object_selection_line>-low LEFT-JUSTIFIED.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
