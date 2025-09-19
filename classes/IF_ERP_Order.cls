public with sharing class IF_ERP_Order {
    public IF_ERP_Order() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String              apexClassName = 'IF_ERP_Order';
    private Boolean             isResponseXml = true;  
    private String              interfaceId;

    /**
         * Wrapper Name         : IF_ORDER_001
         * SFDC interface Id    : IF-ORDER-001
         * AS-IS RFC            : Z_SD_CREATE_SALES_ORDER_ME	
         * New I/F              : ZCRM_SD_CREATE_SALES_ORDER_ME
         * Description          : CRM에서 CPO 생성 후 ERP에 전송
     */

     public IF_ERP_Order_Classes.IF_ORDER_001_Res IF_ORDER_001(IF_ERP_Order_Classes.IF_ORDER_001_Req parameters){
        interfaceId = 'IF-ORDER-001';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}';

        interfaceUtil.isURLEncode = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
                             

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Order_Classes.IF_ORDER_001_Res response = 
                (IF_ERP_Order_Classes.IF_ORDER_001_Res) JSON.deserialize(responseString, IF_ERP_Order_Classes.IF_ORDER_001_Res.class);
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CREATE_SALES_ORDER_ME');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }


    }     

/**
IF-ORDER-004	
       @CLASS           : IF_ERP_Order_Classes
       @Date            : 2024-12-03
       @Writer          : 성서욱
       @RFCName         : ZCRM_SD_CHANGE_SALES_ORDER_ME
       @InterfaceId     : IF-ORDER-004
       @Description     : CRM에서 CPO 수정 정보 ERP에 전송(SQ 상태 변경시)
 */    
     public IF_ERP_Order_Classes.IF_ORDER_004_Res IF_ORDER_004(IF_ERP_Order_Classes.IF_ORDER_004_Req parameters){
        interfaceId = 'IF-ORDER-004';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Order_Classes.IF_ORDER_004_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_004_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_004_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CHANGE_SALES_ORDER_ME');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }    
    }    


// ** IF-ORDER-003				
/**
  */
  /**
         * Wrapper Name         : IF_ORDER_003
         * SFDC interface Id    : IF-ORDER-003
         * AS-IS RFC            : Z_SD_SALES_NOTICE_MACHINE	
         * New I/F              : ZCRM_SD_SALES_NOTICE_MACHINE
         * Description          : 수주통지서 항목 I/F 
  */        
    // ** METHOD
    /**
        */     
        public IF_ERP_Order_Classes.IF_ORDER_003_Res IF_ORDER_003(IF_ERP_Order_Classes.IF_ORDER_003_Req parameters){
                interfaceId = 'IF-ORDER-003';
                String parametersString = 'InputParam=' 
                                            + '{"Input":' 
                                            + JSON.serialize(parameters) 
                                            + '}'; 

                String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Order_Classes.IF_ORDER_003_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_003_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_003_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_SH_CRE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }    

// ** IF-ORDER-005				
/**
  */
  /**
         * Wrapper Name         : IF_ORDER_005
         * SFDC interface Id    : IF-ORDER-005
         * AS-IS RFC            : Z_SD_GET_PRICING_PROCESS_ME
         * New I/F              : ZCRM_SD_GET_PRICING_PROCESS_ME
         * Description          : Multi Model에 대한 Pricing 정보를 시뮬레이션
         * CAUTION              : DEFAULT, CURRENCY, NUMBER, SYSTEM
  */        
    // ** METHOD
    /**
        */                 
        public IF_ERP_Order_Classes_version02.IF_ORDER_005_Res IF_ORDER_005(IF_ERP_Order_Classes_version02.IF_ORDER_005_Req parameters){
            interfaceId = 'IF-ORDER-005';
            String parametersString = 'InputParam=' 
                                            + '{"Input":' 
                                            + JSON.serialize(parameters) 
                                            + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


            try {
                IF_ERP_Order_Classes_version02.IF_ORDER_005_Res response = 
                (IF_ERP_Order_Classes_version02.IF_ORDER_005_Res) JSON.deserialize(responseString, IF_ERP_Order_Classes_version02.IF_ORDER_005_Res.class);
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_PRICING_PROCESS_ME');  
                            
                return response;  


            } catch (TypeException e) {
                System.debug(e.getMessage());
                System.debug('LINE : '+e.getLineNumber());
                return null;
            }
      
            }               

