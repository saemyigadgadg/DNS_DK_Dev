public with sharing class IF_ERP_Board {
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Board';
    private Boolean isResponseXml = true;  
    private String  interfaceId;
    public IF_ERP_Board() {}




/** IF-CSPLUS-030
    */  
    /**
     * Apex Class           : IF_ERP_Board
     * Wrapper Class        : IF_ERP_Board_Classes
     * Wrapper Name         : IF-CSPLUS-030
     * SFDC interface Id    : IF_CSPLUS_030
     * AS-IS RFC            : Z_CS_MT_WORK_RESULT_CANCEL
     * New I/F              : ZCRM_CS_WORK_TIME_CANCEL
     * Description          : 출동 수리-서비스요원 출발/도착 취소
     * KeyValue             : X
     * NOT NULL             : X
    */   
    public IF_ERP_Board_Classes.IF_CSPLUS_030_Res IF_CSPLUS_030(
        IF_ERP_Board_Classes.IF_CSPLUS_030_Req parameters){
            interfaceId = 'IF-CSPLUS-030';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            try {
                IF_ERP_Board_Classes.IF_CSPLUS_030_Res response = 
                (IF_ERP_Board_Classes.IF_CSPLUS_030_Res) JSON.deserialize(responseString, IF_ERP_Board_Classes.IF_CSPLUS_030_Res.class);
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WORK_TIME_CANCEL');

                return response;

            } catch (Exception e) {
               System.debug('EXCEPTION MESSAGE : '+e.getMessage());
               System.debug('EXCEPTION LINE  : '+e.getLineNumber()); 
               return null;            
            }        
    }    
    
}