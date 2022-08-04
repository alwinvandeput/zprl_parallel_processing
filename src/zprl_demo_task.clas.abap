CLASS zprl_demo_task DEFINITION
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



CLASS ZPRL_DEMO_TASK IMPLEMENTATION.


  METHOD execute.

    LOOP AT object_selection_rng_list
      ASSIGNING FIELD-SYMBOL(<object_selection>).

      DATA(demo_object) = NEW zprl_demo_object(
        key = CONV #( <object_selection>-low ) ).

      demo_object->do_something(
        duration_secs = 3 ). "TODO: dynamisch maken

      APPEND
        VALUE #(
          type        = 'S'
          id          = 'ZPRL_DEMO'
          number      = '001'
          message     = |Thread { me->m_id } : Demo object { <object_selection>-low } completed|
          message_v1  = <object_selection>-low
          message_v2  = ''
          message_v3  = ''
          message_v4  = ''
          parameter   = ''
          row         = ''
          field       = <object_selection>-low )
        TO result_list.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
