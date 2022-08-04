CLASS zprl_task DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      t_id                        TYPE i,
      t_task_class_name           TYPE seoclsname,
      t_object_selection_rng_list TYPE STANDARD TABLE OF zprl_object_selection_rng WITH DEFAULT KEY,
      t_result_line               TYPE bapiret2,
      t_result_list               TYPE STANDARD TABLE OF t_result_line WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING id TYPE i.

    METHODS execute ABSTRACT
      IMPORTING
                object_selection_rng_list TYPE t_object_selection_rng_list
      RETURNING VALUE(result_list)        TYPE t_result_list.

  PROTECTED SECTION.

    DATA m_id TYPE t_id.

  PRIVATE SECTION.

ENDCLASS.



CLASS zprl_task IMPLEMENTATION.


  METHOD constructor.

    m_id = id .

  ENDMETHOD.
ENDCLASS.
