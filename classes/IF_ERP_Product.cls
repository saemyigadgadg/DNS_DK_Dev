/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-18-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Product {
    public IF_ERP_Product() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Product';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    /** SFDC interface Id    : IF-OPTY-002
     *  New I/F              : ZCRM_SD_MS_MATERIAL_LST       
     *  Description          : 자재마스터 대표사양, 모델, 부품, 서비스 패키지 정보 생성 (ERP -> CRM)
        */ 
        public IF_ERP_Product_Classes.IF_OPTY_002_Res IF_OPTY_002(IF_ERP_Product_Classes.IF_OPTY_002_Req parameters){
            interfaceId = 'IF-OPTY-002';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Product_Classes.IF_OPTY_002_Res response = 
                (IF_ERP_Product_Classes.IF_OPTY_002_Res) JSON.deserialize(responseString, IF_ERP_Product_Classes.IF_OPTY_002_Res.class);
    
            return response;
        }


    /** SFDC interface Id    : IF-OPTY-004
     *  New I/F              : ZCRM_SD_GET_ADDITION_PARTS_LST       
     *  Description          : 자재마스터 부품(추가자재) 정보 조회
        */ 
        public IF_ERP_Product_Classes.IF_OPTY_004_Res IF_OPTY_004(IF_ERP_Product_Classes.IF_OPTY_004_Req parameters){
            interfaceId = 'IF-OPTY-004';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


            try {
                System.debug('responseString :: '+responseString);

                IF_ERP_Product_Classes.IF_OPTY_004_Res response = 
                (IF_ERP_Product_Classes.IF_OPTY_004_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Product_Classes.IF_OPTY_004_Res.class);
    
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_ADDITION_PARTS_LST');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }

    /** SFDC interface Id    : IF-OPTY-023
     * AS-IS RFC            : Z_SD_GET_DEFAULT_ITEM_CONFIG1
     * New I/F              : ZCRM_SD_GET_DEFAULT_ITEM_CONFI       
     * Description          : 대표사양 별 선택된 옵션 정보, Object Dependency 정보 조회
        */
        public IF_ERP_Product_Classes.IF_OPTY_023_Res IF_OPTY_023(IF_ERP_Product_Classes.IF_OPTY_023_Req parameters){
            interfaceId = 'IF-OPTY-023';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            try {
                String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
                IF_ERP_Product_Classes.IF_OPTY_023_Res response = 
                    (IF_ERP_Product_Classes.IF_OPTY_023_Res) JSON.deserialize(responseString, IF_ERP_Product_Classes.IF_OPTY_023_Res.class);
                
                return response;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            // String responseString = convertATNAM(interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml));

            return null;
        }
        // private String convertATNAM(String responseString){
        //     try {
        //         Map<String, Object> returnMap    = new Map<String, Object>();
        //         Map<String, Object> responseJSON = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        //         returnMap.put('O_RETURN', responseJSON.get('O_RETURN'));

        //         List<String> convertList = new List<String> {
        //             'T_OPTION', 'T_VALUE', 'T_INITSEL', 'T_SELECT',
        //             'T_INCON_VALUE', 'T_INCOM_OPTION', 'T_GROUP', 'T_USERSEL'
        //         };

        //         for (String convertField : convertList) {
        //             List<Object> dataList      = (List<Object>) responseJSON.get(convertField); // T_OPTION List
        //             List<Object> newDataList   = new List<Object>();

        //             for (Object data : dataList) {
        //                 Map<String, Object> dataMap = (Map<String, Object>) data;
        //                 String ATNAM = String.valueOf(dataMap.get('ATNAM'));

        //                 if (ATNAM.startsWith('M_') || 'MFPRO'.equals(ATNAM)) newDataList.add(data);
        //             }
        //             returnMap.put(convertField, (Object) newDataList);
        //         }

        //         responseString = JSON.serialize(returnMap);
        //     } catch (Exception e) {
        //         System.debug('convertATNAM Error : ' + e.getMessage() + '[' + e.getLineNumber() + ']');
        //     }
        //     return responseString;
        // }

    /** SFDC interface Id    : IF-OPTY-023
     * AS-IS RFC            : Z_SD_GET_DEFAULT_ITEM_CONFIG1
     * New I/F              : ZCRM_SD_GET_DEFAULT_ITEM_CONFI       
     * Description          : 대표사양 별 선택된 옵션 정보, Object Dependency 정보 조회
        */
        // public List<IF_ERP_Product_Classes.IF_OPTY_023_Res> IF_OPTY_023(List<IF_ERP_Product_Classes.IF_OPTY_023_Req> parmeterList){
        //     interfaceId = 'IF-OPTY-023';
        //     List<String> parmetersStringList = new List<String>();
        //     for (IF_ERP_Product_Classes.IF_OPTY_023_Req parmeters : parmeterList) {
        //         String parmetersString = 'InputParam=' 
        //                             + '{"Input":' 
        //                             + JSON.serialize(parmeters) 
        //                             + '}'; 
        //         parmetersStringList.add(parmetersString);
        //     }
            
        //     String responseString = convertATNAM(interfaceUtil.sendHttpCaseI_VBELN(parmetersStringList, interfaceId, apexClassName, isResponseXml));

        //     List<IF_ERP_Product_Classes.IF_OPTY_023_Res> response = 
        //         (List<IF_ERP_Product_Classes.IF_OPTY_023_Res>) JSON.deserialize(responseString, List<IF_ERP_Product_Classes.IF_OPTY_023_Res>.class);

        // System.debug('result ::: ' + response);

        //     return response;
        // }
        // private String convertATNAM(List<String> responseStringList){
        //     String returnString = 'Error';
        //     try {
        //         List<Map<String, Object>> returnMapList = new List<Map<String, Object>>();

        //         for (String responseString : responseStringList) {

        //             Map<String, Object> returnMap    = new Map<String, Object>();
        //             Map<String, Object> responseJSON = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        //             returnMap.put('O_RETURN', responseJSON.get('O_RETURN'));
        //             returnMap.put('I_VBELN', responseJSON.get('I_VBELN'));
    
        //             List<String> convertList = new List<String> {
        //                 'T_OPTION', 'T_VALUE', 'T_INITSEL', 'T_SELECT',
        //                 'T_INCON_VALUE', 'T_INCOM_OPTION', 'T_GROUP', 'T_USERSEL'
        //             };
    
        //             for (String convertField : convertList) {
        //                 List<Object> dataList      = (List<Object>) responseJSON.get(convertField); // T_OPTION List
        //                 List<Object> newDataList   = new List<Object>();
    
        //                 for (Object data : dataList) {
        //                     Map<String, Object> dataMap = (Map<String, Object>) data;
        //                     String ATNAM = String.valueOf(dataMap.get('ATNAM'));
    
        //                     if (ATNAM.startsWith('M_') || 'MFPRO'.equals(ATNAM)) newDataList.add(data);
        //                 }
        //                 returnMap.put(convertField, (Object) newDataList);
        //             }
        //             returnMapList.add(returnMap);
        //         }
        //         returnString = JSON.serialize(returnMapList);
        //     } catch (Exception e) {
        //         System.debug('convertATNAM Error : ' + e.getMessage() + '[' + e.getLineNumber() + ']');
        //     }

        //     return returnString;
        // }

    /** SFDC interface Id    : IF-OPTY-027
     * RFC Name              : ZCRM_SD_GET_CV_MARKUP       
     * Description           : CV Markup 조회 (CRM -> ERP)
        */
        public IF_ERP_Product_Classes.IF_OPTY_027_Res IF_OPTY_027(){
            interfaceId = 'IF-OPTY-027';
            String parametersString = 'InputParam=' 
                                        + '{"Input":{}}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Product_Classes.IF_OPTY_027_Res response = 
                (IF_ERP_Product_Classes.IF_OPTY_027_Res) JSON.deserialize(responseString, IF_ERP_Product_Classes.IF_OPTY_027_Res.class);
    
            return response;
        }

    /** SFDC interface Id    : IF-OPTY-029
     * RFC Name              : ZCRM_SD_GLOBAL_DEALER_BASECODE
     * Description           : 글로벌 딜러가 대표사양을 좀 더 구체적으로 식별할 수 있도록 추가 옵션 정보들을 적립해놓은 테이블 조회
        */
        public IF_ERP_Product_Classes.IF_OPTY_029_Res IF_OPTY_029(IF_ERP_Product_Classes.IF_OPTY_029_Req parameters){
            interfaceId = 'IF-OPTY-029';
            String parametersString = 'InputParam=' 
                                        + '{"Input":'
                                        + JSON.serialize(parameters) 
                                        + '}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Product_Classes.IF_OPTY_029_Res response = 
                (IF_ERP_Product_Classes.IF_OPTY_029_Res) JSON.deserialize(responseString, IF_ERP_Product_Classes.IF_OPTY_029_Res.class);
    
            return response;
        }

    /** SFDC interface Id    : IF-OPTY-030
     * RFC Name              : ZCRM_SD_REG_PROD_CODE
     * Description           : Sold-to permitted item 전송
        */
        public IF_ERP_Product_Classes.IF_OPTY_030_Res IF_OPTY_030(IF_ERP_Product_Classes.IF_OPTY_030_Req parameters){
            interfaceId = 'IF-OPTY-030';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            IF_ERP_Product_Classes.IF_OPTY_030_Res response = 
                (IF_ERP_Product_Classes.IF_OPTY_030_Res) JSON.deserialize(responseString, IF_ERP_Product_Classes.IF_OPTY_030_Res.class);
    
            return response;
        }

// ** IF-OPTY-031				
/**
  */
  /**
         * Wrapper Name         : IF_OPTY_031
         * SFDC interface Id    : IF-OPTY-031
         * New I/F              : ZCRM_SD_PART_SALES_ORG_GET
         * Description          : 부품 판매 조직 조회
  */    
    public IF_ERP_Product_Classes.IF_OPTY_031_Res IF_OPTY_031(IF_ERP_Product_Classes.IF_OPTY_031_Req parmeters){
        interfaceId = 'IF-OPTY-031';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Product_Classes.IF_OPTY_031_Res response = 
            (IF_ERP_Product_Classes.IF_OPTY_031_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Product_Classes.IF_OPTY_031_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_PART_SALES_ORG_GET');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }  
    }

// ** IF-OPTY-032				
/**
  */
  /**
         * Wrapper Name         : IF_OPTY_032
         * SFDC interface Id    : IF-OPTY-032
         * New I/F              : ZCRM_ST_BASE_CODE_LIST
         * Description          : 지역별 BASE CODE 조회
  */    
  public IF_ERP_Product_Classes.IF_OPTY_032_Res IF_OPTY_032(IF_ERP_Product_Classes.IF_OPTY_032_Req parmeters){
    interfaceId = 'IF-OPTY-032';            
    String parmetersString = 'InputParam=' 
                        + '{"Input":' 
                        + JSON.serialize(parmeters) 
                        + '}'; 

    String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
    

    try {
        System.debug('responseString :: '+responseString);

        IF_ERP_Product_Classes.IF_OPTY_032_Res response = 
        (IF_ERP_Product_Classes.IF_OPTY_032_Res) JSON.deserialize(
            responseString, 
            IF_ERP_Product_Classes.IF_OPTY_032_Res.class);    

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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_ST_BASE_CODE_LIST');
            return response;        

    } catch (Exception e) {
        System.debug('ERROR MESSAGE : '+e.getMessage());
        System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
        return null;        
    }  
}    

// /** IF-OPTY-004
//     */  
//     /**
//          * Apex Class           : IF_ERP_Product
//          * Wrapper Class        : IF_ERP_Product_Classes
//          * Wrapper Name         : IF_OPTY_004
//          * SFDC interface Id    : IF-OPTY-004
//          * AS-IS RFC            : 
//          * New I/F              : ZCRM_SD_GET_ADDITION_PARTS_LST
//          * Description          : 자재마스터 부품(추가자재) 정보 조회 자재마스터 부품(추가자재) 정보 연동 자제 유형 KNA1 FERT 필요 
//          * KeyValue             : X
//          * NOT NULL             : X
//      */   
//     public IF_ERP_Product_Classes.IF_OPTY_004_Res IF_OPTY_004(IF_ERP_Product_Classes.IF_OPTY_004_Req parmeters){
//         interfaceId = 'IF-OPTY-004';            
//         String parmetersString = 'InputParam=' 
//                             + '{"Input":' 
//                             + JSON.serialize(parmeters) 
//                             + '}'; 

//         String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

//         try {
//             System.debug('responseString :: '+responseString);

//             IF_ERP_Product_Classes.IF_OPTY_004_Res response = 
//             (IF_ERP_Product_Classes.IF_OPTY_004_Res) JSON.deserialize(
//                 responseString, 
//                 IF_ERP_Product_Classes.IF_OPTY_004_Res.class);    
    
//                 System.debug(':::::::::::::    ');
//                 System.debug(':::::::::::::    ');            
//                 System.debug(':::::::::::::  RESPONSE =>');
//                 System.debug(':::::::::::::    {');
//                 System.debug(':::::::::::::    '+JSON.serialize(response));
//                 System.debug(':::::::::::::    } ');
//                 System.debug(':::::::::::::    ');
//                 System.debug(':::::::::::::    ');
//                 System.debug(':::::::::::::    ');
//                 System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
//                 System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_ADDITION_PARTS_LST');
//                 return response;        

//         } catch (Exception e) {
//             System.debug('ERROR MESSAGE : '+e.getMessage());
//             System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
//             return null;        
//         }    
}