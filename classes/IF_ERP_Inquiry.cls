public with sharing class IF_ERP_Inquiry {
    public IF_ERP_Inquiry() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Inquiry';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    // SFDC interface Id    : IF-OPTY-006
    // AS-IS RFC            : Z_SD_MS_IQ_CRE
    // New I/F              : ZCRM_SD_MS_IQ_CRE       
    // Description          : CRM에서 일반 Inquiry 생성 후 ERP에 전송
    public IF_ERP_Inquiry_Classes.IF_OPTY_006_Res IF_OPTY_006(IF_ERP_Inquiry_Classes.IF_OPTY_006_Req parameters){
        interfaceId = 'IF-OPTY-006';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Inquiry_Classes.IF_OPTY_006_Res response = 
            (IF_ERP_Inquiry_Classes.IF_OPTY_006_Res) JSON.deserialize(responseString, IF_ERP_Inquiry_Classes.IF_OPTY_006_Res.class);
        
        return response;
    }

    // SFDC interface Id    : IF-OPTY-007
    // AS-IS RFC            : Z_SD_MS_IQ_CHG       
    // New I/F              : ZCRM_SD_MS_IQ_CHG       
    // Description          : CRM에서 일반 Inquiry 수정 후 ERP에 전송 
    public IF_ERP_Inquiry_Classes.IF_OPTY_007_Res IF_OPTY_007(IF_ERP_Inquiry_Classes.IF_OPTY_007_Req parameters){
        interfaceId = 'IF-OPTY-007';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        // responseString  = responseString.substringAfter('"Output":').substringBeforeLast('}');                
        System.debug('responseString ::: ' + responseString);

        IF_ERP_Inquiry_Classes.IF_OPTY_007_Res response = 
            (IF_ERP_Inquiry_Classes.IF_OPTY_007_Res) JSON.deserialize(responseString, IF_ERP_Inquiry_Classes.IF_OPTY_007_Res.class);

        System.debug(':::::::::::::    RESULT');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');     
        System.debug(':::::::::::::  REQUEST =>');
        System.debug(':::::::::::::    {');
        System.debug(':::::::::::::    '+parametersString);
        System.debug(':::::::::::::    } ');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');            
        System.debug(':::::::::::::  RESPONSE =>');
        System.debug(':::::::::::::    {');
        System.debug(':::::::::::::    '+JSON.serialize(response));
        System.debug(':::::::::::::    } ');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_MAT_REQUEST_LIST');
        
        
        return response;
    }

    /** SFDC interface Id   : IF-OPTY-008
     * New I/F              : ZCRM_SD_MS_IQ_LST
     * Description          : 일반/시스템 Inquiry 정보 반환하여 ERP & CRM 데이터 동기화 (생성, 수정)
        */
        public IF_ERP_Inquiry_Classes.IF_OPTY_008_Res IF_OPTY_008(IF_ERP_Inquiry_Classes.IF_OPTY_008_Req parameters){
            interfaceId = 'IF-OPTY-008';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}';
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Inquiry_Classes.IF_OPTY_008_Res response = 
                (IF_ERP_Inquiry_Classes.IF_OPTY_008_Res) JSON.deserialize(responseString, IF_ERP_Inquiry_Classes.IF_OPTY_008_Res.class);
            
            return response;
        }

    /** SFDC interface Id   : IF-OPTY-022
     * New I/F              : ZCRM_SD_SET_SQ_MASTER
     * Description          : SQ 연동
        */
        public IF_ERP_Inquiry_Classes.IF_OPTY_022_Res IF_OPTY_022(IF_ERP_Inquiry_Classes.IF_OPTY_022_Req parameters){
            interfaceId = 'IF-OPTY-022';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}';
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
                    IF_ERP_Inquiry_Classes.IF_OPTY_022_Res response = 
                        (IF_ERP_Inquiry_Classes.IF_OPTY_022_Res) JSON.deserialize(responseString, IF_ERP_Inquiry_Classes.IF_OPTY_022_Res.class);
            
                    System.debug(':::::::::::::    RESULT');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');     
                    System.debug(':::::::::::::  REQUEST =>');
                    System.debug(':::::::::::::    {');
                    System.debug(':::::::::::::    '+parametersString);
                    System.debug(':::::::::::::    } ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');            
                    System.debug(':::::::::::::  RESPONSE =>');
                    System.debug(':::::::::::::    {');
                    System.debug(':::::::::::::    '+JSON.serialize(response));
                    System.debug(':::::::::::::    } ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_MAT_REQUEST_LIST');
            return response;


            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }
}