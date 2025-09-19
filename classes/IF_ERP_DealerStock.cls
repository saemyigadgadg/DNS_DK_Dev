public with sharing class IF_ERP_DealerStock {
    public IF_ERP_DealerStock() {}
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String              apexClassName = 'IF_ERP_DealerStock';
    private Boolean             isResponseXml = true;  
    private String              interfaceId;

/** IF_DEALERSTOCK_001
    */  
    /**
         * Apex Class           : IF_ERP_DealerStock
         * Wrapper Class        : IF_ERP_DealerStock_Classes
         * Wrapper Name         : IF-DEALERSTOCK-001
         * SFDC interface Id    : IF_DEALERSTOCK_001
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SS_SEND_REPLACE_PART_HIST
         * Description          : 대체품 해제 이력 조회 
         * KeyValue             : X
         * NOT NULL             : X
     */
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res IF_DEALERSTOCK_001(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-001';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res response = 
                (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res.class);
                
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SS_SEND_REPLACE_PART_HIST');

                return response;        
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }    

/** IF_DEALERSTOCK_002
    */  
    /**
         * Apex Class           : IF_ERP_DealerStock
         * Wrapper Class        : IF_ERP_DealerStock_Classes
         * Wrapper Name         : IF-DEALERSTOCK-002
         * SFDC interface Id    : IF_DEALERSTOCK_002
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SS_SEND_MATERIAL_EXTN
         * Description          : 대체품 해제 이력 조회-부품마스터에 LAST 품번이 존재하므로 I/F에 항목 추가-신규부품 생성 시 대리점 별로 부품정보 확장
         * KeyValue             : X
         * NOT NULL             : X
         -> 신규 생성된 품번을 대리점의 Material Master 로 생성해주는 기능 
         대리점 자재 종합조회 - 확장
     */            
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Res IF_DEALERSTOCK_002(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-002';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Res response = 
                (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_002_Res.class);
                
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SS_SEND_MATERIAL_EXTN');

                return response;        
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }    

/** IF-DEALERSTOCK-003
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_REQ
 * Description          : 대리점 무상 오더 불출 요청 정보 조회
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_DEALERSTOCK_GI_REQ_M
    */
    public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res IF_DEALERSTOCK_003(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req parameters){
        interfaceId = 'IF-DEALERSTOCK-003';

        if(parameters.I_DETAIL_INFO != null){
            if(parameters.I_DETAIL_INFO.AUFNR != null)      parameters.I_DETAIL_INFO.AUFNR      = '000' + parameters.I_DETAIL_INFO.AUFNR;
            if(parameters.I_DETAIL_INFO.DEALER_CD != null)  parameters.I_DETAIL_INFO.DEALER_CD  = '000' + parameters.I_DETAIL_INFO.DEALER_CD;
        }

        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters)
                                    + '}';

        System.debug('parameters.I_DETAIL_INFO.AUFNR ::: ' + parameters.I_DETAIL_INFO.AUFNR);
        System.debug('parameters.I_DETAIL_INFO.DEALER_CD ::: ' + parameters.I_DETAIL_INFO.DEALER_CD);

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        responseString = responseString.replace('".INCLUDE"', '"INCLUDE"');

        try{
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res response = 
            (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res.class);
            
            return response;        
        }
        catch(Exception e){
            System.debug('EXCEPTION MESSAGE : '+e.getMessage());
            System.debug('EXCEPTION LINE : '+e.getLineNumber());
            return null;
        }
    } 

/** IF-DEALERSTOCK-004
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_REQ_DIV
 * Description          : 대리점 무상 오더 불출 요청 정보 분할
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_DEALERSTOCK_GI_REQ_DIV_M
    */
    public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res IF_DEALERSTOCK_004(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Req parameters){
        interfaceId = 'IF-DEALERSTOCK-004';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        try{
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res response = 
            (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res.class);
            
            return response;        
        }
        catch(Exception e){
            System.debug('EXCEPTION MESSAGE : '+e.getMessage());
            System.debug('EXCEPTION LINE : '+e.getLineNumber());
            return null;
        }
    } 

