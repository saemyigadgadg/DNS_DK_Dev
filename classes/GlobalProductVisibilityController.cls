public with sharing class GlobalProductVisibilityController {
    /** IsGlobal__c = TRUE인 제품만 조회, 검색어가 있으면 Name LIKE 필터 */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getGlobalProducts(String searchKey) {
        String baseQuery =
            'SELECT Id, Name, Name__c, Model__r.Name, NCSystem__c, Motor__c, Spindle__c, ' +
            'ToolStorageCapacity__c, MonitorSize__c, F_RegionText__c, ETC__c, IsStrategicMaterial__c, ' +
            'Region__c, IsActive, RecordTypeId, IsGlobal__c, IsSEADisplayed__c ' +
            'FROM Product2 ' +
            'WHERE IsGlobal__c = TRUE';
        
        if (String.isNotBlank(searchKey)) {
            String esc = '%' + String.escapeSingleQuotes(searchKey.trim()) + '%';
            baseQuery += ' AND Name LIKE :esc';
        }
        baseQuery += ' ORDER BY Name';
        
        return Database.query(baseQuery);
    }

    /** LWC에서 넘겨준 수정된 레코드를 그대로 update */
    @AuraEnabled
    public static void updateProducts(List<Product2> data) {
        update data;
    }
}