/*
 *
 * @author : SUNG SEO UK
 * @createDate : 2024-11-06 
 */
public with sharing class IF_ERP_Dealer {
    public IF_ERP_Dealer() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String              apexClassName = 'IF_ERP_Dealer';
    private Boolean             isResponseXml = true;  
    private String              interfaceId;


/** IF_DEALER_001
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_001
         * SFDC interface Id    : IF-DEALER-001
         * AS-IS RFC            : 
         * New I/F              : ZCRM_FI_GET_AR_INCOM_DEALER
         * Description          : 담보 증액 금액 조회
     */
        public IF_ERP_Dealer_Classes.IF_DEALER_001_Res IF_DEALER_001(IF_ERP_Dealer_Classes.IF_DEALER_001_Req parameters){
            interfaceId = 'IF-DEALER-001';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


            try{
                IF_ERP_Dealer_Classes.IF_DEALER_001_Res response = 
                (IF_ERP_Dealer_Classes.IF_DEALER_001_Res) JSON.deserialize(responseString, IF_ERP_Dealer_Classes.IF_DEALER_001_Res.class);
                
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_FI_GET_AR_INCOM_DEALER');

                Integer totalAmount = 0;
                for(IF_ERP_Dealer_Classes.IF_DEALER_001_Res_T_ORDER order : response.T_ORDER){
                    Integer WRBTR = 0;
                    Integer CL_WRBTR = 0;
                    if(order.WRBTR != '' && order.WRBTR != null){
                        WRBTR = Integer.valueOf(order.WRBTR);
                        if(WRBTR < 0) WRBTR *= -1;
                    }
                    if(order.WRBTR != '' && order.WRBTR != null){
                        CL_WRBTR = Integer.valueOf(order.CL_WRBTR);
                        if(CL_WRBTR < 0) CL_WRBTR *= -1;
                    }     

                    totalAmount += WRBTR + CL_WRBTR;
                }

                response.TotalAmount = totalAmount;

                return response;        

            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage()); System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }    
    

    /**
     * 
     * SFDC interface Id    : IF-DEALER-004
     * AS-IS RFC            : Z_SD_SEARCH_MORTGAGE_LIST        
     * New I/F              : ZCRM_SD_SEARCH_MORTGAGE_LIST		
     * Description          : I/F 통해 딜러별 딜러명, 대표자, 제공자, 소유자, 담보구분, 담보크기, 담보상세, 담보평가문서, 설정계약서 등 데이터를 ERP에서 받아온다.
     */
    public IF_ERP_Dealer_Classes.IF_DEALER_004_Res IF_DEALER_004(IF_ERP_Dealer_Classes.IF_DEALER_004_Req parameters){
        interfaceId = 'IF-DEALER-004';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


        try{
            IF_ERP_Dealer_Classes.IF_DEALER_004_Res response = 
            (IF_ERP_Dealer_Classes.IF_DEALER_004_Res) JSON.deserialize(responseString, IF_ERP_Dealer_Classes.IF_DEALER_004_Res.class);
            
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_SEARCH_MORTGAGE_LIST');

            return response;        

        }
        catch(Exception e){
            System.debug('EXCEPTION MESSAGE : '+e.getMessage()); System.debug('EXCEPTION LINE : '+e.getLineNumber());
            return null;
        }
    }    

/**
     * 
     * SFDC interface Id    : IF-DEALER-005
     * AS-IS RFC            : Z_FI_CLEARED_AR	        
     * New I/F              : ZCRM_FI_CLEARED_AR	
     * Description          : ERP I/F 통해 기간별 수금실적 정보 조회
*/
    public IF_ERP_Dealer_Classes.IF_DEALER_005_Res IF_DEALER_005(IF_ERP_Dealer_Classes.IF_DEALER_005_Req parameters){
        interfaceId = 'IF-DEALER-005';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        interfaceUtil.isIF_Case = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


        
        try{
            IF_ERP_Dealer_Classes.IF_DEALER_005_Res response = 
            (IF_ERP_Dealer_Classes.IF_DEALER_005_Res) JSON.deserialize(responseString, IF_ERP_Dealer_Classes.IF_DEALER_005_Res.class);
            
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_FI_CLEARED_AR');

            return response;        

        }
        catch(Exception e){
            System.debug('EXCEPTION MESSAGE : '+e.getMessage()); System.debug('EXCEPTION LINE : '+e.getLineNumber());
            return null;
        }

    }    

/**
 *
 *   * Wrapper Name         : IF_DEALER_006
     * SFDC interface Id    : IF-DEALER-006
     * AS-IS RFC            : Z_FB_HISTORY_OF_PAYMENT	        
     * New I/F              : ZCRM_FB_HISTORY_OF_PAYMENT
     * Description          : ERP I/F 통해 고객 및 은행별로 입금현황 조회  
    */    
    public IF_ERP_Dealer_Classes.IF_DEALER_006_Res IF_DEALER_006(IF_ERP_Dealer_Classes.IF_DEALER_006_Req parameters){
        interfaceId = 'IF-DEALER-006';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
    
                IF_ERP_Dealer_Classes.IF_DEALER_006_Res response = 
                (IF_ERP_Dealer_Classes.IF_DEALER_006_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Dealer_Classes.IF_DEALER_006_Res.class);
    
            
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_FB_HISTORY_OF_PAYMENT');
                    return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage()); System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }            
    }  


