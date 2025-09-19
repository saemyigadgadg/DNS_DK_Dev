public with sharing class IF_ERP_Parts_Pending {
    public IF_ERP_Parts_Pending() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Parts_Pending';
    private Boolean isResponseXml = true; 
    private String  interfaceId;

    /** SFDC interface Id    : IF-PARTS-021
     * RFC Name              : ZCRM_EP_SUSPENSE_LIST_ME
     * Description           : (채무현황)미결 현황 조회
        */
        public IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res IF_PARTS_021(IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Req parameters){
            interfaceId = 'IF-PARTS-021';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res response = 
                (IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res) JSON.deserialize(responseString, IF_ERP_Parts_Pending_Classes.IF_PARTS_021_Res.class);
            
            return response;
        }
}