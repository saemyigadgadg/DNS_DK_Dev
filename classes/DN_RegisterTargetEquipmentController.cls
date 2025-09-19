/**
 * @description       : 대상장비등록 모달창
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2024-07-22
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-22-2024   junyeong.choi@sbtglobal   Initial Version
**/
public with sharing class DN_RegisterTargetEquipmentController {

    /* 
    @ description : Campaign 대상 장비 검색
    */ 
    @AuraEnabled
    public static List<EquipmentWrapper> searchTargetEquipments(Id accountId, String modelName, String assetName, String maintPlant, String planningPlant){
        System.debug('maintPlant'+maintPlant);
        System.debug('planningPlant'+planningPlant);
        List<EquipmentWrapper> resultData = new List<EquipmentWrapper>();
        List<Asset> assetList = new List<Asset>();
        try {
            if(String.isEmpty(modelName) && String.isEmpty(assetName) && String.isEmpty(accountId)){
                return resultData;
            }
            String sQuery = 'SELECT Id, Name, SerialNumber, AccountId, Account.Name, Account.CustomerCode__c, Account.Representative__c, Account.Phone, MachineName__c, FM_Address__c, SoldTo__r.Name, SoldTo__c, SoldTo__r.ServiceManager__c, SoldTo__r.PartsManagerEmail__c FROM Asset';
            List<String> wQuery = new List<String>();
            if(accountId != null){
                wQuery.add('AccountId = \'' + accountId + '\'');
            }
            if(String.isNotEmpty(modelName)){
                wQuery.add('MachineName__c LIKE \'%' + String.escapeSingleQuotes(modelName) + '%\'');
            }
            if(String.isNotEmpty(assetName)){
                wQuery.add('Name LIKE \'%' + String.escapeSingleQuotes(assetName) + '%\'');
            }
            if(String.isNotEmpty(maintPlant)){
                wQuery.add('Maintplant__c = \'' + maintPlant + '\'');
            }
            if(String.isNotEmpty(planningPlant)){
                wQuery.add('PlannerGrp__c = \'' + planningPlant + '\'');
            }

            if (!wQuery.isEmpty()) {
                sQuery += ' WHERE ' + String.join(wQuery, ' AND ');
            }
            String oQuery = ' ORDER BY Name ASC LIMIT 500';
            System.debug('sQuery: ' + sQuery);
            assetList = Database.query(sQuery + oQuery);

            // [DNSA] 검색시 자동으로 Email 에 SoldToParty 의 Pre-Call Manager Email 값 Mapping.
            Map<String, List<PreCallManager__c>> assetIdFORPM = new Map<String, List<PreCallManager__c>>();
            Set<Id> soldToIds = new Set<Id>();
            for (Asset ass : assetList) {
                if (ass.SoldTo__c != null) {
                    soldToIds.add(ass.SoldTo__c);
                }
            }
            List<PreCallManager__c> preCallManagers = [SELECT Id, Name, Account__c, DealerEmail__c
                                                        FROM PreCallManager__c 
                                                        WHERE Account__c IN :soldToIds];
            for (PreCallManager__c pcm : preCallManagers) {
                if (!assetIdFORPM.containsKey(pcm.Account__c)) {
                    assetIdFORPM.put(pcm.Account__c, new List<PreCallManager__c>());
                }
                assetIdFORPM.get(pcm.Account__c).add(pcm);
            }

            // Return resultData
            for (Asset asset : assetList) {
                List<PreCallManager__c> pmList = assetIdFORPM.get(asset.SoldTo__c);
                String emailList = '';
                if(pmList != null) {
                    for(PreCallManager__c pm : pmList) {
                        if(pm.DealerEmail__c != null) {
                            if (emailList != '') {
                                emailList += ';';
                            }
                            emailList += pm.DealerEmail__c;
                        }
                    }
                }
                EquipmentWrapper wrapper = new EquipmentWrapper();
                wrapper.AssetId          =   asset.Id;
                wrapper.Name             =   asset.Name;
                wrapper.AccountName      =   (asset.Account != null) ? asset.Account.Name : '';
                wrapper.BusinessNumber   =   (asset.Account != null) ? asset.Account.CustomerCode__c : '';
                wrapper.Representative   =   (asset.Account != null) ? asset.Account.Representative__c : '';
                wrapper.Phone            =   (asset.Account != null) ? asset.Account.Phone : '';
                wrapper.Address          =   asset.FM_Address__c;
                wrapper.SoldTo           =   asset.SoldTo__r.Name;
                if(!String.isEmpty(emailList)) {
                    wrapper.Email            =   emailList;
                }
                resultData.add(wrapper);
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        System.debug('resultData::'+ resultData);
        return resultData;
    }

    /* 
    @ description : 선택한 Campaign 대상 장비 등록
    */     
    @AuraEnabled
    public static ResultWrapper registerTargetEquipment(Id recordId, List<Map<String, Object>> selectedData){
        ResultWrapper resultData = new ResultWrapper();
        try {
            List<CampaignAsset__c> assetsToCreate = new List<CampaignAsset__c>();
            Campaign cp = [SELECT Id, RecordTypeId, RecordType.Name FROM Campaign WHERE Id = :recordId];
            Set<Id> existingIds = new Set<Id>();
            for(CampaignAsset__c ca : [SELECT Id, Equipment__c FROM CampaignAsset__c WHERE Campaign__c = :recordId]) {
                if(ca.Equipment__c	!= null) {
                    existingIds.add(ca.Equipment__c);
                }
            }
            String user = UserInfo.getUserId();
            System.debug('user' + user);
            for(Map<String, Object> data : selectedData){
                Id equipId = (Id)data.get('AssetId');
                if (existingIds.contains(equipId)) {
                    resultData.isSuccess = false;
                    return resultData;
                }

                CampaignAsset__c campaignAsset = new CampaignAsset__c();
                campaignAsset.Campaign__c = recordId;
                campaignAsset.Equipment__c = equipId;
                if(cp.RecordType.Name == 'DNSA Pre-Call') {
                    if((String) data.get('Email') != null ) {
                        campaignAsset.Email__c = (String) data.get('Email');
                    } else {
                        campaignAsset.Email__c = null;
                    }
                } else {
                    if((String) data.get('Manager__c') != null ) {
                        campaignAsset.Manager__c = (String) data.get('Manager__c');
                    } else {
                        campaignAsset.Manager__c = user;
                    }
                }
                assetsToCreate.add(campaignAsset);
            }
            insert assetsToCreate;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            resultData.isSuccess 	= False;
            resultData.errMessage 	= e.getMessage();
        }
        return resultData;
    }

    /* 
    @ description : 등록한 대상 장비 중복 확인
    */     
    @AuraEnabled
    public static ResultWrapper changeTargetEquipment(Id recordId, List<Map<String, Object>> selectedEquipment) {
        System.debug('selectedEquipment: ' + selectedEquipment);
        System.debug('recordId: ' + recordId);
        ResultWrapper resultData = new ResultWrapper();
        try {
            List<CampaignAsset__c> assetsToUpdate = new List<CampaignAsset__c>();
            List<CampaignAsset__c> assetsToCreate = new List<CampaignAsset__c>();

            List<CampaignAsset__c> existingList = [
                SELECT Id, Equipment__c, Manager__c, Campaign__c
                FROM CampaignAsset__c
                WHERE Campaign__c = :recordId
            ];

            Set<Id> existingEquipmentIds = new Set<Id>();
            for (CampaignAsset__c ca : existingList) {
                existingEquipmentIds.add(ca.Equipment__c);
            }
            System.debug('existingEquipmentIds: ' + existingEquipmentIds);

            String userId = UserInfo.getUserId();
            System.debug('Current user: ' + userId);
            Campaign cp = [SELECT Id, RecordTypeId, RecordType.Name FROM Campaign WHERE Id = :recordId];
            for (Map<String, Object> data : selectedEquipment) {
                Id equipId = (Id) data.get('AssetId');
                System.debug('equipId: ' + equipId);

                if (existingEquipmentIds.contains(equipId)) {
                    for (CampaignAsset__c ca : existingList) {
                        if (ca.Equipment__c == equipId) {
                            if(cp.RecordType.Name == 'DNSA Pre-Call') {
                                ca.Email__c = (String) data.get('Email');
                                assetsToUpdate.add(ca);
                            } else {
                                ca.Manager__c = (String) data.get('Manager__c');
                                assetsToUpdate.add(ca);
                            }
                        }
                    }
                } else {
                    CampaignAsset__c campaignAsset = new CampaignAsset__c();
                    campaignAsset.Campaign__c = recordId;
                    campaignAsset.Equipment__c = equipId;
                    if(cp.RecordType.Name == 'DNSA Pre-Call') {
                        campaignAsset.Email__c = (String) data.get('Email') != null ? (String) data.get('Email') : null;
                    } else {
                        campaignAsset.Manager__c = (String) data.get('Manager__c') != null ? (String) data.get('Manager__c') : userId;
                    }
                    assetsToCreate.add(campaignAsset);
                }
            }

            System.debug('assetsToUpdate: ' + assetsToUpdate);
            System.debug('assetsToCreate: ' + assetsToCreate);

            if (!assetsToUpdate.isEmpty()) {
                update assetsToUpdate;
            }
            if (!assetsToCreate.isEmpty()) {
                insert assetsToCreate;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return resultData;
    }

    /* 
    @ description : 고객사 기준 검색 모달 열기
    */     
    @AuraEnabled
    public static List<AccountListWrapper> initAccountList(String accountSearchVal){
        List<AccountListWrapper> resultData = new List<AccountListWrapper>();

        if(String.isEmpty(accountSearchVal)) {
            System.debug('accountSearchVal 없음');
            try {
                List<Account> accList = [SELECT Id, Name, Representative__c, CustomerCode__c FROM Account ORDER BY Name ASC];
                for(Account acc : accList) {
                    AccountListWrapper alw = new AccountListWrapper();
                    alw.AccountId         = acc.Id;
                    alw.Name              = acc.Name;
                    alw.Representative    = acc.Representative__c;
                    alw.BusinessNumber    = acc.CustomerCode__c;
                    resultData.add(alw);
                }
    
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
            System.debug('resultData::'+ resultData);
            return resultData;
            
        } else {
            System.debug('accountSearchVal 있음');
            List<Account> searchList = new List<Account>();
            try {
                String sQuery = 'SELECT Id, Name, Representative__c, CustomerCode__c FROM Account';
                String wQuery = ' WHERE Name LIKE \'%' + accountSearchVal + '%\'';
                searchList = Database.Query(sQuery + wQuery);
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }

            System.debug('여기');
            for(Account acc : searchList) {
                AccountListWrapper alw = new AccountListWrapper();
                alw.AccountId         = acc.Id;
                alw.Name              = acc.Name;
                alw.Representative    = acc.Representative__c;
                alw.BusinessNumber    = acc.CustomerCode__c;
                resultData.add(alw);
            }
            return resultData;
        }
    }

    /* 
    @ description : 기종 기준 검색 모달 열기
    */     
    @AuraEnabled
    public static List<ModelWrapper> initModelList(String accountName, String modelSearchVal){
        List<ModelWrapper> resultData = new List<ModelWrapper>();

        if(String.isEmpty(modelSearchVal)) {
            System.debug('modelSearchVal 없음');
            try {
                List<ModelManager__c> mmList = [SELECT Id, Name FROM ModelManager__c ORDER BY Name ASC];
                for(ModelManager__c mm : mmList) {
                    ModelWrapper mw = new ModelWrapper();
                    mw.Model              = mm.Name;
                    resultData.add(mw);
                }
    
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
            System.debug('resultData::'+ resultData);
            return resultData;
        } else {
            System.debug('modelSearchVal 있음');
            List<ModelManager__c> searchList = new List<ModelManager__c>();
            try {
                String sQuery = 'SELECT Id, Name FROM ModelManager__c';
                String wQuery = ' WHERE Name LIKE \'%' + modelSearchVal + '%\'';
                String oQuery = ' ORDER BY Name ASC';
                searchList = Database.Query(sQuery + wQuery + oQuery);
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
            for(ModelManager__c ass : searchList) {
                ModelWrapper ew = new ModelWrapper();
                ew.Model           =   ass.Name;
                resultData.add(ew);
            }
            return resultData;
        }
    }
    
    // Confirm CommonParts
    @AuraEnabled
    public static ResultWrapper checkCommonParts(Id recordId) {
        System.debug('recordId' + recordId);
        ResultWrapper resultData = new ResultWrapper();
        try {
            Campaign cp = getCampaign(recordId);
            List<CommonPart__c> cpList = [
                SELECT  Id, Campaign__c
                FROM    CommonPart__c
                WHERE   Campaign__c = : recordId
            ];

            if (cpList.size() < 1 && cp.UseCommonParts__c == true) {
                resultData.registerCheck = true;
            }
            if(cp.RecordType.Name == 'DNSA Pre-Call') {
                resultData.DNSArecordType = true;
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            resultData.isSuccess = false;
            resultData.errMessage = e.getMessage();
        }
        return resultData;
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
        try {
            Campaign cp = [
                SELECT Id, ExtractCheck__c, Branch__c, UseCommonParts__c, RecordType.Name, RecordTypeId
                FROM Campaign
                WHERE Id = :recordId
                LIMIT 1
            ];
            return cp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * @Description 
     *  - TargetEquipmentList Wrapper
     * 
     * @Variable 
     *  - AssetId	        :   제조번호
     *  - Name	            :   제조번호
     *  - AccountName	    :   고객사명
     *  - BusinessNumber    :   사업자번호
     *  - Representative    :   대표자
     *  - Phone	            :   전화
     */ 
    public class EquipmentWrapper {
        @AuraEnabled public String AssetId           {get; set;}
        @AuraEnabled public String Name              {get; set;}
        @AuraEnabled public String AccountName       {get; set;}
        @AuraEnabled public String BusinessNumber    {get; set;}
        @AuraEnabled public String Representative    {get; set;}
        @AuraEnabled public String Phone             {get; set;}
        @AuraEnabled public String Model             {get; set;}
        @AuraEnabled public String Address           {get; set;}
        @AuraEnabled public String SoldTo            {get; set;}
        @AuraEnabled public String Email             {get; set;}

        public EquipmentWrapper() {
            this.AssetId          =   '';
            this.Name             =   '';
            this.AccountName      =   '';
            this.BusinessNumber   =   '';
            this.Representative   =   '';
            this.Phone            =   '';
            this.Model            =   '';
            this.Address          =   '';
            this.SoldTo           =   '';
            this.Email            =   '';
        }
    }

    /*
     */ 
    public class ModelWrapper {
        @AuraEnabled public String Model           {get; set;}
        @AuraEnabled public String ModelCategory   {get; set;}

        public ModelWrapper() {
            this.Model          =   '';
            this.ModelCategory  =   '';
        }
    }

    /*
     * @Description 
     *  - AccountList Wrapper
     * 
     * @Variable 
     *  - AccountId	        : 고객사 아이디
     *  - Name	            : 고객사 명
     *  - BusinessNumber	: 사업자 번호
     *  - Representative	: 대표자 명
     */ 
    public class AccountListWrapper {
        @AuraEnabled public String AccountId           {get; set;}
        @AuraEnabled public String Name                {get; set;}
        @AuraEnabled public String BusinessNumber      {get; set;}
        @AuraEnabled public String Representative      {get; set;}

        public AccountListWrapper() {
            this.AccountId           = '';
            this.Name                = '';
            this.BusinessNumber      = '';
            this.Representative      = '';
        }
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
        @AuraEnabled public Boolean registerCheck  { get; set;}
        @AuraEnabled public Boolean DNSArecordType { get; set;}
        
        public ResultWrapper(){
            this.isSuccess      = true;
            this.registerCheck  = false;
            this.DNSArecordType = false;
        }
    }
}