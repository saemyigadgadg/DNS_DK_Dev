public with sharing class IF_ERP_PE_Inquery {
    public IF_ERP_PE_Inquery() {}
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_PE_Inquery';
    private Boolean isResponseXml = true;  
    private String  interfaceId;


// ** IF-PARTS-029
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_029
         * SFDC interface Id    : IF-PARTS-029
         * New I/F              : ZCRM_SS_RECV_PE_INQUIRY_LIST
         * Description          : PE Inquiry list 조회
  */    
    public IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res IF_PARTS_029(IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req parameters){
        interfaceId = 'IF-PARTS-029';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 
        interfaceUtil.isURLEncode = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
                            
        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res response = 
                (IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res) JSON.deserialize(responseString, IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res.class);

                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }     

// ** IF-PARTS-030
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_030
         * SFDC interface Id    : IF-PARTS-030
         * New I/F              : ZCRM_SS_PE_INQUIRY_SIMULATION
         * Description          : Parts 가격 조회
  */    
    public IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res IF_PARTS_030(IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req parameters){
        interfaceId = 'IF-PARTS-030';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 
        interfaceUtil.isURLEncode = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
                            
        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res response = 
                (IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res) JSON.deserialize(responseString, IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res.class);

                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    } 




// ** IF-PARTS-031
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_031
         * SFDC interface Id    : IF-PARTS-031
         * New I/F              : ZCRM_SS_RECV_PE_INQUIRY_CREATE
         * Description          : PE Inquiry 생성
  */    
    public IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res IF_PARTS_031(IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req parameters){
        List<IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH>    IT_ATTACH     = parameters.IT_ATTACH;

        for (IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH IT_ATTACH_E : IT_ATTACH) {
            if(IT_ATTACH_E.FILE_NAME != null) IT_ATTACH_E.FILE_NAME      = EncodingUtil.urlEncode(IT_ATTACH_E.FILE_NAME, 'UTF-8');
        }

        interfaceId = 'IF-PARTS-031';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        parametersString = encodeForSAP(parametersString);

        parametersString = parametersString.replace('"IT_ATTACH":[]', '"IT_ATTACH":' + Json.serialize(IT_ATTACH));

        interfaceUtil.isCustomURLEncode = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res response = 
                (IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res) JSON.deserialize(responseString, IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res.class);


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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SS_RECV_PE_INQUIRY_CREATE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }       

// ** IF-PARTS-032
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_032
         * SFDC interface Id    : IF-PARTS-032
         * New I/F              : ZCRM_SS_RECV_PE_INQUIRY_DETAIL
         * Description          : PE Inquiry 상세 화면 조회
  */
    public IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res IF_PARTS_032(IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req parameters){
        interfaceId = 'IF-PARTS-032';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 
        interfaceUtil.isURLEncode = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
                            

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res response = 
                (IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res) JSON.deserialize(responseString, IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res.class);

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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SS_RECV_PE_INQUIRY_DETAIL');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }        
 
// ** IF-PARTS-033
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_033
         * SFDC interface Id    : IF-PARTS-033
         * New I/F              : ZCRM_SS_PE_INQUIRY_FILE_DOWN
         * Description          : PE Inquiry 첨부 파일 조회
  */    
    public IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res IF_PARTS_033(IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Req parameters){
        interfaceId = 'IF-PARTS-033';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 
        interfaceUtil.isURLEncode = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
                            

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res response = 
                (IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res) JSON.deserialize(responseString, IF_ERP_PE_Inquery_Classes.IF_PARTS_033_Res.class);

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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SS_PE_INQUIRY_FILE_DOWN');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }        
  
    private String encodeForSAP(String jsonString){
        jsonString = EncodingUtil.urlEncode(jsonString, 'UTF-8');
        jsonString = jsonString.replaceAll('%3D', '=');
        jsonString = jsonString.replaceAll('%7B', '{');
        jsonString = jsonString.replaceAll('%22', '"');
        jsonString = jsonString.replaceAll('%3A', ':');
        jsonString = jsonString.replaceAll('%7D', '}');  
        jsonString = jsonString.replaceAll('%5B', '[');  
        jsonString = jsonString.replaceAll('%5D', ']');  

        return jsonString;
    }

}