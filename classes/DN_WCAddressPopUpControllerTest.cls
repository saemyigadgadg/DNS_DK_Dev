@isTest
public with sharing class DN_WCAddressPopUpControllerTest {
    @TestSetup
    static void makeData(){
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);

        OperatingHours oh = new OperatingHours();
        oh.Name     = '대한민국 표준 작업 시간';
        oh.TimeZone = 'Asia/Seoul';
        insert oh;

        ServiceTerritory wc = new ServiceTerritory();
        wc.Name                 = 'MCT서비스';
        wc.ServiceWorkCenter__c = acc.Id;
        wc.OperatingHoursId     = oh.Id;
        wc.classify__c          = 'W/C';
        wc.WCCode__c            = '11001620';
        wc.IsActive             = true;
        insert wc;
    }

    @isTest
    static void getAddressTest(){
        InterfaceCommonUtil.setInterface('MOIS_ADDRESS', 'IF_MOIS_ADDRESS', 'SUCCESS');

        Test.startTest();
        try {
            DN_WCAddressPopUpController.getAddress('대왕판교로', 1);
            DN_WCAddressPopUpController.getAddress('',0);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void setAddressTest(){
        InterfaceCommonUtil.setInterface('MOIS_ADDRESS', 'IF_MOIS_ADDRESS', 'SUCCESS');
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Map<String, Object> addressMap = new Map<String, Object>{
            'roadAddr'  => 'New Road Address',
            'zipNo'     => '67890',
            'siNm'      => 'New City',
            'sggNm'     => 'New District'
        };
        String detailInfo = 'Apt 101';

        Test.startTest();
        try {
            DN_WCAddressPopUpController.setAddress(st.Id, addressMap, detailInfo);
            DN_WCAddressPopUpController.setAddress('', addressMap, detailInfo);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}