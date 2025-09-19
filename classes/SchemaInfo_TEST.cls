/** 
 * @Class :  SchemaInfo_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 21. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-21 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class SchemaInfo_TEST {
    @isTest
    static void execute() {
        SchemaInfo schema = new SchemaInfo();
        schema = new SchemaInfo('DealerReturnOrderItem__c');

        System.debug('type : '+ schema.getType());
        System.debug('typeToString : '+ schema.getTypeToString());
        System.debug('label : '+ schema.getLabel());
        System.debug('icon : '+ schema.getIconName());
        System.debug('result : '+ schema.getResult());
        System.debug('recordTypeMap : '+ schema.getRecordTypeMapByIds());
        System.debug('recordTypeMapByDeveloperNames : '+ schema.getRecordTypeMapByDeveloperNames());
        System.debug('recordTypeMapByNames : '+ schema.getRecordTypeMapByNames());
        System.debug('recordTypeMapByNamesKeySet : '+ schema.getRecordTypeMapByNamesKeySet());
        System.debug('recordType By DeveloperName : '+ schema.getRecordTypeByDeveloperName(''));
        try {
            System.debug('recordType By Id : '+ schema.getRecordTypeById(''));
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        System.debug('field Map : '+ schema.getFieldMap());
        System.debug('fieldSet Map : '+ schema.getFieldSetMap());
        System.debug('fieldResult : '+ schema.getFieldInfo('Name'));
        System.debug('getPicklistEntrys : '+ schema.getPicklistEntrys('Reason1__c'));
        System.debug('getPicklistValuesForOptions : '+ schema.getPicklistValuesForOptions('Reason1__c', true));
        System.debug('getDependentPicklistValuesForOptions : '+ schema.getDependentPicklistValuesForOptions('Reason2__c'));
        System.debug(schema.getAllFieldsForQuery());
        List<Account> accList = new List<Account>();
        accList.add(TestDataFactoryForDealerPortal.dealer);
        accList.add(TestDataFactoryForDealerPortal.dealer2);
        accList[0].SalesOffice__c = '1146';
        accList[1].SalesOffice__c = '1146';
        insert accList;
        Map<String, UserRecordAccess> recordAccess = schema.getUserAccesses(UserInfo.getUserId(), new Set<String>{accList[0].id, accList[1].id});
        System.debug(
            JSON.serialize(recordAccess.get(accList[0].Id))
        );
    }
}