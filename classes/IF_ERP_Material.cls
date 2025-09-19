/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-21-2025
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-21-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Material {
    public IF_ERP_Material() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    public Boolean isResponseXml = true;  
    private String  apexClassName = 'IF_ERP_Material';
    private String  interfaceId;
    
    /** IF-CSPLUS-007
     * Class Name           : IF_ERP_Material 
     * Wrapper Name         : IF_CSPLUS_007
     * SFDC interface Id    : IF-CSPLUS-007
     * AS-IS RFC            : Z_CS_MT_PARTS_DELIVERY_INFO	
     * New I/F              : ZCRM_CS_MT_PARTS_DELIVERY_INFO
     * Description          : 부품 배송정보 조회
     * REAL                 : Y  
        */ 
        public IF_ERP_Material_Classes.IF_CSPLUS_007_Res IF_CSPLUS_007(IF_ERP_Material_Classes.IF_CSPLUS_007_Req parameters){
            interfaceId = 'IF-CSPLUS-007';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';

            // parametersString        = interfaceUtil.encodeForSAP(parametersString);
            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = 
                (IF_ERP_Material_Classes.IF_CSPLUS_007_Res) JSON.deserialize(responseString, IF_ERP_Material_Classes.IF_CSPLUS_007_Res.class);

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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_PARTS_DELIVERY_INFO');
                System.debug(':::::::::::::    CLASS NAME   : '+apexClassName);   

            return response;
        }

    /** IF-CSPLUS-017
     * RFC Name             : ZCRM_CS_EQUIPMNT_CHANGE
     * Description          : 장비 정보 수정(CRM -> ERP)
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_017_Res IF_CSPLUS_017(IF_ERP_Material_Classes.IF_CSPLUS_017_Req parameters){
            interfaceId = 'IF-CSPLUS-017';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';

            parametersString        = interfaceUtil.encodeForSAP(parametersString);
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
    
                try {
                    System.debug('responseString :: '+responseString);
        
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Res response = 
                    (IF_ERP_Material_Classes.IF_CSPLUS_017_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_Material_Classes.IF_CSPLUS_017_Res.class);
                
                        return response;        
        
                } catch (Exception e) {
                    System.debug('ERROR MESSAGE : '+e.getMessage());
                    System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                    return null;        
                }
        }

    /** IF-CSPLUS-018
     * RFC Name             : ZCRM_CS_EQUIPMNT_MANAGEMENT
     * Description          : 장비 정보 생성 & 수정(ERP -> CRM)
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_018_Res IF_CSPLUS_018(IF_ERP_Material_Classes.IF_CSPLUS_018_Req parameters){
            interfaceId = 'IF-CSPLUS-018';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 
    
            interfaceUtil.isIF_Case = true;
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Material_Classes.IF_CSPLUS_018_Res response = 
                (IF_ERP_Material_Classes.IF_CSPLUS_018_Res) JSON.deserialize(responseString, IF_ERP_Material_Classes.IF_CSPLUS_018_Res.class);
    
            return response;
        }

    /** IF-CSPLUS-021
     * AS-IS RFC            : ZSL_RECV_EP_DEALER_STOCK_INFO       
     * New I/F              : ZCRM_SL_RECV_EP_DEALER_STOCK       
     * Description          : * 부품 주문 및 부품 청구 생성을 위한 부품 재고조회
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_021_Res IF_CSPLUS_021(IF_ERP_Material_Classes.IF_CSPLUS_021_Req parameters){
            interfaceId = 'IF-CSPLUS-021';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            // responseString  = responseString.substringAfter('"Output":').substringBeforeLast('}');                
            System.debug('responseString ::: ' + responseString);

            IF_ERP_Material_Classes.IF_CSPLUS_021_Res response = 
                (IF_ERP_Material_Classes.IF_CSPLUS_021_Res) JSON.deserialize(responseString, IF_ERP_Material_Classes.IF_CSPLUS_021_Res.class);

            return response;
        }

    /** IF-CSPLUS-024
     * AS-IS RFC            : Z_CS_MT_CUSTOMER_EQUIP_INFO       
     * New I/F              : ZCRM_CS_MT_CUSTOMER_EQUIP_INFO   
     * Description          : SP-Task 목록 조회 및 저장
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_024_Res IF_CSPLUS_024(IF_ERP_Material_Classes.IF_CSPLUS_024_Req parameters){
            interfaceId = 'IF-CSPLUS-024';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            System.debug('직전의 responseString ::: ' + responseString);

            IF_ERP_Material_Classes.IF_CSPLUS_024_Res response = 
                (IF_ERP_Material_Classes.IF_CSPLUS_024_Res) JSON.deserialize(responseString, IF_ERP_Material_Classes.IF_CSPLUS_024_Res.class);

            return response;
        }

    /** IF-CSPLUS-031
     * AS-IS RFC            : ZSS_RECV_SPD_CARTRIDGE_BY_EQUI
     * New I/F              : ZCRM_SS_SPD_CARTRIDGE_BY_EQUI
     * Description          : 스핀들 입고수리 부품 청구를 위한 조회
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_031_Res IF_CSPLUS_031(IF_ERP_Material_Classes.IF_CSPLUS_031_Req parameters){
            interfaceId = 'IF-CSPLUS-031';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            
            try {

                    IF_ERP_Material_Classes.IF_CSPLUS_031_Res response = 
                        (IF_ERP_Material_Classes.IF_CSPLUS_031_Res) JSON.deserialize(
                            responseString, IF_ERP_Material_Classes.IF_CSPLUS_031_Res.class);
                            
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SS_SPD_CARTRIDGE_BY_EQUI');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }
    
    /** IF-CSPLUS-045
     * RFC Name             : ZCRM_CS_EQUIPMENT_FILE
     * Description          : 장비 파일 데이터 조회  (CRM -> ERP)
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_045_Res IF_CSPLUS_045(IF_ERP_Material_Classes.IF_CSPLUS_045_Req parameters){
            interfaceId = 'IF-CSPLUS-045';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 
    
            interfaceUtil.isIF_Case = true;
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Material_Classes.IF_CSPLUS_045_Res response = 
                (IF_ERP_Material_Classes.IF_CSPLUS_045_Res) JSON.deserialize(responseString, IF_ERP_Material_Classes.IF_CSPLUS_045_Res.class);
    
            return response;
        }

    /** IF-CSPLUS-047
     * RFC Name             : ZCRM_CS_EQUIP_ORDER_FILE
     * Description          : 장비 파일 데이터 조회  (CRM -> ERP)
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_047_Res IF_CSPLUS_047(IF_ERP_Material_Classes.IF_CSPLUS_047_Req parameters){
            interfaceId = 'IF-CSPLUS-047';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 
    
            interfaceUtil.isIF_Case = true;
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Material_Classes.IF_CSPLUS_047_Res response = 
                (IF_ERP_Material_Classes.IF_CSPLUS_047_Res) JSON.deserialize(responseString, IF_ERP_Material_Classes.IF_CSPLUS_047_Res.class);
    
            return response;
        }
}