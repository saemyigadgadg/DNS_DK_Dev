/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-19-2025   Hanyeong Choi   Initial Version
**/
@isTest 
public with sharing class DN_DeviceManagerBatch_TEST {
    @TestSetup static void setup() { // Create Users 
        User thisUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
        List<User> users = new List<User>(); 
        System.runAs(thisUser) { 
            User u1 = TestDataFactoryForSales.createDNSUser(thisUser.Profile.Name, 'KA'); 
            u1.Portal_EmployeeNumber__c = 'EMP001'; 
            u1.Email = 'emp001@test.com'; 
            users.add(u1);
            User u2 = TestDataFactoryForSales.createDNSUser(thisUser.Profile.Name, 'KA');
            u2.Portal_EmployeeNumber__c = 'EMP002';
            u2.Email = 'emp002@test.com';
            users.add(u2);

            User u3 = TestDataFactoryForSales.createDNSUser(thisUser.Profile.Name, 'KA');
            u3.Portal_EmployeeNumber__c = 'EMP003';
            u3.Email = 'emp003@test.com';
            users.add(u3);

            User u4 = TestDataFactoryForSales.createDNSUser(thisUser.Profile.Name, 'KA');
            u4.Portal_EmployeeNumber__c = 'EMP004';
            u4.Email = 'emp004@test.com';
            users.add(u4);

            User u5 = TestDataFactoryForSales.createDNSUser(thisUser.Profile.Name, 'KA');
            u5.Portal_EmployeeNumber__c = 'DEP001';
            u5.Email = 'dep001@test.com';
            users.add(u5);

            User u6 = TestDataFactoryForSales.createDNSUser(thisUser.Profile.Name, 'KA');
            u6.Portal_EmployeeNumber__c = 'DEP002';
            u6.Email = 'dep002@test.com';
            users.add(u6);

            insert users;
        }

        // Create Model__c
        List<Model__c> models = new List<Model__c>();
        models.add(new Model__c(Name = 'Model1', MaterialCode__c = 'MOD001'));
        models.add(new Model__c(Name = 'Model2', MaterialCode__c = 'MOD002'));
        models.add(new Model__c(Name = 'Model3', MaterialCode__c = 'MOD003'));
        insert models;

        // Create Product2
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Product1', Model__c = models[0].Id));
        products.add(new Product2(Name = 'Product2', Model__c = models[1].Id));
        products.add(new Product2(Name = 'Product3', Model__c = models[2].Id));
        insert products;

        // Create Existing Product_Representative__c
        Product_Representative__c pr = new Product_Representative__c(
            Model__c = models[0].Id,
            User__c = users[0].Id,
            ControlUser__c = users[1].Id,
            MachineEmail__c = 'emp001@test.com',
            ControlEmail__c = 'emp002@test.com',
            MachineTeam__c = 'Team1',
            ControlTeam__c = 'Team2'
        );
        insert pr;

        // Create IF_DeviceManager__c
        List<IF_DeviceManager__c> ifDevices = new List<IF_DeviceManager__c>();
        
        // Normal Case (WERKS__c = 1840, MOD001)
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD001',
            MAKTX__c = 'Model1',
            WERKS__c = '1840',
            EMPNO_RD1__c = 'EMP001',
            EMPNM_RD1__c = 'User1',
            EPMAIL_RD1__c = 'emp001@test.com',
            DEPNM_RD1__c = 'Team1',
            DEPNO_RD1__c = 'DEP001',
            DPMAIL_RD1__c = 'dep001@test.com',
            EMPNO_RD2__c = 'EMP002',
            EMPNM_RD2__c = 'User2',
            EPMAIL_RD2__c = 'emp002@test.com',
            DEPNM_RD2__c = 'Team2',
            DEPNO_RD2__c = 'DEP002',
            DPMAIL_RD2__c = 'dep002@test.com',
            EMPNO_RD3__c = 'EMP003',
            EMPNM_RD3__c = 'User3',
            EPMAIL_RD3__c = 'emp003@test.com',
            DEPNM_RD3__c = 'Team3',
            DEPHD_RD3__c = 'DEP001',
            EMPNO_RD4__c = 'EMP004',
            EMPNM_RD4__c = 'User4',
            EPMAIL_RD4__c = 'emp004@test.com',
            DEPNM_RD4__c = 'Team4',
            DEPHD_RD4__c = 'DEP002',
            IsConverted__c = false
        ));

        // Duplicate SATNR__c (WERKS__c = 1842, MOD001)
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD001',
            MAKTX__c = 'Model1',
            WERKS__c = '1842',
            EMPNO_RD1__c = 'EMP001',
            EMPNM_RD1__c = 'User1',
            EPMAIL_RD1__c = 'emp001@test.com',
            DEPNM_RD1__c = 'Team1',
            DEPNO_RD1__c = 'DEP001',
            DPMAIL_RD1__c = 'dep001@test.com',
            IsConverted__c = false
        ));

        // Normal Case (WERKS__c = 1842, MOD002)
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD002',
            MAKTX__c = 'Model2',
            WERKS__c = '1842',
            EMPNO_RD1__c = 'EMP003',
            EMPNM_RD1__c = 'User3',
            EPMAIL_RD1__c = 'emp003@test.com',
            DEPNM_RD1__c = 'Team3',
            DEPNO_RD1__c = 'DEP001',
            DPMAIL_RD1__c = 'dep001@test.com',
            EMPNO_RD2__c = 'EMP004',
            EMPNM_RD2__c = 'User4',
            EPMAIL_RD2__c = 'emp004@test.com',
            DEPNM_RD2__c = 'Team4',
            DEPNO_RD2__c = 'DEP002',
            DPMAIL_RD2__c = 'dep002@test.com',
            IsConverted__c = false
        ));

        // No User Case (MOD003)
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD003',
            MAKTX__c = 'Model3',
            WERKS__c = '1840',
            EMPNO_RD1__c = 'INVALID',
            EMPNM_RD1__c = 'Invalid User',
            EPMAIL_RD1__c = 'invalid@test.com',
            DEPNM_RD1__c = 'TeamX',
            DEPNO_RD1__c = 'INVALID_DEP',
            IsConverted__c = false
        ));

        // No Model Case
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD999',
            MAKTX__c = 'Invalid Model',
            WERKS__c = '1840',
            EMPNO_RD1__c = 'EMP001',
            EMPNM_RD1__c = 'User1',
            EPMAIL_RD1__c = 'emp001@test.com',
            DEPNM_RD1__c = 'Team1',
            DEPNO_RD1__c = 'DEP001',
            DPMAIL_RD1__c = 'dep001@test.com',
            IsConverted__c = false
        ));

        // Partial User Case (EMPNO_RD1__c null, use EMPNO_RD3__c, MOD003)
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD003',
            MAKTX__c = 'Model3',
            WERKS__c = '1840',
            EMPNO_RD3__c = 'EMP003',
            EMPNM_RD3__c = 'User3',
            EPMAIL_RD3__c = 'emp003@test.com',
            DEPNM_RD3__c = 'Team3',
            DEPHD_RD3__c = 'DEP001',
            IsConverted__c = false
        ));

        // Partial User Case (EMPNO_RD2__c null, use EMPNO_RD4__c, MOD002)
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD002',
            MAKTX__c = 'Model2',
            WERKS__c = '1840',
            EMPNO_RD4__c = 'EMP004',
            EMPNM_RD4__c = 'User4',
            EPMAIL_RD4__c = 'emp004@test.com',
            DEPNM_RD4__c = 'Team4',
            DEPHD_RD4__c = 'DEP002',
            IsConverted__c = false
        ));

        // DML Failure Case (Invalid Data, MOD003)
        ifDevices.add(new IF_DeviceManager__c(
            SATNR__c = 'MOD003',
            MAKTX__c = 'Model3',
            WERKS__c = '1840',
            EMPNO_RD1__c = 'EMP001',
            EMPNM_RD1__c = null, // Potential DML issue if required
            EPMAIL_RD1__c = 'emp001@test.com',
            DEPNM_RD1__c = 'Team1',
            DEPNO_RD1__c = 'DEP001',
            IsConverted__c = false
        ));

        insert ifDevices;
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        DN_DeviceManagerBatch batch = new DN_DeviceManagerBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();
    }

    @isTest
    static void testEmptyScope() {
        Test.startTest();
        DN_DeviceManagerBatch batch = new DN_DeviceManagerBatch();
        batch.execute(null, new List<SObject>());
        Test.stopTest();
    }
}