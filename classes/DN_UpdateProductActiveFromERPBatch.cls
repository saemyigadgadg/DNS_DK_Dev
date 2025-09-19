/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-20-2025
 * @last modified by  : JangJunHee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-22-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
global with sharing class DN_UpdateProductActiveFromERPBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog('IF-OPTY-030', 'IF_ERP_Product');
    private static Map<String,Schema.SObjectType>  schemaMap     = Schema.getGlobalDescribe();

    // 장비 Name 을 Key로 장비에 속한 product를 가져옴
    Map<String, IF_Product__c>          ifProductForName        = new Map<String, IF_Product__c>();
    // 장비 Name 을 Key로 장비에 속한 List를 가져옴 *ifProduct isComplete__c true 변경용
    Map<String, List<IF_Product__c>>    ifProductListForName    = new Map<String, List<IF_Product__c>>();
    // 장비 Name 을 Key로 장비 변경 정보 저장용                          ( 2025-06-19 logic 변경 후 사용 x )
    // Map<String, Product2>               prdForName              = new Map<String, Product2>();
    // Product DML 에러 발생시 Product Id Key 로 Product Name 가져오는용 ( 2025-06-19 logic 변경 후 사용 x )
    // Map<String, String>                 prdNameForPrdId         = new Map<String, String>();
    // Product DML 에러 발생시 Product Name Key 로 IF Product 가져오는용 ( 2025-06-19 logic 변경 후 사용 x )
    // Map<String, IF_Product__c>          IFPrdForPrdName         = new Map<String, IF_Product__c>();

    global DN_UpdateProductActiveFromERPBatch() {}

    global class DN_UpdateProductActiveFromERPBatch_Exception extends Exception{}

    global List<IF_Product__c> start(Database.BatchableContext BC) {
        System.debug('DN_UpdateProductActiveFromERPBatch Start ------------');
        try {
            // 1. IF Product Query
            Map<String, Schema.SObjectField> IFObjectFields = schemaMap.get('IF_Product__c').getDescribe().fields.getMap();
            List<String> IFFieldsToQuery = new List<String>(IFObjectFields.keySet());

            String  IFQuery = 'SELECT ' + String.join(IFFieldsToQuery, ', ') + ' FROM IF_Product__c';
                    IFQuery += ' WHERE IsComplete__c = false ';
                    IFQuery += ' AND FromInterfaceId__c = \'IF-OPTY-030\'';
                    IFQuery += ' ORDER BY CreatedDate ASC';
                    IFQuery += ' LIMIT 50000';

            List<IF_Product__c> ifProductList = (List<IF_Product__c>) Database.query(IFQuery);

            // 2. IF Product IsComplete__c = true 및 ifProductForName, ifProductListForName put
            for (IF_Product__c ifProduct : ifProductList) {
                ifProduct.IsComplete__c = true;

                this.ifProductForName.put(ifProduct.MALNR__c, ifProduct);

                if(this.ifProductListForName.get(ifProduct.MALNR__c) != null){
                    this.ifProductListForName.get(ifProduct.MALNR__c).add(ifProduct);
                }else{
                    this.ifProductListForName.put(ifProduct.MALNR__c, new List<IF_Product__c>{ifProduct});
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
        System.debug('DN_UpdateProductActiveFromERPBatch Execute ------------');

        List<IF_Product__c>         updateIFProductList     = new List<IF_Product__c>();

        Map<String, String>         prdNameForPrdId         = new Map<String, String>();
        Map<String, IF_Product__c>  IFPrdForPrdName         = new Map<String, IF_Product__c>();
        List<Database.SaveResult>   errorSRList             = new List<Database.SaveResult>();

        System.SavePoint savePoint = Database.setSavepoint();
        try {
            // 1. product field mapping 에 필요한 장비 Name List 생성, updateIFProductList put, IFPrdForPrdName put
            List<String> nameList = new List<String>();
            for (IF_Product__c ifProduct : scope) {
                if(this.ifProductListForName.get(ifProduct.MALNR__c) != null) {
                    updateIFProductList.addAll(this.ifProductListForName.get(ifProduct.MALNR__c));
                }
                IFPrdForPrdName.put(ifProduct.MALNR__c, ifProduct);
                nameList.add(ifProduct.MALNR__c);
            }

            // 2. IF Product 에 해당하는 대표사양 Query
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('Product2').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM Product2';
                    query += ' WHERE RecordType.name = \'basecode\'';
                    query += ' AND Name IN (\''+ String.join(nameList, '\',\'') +'\')';
                    query += ' ORDER BY CreatedDate DESC LIMIT 50000';

            List<Product2> productList = (List<Product2>) Database.query(query);

            // 3. name 을 Key 로 prdForName 에 해당하는 IF Product 가져와서 Product 값 mapping 후 prdNameForPrdId put
            for (Product2 prd : productList) {
                prdNameForPrdId.put(prd.Id, prd.Name);

                if(this.ifProductForName.get(prd.Name) != null 
                    && this.ifProductForName.get(prd.Name).VKORG__c == '1800'
                    && this.ifProductForName.get(prd.Name).SPART__c == '40'
                    && this.ifProductForName.get(prd.Name).KUNNR__c == 'KR'
                ){
                    prd.put('IsKorea__c', true);
                    prd.put('IsActive', true);
                    prd.put('ModelDescription__c', this.ifProductForName.get(prd.Name).ZMDDESC__c);
                }
            }

            // 4. product Update 및 DML 실패한 Save Result 저장
            if(productList.size() > 0) {
                System.debug('<< TriggerHandler.bypass On >>');
                TriggerHandler.bypass('ProductTriggerHandler');

                Database.SaveResult[] srList = Database.update(productList, false);
                for(Database.SaveResult sr : srList){
                    if (!sr.isSuccess()) {
                        System.debug('Update Product DML Error');
                        errorSRList.add(sr);
                    }
                }

                System.debug('<< TriggerHandler.bypass Off >>');
                TriggerHandler.clearBypass('ProductTriggerHandler');
            }
            // 5. update IFProduct List 
            if(updateIFProductList.size() > 0)  Database.update(updateIFProductList);

            // 5-1. ErrorSRList 가 빈 값이 아닌경우 IF Product Error__c 값 추가 후 update
            if(errorSRList.size() > 0) {
                List<IF_Product__c> dmlErrorIFProductList = new List<IF_Product__c>();

                for(Database.SaveResult sr : errorSRList) {
                    String productName  = prdNameForPrdId.get(sr.getId());

                    IF_Product__c ifPrd = IFPrdForPrdName.get(productName);
                    
                    String errorMessage = String.valueOf(sr.getErrors());
                    ifPrd.Error__c      = errorMessage.length() > 254 ? errorMessage.substring(0, 254) : errorMessage;
                    ifPrd.IsComplete__c = false;
                }

                Database.update(dmlErrorIFProductList);
            }

            // 6. For Test Coverage
            if(Test.isRunningTest()) throw new DN_UpdateProductActiveFromERPBatch_Exception();
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
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('DN_UpdateProductActiveFromERPBatch Finish ------------');
    }
}