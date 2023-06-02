CLASS znov05_cl_mustache_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
* remove "for testing" so that it can be called

  PUBLIC SECTION.

    CONSTANTS c_nl TYPE c VALUE cl_abap_char_utilities=>newline.

    TYPES:
      BEGIN OF ty_dummy,
        name TYPE string,
        am   TYPE abap_bool,
        pm   TYPE abap_bool,
        html TYPE string,
        tab  TYPE string_table,
        obj  TYPE REF TO zcl_mustache_utils,
        BEGIN OF attr,
          age    TYPE i,
          male   TYPE abap_bool,
          female TYPE abap_bool,
        END OF attr,
      END OF ty_dummy,

      BEGIN OF ty_size,
        size TYPE c LENGTH 4,
        qty  TYPE i,
      END OF ty_size,
      ty_size_tt TYPE STANDARD TABLE OF ty_size WITH DEFAULT KEY,

      BEGIN OF ty_item,
        name  TYPE string,
        price TYPE string,
        sizes TYPE ty_size_tt,
      END OF ty_item,
      ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY,

      BEGIN OF ty_tag_rc,
        val TYPE string,
        rc  TYPE c LENGTH 4,
      END OF ty_tag_rc,
      ty_tag_rc_tt TYPE STANDARD TABLE OF ty_tag_rc WITH DEFAULT KEY,

      BEGIN OF ty_test_case,
        template     TYPE string,
        tokens       TYPE zif_mustache=>ty_token_tt,
        output       TYPE string,
        complex_test TYPE abap_bool,
      END OF ty_test_case,
      ty_test_case_tt TYPE STANDARD TABLE OF ty_test_case WITH DEFAULT KEY.


    CLASS-METHODS get_test_case
      IMPORTING iv_index        TYPE i OPTIONAL
      EXPORTING ev_count        TYPE i
                ev_complex_test TYPE c
                ev_template     TYPE string
                et_tokens       TYPE zif_mustache=>ty_token_tt
                ev_output       TYPE string.
    CLASS-METHODS get_test_data
      EXPORTING es_simple   TYPE ty_dummy
                et_complex1 TYPE zif_mustache=>ty_struc_tt
                et_complex2 TYPE zif_mustache=>ty_struc_tt.

    CLASS-METHODS class_constructor.


  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_test_case_stash TYPE ty_test_case_tt.

ENDCLASS.



