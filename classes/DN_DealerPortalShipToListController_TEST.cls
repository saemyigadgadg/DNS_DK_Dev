@isTest
public with sharing class DN_DealerPortalShipToListController_TEST {
    static Account acc;
    static DealerCustomerShipTo__c shipTo;
    static DealerCustomer__c dealerCustomer;
    static {
        acc = TestDataFactoryForDealerPortal.dealer;
        insert acc;
        dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
        insert dealerCustomer;
        shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(dealerCustomer.Id);
        insert shipTo;
    }

    @IsTest
    static void test1(){
        Test.startTest();
            DN_DealerPortalShipToListController.getShipToList(dealerCustomer.Id);
            shipTo.IsDealer__c = true;
            update shipTo;
            DN_DealerPortalShipToListController.getShipToList(dealerCustomer.Id);
            
            List<Map<String,Object>> addressList = new List<Map<String,Object>>();
            Map<String,Object> addressMap = new Map<String,Object>();
            addressMap.put('id',shipTo.Id);
            addressMap.put('roadAddr','tset');
            addressMap.put('detailInfo','test');
            addressMap.put('city','대구광역시 달서구 이곡동 1336-8');
            addressMap.put('postalCode','51392');
            addressList.add(addressMap);
            List<String> deleted = new List<String>();
            deleted.add(shipTo.Id);
            DN_DealerPortalShipToListController.addressUpsert(dealerCustomer.Id,addressList,deleted);
        Test.stopTest();
    }

    @IsTest // catch!!
    static void test2(){
        try {
            Test.startTest();
            DN_DealerPortalShipToListController.getShipToList(dealerCustomer.Id);
            List<Map<String,Object>> addressList = new List<Map<String,Object>>();
            Map<String,Object> addressMap = new Map<String,Object>();
            addressMap.put('id',dealerCustomer.Id);
            addressMap.put('roadAddr','tset');
            addressMap.put('detailInfo','test');
            addressMap.put('city','대구광역시 달서구 이곡동 1336-8');
            addressMap.put('postalCode','51392');
            addressList.add(addressMap);
            List<String> deleted = new List<String>();
            deleted.add(shipTo.Id);
            DN_DealerPortalShipToListController.addressUpsert(dealerCustomer.Id,addressList,deleted);
            Test.stopTest();    
        } catch (Exception e) {
            
        } 
    }
    
}