class ZPRL_TIMER definition
  public
  final
  create public .

public section.

  methods START .
  methods STOP .
  methods GET_DURATION_IN_MILLI_SEC
    returning
      value(RV_MILLI_SEC) type I .
  methods GET_DURATION_IN_SECONDS
    returning
      value(RV_SECONDS) type I .
  methods GET_DURATION_IN_MINUTES
    returning
      value(RV_MINUTES) type I .
  PROTECTED SECTION.
    TYPES:
      gtv_decimal TYPE p LENGTH 16 DECIMALS 6.

    DATA:
      gv_running_ind TYPE abap_bool,
      gv_start_time  TYPE i,
      gv_stop_time   TYPE i.

    METHODS:
      round_down
        IMPORTING iv_decimal_value       TYPE gtv_decimal
        RETURNING VALUE(rv_result_value) TYPE i.

ENDCLASS.



CLASS ZPRL_TIMER IMPLEMENTATION.


  METHOD GET_DURATION_IN_MILLI_SEC.

    "Determine stop time, if running, than current time
    DATA lv_stop_time TYPE i.

    IF gv_running_ind = abap_true.

      GET RUN TIME FIELD lv_stop_time.

    ELSE.

      lv_stop_time = gv_stop_time.

    ENDIF.

    rv_milli_sec = lv_stop_time - gv_start_time.

  ENDMETHOD.


  METHOD GET_DURATION_IN_MINUTES.

    rv_minutes = round_down( get_duration_in_seconds( ) / 60 ).

  ENDMETHOD.


  METHOD GET_DURATION_IN_SECONDS.

    rv_seconds = round_down( get_duration_in_milli_sec( ) / 1000 / 1000 ).

  ENDMETHOD.


  METHOD ROUND_DOWN.

    DATA:
      lv_result_value TYPE p DECIMALS 0.

    CALL FUNCTION 'ROUND'
      EXPORTING
        decimals      = 0
        input         = iv_decimal_value
        sign          = '-'  "Negative Rounding Concept
      IMPORTING
        output        = lv_result_value
      EXCEPTIONS
        input_invalid = 1
        overflow      = 2
        type_invalid  = 3
        OTHERS        = 4.

    rv_result_value = lv_result_value.

  ENDMETHOD.


  METHOD START.

    gv_running_ind = abap_true.

    GET RUN TIME FIELD gv_start_time.

  ENDMETHOD.


  METHOD STOP.

    GET RUN TIME FIELD gv_stop_time.

    gv_running_ind = abap_false.

  ENDMETHOD.
ENDCLASS.
