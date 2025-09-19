/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : JangJunHee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-12-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_PowerBI_Opportunity implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable{
    public IF_PowerBI_Opportunity() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String    apexClassName = 'IF_PowerBI_Opportunity';
    private Boolean   isResponseXml = true;  
    private String    interfaceId;
    public  Datetime  fromDate;
    public  Datetime  toDate;

    public class PowerBI_RequestDto {
        public String DOCTYPE            {get;set;}             
        public String VKORG              {get;set;}         
        public String DIST_CHANNEL       {get;set;}                 
        public String DIVISION           {get;set;}             
        public String SALES_STAGE_NM     {get;set;}                     
        
        public String INQUIRY_NO         {get;set;}              
        public String PACKAGE_NO         {get;set;}                 
        public String BRANCH_NM          {get;set;}             
        public String DEALER_NM          {get;set;}             
        public String REG_USER_NM        {get;set;}                 
        
        public String CUST_CD            {get;set;}             
        public String CUST_NM            {get;set;}             
        public String CUST_TYPE          {get;set;}             
        public String RIVAL_CUST_YN      {get;set;}                 
        public String CUST_ADDRESS       {get;set;}                 
        
        public String CUST_REP_NM        {get;set;}                 
        public String CUST_TEL           {get;set;}             
        public String MODEL_NM           {get;set;}             
        public String PRODUCT_CD         {get;set;}                 
        public String PRODUCT_CNT        {get;set;}                 
        
        public String SQ                 {get;set;}         
        public String REG_DATE           {get;set;}             
        public String CHG_DATE           {get;set;}             
        // public String CONTRACT_DATE      {get;set;}                 
        // public String PAYMENT_DATE       {get;set;}                 
        
        public String DELIVERY_DATE      {get;set;}                 
        // public String ORDER_DATE         {get;set;}                 
        public String INSIGHT_NM         {get;set;}                 
        // public String OPTION_FLAG        {get;set;}                 
        public String INDUST_DIV1_NM     {get;set;}                     
        
        public String INDUST_DIV2_NM     {get;set;}                     
        public String INDUST_DIV3_NM     {get;set;}                     
        // public String WORKPIECE          {get;set;}             
        // public String CREASON            {get;set;}             
        public String CREASON1           {get;set;}             
        
        public String CREASON2           {get;set;}             
        // public String CREASON3           {get;set;}             
        // public String ORDER_DIF          {get;set;}             
        // public String CONTRACT_DIF       {get;set;}                 
        // public String DELIVERY_DIF       {get;set;}                 
        
        public String NOTE               {get;set;}         
        public String CNT                {get;set;}         
        // public String DELIVERY_MONTH     {get;set;}                     
        public String REG_QTR            {get;set;}             
        public String CREATE_DATE        {get;set;}         

        public String REG_USER_ID        {get;set;}             
    }

    public class PowerBI_ResponseDto {
        public String E_MSGTY            {get;set;}   
        public String E_MSGTX            {get;set;}           
    }

    public void execute(SchedulableContext sc) {
        Date today = Date.today();
        IF_PowerBI_Opportunity batch = new IF_PowerBI_Opportunity();
        Datetime todayDT = Datetime.newInstance(today.year(), today.month(), today.day(), 0, 0, 0);
        Datetime now   = Datetime.now();
        batch.fromDate = todayDT;
        batch.toDate   = now;

        Database.executeBatch(batch, 100);
    }

    public List<OpportunityLineItem> start(Database.BatchableContext BC) {
        System.debug('IF_PowerBI_Opportunity Start ------------');
        try {
            List<OpportunityLineItem> opptyLIList = [
                SELECT Opportunity.RecordType.Name, Opportunity.Inquiry_Type__c, Opportunity.Owner.SalesOrganization__c,
                    Opportunity.Owner.DistributionChannel__c, Opportunity.Owner.Division__c, Opportunity.FM_SatagePB__c,
                    ERPInquiryNo__c, Opportunity.PackageNo__c, Opportunity.FM_SalesOffice__c, 
                    Opportunity.Dealer__r.Name, Opportunity.Owner.Name, Opportunity.Account.CustomerCode__c, 
                    Opportunity.Account.Name, Opportunity.HasCompetitor__c, Opportunity.Account.ShippingCity,
                    Opportunity.CustomerContact__r.Name, Opportunity.CustomerContact__r.Phone,
                    Product2.Model__r.Name, Product2.Name, Quantity, CreatedDate, 
                    Opportunity.LastModifiedDate, Opportunity.RequestDelieveryDate__c, Opportunity.Insight__c,
                    Opportunity.FM_MainPB__c, Opportunity.FM_SubPB__c, Opportunity.IsTooling__c, 
                    Opportunity.Reason_Sales__c, Opportunity.Reason_Service__c, Opportunity.FM_AccountTypePB__c,
                    Opportunity.Description__c, LastModifiedDate, Opportunity.Dealer__c, 
                    Opportunity.owner.FM_UserIdPB__c, FM_CreatationDate__c

                FROM OpportunityLineItem
                WHERE Opportunity.Inquiry_Type__c != 'ZIPS' AND ERPInquiryNo__c != null AND ERPInquiryNo__c != ''
            ];

            return opptyLIList;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw e;
        }
    }
    public void execute(Database.BatchableContext bc, List<OpportunityLineItem> scope) {
        System.debug('IF_PowerBI_Opportunity Execute ------------');
        List<PowerBI_RequestDto> reqList = new List<PowerBI_RequestDto>();
        for (OpportunityLineItem opptyLI : scope) reqList.add(mappingRequest(opptyLI));

        interfaceId = 'IF-OPTY-034';
        String reqString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(reqList) 
                                    + '}';

        interfaceUtil.isURLEncode = true;
        String responseString = interfaceUtil.sendHttp(reqString, interfaceId, apexClassName, false);

        PowerBI_ResponseDto response = 
            (PowerBI_ResponseDto) JSON.deserialize(responseString, PowerBI_ResponseDto.class);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('IF_PowerBI_Opportunity Finish ------------');
    }

    public PowerBI_RequestDto mappingRequest(OpportunityLineItem opptyLI){
        PowerBI_RequestDto req = new PowerBI_RequestDto();

        try {
            req.DOCTYPE             = opptyLI.Opportunity.Inquiry_Type__c == null ? 'ZINM' : opptyLI.Opportunity.Inquiry_Type__c;
            req.VKORG               = opptyLI.Opportunity.Owner.SalesOrganization__c ;
            req.DIST_CHANNEL        = opptyLI.Opportunity.Owner.DistributionChannel__c;
            req.DIVISION            = opptyLI.Opportunity.Owner.Division__c;
            req.SALES_STAGE_NM      = opptyLI.Opportunity.FM_SatagePB__c;
            
            req.INQUIRY_NO          = opptyLI.ERPInquiryNo__c;                      
            req.PACKAGE_NO          = opptyLI.Opportunity.PackageNo__c == null ? 'NULL' : String.valueOf(opptyLI.Opportunity.PackageNo__c);
            req.BRANCH_NM           = opptyLI.Opportunity.FM_SalesOffice__c == null ? 'NULL' : opptyLI.Opportunity.FM_SalesOffice__c;
            req.DEALER_NM           = opptyLI.Opportunity.Dealer__c == null ? opptyLI.Opportunity.Owner.Name : opptyLI.Opportunity.Dealer__r.Name;
            req.REG_USER_NM         = opptyLI.Opportunity.Owner.Name;

            req.CUST_CD             = opptyLI.Opportunity.Account.CustomerCode__c;
            req.CUST_NM             = opptyLI.Opportunity.Account.Name;
            req.CUST_TYPE           = opptyLI.Opportunity.FM_AccountTypePB__c;
            if(opptyLI.Opportunity.HasCompetitor__c != null) req.RIVAL_CUST_YN = opptyLI.Opportunity.HasCompetitor__c;
            req.CUST_ADDRESS        = opptyLI.Opportunity.Account.ShippingCity;
            
            req.CUST_REP_NM         = opptyLI.Opportunity.CustomerContact__r.Name;
            req.CUST_TEL            = opptyLI.Opportunity.CustomerContact__r.Phone == null ? '0' : opptyLI.Opportunity.CustomerContact__r.Phone;
            req.MODEL_NM            = opptyLI.Product2.Model__r.Name == null ? 'NULL' : opptyLI.Product2.Model__r.Name;
            req.PRODUCT_CD          = opptyLI.Product2.Name;
            req.PRODUCT_CNT         = String.valueOf(Integer.valueOf(opptyLI.Quantity));
            
            req.SQ                  = '0';

            String creatationDate   = opptyLI.FM_CreatationDate__c;
            // req.REG_DATE            =
            //     String.valueOf(createdDate.year()) + 
            //     String.valueOf(createdDate.month()).leftPad(2, '0') + 
            //     String.valueOf(createdDate.day()).leftPad(2, '0');
            req.REG_DATE            = creatationDate;
                
            Datetime lastmodifiedDate   = opptyLI.LastModifiedDate;
            req.CHG_DATE                = 
                String.valueOf(lastmodifiedDate.year()) + 
                String.valueOf(lastmodifiedDate.month()).leftPad(2, '0') + 
                String.valueOf(lastmodifiedDate.day()).leftPad(2, '0');
            // req.CONTRACT_DATE       = 
            // req.PAYMENT_DATE        = 
            
            Date deliveryDate       = opptyLI.Opportunity.RequestDelieveryDate__c;
            req.DELIVERY_DATE       = deliveryDate != null ?
                String.valueOf(deliveryDate.year()) + 
                String.valueOf(deliveryDate.month()).leftPad(2, '0') + 
                String.valueOf(deliveryDate.day()).leftPad(2, '0') :
                'NULL';
            // req.ORDER_DATE          = 
            req.INSIGHT_NM          = convertInsight(opptyLI.Opportunity.Insight__c);
            // req.OPTION_FLAG         = 
            req.INDUST_DIV1_NM      = opptyLI.Opportunity.FM_MainPB__c;
            
            req.INDUST_DIV2_NM      = opptyLI.Opportunity.FM_SubPB__c == null ? '기타' : opptyLI.Opportunity.FM_SubPB__c;
            req.INDUST_DIV3_NM      = opptyLI.Opportunity.IsTooling__c == 'MY'? '금형' : '비금형';
            // req.WORKPIECE           = 
            // req.CREASON             = 
            req.CREASON1            = opptyLI.Opportunity.Reason_Sales__c == null ? 'NULL' : opptyLI.Opportunity.Reason_Sales__c;
            
            req.CREASON2            = opptyLI.Opportunity.Reason_Service__c == null ? 'NULL' : opptyLI.Opportunity.Reason_Service__c;
            // req.CREASON3            = 
            // req.ORDER_DIF           = 
            // req.CONTRACT_DIF        = 
            // req.DELIVERY_DIF        = 
            
            req.NOTE                = opptyLI.Opportunity.Description__c == null ? 'NULL' : opptyLI.Opportunity.Description__c;
            req.CNT                 = '1';
            // req.DELIVERY_MONTH      = 
            req.REG_QTR             = creatationDate.substring(2, 4) + ' ' + calcuQ(Integer.valueOf(creatationDate.substring(4, 6)));
            req.CREATE_DATE         = 
                creatationDate.substring(0, 4) + '-' 
                + creatationDate.substring(4, 6) + '-' 
                + creatationDate.substring(6, 8) + ' 00:00:00';
            
            req.REG_USER_ID         = opptyLI.Opportunity.owner.FM_UserIdPB__c;

        } catch (Exception e) {
            System.debug('Error ::: [' + e.getLineNumber() + ']' + e.getMessage());
        }

        return req;
    }
    public String calcuQ(Integer Month){
        if(Month >= 1  && Month < 4) return '1Q';
        else if(Month >= 4  && Month < 7) return '2Q';
        else if(Month >= 7  && Month < 10) return '3Q';
        else return '4Q';
    }
    public String convertInsight(String insight){
        if(insight == '25%') return '30%미만';
        else if(insight == '50%') return '50~30%';
        else if(insight == '75%') return '70~50%';
        else if(insight == '100%') return '90%이상';
        else return '30%미만';
    }

}