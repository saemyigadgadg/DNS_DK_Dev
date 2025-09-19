/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 07-28-2025
 * @last modified by  : JangJunHee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-22-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
global with sharing class DN_UpdateProductFromERPBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    private InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog('IF-OPTY-002', 'IF_ERP_Product');

    private static final Id baseCodeRT  = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('BaseCode').getRecordTypeId();
    private static final Id partRT      = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private static Schema.SObjectField modelEField  = schemaMap.get('Model__c').getDescribe().fields.getMap().get('MaterialCode__c');
    private static Schema.SObjectField prdEField    = schemaMap.get('Product2').getDescribe().fields.getMap().get('ERP_Key__c');
    private static Schema.SObjectField pbeEField    = schemaMap.get('PriceBookEntry').getDescribe().fields.getMap().get('ProductCode_Currency_Key__c');
    private static Schema.SObjectField pbpEField    = schemaMap.get('ProductByPlant__c').getDescribe().fields.getMap().get('ExternalKey__c');
    private static Map<String, String> currencyForalphabet  = getCurrencyForalphabet();

    global List<String> start(Database.BatchableContext BC) {
        System.debug('DN_UpdateProductFromERPBatch Start ------------');
        try {
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Product__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Product__c';
                    query += ' WHERE IsComplete__c = false AND FromInterfaceId__c = \'IF-OPTY-002\' AND isConvertError__c = false';
                    query += ' ORDER BY CreatedDate ASC, MATNR__c DESC';
                    query += ' LIMIT 50000';

            List<IF_Product__c> ifPrdList = (List<IF_Product__c>) Database.query(query);
            if(ifPrdList.isEmpty()) System.abortJob(bc.getJobId());

            Set<String> productNameSet = new Set<String>();
            for(IF_Product__c ifPrd : ifPrdList) {
                productNameSet.add(ifPrd.MATNR__c);
            }

            return new List<String>(productNameSet);
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
/**
 * 변수명 정리
 * EKey         : MATNR__c              - Name, Product Code 등의 External Key
 * model        : Model__c              - SObject (모델)
 * prd          : Product2              - SObject (대표사양)
 * sp           : SavePoint     
 * MN           : ModelName             - Model__c 의 MaterialCode__c 면서 External Key
 * MId          : Model Id              - Model__c 의 Id
 * ifPrd        : IF_Product            - SObject (적재 Obejct)
 * prdEKey      : Product2.ERP_Key__c   - product2(대표사양)의 ERP Key = Product COde
 * pb           : Pricebook2            - SObject
 * pbe          : PricebookEntry        - SObject
    */
    global void execute(Database.BatchableContext bc, List<String> scope) {
        System.debug('DN_UpdateProductFromERPBatch Execute ------------');

        TriggerHandler.bypass('ProductTriggerHandler');
        System.debug('<< TriggerHandler.bypass On >>');

        Map<String, List<Product2>> prdListForMN        = new Map<String, List<Product2>>();
        Map<String, String>         MIdForMN            = new Map<String, String>();

        Map<String, Model__c>       modelForEKey        = new Map<String, Model__c>();
        Map<String, Product2>       prdForEKey          = new Map<String, Product2>();
        Map<String, Product2>       prdPartForEKey      = new Map<String, Product2>();
        Map<String, String>         MNForPrdEKey        = new Map<String, String>();

        // List<PricebookEntry>        pbeList             = new List<PricebookEntry>();
        Map<String, PricebookEntry> pbeForEKey          = new Map<String, PricebookEntry>();

        Map<String, Set<String>>    plantListForEKey    = new Map<String, Set<String>>();

        Map<String, List<IF_Product__c>> ifPrdListMap   = new Map<String, List<IF_Product__c>>();

        System.SavePoint sp = Database.setSavepoint();
        
        try {
            
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Product__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Product__c';
                    query += ' WHERE IsComplete__c = false AND FromInterfaceId__c = \'IF-OPTY-002\' AND MATNR__c IN (\''+ String.join(scope, '\',\'') +'\')';
                    query += ' ORDER BY CreatedDate ASC, MATNR__c DESC';
                    query += ' LIMIT 50000';

            List<IF_Product__c> ifPrdList = (List<IF_Product__c>) Database.query(query);

            // if product 값 맵핑
            for (IF_Product__c ifPrd : ifPrdList) {

                List<IF_Product__c> ifPrdValueList = new List<IF_Product__c>();
                if(ifPrdListMap.get(ifPrd.MATNR__c) != null){
                    ifPrdValueList = ifPrdListMap.get(ifPrd.MATNR__c);
                }
                ifPrdValueList.add(ifPrd);
                ifPrdListMap.put(ifPrd.MATNR__c, ifPrdValueList);

                if(ifPrd.MTART__c == 'PKMT') {
                    Model__c model = generateModel(ifPrd);
                    modelForEKey.put(ifPrd.MATNR__c, model);

                }else if(ifPrd.MTART__c == 'FPRO') {
                    String MN       = ifPrd.SATNR__c;
                    String prdEKey  = ifPrd.MATNR__c;

                    if(ifPrd.WERKS__c != null){
                        if(plantListForEKey.get(ifPrd.MATNR__c) == null) 
                            plantListForEKey.put(ifPrd.MATNR__c, new Set<String>{ifPrd.WERKS__c});
                        else
                            plantListForEKey.get(ifPrd.MATNR__c).add(ifPrd.WERKS__c);
                    }

                    Product2 prd = generatePrd(ifPrd);

                    if(prdListForMN.get(MN) == null) prdListForMN.put(MN, new List<Product2> {prd});
                    else {
                        List<Product2> prdList = prdListForMN.get(MN);
                        prdList.add(prd);
                        prdListForMN.put(MN, prdList);
                    }
                }else if(ifprd.MTART__c != null){
                    if(ifPrd.WERKS__c != null){
                        if(plantListForEKey.get(ifPrd.MATNR__c) == null) 
                            plantListForEKey.put(ifPrd.MATNR__c, new Set<String>{ifPrd.WERKS__c});
                        else
                            plantListForEKey.get(ifPrd.MATNR__c).add(ifPrd.WERKS__c);
                    }

                    Product2 prd = generatePrd(ifPrd);
                    prd.recordTypeId = partRT;

                    prdPartForEKey.put(prd.ERP_Key__c, prd);
                }
                ifPrd.IsComplete__c = true;
            }

            // model upsert
            List<String> MIdList = new List<String>();
            if(modelForEKey.keySet().size() > 0) {
                List<Model__c> modelList =  modelForEKey.values();
                List<Database.UpsertResult> urList = Database.upsert(modelList, modelEField, false);
                if(urList.size() > 0){
                    for(integer i = 0; i < urList.size() ; i++){
                        if(!urList[i].isSuccess()){
                            String key = modelList[i].MaterialCode__c;
                            List<IF_Product__c> ifPrdErrorList = ifPrdListMap.get(key);
                            for(IF_Product__c ipe : ifPrdErrorList){
                                ipe.ConvertErrorMessage__c = String.valueOf(urList[i].getErrors());
                                ipe.isConvertError__c = true;
                                ipe.IsComplete__c = false;
                            }                            
                        }
                    }
                }
                
            }

            for (Model__c model : [
                SELECT  Id, Code__c
                FROM    Model__c
                WHERE   Code__c IN :prdListForMN.keySet()
            ]) MIdForMN.put(model.Code__c, model.Id);

            // product에 model lookup
            for (String MN : prdListForMN.keySet()) {
                List<Product2> prdList = prdListForMN.get(MN);

                for (Product2 prd : prdList) {
                    List<String> splitPrdCodeList   = prd.Name.split('-');
                    if(splitPrdCodeList.size() > 3) {
                        String prdCurrencyCode = splitPrdCodeList[splitPrdCodeList.size() - 1];
                        if(prdCurrencyCode.length() == 3) {
                            prdCurrencyCode = prdCurrencyCode.substring(0, 1);
                            if(prdCurrencyCode == 'P') prd.IsPilot__c = true;
                        }
                    }

                    prd.Model__c = MIdForMN.get(MN);                    
                    prdForEKey.put(prd.ERP_Key__c, prd);                    
                }
            }

            // 대표사양 prd upsert
            if (prdForEKey.keySet().size() > 0) {
                List<Product2> prdList =  prdForEKey.values();
                List<Database.UpsertResult> urList = Database.upsert(prdList, prdEField, false);
                if(urList.size() > 0){
                    for(integer i = 0; i < urList.size() ; i++){
                        if(!urList[i].isSuccess()){
                            String key = prdList[i].ERP_Key__c;
                            List<IF_Product__c> ifPrdErrorList = ifPrdListMap.get(key);
                            for(IF_Product__c ipe : ifPrdErrorList){
                                ipe.ConvertErrorMessage__c = String.valueOf(urList[i].getErrors());
                                ipe.isConvertError__c = true;
                                ipe.IsComplete__c = false;
                            }                            
                        }
                    }
                }
            }

            // 부품 prd upsert
            if (prdPartForEKey.keySet().size() > 0) {
                List<Product2> prdList =  prdPartForEKey.values();
                List<Database.UpsertResult> urList = Database.upsert(prdList, prdEField, false);
                if(urList.size() > 0){
                    for(integer i = 0; i < urList.size() ; i++){
                        if(!urList[i].isSuccess()){
                            String key = prdList[i].ERP_Key__c;
                            List<IF_Product__c> ifPrdErrorList = ifPrdListMap.get(key);
                            for(IF_Product__c ipe : ifPrdErrorList){
                                ipe.ConvertErrorMessage__c = String.valueOf(urList[i].getErrors());
                                ipe.isConvertError__c = true;
                                ipe.IsComplete__c = false;
                            }                            
                        }
                    }
                }
            }
            
            List<Product2> spList = [
                SELECT Id, ERP_Key__c, recordTypeId
                FROM Product2
                WHERE ERP_Key__c IN :prdForEKey.keySet() AND RecordType.Name = 'Service Package'
            ];

            List<Product2> updateSPList = new List<Product2>();
            for(Product2 serviceP : spList){
                Product2 partPrd = prdForEKey.get(serviceP.ERP_Key__c);
                partPrd.Id              = serviceP.Id;
                partPrd.recordTypeId    = serviceP.recordTypeId;
                
                updateSPList.add(partPrd);
            }
            if(updateSPList.size() > 0) {
                List<Database.SaveResult> srList = Database.update(updateSPList, false);
                if(srList.size() > 0){
                    for(integer i = 0; i < srList.size() ; i++){
                        if(!srList[i].isSuccess()){
                            String key = updateSPList[i].ERP_Key__c;
                            List<IF_Product__c> ifPrdErrorList = ifPrdListMap.get(key);
                            for(IF_Product__c ipe : ifPrdErrorList){
                                ipe.ConvertErrorMessage__c = String.valueOf(srList[i].getErrors());
                                ipe.isConvertError__c = true;
                                ipe.IsComplete__c = false;
                            }                            
                        }
                    }
                }
            }

            // Product By Plant 생성 및 prd plant__c Mapping
            Map<String, ProductByPlant__c> productByPlantForEKey = new Map<String, ProductByPlant__c>();
            List<Product2> updatePlantProductList = new List<Product2>();
            if(plantListForEKey.keySet().size() > 0){
                for (String prdEKey : plantListForEKey.keySet()) {
                    
                    if (prdForEKey.get(prdEKey) != null 
                        && plantListForEKey.get(prdEKey) != null 
                        && plantListForEKey.get(prdEKey).Size() > 0) {

                        Set<String> plantList = plantListForEKey.get(prdEKey);

                        Product2 prd        = prdForEKey.get(prdEKey);
                        prd.Plant__c        = String.join(plantList, ';');
                        
                        for (String plant : plantList) {
                            ProductByPlant__c pbp = new ProductByPlant__c();
                            pbp.Part__c         = prd.Id;
                            pbp.Plant__c        = plant;
                            pbp.ExternalKey__c  = prd.Name + '_' + plant;
    
                            productByPlantForEKey.put(pbp.ExternalKey__c, pbp);
                        }
                        updatePlantProductList.add(prd);
                    } 

                    if (prdPartForEKey.get(prdEKey) != null 
                        && plantListForEKey.get(prdEKey) != null 
                        && plantListForEKey.get(prdEKey).size() > 0) {

                        Set<String> plantList = plantListForEKey.get(prdEKey);

                        Product2 prd        = prdPartForEKey.get(prdEKey);
                        prd.Plant__c        = String.join(plantList, ';');
                        
                        for (String plant : plantList) {
                            ProductByPlant__c pbp = new ProductByPlant__c();
                            pbp.Part__c         = prd.Id;
                            pbp.Plant__c        = plant;
                            pbp.ExternalKey__c  = prd.Name + '_' + plant;
    
                            productByPlantForEKey.put(pbp.ExternalKey__c, pbp);
                        }
                        updatePlantProductList.add(prd);
                    }
                }
            }

            // ProductByPlant upsert
            if (productByPlantForEKey.keySet().size() > 0) {                
                List<Database.UpsertResult> urList = Database.upsert(productByPlantForEKey.values(), pbpEField, false);
                List<ProductByPlant__c> prdList =  productByPlantForEKey.values();
                if(urList.size() > 0){
                    for(integer i = 0; i < urList.size() ; i++){
                        if(!urList[i].isSuccess()){
                            String key = prdList[i].Name;
                            List<IF_Product__c> ifPrdErrorList = ifPrdListMap.get(key);
                            for(IF_Product__c ipe : ifPrdErrorList){
                                ipe.ConvertErrorMessage__c = String.valueOf(urList[i].getErrors());
                                ipe.isConvertError__c = true;
                                ipe.IsComplete__c = false;
                            }                            
                        }
                    }
                }
            }

            // product plant__c update
            if (updatePlantProductList.size() > 0) {
                List<Database.SaveResult> srList = Database.update(updatePlantProductList, false);
                if(srList.size() > 0){
                    for(integer i = 0; i < srList.size() ; i++){
                        if(!srList[i].isSuccess()){
                            String key = updatePlantProductList[i].ERP_Key__c;
                            List<IF_Product__c> ifPrdErrorList = ifPrdListMap.get(key);
                            for(IF_Product__c ipe : ifPrdErrorList){
                                ipe.ConvertErrorMessage__c = String.valueOf(srList[i].getErrors());
                                ipe.isConvertError__c = true;
                                ipe.IsComplete__c = false;
                            }                            
                        }
                    }
                }
            }

            // get pricebookId
            String pbId = Test.isRunningTest() ? Test.getStandardPricebookId() : [
                SELECT  Id, Name 
                FROM    Pricebook2 
                WHERE   isStandard = true 
                LIMIT 1
            ].Id;

            // 대표사양 pricebookEntry 생성
            List<String> pbeEKeyList = new List<String>();
            for (Product2 prd : prdForEKey.values()) {
                PricebookEntry pbe = new PricebookEntry();
                pbe.Pricebook2Id    = pbId;
                pbe.Product2Id      = prd.Id;
                pbe.IsActive        = true;
                pbe.UnitPrice       = 0;
                pbe.ProductCode_Currency_Key__c = prd.Name + '_' + pbe.CurrencyIsoCode;

                Boolean isKRW = false;
                // product code 마지막 알파벳 기준으로 pbe currency 입력
                List<String> splitPrdCodeList   = prd.ProductCode.split('-');
                if(splitPrdCodeList.size() > 3) {
                    String prdCurrencyCode = splitPrdCodeList[splitPrdCodeList.size() - 1];
                    if(prdCurrencyCode.length() == 3) {
                        prdCurrencyCode = prdCurrencyCode.substring(0, 1);
                        if(currencyForalphabet.get(prdCurrencyCode) != null){
                            List<String> currencyCodeList = currencyForalphabet.get(prdCurrencyCode).split(',');
    
                            for (String currencyCode : currencyCodeList) {
                                pbe.CurrencyIsoCode = currencyCode;
                                pbeForEKey.put(pbe.ProductCode_Currency_Key__c, pbe);
                                // pbeList.add(pbe);
                            }
                        } else isKRW = true;
                    } else isKRW = true;
                } else isKRW = true;
                
                if(isKRW){
                    pbe.CurrencyIsoCode = 'KRW';
                    pbeForEKey.put(pbe.ProductCode_Currency_Key__c, pbe);
                    // pbeList.add(pbe);
                }
            }

            // part pricebookEntry 생성
            for (Product2 prd : prdPartForEKey.values()) {
                PricebookEntry pbe = new PricebookEntry();
                pbe.Pricebook2Id    = pbId;
                pbe.Product2Id      = prd.Id;
                pbe.CurrencyIsoCode = 'KRW';
                pbe.IsActive        = true;
                pbe.UnitPrice       = 0;
                pbe.ProductCode_Currency_Key__c = prd.Name + '_' + pbe.CurrencyIsoCode;

                pbeForEKey.put(pbe.ProductCode_Currency_Key__c, pbe);
                // pbeList.add(pbe);
            }

            List<PricebookEntry> pbeQueryList = [
                SELECT Id, ProductCode_Currency_Key__c 
                FROM PricebookEntry 
                WHERE ProductCode_Currency_Key__c IN :pbeForEKey.keySet()
            ];

            for (PricebookEntry pbe : pbeQueryList) {
                if(pbeForEKey.containsKey(pbe.ProductCode_Currency_Key__c)) pbeForEKey.remove(pbe.ProductCode_Currency_Key__c);
            }

            // if (!ifPrdList.isEmpty())   Database.Update(ifPrdList, true);
            if (!pbeForEKey.values().isEmpty()) {                    
                List<PricebookEntry> pbeList =  pbeForEKey.values();
                List<Database.SaveResult> srList = Database.insert(pbeList, false);
                if(srList.size() > 0){
                    for(integer i = 0; i < srList.size() ; i++){
                        if(!srList[i].isSuccess()){
                            String key = pbeList[i].ProductCode_Currency_Key__c.split('_')[0];
                            List<IF_Product__c> ifPrdErrorList = ifPrdListMap.get(key);
                            for(IF_Product__c ipe : ifPrdErrorList){
                                ipe.ConvertErrorMessage__c = String.valueOf(srList[i].getErrors());
                                ipe.isConvertError__c = true;
                                ipe.IsComplete__c = false;
                            }                            
                        }
                    }
                }
            }

            ifPrdList = new List<IF_Product__c>();
            for(List<IF_Product__c> ifprd: ifPrdListMap.values()) ifPrdList.addAll(ifprd);           
            if (!ifPrdList.isEmpty()) Database.Update(ifPrdList, true);

        } catch (Exception e) {
            Database.rollback(sp);

            this.interfaceLog.errorText = new List<String>();
            this.interfaceLog.errorText.add('[' + e.getLineNumber() + ']' + e.getMessage());   
            InterfaceCommonLog ifCommonLog = new InterfaceCommonLog();
            ifCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{this.interfaceLog});

            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());

            // 사용자 조회 (사용자 정의 개체 초과로 인한 하드코딩)
            User targetUser = [
                SELECT Id, Email 
                FROM User 
                WHERE Username = 'interface@dncompany.com' 
                LIMIT 1
            ];

            // 메일 생성
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { targetUser.Email });
            mail.setSubject('DN Interface Error');
            mail.setPlainTextBody(e.getMessage());

            // 메일 전송
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                System.debug('이메일 전송 성공');
            } catch (Exception e2) {
                System.debug('이메일 전송 실패: ' + e2.getMessage());
            }
            System.abortJob(bc.getJobId());
        }

        TriggerHandler.clearBypass('ProductTriggerHandler');
        System.debug('<< TriggerHandler.bypass Off >>');
    }
    global void finish(Database.BatchableContext bc) {
        try {
            System.debug('DN_UpdateProductFromERPBatch Finish ------------');
            DN_UpdateProductFromERPBatch batchInstance = new DN_UpdateProductFromERPBatch();
            if(!Test.isRunningTest()) Database.executeBatch(batchInstance, 10);
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // util method
    private Model__c generateModel(IF_Product__c ifPrd){
        Model__c model = new Model__c();
        model.MaterialCode__c    = ifPrd.MATNR__c;

        model.Name               = ifPrd.MATNR__c;
        model.NameEN__c          = ifPrd.MAKTX__c;
        model.Name__c            = ifPrd.MAKTX__c;
        model.Unit__c            = ifPrd.MEINS__c;
        
        model.Weight__c              = ifPrd.NTGEW__c != null ? Decimal.valueOf(ifPrd.NTGEW__c) : 0;
        model.WeightUnit__c          = ifPrd.GEWEI__c;
        model.MaterialGroupCode__c   = ifPrd.MATKL__c;
        model.MaterialGroupName__c   = ifPrd.WGBEZ__c;

        return model;
    }
    private Product2 generatePrd(IF_Product__c ifPrd){
        Product2 prd = new Product2();
        prd.recordTypeId       = baseCodeRT;
        prd.ERP_Key__c         = ifPrd.MATNR__c;
        
        prd.Name               = ifPrd.MATNR__c;
        prd.Name__c            = ifPrd.MATNR__c;

        prd.ProductCode        = ifPrd.MATNR__c;
        prd.MaterialDetailsEN__c    = ifPrd.MAKTX__c;
        prd.MaterialDetailsKO__c    = ifPrd.MAKTX__c;
        prd.Unit__c            = ifPrd.MEINS__c;

        prd.Weight__c              = ifPrd.NTGEW__c != null ? Decimal.valueOf(ifPrd.NTGEW__c) : 0; 
        prd.WeightUnit__c          = ifPrd.GEWEI__c; 
        prd.MaterialGroupCode__c   = ifPrd.MATKL__c; 
        prd.MaterialGroupName__c   = ifPrd.WGBEZ__c;
        prd.IsActive               = true;

        if(ifPrd.HE_INDICATOR__c      == 'X') prd.HEIndicator__c = true;
        else                                  prd.HEIndicator__c = false;
        
        return prd;
    }
    private static Map<String, String> getCurrencyForalphabet(){
        return new Map<String, String> {
            'K'         => 'KRW',
            'Z'         => 'USD,CNY',
            'E'         => 'EUR',
            'U'         => 'USD',
            'I'         => 'EUR',
            'B'         => 'GBP',
            'X'         => 'AUD,JPY,USD',
            'P'         => 'KRW,CNY,GBP,EUR,AUD,JPY,USD',
            'S'         => 'USD,AUD'
        };
    }

}