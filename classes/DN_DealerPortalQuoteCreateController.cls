/** 
 * @Class : DN_DealerPortalQuoteCreateController
 * 
 * @Test: DN_DealerPortalQuoteCreateCon_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 24. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-24 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_DealerPortalQuoteCreateController {
    public DN_DealerPortalQuoteCreateController() {}

    /*
     * @ Method : currentUser
     * @ Description : 현재 사용자 정보
     *  
     */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /*
     * @ Method : doDownloadQuote
     * @ Description : 견적 정보 다운로드
     *  
     */
    @AuraEnabled
    public static Map<String,Object> doDownloadQuote(String recordId){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            
            Quote quoteWrapper = new Quote(recordId);
            List<Account> dealers = [
                SELECT
                ShippingStreet,
                ShippingPostalCode,
                DetailAddress__c,
                Fax,
                Phone,
                Mobile__c
                FROM Account WHERE Id = :quoteWrapper.dealer
            ];

            if(dealers.size() > 0) {
                quoteWrapper.address = dealers[0].ShippingStreet;
                quoteWrapper.phone = dealers[0].Phone;
                quoteWrapper.fax = dealers[0].Fax;
                quoteWrapper.postalCode = dealers[0].ShippingPostalCode;
            }

            result.put('quote', quoteWrapper);

        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug(e.getStackTraceString());
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, 500);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
     * @ Method : doSave
     * @ Description : 견적서 저장
     *  
     */
    @AuraEnabled
    public static Map<String,Object> doSave(Quote quote){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        //SavePoint 필요
        Savepoint sp = Database.setSavepoint(); 
        try {
            
            DealerQuote__c convertedQuote = quote.convertToSObject();
            insert convertedQuote;

            System.debug('convertedQuote.Id :: ' +convertedQuote.Id);
            List<DealerQuoteItem__c> convertedQuoteItems = new List<DealerQuoteItem__c>();
            for(QuoteItem item : quote.itemList) {
                DealerQuoteItem__c convertedQuoteItem = item.convertToSObject();
                convertedQuoteItem.Quote__c = convertedQuote.Id;
                convertedQuoteItems.add(convertedQuoteItem);
            }
            
            if(convertedQuoteItems.size() > 0) insert convertedQuoteItems;

            result.put('quoteId', convertedQuote.Id);

        } catch (Exception e) {
            Database.rollback(sp);
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug(e.getStackTraceString());
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, 500);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
     * @ Method : doSimulation
     * @ Description : 부품 가격 정보 조회
     *  
     */
    @AuraEnabled
    public static Map<String,Object> doSimulation(List<String> partCodeList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();

        try {
            String agencyId = currentUser.getAgencyId();

            DN_SimulationManager simulator = new DN_SimulationManager(
                DN_SimulationManager.Type.QUOTE
                , partCodeList
                ,agencyId
            );
            // result.put('partDetailsMap' ,simulator.simulation());
            result.put('partDetailsMap' ,simulator.simulation(currentUser, null));
            
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug(e.getStackTraceString());
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, 500);
           
        }
        result.put('status', resultStatus);
        return result;
    }

    
    /*
     * @ class : Quote
     * @ Description : Quote Class
     *  
     */
    public class Quote {
        @AuraEnabled public String id                   {get; set;}
        @AuraEnabled public String seq                  {get; set;}
        @AuraEnabled public String salesOrganization    {get; set;}
        @AuraEnabled public String distributionChannel  {get; set;}
        @AuraEnabled public String division             {get; set;}
        @AuraEnabled public String dealer               {get; set;}
        @AuraEnabled public String dealerName           {get; set;} //Dealer__r.Name
        @AuraEnabled public String customerCode         {get; set;} //일반고객일 경우만 값이 존재 (9999999999)
        @AuraEnabled public String customer             {get; set;} //DealerCustomer__c
        @AuraEnabled public String customerName         {get; set;} //DealerCustomer__r.Name
        @AuraEnabled public String machineName          {get; set;}
        @AuraEnabled public String equipment            {get; set;}
        @AuraEnabled public String description          {get; set;}
        @AuraEnabled public Date   publishDate          {get; set;}
        @AuraEnabled public String address              {get; set;}
        @AuraEnabled public String phone                {get; set;}
        @AuraEnabled public String fax                  {get; set;}
        @AuraEnabled public String postalCode           {get; set;}
        @AuraEnabled public List<QuoteItem> itemList    {
            get {
                if(itemList == null) itemList = new List<QuoteItem>();
                return itemList;
            }
            set;
        }
        public Quote(){}
        public Quote(String recordId){
            DealerQuote__c quoteSObject = [
            SELECT 
                Id
                ,Name
                ,FM_PublishDate__c
                ,SalesOrganization__c
                ,DistributionChannel__c
                ,Division__c
                ,Dealer__c
                ,Dealer__r.Name
                ,CustomerCode__c
                ,Customer__c
                ,Customer__r.Name
                ,FM_CustomerName__c
                ,MachineName__c
                ,Equipment__c
                ,Description__c
                , (
                    SELECT
                        Quote__c
                        , ItemNumber__c
                        , Part__c
                        , Part__r.Name
                        , Part__r.FM_MaterialDetails__c
                        , ReplacingPart__c
                        , ReplacingPart__r.Name
                        , ReplacingPart__r.FM_MaterialDetails__c
                        , FM_PartName__c
                        , Quantity__c
                        , FM_Unit__c
                        , CustomerPrice__c
                        , DiscountPrice__c
                        , DiscountRate__c
                        , FM_DiscountAmount__c
                    FROM DealerQuoteItem__r
                )
            FROM DealerQuote__c WHERE Id = :recordId LIMIT 1];
            this.initialize(quoteSObject);

            for(DealerQuoteItem__c quoteItemSObject : quoteSObject.DealerQuoteItem__r) {
                itemList.add(new QuoteItem(quoteItemSObject));
            }
        }
        public Quote(DealerQuote__c quoteSObject){
            this.initialize(quoteSObject);
        }

        /*
        * @ Method : initialize
        * @ Description : Quote 정보 Quote클래스에 주입
        *  
        */
        private void initialize(DealerQuote__c quoteSObject) {
            this.id                  = quoteSObject.Id;
            this.salesOrganization   = quoteSObject.SalesOrganization__c;
            this.distributionChannel = quoteSObject.DistributionChannel__c;
            this.division            = quoteSObject.Division__c;
            this.dealer              = quoteSObject.Dealer__c;
            this.dealerName          = quoteSObject.Dealer__r.Name;
            this.customerCode        = quoteSObject.CustomerCode__c;
            this.customer            = quoteSObject.Customer__c;
            this.customerName        = quoteSObject.FM_CustomerName__c;
            this.machineName         = quoteSObject.MachineName__c;
            this.equipment           = quoteSObject.Equipment__c;
            this.description         = quoteSObject.Description__c;
            this.publishDate         = quoteSObject.FM_PublishDate__c;
            this.seq                 = quoteSObject.Name;
        }

        /*
        * @ Method : convertToSObject
        * @ Description : 쿼트 오브젝트에 현재 유저정보 등 데이터 주입
        *  
        */
        public DealerQuote__c convertToSObject() {
            DealerQuote__c quoteSObject = new DealerQuote__c(
                SalesOrganization__c = currentUser.getSalesOranization(),
                DistributionChannel__c = currentUser.getDistributionChannel(),
                Division__c = currentUser.getDivision(),
                Dealer__c = currentUser.getAgencyId(),
                CustomerCode__c = customerCode,
                MachineName__c  = machineName,
                Equipment__c = equipment,
                Customer__c = customer,
                Description__c = description
            );
            return quoteSObject;
        }

    }

    /*
    * @ Class : QuoteItem
    * @ Description : QuoteItem Class
    *  
    */
    public class QuoteItem {
        @AuraEnabled public String quoteId              {get; set;} //견적Id
        @AuraEnabled public String itemSeq              {get; set;}
        @AuraEnabled public String part                 {get; set;}
        @AuraEnabled public String partName             {get; set;}
        @AuraEnabled public String partDetails          {get; set;}
        @AuraEnabled public String replacingPart        {get; set;}
        @AuraEnabled public String replacingPartName    {get; set;}
        @AuraEnabled public String replacingPartDetails {get; set;}
        @AuraEnabled public String unit                 {get; set;}
        @AuraEnabled public Decimal quantity            {get; set;}
        @AuraEnabled public Decimal customerPrice       {get; set;} //Decimal?
        @AuraEnabled public Decimal discountPrice       {get; set;} //Decimal?
        @AuraEnabled public Decimal discountAmount      {get; set;} //Decimal?
        @AuraEnabled public Decimal discountRate        {get; set;}
        public QuoteItem() {}
        public QuoteItem(DealerQuoteItem__c quoteItemSObject) {
            this.quoteId                = quoteItemSObject.Quote__c;
            this.itemSeq                = quoteItemSObject.ItemNumber__c;
            this.part                   = quoteItemSObject.Part__c;
            this.partName               = quoteItemSObject.Part__r.Name;
            this.partDetails            = quoteItemSObject.Part__r.FM_MaterialDetails__c;
            this.replacingPart          = quoteItemSObject.ReplacingPart__c;
            this.replacingPartName      = quoteItemSObject.ReplacingPart__r.Name;
            this.replacingPartDetails   = quoteItemSObject.ReplacingPart__r.FM_MaterialDetails__c;
            this.quantity               = quoteItemSObject.Quantity__c;
            this.unit                   = quoteItemSObject.FM_Unit__c;
            this.customerPrice          = quoteItemSObject.CustomerPrice__c;
            this.discountPrice          = quoteItemSObject.DiscountPrice__c;
            this.discountAmount         = quoteItemSObject.FM_DiscountAmount__c;
            this.discountRate           = quoteItemSObject.DiscountRate__c;
        }

        /*
        * @ Method : convertToSObject
        * @ Description : QuoteItem에 데이터 주입
        *  
        */
        public DealerQuoteItem__c convertToSObject() {
            DealerQuoteItem__c quoteItemSObject = new DealerQuoteItem__c(
                ItemNumber__c = itemSeq,
                Quantity__c = quantity,
                CustomerPrice__c = customerPrice,
                DiscountPrice__c = discountPrice,
                DiscountRate__c = discountRate
            );

            if(String.isNotBlank(part) && part.length() == 18) quoteItemSObject.Part__c = part;
            if(String.isNotBlank(replacingPart) && replacingPart.length() == 18) quoteItemSObject.ReplacingPart__c = replacingPart;
            

            return quoteItemSObject;
        }

        public DealerQuoteItem__c convertToSObject(String quoteId) {
            DealerQuoteItem__c quoteItem = convertToSObject();
            quoteItem.Quote__c = quoteId;
            return quoteItem;
        }
    }

    /*
    * @ Class : StatusCode
    * @ Description : 상태값 정보 Class
    *  
    */
    public enum StatusCode { SUCCESS, ERROR }
    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}
        
        /*
        * @ StatusInfo : 생성자
        */
        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        /*
        * @ setCode : 상태 코드 정보
        */
        public void setCode(Integer code) {
            this.code = code;
        }

        /*
        * @ Description : 메세지 정보
        */
        public void setMessage(String msg) {
            this.msg = msg;
        }

        /*
        * @ setError : 에러인 경우 메세지 및 상태 코드
        */
        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }
}