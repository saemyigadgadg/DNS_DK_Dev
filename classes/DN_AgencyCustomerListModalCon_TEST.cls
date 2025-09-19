/** 
 * @Class :  DN_AgencyCustomerListModalCon_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 18. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-18 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_AgencyCustomerListModalCon_TEST {
    
    @TestSetup
    static void makeData(){
        
        
        String adminProfile = UserInfo.getLanguage() == 'ko' ? '시스템 관리자' : 'System Administrator';
        User adminTestUser = createTestUser(adminProfile, 'CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        insert adminTestUser;

        System.runAs(adminTestUser) {
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            Sequence__c seq1 = new Sequence__c(
                Name ='DealerCustomer_Dealer',
                Type__c = 'Dealer', 
                Pattern__c = '1{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq1);

            Sequence__c seq2 = new Sequence__c(
                Name ='DealerCustomer_Customer',
                Type__c = 'Customer', 
                Pattern__c = '5{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq2);
            insert sequenceList;

            SchemaInfo schemaInfo = new SchemaInfo('Account');
            Schema.RecordTypeInfo recordTypeInfo = schemaInfo.getRecordTypeByDeveloperName('Dealer');
            Account dealer = new Account(
                RecordTypeId = recordTypeInfo.getRecordTypeId(),
                Name = 'Dealer1'
            );
            insert dealer;

            DealerCustomer__c customerByTypeDealer = new DealerCustomer__c(
                SalesOrganization__c = '1846',
                DistributionChannel__c = '10',
                Division__c = '40',
                Name = dealer.Name,
                SourceAccount__c = dealer.Id,
                RoadAddr__c = '도로명 주소',
                DetailInfo__c = '상세 주소',
                IsDealer__c = true,
                IsActive__c = true
            );
            insert customerByTypeDealer;

            DealerCustomerShipTo__c customerShipToByTypeDealer = new DealerCustomerShipTo__c(
                Customer__c = customerByTypeDealer.Id,
                RoadAddr__c = '도로명 주소',
                DetailInfo__c = '상세 주소',
                IsDealer__c = true
            );
            insert customerShipToByTypeDealer;
        }

    }

        /**
     * @description 테스트 User를 생성하는 메서드
     * @param profileName - 할당할 Profile의 이름
     * @param roleName - 할당할 Role의 이름 (옵션)
     * @return 생성된 User 객체
     */
    public static User createTestUser(String profileName, String roleName) {
        // Profile 조회
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];

        // Role 설정 (Optional)
        Id roleId = null;
        if (roleName != null) {
            UserRole role = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
            roleId = role != null ? role.Id : null;
        }

        // 테스트 User 생성
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US',
            UserRoleId = roleId
        );

        return testUser;
    }

    @isTest
    static void getAgencyList_TEST() {
        DN_AgencyCustomerListModalController.SearchParams params = new DN_AgencyCustomerListModalController.SearchParams();

        Test.startTest();
        //Dealer
        params.customerName = '';
        params.customerCode = '';
        params.type         = 'dealer';

        Map<String,Object> dealerResult = DN_AgencyCustomerListModalController.getAgencyList('', params);

        //Customer
        params.customerName = '';
        params.customerCode = '';
        params.type         = 'customer';

        Map<String,Object> customerResult = DN_AgencyCustomerListModalController.getAgencyList('', params);

        //Seller
        params.customerName = '';
        params.customerCode = '';
        params.type         = 'seller';

        Map<String,Object> sellerResult = DN_AgencyCustomerListModalController.getAgencyList('', params);

        Test.stopTest();
    }
}