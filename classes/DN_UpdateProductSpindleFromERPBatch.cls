/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 07-28-2025
 * @last modified by  : JangJunHee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-16-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
global with sharing class DN_UpdateProductSpindleFromERPBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog('IF-OPTY-032', 'IF_ERP_Product');
    private static Map<String,Schema.SObjectType>  schemaMap     = Schema.getGlobalDescribe();

    // 장비 Name 을 Key로 장비에 속한 product를 가져옴
    Map<String, IF_Product__c>                  ifProductForName        = new Map<String, IF_Product__c>();
    // 장비 Name 을 Key로 장비에 속한 List를 가져옴 *ifProduct isComplete__c true 변경용
    private Map<String, List<IF_Product__c>>    ifProductListForName    = new Map<String, List<IF_Product__c>>();

    public DN_UpdateProductSpindleFromERPBatch() {}

    global List<IF_Product__c> start(Database.BatchableContext BC) {
        System.debug('DN_UpdateProductSpindleFromERPBatch Start ------------');
        try {
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Product__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Product__c';
                    query += ' WHERE IsComplete__c = false AND FromInterfaceId__c = \'IF-OPTY-032\'';
                    query += ' ORDER BY CreatedDate ASC';

            List<IF_Product__c> ifProductList = (List<IF_Product__c>) Database.query(query);

            for (IF_Product__c ifProduct : ifProductList) {
                ifProduct.IsComplete__c = true;
                
                this.ifProductForName.put(ifProduct.MATNR__c, ifProduct);

                if(this.ifProductListForName.get(ifProduct.MATNR__c) != null){
                    this.ifProductListForName.get(ifProduct.MATNR__c).add(ifProduct);
                }else{
                    this.ifProductListForName.put(ifProduct.MATNR__c, new List<IF_Product__c>{ifProduct});
                }
            }

            return this.ifProductForName.values();
        } catch (Exception e) {
            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
            return null;
        }
    }
    global void execute(Database.BatchableContext bc, List<IF_Product__c> scope) {
        System.debug('DN_UpdateProductSpindleFromERPBatch Execute ------------');

        TriggerHandler.bypass('ProductTriggerHandler');
        System.debug('<< TriggerHandler.bypass On >>');

        List<IF_Product__c> updateIFProductList = new List<IF_Product__c>();
        
        System.SavePoint savePoint = Database.setSavepoint();
        try {
            // 1. product query 에 필요한 scope 장비 Name List 생성
            List<String> nameList = new List<String>();
            for (IF_Product__c ifProduct : scope) nameList.add(ifProduct.MATNR__c);

            // 2. product query
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('Product2').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM Product2';
                    query += ' WHERE Name IN (\''+ String.join(nameList, '\',\'') +'\')';
                    query += ' ORDER BY CreatedDate DESC LIMIT 50000';

            List<Product2> productList = (List<Product2>) Database.query(query);

            // 3. product 에 해당하는 IF_Product 를 가져와서 product에 Spindle field mapping
            List<Product2> updateProductList = new List<Product2>();
            Set<String> duplicateCheckSet = new Set<String>();
            for (Product2 product : productList) {
                
                if(this.ifProductForName.get(product.Name) != null
                    && !duplicateCheckSet.contains(product.Name)    
                ){
                    IF_Product__c ifProduct = this.ifProductForName.get(product.Name);
    
                    product.put('Region__c'               , ifProduct.REGION__c);
                    product.put('NCSystem__c'             , ifProduct.ATWTB__c);
                    product.put('MaxSpindleSpeed__c'      , ifProduct.ATWTB2__c);
                    product.put('ToolStorageCapacity__c'  , ifProduct.ATWTB3__c);
                    product.put('MonitorSize__c'          , ifProduct.ATWTB4__c);
                    product.put('MaxMainSpindleSpeed__c'  , ifProduct.ATWTB5__c);
                    product.put('isGlobal__c'  , TRUE);
    
                    updateProductList.add(product);
                    duplicateCheckSet.add(product.Name);
                    
                    if(this.ifProductListForName.get(product.Name) != null) updateIFProductList.addAll(this.ifProductListForName.get(product.Name));
                }
            }

            // 4. IF_Product, Product2 List update
            if(updateProductList.size() > 0)    Database.update(updateProductList);
            if(updateIFProductList.size() > 0)  Database.update(updateIFProductList);
        } catch (Exception e) {
            Database.rollback(savePoint);

            this.interfaceLog.errorText = new List<String>();
            this.interfaceLog.errorText.add('[' + e.getLineNumber() + ']' + e.getMessage());   
            InterfaceCommonLog ifCommonLog = new InterfaceCommonLog();
            ifCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{this.interfaceLog});

            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
        }

        TriggerHandler.clearBypass('ProductTriggerHandler');
        System.debug('<< TriggerHandler.bypass Off >>');
    }
    global void finish(Database.BatchableContext bc) {
        try {
            System.debug('DN_UpdateProductSpindleFromERPBatch Finish ------------');
        } catch (Exception e) {
            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
        }
    }
}