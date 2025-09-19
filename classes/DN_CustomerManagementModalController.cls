/**
 * @author            : iltae.seo
 * @last modified on  : 2024-12-06
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-06   iltae.seo     Initial Version
**/
public with sharing class DN_CustomerManagementModalController {
    
    /**
     * @Description
     * 	- 현재 URL이 커뮤니티 사이트 인지 확인
     * @author iltae.seo | 12-13-2024
     * @return 
     *  - recordId	    : List<String>
    **/ 
    @AuraEnabled
    public static List<String> getSiteUrlList(){
        try {
            set<String> ids = new set<String>();
            List<String> siteUrlList = new List<String>();
            List<Site> siteList = [select Id, Name,SiteType from Site where Status ='Active' ];
            for(Site si :siteList) {
                ids.add(si.Id);
            }
            List<SiteDetail> siteDetailList = [select Id, DurableId, IsRegistrationEnabled, SecureUrl from SiteDetail where DurableId IN : ids];
            for(SiteDetail detail : siteDetailList) {
                siteUrlList.add(detail.SecureUrl);
            }
            return siteUrlList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Init
    @AuraEnabled
    public static Map<String,List<sObject>> getInit(String recordId){
        try {
            Map<String,List<sObject>> returnMap = new Map<String,List<sObject>>();
            // recordId가 null이 아니면 수정모드
            if(recordId !=null) {
                List<DealerCustomer__c> dealerCustomer = [select Id,Name,Address__Street__s,Address__c,PartManagerName__c,PartsManagerContact__c,PartsManagerEmail__c,PartsManagerFax__c,PartsManagerPhone__c   from DealerCustomer__c where Id=:recordId];
                //List<Contact> cont = [select Id, LastName,MobilePhone,Phone,Email,Fax from Contact where Id=:dealerCustomer[0].PartsManager__c];
                List<DealerCustomerShipTo__c> shipList = [select Id, 
                                                            sggNm__c, Customer__c, Address__Street__s, Address__City__s, 
                                                            Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, 
                                                            Address__Latitude__s, Address__Longitude__s, Address__GeocodeAccuracy__s,RoadAddr__c, 
                                                            Address__c, SourceSystem__c,DetailInfo__c from DealerCustomerShipTo__c  
                                                            where Customer__c=:recordId AND Customer__c !=null];
                if(shipList.size() > 0) returnMap.put('shipList',shipList);

                if(dealerCustomer.size() > 0) returnMap.put('delaer', dealerCustomer);
                //if(cont.size() > 0) returnMap.put('contact', cont);
            }
            
            // 현재 테스트 유저에 Contact정보가 없어서 잠시 픽스 사용
            List<User> currentUser = [select Id, Name,ContactId ,Contact.AccountId,SalesOrganization__c,DistributionChannel__c,Division__c,UserType
                                        from User where Id=:UserInfo.getUserId()]; //UserInfo.getUserId();
            returnMap.put('currentUser', currentUser);
            return returnMap;
        } catch (Exception e) {
            throw new DN_CustomerManagementModalControllerException(e.getMessage());
            
        }
    }
    
    // 배송지 설정
    @AuraEnabled
    public static DealerCustomer__c saveRecord(String recordId, DealerCustomer__c customer,List<DealerCustomerShipTo__c> shipToList, List<String> deleted){
        try {            
            // 고객 벨리데이션 확인
            Map<String,Boolean> valMap = setRequiredCheck(customer,shipToList);    
            for(String fields : valMap.keySet()) {
                System.debug(fields + ' < ==fields');
                if(valMap.get(fields)) {
                    throw new DN_CustomerManagementModalControllerException(fields + ' 필수값이 누락되었습니다.');
                }
            }
            if(recordId !=null) {
                customer.Id = recordId;
                update customer;
            } else {
                insert customer;
            }
            System.debug(customer + ' <> ===customer');
            
            // 배송처
            for(DealerCustomerShipTo__c ship : shipToList) {
                ship.Customer__c = customer.Id;
            }
            upsert shipToList;
            System.debug(shipToList + ' <M ===shipToList');
            //배송처 삭제할 건 있으면 삭제
            if(deleted.size() >0) {
                List<DealerCustomerShipTo__c> deleteList = [select Id from DealerCustomerShipTo__c where Id IN:deleted];
                delete deleteList;
            }
            return customer;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            throw new DN_CustomerManagementModalControllerException(e.getMessage());
        }
    }
    

    // 고객 벨리데이션
    public static Map<String,Boolean> setRequiredCheck(DealerCustomer__c customer,List<DealerCustomerShipTo__c> shipToList) {
        
        Map<String,Boolean> returnMap = new Map<String,Boolean>();
        if(String.isBlank(customer.Name)) {
            returnMap.put('고객사명(한글)', true);
            return returnMap; 
        } 
        if(String.isBlank(customer.Address__Street__s)) {
            returnMap.put('주소', true);
            return returnMap; 
        }
        if(String.isBlank(customer.PartManagerName__c)) {
            returnMap.put('부품 담당자', true);
            return returnMap; 
        }
        for(DealerCustomerShipTo__c shipTo: shipToList) {
            if(String.isBlank(shipTo.Address__Street__s)) {
                returnMap.put('배송주소', true);
                return returnMap;
            }
        }

        return returnMap;
    }
    
    // /**어드민 기능 추후 사용할 수 있음 */
    // // 고객사 코드로 검색
    // @AuraEnabled
    // public static List<DealerCustomer__c> getCustomer(String customerCode){
    //     try {
    //         String dealerCustomerId ='';
    //         List<DealerCustomer__c> dealerCustomer = [select Id, Name,Address__c,SalesOrganization__c,AccountNameEnglish__c,
    //                                                     BusinessNumber__c,Representative__c,TypeOfIndustry__c,Phone__c,//PartsManager__c,
    //                                                     Etc__c,Address__Street__s,Address__PostalCode__s,Address__City__s,Address__CountryCode__s,
    //                                                     IsDealer__c,CRMCustomerCode__c from DealerCustomer__c where SourceAccount__c =:customerCode AND SourceAccount__c !=null limit 1];
            
    //         return dealerCustomer;
    //     } catch (Exception e) {
    //         throw new DN_CustomerManagementModalControllerException(e.getMessage());
    //     }
    // }

    @AuraEnabled
    public static Boolean getDealerCustomer(String recordId){
        try {
            Boolean isCheck = DN_DealerPortalSessionController.getDealerCustomer(recordId);
            System.debug(isCheck + ' ::: isCheck');
            return isCheck;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DN_CustomerManagementModalControllerException extends Exception {}
}