/**
* @Class : CampaignTriggerHandler
*
* @Author : Junyeong, Choi
* @Date : 2024. 08. 21.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-08-21 | Junyeong, Choi   | 최초작성
*  2. | 2024-11-21 | Junyeong, Choi   | 두번째작성
*
*/
public with sharing class CampaignTriggerHandler extends TriggerHandler {

    /**
     * @Description
     * 	- Campaign BeforeInsert
     *  1. DNSA Pre-call Type 에 따라 Email Template Mapping
    **/
    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {
                List<EmailTemplate> templates = [SELECT Name, HtmlValue FROM EmailTemplate WHERE Name IN ('DNSA Pre-Call Request Email', 'DNSA Missing Part Request Email')];
                Map<String, String> templateMap = new Map<String, String>();
                for (EmailTemplate tmpl : templates) {
                    templateMap.put(tmpl.Name, tmpl.HtmlValue);
                }
    
                List<Campaign> cpList = (List<Campaign>)news;
                Set<Id> rtIds = new Set<Id>();
                for(Campaign cp : cpList){
                    rtIds.add(cp.RecordTypeId);
                }
    
                Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE Id IN :rtIds]);
    
                for(Campaign cp : cpList){
                    String rtName = rtMap.get(cp.RecordTypeId).Name;
                    if(rtName == 'DNSA Pre-Call' && cp.Pre__c == 'Pre-call'){
                        cp.MailContents__c = templateMap.get('DNSA Pre-Call Request Email');
                    } else if(rtName == 'DNSA Pre-Call' && cp.Pre__c == 'Missing Part'){
                        cp.MailContents__c = templateMap.get('DNSA Missing Part Request Email');
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Campaign AfterInsert
     *  1. CampaignType__c 의 값에 따라 CampaignRecordId Update
    **/
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting){
            List<Campaign> campaignList = (List<Campaign>) news;
            System.debug('[onAfterInsert] campaignList ::: ' + campaignList);
            Set<Id> cpIds = new Set<Id>();
            for(Campaign obj : campaignList){
                cpIds.add(obj.Id);
            }
            CommonWrapper cw = updateRecordType(campaignList, cpIds);
        }
    }

    /**
     * @Description
     * 	- Campaign BeforeUpdate
     *  1. DNSA Pre-call Type 에 따라 Email Template Mapping
    **/
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            List<Campaign> oldCampaignList = (List<Campaign>) olds;
            List<Campaign> newCampaignList = (List<Campaign>) news;
            Map<Id, Campaign> oldCampaignMap = (Map<Id, Campaign>) oldMap;
            Map<Id, Campaign> newCampaignMap = (Map<Id, Campaign>) newMap;
            Map<String, String> typeFOREmailMap = new Map<String, String>();
            String preCallHtmlValue = [SELECT Id, Name, Body, HtmlValue FROM EmailTemplate WHERE Name = 'DNSA Pre-Call Request Email'].HtmlValue;
            String missingPartHtmlValue = [SELECT Id, Name, Body, HtmlValue FROM EmailTemplate WHERE Name = 'DNSA Missing Part Request Email'].HtmlValue;

            Schema.DescribeFieldResult FieldResult = Campaign.Pre__c.getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : PicklistValues) {
                if(entry.getValue() == 'Pre-call') {
                    System.debug('Pre-call');
                    typeFOREmailMap.put(entry.getValue(), preCallHtmlValue);
                } else if (entry.getValue() == 'Missing Part') {
                    System.debug('Missing Part');
                    typeFOREmailMap.put(entry.getValue(), missingPartHtmlValue);
                }
            }

            for(Campaign newObj : newCampaignList) {
                Campaign oldObj = (Campaign) oldCampaignMap.get(newObj.Id);
                if(newObj.Pre__c != oldObj.Pre__c) {
                    String aHtmlValue = typeFOREmailMap.get(newObj.Pre__c);
                    System.debug('aHtmlValue'+aHtmlValue);
                    newObj.MailContents__c = aHtmlValue;
                }
            }
        }
    }

    /**
     * @Description
     * 	- Campaign AfterUpdate
     *  1. CampaignType__c 이 변경되면 해당 RecordId 도 Update
    **/ 
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            List<Campaign> oldCPList = (List<Campaign>) olds;
            List<Campaign> newCPList = (List<Campaign>) news;
            System.debug('newCPList ::: ' + newCPList);
            Map<Id, Campaign> oldCampaignMap = (Map<Id, Campaign>) oldMap;
            Map<Id, Campaign> newCampaignMap = (Map<Id, Campaign>) newMap;

            Set<Id> cpIds = new Set<Id>();
            for(Campaign obj : newCPList) {
                cpIds.add(obj.Id);
            }

            List<Campaign> cpLabels = [
                SELECT Id, RecordType.Name, RecordTypeId, toLabel(CampaignType__c)
                FROM Campaign
                WHERE Id IN :cpIds
            ];
            System.debug(cpLabels);

            Map<Id, String> cpAPI = new Map<Id, String>();
            for (Campaign c : [SELECT Id, CampaignType__c FROM Campaign WHERE Id IN :cpIds]) {
                cpAPI.put(c.Id, c.CampaignType__c);
            }
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Name, Id FROM RecordType WHERE SObjectType = 'Campaign']) {
                recordTypeMap.put(rt.Name, rt.Id);
            }
    
            List<Campaign> updateList = new List<Campaign>();
            String userLanguage = UserInfo.getLanguage();
            System.debug('User Language: ' + userLanguage);


            for(Campaign newCP : cpLabels) {
                Campaign oldCP = (Campaign) oldMap.get(newCP.Id);
                System.debug('oldCP ::: ' + oldCP);
                if(newCP.CampaignType__c != oldCP.CampaignType__c) {
                    String campaignTypeLabel = newCP.CampaignType__c; 
                    if (userLanguage != null) {
                        switch on userLanguage {
                            when 'en_US' {
                                if (recordTypeMap.containsKey(campaignTypeLabel) && newCP.RecordType.Name != campaignTypeLabel) {
                                    newCP.RecordTypeId = recordTypeMap.get(campaignTypeLabel);
                                    newCP.CampaignType__c = cpAPI.get(newCP.Id);
                                    updateList.add(newCP);
                                }
                            }
                            when 'ko' {
                                System.debug('ko');
                                campaignTypeLabel = 
                                campaignTypeLabel == '순회서비스' ? 'Service Campaign' :
                                campaignTypeLabel == '정기점검' ? 'Regular Inspections' :
                                campaignTypeLabel == 'Pre-Call' ? 'Pre-Call' : null;

                                if (campaignTypeLabel == null) {
                                    System.debug('Unknown label, skipping...');
                                    continue;
                                }
                                
                                if (recordTypeMap.containsKey(campaignTypeLabel) && newCP.RecordType.Name != campaignTypeLabel) {
                                    newCP.RecordTypeId = recordTypeMap.get(campaignTypeLabel);
                                    newCP.CampaignType__c = cpAPI.get(newCP.Id);
                                    updateList.add(newCP);
                                }
                            }
                        }
                    }
                }
            }
            System.debug('updateList: ' + updateList);

            if (!updateList.isEmpty()) {
                update updateList;
            }
        }
    }
                                            
    /**
     * @Description
     * 	- Update Record Type
     * @author Junyeong Choi | 20241118
    **/
    public static CommonWrapper updateRecordType(List<Campaign> campaignList, Set<Id> cpIds) {
        CommonWrapper cw = new CommonWrapper();
        try {
            List<Campaign> cpLabels = [
                SELECT Id, RecordType.Name, RecordTypeId, toLabel(CampaignType__c)
                FROM Campaign
                WHERE Id IN :cpIds
            ];
            System.debug(cpLabels);
    
            Map<Id, String> cpAPI = new Map<Id, String>();
            for (Campaign c : [SELECT Id, CampaignType__c FROM Campaign WHERE Id IN :cpIds]) {
                cpAPI.put(c.Id, c.CampaignType__c);
            }
    
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Name, Id FROM RecordType WHERE SObjectType = 'Campaign']) {
                recordTypeMap.put(rt.Name, rt.Id);
            }
    
            List<Campaign> updateList = new List<Campaign>();
            String userLanguage = UserInfo.getLanguage();
            System.debug('User Language: ' + userLanguage);
    
            for (Campaign campaign : cpLabels) {
                String campaignTypeLabel = campaign.CampaignType__c;
                System.debug('CampaignType Label: ' + campaignTypeLabel);
    
                if (userLanguage != null) {
                    switch on userLanguage {
                        when 'en_US' {
                            if (recordTypeMap.containsKey(campaignTypeLabel) && campaign.RecordType.Name != campaignTypeLabel) {
                                campaign.RecordTypeId = recordTypeMap.get(campaignTypeLabel);
                                campaign.CampaignType__c = cpAPI.get(campaign.Id);
                                updateList.add(campaign);
                            }
                        }
                        when 'ko' {
                            System.debug('ko');
                            campaignTypeLabel = 
                            campaignTypeLabel == '순회서비스' ? 'Service Campaign' :
                            campaignTypeLabel == '정기점검' ? 'Regular Inspections' :
                            campaignTypeLabel == 'Pre-Call' ? 'Pre-Call' : null;
                            if (campaignTypeLabel == null) {
                                System.debug('Unknown label, skipping...');
                                continue;
                            }

                            if (recordTypeMap.containsKey(campaignTypeLabel) && campaign.RecordType.Name != campaignTypeLabel) {
                                campaign.RecordTypeId = recordTypeMap.get(campaignTypeLabel);
                                campaign.CampaignType__c = cpAPI.get(campaign.Id);
                                updateList.add(campaign);
                            }
                        }
                    }
                }
            }
    
            System.debug('Update List: ' + updateList);
    
            if (!updateList.isEmpty()) {
                update updateList;
            }
    
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }
        
    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     * 		- returnValue 			: 성공시 Return 값 
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		{get; set;}
        @AuraEnabled
        public String errMessage		{get; set;} 
        @AuraEnabled
        public String returnValue		{get; set;}

        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnValue 	= '';
        }
    }
}