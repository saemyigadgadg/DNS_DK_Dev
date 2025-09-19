public with sharing class IF_ERP_Parts_receivable {
    public IF_ERP_Parts_receivable() {}
    
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    
    private String  apexClassName = 'IF_ERP_Parts_receivable';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    /**  SFDC interface Id  : IF-PARTS-020
     * AS-IS RFC            : Z_EP_INVOICE_LIST2
     * New I/F              : ZCRM_EP_INVOICE_LIST2
     * Description          : 외상매입금 리스트 조회
        */
        public IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res IF_PARTS_020(IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Req parameters){
            interfaceId = 'IF-PARTS-020';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res response = 
                (IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res) JSON.deserialize(responseString, IF_ERP_Parts_receivable_Classes.IF_PARTS_020_Res.class);
            
            return response;
        }

    // SFDC interface Id    : IF-PARTS-023
    // AS-IS RFC            : ZSS_RECV_EP_INVOICE_DETAIL
    // New I/F              : ZCRM_SS_RECV_EP_INVOICE_DETAIL
    // Description          : Parts > 채무현황 > 외상매입금 리스트
    public IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res IF_PARTS_023(IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Req parameters){
        interfaceId = 'IF-PARTS-023';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res response = 
            (IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res) JSON.deserialize(responseString, IF_ERP_Parts_receivable_Classes.IF_PARTS_023_Res.class);
        
        return response;
    }
}