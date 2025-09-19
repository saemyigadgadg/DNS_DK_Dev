/**
* @Class : DN_RegularServiceCampaignBatch
*
* @Author : Junyeong, Choi
* @Date : 2024. 10. 21.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-10-21 | Junyeong, Choi   | 최초작성
*  2. | 2024-12-18 | Junyeong, Choi   | Ver 2. 서비스 패키지 오브젝트 삭제. Asset 과 Product 기준으로 캠페인 생성
*/
global class DN_RegularServiceCampaignBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext context) {
        // 월말마다 캠페인 생성 배치 Start - 더미 쿼리
        return Database.getQueryLocator(
            'SELECT Id FROM Asset LIMIT 1'
        );
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        // 매월 말일에 Batch 스케줄러 설정해서 다음 달 Campaign 미리 만들어놓기
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);

        RecordType camrt     = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Campaign' AND Name = 'Regular Inspections' LIMIT 1];
        Date today           = Date.today();
        Date nextMonthDate   = today.addMonths(1);
        String spDate        = nextMonthDate.year() + '년 ' + nextMonthDate.month() + '월 정기점검 캠페인';

        Campaign newCampaign = new Campaign();
        newCampaign.Name                    = spDate;
        newCampaign.RecordTypeId            = camrt.Id;
        newCampaign.CampaignType__c         = 'RegularInspections';
        newCampaign.RegularServiceType__c   = 'General Regular Service';
        newCampaign.IsActive                = true;
        insert newCampaign;
    }

    public void finish(Database.BatchableContext context) {
        System.debug('배치 실행 완료');
    }

    public void execute(SchedulableContext sc) {
        DN_RegularServiceCampaignBatch batch = new DN_RegularServiceCampaignBatch();
        Database.executeBatch(batch, 1);        
    }

}