public with sharing class IF_ERP_Parts_Order {
    public IF_ERP_Parts_Order() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Parts_Order';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    // SFDC interface Id    : IF-PARTS-001
    // AS-IS RFC            : Z_EP_GET_ORDERTYPE2
    // New I/F              : ZCRM_EP_GET_ORDERTYPE2
    // Description          : 주문유형 Code 값 조회 및 저장
    public IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res IF_PARTS_001(IF_ERP_Parts_Order_Classes.IF_PARTS_001_Req parameters){
        parameters.I_LANG = interfaceUtil.getLanguageKey(parameters.I_LANG);
        interfaceId = 'IF-PARTS-001';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res response = 
            (IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_001_Res.class);
        
        return response;
    }

    // SFDC interface Id    : IF-PARTS-003
    // AS-IS RFC            : Z_EP_ORDER_SIMULATION
    // New I/F              : ZCRM_EP_ORDER_SIMULATION
    // Description          : 부품 오더 조회
    public IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res IF_PARTS_003(IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req parameters){
        interfaceId = 'IF-PARTS-003';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}'; 

        interfaceUtil.isIF_Case = true;
        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res response = 
            (IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res.class);
        
        return response;
    }

    // SFDC interface Id    : IF-PARTS-005
    // AS-IS RFC            : Z_EP_PARTS_ORDER_CREATE
    // New I/F              : ZCRM_EP_PARTS_ORDER_CREATE
    // Description          : (대리점=> DNS) 오더 생성을 위한 I/F 호출
    public IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res IF_PARTS_005(IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req parameters){
        parameters.I_USERID = interfaceUtil.getERPKey();

        interfaceId = 'IF-PARTS-005';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}'; 

        interfaceUtil.isIF_Case = true;
        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res response = 
            (IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res.class);
        
        return response;
    }

    /** SFDC interface Id   : IF-PARTS-007
     * AS-IS RFC            : Z_EP_ORDERLIST_ME
     * New I/F              : ZCRM_EP_ORDERLIST_ME
     * Description          : 오더 조회
        */
        public IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res IF_PARTS_007(IF_ERP_Parts_Order_Classes.IF_PARTS_007_Req parameters){


            interfaceId = 'IF-PARTS-007';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res response = 
                (IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_007_Res.class);
            
            return response;
        }

    /** SFDC interface Id   : IF-PARTS-008
     * AS-IS RFC            : Z_EP_ORDER_LOAD2
     * New I/F              : ZCRM_EP_ORDER_LOAD2
     * Description          : 오더 상세 조회
        */
        public IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res IF_PARTS_008(IF_ERP_Parts_Order_Classes.IF_PARTS_008_Req parameters){
            interfaceId = 'IF-PARTS-008';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res response = 
                (IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_008_Res.class);
            
            return response;
        }
    
    // SFDC interface Id    : IF-PARTS-009
    // AS-IS RFC            : Z_EP_ORDER_SIMULATION_MASS
    // New I/F              : ZCRM_EP_ORDER_SIMULATION_MASS
    // Description          : 부품 주문 -> 오더생성 -> Simulation 버튼을 통해 부품 정보 조회
    public IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res IF_PARTS_009(IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req parameters){
        interfaceId = 'IF-PARTS-009';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}'; 

        interfaceUtil.isIF_Case = true;
        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res response = 
            (IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res.class);
        
        return response;
    }

    // SFDC interface Id    : IF-PARTS-012
    // AS-IS RFC            : Z_EP_ORDERSTATUS_INFO2
    // New I/F              : ZCRM_EP_ORDERSTATUS_INFO2
    // Description          : 오더 상태 목록 조회
    public IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res IF_PARTS_012(IF_ERP_Parts_Order_Classes.IF_PARTS_012_Req parameters){
        interfaceId = 'IF-PARTS-012';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res response = 
            (IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_012_Res.class);
        
        return response;
    }

    // SFDC interface Id    : IF-PARTS-013
    // AS-IS RFC            : Z_EP_STATUS_INFO_DETAIL2
    // New I/F              : ZCRM_EP_STATUS_INFO_DETAIL2
    // Description          : 오더 상태 상세 조회를 위한 I/F 호출
    public IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res IF_PARTS_013(IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req parameters){
        interfaceId = 'IF-PARTS-013';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res response = 
            (IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res.class);
        
        return response;
    }

    /** SFDC interface Id   : IF-PARTS-026
     * RFC Name             : ZCRM_SS_RECV_CHANGE_EMERGENCY
     * Description          : 오더상세 화면에서 상태 저장
        */
        public IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res IF_PARTS_026(IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req parameters){
            interfaceId = 'IF-PARTS-026';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res response = 
                (IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res.class);
            
            return response;
        } 

    /** SFDC interface Id   : IF-PARTS-034
     * RFC Name             : ZCRM_EP_ORDER_LIST_DETAIL
     * Description          : 부품 주문 데이터 ERP – CRM 동기화
        */
        public IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res IF_PARTS_034(IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req parameters){
            interfaceId = 'IF-PARTS-034';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res response = 
                (IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res) JSON.deserialize(responseString, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res.class);
            
            return response;
        } 
}