/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-31-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-21-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_WorkOrder {
    public IF_ERP_WorkOrder() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_WorkOrder';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

/** IF-CSPLUS-004 *개발 취소*
 *  AS-IS RFC            : Z_CS_MT_WORK_RESULT_CONFIRM
 *  New I/F              : ZCRM_CS_MT_WORK_RESULT_CONFIRM
 *  Description          : 작업 내역 및 조치내역 조회/수정/삭제
    */
    // public IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res IF_CSPLUS_004(IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Req parameters){
    //     interfaceId = 'IF-CSPLUS-004';
    //     String parametersString = 'InputParam='
    //                                 + '{"Input":'
    //                                 + JSON.serialize(parameters)
    //                                 + '}';

    //     String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

    //     IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res response =
    //         (IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res) JSON.deserialize(responseString, IF_ERP_WorkOrder_Classes.IF_CSPLUS_004_Res.class);

    //     return response;
    // }

/** IF_CSPLUS_005
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF_CSPLUS_005
         * SFDC interface Id    : IF-CSPLUS-005
         * AS-IS RFC            : ZCS_RECV_PROC_EDU_SAVE	
         * New I/F              : ZCRM_CS_RECV_PROC_EDU_SAVE
         * Description          : 납품후 교육 관련 Ticket 및 WorkOrder 조회/수정/삭제 
         * KeyValue             : X
         * NOT NULL             : X
     */     
    public IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res IF_CSPLUS_005(IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req parameters){
        interfaceId = 'IF-CSPLUS-005';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        interfaceUtil.isURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        // responseString  = responseString.substringAfter('"Output":').substringBeforeLast('}');                

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res response = 
            (IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res) JSON.deserialize(responseString, IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res.class);


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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_RECV_PROC_EDU_SAVE');
            System.debug(':::::::::::::    CLASS NAME   : '+apexClassName);   

        return response;
    }

/** IF-CSPLUS-010
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-010
         * SFDC interface Id    : IF_CSPLUS_010
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_MT_AS_RECEIPT_SAVE				
         * Description          : WorkOrder정보 생성
     */     
    public IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res IF_CSPLUS_010(IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req parmeters){
        interfaceId = 'IF-CSPLUS-010';           
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 
        interfaceUtil.isURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res response = 
            (IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res) JSON.deserialize(
                responseString, 
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_AS_RECEIPT_SAVE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    } 

/** IF-CSPLUS-015
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-015
         * SFDC interface Id    : IF_CSPLUS_015
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_MT_SUB_ENGINEER_SAVE				
         * Description          : 공동 작업자 생성
     */     
    public IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res IF_CSPLUS_015(IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req parmeters){
        interfaceId = 'IF-CSPLUS-015';           
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res response = 
            (IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res) JSON.deserialize(
                responseString, 
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_SUB_ENGINEER_SAVE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }

/** IF-CSPLUS-019
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF_CSPLUS_019
         * SFDC interface Id    : IF_CSPLUS_019
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_WORKWORDER_MANAGE				
         * Description          : Work Order 생성/수정/취소 - 신규 Work Order 생성 시 ERP로 데이터 전송
         * IF_CSPLUS_019_Res_ES_HEADER -> IF_CURRENCY
         * IF_CSPLUS_019_Res_ET_OPERATIONS -> IF_CURRENCY
     */     
    public IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res IF_CSPLUS_019(IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Req parmeters){
        interfaceId = 'IF-CSPLUS-019';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res response = 
            (IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res) JSON.deserialize(
                responseString, 
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_019_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WORKWORDER_MANAGE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }     

/** IF-CSPLUS-028
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-028
         * SFDC interface Id    : IF_CSPLUS_028
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_RECV_WORK_DATE_REGIST				
         * Description          : 서비스 요원 출동/도착
     */       
        public IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res IF_CSPLUS_028(IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req parmeters){
            interfaceId = 'IF-CSPLUS-028';           
            String parmetersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parmeters) 
                                + '}'; 

            String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
            

            try {
                System.debug('responseString :: '+responseString);

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res response = 
                (IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_RECV_WORK_DATE_REGIST');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }     

/** IF-CSPLUS-034 *개발취소*
 *  AS-IS RFC            : ZSS_RECV_EP_SIMULATION
 *  New I/F              : ZCRM_SS_RECV_EP_SIMULATION
 *  Description          : 메인작업자 변경 및 조치내역 업데이트 (관리자)
    */
    // public IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res IF_CSPLUS_034(IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Req parameters){
    //     interfaceId = 'IF-CSPLUS-034';
    //     String parametersString = 'InputParam='
    //                                 + '{"Input":'
    //                                 + JSON.serialize(parameters) 
    //                                 + '}'; 

    //     String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

    //     IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res response = 
    //         (IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res) JSON.deserialize(responseString, IF_ERP_WorkOrder_Classes.IF_CSPLUS_034_Res.class);

    //     return response;
    // }

/** IF-CSPLUS-037
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-037
         * SFDC interface Id    : IF_CSPLUS_037
         * New I/F              : ZCRM_CS_CREATE_SRV_ORDER_USA				
         * Description          : A/S접수 생성
     */     
        public IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res IF_CSPLUS_037(IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Req parmeters){
            interfaceId = 'IF-CSPLUS-037';           
            String parmetersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parmeters) 
                                + '}'; 
            interfaceUtil.isIF_Case = true;
            String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
            

            try {
                System.debug('responseString :: '+responseString);

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res response = 
                (IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_WorkOrder_Classes.IF_CSPLUS_037_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_CREATE_SRV_ORDER_USA');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }          

/** IF-CSPLUS-042
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-042
         * SFDC interface Id    : IF_CSPLUS_042
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_RECV_SP_CLAIM_SAVE				
         * Description          : 설치검수 정기점검 및 기획/순회서비스 생성
    */       
    public IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res IF_CSPLUS_042(IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req parmeters){
        interfaceId = 'IF-CSPLUS-042';           
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res response = 
                (IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res.class);    
    
            return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }     
    
/** SFDC interface Id   : IF-CSPLUS-046
 * New I/F              : ZCRM_CS_WORK_ORDER_FILE
 * Description          : 서비스오더 파일 데이터 조회 (CRM -> ERP)
    */
    public IF_ERP_WorkOrder_Classes.IF_CSPLUS_046_Res IF_CSPLUS_046(IF_ERP_WorkOrder_Classes.IF_CSPLUS_046_Req parmeters){
        interfaceId = 'IF-CSPLUS-046';           
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_WorkOrder_Classes.IF_CSPLUS_046_Res response = 
                (IF_ERP_WorkOrder_Classes.IF_CSPLUS_046_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_WorkOrder_Classes.IF_CSPLUS_046_Res.class);    
    
            return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }     

}