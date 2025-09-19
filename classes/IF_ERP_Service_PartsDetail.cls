/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-25-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-25-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Service_PartsDetail {
    public IF_ERP_Service_PartsDetail() {}

    public class DN_InquiryAgencyMaterialsControllerException extends Exception {}
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String              apexClassName = 'IF_ERP_Service_PartsDetail';
    private Boolean             isResponseXml = true;  
    private String              interfaceId;

/** IF_SERVICE_037
    */  
    /**
         * Apex Class           : IF_ERP_Service_PartsDetail
         * Wrapper Class        : IF_ERP_Service_PartsDetail_Classes
         * Wrapper Name         : IF_SERVICE_037
         * SFDC interface Id    : IF-SERVICE-037
         * AS-IS RFC            : Z_EP_PARTS_STANDARD_ME	
         * New I/F              : ZCRM_EP_PARTS_STANDARD_ME
         * Description          : 부품 기본 정보 조회
         * KeyValue             : IF_CURRENCY ( CURRENCY )
     */    
     public IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res IF_SERVICE_037(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req parameters){
        InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog('IF-SERVICE-037', 'IF_ERP_Service_PartsDetail');
        if(parameters.I_MATNR == null || String.isEmpty(parameters.I_MATNR) || String.isBlank(parameters.I_MATNR) ) {
            throw new DN_InquiryAgencyMaterialsControllerException('부품 번호가 올바르지 않습니다.');
        }else{
            interfaceLog.requestBody = '{"Input":' + JSON.serialize(parameters) + '}';

            interfaceUtil.saveLog.add(interfaceLog);

            interfaceId = 'IF-SERVICE-037';
            parameters.I_LANGU = interfaceUtil.getLanguageKey(parameters.I_LANGU);
            String parametersString = 'InputParam='
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            
            try {
                System.debug('responseString :: '+responseString);
    
                IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res response = 
                    (IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res) JSON.deserialize(responseString, 
                    IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res.class);

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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_EP_PARTS_STANDARD_ME');
                    return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }          
        }
        
    }


/** IF_SERVICE_038
    */  
    /**
         * Apex Class           : IF_ERP_Service_PartsDetail
         * Wrapper Class        : IF_ERP_Service_PartsDetail_Classes
         * Wrapper Name         : IF_SERVICE_038
         * SFDC interface Id    : IF-SERVICE-038
         * AS-IS RFC            : Z_EP_ITEM_SUB_LIST_ME		
         * New I/F              : ZCRM_EP_ITEM_SUB_LIST_ME
         * Description          : 대체품 정보 조회 
         * KeyValue             : X
     */     
    public IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res IF_SERVICE_038(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req parameters){
        interfaceId = 'IF-SERVICE-038';
        parameters.I_LANGU = interfaceUtil.getLanguageKey(parameters.I_LANGU);
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

                try {
                    System.debug('responseString :: '+responseString);
        
                    IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res response = 
                        (IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res) JSON.deserialize(responseString, 
                        IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res.class);

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
                        System.debug(':::::::::::::    RFC NAME     : ZCRM_EP_ITEM_SUB_LIST_ME');
                        return response;        
        
                } catch (Exception e) {
                    System.debug('ERROR MESSAGE : '+e.getMessage());
                    System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                    return null;        
                }        
    }                
}