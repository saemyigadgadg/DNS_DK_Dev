/**
* @Class : DN_CloneOpportunityController
*
* @Author : SeJin, Kwon
* @Date : 2024. 06. 18.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-18 | SeJin, Kwon   | 최초작성
*
*/
public with sharing class DN_CloneOpportunityController {

    @AuraEnabled
    public static string getStage(String recordId){
        try {
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = [SELECT Id, StageName FROM Opportunity WHERE Id =: recordId];
            return oppList[0].StageName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    //RecordType이 Turn-Key면 General, General이면 Turn-Key로 return 
    @AuraEnabled(cacheable=true)
    public static List<RecordType> changeRecordTypes(String recordId) {
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT 
                    RecordTypeId
                   FROM Opportunity 
                   WHERE Id =:recordId];

        List<RecordType> recordList = new List<RecordType>();
        if (!oppList.isEmpty()) {        
        
        recordList = [SELECT 
                        Id, DeveloperName, Name
                        FROM RecordType
                        WHERE Id !=: oppList[0].RecordTypeId and SobjectType = 'Opportunity' and DeveloperName != 'Service' and DeveloperName != 'DNSA'];
        }
        return recordList;
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordName(String recordId) {

        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [SELECT 
                    RecordTypeId
                   FROM Opportunity 
                   WHERE Id =:recordId];

        List<RecordType> recordList = new List<RecordType>();   
        if (!oppList.isEmpty()) { 
            recordList = [SELECT 
                        Id, DeveloperName, Name
                        FROM RecordType
                        WHERE Id =: oppList[0].RecordTypeId];
        }  
        return recordList;
    }

    //Clone Opportunity 생성
    @AuraEnabled
    public static string opptyCloneCreate(Opportunity oppty, String recordId, String changeType, String changeRecordType){

        Date todayDate = Date.today();
        System.debug('changeRecordType : ' + changeRecordType);
        if(oppty.CloseDate < todayDate){
            throw new AuraHandledException(System.Label.DNS_M_ContractDate);
        }else if(oppty.RequestDelieveryDate__c != null && oppty.RequestDelieveryDate__c <= todayDate){
            throw new AuraHandledException(System.Label.DNS_M_RequestDate);
        }else if(changeRecordType == 'Turn_Key' && oppty.IsStrategicMaterial__c){
            throw new AuraHandledException(System.Label.DNS_M_StrategicCheck);
        }else{
            List<Opportunity> stageCheck = [SELECT Id, stageName FROM Opportunity WHERE Id =: recordId];
            if(!stageCheck[0].stageName.contains('Closed') && changeType == 'ChangeType'){
                //Clone Create시 기존 oppty data update
                Opportunity originData = new Opportunity(
                    Id = recordId,
                    StageName = 'Closed Drop',
                    Reason_Mis__c = 'Change Of Inquiry Type',
                    Loss_Reason__c = '1. Change Of Inquiry Type');
                try {
                update originData;
                } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
                }
            }
            System.debug('oppty.RecordTypeId : ' + oppty.RecordTypeId);
            //단순 Clone Create
            if(oppty.RecordTypeId != null){

                try {
                    oppty.IsClone__c = true;
                    insert oppty;
                    List<RecordType> recordList = [
                        SELECT Id
                                , DeveloperName
                                , Name
                        FROM RecordType
                        WHERE Id =: oppty.RecordTypeId
                    ];

                    //new record가 General이고 olds record도 General이면서 opportunityLineItem에 데이터가 있으면 복제_권세진 241029
                    if(recordList[0].DeveloperName == 'General'){
                        Map<Id, Id> priceMap = new Map<Id, Id>();
                        Set<Id> prdId = new Set<Id>();

                        List<Opportunity> oldsList = [
                            SELECT Id
                                    , RecordTypeId
                                    ,CurrencyIsoCode
                            FROM Opportunity
                            WHERE Id =: recordId];

                        List<RecordType> oldsrecordList = [
                        SELECT Id
                                , DeveloperName
                                , Name
                        FROM RecordType
                        WHERE Id =: oldsList[0].RecordTypeId
                        ];
                        if(oldsrecordList[0].DeveloperName == 'General'){
                            List<OpportunityLineItem> oppPrdList = [SELECT 
                                                                        OpportunityId,
                                                                        PricebookEntryId,
                                                                        Quantity,
                                                                        UnitPrice,
                                                                        ListPrice,
                                                                        Product2Id
                                                                    FROM
                                                                        OpportunityLineItem
                                                                    WHERE
                                                                        OpportunityId =: recordId
                                                                    ];
                            if(oppPrdList.size() > 0){
                                for(OpportunityLineItem oppPrds : oppPrdList){
                                    prdId.add(oppPrds.Product2Id);
                                }
                                List<PricebookEntry> pbEntryList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN:prdId AND CurrencyIsoCode =:oldsList[0].CurrencyIsoCode];
                                if(!pbEntryList.isEmpty()){
                                    for(PricebookEntry pb : pbEntryList){
                                        priceMap.put(pb.Product2Id, pb.Id);
                                    }
                                }
                                System.debug('priceMap : ' + priceMap);
                                List<OpportunityLineItem> oppNewPrdList = new List<OpportunityLineItem>();

                                for(OpportunityLineItem oppPrdItem : oppPrdList){
                                    OpportunityLineItem oppNewPrd = new OpportunityLineItem();
                                    oppNewPrd.OpportunityId     =   oppty.id;
                                    // oppNewPrd.PricebookEntryId  =   oppPrdItem.PricebookEntryId;
                                    oppNewPrd.Product2Id        = oppPrdItem.Product2Id;
                                    oppNewPrd.PricebookEntryId  =   priceMap.get(oppPrdItem.Product2Id);
                                    oppNewPrd.Quantity          =   oppPrdItem.Quantity;
                                    oppNewPrd.UnitPrice         =   oppPrdItem.UnitPrice;

                                    oppNewPrdList.add(oppNewPrd);
                                }
                                try{
                                    insert oppNewPrdList;
                                    Opportunity opptyQty = new Opportunity();
                                    opptyQty.Id = oppty.Id;
                                    opptyQty.TotalOpportunityQuantity = oppPrdList.size();
                                    update opptyQty;
                                }catch(Exception e){
                                    System.debug('Error : ' + e.getMessage() + 'Line : ' + e.getLineNumber());
                                    throw new AuraHandledException(System.Label.DNS_M_Error + ' : ' + e.getMessage());
                                }
                            }
                        }
                    }
                    
                } catch (Exception e) {
                    throw new AuraHandledException(System.Label.DNS_M_Error + ' : ' + e.getMessage());
                }

                List<RecordType> recordList = [
                    SELECT Id, DeveloperName, Name
                    FROM RecordType
                    WHERE Id =: oppty.RecordTypeId
                ];
                System.debug('opptyId : ' + oppty.Id);

                //경쟁사 정보 복제
                List<OpptyCompetitorMapping__c> originCompetitor = 
                [
                    SELECT
                        Competitor__c,
                        Competitor_Model__c
                    FROM
                        OpptyCompetitorMapping__c  
                    WHERE
                        Opportunity__c =: recordId
                ];
                System.debug('originCompetitor : ' + originCompetitor);
                List<OpptyCompetitorMapping__c> newCompetitor = new List<OpptyCompetitorMapping__c>();
                if(originCompetitor.size() > 0){
                    for(OpptyCompetitorMapping__c origin : originCompetitor)
                    {
                        OpptyCompetitorMapping__c competitor = new OpptyCompetitorMapping__c();
                        competitor.Opportunity__c = oppty.Id;
                        competitor.Competitor__c = origin.Competitor__c;
                        competitor.Competitor_Model__c = origin.Competitor_Model__c;
                        newCompetitor.add(competitor);
                    }

                    insert newCompetitor;
                }
                
                // return oppty.Id;
            }else {
                List<Opportunity> oppList = new List<Opportunity>();
                    oppList = [SELECT 
                                RecordTypeId
                            FROM Opportunity 
                            WHERE Id =:recordId];

                List<RecordType> recordList = new List<RecordType>();
                if (!oppList.isEmpty()) {        
                
                    recordList = [SELECT 
                                    Id, DeveloperName, Name
                                    FROM RecordType
                                    WHERE Id !=: oppList[0].RecordTypeId and SobjectType = 'Opportunity' and DeveloperName != 'Service' and DeveloperName != 'DNSA'];
                }
                oppty.RecordTypeId = recordList[0].Id;
                oppty.OriginOpportunity__c = recordId;
                oppty.IsClone__c = true;
                try {
                    insert oppty;

                    //경쟁사 정보 복제
                    List<OpptyCompetitorMapping__c> originCompetitor = 
                    [
                        SELECT
                            Competitor__c,
                            Competitor_Model__c
                        FROM
                            OpptyCompetitorMapping__c  
                        WHERE
                            Opportunity__c =: recordId
                    ];
                    System.debug('originCompetitor : ' + originCompetitor);
                    List<OpptyCompetitorMapping__c> newCompetitor = new List<OpptyCompetitorMapping__c>();
                    if(originCompetitor.size() > 0){
                        for(OpptyCompetitorMapping__c origin : originCompetitor)
                        {
                            OpptyCompetitorMapping__c competitor = new OpptyCompetitorMapping__c();
                            competitor.Opportunity__c = oppty.Id;
                            competitor.Competitor__c = origin.Competitor__c;
                            competitor.Competitor_Model__c = origin.Competitor_Model__c;
                            newCompetitor.add(competitor);
                        }

                        insert newCompetitor;
                    }
                    
                } catch (Exception e) {
                    // throw new AuraHandledException(System.Label.DNS_M_Error + ' : ' + e.getMessage());
                    System.debug('Line : ' + e.getLineNumber() + 'MSG : ' + e.getMessage());
                    return 'ERROR';
                }
                
            }

        }
        return oppty.Id;
        
    }
}