class ZCL_ZEPM_BP_DPC_EXT definition
  public
  inheriting from ZCL_ZEPM_BP_DPC
  create public .

public section.
protected section.

  methods EPMBUSINESSPARTN_GET_ENTITYSET
    redefinition .
  methods EPMBUSINESSPARTN_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZEPM_BP_DPC_EXT IMPLEMENTATION.


  METHOD epmbusinesspartn_get_entity.
    DATA: lv_bp_id  TYPE bapi_epm_bp_id,
          lt_return TYPE STANDARD TABLE OF bapiret2,
          lt_errors TYPE STANDARD TABLE OF bapiret2.

    DATA(lt_keys) = io_tech_request_context->get_keys( ).
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>) INDEX 1.


    IF <fs_key> IS ASSIGNED.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_key>-value
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
      LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
        WHERE type = 'E'.
        APPEND <fs_return> TO lt_errors.
      ENDLOOP.

      IF lt_errors IS NOT INITIAL.
        DATA(lr_msg_cont) =
            /iwbep/cl_mgw_msg_container=>get_mgw_msg_container( ).

        lr_msg_cont->add_messages_from_bapi(
          EXPORTING
            it_bapi_messages          = lt_errors
        ).
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
