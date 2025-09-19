public with sharing class IF_ERP_Parts_Shipping {
    public IF_ERP_Parts_Shipping() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Parts_Shipping';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    /** SFDC interface Id    : IF-PARTS-002
     *  AS-IS RFC            : Z_EP_SHIPPING_INFO
     *  New I/F              : ZCRM_EP_SHIPPING_INFO
     *  Description          : 배송정보 목록 가져오기
        */
        public IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res IF_PARTS_002(IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Req parameters){
            parameters.I_LANG = interfaceUtil.getLanguageKey(parameters.I_LANG);

            interfaceId = 'IF-PARTS-002';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res response = 
                (IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res) JSON.deserialize(responseString, IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res.class);

            System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
            System.debug(':::::::::::::    RFC NAME     : ZCRM_EP_SHIPPING_INFO');
            System.debug(':::::::::::::    CLASS NAME   : '+apexClassName);                  
            
            return response;
        }
    
    // SFDC interface Id    : IF-PARTS-014
    // AS-IS RFC            : Z_CS_GET_DELIVERY_STAT_SHIP_NO
    // New I/F              : ZCRM_CS_GET_DELIVERY_STAT_SHIP_NO
    // Description          : 배송번호 조회
    public IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res IF_PARTS_014(IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Req parameters){
        interfaceId = 'IF-PARTS-014';
        String parametersString = 'InputParam=' 
                                    + '{"Input":'
                                    + JSON.serialize(parameters)
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res response = 
            (IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res) JSON.deserialize(responseString, IF_ERP_Parts_Shipping_Classes.IF_PARTS_014_Res.class);
        
        return response;
    }

    // SFDC interface Id    : IF-PARTS-015
    // AS-IS RFC            : Z_EP_SHIPMENT_LIST2
    // New I/F              : ZCRM_EP_SHIPMENT_LIST2
    // Description          : 배송상태 조회
    public IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res IF_PARTS_015(IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req parameters){
        parameters.I_LANGU = interfaceUtil.getLanguageKey(parameters.I_LANGU);

        interfaceId = 'IF-PARTS-015';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}';

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res response = 
            (IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res) JSON.deserialize(responseString, IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res.class);
        
        return response;
    }

    /** SFDC interface Id    : IF-PARTS-027
     *  AS-IS RFC            : ZCRM_EP_SHIPMENT_DETAIL 
     *  Description          : 배송세부정보 조회
        */
        public IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res IF_PARTS_027(IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Req parameters){

            interfaceId = 'IF-PARTS-027';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}';

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res response = 
                (IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res) JSON.deserialize(responseString, IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res.class);
            
            return response;
        }

    
}