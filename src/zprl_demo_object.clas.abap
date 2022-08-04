CLASS zprl_demo_object DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES t_key TYPE i.

    METHODS constructor
      IMPORTING
        !key TYPE t_key .
    METHODS do_something
      IMPORTING
        !duration_secs TYPE i .

  PROTECTED SECTION.
    DATA m_key TYPE t_key.

  PRIVATE SECTION.
ENDCLASS.



CLASS ZPRL_DEMO_OBJECT IMPLEMENTATION.


  METHOD constructor.

    m_key = key.

  ENDMETHOD.


  METHOD do_something.

    DATA(timer) = NEW zprl_timer( ).

    timer->start( ).

    DO.

      DATA(timer_duration_secs) = timer->get_duration_in_seconds( ).

      IF timer_duration_secs >= duration_secs.
        EXIT.
      ENDIF.

    ENDDO.

    timer->stop( ).
    CLEAR timer.

  ENDMETHOD.
ENDCLASS.
