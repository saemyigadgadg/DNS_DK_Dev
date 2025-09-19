public with sharing class IF_ERP_PermittedItemBatchAPIBatch 
                    implements Database.Batchable<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST>, 
                        Database.AllowsCallouts, 
                        Database.Stateful{

    public List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> T_LIST;
    
    /**
     * Constructor
        */
        public IF_ERP_PermittedItemBatchAPIBatch() {}

    /**
     * Batch Start
        */
        public List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> start(Database.BatchableContext BC){
            System.debug('call out success');
            return this.T_LIST;
        }
    /**
     * Batch execute
        */        
        public void execute(Database.BatchableContext BC, List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> scope){
            List<IF_Product__c> insertProductList = new List<IF_Product__c>();

            for(IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST item : scope){
                IF_Product__c p = new IF_Product__c();
                p.MANDT__c = item.MANDT;
                p.VKORG__c = item.VKORG;
                p.VTWEG__c = item.VTWEG;
                p.SPART__c = item.SPART;
                p.KUNNR__c = item.KUNNR;
                p.MATNR__c = item.MATNR;
                p.MALNR__c = item.MALNR;
                p.DEIND__c = item.DEIND;
                p.ERDAT__c = item.ERDAT;
                p.ERNAM__c = item.ERNAM;
                p.ERZET__c = item.ERZET;
                p.AEDAT__c = item.AEDAT;
                p.AENAM__c = item.AENAM;
                p.AEZET__c = item.AEZET;
                
                p.FromInterfaceId__c = 'IF-OPTY-030';
                insertProductList.add(p);
            }

            if(insertProductList.size() > 0) insert insertProductList;
        }
    /**
     * Batch finish
        */
        public void finish(Database.BatchableContext BC){
            if(!Test.isRunningTest()) {
                DN_UpdateProductActiveFromERPBatch batch = new DN_UpdateProductActiveFromERPBatch();
                Database.executeBatch(batch);
            }
        }
}