/**
 * @description       : 
 * @author            : sunwoong.han@dkbmc.com
 * @group             : 
 * @last modified on  : 2025-09-11
 * @last modified by  : sunwoong.han@dkbmc.com
**/
@isTest
public with sharing class DN_C_Utils_Test {
    @TestSetup
    static void makeData(){
        
    }

    @IsTest
    static void test01() {
        
        Test.startTest();

        Map<String, List<Map<String, String>>> picklistDependent = DN_C_Utils.getDependentPicklistLV(Account.Rating);
        Blob testBlob = DN_C_Utils.doEncryption('test123123123', DN_C_Utils.Encryption.SHA_256);
        Map<String, String> encryptionResult = DN_C_Utils.processEncryption('test123123123');
        DN_C_Utils.DecryptionResult decryptionResult = DN_C_Utils.processDecryption(encryptionResult.get('encrypteValue'), encryptionResult.get('key'));

        String iconName = DN_C_Utils.getIconName('');
        iconName = DN_C_Utils.getIconName('Account');
        iconName = DN_C_Utils.getIconName('Opportunity');

        DN_C_Utils.SchemaInfo schemaInfo = new DN_C_Utils.SchemaInfo();
        schemaInfo = new DN_C_Utils.SchemaInfo('Account');
        schemaInfo.setSchema('Opportunity');

        Schema.SObjectType                  sObjectType    = schemaInfo.getType();
        String                              sObjType       = schemaInfo.getTypeToString();
        String                              sObjectLabel   = schemaInfo.getLabel();
        Schema.DescribeSObjectResult        sObjectResult  = schemaInfo.getResult();
        Map<Id, Schema.RecordTypeInfo>      recordTypeMap1 = schemaInfo.getRecordTypeMapByIds();
        Map<String, Schema.RecordTypeInfo>  recordTypeMap2 = schemaInfo.getRecordTypeMapByDeveloperNames();
        Map<String, Schema.RecordTypeInfo>  recordTypeMap3 = schemaInfo.getRecordTypeMapByNames();

        for(Id typeId : recordTypeMap1.keySet()) {
            Schema.RecordTypeInfo           recordType1    = schemaInfo.getRecordTypeById(typeId);
            break;
        }

        for(String typeName : recordTypeMap2.keySet()) {
            Schema.RecordTypeInfo           recordType2    = schemaInfo.getRecordTypeByDeveloperName(typeName);
            break;
        }

        Map<String, Schema.SObjectField>    fieldMap       = schemaInfo.getFieldMap();
        Map<String, Schema.FieldSet>        fieldSetMap    = schemaInfo.getFieldSetMap();
        Schema.DescribeFieldResult          fieldResult    = schemaInfo.getFieldInfo('Name');
        List<Schema.PicklistEntry>          picklistEntry  = schemaInfo.getPicklistEntrys('ProcessStatus__c');

        schemaInfo.getFieldList();
        schemaInfo.getFieldSetList();
        schemaInfo.getPicklistSelectOptions('Status');
        schemaInfo.getObjectPermission();

        DN_C_Utils.getLexOrigin();
        DN_C_Utils.getVFOrigin();
        DN_C_Utils.getCurrencySymbolFromIso('CNY');
        DN_C_Utils.getCurrencyIsoCode(new Account());
        DN_C_Utils.getCurrencySymbol(new Account());

        String orgType = DN_C_Utils.getOrganizationType();

        Test.stopTest();
    }

    @IsTest
    static void test(){
        String fields = 'Id,Name';
        Integer limitSize = 10;
        Integer offset = 0;

        Test.startTest();
        DN_C_Utils.SearchResult conResult = new DN_C_Utils.SearchResult();
        conResult.datas = new List<SObject>();
        conResult.totalCount = 0;
        
        DN_C_Utils.Criteria criteria = new DN_C_Utils.Criteria();
        criteria.fieldPath = 'Name';
        criteria.operator = 'IN';
        criteria.value = new List<String>{'test', 'test2'};

        DN_C_Utils.Filter filter = new DN_C_Utils.Filter();
        filter.criteria = new List<DN_C_Utils.Criteria>();
        filter.criteria.add(criteria);
        filter.filterLogic = '{0}';
        filter.objectName = 'Account';

        DN_C_Utils.SearchResult result = DN_C_Utils.searchData(fields, filter, limitSize, offset);
        Test.stopTest();
    }
}