/** IF_DEALER_003
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_003
         * SFDC interface Id    : IF-DEALER-003
         * AS-IS RFC            : Z_SD_SEARCH_CREDIT_INFO
         * New I/F              : ZCRM_SD_SEARCH_CREDIT_INFO
         * Description          : ERP I/F 통해 계정별 여신 정보 조회
     */    
    public IF_ERP_Dealer_Classes.IF_DEALER_003_Res IF_DEALER_003(IF_ERP_Dealer_Classes.IF_DEALER_003_Req parameters){
        interfaceId = 'IF-DEALER-003';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
    

                IF_ERP_Dealer_Classes.IF_DEALER_003_Res response = 
                (IF_ERP_Dealer_Classes.IF_DEALER_003_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Dealer_Classes.IF_DEALER_003_Res.class);
            
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_SEARCH_CREDIT_INFO');
                    return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage()); System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
    }     


/** IF_DEALER_008
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_008
         * SFDC interface Id    : IF-DEALER-008
         * AS-IS RFC            : Z_SD_MS_DE_ASS
         * New I/F              : ZCRM_SD_MS_DE_ASS
         * Description          : Account를 담당하는 DNS 직판인원, 딜러 Partner 정보 연동
     */
    public IF_ERP_Dealer_Classes.IF_DEALER_008_Res IF_DEALER_008(IF_ERP_Dealer_Classes.IF_DEALER_008_Req parameters){
        interfaceId = 'IF-DEALER-008';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {

                IF_ERP_Dealer_Classes.IF_DEALER_008_Res response = 
                (IF_ERP_Dealer_Classes.IF_DEALER_008_Res) JSON.deserialize(responseString, IF_ERP_Dealer_Classes.IF_DEALER_008_Res.class);
    
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
                System.debug('ERROR MESSAGE : '+e.getMessage()); System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
    }  



/** IF_DEALER_007
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_007
         * SFDC interface Id    : IF-DEALER-007
         * AS-IS RFC            : 
         * New I/F              : ZCRM_FI_GET_AR_INCOM
         * Description          : 주문별 수금일정 조회 - ERP I/F 통해 고객 및 계약번호별로 주문별 수금일정 조회
     */
        public IF_ERP_Dealer_Classes.IF_DEALER_007_Res IF_DEALER_007(IF_ERP_Dealer_Classes.IF_DEALER_007_Req parameters){
            interfaceId = 'IF-DEALER-007';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

                try {

                    IF_ERP_Dealer_Classes.IF_DEALER_007_Res response = 
                    (IF_ERP_Dealer_Classes.IF_DEALER_007_Res) JSON.deserialize(responseString, IF_ERP_Dealer_Classes.IF_DEALER_007_Res.class);

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
                        System.debug(':::::::::::::    RFC NAME     : ZCRM_FI_GET_AR_INCOM');
                        return response;        

                } catch (Exception e) {
                    System.debug('ERROR MESSAGE : '+e.getMessage()); System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                    return null;        
                }
        }  

     
/** IF_DEALER_010
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_010
         * SFDC interface Id    : IF-DEALER-010
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_GET_INCOMING_COLLECT 
         * Description          : 월별 수금계획
     */
        public IF_ERP_Dealer_Classes.IF_DEALER_010_Res IF_DEALER_010(IF_ERP_Dealer_Classes.IF_DEALER_010_Req parameters){
            interfaceId = 'IF-DEALER-010';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

                try {

                    IF_ERP_Dealer_Classes.IF_DEALER_010_Res response = 
                    (IF_ERP_Dealer_Classes.IF_DEALER_010_Res) JSON.deserialize(responseString, IF_ERP_Dealer_Classes.IF_DEALER_010_Res.class);

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
                        System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_INCOMING_COLLECT');
                        return response;        

                } catch (Exception e) {
                    System.debug('ERROR MESSAGE : '+e.getMessage()); System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                    return null;        
                }
        }  


}