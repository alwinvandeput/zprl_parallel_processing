REPORT zprl_demo2_object_do_mass_prc.

"Demo 2 is based on selection ranges
"Method zprl_demo2_object_mass_prc->select_objects( ) returns a list
"of ranges instead of object keys

PARAMETERS parall  AS CHECKBOX DEFAULT abap_true.
PARAMETERS maxthr  TYPE i DEFAULT 99.
PARAMETERS freethr  TYPE i DEFAULT 3.
PARAMETERS tasksel  TYPE i DEFAULT 1.
PARAMETERS selobj  TYPE i DEFAULT 7.
PARAMETERS dmobcnt TYPE i DEFAULT 100.

START-OF-SELECTION.

  DATA(mass_process) = NEW zprl_demo2_object_mass_prc(
    demo_parameters = VALUE #(
      process_parallel_ind        =  parall
      max_parallel_task_count     = maxthr
      min_free_work_process_count = freethr
      task_object_count           = tasksel
      demo_selection_obj_count    = selobj
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
