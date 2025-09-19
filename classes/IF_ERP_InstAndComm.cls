public with sharing class IF_ERP_InstAndComm {
    public IF_ERP_InstAndComm() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_InstAndComm';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

/** IF-CSPLUS-036
    */  
    /**
         * Apex Class           : IF_ERP_InstAndComm
         * Wrapper Class        : IF_ERP_InstAndComm_Classes
         * Wrapper Name         : IF-CSPLUS-036
         * SFDC interface Id    : IF_CSPLUS_036
         * New I/F              : ZCRM_CS_WORKORDER_INSTALL
         * Description          : WorkOrder 생성 및 수정
         * KeyValue             : X
         * NOT NULL             : X
     */  
        public IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res IF_CSPLUS_036(IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Req parameters){
            interfaceId = 'IF-CSPLUS-036';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}';
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            try {

                IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res response = 
                (IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res) JSON.deserialize(responseString, IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res.class);
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WORKORDER_INSTALL');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;
            }
        }
    
    /** SFDC interface Id   : IF-CSPLUS-043
     * RFC Name             : ZCRM_CS_WORKORDER_INSTALL_CHG
     * Description          : 설치시운전 오더 수정
        */
        public IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res IF_CSPLUS_043(IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Req parameters){
            interfaceId = 'IF-CSPLUS-043';

            if(parameters.I_SOLDTO  != null) parameters.I_SOLDTO = '000' + parameters.I_SOLDTO;
            if(parameters.I_AUFNR   != null) parameters.I_AUFNR  = '000' + parameters.I_AUFNR;
            if(parameters.I_PARNR   != null) parameters.I_PARNR  = '000' + parameters.I_PARNR;

            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}';
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            try {

                IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res response = 
                    (IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res) JSON.deserialize(responseString, IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res.class);

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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WORKORDER_INSTALL');
                return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;
            }
        }
}