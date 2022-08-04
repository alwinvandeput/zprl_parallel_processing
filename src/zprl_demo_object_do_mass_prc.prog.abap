*&---------------------------------------------------------------------*
*& Report ZPRL_DEMO_OBJECT_DO_MASS_PRC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprl_demo_object_do_mass_prc.

PARAMETERS parall  AS CHECKBOX DEFAULT abap_true.
PARAMETERS maxthr  TYPE i DEFAULT 99.
PARAMETERS freethr  TYPE i DEFAULT 3.
PARAMETERS throbj  TYPE i DEFAULT 7.
PARAMETERS dmobcnt TYPE i DEFAULT 100.

*PARAMETERS objTYPE TYPE zprl_object_selection_rng-object_type
*PARAMETERS objact TYPE zprl_object_selection_rng-object_action.

*Object count: 100
*Object method duration sec.: 2 to 4
*Processing
*Server group: <optional?>
* Strategy
*Radio button: Max. processes used: X
*Max. thread process count: 5
*Min. thread free count: 3
*Radio button: Min. processes free: <empty>
*Min thread free count: 3 <disabled>
*Objects per process count: 7
*Activate application log: X
*Application log object: ZPRL_DEMO_MASS_PRC

START-OF-SELECTION.

  DATA(mass_process) = NEW zprl_demo_object_mass_prc(
    demo_parameters = VALUE #(
      process_parallel_ind        =  parall
      max_parallel_task_count     = maxthr
      min_free_work_process_count = freethr
      task_object_count           = throbj
      demo_object_count           = dmobcnt ) ).

  mass_process->start( ).

  "----------------------------------------------
  "Write results to screen
  "----------------------------------------------
  DATA(duration_secs) = mass_process->get_duration_in_secs( ).

  WRITE : 'Duration : ', duration_secs.

  DATA(result_list) = mass_process->get_task_result_list( ).

  LOOP AT result_list
    ASSIGNING FIELD-SYMBOL(<result_line>).

    WRITE : / <result_line>-message.

  ENDLOOP.
