public with sharing class DN_UpdateDNSAModelFromERPBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog('IF-OPTY-033', 'IF_ERP_SalesOrder');
    
    private static Map<String,Schema.SObjectType>  schemaMap     = Schema.getGlobalDescribe();
    private static Schema.SObjectField modelEField  = schemaMap.get('DNSAModel__c').getDescribe().fields.getMap().get('Upsert_Key__c');
    

    public DN_UpdateDNSAModelFromERPBatch() {}

    public List<IF_Product__c> start(Database.BatchableContext BC) {
        System.debug('DN_UpdateDNSAModelFromERPBatch Start ------------');
        try {
            Map<String, Schema.SObjectField> objectFields = schemaMap.get('IF_Product__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_Product__c';
                    query += ' WHERE IsComplete__c = false AND FromInterfaceId__c = \'IF-OPTY-033\'';
                    query += ' ORDER BY CreatedDate ASC, BASE_CODE__c DESC';
                    query += ' LIMIT 50000';

            List<IF_Product__c> ifProductList = (List<IF_Product__c>) Database.query(query);

            return ifProductList;
        } catch (Exception e) {
            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
            return null;
        }
    }
    public void execute(Database.BatchableContext bc, List<IF_Product__c> scope) {
        System.debug('DN_UpdateDNSAModelFromERPBatch Execute ------------');

        Map<String, DNSAModel__c> dnsaModelForUpsertKey = new Map<String, DNSAModel__c>();

        System.SavePoint savePoint = Database.setSavepoint();
        try {

            // 1. if Product dnsaModelForUpsertKey mapping 및 scope if Product isComplete__c = true 로 변경
            for (IF_Product__c ifPrd : scope) {
                DNSAModel__c dsnaModel = generateDNSAModel(ifPrd);
                dnsaModelForUpsertKey.put(dsnaModel.Upsert_Key__c, dsnaModel);

                ifPrd.isComplete__c = true;
            }

            // 2. upsert DNSAModel__c 및 update IF_Product__c
            if(dnsaModelForUpsertKey.values().size() > 0) Database.upsert(dnsaModelForUpsertKey.values(), modelEField, true);
            if(scope.size() > 0) Database.update(scope);

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
    public void finish(Database.BatchableContext bc) {
        try {
            System.debug('DN_UpdateDNSAModelFromERPBatch Finish ------------');
        } catch (Exception e) {

            System.debug('Error ::: '         + e.getMessage());
            System.debug('Line Number ::: '   + e.getLineNumber());

            System.abortJob(bc.getJobId());
        }
    }
    private DNSAModel__c generateDNSAModel(IF_Product__c ifPrd){
        DNSAModel__c dsnaModel = new DNSAModel__c();

        Decimal seq = Decimal.valueOf(ifPrd.ZZSQ__c);

        dsnaModel.BaseCode__c        = ifPrd.BASE_CODE__c;
        dsnaModel.SEQ__c             = seq;
        dsnaModel.Name               = ifPrd.MDLNM__c;        
        dsnaModel.ModelName__c       = ifPrd.SATNR__c;                
        dsnaModel.PKMT__c            = ifPrd.AEDAT__c;   
        
        dsnaModel.Upsert_Key__c      = ifPrd.BASE_CODE__c + '_' + seq;

        return dsnaModel;
    }
}