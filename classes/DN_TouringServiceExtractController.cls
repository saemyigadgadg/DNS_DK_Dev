/**
 * @description       : 순회서비스 Ticket 추출
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2024-07-23
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-23-2024   junyeong.choi@sbtglobal   Initial Version
**/
public with sharing class DN_TouringServiceExtractController {

    //@description       : 등록된 대상 장비 추출을 위한 대상 장비 목록 모달
    @AuraEnabled
    public static ResultWrapper confirmExtract(Id recordId) {
        ResultWrapper resultData = new ResultWrapper();
        try {
            Campaign cp = getCampaign(recordId);
            List<CampaignAsset__c> caList = getTargetEquipmntList(recordId);

            if (caList.size() < 1) {
                resultData.registerCheck = true;
            } else {
                if (cp.ExtractCheck__c == true) {
                    resultData.isSuccess = true;
                    resultData.extractCheck = true;
                    return resultData;
                } else {
                    resultData.isSuccess = true;
                    resultData.extractCheck = false;
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            resultData.isSuccess = false;
        }
        return resultData;
    }

    //@description       : 등록된 대상 장비 목록 조회
    @AuraEnabled
    public static List<TargetListWrapper> getTargetEquipList(Id recordId){
        System.debug('recordId'+recordID);
        List<TargetListWrapper> wrappers = new List<TargetListWrapper>();
        try {
            List<CampaignAsset__c> caList = 
            [
                SELECT Id, Name, Equipment__c, Equipment__r.Name, Manager__c, Campaign__c, Equipment__r.Account.Name, AccountAddress__c, FM_MachineName__c
                FROM CampaignAsset__c
                WHERE Campaign__c =:recordId
                ORDER BY CreatedDate ASC
            ];

            List<Case> caseList = 
            [
                SELECT Id, Campaign__c, AssetId
                FROM Case
                WHERE Campaign__c =:recordId
            ];
            Set<Id> caseIds = new Set<Id>();
            for(Case cs : caseList) {
                caseIds.add(cs.AssetId);
            }
            List<CampaignAsset__c> targetCAList = new List<CampaignAsset__c>();
            for(CampaignAsset__c ca : caList) {
                if(!caseIds.contains(ca.Equipment__c)) {
                    TargetListWrapper wrapper = new TargetListWrapper();
                    wrapper.Name    = ca.Equipment__r.Name;
                    wrapper.Manager = ca.Manager__c;
                    wrapper.Id      = ca.Id;
                    wrapper.Account = ca.Equipment__r.Account.Name;
                    wrapper.Model   = ca.FM_MachineName__c;
                    wrapper.Address = ca.AccountAddress__c;
                    wrappers.add(wrapper);
                }
            }
        } catch (Exception e) {
            System.debug('Error');
        }
        return wrappers;
    }

    // @description       : 대상 장비 Ticket 추출
    @AuraEnabled
    public static ResultWrapper extractTicket(Id recordId, String targetData) {
        System.debug('recordId' + recordId);
        System.debug('targetData' + targetData);
        ResultWrapper resultData         = new ResultWrapper();
        List<Id> caseIds                 = new List<Id>();
        List<Id> caIds                  = new List<Id>();
        Map<Id, Id> caseIdToManagerMap   = new Map<Id, Id>();
        List<Case> caseList              = new List<Case>();
        try{
            List<TargetListWrapper> targetList = new List<TargetListWrapper>();
            if (!String.isEmpty(targetData)) {
                targetList = (List<TargetListWrapper>) JSON.deserialize(targetData, List<TargetListWrapper>.class);
            }
            System.debug('targetList'+targetList);
            Campaign cp = getCampaign(recordId);

            List<CampaignAsset__c> caList = getCAList(targetList);
            for(CampaignAsset__c obj : caList) {
                Case caseData                    = new Case();
                caseData.Status                  = 'New';
                caseData.Campaign__c             = recordId;
                caseData.AssetId                 = obj.Equipment__c;
                caseData.TicketType__c           = 'Internal request';
                if (cp.CampaignType__c == 'ServiceCampaign') {
                    caseData.InternalTicketType__c = 'Service Campaign';
                } else if (cp.CampaignType__c == 'Pre_Call') {
                    caseData.InternalTicketType__c = 'Pre-Call';
                }
                caseData.AccountId               = obj.Equipment__r.AccountId;
                if(obj.Manager__c == null) {
                    caseData.OwnerId             = obj.CreatedById;
                } else {
                    caseData.OwnerId             = obj.Manager__c;
                }
                caseData.InternalRequester__c    = cp.OwnerId;
                caseData.ReceptionDetails__c     = cp.Name + (cp.Purpose__c != null ? '\n' + '목적 : ' + cp.Purpose__c : '') + (cp.Description != null ? '\n' + '설명 : ' + cp.Description : '');
                caseData.ReceptionPath__c	     = 'Indirect application'; 
                caseData.isAlarmToCustomer__c	 = false;
                caseList.add(caseData);
            }
            System.debug('caseList'+caseList);
            insert caseList;

            // 캠페인 첨부파일 -> 티켓에도 첨부 (Work Order 에는 Trigger 로 넣음)
            List<ContentDocumentLink> cdlList = 
            [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId AND IsDeleted = FALSE
            ];
            List<ContentDocumentLink> newCdlList = new List<ContentDocumentLink>();

            if(!cdlList.isEmpty()) {
                for(ContentDocumentLink cdl : cdlList) {
                    for(Case ca : caseList) {
                        ContentDocumentLink newLink = new ContentDocumentLink();
                        newLink.ContentDocumentId = cdl.ContentDocumentId;
                        newLink.LinkedEntityId = ca.Id;
                        newLink.ShareType = 'V';
                        newCdlList.add(newLink);
                    }
                }
            }

            if (!newCdlList.isEmpty()) {
                insert newCdlList;
            }

            for(Case caseItem : caseList) {
                System.debug('caseId' + caseItem.Id);
                caseIds.add(caseItem.Id);
                CampaignAsset__c ca = caList.get(caseList.indexOf(caseItem));
                caseIdToManagerMap.put(caseItem.Id, ca.Manager__c);
            }
            extractCampaignTartget(caseIds, recordId, caseIdToManagerMap, cp.Branch__c);

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            resultData.isSuccess 	= False;
        }
        return resultData;
    }

    // @description       : 대상 장비 Ticket 추출
    @AuraEnabled
    public static void extractCampaignTartget(List<Id> Ids, Id recordId, Map<Id, Id> caseIdToManagerMap, String branch){
        System.debug('extract');
        System.debug('Ids'+Ids);
        try {
            List<CampaignTarget__c> ctList = new List<CampaignTarget__c>();
                List<Case> caseList = [SELECT Id, AssetId FROM Case WHERE Id IN :Ids];
                System.debug('caseList'+caseList);
                for(Case obj : caseList) {
                    CampaignTarget__c ct = new CampaignTarget__c();
                    ct.Ticket__c        =   obj.Id;
                    ct.Campaign__c      =   recordId;
                    ct.Equipment__c	    =   obj.AssetId;
                    ct.Manager__c	    =   caseIdToManagerMap.get(obj.id);
                    ctList.add(ct);
                }
                System.debug('ctList'+ctList);
                insert ctList;

            Campaign cp = [
                SELECT Id, ExtractCheck__c
                FROM Campaign
                WHERE Id = :recordId
            ];

            cp.ExtractCheck__c = true;
            update cp;
            
        } catch (Exception e) {
            System.debug('Error');
        }
    }

    /**
     * @Description
     * 	- Get Campaign
     * @Return
     *  - Campaign
     * @author Junyeong Choi | 20241029
    **/
    @AuraEnabled
    public static Campaign getCampaign(String recordId){
        Campaign cp = [
            SELECT Id, Name, ExtractCheck__c, Branch__c, Description, CampaignType__c, OwnerId, Purpose__c
            FROM Campaign
            WHERE Id = :recordId
            LIMIT 1
        ];
        return cp;
    }

    /**
     * @Description
     * 	- Get Get Campaign Asset__c List
     * @Return
     *  - List<CampaignAsset__c>
     * @author Junyeong Choi | 20241029
    **/
    @AuraEnabled
    public static List<CampaignAsset__c> getCAList(List<TargetListWrapper> targetList){
        SET<Id> ids = new SET<Id>();
        for(TargetListWrapper tg : targetList) {
            ids.add(tg.Id);
        }
        System.debug('ids' + ids);
        List<CampaignAsset__c> caList = 
        [
            SELECT Id, Campaign__c, Equipment__c, Equipment__r.AccountId, Manager__c, CreatedById
            FROM CampaignAsset__c 
            WHERE Id = :ids
        ];
        System.debug('caList' + caList);
        for (CampaignAsset__c ca : caList) {
            for (TargetListWrapper tg : targetList) {
                if (tg.Id == ca.Id) {
                    ca.Manager__c = tg.Manager;
                    break;
                }
            }
        }
        update caList;
        return caList;
    }

    @AuraEnabled
    public static List<CampaignAsset__c> getTargetEquipmntList(String recordId){
        List<CampaignAsset__c> caList = 
        [
            SELECT Id, Campaign__c, Equipment__c, Equipment__r.AccountId, Manager__c, CreatedById
            FROM CampaignAsset__c 
            WHERE Campaign__c = :recordId
        ];
        return caList;
    }


    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     */ 
    public class ResultWrapper{
        @AuraEnabled public Boolean isSuccess      { get; set;}
        @AuraEnabled public String  errMessage     { get; set;}
        @AuraEnabled public Boolean extractCheck   { get; set;}
        @AuraEnabled public Boolean registerCheck  { get; set;}

        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }

    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     */ 
    public class TargetListWrapper{
        @AuraEnabled public String Name            { get; set;}
        @AuraEnabled public String Manager         { get; set;}
        @AuraEnabled public String Id              { get; set;}
        @AuraEnabled public String Account         { get; set;}
        @AuraEnabled public String Model           { get; set;}
        @AuraEnabled public String Address         { get; set;}

        
        public TargetListWrapper(){
            this.Name       = '';
            this.Manager    = '';
            this.Id         = '';
            this.Account    = '';
            this.Model      = '';
            this.Address    = '';
        }
    }
}