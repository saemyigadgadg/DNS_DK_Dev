/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-06-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Quotation {
    public IF_ERP_Quotation() {}
    

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Quotation';
    private Boolean isResponseXml = true;  
    private String  interfaceId;
    
/** IF-OPTY-019  
*/  
    /**
         * Apex Class           : IF_ERP_Quotation
         * Wrapper Class        : IF_ERP_Quotation_Classes
         * Wrapper Name         : IF-OPTY-019  
         * SFDC interface Id    : IF_OPTY_019
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_MS_QT_CRE
         * Description          : Quotation 생성 CRM에서 Quotation 생성 후 ERP에 전송 
         * KeyValue             : X
         * NOT NULL             : X
    */     
    // public IF_ERP_Quotation_Classes.IF_OPTY_019_Res IF_OPTY_019(IF_ERP_Quotation_Classes.IF_OPTY_019_Req parmeters){
    //     interfaceId = 'IF-OPTY-019';            
    //     String parmetersString = 'InputParam=' 
    //                         + '{"Input":' 
    //                         + JSON.serialize(parmeters) 
    //                         + '}';

    //     // interfaceUtil.isu0024Case = true;
    //     interfaceUtil.isURLEncode = true;
    //     String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
    //     // String responseString = interfaceUtil.sendHttpCaseI_VBELN(parmetersString, interfaceId, apexClassName, isResponseXml);

    //     try {
    //         System.debug('responseString :: '+responseString);

    //         IF_ERP_Quotation_Classes.IF_OPTY_019_Res response =
    //         (IF_ERP_Quotation_Classes.IF_OPTY_019_Res) JSON.deserialize(
    //             responseString,
    //             IF_ERP_Quotation_Classes.IF_OPTY_019_Res.class);

    //             return response;        

    //     } catch (Exception e) {
    //         System.debug('ERROR MESSAGE : '+e.getMessage());
    //         System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
    //         return null;
    //     }
    // }
    public List<IF_ERP_Quotation_Classes.IF_OPTY_019_Res> IF_OPTY_019(List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req> parmeterList){
        interfaceId = 'IF-OPTY-019';
        List<String> parmetersStringList = new List<String>();
        for (IF_ERP_Quotation_Classes.IF_OPTY_019_Req parmeters : parmeterList) {
            String parmetersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parmeters) 
                                + '}'; 
            parmetersStringList.add(parmetersString);
        }
        // interfaceUtil.isu0024Case = true;
        interfaceUtil.isURLEncode = true;
        List<String> responseStringList = interfaceUtil.sendHttpCaseI_VBELN(parmetersStringList, interfaceId, apexClassName, isResponseXml);

        try {
            List<IF_ERP_Quotation_Classes.IF_OPTY_019_Res> responseList = new List<IF_ERP_Quotation_Classes.IF_OPTY_019_Res>();

            for (String responseString : responseStringList) {
                IF_ERP_Quotation_Classes.IF_OPTY_019_Res response =
                (IF_ERP_Quotation_Classes.IF_OPTY_019_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Quotation_Classes.IF_OPTY_019_Res.class);
                
                responseList.add(response);
            }
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    ');            
                System.debug(':::::::::::::  RESPONSE =>');
                System.debug(':::::::::::::    {');
                System.debug(':::::::::::::    '+JSON.serialize(responseList));
                System.debug(':::::::::::::    } ');
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_QT_CRE');

                return responseList;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }  

/** SFDC interface Id   : IF-OPTY-020
 * New I/F              : ZCRM_SD_MS_QT_CHG
 * Description          : Quotation 수정 (CRM -> ERP)
    */
    // public IF_ERP_Quotation_Classes.IF_OPTY_020_Res IF_OPTY_020(IF_ERP_Quotation_Classes.IF_OPTY_020_Req parmeters){
    //     interfaceId = 'IF-OPTY-020';            
    //     String parmetersString = 'InputParam=' 
    //                         + '{"Input":' 
    //                         + JSON.serialize(parmeters) 
    //                         + '}'; 

    //     // interfaceUtil.isu0024Case = true;
    //     interfaceUtil.isURLEncode = true;
    //     String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);

    //     try {
    //         System.debug('responseString :: '+responseString);

    //         IF_ERP_Quotation_Classes.IF_OPTY_020_Res response = 
    //         (IF_ERP_Quotation_Classes.IF_OPTY_020_Res) JSON.deserialize(
    //             responseString, 
    //             IF_ERP_Quotation_Classes.IF_OPTY_020_Res.class);    
    
    //             return response;        

    //     } catch (Exception e) {
    //         System.debug('ERROR MESSAGE : '+e.getMessage());
    //         System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
    //         return null;        
    //     }
    // }  
    public List<IF_ERP_Quotation_Classes.IF_OPTY_020_Res> IF_OPTY_020(List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req> parmeterList){
        interfaceId = 'IF-OPTY-020';   
        List<String> parmetersStringList = new List<String>();
        for (IF_ERP_Quotation_Classes.IF_OPTY_020_Req parmeters : parmeterList) {
            String parmetersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parmeters) 
                                + '}'; 
            parmetersStringList.add(parmetersString);
        }

        // interfaceUtil.isu0024Case = true;
        interfaceUtil.isURLEncode = true;
        List<String> responseStringList = interfaceUtil.sendHttp(parmetersStringList, interfaceId, apexClassName, isResponseXml);

        try {
            List<IF_ERP_Quotation_Classes.IF_OPTY_020_Res> responseList = new List<IF_ERP_Quotation_Classes.IF_OPTY_020_Res>();

            for (String responseString : responseStringList) {
                IF_ERP_Quotation_Classes.IF_OPTY_020_Res response =
                (IF_ERP_Quotation_Classes.IF_OPTY_020_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Quotation_Classes.IF_OPTY_020_Res.class);    
                
                responseList.add(response);
            }
            return responseList;
        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }  

/** SFDC interface Id   : IF-ORDER-021
 * New I/F              : ZCRM_SD_QT_SO_CRE
 * Description          : Quotation 수정 (CRM -> ERP)
    */
    // public IF_ERP_Quotation_Classes.IF_ORDER_021_Res IF_ORDER_021(IF_ERP_Quotation_Classes.IF_ORDER_021_Req parmeters){
    //     interfaceId = 'IF-ORDER-021';            
    //     String parmetersString = 'InputParam=' 
    //                         + '{"Input":' 
    //                         + JSON.serialize(parmeters) 
    //                         + '}'; 

    //     // interfaceUtil.isu0024Case = true;
    //     interfaceUtil.isURLEncode = true;
    //     String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);

    //     try {
    //         System.debug('responseString :: '+responseString);

    //         IF_ERP_Quotation_Classes.IF_ORDER_021_Res response = 
    //         (IF_ERP_Quotation_Classes.IF_ORDER_021_Res) JSON.deserialize(
    //             responseString, 
    //             IF_ERP_Quotation_Classes.IF_ORDER_021_Res.class);    
    
    //             return response;        

    //     } catch (Exception e) {
    //         System.debug('ERROR MESSAGE : '+e.getMessage());
    //         System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
    //         return null;        
    //     }
    // }  
}