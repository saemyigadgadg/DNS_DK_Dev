/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-11-2025
 * @last modified by  : JangJunHee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-09-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_PowerBI_Valid_Opportunity implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable{
    public IF_PowerBI_Valid_Opportunity() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_PowerBI_Valid_Opportunity';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    public Integer batchYear;
    public Integer batchMonth;

    public class PowerBI_RequestDto {
        public String VALID_PERIOD      {get;set;}    
        public String VALID_DATE        {get;set;}    
        public String SALES_STAGE_NM    {get;set;}        
        public String INQUIRY_NO        {get;set;}    
        public String INDUST_DIV1_NM    {get;set;}          

        public String CREATE_DATE       {get;set;}
    }

    public void execute(SchedulableContext sc) {
        IF_PowerBI_Valid_Opportunity batch = new IF_PowerBI_Valid_Opportunity();
        Date today = Date.today();

        if(today.month() == 1){
            batch.batchYear  = today.year() - 1;
            batch.batchMonth = 12;
        }else{
            batch.batchYear  = today.year();
            batch.batchMonth = today.month() - 1;
        }

        Database.executeBatch(batch, 100);
    }

    public class PowerBI_ResponseDto {
        public String E_MSGTY            {get;set;}   
        public String E_MSGTX            {get;set;}           
    }

    public List<OpportunityLineItem> start(Database.BatchableContext BC) {
        System.debug('IF_PowerBI_Valid_Opportunity Start ------------');
        try {
            List<OpportunityLineItem> opptyLIList = [
                SELECT id, Opportunity.CloseDate, Opportunity.FM_SatagePB__c, ERPInquiryNo__c, 
                    Opportunity.FM_MainPB__c,  CreatedBy.Name, CreatedDate
                FROM OpportunityLineItem 
                WHERE ERPInquiryNo__c != null AND Opportunity.Inquiry_Type__c != 'ZIPS' AND Opportunity.CurrencyIsoCode = 'KRW'
                    AND (NOT(Opportunity.StageName like 'Close%')) 
            ];

            return opptyLIList;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw e;
        }
    }
    public void execute(Database.BatchableContext bc, List<OpportunityLineItem> scope) {
        List<PowerBI_RequestDto> reqList = new List<PowerBI_RequestDto>();
        for (OpportunityLineItem opptyLI : scope) reqList.add(mappingRequest(opptyLI));
        
        interfaceId = 'IF-OPTY-035';
        String reqString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(reqList) 
                                    + '}';

        String responseString = interfaceUtil.sendHttp(reqString, interfaceId, apexClassName, false);

        PowerBI_ResponseDto response = 
            (PowerBI_ResponseDto) JSON.deserialize(responseString, PowerBI_ResponseDto.class);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('IF_PowerBI_Valid_Opportunity Finish ------------');
    }

    public PowerBI_RequestDto mappingRequest(OpportunityLineItem opptyLI){
        PowerBI_RequestDto req = new PowerBI_RequestDto();

        try {
            Datetime closeDate = opptyLI.Opportunity.CloseDate;

            req.VALID_PERIOD        =               
                String.valueOf(this.batchYear).substring(2) + '.' + 
                String.valueOf(this.batchMonth).leftPad(2, '0');
            req.VALID_DATE          =
                String.valueOf(this.batchYear) + '-' +
                String.valueOf(this.batchMonth).leftPad(2, '0') + '-01';
            req.SALES_STAGE_NM      = opptyLI.Opportunity.FM_SatagePB__c;
            req.INQUIRY_NO          = opptyLI.ERPInquiryNo__c;
            req.INDUST_DIV1_NM      = opptyLI.Opportunity.FM_MainPB__c;

            req.CREATE_DATE         = String.valueOf(opptyLI.CreatedDate);

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return req;
    }
}