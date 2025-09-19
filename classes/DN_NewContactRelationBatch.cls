/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - 대리점의 딜러(Contact) 신규 생성 시, 기존 대리점의 고객 접근(AccountContactRelation) 권한 부여
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-04-18   yuhyun.park@sbtglobal.com   Initial Version
**/
global class DN_NewContactRelationBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    private static final Id accDealerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    global String setDealerId;
    global DN_NewContactRelationBatch(String dealerId) {
		setDealerId = dealerId;
    }
    // 1) start: Association 레코드 자체를 QueryLocator로
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('setDealerId ::  ' + setDealerId );

        String query='SELECT Dealer__c, Customer__c ';
        	   query += 'FROM DNS_CustomerDealerAssociation__c ';
               query += 'WHERE Customer__r.IsErpDelete__c = false ';    
        
        if(setDealerId != '') {
             query += 'AND Dealer__c = \'' + setDealerId + '\'';
		}
        query += 'ORDER BY Customer__c';
              
        return Database.getQueryLocator(query);

    }

    // 2) execute: Association 단위로 scope를 받음
    global void execute(Database.BatchableContext bc, List<DNS_CustomerDealerAssociation__c> scope) {

        if (scope.isEmpty()) return;

        // 2-1) Dealer → Set<고객> 매핑
        // 딜러 한개기준으로 배치 돌리면 이 로직도 필요 없음
        Map<Id, Set<Id>> dealerToCustomers = new Map<Id, Set<Id>>();
        for (DNS_CustomerDealerAssociation__c a : scope) {
            if (!dealerToCustomers.containsKey(a.Dealer__c)) {
                dealerToCustomers.put(a.Dealer__c, new Set<Id>());
            }
            dealerToCustomers.get(a.Dealer__c).add(a.Customer__c);
        }

        // 2-2) 해당 딜러들의 Dealer(Contact) 조회
        // 딜러 한개기준으로 배치 돌리면 이 로직도 필요 없음
        Map<Id, List<Id>> dealerToContacts = new Map<Id, List<Id>>();
        for (Contact c : [
            SELECT Id, AccountId
              FROM Contact
             WHERE RecordTypeId = :conDealerRT
               AND AccountId IN :dealerToCustomers.keySet()
        ]) {
            if (!dealerToContacts.containsKey(c.AccountId)) {
                dealerToContacts.put(c.AccountId, new List<Id>());
            }
            dealerToContacts.get(c.AccountId).add(c.Id);
        }

        // 2-3) ACR 생성 리스트 축적
        List<AccountContactRelation> toInsert = new List<AccountContactRelation>();
        for (Id dealerId : dealerToCustomers.keySet()) {
            List<Id> contacts  = dealerToContacts.get(dealerId);
            Set<Id> customers = dealerToCustomers.get(dealerId);
            if (contacts == null) continue;

            for (Id custId : customers) {
                for (Id conId : contacts) {
                    toInsert.add(new AccountContactRelation(
                        ContactId = conId,
                        AccountId  = custId
                    ));
                }
            }
        }

        // 2-4) 중복 체크(선택) 및 DML
        if (!toInsert.isEmpty()) {
            // 필요하면 기존 ACR을 미리 조회해서 중복 필터링 가능
            Database.insert(toInsert, false);
        }
    }

    // 3) finish: 체이닝이 필요 없으면 비워두거나 로깅만
    global void finish(Database.BatchableContext bc) {
        System.debug('Finished one chunk of Associations.');
    }

    // 4) 스케줄러 진입점
    global void execute(SchedulableContext sc) {

    }
}