/** 
 * @Class : DN_AgencyCustomerListModalController
 * 
 * @Test: DN_AgencyCustomerListModalCon_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 23. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-23 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_AgencyCustomerListModalController {

    /*
     * @ Method : currentUser
     * @ Description : DN_UserDetails 대리점에서서 사용하는 현재 유저정보 / 어드민인 경우 DealerPortalUserSetting__mdt에 설정된 정보
     */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /*
     * @ Method : getAgencyList
     * @ Description : 검색 값 기준으로 고객사 또는 판매처 목록을 조회회
     * @ Parameter : targetObject - ( 오브젝트 API명), SearchParams - 검색 시 조회조건
     */
    @AuraEnabled
    public static Map<String,Object> getAgencyList(String targetObject, SearchParams searchParams){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            List<AgencyCustomer> agencyCustomerList = new List<AgencyCustomer>();
            agencyCustomerList = getAgencyListDealerCustomerAll(searchParams);

            result.put('agencyCustomerList', agencyCustomerList);
            result.put('agencyShipToList', getCustomerShipTos(searchParams.customerCode, searchParams.customerName));
        } catch (Exception e) {
            resultStatus.setError('Exception : ' + e.getMessage(), null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
     * @ Method : getAgencyListDealerCustomerAll
     * @ Description : SearchParams.Type에 따라 고객사 정보 조회
     * @ Parameter : searchParams - 검색 시 조회 조건
     */
    private static List<AgencyCustomer> getAgencyListDealerCustomerAll(SearchParams searchParams) {
        System.debug(searchParams.type  + ' ::: searchParams.type');
        List<AgencyCustomer> agencyList = new List<AgencyCustomer>();
        String query ='';
        List<String> searchKeyList = new List<String>();
        if('seller'.equals(searchParams.type)){
            Map<String, Account> customerCodeMap = new Map<String, Account>();
            query = ' SELECT Id, Name, CustomerCode__c, FM_Address__c '
                   +' FROM Account '
                   +' WHERE CustomerCode__c != null '
                   +' AND RecordType.DeveloperName =\'Dealer\' '//IN (\'TradeCustomer\' , \'Dealer\') '
                   +' AND SalesOrganization__c = \'1800\' '
                   +' AND DistributionChannel__c = \'10\' '
                   +' AND Division__c  = \'40\' '
                   +' AND SalesDistrict__c = \'A1KR\' '; //distinct => SalesDistrict__c
            if(String.isNotBlank(searchParams.customerName)) searchKeyList.add(' Name LIKE \'%' + searchParams.customerName + '%\'');
            if(String.isNotBlank(searchParams.customerCode)) searchKeyList.add(' CustomerCode__c LIKE \'%' + searchParams.customerCode + '%\' ');
            if(searchKeyList.size() > 0) {
                query += ' AND ' + '(' + String.join(searchKeyList, ' OR ') + ' )';
            } else {
                query += ' LIMIT 200';  
            }
            System.debug('query :: '+query);
            customerCodeMap = DN_WithoutSharingDealerPortal.withoutSearchSeller(query);
            for(String accCusCode : customerCodeMap.keySet()) {
                Account acc = customerCodeMap.get(accCusCode);
                AgencyCustomer agency = new AgencyCustomer();
                agency.id               = acc.Id;
                agency.customerCode     = acc.CustomerCode__c;
                agency.customerName     = acc.Name;
                agency.customerAddress  = acc.FM_Address__c;
                agencyList.add(agency);
            }

        } else {
            query = ' SELECT Id, Name, FM_Address__c, Representative__c, CustomerCode__c, DiscountRate__c, ShippingType__c FROM DealerCustomer__c '
                            + ' WHERE IsActive__c = true';
                            // AND SalesOrganization__c = 
                        // AND DistributionChannel__c = 
                        // AND Division__c =
                        // AND 
            if('customer'.equals(searchParams.type)) query += ' AND SourceAccount__c = null ';
            else if('dealer'.equals(searchParams.type)) {
                query += ' AND IsDealer__c = true ';
                if(String.isNotBlank(currentUser.getAgencyId())) query += ' AND SourceAccount__c != \''+ currentUser.getAgencyId() +'\'';
                
                if(!Test.isRunningTest()) {
                    query += ' AND SourceAccount__c IN ( SELECT AccountId FROM User where UserType = \'PowerPartner\'  and Profile.Name = \'DNS CS Parts_Partner\' AND IsActive = true ) ';
                }
            }
            if('All'.equals(searchParams.type)) {
                query += ' AND SourceAccount__c != \''+ currentUser.getAgencyId() +'\'';
                //query += ' AND Dealer__c=\'' +currentUser.getAgencyId()+ '\'';
            }
            //List<String> searchKeyList = new List<String>();
            if(String.isNotBlank(searchParams.customerName)) searchKeyList.add(' Name LIKE \'%' + searchParams.customerName + '%\'');
            if(String.isNotBlank(searchParams.customerCode)) searchKeyList.add(' CustomerCode__c LIKE \'%' + searchParams.customerCode + '%\' ');
            
            Boolean isLimit = false;
            if(searchKeyList.size() > 0) {
                query += ' AND ' + '(' + String.join(searchKeyList, ' OR ') + ' )';
            }
            else {
                isLimit = true;
                
            }
            query += ' ORDER BY CustomerCode__c ';
            query += ' LIMIT 200';
            System.debug('query :: '+query);
            for(DealerCustomer__c dealerCustomer : (List<DealerCustomer__c>) Database.query(query)) {
                agencyList.add(new AgencyCustomer(dealerCustomer));
            }
        } 

        return agencyList;
    }

    /*
     * @ Method : getCustomerShipTos
     * @ Description : 고객의 배송처 정보 조회 (오브젝트 : DealerCustomerShipTo__c)
     * @ Parameter : customerCode - 고객 코드, customerName - 고객사명
     */
    public static List<AgencyCustomerShipTo> getCustomerShipTos(String customerCode, String customerName) {
        List<AgencyCustomerShipTo> customerShipToList = new List<AgencyCustomerShipTo>();

        String query =' SELECT '
                     +'     Id '
                     +'     , Customer__c '
                     +'     , Customer__r.CustomerCode__c '
                     +'     , Customer__r.Name '
                     +'     , Customer__r.FM_PartsManagerName__c '
                     +'     , Customer__r.FM_PartsManagerPhone__c '
                     +'     , sggNm__c '
                     +'     , FM_Address__c '
                     +'     , Address__Street__s '
                     +'     , Address__City__s '
                     +'     , Address__PostalCode__s '
                     +'     , Address__StateCode__s '
                     +'     , Address__CountryCode__s '
                     +'     , Address__c '
                     +'     , DetailInfo__c '
                     +'     , RoadAddr__c  '
                     +' FROM DealerCustomerShipTo__c WHERE Id != null AND Customer__r.IsActive__c = true ';
        if(String.isNotBlank(customerName)) query += ' AND Customer__r.Name like \'%'+customerName+'%\'';
        if(String.isNotBlank(customerCode)) query += ' AND Customer__r.CustomerCode__c like \'%'+customerCode+'%\'';
        String queryOrderBy = ' ORDER BY Customer__r.CustomerCode__c ,Customer__r.Name ,CreatedDate ';
        System.debug('query ');
        System.debug(query + queryOrderBy);
        for(DealerCustomerShipTo__c shipTo : Database.query(query + queryOrderBy + ' LIMIT 200')) {
            customerShipToList.add(new AgencyCustomerShipTo(shipTo));
        }
        return customerShipToList;
    }

    /*
     * @ Class : SearchParams - customerName(고객사명), customerCode(고객코드),
     *                  Type : Seller - 판매처
     *                  Type : Customer - 고객사
     *                  Type : All - 전체체
     */
    public class SearchParams {
        @AuraEnabled public String customerName {get;set;}
        @AuraEnabled public String customerCode {get;set;}
        @AuraEnabled public String type         {get;set;}
    }

    /*
     * @ Class : AgencyCustomer - 고객사 정보 클래스
     *                  targetObject - 오브젝트명
     *                  id - Record Id
     *                  customerCode - 고객사 또는 판매처 코드
     *                  customerName - 고객사 또는 판매처명
     *                  representativeName - 고객사 또는 판매처 대표자명
     *                  customerAddress - 주소 정보
     *                  postalCode - 우편번호
     *                  shippingType - 배송타입
     *                  discountRate - 할인율
     */
    public class AgencyCustomer {
        @AuraEnabled public String targetObject         {get; set;}
        @AuraEnabled public String id                   {get; set;}
        @AuraEnabled public String customerCode         {get; set;}
        @AuraEnabled public String customerName         {get; set;}
        @AuraEnabled public String representativeName   {get; set;}
        @AuraEnabled public String customerAddress      {get; set;} //Full 주소
        @AuraEnabled public String postalCode           {get; set;} //우편번호
        @AuraEnabled public String shippingType         {get; set;}
        @AuraEnabled public Decimal discountRate        {get; set;} //할인율

        public AgencyCustomer() {}
        public AgencyCustomer(DealerCustomer__c dealerCustomer) {
            targetObject = 'DealerCustomer__c';
            id = dealerCustomer.Id;
            customerCode = dealerCustomer.CustomerCode__c;
            customerName = dealerCustomer.Name;
            representativeName = dealerCustomer.Representative__c;
            customerAddress = dealerCustomer.FM_Address__c;
            discountRate = dealerCustomer.DiscountRate__c;
            shippingType = dealerCustomer.getPopulatedFieldsAsMap().containsKey('ShippingType__c') ? dealerCustomer.ShippingType__c: '';
        }
    }

    /*
     * @ Class : AgencyCustomerShipTo - 배송처 정보 클래스
     *                  targetObject - 오브젝트명
     *                  id - Record Id
     *                  customerId - 고객사 또는 판매처 Id
     *                  customerCode - 고객사 또는 판매처코드드
     *                  customerName - 고객사 또는 판매처명
     *                  customerAddress - 주소 정보
     *                  postalCode - 우편번호
     *                  city - 시군구 
     *                  manager - 부품 담당자
     *                  customerPhone - 담당자 핸드폰 번호
     */
    public class AgencyCustomerShipTo {
        @AuraEnabled public String id           {get; set;}
        @AuraEnabled public String customerId           {get; set;}
        @AuraEnabled public String customerCode         {get; set;}
        @AuraEnabled public String customerName         {get; set;}
        @AuraEnabled public String customerAddress      {get; set;} //Full Address
        @AuraEnabled public String postalCode           {get; set;} //우편번호
        @AuraEnabled public String city                 {get; set;} //CITY1 기본주소
        @AuraEnabled public String street               {get; set;} //STREET 상세주소
        @AuraEnabled public String manager              {get; set;}
        @AuraEnabled public String customerPhone        {get; set;}
        public AgencyCustomerShipTo(){}
        public AgencyCustomerShipTo(DealerCustomerShipTo__c shipTo){
            id              = shipTo.id;
            customerId      = shipTo.Customer__c;
            customerCode    = shipTo.Customer__r.CustomerCode__c;
            customerName    = shipTo.Customer__r.Name;
            customerAddress = shipTo.FM_Address__c;
            postalCode      = shipTo.Address__PostalCode__s;
            street          = shipTo.DetailInfo__c;
            city            = shipTo.RoadAddr__c;
            manager = shipTo.Customer__r.FM_PartsManagerName__c;      
            customerPhone = shipTo.Customer__r.FM_PartsManagerPhone__c;
        }
    }
   
    public enum StatusCode { SUCCESS, ERROR }

    /*
     * @ Class : StatusInfo - 
     *                  Type : Seller - 판매처
     *                  Type : Customer - 고객사
     *                  Type : All - 전체
     */
    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        public void setCode(Integer code) {
            this.code = code;
        }

        public void setMessage(String msg) {
            this.msg = msg;
        }

        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }

}