CLASS znov05_cl_mustache_test IMPLEMENTATION.


  METHOD class_constructor.

    FIELD-SYMBOLS: <t>     LIKE LINE OF gt_test_case_stash,
                   <token> LIKE LINE OF <t>-tokens.

    " Case 1
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = 'Hello {{name}}!'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Hello ` )
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `name` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = `!` )
    ).
    <t>-output = 'Hello Anonymous network user!'.

    " Case 2
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = 'Hello {{name}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Hello ` )
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `name` )
    ).
    <t>-output = 'Hello Anonymous network user'.

    " Case 3
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = '{{name}} Hello'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `name` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = ` Hello` )
    ).
    <t>-output = 'Anonymous network user Hello'.

    " Case 4
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = 'Good {{#pm}}afternoon{{/pm}}{{^pm}}morning{{/pm}}, {{name}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Good ` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 1 content = `pm` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `afternoon` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-ifnot level = 1 content = `pm` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `morning` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = `, ` )
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `name` )
    ).
    <t>-output = 'Good afternoon, Anonymous network user'.

    " Case 5
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = 'Good {{^am}}afternoon{{/am}}{{#am}}morning{{/am}}, {{name}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Good ` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-ifnot level = 1 content = `am` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `afternoon` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 1 content = `am` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `morning` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = `, ` )
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `name` )
    ).
    <t>-output = 'Good afternoon, Anonymous network user'.

    " Case 6
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = '{{!comment}}{{html}} {{{html}}} {{&html}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `html` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = ` ` )
      ( type = zif_mustache=>c_token_type-utag level = 1 content = `html` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = ` ` )
      ( type = zif_mustache=>c_token_type-utag level = 1 content = `html` )
    ).
    <t>-output = '&lt;tag&gt;&amp; <tag>& <tag>&'.

    " Case 7
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = '{{pm}}{{=<* *>=}}<*pm*>{{xx}}<*={{ }}=*>{{pm}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `pm` )
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `pm` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = `{{xx}}` )
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `pm` )
    ).
    <t>-output = 'XX{{xx}}X'.

    " Case 8
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-complex_test = '1'.
    <t>-template = 'Welcome to {{shop}}'                    && "c_nl &&
                   'Our sales:'                             && "c_nl &&
                   '{{#items}}'                             && "c_nl &&
                   '* {{name}} - ${{price}}'                && "c_nl &&
                   '  sizes: {{#sizes}}{{size}},{{/sizes}}' && "c_nl &&
                   '{{/items}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Welcome to ` )
      ( type = zif_mustache=>c_token_type-etag level = 1 content = `shop` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Our sales:` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 1 content = `items` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `* ` )
      ( type = zif_mustache=>c_token_type-etag level = 2 content = `name` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = ` - $` )
      ( type = zif_mustache=>c_token_type-etag level = 2 content = `price` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `  sizes: ` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 2 content = `sizes` )
      ( type = zif_mustache=>c_token_type-etag level = 3 content = `size` )
      ( type = zif_mustache=>c_token_type-static level = 3 content = `,` )
    ).
    <t>-output   = 'Welcome to Shopsky'                     && "c_nl &&
                   'Our sales:'                             && "c_nl &&
                   '* Boots - $99.00'                       && "c_nl &&
                   '  sizes: 40,41,42,'                     && "c_nl &&
                   '* T-short - $49.00'                     && "c_nl &&
                   '  sizes: S,M,L,'.

    " Case 9 - newlines and lonely section
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-complex_test = '1'.
    <t>-template = 'Our sales:'                             && c_nl &&
                   `  {{#items}}  `                         && c_nl &&
                   '* {{name}} - ${{price}}'                && c_nl &&
                   `  {{/items}}  `.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Our sales:` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = c_nl )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 1 content = `items` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `* ` )
      ( type = zif_mustache=>c_token_type-etag level = 2 content = `name` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = ` - $` )
      ( type = zif_mustache=>c_token_type-etag level = 2 content = `price` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = c_nl )
    ).
    <t>-output   = 'Our sales:'                             && c_nl &&
                   '* Boots - $99.00'                       && c_nl &&
                   '* T-short - $49.00'                     && c_nl.

    " Case 10
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-template = '{{#tab}}{{@tabline}},{{/tab}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 1 content = `tab` )
      ( type = zif_mustache=>c_token_type-etag level = 2 content = `@tabline` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `,` )
    ).
    <t>-output = 'line1,line2,'.

    " Case 11 - empty table, -first/-last
    APPEND INITIAL LINE TO gt_test_case_stash ASSIGNING <t>.
    <t>-complex_test = '2'.
    <t>-template =
       'Our sales:'                             && c_nl &&
       '{{#items}}'                             && c_nl &&
       '* {{name}} - ${{price}}'                && c_nl &&
       '  sizes: {{#sizes}}{{^@first}}, {{/@first}}{{size}}{{#@last}}.{{/@last}}{{/sizes}}{{^sizes}}all sold out{{/sizes}}' && c_nl &&
       '{{/items}}'.
    <t>-tokens = VALUE #(
      ( type = zif_mustache=>c_token_type-static level = 1 content = `Our sales:` )
      ( type = zif_mustache=>c_token_type-static level = 1 content = c_nl )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 1 content = `items` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = `* ` )
      ( type = zif_mustache=>c_token_type-etag level = 2 content = `name` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = ` - $` )
      ( type = zif_mustache=>c_token_type-etag level = 2 content = `price` )
      ( type = zif_mustache=>c_token_type-static level = 2 content = c_nl )

      ( type = zif_mustache=>c_token_type-static level = 2 content = `  sizes: ` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 2 content = `sizes` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-ifnot level = 3 content = `@first` )
      ( type = zif_mustache=>c_token_type-static level = 4 content = `, ` )
      ( type = zif_mustache=>c_token_type-etag level = 3 content = `size` )
      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-if level = 3 content = `@last` )
      ( type = zif_mustache=>c_token_type-static level = 4 content = `.` )


      ( type = zif_mustache=>c_token_type-section cond = zif_mustache=>c_section_condition-ifnot level = 2 content = `sizes` )
      ( type = zif_mustache=>c_token_type-static level = 3 content = `all sold out` )

      ( type = zif_mustache=>c_token_type-static level = 2 content = c_nl )

    ).
    <t>-output   = 'Our sales:'                            && c_nl &&
                   '* 3-Hole - $100'                       && c_nl &&
                   '  sizes: 37, 40, 42.'                  && c_nl &&
                   '* 6-Hole - $200'                       && c_nl &&
                   '  sizes: all sold out'                 && c_nl.
  ENDMETHOD.  " class_setup.


  METHOD get_test_case.

    FIELD-SYMBOLS: <t>     LIKE LINE OF gt_test_case_stash.

    IF ev_count IS REQUESTED.
      ev_count = lines( gt_test_case_stash ).
    ENDIF.

    IF iv_index IS INITIAL.
      RETURN. " Nothing else requested
    ENDIF.

    READ TABLE gt_test_case_stash INDEX iv_index ASSIGNING <t>.

    ev_complex_test = <t>-complex_test.
    ev_template     = <t>-template.
    et_tokens       = <t>-tokens.
    ev_output       = <t>-output.

  ENDMETHOD. "get_test_case


  METHOD get_test_data.

    FIELD-SYMBOLS: <data> LIKE LINE OF et_complex1,
                   <tab>  TYPE ty_item_tt,
                   <item> LIKE LINE OF <tab>,
                   <size> TYPE ty_size.

    " Simple data
    es_simple-name = 'Anonymous network user'.
    es_simple-am   = abap_false.
    es_simple-pm   = abap_true.
    es_simple-html = '<tag>&'.
    CREATE OBJECT es_simple-obj.
    APPEND 'line1' TO es_simple-tab.
    APPEND 'line2' TO es_simple-tab.

    " Complex data
    CLEAR et_complex1.

    APPEND INITIAL LINE TO et_complex1 ASSIGNING <data>.
    <data>-name = 'shop'.
    <data>-val  = 'Shopsky'.
    APPEND INITIAL LINE TO et_complex1 ASSIGNING <data>.
    <data>-name = 'items'.
    CREATE DATA <data>-dref TYPE ty_item_tt.

    ASSIGN <data>-dref->* TO <tab>.

    " Boots
    APPEND INITIAL LINE TO <tab> ASSIGNING <item>.
    <item>-name  = 'Boots'.
    <item>-price = '99.00'.
    APPEND INITIAL LINE TO <item>-sizes ASSIGNING <size>.
    <size>-size = '40'.
    <size>-qty  = 8.
    APPEND INITIAL LINE TO <item>-sizes ASSIGNING <size>.
    <size>-size = '41'.
    <size>-qty  = 12.
    APPEND INITIAL LINE TO <item>-sizes ASSIGNING <size>.
    <size>-size = '42'.
    <size>-qty  = 3.

    "T-short
    APPEND INITIAL LINE TO <tab> ASSIGNING <item>.
    <item>-name  = 'T-short'.
    <item>-price = '49.00'.
    APPEND INITIAL LINE TO <item>-sizes ASSIGNING <size>.
    <size>-size = 'S'.
    <size>-qty  = 15.
    APPEND INITIAL LINE TO <item>-sizes ASSIGNING <size>.
    <size>-size = 'M'.
    <size>-qty  = 23.
    APPEND INITIAL LINE TO <item>-sizes ASSIGNING <size>.
    <size>-size = 'L'.
    <size>-qty  = 18.

    " Complexer data
    et_complex2 = VALUE #( ( name = 'shop' val  = 'Shopsky' ) ( name = 'items' dref = NEW ty_item_tt(
      ( name = '3-Hole' price = '100' sizes = VALUE #( ( size = '37' qty = 2 ) ( size = '40' qty = 3 ) ( size = '42' qty = 4 ) ) )
      ( name = '6-Hole' price = '200' )
    ) ) ).
  ENDMETHOD. "get_test_data
ENDCLASS.
