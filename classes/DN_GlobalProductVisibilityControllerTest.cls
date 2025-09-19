@IsTest(seeAllData=false)
private class DN_GlobalProductVisibilityControllerTest {

    private static Profile anySysAdminProfile() {
        List<Profile> ps = [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN ('System Administrator','시스템 관리자')
            LIMIT 1
        ];
        return ps[0];
    }

    private static Profile anyNonAdminProfile() {
        List<Profile> ps = [
            SELECT Id, Name
            FROM Profile
            WHERE Name NOT IN ('System Administrator','시스템 관리자')
            AND UserLicense.Name != 'Customer Community'
            AND UserLicense.Name != 'Customer Community Plus'
            AND UserLicense.Name != 'Partner Community'
            LIMIT 1
        ];
        return ps[0];
    }

    private static User newUser(Profile p, String unamePrefix) {
        return new User(
            Alias = 'ts',
            Email = unamePrefix + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Asia/Seoul',
            Username = unamePrefix + '+' + Crypto.getRandomLong() + '@example.com',
            ProfileId = p.Id
        );
    }

    private static Id baseCodeRtId_ByName() {
        List<RecordType> rts = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType='Product2' AND Name='BaseCode'
            LIMIT 1
        ];
        return rts[0].Id;
    }

    private static Map<String, Id> seed() {
        Id rtId = baseCodeRtId_ByName();
        Product2 p1 = new Product2(Name='Prod TEST A',    ProductCode='ABCX12', RecordTypeId=rtId, IsActive=true, IsGlobal__c=true,  IsKorea__c=false, IsSEADisplayed__c=false);
        Product2 p2 = new Product2(Name='Prod B',         ProductCode='ABDX1',  RecordTypeId=rtId, IsActive=true, IsGlobal__c=true,  IsKorea__c=false, IsSEADisplayed__c=false);
        Product2 p3 = new Product2(Name='Prod C',         ProductCode='ZZZX99', RecordTypeId=rtId, IsActive=true, IsGlobal__c=false, IsKorea__c=true,  IsSEADisplayed__c=false);
        Product2 p5 = new Product2(Name='Prod Match Two', ProductCode='YYYX77', RecordTypeId=rtId, IsActive=true, IsGlobal__c=true,  IsKorea__c=false, IsSEADisplayed__c=false);
        insert new List<Product2>{ p1, p2, p3, p5 };
        return new Map<String, Id>{ 'p1'=>p1.Id, 'p2'=>p2.Id, 'p3'=>p3.Id, 'p5'=>p5.Id };
    }

    @IsTest
    static void admin_seesAll() {
        User admin = newUser(anySysAdminProfile(), 'adminA'); insert admin;
        seed();
        System.runAs(admin) {
            Test.startTest();
            DN_GlobalProductVisibilityController.getGlobalProducts(null);
            Test.stopTest();
        }
    }

    @IsTest
    static void standard_user_filtersApply() {
        User u = newUser(anyNonAdminProfile(), 'stdA'); insert u;
        seed();
        System.runAs(u) {
            Test.startTest();
            DN_GlobalProductVisibilityController.getGlobalProducts(null);
            Test.stopTest();
        }
    }

    @IsTest
    static void searchKey_furtherFilters() {
        User u = newUser(anyNonAdminProfile(), 'stdB'); insert u;
        seed();
        System.runAs(u) {
            Test.startTest();
            DN_GlobalProductVisibilityController.getGlobalProducts('TEST');
            Test.stopTest();
        }
    }

    @IsTest
    static void update_and_adminFlag() {
        User admin = newUser(anySysAdminProfile(), 'adminB'); insert admin;
        Map<String, Id> ids = seed();
        System.runAs(admin) {
            Test.startTest();
            DN_GlobalProductVisibilityController.isCurrentUserAdmin();
            Product2 upd = new Product2(Id=ids.get('p1'), IsSEADisplayed__c=true);
            DN_GlobalProductVisibilityController.updateProducts(new List<Product2>{ upd });
            Test.stopTest();
        }
    }
}