/** IF-DEALERSTOCK-005
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_REQ_DEL
 * Description          : 대리점 무상 오더 불출 관련 SAP 삭제
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_DEALERSTOCK_GI_REQ_DEL_M
    */
    public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res IF_DEALERSTOCK_005(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Req parameters){
        interfaceId = 'IF-DEALERSTOCK-005';

        if(parameters.I_AUFNR != null) parameters.I_AUFNR = '000' + parameters.I_AUFNR;
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        try{
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res response = 
                (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res.class);
            
            return response;        
        }
        catch(Exception e){
            System.debug('EXCEPTION MESSAGE : '+e.getMessage());
            System.debug('EXCEPTION LINE : '+e.getLineNumber());
            return null;
        }
    } 

/** IF-DEALERSTOCK-006
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_INF_DSP
 * Description          : 출하정보 조회
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_DEALERSTOCK_GI_INF_DSP_M
    */
    public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res IF_DEALERSTOCK_006(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req parameters){
        interfaceId = 'IF-DEALERSTOCK-006';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


        try{
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res response = 
            (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res.class);
            
            return response;        
        }
        catch(Exception e){
            System.debug('EXCEPTION MESSAGE : '+e.getMessage());
            System.debug('EXCEPTION LINE : '+e.getLineNumber());
            return null;
        }
    } 

/** IF_DEALERSTOCK_007
    */  
    /**
         * Apex Class           : IF_ERP_DealerStock
         * Wrapper Class        : IF_ERP_DealerStock_Classes
         * Wrapper Name         : IF-DEALERSTOCK-002
         * SFDC interface Id    : IF_DEALERSTOCK_002
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SS_SEND_TSL_LIST				
         * Description          : : Service factor by target service level 조회
         * KeyValue             : X
         * NOT NULL             : X
     */            
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res IF_DEALERSTOCK_007(){
            interfaceId = 'IF-DEALERSTOCK-007';
            String parametersString = 'InputParam={"Input":"{}"}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res response = 
                (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res) JSON.deserialize(
                    responseString,
                     IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_007_Res.class);
                
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SS_SEND_TSL_LIST');

                return response;        
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }  

    /** SFDC interface Id   : IF-DEALERSTOCK-009
     * New I/F              : ZCRM_SS_DEALER_GRADE
     * Description          : 대리점 등급별 할인율 조회
        */
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res IF_DEALERSTOCK_009(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-009';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res response = 
                    (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_009_Res.class);
                
                return response;         
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }

    /** SFDC interface Id   : IF-DEALERSTOCK-010
     * New I/F              : ZCRM_SS_RECV_EP_SIMULATION
     * Description          : 대리점 재고 관리 시뮬레이션 
        */
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res IF_DEALERSTOCK_010(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-010';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res response = 
                    (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res.class);

                return response;
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }
    
    /** SFDC interface Id   : IF-DEALERSTOCK-011
     * New I/F              : ZCRM_EP_SAFETY_STOCK_ADD
     * Description          : 기타입고
        */
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res IF_DEALERSTOCK_011(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-011';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res response = 
                    (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res.class);

                return response;
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }
    /** SFDC interface Id   : IF-DEALERSTOCK-012
     * New I/F              : ZCRM_EP_SAFETY_STOCK_ADD2
     * Description          : 기타출고
        */
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res IF_DEALERSTOCK_012(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-012';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res response = 
                    (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res.class);

                return response;
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }

    /** SFDC interface Id   : IF-DEALERSTOCK-014
     * New I/F              : ZCRM_SL_RECV_EP_GR_LIST_TO_CAN
     * Description          : 입고취소
        */
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res IF_DEALERSTOCK_014(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-014';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res response = 
                    (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res.class);
                
                return response;         
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }    


/** IF-DEALERSTOCK-015
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_INF_DSP
 * Description          : 정산완료 STATUS를 업데이트
 * 
 */
        public IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res IF_DEALERSTOCK_015(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req parameters){
            interfaceId = 'IF-DEALERSTOCK-015';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            interfaceUtil.isIF_Case = true;
            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try{
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res response = 
                    (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res) JSON.deserialize(responseString, IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res.class);
                
                return response;         
            }
            catch(Exception e){
                System.debug('EXCEPTION MESSAGE : '+e.getMessage());
                System.debug('EXCEPTION LINE : '+e.getLineNumber());
                return null;
            }
        }    




}