/** IF_ORDER_008
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-008
         * SFDC interface Id    : IF_ORDER_008
         * AS-IS RFC            : Z_SD_GET_KIT_LIST_CAT
         * New I/F              : ZCRM_SD_GET_KIT_LIST_CAT_USA
         * Description          : Option Only Order 생성(Factory Order)-PKMT(모델)을 입력해서 추가자재 중분류를 가져오는 RFC
         * KeyValue             : X
         * NOT NULL             : X
     */            
     public IF_ERP_Order_Classes.IF_ORDER_008_Res IF_ORDER_008(IF_ERP_Order_Classes.IF_ORDER_008_Req parmeters){
        interfaceId = 'IF-ORDER-008';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {

            IF_ERP_Order_Classes.IF_ORDER_008_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_008_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_008_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_KIT_LIST_CAT_USA');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }
    
/** IF_ORDER_009
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-009
         * SFDC interface Id    : IF_ORDER_009
         * AS-IS RFC            : Z_SD_GET_KIT_LIST
         * New I/F              : ZCRM_SD_GET_KIT_LIST_USA
         * Description          : Option Only Order 생성(Factory Order)-추가자재 중분류(I_KIT_CAT)를 입력해서 세부 Kit 데이터를 가져오는 RFC
         * KeyValue             : X
         * NOT NULL             : X
     */            
    public IF_ERP_Order_Classes.IF_ORDER_009_Res IF_ORDER_009(IF_ERP_Order_Classes.IF_ORDER_009_Req parmeters){
        interfaceId = 'IF-ORDER-009';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {

            IF_ERP_Order_Classes.IF_ORDER_009_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_009_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_009_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_KIT_LIST_USA');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }          

/** IF-ORDER-010 
 *  RFC Name             : ZCRM_SD_BOOKING_LIST_USA
 *  Description          : Booking List Interface
    */
    public IF_ERP_Order_Classes.IF_ORDER_010_Res IF_ORDER_010(IF_ERP_Order_Classes.IF_ORDER_010_Req parmeters){
        interfaceId = 'IF-ORDER-010';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

                            
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_010_Res response = (IF_ERP_Order_Classes.IF_ORDER_010_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_010_Res.class);    

            return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }    

/** IF-ORDER-011
 *  RFC Name             : ZCRM_SD_BOOKING_LIST_USA
 *  Description          : Booking List Interface
    */
    public IF_ERP_Order_Classes.IF_ORDER_011_Res IF_ORDER_011(IF_ERP_Order_Classes.IF_ORDER_011_Req parmeters){
        interfaceId = 'IF-ORDER-011';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_011_Res response = (IF_ERP_Order_Classes.IF_ORDER_011_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_011_Res.class);    

            return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }      

/** IF_ORDER_012
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-012
         * SFDC interface Id    : IF_ORDER_012
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_SALES_ORDER_INFO_USA
         * Description          : DNSA의 Order 정보 Interface용 RFC
         * KeyValue             : X
         * NOT NULL             : X
     */            
    public IF_ERP_Order_Classes.IF_ORDER_012_Res IF_ORDER_012(IF_ERP_Order_Classes.IF_ORDER_012_Req parmeters){
        interfaceId = 'IF-ORDER-012';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {

            IF_ERP_Order_Classes.IF_ORDER_012_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_012_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_012_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_SALES_ORDER_INFO_USA');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }         

/** IF_ORDER_007
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-007
         * SFDC interface Id    : IF_ORDER_007
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_CREATE_SO_FCT_OPT_USA 
         * Description          : Real Sales Order 생성(Factory Order/Option Only Order )
     */
    public IF_ERP_Order_Classes.IF_ORDER_007_Res IF_ORDER_007(IF_ERP_Order_Classes.IF_ORDER_007_Req parmeters){
        interfaceId = 'IF-ORDER-007';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        // interfaceUtil.isu005CCase = true;
        // interfaceUtil.isu0024Case = true;
        interfaceUtil.isURLEncode = true;
        // parmetersString.replaceAll('%', '%%');
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {

            IF_ERP_Order_Classes.IF_ORDER_007_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_007_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_007_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CREATE_SO_FCT_OPT_USA');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }         

/** IF_ORDER_002
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-002
         * SFDC interface Id    : IF_ORDER_002
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_SEARCH_ORDER_LIST  
         * Description          : Real Sales Order 생성(Factory Order/Option Only Order )
     */
        public IF_ERP_Order_Classes.IF_ORDER_002_Res IF_ORDER_002(IF_ERP_Order_Classes.IF_ORDER_002_Req parmeters){
            interfaceId = 'IF-ORDER-002';            
            String parmetersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parmeters) 
                                + '}'; 

            String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
            
            try {

                IF_ERP_Order_Classes.IF_ORDER_002_Res response = 
                (IF_ERP_Order_Classes.IF_ORDER_002_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Order_Classes.IF_ORDER_002_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_SEARCH_ORDER_LIST');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        } 

/** IF_ORDER_014
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-014
         * SFDC interface Id    : IF-ORDER-014
         * New I/F              : ZCRM_SD_INCOMING_PLAN_FOR_WEB
         * Description          : 수금 스케쥴 생성(CRM -> ERP)
     */
    public IF_ERP_Order_Classes.IF_ORDER_014_Res IF_ORDER_014(IF_ERP_Order_Classes.IF_ORDER_014_Req parmeters){
        interfaceId = 'IF-ORDER-014';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_014_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_014_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_014_Res.class);    
    
                return response;        
        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    } 

/** IF_ORDER_015
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-015
         * SFDC interface Id    : IF_ORDER_015
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_GET_DRAFT_NO_SH  
         * Description          : 내역 : 주문 생성을 위한 Draft 번호 조회
     */
        public IF_ERP_Order_Classes.IF_ORDER_015_Res IF_ORDER_015(IF_ERP_Order_Classes.IF_ORDER_015_Req parmeters){
            interfaceId = 'IF-ORDER-015';            
            String parmetersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parmeters) 
                                + '}'; 

            String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
            
            try {

                IF_ERP_Order_Classes.IF_ORDER_015_Res response = 
                (IF_ERP_Order_Classes.IF_ORDER_015_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Order_Classes.IF_ORDER_015_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_DRAFT_NO_SH');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        } 

/** IF_ORDER_006
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-006
         * SFDC interface Id    : IF_ORDER_006
         * RFC Name             : ZCRM_SD_CREATE_SO_COMM_USA
         * Description          : Real Sales Order 생성(Commodity)
     */
    public IF_ERP_Order_Classes.IF_ORDER_006_Res IF_ORDER_006(IF_ERP_Order_Classes.IF_ORDER_006_Req parmeters){
        interfaceId = 'IF-ORDER-006';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        // interfaceUtil.isu0024Case =true;
        // interfaceUtil.isu005CCase =true;
        interfaceUtil.isURLEncode =true;
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_006_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_006_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_006_Res.class);    
    
                System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_DRAFT_NO_SH');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    } 

/** IF_ORDER_018
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_018
         * SFDC interface Id    : IF-ORDER-018
         * New I/F              : ZCRM_SD_REIMBURSEMENT_PRICE
         * Description          : Service Reimbursement 조회 - Sales Area, Currency, PKMT, 생성일 입력 후 Reimbursement 조회
     */
     /** REQUEST 
      */     
    public IF_ERP_Order_Classes.IF_ORDER_018_Res IF_ORDER_018(IF_ERP_Order_Classes.IF_ORDER_018_Req parmeters){
        interfaceId = 'IF-ORDER-018';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_018_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_018_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_018_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_REIMBURSEMENT_PRICE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }       

/** IF_ORDER_020
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_020
         * SFDC interface Id    : IF-ORDER-020
         * New I/F              : ZCRM_SD_GET_BRANCH_LIST
         * Description          : DNSA Distributor-Distributor간 Related Dealer 조회
     */
     /** REQUEST 
      */     
    public IF_ERP_Order_Classes.IF_ORDER_020_Res IF_ORDER_020(IF_ERP_Order_Classes.IF_ORDER_020_Req parmeters){
        interfaceId = 'IF-ORDER-020';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_020_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_020_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_020_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_BRANCH_LIST');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }    
    
/** IF_ORDER_016
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_016
         * SFDC interface Id    : IF-ORDER-016
         * New I/F              : ZCRM_SD_PROMOTION_DISP
         * Description          : 프로모션 데이터 조회 (ERP -> CRM)
     */
     /** REQUEST 
      */         
      public IF_ERP_Order_Classes.IF_ORDER_016_Res IF_ORDER_016(IF_ERP_Order_Classes.IF_ORDER_016_Req parmeters){
        interfaceId = 'IF-ORDER-016';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_016_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_016_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_016_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_PROMOTION_DISP');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }       

/** IF_ORDER_017
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_017
         * SFDC interface Id    : IF-ORDER-017
         * New I/F              : ZCRM_SD_WARRANTY_DISP
         * Description          : Warranty 데이터 조회 (ERP -> CRM)
     */
     /** REQUEST 
      */    
      public IF_ERP_Order_Classes.IF_ORDER_017_Res IF_ORDER_017(IF_ERP_Order_Classes.IF_ORDER_017_Req parmeters){
        interfaceId = 'IF-ORDER-017';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_017_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_017_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_017_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_WARRANTY_DISP');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }       

/** IF_ORDER_021
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_021
         * SFDC interface Id    : IF-ORDER-021
         * New I/F              : ZCRM_SD_SO_CV_MANAGE
         * Description          : Order CV 변환
         * IF_CURRENCY
     */    
    public IF_ERP_Order_Classes.IF_ORDER_021_Res IF_ORDER_021(IF_ERP_Order_Classes.IF_ORDER_021_Req parmeters){
        interfaceId = 'IF-ORDER-021';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_021_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_021_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_021_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_SO_CV_MANAGE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }       


/** IF_ORDER_022
    */  
    /**
         * Wrapper Name         : IF_ORDER_022
         * SFDC interface Id    : IF-ORDER-022
         * New I/F              : ZCRM_SD_GET_PSO_PRICEE
     */    
    public IF_ERP_Order_Classes.IF_ORDER_022_Res IF_ORDER_022(IF_ERP_Order_Classes.IF_ORDER_022_Req parmeters){
        interfaceId = 'IF-ORDER-022';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Order_Classes.IF_ORDER_022_Res response = 
            (IF_ERP_Order_Classes.IF_ORDER_022_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Order_Classes.IF_ORDER_022_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_PSO_PRICEE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }       

}