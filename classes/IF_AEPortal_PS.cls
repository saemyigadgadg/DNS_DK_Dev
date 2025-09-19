public with sharing class IF_AEPortal_PS {
    public IF_AEPortal_PS() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_AEPortal_PS';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    /** SFDC interface Id   : IF-OPTY-013
     * New I/F              : 
     * Description          : 
        */
        public IF_AEPortal_PS_Classes.IF_OPTY_013_Res IF_OPTY_013(IF_AEPortal_PS_Classes.IF_OPTY_013_Req parameters){
            interfaceId = 'IF-OPTY-013';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}';

            // parametersString = parametersString.replaceAll('\\\\', '\\\\\\\\');
            parametersString = parametersString.replaceAll('\r\n', '\\\\r\\\\n');
            interfaceUtil.isURLEncode = true;

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_AEPortal_PS_Classes.IF_OPTY_013_Res response = 
                (IF_AEPortal_PS_Classes.IF_OPTY_013_Res) JSON.deserialize(responseString, IF_AEPortal_PS_Classes.IF_OPTY_013_Res.class);

            return response;
        } 

    /** SFDC interface Id   : IF-OPTY-016
     * Description          : AE Portal file 전송
     * 
     * Example 
     * FILE_NAME    : Sample.txt
     * INQUIRY_SEQ  : 15655
     * DOWNLOAD_URL : https://dn-solutions--dev.sandbox.my.salesforce.com/sfc/p/F700000020D3/a/F70000001M6F/Ch9sp_buGSsxha.n8OTlJSf3oYrPxXFZHYtQ6IF3RuY
     * INQUIRY_ID   : 006F700000HEFO1IAP
        */
        public void IF_OPTY_016(List<IF_AEPortal_PS_Classes.IF_OPTY_016_Req> parameters){

            for (IF_AEPortal_PS_Classes.IF_OPTY_016_Req req : parameters) req.ATTACH_SEQ      = 0;

            interfaceId = 'IF-OPTY-016';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';

            interfaceUtil.isURLEncode = true;

            interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        }
}