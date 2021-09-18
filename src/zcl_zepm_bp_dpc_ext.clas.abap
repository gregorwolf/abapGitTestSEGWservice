CLASS zcl_zepm_bp_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zepm_bp_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~get_stream
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~update_stream
        REDEFINITION .
  PROTECTED SECTION.

    METHODS epmbusinesspartn_get_entity
        REDEFINITION .
    METHODS epmbusinesspartn_get_entityset
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_zepm_bp_dpc_ext IMPLEMENTATION.

  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.
    super->/iwbep/if_mgw_appl_srv_runtime~get_stream(
      EXPORTING
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        it_key_tab              = it_key_tab
        it_navigation_path      = it_navigation_path
        io_tech_request_context = io_tech_request_context
      IMPORTING
        er_stream               = er_stream
        es_response_context     = es_response_context ).
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~update_stream.
    super->/iwbep/if_mgw_appl_srv_runtime~update_stream(
        iv_entity_name          = iv_entity_name
        iv_entity_set_name      = iv_entity_set_name
        iv_source_name          = iv_source_name
        is_media_resource       = is_media_resource
        it_key_tab              = it_key_tab
        it_navigation_path      = it_navigation_path
        io_tech_request_context = io_tech_request_context ).
  ENDMETHOD.


  METHOD epmbusinesspartn_get_entity.
    DATA: lv_bp_id  TYPE bapi_epm_bp_id,
          lt_return TYPE STANDARD TABLE OF bapiret2,
          lt_errors TYPE STANDARD TABLE OF bapiret2.

    DATA(lt_keys) = io_tech_request_context->get_keys( ).
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<ls_key>) INDEX 1.

    IF <ls_key> IS ASSIGNED.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <ls_key>-value
        IMPORTING
          output = lv_bp_id.

      CALL FUNCTION 'BAPI_EPM_BP_GET_DETAIL'
        EXPORTING
          bp_id      = lv_bp_id
        IMPORTING
          headerdata = er_entity
        TABLES
          return     = lt_return.

      " Collect Errors
      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>) WHERE type = 'E'.
        APPEND <ls_return> TO lt_errors.
      ENDLOOP.

      IF lt_errors IS NOT INITIAL.
        DATA(lr_msg_cont) =
            /iwbep/cl_mgw_msg_container=>get_mgw_msg_container( ).

        lr_msg_cont->add_messages_from_bapi( it_bapi_messages = lt_errors ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = lr_msg_cont.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD epmbusinesspartn_get_entityset.
    CALL FUNCTION 'BAPI_EPM_BP_GET_LIST'
      TABLES
        bpheaderdata = et_entityset.
  ENDMETHOD.
ENDCLASS.