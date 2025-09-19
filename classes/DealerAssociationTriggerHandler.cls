/**
 * @description       : DNS_CustomerDealerAssociation__c Trigger Handler
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-24-2024   Hanyeong Choi   Initial Version
 * 1.0   11-18-2024   Yuhyun Park     전체 주석 처리 (Sharing Setting으로 대체) & 추가 로직(DealerAssociation record 생성 시, 해당 Cusutomer 필드에 Delaer 추가)
 * 1.0   11-28-2024   Yuhyun Park     다시 전체 Manual Sharing으로 전환
**/


public with sharing class DealerAssociationTriggerHandler extends TriggerHandler {

    private static final Id dealerConRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();


    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){

        if(isExecuting){
            System.debug('CustomerDealerAssociation AFTER_INSERT TRIGGER Start');

            List<DNS_CustomerDealerAssociation__c> cdaList = (List<DNS_CustomerDealerAssociation__c>) news;
            Set<Id> dealerAccIds            = new Set<Id>();
            Set<Id> customerAccIds          = new Set<Id>();
            Map<Id, List<Id>> dealerCustomerMap = new Map<Id, List<Id>>();
            
            for(DNS_CustomerDealerAssociation__c cda : cdaList) {
                if(cda.Customer__c != null && cda.Dealer__c != null){
                    dealerAccIds.add(cda.Dealer__c);
                    customerAccIds.add(cda.Customer__c);

                    if(!dealerCustomerMap.containsKey(cda.Dealer__c)){
                        dealerCustomerMap.put(cda.Dealer__c, new List<Id>());
                    }
                    dealerCustomerMap.get(cda.Dealer__c).add(cda.Customer__c);

                }
            }

            if(!dealerAccIds.isEmpty() && !dealerCustomerMap.isEmpty()){
                grantAccessToCustomer(dealerAccIds, dealerCustomerMap);
            }
            System.debug('CustomerDealerAssociation AFTER_INSERT TRIGGER End');
        }
    }

    public override void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap) {

        if(isExecuting){
            System.debug('CustomerDealerAssociation AFTER_DELETE TRIGGER Start');

            List<DNS_CustomerDealerAssociation__c> cdaList = (List<DNS_CustomerDealerAssociation__c>) dels;
            Set<Id> dealerAccIds            = new Set<Id>();
            Set<Id> customerAccIds          = new Set<Id>();

            for(DNS_CustomerDealerAssociation__c cda : cdaList) {
                if(cda.Customer__c != null && cda.Dealer__c != null){
                    dealerAccIds.add(cda.Dealer__c);
                    customerAccIds.add(cda.Customer__c);
                }
            }

            if(!dealerAccIds.isEmpty() && !customerAccIds.isEmpty()){
                deleteAccessToCustomer(dealerAccIds, customerAccIds);
            }
            if(!customerAccIds.isEmpty()) updateSalesOffice(customerAccIds);
            System.debug('CustomerDealerAssociation AFTER_DELETE TRIGGER End');
        }
    }


    /**
     * @Description
     * 	- DealerAssociation record 생성 시, 대리점(Account) 소속의 모든 딜러(Contact/User)에게 Customer(Account) Read 권한 부여 
     *  - 2025-01-03 : Read 권한에서 Edit 권한으로 변경
     *  - 2025-01-15 : AccountShare 생성에서 AccountContactRelation 생성 + Sharing Set(Portal)으로 변경
     * @author Yuhyun Park | 11-28-2024
     * 
    **/   
    private static void grantAccessToCustomer(Set<Id> dealerAccIds, Map<Id, List<Id>> dealerCustomerMap) {
        
        List<AccountContactRelation> relationToInsert = new List<AccountContactRelation>();

        List<Contact> dealerConList = [
            SELECT  Id, AccountId
            FROM    Contact
            WHERE   AccountId IN :dealerAccIds
            AND     RecordTypeId = :dealerConRT
        ];

        System.debug('dealerConList :: ' + dealerConList);


        if(!dealerConList.isEmpty()){
            for(Contact dealerCon : dealerConList){
                if(dealerCustomerMap.containsKey(dealerCon.AccountId)){
                    for(Id customerId : dealerCustomerMap.get(dealerCon.AccountId)){
                        AccountContactRelation newRelation = new AccountContactRelation();
                        newRelation.AccountId = customerId;
                        newRelation.ContactId = dealerCon.Id;
                        relationToInsert.add(newRelation);
                    }
                }
            }

            if(!relationToInsert.isEmpty()){
                System.debug('relationToInsert ::' + relationToInsert);
                insert relationToInsert;
            }
        }
        
        return;
    }


    /**
     * @Description
     * 	- DealerAssociation record 삭제 시, 대리점(Account) 소속의 모든 딜러(Contact/User)에게 Customer(Account) Read 권한 회수
     *  - 2025-01-03 Read 권한에서 Edit 권한으로 변경
     *  - 2025-01-15 : AccountShare 삭제에서 AccountContactRelation 삭제 + Sharing Set(Portal)으로 변경
     * @author Yuhyun Park | 11-28-2024
     * 
    **/
    private static void deleteAccessToCustomer(Set<Id> dealerAccIds, Set<Id> customerAccIds) {
        Set<Id> dealerConIds = new Set<Id>();
    
        // Dealer와 연결된 Contact 조회
        List<Contact> dealerContactList = [
            SELECT  Id, AccountId 
            FROM    Contact 
            WHERE   AccountId IN :dealerAccIds
        ];

        System.debug('dealerContactList :: ' + dealerContactList);
    
        if(!dealerContactList.isEmpty()){
            for (Contact con : dealerContactList) {
                dealerConIds.add(con.Id);
            }
        }

        System.debug('dealerConIds :: ' + dealerConIds);

        if(!dealerConIds.isEmpty()){
            List<AccountContactRelation> relationList = [
                SELECT  Id, AccountId, ContactId
                FROM    AccountContactRelation
                WHERE   ContactId IN :dealerConIds
                AND     AccountId IN :customerAccIds
            ];
        
            System.debug('AccountContactRelation records to delete: ' + relationList);
        
            if (!relationList.isEmpty()) {
                delete relationList;
            }
        }
        return;
    }


    //  Customer(Account) 필드 변경 시, 연관된 Dealer(User) 필드 업데이트
    private static void updateSalesOffice(Set<Id> customerAccIds) {
        List<Account> accUpdateList = new List<Account>();
        List<SalesAreaData__c> sadUpdateList = new List<SalesAreaData__c>();
        List<DNS_CustomerDealerAssociation__c> cdaList = [
            SELECT  Id
                    , Dealer__r.SalesOffice__c
                    , Customer__c 
            FROM DNS_CustomerDealerAssociation__c 
            WHERE Customer__c IN :customerAccIds
        ];
        
        if(!cdaList.isEmpty()) {

            if(cdaList.size() == 1) {
                Set<Id> accIds = new Set<Id>();
                Map<String, String> cdaMap = new Map<String, String>();
                for(DNS_CustomerDealerAssociation__c cda : cdaList) {
                    accIds.add(cda.Customer__c);
                    cdaMap.put(cda.Customer__c, cda.Dealer__r.SalesOffice__c);
                }

                if(!accIds.isEmpty()) {
                    List<Account> accList = [
                        SELECT  Id
                                , SalesOffice__c 
                                , (
                                    SELECT SalesOffice__c, Account__c
                                    FROM SalesAreaData__r
                                    WHERE SalesOrganization__c = '1800'
                                )
                        FROM Account 
                        WHERE Id IN :cdaMap.keySet()
                    ];
                    System.debug('test01 - accList ::: ' + accList);

                    for(Account acc : accList) {
                        if(cdaMap.containsKey(acc.Id)) {
                            acc.SalesOffice__c = cdaMap.get(acc.Id);
                            accUpdateList.add(acc);
                        }
    
                        if(!acc.SalesAreaData__r.isEmpty()) {
                            for(SalesAreaData__c sad : acc.SalesAreaData__r) {
                                if(cdaMap.containsKey(sad.Account__c)) {
                                    sad.SalesOffice__c = cdaMap.get(acc.Id);
                                    sadUpdateList.add(sad);
                                }
                            }
                        }
                    }
                }
                if(!accUpdateList.isEmpty()) update accUpdateList;
                if(!sadUpdateList.isEmpty()) update sadUpdateList;
            }
        }
        return;
    }
    
}