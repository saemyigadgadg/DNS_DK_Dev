/**
 * @author            : iltae.seo
 * @last modified on  : 2024-12-05
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-05   iltae.seo     Initial Version
**/
public without sharing class DN_DealerPortalShipToListController {
    /**
    * @description 현재 유저 정보
    * @author iltae.seo | 2024-12-05   
    **/
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
    * @description DealerCustomerShipTo 목록 반환
    * @author iltae.seo | 2024-12-05 
    * @param String recordId  
    **/
    @AuraEnabled
    public static List<Address> getShipToList(String recordId){
        try {
            System.debug(recordId + ' < ===recordId');
            List<Address> addressList = new List<Address>();
            List<DealerCustomerShipTo__c> shipList = [select Id, 
                                                            sggNm__c, Customer__c, Address__Street__s, Address__City__s,IsDealer__c,DealerCode__c,Customer__r.Dealer__r.CustomerCode__c,
                                                            Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, 
                                                            Address__Latitude__s, Address__Longitude__s, Address__GeocodeAccuracy__s,RoadAddr__c, 
                                                            Address__c, SourceSystem__c,DetailInfo__c from DealerCustomerShipTo__c  
                                                            where Customer__c=:recordId 
                                                            AND Customer__c !=null ORDER BY IsDealer__c Desc
                                                    ];
            String delaerCode= shipList.size() > 0 ? shipList[0].Customer__r.Dealer__r.CustomerCode__c : currentUser.getAgencyCustomerCode();

            for(DealerCustomerShipTo__c dealer: shipList) {
                if(dealer.IsDealer__c) {
                    addressList.add(new Address(dealer));
                } else {
                	if(String.isNotBlank(dealer.DealerCode__c)) {
                    	if(dealer.DealerCode__c ==delaerCode) {
                        	addressList.add(new Address(dealer));
                    	}
                	} else {
                    	if(dealer.Customer__r.Dealer__r.CustomerCode__c ==delaerCode) {
                        	addressList.add(new Address(dealer));
                    	}
                	}    
                }
                
                
            }
            System.debug(addressList + ':::addressList');
            return addressList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description 주소 업데이트
    * @author iltae.seo | 2024-12-05 
    * @param String recordId, List<Map<String,Object>> addressList, List<String> deleted
    **/
    @AuraEnabled
    public static void addressUpsert(String recordId, List<Map<String,Object>> addressList, List<String> deleted){
        try {
            System.debug(addressList+ ' <---addressList');
            List<DealerCustomerShipTo__c> shipToList = new List<DealerCustomerShipTo__c>();
            for(Map<String,Object> obj : addressList) {
                DealerCustomerShipTo__c shipto  = new DealerCustomerShipTo__c();
                if( (String)obj.get('id') !='') shipto.Id    = (String) obj.get('id');
                shipto.Address__Street__s       = (String) obj.get('roadAddr') + '\n'+ (String) obj.get('detailInfo');
                shipto.Address__PostalCode__s   = (String) obj.get('postalCode');
                shipto.Address__City__s         = (String) obj.get('city');
                shipto.Address__CountryCode__s  = 'KR';
                shipto.Customer__c              = recordId;
                shipto.DetailInfo__c            = (String) obj.get('detailInfo');
                shipto.RoadAddr__c              = (String) obj.get('roadAddr');
                shipToList.add(shipto);
            }
            upsert shipToList;
            if(deleted.size() >0) {
                List<DealerCustomerShipTo__c> deleteList = [select Id from DealerCustomerShipTo__c where Id IN:deleted];
                delete deleteList;
            }
           
        } catch (Exception e) {
            System.debug(e.getMessage() + ' e.getMesasgae');
            System.debug(e.getLineNumber() + 'e.getLineNumber');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 주소 업데이트
    * @author iltae.seo | 2024-12-05 
    * @param String recordId, List<Map<String,Object>> addressList, List<String> deleted
    **/
    public class Address {
        @AuraEnabled public string id {get;set;}
        @AuraEnabled public string street {get;set;}
        @AuraEnabled public string postalCode {get;set;}
        @AuraEnabled public string city {get;set;}
        @AuraEnabled public string detailInfo {get;set;}
        @AuraEnabled public string sggNm {get;set;}
        @AuraEnabled public string roadAddr {get;set;} 
        @AuraEnabled public Boolean isDealer {get;set;} 
        public Address(DealerCustomerShipTo__c shipTo) {
            this.id = shipTo.Id;
            this.street = shipTo.Address__Street__s;
            this.postalCode = shipTo.Address__PostalCode__s;
            this.city = shipTo.Address__City__s;
            this.detailInfo = shipTo.DetailInfo__c;
            this.sggNm = shipTo.sggNm__c;
            this.roadAddr = shipTo.RoadAddr__c;
            this.isDealer = shipTo.IsDealer__c;
        }
        
    }
    
}