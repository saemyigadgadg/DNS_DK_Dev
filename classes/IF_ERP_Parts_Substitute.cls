public with sharing class IF_ERP_Parts_Substitute {
    public IF_ERP_Parts_Substitute() {}

    public InterfaceCommonUtil interfaceUtil = new InterfaceCommonUtil();
    private String  apexClassName = 'IF_ERP_Parts_Substitute';
    private Boolean isResponseXml = true; 
    private String  interfaceId;

    // SFDC interface Id    : IF-PARTS-004
    // AS-IS RFC            : Z_SD_PREPARE_TOGETHER_PARTS
    // New I/F              : ZCRM_SD_PREPARE_TOGETHER_PARTS
    // Description          : 대체품 조회를 위한 I/F 호출 
    public IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res IF_PARTS_004(IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req parameters){
        interfaceId = 'IF-PARTS-004';
        String parametersString = 'InputParam='
                                    + '{"Input":'
                                    + JSON.serialize(parameters)
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res response = 
            (IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res) JSON.deserialize(responseString, IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res.class);
        
        return response;
    }
}