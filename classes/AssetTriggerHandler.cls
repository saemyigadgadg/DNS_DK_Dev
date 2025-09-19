/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class AssetTriggerHandler extends TriggerHandler {

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        System.debug('Asset Before Update');


        // String currentUserId = UserInfo.getUserId();

        // List<AssetNoteChange__c> changeAvaliableUserList = [SELECT Name, UserId__c FROM AssetNoteChange__c];
        // List<User> systemAdmins = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator', '시스템 관리자') AND IsActive = true];
        // Set<String> changeAvaliableUserIds = new Set<String>();
        // for (AssetNoteChange__c anc : changeAvaliableUserList) {
        //     changeAvaliableUserIds.add(anc.UserId__c);
        // }
        // for (User user : systemAdmins) {
        //     changeAvaliableUserIds.add(user.Id);
        // }

        // 정규식 yyyy/MM (예: 2023/11)
        Pattern constrYrMthPattern = Pattern.compile('^\\d{4}/(0[1-9]|1[0-2])$');
    
        for (Asset newAsset : (List<Asset>) news) {
            Asset oldAsset = (Asset) oldMap.get(newAsset.Id);
            newAsset.WarrantyStartDate__c = newAsset.WarrantyStartDateWages__c;
            // Asset oldAsset = (Asset) oldMap.get(newAsset.Id);
            // if (newAsset.InternNote__c != oldAsset.InternNote__c && !changeAvaliableUserIds.contains(currentUserId)) {
            //     newAsset.InternNote__c.addError(System.Label.DN_Error_AssetInternNote);
            // }
            String constrYrMth = newAsset.ConstrYrMth__c == null ? '' : String.valueOf(newAsset.ConstrYrMth__c);

            //날짜 계산하는 로직 추가 - 이원정
            Boolean isBeginguaranteeChanged = oldAsset.BeginguaranteeSpindle__c != newAsset.BeginguaranteeSpindle__c;
            Boolean isSalesTypeChanged = oldAsset.SalesType__c != newAsset.SalesType__c;

            if ((isBeginguaranteeChanged || isSalesTypeChanged) && newAsset.BeginguaranteeSpindle__c != null && newAsset.SalesType__c != null) {
                Date baseDate = newAsset.BeginguaranteeSpindle__c;

                if (newAsset.SalesType__c == '신품(18개월)') {
                    newAsset.WarrantyendSpindle__c = baseDate.addMonths(18).addDays(-1);
                } 
                else if (newAsset.SalesType__c == '재생품(12개월)') 
                {
                    newAsset.WarrantyendSpindle__c = baseDate.addMonths(12).addDays(-1);
                } 
                else 
                {
                    // 수리품(6개월) 또는 기타
                    newAsset.WarrantyendSpindle__c = baseDate.addMonths(6).addDays(-1);
                }
                System.debug('@@ WarrantyendSpindle__c: ' + newAsset.WarrantyendSpindle__c);
            }

            //250808 장비 Warranty 36개월 계산 - 이원정
            if(newAsset.WarrantyMasterLabor__c == 'MT-X36'){
                Date baseDate = newAsset.WarrantyStartDate__c;
                newAsset.WarrantyEnd__c = baseDate.addMonths(36).addDays(-1);
            }

    
            if (constrYrMth.length() > 0 && !constrYrMthPattern.matcher(constrYrMth).matches()) {
                System.debug('AssetTriggerHandler:onBeforeUpdate:::');
                newAsset.addError('Constr.yr/mth 값은 "yyyy/MM" 형식(예: 2023/11)이어야 합니다.');
            }
        }

    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        System.debug('Asset After Update');
        String fieldSetName = 'ERP_Fields';
        Map<String, String> statusECUSMap = new Map<String, String>();

        Set<String> fieldSetFields = getFieldSetFields('Asset', fieldSetName);


        List<Asset> changedAssets = new List<Asset>();
        for (Asset newAsset : (List<Asset>) news) {
            Asset oldAsset = (Asset) oldMap.get(newAsset.Id);
            
            if (isFieldChanged(oldAsset, newAsset, fieldSetFields)) {
                changedAssets.add(newAsset);
                if (newAsset.Status != oldAsset.Status && newAsset.Status == 'ECUS') {
                    statusECUSMap.put(newAsset.Id, 'X');
                } else {
                    statusECUSMap.put(newAsset.Id, '');
                }

            }
        }

        if (!changedAssets.isEmpty()) {
            System.debug('changedAssets::: ' + changedAssets);

            String query = fieldSetQuery('Asset', fieldSetName, changedAssets);
            System.debug('query:::' + query);

            // Database.executeBatch(new DN_ERPToAssetBatch(query, statusECUSMap), 1); // 테스트 때문에 잠깐 주석
            System.enqueueJob(new DN_ERPToAssetQueue(changedAssets, statusECUSMap));
        }
    }

    // 필드셋에서 필드 이름을 가져오는 메소드
    @TestVisible
    private Set<String> getFieldSetFields(String sObjectName, String fieldSetName) {
        Set<String> fieldNames = new Set<String>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = describeResult.fieldSets.getMap();

        if (fieldSetMap.containsKey(fieldSetName)) {
            Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                fieldNames.add(field.getFieldPath());
                System.debug('fieldNames:::' + fieldNames);
            }
        } else {
            throw new IllegalArgumentException('FieldSet ' + fieldSetName + ' not found for object ' + sObjectName);
        }
        return fieldNames;
    }

    // 필드 변경 여부를 확인하는 메소드
    @TestVisible
    private Boolean isFieldChanged(SObject oldRecord, SObject newRecord, Set<String> fieldsToCheck) {
        for (String field : fieldsToCheck) {
            Object oldValue = oldRecord.get(field);
            Object newValue = newRecord.get(field);
            System.debug('field::: ' + field + ', oldValue::: ' + oldValue + ', newValue::: ' + newValue);

            if (oldValue != newValue) {
                return true;
            }
        }
        return false;
    }

    // 필드셋 쿼리 생성 메소드
    @TestVisible
    private String fieldSetQuery(String sObjectName, String fieldSetName, List<SObject> records) {
        List<String> recordIdStrings = new List<String>();
        for (SObject record : records) {
            recordIdStrings.add('\'' + String.valueOf(record.Id) + '\'');
        }
        String recordId = String.join(recordIdStrings, ',');
        System.debug('recordId:::' + recordId);

        List<String> fields = new List<String>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = describeResult.fieldSets.getMap();

        if (fieldSetMap.containsKey(fieldSetName)) {
            Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                fields.add(field.getFieldPath());
            }
        } else {
            throw new IllegalArgumentException('FieldSet ' + fieldSetName + ' not found for object ' + sObjectName);
        }

        return 'SELECT ' + String.join(fields, ', ')+ ', WorkCenter__r.WCCode__c, Id, Name, Account.CountryLookup__r.CountryCode__c, Account.Name, Account.Representative__c, Account.ShippingAddress, Account.ShippingStreet, Account.ShippingPostalCode, Account.ShippingCity, Account.RegionLookup__r.RegionCode__c, Account.Phone, SoldTo__r.CustomerCode__c, Account.CustomerCode__c, MainWorkCtr__r.WCCode__c, Owner.ERP_Key__c, OwnerId' + ' FROM ' + sObjectName + ' WHERE Id IN (' + recordId + ') LIMIT 1';
    }

    public class DN_ERPToAssetQueue implements Queueable, Database.AllowsCallouts {

        private List<Asset> assetList;
        private Map<String, String> statusECUSMap;

        public DN_ERPToAssetQueue(List<Asset> assetList, Map<String, String> statusECUSMap) {
            this.assetList = assetList;
            this.statusECUSMap = statusECUSMap;
        }

        public void execute(QueueableContext context) {
            List<Asset> updateList = new List<Asset>();
            System.debug('I_AG_PARNR : ' + asset.Id);
                List<Asset> assets = [SELECT Id, Account.Name, Account.Representative__c, Account.ShippingStreet, Account.ShippingPostalCode, Account.ShippingCity, Account.CountryLookup__r.CountryCode__c
                , Account.RegionLookup__r.RegionCode__c, Account.Phone, Maintplant__c, WorkCenter__r.WCCode__c, WarrantyStartDateWages__c, WarrantyEndWages__c, WarrantyEnd__c
                , PlanningPlant__c, PlannerGrp__c, MainWorkCtr__r.WCCode__c, OwnerId, Owner.ERP_Key__c, Name, SoldTo__r.CustomerCode__c, Account.CustomerCode__c, InternNoteLong__c
                FROM Asset WHERE Id =:assetList[0].Id];

            for (Asset asset : assets) {
                System.debug('@@' + asset.SoldTo__r.CustomerCode__c);
                
                try {
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Req wrapper_01 = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req();

                    // -------------------------
                    // Address
                    // -------------------------
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ADDRESS temp01_i_address = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ADDRESS();
                    temp01_i_address.NAME1      = asset.Account.Name;
                    temp01_i_address.NAME2      = asset.Account.Representative__c;
                    temp01_i_address.STREET     = asset.Account.ShippingStreet == null ? '' : asset.Account.ShippingStreet;
                    temp01_i_address.POST_CODE1 = asset.Account.ShippingPostalCode == null ? '' : asset.Account.ShippingPostalCode.replace('-', '');
                    temp01_i_address.CITY1      = asset.Account.ShippingCity == null ? '' : asset.Account.ShippingCity;
                    temp01_i_address.COUNTRY    = asset.Account.CountryLookup__r.CountryCode__c;
                    temp01_i_address.REGION     = asset.Account.RegionLookup__r.RegionCode__c;
                    temp01_i_address.TEL_NUMBER = asset.Account.Phone;

                    // -------------------------
                    // Location
                    // -------------------------
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_LOCATION temp01_i_location = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_LOCATION();
                    temp01_i_location.MAINTPLANT = asset.Maintplant__c;
                    temp01_i_location.ARBPL      = asset.WorkCenter__r.WCCode__c == null ? '' : asset.WorkCenter__r.WCCode__c;
                    temp01_i_location.WERKS      = asset.Maintplant__c;

                    // -------------------------
                    // Warranty
                    // -------------------------
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_WARRANTY temp01_i_warranty = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_WARRANTY();
                    temp01_i_warranty.GWLDT   = asset.WarrantyStartDateWages__c == null ? '' : formattingDate(asset.WarrantyStartDateWages__c);
                    temp01_i_warranty.GWLEN   = asset.WarrantyEndWages__c == null ? '' : formattingDate(asset.WarrantyEndWages__c);
                    temp01_i_warranty.V_GWLEN = asset.WarrantyEnd__c == null ? '' : formattingDate(asset.WarrantyEnd__c);

                    // -------------------------
                    // Org
                    // -------------------------
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ORG temp01_i_org = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_ORG();
                    temp01_i_org.PLANPLANT = asset.PlanningPlant__c;
                    temp01_i_org.PLANGROUP = asset.PlannerGrp__c;
                    temp01_i_org.ARBPL     = asset.MainWorkCtr__r.WCCode__c == null ? '' : asset.WorkCenter__r.WCCode__c;
                    temp01_i_org.WERKS     = asset.PlanningPlant__c;

                    // -------------------------
                    // UserInfo
                    // -------------------------
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_USERINFO temp01_i_userInfo = new IF_ERP_Material_Classes.IF_CSPLUS_017_Req_I_USERINFO();
                    temp01_i_userInfo.BNAME = asset.OwnerId;
                    temp01_i_userInfo.RNAME = String.valueOf(asset.Owner.ERP_Key__c);

                    // -------------------------
                    // Wrapper 설정
                    // -------------------------
                    wrapper_01.I_EQUNR           = asset.Name;
                    wrapper_01.I_AG_PARNR        = asset.SoldTo__r.CustomerCode__c == null ? '' : asset.SoldTo__r.CustomerCode__c.leftPad(10, '0'); 
                    wrapper_01.I_WE_PARNR        = asset.Account.CustomerCode__c == null ? '' : asset.Account.CustomerCode__c.leftPad(10, '0');
                    wrapper_01.I_PARTNER_DEL_FLG = asset.SoldTo__r.CustomerCode__c == null && asset.Account.CustomerCode__c == null ? 'X' : '';
                    wrapper_01.I_NOTE            = asset.InternNoteLong__c;
                    wrapper_01.I_STATUS_FLG      = statusECUSMap.get(asset.Id) == null ? '' : statusECUSMap.get(asset.Id);

                    wrapper_01.I_USERINFO        = temp01_i_userInfo;
                    wrapper_01.I_ADDRESS         = temp01_i_address;
                    wrapper_01.I_LOCATION        = temp01_i_location;
                    wrapper_01.I_ORG             = temp01_i_org;
                    wrapper_01.I_WARRANTY        = temp01_i_warranty;

                    // -------------------------
                    // Callout
                    // -------------------------
                    IF_ERP_Material method = new IF_ERP_Material();
                    IF_ERP_Material_Classes.IF_CSPLUS_017_Res response = method.IF_CSPLUS_017(wrapper_01);

                    if (response.O_RETURN.TYPE == 'E') {
                        asset.IsERPUpdate__c   = true;
                        asset.ERPUpdateError__c = response.O_RETURN.MESSAGE;
                        asset.IsECUSCahnge__c  = (statusECUSMap.get(asset.Id) == 'X');
                    } else if (response.O_RETURN.TYPE == '' && response.T_RETURN.size() > 0) {
                        asset.IsERPUpdate__c   = true;
                        asset.ERPUpdateError__c = response.T_RETURN[0].MESSAGE;
                        asset.IsECUSCahnge__c  = (statusECUSMap.get(asset.Id) == 'X');
                    } else if (response.O_RETURN.TYPE == 'S') {
                        asset.IsERPUpdate__c   = false;
                        asset.ERPUpdateError__c = '';
                        asset.IsECUSCahnge__c  = false;
                    }

                } catch (Exception e) {
                    asset.IsERPUpdate__c   = true;
                    asset.ERPUpdateError__c = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
                }

                updateList.add(asset);
            }

            if (!updateList.isEmpty()) {
                TriggerHandler.bypass('AssetTriggerHandler');
                update updateList;
                TriggerHandler.clearBypass('AssetTriggerHandler');
            }
        }

        // 날짜 format
        private String formattingDate(Date dateValue) {
            return Datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day()).format('yyyyMMdd');
        }
    }
}