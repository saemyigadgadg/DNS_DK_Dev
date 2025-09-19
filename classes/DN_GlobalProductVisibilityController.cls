public with sharing class DN_GlobalProductVisibilityController {
    /** IsGlobal__c = TRUE인 제품만 조회, 검색어가 있으면 Name LIKE 필터 */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getGlobalProducts(String searchKey) {
        List<User> profileName = [SELECT Profile.Name FROM User WHERE Id =:UserInfo.getUserId()];
        // 개발 환경
        //Boolean isAdmin = (profileName == 'System Administrator' || profileName == '시스템 관리자') && UserInfo.getUserId() != '005F7000006CqEGIA0';
        // 운영 환경
        Boolean isAdmin = (profileName[0].Profile.Name == 'System Administrator' || profileName[0].Profile.Name == '시스템 관리자') && UserInfo.getUserId() != '005TJ000004ec5tYAA';

        String baseQuery =
            'SELECT Id, Name, Name__c, Model__r.Name, NCSystem__c, Motor__c, Spindle__c, ' +
            'ToolStorageCapacity__c, MonitorSize__c, F_RegionText__c, ETC__c, IsStrategicMaterial__c, ' +
            'Region__c, IsActive, RecordTypeId, RecordType.Name, ProductCode, IsGlobal__c, IsKorea__c, IsSEADisplayed__c ' +
            'FROM Product2 '; 
        
        Boolean hasWhere = false;


        // System Admin 외 글로벌 영업 제품 관리자 조건 필터 적용 
        if (!isAdmin) {
            baseQuery += 'WHERE IsGlobal__c = TRUE AND RecordType.Name = \'BaseCode\' ';
            //나중에 추가 필요 
            baseQuery += 'AND ProductCode LIKE \'%X__\' ';
            hasWhere = true;
        }
        
        
        if (String.isNotBlank(searchKey)) {
            String esc = '%' + String.escapeSingleQuotes(searchKey.trim()) + '%';
            baseQuery += (hasWhere ? 'AND ' : 'WHERE ');
            baseQuery += 'Name LIKE \'' + esc + '\' ';
        }
      
        //쿼리 200개로 제한
        baseQuery += ' ORDER BY Name LIMIT 200';

        return Database.query(baseQuery);
    }

    /** LWC에서 넘겨준 수정된 레코드를 그대로 update */
    @AuraEnabled
    public static void updateProducts(List<Product2> data) {
        update data;
    }
    
    @AuraEnabled
    public static Boolean isCurrentUserAdmin() {
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        return profileName == 'System Administrator' || profileName == '시스템 관리자';
    }
}