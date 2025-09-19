/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   10-22-2024   Hanyeong Choi   Initial Version
 * 1.1   03-12-2025   Hyunwook Jin    대리점재고관리의 대리점 고객 SalesAreaData 조직정보로 생성할 수 있게 로직변경
**/
public with sharing class SalesAreaDataTriggerHandler extends TriggerHandler {
    private static final User currentUser = setCurrentUser();

    /**
     * SalesAreaData__c 레코드 삽입 후, 계정 조직 정보를 업데이트하고 대리점 고객 정보를 삽입합니다.
     */
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting) {

            if(TriggerHandler.isBypassed('SalesAreaDataTriggerHandler')) {
                System.debug('<< Bypass SalesAreaDataTriggerHandler >> ');
                return;
            }

            System.debug('SalesAreaData AFTER_INSERT TRIGGER Start');
            List<SalesAreaData__c>  sadList = (List<SalesAreaData__c>) news;
            Set<Id>                 accIds  = new Set<Id>();
            
            for(SalesAreaData__c sad : sadList) {
                accIds.add(sad.Account__c);
            }
            // 2025-02-04 대리점 재고관리 테이블에 Account정보를 적재하기 위해 메소드 추가
            insertDealerCustomer(sadList);


            if(!accIds.isEmpty()) updateAccOrganization(accIds);

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('SalesAreaData AFTER_INSERT TRIGGER End');
        }
    }

    /**
     * SalesAreaData__c 레코드 업데이트 전, SalesOffice__c 변경 시 ERP를 통해 검증합니다.
     */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting){
            System.debug('SalesAreaData BEFORE_UPDATE TRIGGER Start');
            List<SalesAreaData__c> sadList = (List<SalesAreaData__c>) news;
            List<SalesAreaData__c> updateSOList = new List<SalesAreaData__c>();
            
            for(SalesAreaData__c sad : sadList) {
                if(oldMap.get(sad.Id).get('SalesOffice__c') != sad.SalesOffice__c) {
                    updateSOList.add(sad);
                }
            }

            
            if(!updateSOList.isEmpty()) {
                // if(!Test.isRunningTest()) System.enqueueJob(new updateSadQueueable(updateSOList));
                System.enqueueJob(new updateSadQueueable(updateSOList));
            }

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('SalesAreaData BEFORE_UPDATE TRIGGER End');
        }
    }

    /**
     * SalesAreaData__c 레코드 업데이트 후, 계정의 조직 및 SalesOffice 정보를 업데이트합니다.
     */
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SalesAreaData AFTER_UPDATE TRIGGER Start');
            List<SalesAreaData__c>  sadList = (List<SalesAreaData__c>) news;
            Set<Id>                 accIds  = new Set<Id>();
            Set<Id>                 officeAccIds  = new Set<Id>();

            for(SalesAreaData__c sad : sadList) {
                if(oldMap.get(sad.Id).get('SalesOrganization__c') != sad.SalesOrganization__c) {
                    accIds.add(sad.Account__c);
                }
                if(oldMap.get(sad.Id).get('SalesOffice__c') == null && sad.SalesOffice__c != null) {
                    officeAccIds.add(sad.Account__c);
                }
            }
            if(!accIds.isEmpty()) updateAccOrganization(accIds);
            if(!officeAccIds.isEmpty()) updateAccOffice(officeAccIds, sadList);

            // 2025-03-12 대리점 재고관리 테이블에 Account정보를 적재하기 위해 메소드 추가 
            // 테스트용으로 강제적으로 수행하기 위해 추가
            // insertDealerCustomer(sadList);

            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('SalesAreaData AFTER_UPDATE TRIGGER End');
        }
    }

    /**
     * SalesAreaData__c 레코드 삭제 후, 계정의 조직 정보를 업데이트합니다.
     */
    public override void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if(isExecuting) {
            System.debug('SalesAreaData AFTER_DELETE TRIGGER Start');
            List<SalesAreaData__c>  sadList = (List<SalesAreaData__c>) dels;
            Set<Id>                 accIds  = new Set<Id>();

            for(SalesAreaData__c sad : sadList) {
                accIds.add(sad.Account__c);
            }
            if(!accIds.isEmpty()) updateAccOrganization(accIds);
            
            setting(false, TriggerOperation.AFTER_DELETE);
            System.debug('SalesAreaData AFTER_DELETE TRIGGER End');
        }
    }

    /**
     * 계정의 조직 정보를 업데이트합니다.
     */
    private static void updateAccOrganization(Set<Id> accIds) {
        List<Account> accList = [
            SELECT  Id,
                    SharingSalesOrganization__c,
                    SalesOrganization__c,
                    SalesOrganization_CS__c,
                    SalesOffice__c,
                    (
                        SELECT SalesOrganization__c, SalesOffice__c
                        FROM SalesAreaData__r
                    )
            FROM Account
            WHERE Id IN :accIds
        ];

        if(!accList.isEmpty()) {
            List<Account> updateAccList = new List<Account>();
            
            for(Account acc : accList) {
                acc.SharingSalesOrganization__c = null;
                
                if(!acc.SalesAreaData__r.isEmpty()) {
                    for(SalesAreaData__c sad : acc.SalesAreaData__r) {

                        if (sad.SalesOrganization__c == '1800') {
                            acc.SalesOrganization__c = sad.SalesOrganization__c;
                            acc.SalesOffice__c = sad.SalesOffice__c;
                        }

                        if(sad.SalesOrganization__c == '1846') {
                            acc.SalesOrganization_CS__c = '1846';
                        }

                        if(acc.SharingSalesOrganization__c == null) {
                            acc.SharingSalesOrganization__c = sad.SalesOrganization__c;
                        }

                        if(!acc.SharingSalesOrganization__c.contains(sad.SalesOrganization__c)) {
                            acc.SharingSalesOrganization__c += ',' + sad.SalesOrganization__c;
    
                            if(acc.SharingSalesOrganization__c.startsWith(',')) {
                                acc.SharingSalesOrganization__c = acc.SharingSalesOrganization__c.substring(1);
                            }
                        }
                    }
                }
                updateAccList.add(acc);
            }
            if(!updateAccList.isEmpty()) update updateAccList;
        }
        return;
    }

    /**
     * 계정의 SalesOffice 정보를 업데이트합니다.
     */
    private static void updateAccOffice(Set<Id> officeAccIds, List<SalesAreaData__c> sadList) {
        List<Account> accList = [
            SELECT  Id,
                    SharingSalesOrganization__c,
                    SalesOrganization__c,
                    SalesOffice__c
            FROM Account
            WHERE Id IN :officeAccIds
        ];

        if(!accList.isEmpty()) {
            List<Account> updateAccList = new List<Account>();
            for(SalesAreaData__c sad : sadList) {
                for(Account acc : accList) {
                    if(acc.Id == sad.Account__c && sad.SalesOrganization__c == '1846') {
                        acc.SalesOffice__c = sad.SalesOffice__c;
                        updateAccList.add(acc);
                    }
                }
            }
            if(!updateAccList.isEmpty()) update updateAccList;
        }
        return;
    }

    /**
     * 현재 사용자 정보를 설정합니다.
     */
    private static User setCurrentUser() {
        Id loginUserId = UserInfo.getUserId();
        User loginUser = [
            SELECT id
                    , Name
                    , Username
                    , IsPortalEnabled
                    , AccountId
                    , ContactId
                    , SalesOrganization__c
                    , DistributionChannel__c
                    , Division__c
                    , SalesDistrict__c
                    , SalesOffice__c
                    , FM_ProfileName__c
                    , Profile.Name
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        return loginUser;
    }

    /**
     * @Description
     * 	- KDGRP - 02이며 , 레코드타입이 딜러인 경우 대리점 재고관리에서 사용하는 DealerCustomer__c에 적재하는 메소드
     * @author iltae seo | 2025-02-04
     * @Parameter
     *  - List<SalesAreaData__c>       : SalesAreaData List
    **/ 
    private static void insertDealerCustomer(List<SalesAreaData__c> salesAreaDataList) {
        set<String> salesAreaIds = new set<String>();
        for(SalesAreaData__c salesArea : salesAreaDataList) {
            salesAreaIds.add(salesArea.Id);
        }
        List<SalesAreaData__c> areaDataSetList = [
            SELECT  Id
            , Account__r.CustomerCode__c 
            , Account__r.Name
            , Account__r.AccountNameEnglish__c
            , Account__r.SalesOrganization__c
            , Account__r.DistributionChannel__c
            , Account__r.Division__c
            , Account__r.BusinessNumber__c
            , Account__r.sggNm__c
            , Account__r.Phone
            , Account__r.Representative__c
            , Account__r.TypeOfBusiness__c
            , Account__r.TypeOfIndustry__c
            , Account__r.ShippingStreet
            , Account__r.ShippingPostalCode
            , Account__r.ShippingCity
            , Account__r.DetailAddress__c
            , Account__c
            , SalesOrganization__c
            , DistributionChannel__c
            , Division__c
            , CustomerGroup__c
            , SalesOffice__c
            , SalesDistrict__c
            , Currency__c
            , ShipToParty__c
            , BillToParty__c
            , SoldToParty__c
            , Payer__c
            FROM    SalesAreaData__c
            where CustomerGroup__c ='02'
            AND SalesOrganization__c = '1846'   //TODO: 부품대리점 조직정보 변경시 변경해야함.
            AND Account__r.RecordType.DeveloperName ='Dealer'
            AND Id IN :salesAreaIds
        ];
        Map<String, Account> accountMap = new Map<String,Account>();
        for(SalesAreaData__c sales : areaDataSetList) {
            Account partsDealer = (Account)sales.getSObject('Account__r');
            partsDealer.SalesOrganization__c = sales.SalesOrganization__c; // 부품대리점 조직정보로 변경
            partsDealer.DistributionChannel__c = sales.DistributionChannel__c;
            partsDealer.Division__c = sales.Division__c;

            if(!accountMap.containsKey(partsDealer.Id)) {
                accountMap.put(partsDealer.Id, partsDealer);
            }
        }

        if(accountMap.size() > 0)
            DN_DealerCustomerAgencyController.insertAgency(accountMap.values());
    }

    /**
     * SalesAreaData__c 레코드의 SalesOffice 정보를 ERP 시스템을 통해 검증하고 업데이트합니다.
     */
    public class updateSadQueueable implements Queueable, Database.AllowsCallouts{
        private List<SalesAreaData__c> updateSadList;

        public updateSadQueueable(List<SalesAreaData__c> updateSadList) {
            this.updateSadList = updateSadList;
        }

        public void execute(QueueableContext context) {

            List<SalesAreaData__c> finalUpdateList = new List<SalesAreaData__c>();
            Set<Id> accIds = new Set<Id>();
            
            for( SalesAreaData__c sad : updateSadList){
                if(sad.Account__c != null){
                    accIds.add(sad.Account__c);
                }
            }

            Map<Id, Account> accMap = new Map<Id, Account>([
                SELECT  Id, CustomerCode__c
                FROM    Account
                WHERE   Id IN :accIds
            ]);


            for (SalesAreaData__c sad : updateSadList) {
                
                IF_ERP_Account_Classes.IF_ACCOUNT_019_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_019_Req();
                IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_AREA I_SALES_AREA = new IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_AREA();
                IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_DETAIL I_SALES_DETAIL = new IF_ERP_Account_Classes.IF_ACCOUNT_019_Req_I_SALES_DETAIL();

                if(accMap.containsKey(sad.Account__c)){
                    erpParameters.I_KUNNR = accMap.get(sad.Account__c).CustomerCode__c;

                    I_SALES_AREA.VKORG          = sad.SalesOrganization__c;
                    I_SALES_AREA.VTWEG          = sad.DistributionChannel__c;
                    I_SALES_AREA.SPART          = sad.Division__c;
                    I_SALES_DETAIL.VKBUR        = sad.SalesOffice__c;

                    I_SALES_DETAIL.BZIRK        = sad.SalesDistrict__c;
                    I_SALES_DETAIL.KALKS        = sad.CustPricProc__c;
                    I_SALES_DETAIL.KDGRP        = sad.CustomerGroup__c;
                    I_SALES_DETAIL.WAERS        = sad.CurrencyIsoCode;
    
                    erpParameters.I_SALES_AREA = I_SALES_AREA;
                    erpParameters.I_SALES_DETAIL = I_SALES_DETAIL;

                    IF_ERP_Account erpService = new IF_ERP_Account();
                    IF_ERP_Account_Classes.IF_ACCOUNT_019_Res erpResponse = erpService.IF_ACCOUNT_019(erpParameters);
    
                    if(erpResponse.O_RETURN.TYPE == 'S'){
                        System.debug('Sales Area Data Sales Office Update Success !');
                        finalUpdateList.add(sad);
                    }else{
                        sad.addError('ERP validation failed: ' + (erpResponse.O_RETURN.MESSAGE != null ? erpResponse.O_RETURN.MESSAGE : 'Unknown error'));
                    }
                } else {
                    System.debug('Error : Not match Account');
                }

            }

            if(!finalUpdateList.isEmpty()){
                update finalUpdateList;
                System.debug('SalesAreaData Trigger : updateSadQueueable Executed');
            }
        }
    }
}