public with sharing class IF_ERP_Service_CostAdjustment {

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String apexClassName        = 'IF_ERP_Service_CostAdjustment';
    private Boolean isResponseXml       = true;    
    private String interfaceId;
    public IF_ERP_Service_CostAdjustment() {}


    // SFDC interface Id    : IF_SERVICE_044
    // AS-IS RFC            : ZCS_RECV_SVC_LABOR_SAVE       
    // New I/F              : ZCRM_CS_RECV_SVC_LABOR_SAVE				
    // Description          : 비용정산 저장(Order 번호를 기준으로 테이블 업데이트)
    public IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res IF_SERVICE_044(IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Req parmeters){
        interfaceId = 'IF-SERVICE-044';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);


    try{
        IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res response = 
            (IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_044_Res.class
                );


            System.debug(':::::::::::::    RESULT');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');     
            System.debug(':::::::::::::  REQUEST =>');
            System.debug(':::::::::::::    {');
            System.debug(':::::::::::::    '+parmetersString);
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_RECV_SVC_LABOR_SAVE');
            return response;

        }
        catch(Exception e){
            System.debug('Exception Manager : '+e.getMessage());
            System.debug('Exception Manager Line : '+e.getLineNumber());
            return null;
        }
    }

// ** IF-SERVICE-043
/**
  */
  /**
     * Class Name           : IF_ERP_Service_CostAdjustment 
     * Wrapper Name         : IF-SERVICE-043
     * SFDC interface Id    : IF-SERVICE-043
     * AS-IS RFC            : ZCS_SEND_WEB_SVC_LABOR_COST      
     * New I/F              : ZCRM_CS_SEND_WEB_SVC_LABOR_COS
     * Description          : 비용정산 목록 조회 
     * REAL                 : Y  
  */ 
  public IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res IF_SERVICE_043(IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Req parmeters){
    interfaceId = 'IF-SERVICE-043';            
    String parmetersString = 'InputParam=' 
                        + '{"Input":' 
                        + JSON.serialize(parmeters) 
                        + '}'; 

    String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
    

    IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res response = 
        (IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res) JSON.deserialize(
            responseString, 
            IF_ERP_Service_CostAdjustment_Classes.IF_SERVICE_043_Res.class
            );

        System.debug(':::::::::::::    RESULT');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');     
        System.debug(':::::::::::::  REQUEST =>');
        System.debug(':::::::::::::    {');
        System.debug(':::::::::::::    '+parmetersString);
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
        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_SEND_WEB_SVC_LABOR_COST');
        System.debug(':::::::::::::    CLASS NAME   : '+apexClassName);            


    return response;
}    
}