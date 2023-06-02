CLASS znov05_cl_mustache_01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS znov05_cl_mustache_01 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA:
*      lo_mustache     TYPE REF TO zcl_mustache,
      lv_index        TYPE i,
      lv_count        TYPE i,
      lv_complex_test TYPE c,
      lv_template     TYPE string,
      lt_tokens       TYPE zif_mustache=>ty_token_tt,
      lv_output       TYPE string,
      ls_simple       TYPE znov05_cl_mustache_test=>ty_dummy,
      lt_complex1     TYPE zif_mustache=>ty_struc_tt,
      lt_complex2     TYPE zif_mustache=>ty_struc_tt.

    znov05_cl_mustache_test=>get_test_data(
      IMPORTING
        es_simple   = ls_simple
        et_complex1 = lt_complex1
        et_complex2 = lt_complex2
    ).

    DATA(i) = 1.
    DO 11 TIMES.
      lv_index = i. " value range: 1~11
      znov05_cl_mustache_test=>get_test_case(
        EXPORTING
          iv_index        = lv_index
        IMPORTING
          ev_count        = lv_count
          ev_complex_test = lv_complex_test
          ev_template     = lv_template
          et_tokens       = lt_tokens
          ev_output       = lv_output
      ).

      out->write(
        |TEST CASE: | && lv_index && cl_abap_char_utilities=>newline &&
        |TEMPLATE:| && lv_template && cl_abap_char_utilities=>newline &&
        |OUTPUT:|
        ).

      DATA(lo_mustache) = zcl_mustache=>create( lv_template ).
      CASE lv_index.
        WHEN 1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 10.
          out->write( lo_mustache->render( ls_simple ) ).
        WHEN 8 OR 9.
          out->write( lo_mustache->render_tt( lt_complex1 ) ).
        WHEN 11.
          out->write( lo_mustache->render_tt( lt_complex2 ) ).
      ENDCASE.
      out->write( cl_abap_char_utilities=>newline ).

      i = i + 1.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
