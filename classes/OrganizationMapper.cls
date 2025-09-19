/**
 * @description       : 
 * @author            : Joohyun Lee
 * @group             : 
 * @last modified on  : 2025-07-23
 * @last modified by  : yeongju.yun
**/
public with sharing class OrganizationMapper {

    String sObjName = '';
    String sObjId   = '';
    OrganizationInformationSetting__mdt mappingSetting;
    Map<String, Object> userMap = new Map<String, Object>();
    private static Boolean isTriggering = false;

    List<OrganizationInformationSetting__mdt> metaList = new List<OrganizationInformationSetting__mdt>();
    Map<String, String> fdMap = new Map<String, String>(); // key : FieldDefinition.DurableId, FieldDefinition.QualifiedApiName


    /**
    * @description sObject와 소유자 정보 기반으로 Office등의 정보 등, Metadata를 준비
    **/
    public OrganizationMapper(List<sObject> news) {

        System.debug('OrganizationMapper');

        try {
            if(!isTriggering || Test.isRunningTest()) {
                sObjName = String.valueOf(news.getSobjectType());

                Boolean isCustomObject = sObjName.endsWith('__c');
                if(isCustomObject) {
                    List<EntityDefinition> entityList = [SELECT DurableId, QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName =:sObjName];
                    sObjId = entityList[0].DurableId;
                }
                
                Map<String, OrganizationInformationSetting__mdt> mappingSettings = OrganizationInformationSetting__mdt.getAll();
                List<String> metaFields = new List<String>();
                
                for(OrganizationInformationSetting__mdt meta : mappingSettings.values()) {
                    if(meta.TargetObject__c == sObjName || meta.TargetObject__c == sObjId) {
                        metaList.add(meta);
                        metaFields.add(meta.TargetField__c);
                    }
                }
                if(!metaFields.isEmpty()) {
                    List<FieldDefinition> fieldList = [SELECT DurableId, QualifiedApiName FROM FieldDefinition WHERE DurableId  =:metaFields];
                    for(FieldDefinition fd : fieldList) {
                        fdMap.put(fd.DurableId, fd.QualifiedApiName);
                    }
                }

                if(!metaList.isEmpty()) {

                        Set<String> OwnerIds = new Set<String>();
                        for(sObject obj : news) {
                            OwnerIds.add(String.valueOf(obj.get('OwnerId')));
                        }
    
                        List<String> adminProfiles = new List<String>{'System Administrator', '시스템 관리자'};
                        
                        List<User> userList = [SELECT Id, SalesOffice__c, SalesOrganization__c, Profile.Name FROM User WHERE Id IN :OwnerIds];
                        if(!userList.isEmpty()) {
                            for(User u : userList) {
                                // 250417 yeongju.yun Admin이 Owner일때는 Office, Org등 정보 업데이트 X
                                if(adminProfiles.contains(u.Profile.Name)) continue;
                                userMap.put(u.Id, u);
                            }
                        }
                }
            }
        } catch(Exception e) {
            System.debug('OrganizationMapper- Exception ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
    }

    /**
    * @description Owner가 Admin이 아닌 경우, Owner의 데이터 Mapping
    **/
    public void mappingField(List<sObject> news) {
        try {
            if(!isTriggering) {
                if(!metaList.isEmpty() || Test.isRunningTest()) {

                    for(sObject obj : news) {
                        User u = (User) userMap.get(String.valueOf(obj.get('OwnerId')));
                        if(u != null) {
                            for(OrganizationInformationSetting__mdt meta : metaList) {
                                obj.put(fdMap.get(meta.TargetField__c), u.get(meta.UserField__c) != null ? u.get(meta.UserField__c) : '');
                            }
                        }
                    }
                }
                isTriggering = true;
            }
        } catch (Exception e) {
            System.debug('OrganizationMapper- mappingField ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
    }

    /**
    * @description Owner 변경 시 변경 된 Owner 기반으로 업데이트
    **/
    public void mappingField(List<sObject> news, Map<Id, SObject> oldMap) {
        try {
            if(!isTriggering || Test.isRunningTest()) {
                if(!metaList.isEmpty() || Test.isRunningTest()) {
                    for(sObject obj : news) {
                        SObject oldObj    = oldMap.get(String.valueOf(obj.get('Id')));

                        // Owner 필드가 존재하는 경우
                        if(obj.getSObjectType().getDescribe().fields.getMap().containsKey('OwnerId')) { // 250311 yeongju.yun
                            String ownerId    = String.valueOf(obj.get('OwnerId'));
                            String oldOwnerId = String.valueOf(oldObj.get('OwnerId'));

                            // Owner 변경 했을 경우
                            if(!oldOwnerId.equals(ownerId)) {
                                User u = (User) userMap.get(ownerId);
                                if(u != null) {
                                    for(OrganizationInformationSetting__mdt meta : metaList) {
                                        obj.put(fdMap.get(meta.TargetField__c), u.get(meta.UserField__c) != null ? u.get(meta.UserField__c) : '');
                                    }
                                }
                            }
                        } else {
                            break;
                        }
                    }
                    isTriggering = true;
                }
            }
        } catch (Exception e) {
            System.debug('OrganizationMapper- mappingField ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
    }
}