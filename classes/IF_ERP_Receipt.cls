public with sharing class IF_ERP_Receipt {
    public IF_ERP_Receipt() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Receipt';
    private Boolean isResponseXml = true;  
    private String  interfaceId;
    
/** SFDC interface Id   : IF-CSPLUS-008
 * AS-IS RFC            : ZCS_SEND_MT_GET_PACKING_DATE 
 * New I/F              : ZCRM_CS_MT_GET_PACKING_DATE       
 * Description          : 포장완료일 조회
    */
    public IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res IF_CSPLUS_008(IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req parameters){
        interfaceId = 'IF-CSPLUS-008';

        System.debug('input parameter  : '+parameters);
        System.debug('input parameter JSON.string  : '+JSON.serialize(parameters));
    
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res response = 
            (IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res) JSON.deserialize(responseString, IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res.class);


            System.debug(':::::::::::::    RESULT');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');     
            System.debug(':::::::::::::  REQUEST =>');
            System.debug(':::::::::::::    {');
            System.debug(':::::::::::::    '+parametersString);
            System.debug(':::::::::::::    } ');
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_GET_PACKING_DATE');
            System.debug(':::::::::::::    CLASS NAME   : '+apexClassName);            

        return response;
    }
    public List<IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res> IF_CSPLUS_008(List<IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req> parmetersList){
        interfaceId = 'IF-CSPLUS-008';
        List<String> parametersStringList = new List<String>();
        for (IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req parameters : parmetersList) {
            String parametersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parameters)
                                + '}'; 
            parametersStringList.add(parametersString);
        }

        List<String> responseStringList = interfaceUtil.sendHttp(parametersStringList, interfaceId, apexClassName, isResponseXml);
        
        List<IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res> responseList = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res>();
        for (String responseString : responseStringList) {

            IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res response = 
                (IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res) JSON.deserialize(responseString, IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res.class);

            responseList.add(response);
        }

        return responseList;
    }

/** SFDC interface Id   : IF-CSPLUS-025
 * AS-IS RFC            : Z_CS_MT_AS_RECEIPT_LIST3 
 * New I/F              : ZCRM_CS_MT_AS_RECEIPT_LIST3       
 * Description          : * 필드하자 관리 대상 장비의 출하정보 매출정보 등 다양한 정보 조회
    */
    public IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res IF_CSPLUS_025(IF_ERP_Receipt_Classes.IF_CSPLUS_025_Req parameters){
        interfaceId = 'IF-CSPLUS-025';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);


        IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res response = 
            (IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res) JSON.deserialize(responseString, IF_ERP_Receipt_Classes.IF_CSPLUS_025_Res.class);
            
            System.debug(':::::::::::::    RESULT');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');     
            System.debug(':::::::::::::  REQUEST =>');
            System.debug(':::::::::::::    {');
            System.debug(':::::::::::::    '+parametersString);
            System.debug(':::::::::::::    } ');
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_AS_RECEIPT_LIST3');
            System.debug(':::::::::::::    CLASS NAME   : '+apexClassName);    

        return response;
    }

/** SFDC interface Id   : IF-CSPLUS-032
 * AS-IS RFC            : Z_CS_INSTALL_PRBM_SAVE
 * New I/F              : ZCRM_CS_INSTALL_PRBM_SAVE
 * Description          : * 설치 하자로 생성된 WorkOrder인지 여부 전송
    */ 
    public IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res IF_CSPLUS_032(IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req parameters){
        interfaceId = 'IF-CSPLUS-032';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res response = 
            (IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res) JSON.deserialize(responseString, IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res.class);

        return response;
    }
    public List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res> IF_CSPLUS_032(List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req> parmetersList){
        interfaceId = 'IF-CSPLUS-032';
        List<String> parametersStringList = new List<String>();
        for (IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req parameters : parmetersList) {
            String parametersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parameters)
                                + '}'; 
            parametersStringList.add(parametersString);
        }

        List<String> responseStringList = interfaceUtil.sendHttp(parametersStringList, interfaceId, apexClassName, isResponseXml);

        List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res> responseList = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res>();
        for (String responseString : responseStringList) {
            System.debug('responseString ::? ' + responseString);
            IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res response = 
                (IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res) JSON.deserialize(responseString, IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res.class);

            responseList.add(response);
        }

        return responseList;
    }
    
/** SFDC interface Id   : IF-CSPLUS-033
 * AS-IS RFC            : Z_CS_MT_MAT_REQUEST_LIST
 * New I/F              : ZCRM_CS_MT_MAT_REQUEST_LIST
 * Description          : * 필드하자 관리 부품 확보상태 조회
    */ 
    public IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res IF_CSPLUS_033(IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req parameters){
        interfaceId = 'IF-CSPLUS-033';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 



        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res response = 
            (IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res) JSON.deserialize(responseString, IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res.class);

        System.debug(':::::::::::::    RESULT');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');     
        System.debug(':::::::::::::  REQUEST =>');
        System.debug(':::::::::::::    {');
        System.debug(':::::::::::::    '+parametersString);
        System.debug(':::::::::::::    } ');
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
        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_MT_MAT_REQUEST_LIST');
        System.debug(':::::::::::::    CLASS NAME   : '+apexClassName);    

        return response;
    }

}