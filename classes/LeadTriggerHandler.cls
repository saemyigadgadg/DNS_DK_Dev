/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-12
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-07   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class LeadTriggerHandler extends TriggerHandler {

    private static final Id   dnsLeadRT             = SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('DNS').getRecordTypeId();
    private static final Id   dnsaLeadRT            = SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

    private static final Id   prospectCustomerRT    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id   dnsaCustomerRT        = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();


    // for Web-to-lead Country. (Coutry에 정의되지 않은 값이 들어올 경우, 'Etc'로 입력)
    public override void onBeforeInsert(List<sObject> news) {
        try {
            if (isExecuting) {
                System.debug('Lead BEFORE_INSERT TRIGGER Start');
    
                List<Lead> leadList = (List<Lead>) news;
                Set<Id> ownerIds = new Set<Id>();
    
                // Country 필드의 유효한 Picklist 값 가져오기
                Set<String> validCountries = new Set<String>();
                Schema.DescribeFieldResult countryField = Lead.Country__c.getDescribe();
                System.debug('countryField :: ' + countryField );
                for (Schema.PicklistEntry entry : countryField.getPicklistValues()) {
                    validCountries.add(entry.getValue());
                }
    
                // Country 값 검증 및 수정
                for (Lead lead : leadList) {
                    System.debug('lead :: ' + lead );
                    System.debug('lead.IsWebtoLead__c :: ' + lead.IsWebtoLead__c );

                    // 추가: Lead 생성 시 Status가 "New"가 아니면 에러 발생
                    if (lead.Status != 'New') {
                        // Lead 생성 시 Status는 "New"여야 합니다.
                        lead.addError(System.Label.DNS_M_LeadIsNew);

                    }

                    if (lead.IsWebtoLead__c && 
                        (String.isBlank(lead.Country__c) || !validCountries.contains(lead.Country__c))) {
                            lead.Country_Etc__c = lead.Country__c;
                            System.debug('lead.Country_Etc__c :: ' + lead.Country_Etc__c );
                            if(!String.isBlank(lead.Country_Etc__c)){
                                lead.Country__c = 'Etc'; // Country 값이 비어있거나 잘못된 경우 기본값 설정
                                System.debug('lead.Country__c :: ' + lead.Country__c );

                            }
                            System.debug('Country is invalid or blank. Setting to "Etc" for Lead Id');
                    }
                }

                insertSalseAreaData(leadList);
    
                System.debug('Lead BEFORE_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            handleException(e);
        }
    }
    


    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        try {
            if (isExecuting) {
                System.debug('Lead AFTER_UPDATE TRIGGER Start');

                List<Lead> leadList = (List<Lead>) news;
                Map<Id, Lead> oldLeadMap = (Map<Id, Lead>) oldMap;

                for (Lead newLead : leadList) {
                    Lead oldLead = oldLeadMap.get(newLead.Id);
                    boolean isConvertedChanged = oldLead.IsConverted != newLead.IsConverted && newLead.IsConverted;
                    
                    if (isConvertedChanged) {
                        updateLeadEvent(leadList);
                        updateAccRecordType(leadList);
                    }
                }

                setting(false, TriggerOperation.AFTER_UPDATE);
                System.debug('Lead AFTER_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            handleException(e);
        }
    }


    /**
     * @Description
     * 	- Lead의 Owner가 딜러로 변경되었을 때, 그 딜러의 Sales Area정보를 Lead에 Update
     *  - Lead를 변환할 때, IsConvertInfoFilled__c가 false이면 에러 발생
     * @author Yuhyun Park | 01-09-2025
    **/ 
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        try {
            if (isExecuting) {
                System.debug('Lead BEFORE_UPDATE TRIGGER Start');

                // OwnerId 리스트 및 User 필드 매핑용 Map
                List<Id> ownerIds = new List<Id>(); 
                Map<Id, Map<String, String>> userDetailsMap = new Map<Id, Map<String, String>>(); 
                List<Lead> leadList = (List<Lead>) news;
    
                for (Lead newLead : leadList) {
                    Lead oldLead = (Lead) oldMap.get(newLead.Id);

                    // Lead의 Owner 변경 여부 확인
                    if (oldLead.OwnerId != newLead.OwnerId) {
                        System.debug('Owner Changed for Lead Id: ' + newLead.Id);
                        ownerIds.add(newLead.OwnerId); // 변경된 OwnerId 추가
                    }

                    // Convert 방지 : 변환하기 위한 필수 값 입력 확인 (for 딜러포탈) IsConvertInfoFilled__c
                    if (oldLead.IsConverted != newLead.IsConverted && newLead.IsConverted == true) {
                        if (newLead.IsConvertInfoFilled__c != true) {
                            // 에러 발생: 필수 값이 누락되었습니다.
                            newLead.addError(System.Label.DNS_M_CheckLeadRequired);
                        }
                        
                        if (newLead.IsERPValidated__c != true) {
                            // 에러 발생: Validate 버튼을 클릭해서 검증을 먼저 진행해주세요.
                            newLead.addError(System.Label.DNS_M_CheckLeadERPValid);
                        }
                    }

                    // 기존에 ERP 검증이 완료된 상태에서 Company 또는 Representative__c가 변경되면 IsERPValidated__c를 false로 업데이트
                    if (oldLead.IsERPValidated__c == true && (oldLead.Company != newLead.Company || oldLead.Representative__c != newLead.Representative__c)) {
                        newLead.IsERPValidated__c = false;
                        System.debug('Reset IsERPValidated__c to false for Lead Id: ' + newLead.Id);
                    }

                }
    
                // OwnerId가 있는 경우 해당 User의 관련 필드 조회
                if (!ownerIds.isEmpty()) {
                    List<User> userList = [
                        SELECT Id, 
                               SalesOrganization__c, 
                               SalesDistrict__c, 
                               SalesOffice__c, 
                               DistributionChannel__c, 
                               Division__c 
                        FROM User 
                        WHERE Id IN :ownerIds
                    ];
                    for (User user : userList) {
                        Map<String, String> userFields = new Map<String, String>();
                        userFields.put('SalesOrganization__c'   , user.SalesOrganization__c);
                        userFields.put('SalesDistrict__c'       , user.SalesDistrict__c);
                        userFields.put('SalesOffice__c'         , user.SalesOffice__c);
                        userFields.put('DistributionChannel__c' , user.DistributionChannel__c);
                        userFields.put('Division__c'            , user.Division__c);
                        userDetailsMap.put(user.Id, userFields);
                    }
                }
    
                // Lead의 필드 업데이트
                for (Lead newLead : leadList) {
                    if (userDetailsMap.containsKey(newLead.OwnerId)) {
                        Map<String, String> userFields  = userDetailsMap.get(newLead.OwnerId);
                        newLead.SalesOrganization__c    = userFields.get('SalesOrganization__c');
                        newLead.SalesDistrict__c        = userFields.get('SalesDistrict__c');
                        newLead.SalesOffice__c          = userFields.get('SalesOffice__c');
                        newLead.DistributionChannel__c  = userFields.get('DistributionChannel__c');
                        newLead.Division__c             = userFields.get('Division__c');
                        System.debug('Updated Lead Id: ' + newLead.Id + ' with Owner fields.');
                    }
                }
                System.debug('Lead BEFORE_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            handleException(e);
        }
    }



    /**
     * @Description
     * 	- Lead가 Conveted일 때, 연결된 Lead Event에 Conveted된 AccountId와 ContactId 전송
     * @author Yuhyun Park | 11-07-2024
     * @Parameter
     *  - news       : Converted Lead List
    **/ 
    private void updateLeadEvent(List<Lead> newLeads) {

        System.debug('newLeads in updateLeadEvent :: ' + newLeads);

        Set<Id> leadIdSet = new Map<Id, Lead>(newLeads).keySet();

        if (!leadIdSet.isEmpty()) {
            List<LeadEvent__c> leadEventList = [
                SELECT Id, Lead__c, Account__c, Contact__c
                FROM LeadEvent__c
                WHERE Lead__c IN :leadIdSet
            ];

            Map<Id, Lead> leadMap = new Map<Id, Lead>(newLeads);
            List<LeadEvent__c> leadEventToUpdate = new List<LeadEvent__c>();

            if(!leadEventList.isEmpty()){
                for (LeadEvent__c leadEvent : leadEventList) {
                    Lead lead = leadMap.get(leadEvent.Lead__c);
    
                    if (lead != null) {
                        leadEvent.Account__c = lead.ConvertedAccountId;
                        leadEvent.Contact__c = lead.ConvertedContactId;
                        leadEventToUpdate.add(leadEvent);
                    }
                }
    
                if (!leadEventToUpdate.isEmpty()) {
                    update leadEventToUpdate;
                }
            }
        }
    }

    /**
     * @Description
     * 	- DNS   : Lead가 Conveted일 때, 생성된 Account의 Record Type을 항상 Prospect Customer로 업데이트 
     * 	- DNSA  : Lead가 Conveted일 때, 생성된 Account의 Record Type을 항상 DNSA Customer로 업데이트 
     * @author Yuhyun Park | 11-20-2024
     * @Parameter
     *  - news       : Converted Lead List
    **/ 
    private void updateAccRecordType(List<Lead> newLeads) {

        System.debug('newLeads in updateAccRecordType :: ' + newLeads);

        Set<Id> accIdSet = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();

        for(Lead lead : newLeads){
            if(lead.ConvertedAccountId != null){
                accIdSet.add(lead.ConvertedAccountId);
            }
        }

        if (!accIdSet.isEmpty()) {
            List<Account> targetAccList = [SELECT Id, RecordTypeId FROM Account WHERE Id IN :accIdSet];
    
            if (!targetAccList.isEmpty()) {
                for (Account acc : targetAccList) {
                    for (Lead lead : newLeads) {
                        if (lead.ConvertedAccountId == acc.Id) {

                            // Lead의 RecordType에 따라 Account의 RecordType 업데이트
                            if (lead.RecordTypeId == dnsLeadRT && acc.RecordTypeId != prospectCustomerRT) {
                                acc.RecordTypeId = prospectCustomerRT;

                            } else if (lead.RecordTypeId == dnsaLeadRT && acc.RecordTypeId != dnsaCustomerRT) {
                                acc.RecordTypeId = dnsaCustomerRT;
                            }
                            accToUpdate.add(acc);
                            break;  // 중복 작업 방지~
                        }
                    }
                }
    
                if (!accToUpdate.isEmpty()) {
                    update accToUpdate;
                    System.debug('Accounts updated: ' + accToUpdate);
                }
            }
        }
    }


    /**
     * @Description
     * 	-  Owner의 Sales Area Data 값을 조회하여 Lead의 Sales Area Data 필드에 할당하는 메서드.
     * @author Yuhyun Park | 03-24-2025
     * @Parameter
     *  - news       : Converted Lead List
    **/ 
    private void insertSalseAreaData(List<Lead> leadList) {

        Set<Id> ownerIds = new Set<Id>();
    
        for (Lead lead : leadList) {
            if (lead.OwnerId != null) {
                ownerIds.add(lead.OwnerId);
            }
        }
        
        if (!ownerIds.isEmpty()) {
            Map<Id, User> userMap = new Map<Id, User>(
                [SELECT Id, SalesOrganization__c, SalesDistrict__c, DistributionChannel__c, SalesOffice__c, Division__c FROM User WHERE Id IN :ownerIds]
            );

            for (Lead lead : leadList) {
                if (userMap.containsKey(lead.OwnerId)) {
                    lead.SalesOrganization__c   = userMap.get(lead.OwnerId).SalesOrganization__c;
                    lead.SalesDistrict__c       = userMap.get(lead.OwnerId).SalesDistrict__c;
                    lead.DistributionChannel__c = userMap.get(lead.OwnerId).DistributionChannel__c;
                    lead.SalesOffice__c         = userMap.get(lead.OwnerId).SalesOffice__c;
                    lead.Division__c            = userMap.get(lead.OwnerId).Division__c;
                }
            }
        }
    }



    /**
     * @description - Handles and logs exceptions.
     */
    private void handleException(Exception e) {
        System.debug('Error : ' + e.getMessage());
        System.debug('Line Number : ' + e.getLineNumber());
        throw new AuraHandledException(e.getMessage());
    }
}