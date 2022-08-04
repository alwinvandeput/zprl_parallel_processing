FUNCTION Z_PRL_TASK_RFC.
*"----------------------------------------------------------------------
*"*"Lokale interface:
*"  IMPORTING
*"     VALUE(CLASS_NAME) TYPE  SEOCLSNAME
*"     VALUE(ID) TYPE  I
*"  TABLES
*"      OBJECT_SELECTION_RNG_LIST STRUCTURE  ZPRL_OBJECT_SELECTION_RNG
*"      RESULT_LIST STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA task TYPE REF TO zprl_task.

  CREATE OBJECT task TYPE (class_name)
    exporting
      id = id.

  DATA(temp_result_list) =
    task->execute(
      object_selection_rng_list = object_selection_rng_list[] ).

  result_list[] = temp_result_list[].

ENDFUNCTION.
