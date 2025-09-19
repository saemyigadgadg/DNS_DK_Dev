public with sharing class IF_ERP_ShipmentOrder {
    public IF_ERP_ShipmentOrder() {}
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_ShipmentOrder';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

/** IF_CSPLUS_029
    */  
    /**
         * Apex Class           : IF_ERP_ShipmentOrder
         * Wrapper Class        : IF_ERP_ShipmentOrder_Classes
         * Wrapper Name         : IF_CSPLUS_029
         * SFDC interface Id    : IF-CSPLUS-029
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_CS_MT_GET_SHIPPING_DOC_IN
         * Description          : 장비의 출하지시서 조회  - 기존 출하지시서 I/F(5건) 통합으로 신규 생성 
         * KeyValue             : X
         * NOT NULL             : X
     */              
    /** REQUEST 
      */    
     /** REQUEST 
      */    
      public IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res IF_CSPLUS_029(IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Req parameters){
        interfaceId = 'IF-CSPLUS-029';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res response = 
            (IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res) JSON.deserialize(responseString, IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res.class);

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
        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_GET_SHIPPING_DOC_IN');
        
        return response;
    }



}