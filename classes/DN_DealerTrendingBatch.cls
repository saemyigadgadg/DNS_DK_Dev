/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - 연/월별로 Active 딜러 개수를 파악하기 위한 배치
 *  - Scheduled Jobs 등록
 *  - 레포트 구성
 * @last modified on  : 2025-02-10
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-24   yuhyun.park@sbtglobal.com   Initial Version
**/
global class DN_DealerTrendingBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    private static final Id   accType       = SObjectType.DealerTrending__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
    private static final Id   conType       = SObjectType.DealerTrending__c.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
    private static final Id   accDealerRT   = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id   conDealerRT   = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();


     // 최종 insert 대상 리스트 디버그용
     List<DealerTrending__c> insertedRecords = new List<DealerTrending__c>();

    
    global List<SObject> start(Database.BatchableContext bc) {

        // Account 쿼리
        List<Account> accList = [
            SELECT  Id, RecordTypeId, SalesOrganization__c 
            FROM    Account 
            WHERE   Inactive__c = false 
            AND     RecordTypeId =: accDealerRT
            AND     SalesOrganization__c = '1800'
        ];

        // Contact 쿼리
        List<Contact> conList = [
            SELECT  Id, RecordTypeId, AccountId, SalesOrganization__c 
            FROM    Contact 
            WHERE   Inactive__c = false 
            AND     RecordTypeId =: conDealerRT
            AND     SalesOrganization__c = '1800'
        ];
        
        List<SObject> sList = new List<SObject>();

        sList.addAll(accList);
        sList.addAll(conList);
        
        return sList;
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        System.debug('scope :: ' + scope);
        List<DealerTrending__c> insertList  = new List<DealerTrending__c>();

        String yearMonth = DateTime.now().format('yyyy-MM');

        for(SObject sObj : scope) {

            DealerTrending__c record = new DealerTrending__c();
            record.Name = yearMonth;
            record.Date__c = DateTime.now().date();

            // Account 타입
            if (sObj instanceof Account) {

                Account acc = (Account) sObj; // sObj를 Account로 캐스팅
                record.Account__c = acc.Id;
                record.RecordTypeId = accType;

            // Contact 타입    
            }else if (sObj instanceof Contact) {

                Contact con = (Contact) sObj; // sObj를 Contact로 캐스팅
                if (con.AccountId != null) {
                    record.Account__c = con.AccountId;
                }
                record.Contact__c = con.Id;
                record.RecordTypeId = conType;
            }

            insertList.add(record);
        }

        if(!insertList.isEmpty()){
            insert insertList;
            insertedRecords.addAll(insertList);
        }

    }

    global void finish(Database.BatchableContext bc) {

        // 배치가 완료된 후 insertList 디버그 출력
        System.debug('Inserted Records :: ' + insertedRecords);

    }

    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_DealerTrendingBatch batch = new DN_DealerTrendingBatch();
        Database.executeBatch(batch);
    }
}