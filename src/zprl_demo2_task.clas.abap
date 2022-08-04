CLASS zprl_demo2_task DEFINITION
  PUBLIC
  INHERITING FROM zprl_task
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS execute
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zprl_demo2_task IMPLEMENTATION.


  METHOD execute.

    ASSERT object_selection_rng_list[] IS NOT INITIAL.

    DATA(object_selection) = object_selection_rng_list[ 1 ].

    DATA(key) = CONV i( object_selection-low ).
    DATA(end_key) = CONV i( object_selection-high ).

    DO.

      DATA(demo_object) = NEW zprl_demo_object(
        key = key ).

      demo_object->do_something(
        duration_secs = 3 ). "TODO: dynamisch maken

      APPEND
        VALUE #(
          type        = 'S'
          id          = 'ZPRL_DEMO'
          number      = '001'
          message     = |Thread { me->m_id } : Demo object { key } completed|
          message_v1  = key
          message_v2  = ''
          message_v3  = ''
          message_v4  = ''
          parameter   = ''
          row         = ''
          field       = key )
        TO result_list.

      key = key + 1.

      IF key > end_key.
        EXIT.
      ENDIF.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
