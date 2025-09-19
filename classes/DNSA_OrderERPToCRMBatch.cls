/**
 * @description       : DNSA ERP To CRM
 *                      DNSA Order는 CRM에서 생성되므로 Update로 진행
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-02-25   yeongju.yun   Initial Version
 * 1.1   2025-04-13   yeongju.yun   EDIT01. Order Update Only > Upsert
**/
global with sharing class DNSA_OrderERPToCRMBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    public static DN_OrderService ordSvc = new DN_OrderService();
    public static Set<String> orderIds = new Set<String>(); 

    public DNSA_OrderERPToCRMBatch() {}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = ' SELECT VBELN__c FROM IF_Order__c '
                     + ' WHERE IsDNSA__c = TRUE AND IsConverted__c = FALSE AND TABLE_NAME__c = \'T_ORDER\' AND POSNR__c = \'000010\' ';
        
        System.debug('QueryLocator - query ::: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        Set<String> rsoNoSet = new Set<String>();
        for(SObject obj : scope) {
            rsoNoSet.add(String.valueOf(obj.get('VBELN__c')));
        }
        List<String> rsoNos = new List<String>(rsoNoSet);

        // get target
        List<IF_Order__c> rsoTarget = new List<IF_Order__c>();
        Map<String, IF_Order__c> psoMap = new Map<String, IF_Order__c>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('IF_ORDER__c').getDescribe().fields.getMap();
        String queryFields = String.join(new List<String>(fieldMap.keySet()), ', ');
        String query = ' SELECT ' + queryFields + ' FROM IF_ORDER__c '
                     + ' WHERE IsDNSA__c = TRUE AND IsConverted__c = FALSE '
                     + ' AND ( (TABLE_NAME__c = \'T_ORDER\' AND VBELN__c IN :rsoNos ) '
                     + '    OR (TABLE_NAME__c = \'T_ZCRMS0094\' AND VBELN_SO__c IN :rsoNos ) )';
        List<IF_ORDER__c> ifOrders = Database.query(query);

        Set<String> orderKeySet       = new Set<String>(); // order item
        Set<String> customerNoSet     = new Set<String>(); // account
        Set<String> productCodeSet    = new Set<String>(); // product
        Set<String> productCodeNewSet = new Set<String>(); // product to insert
        for(IF_Order__c ifOrder : ifOrders) {
            if(ifOrder.TABLE_NAME__c == 'T_ORDER') { 
                rsoTarget.add(ifOrder); 

                if(String.isNotBlank(ifOrder.KUNNR_AG__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_AG__c)); }
                if(String.isNotBlank(ifOrder.KUNNR_WE__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_WE__c)); }
                if(String.isNotBlank(ifOrder.KUNNR_RE__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_RE__c)); }
                if(String.isNotBlank(ifOrder.KUNNR_RG__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_RG__c)); }
                if(String.isNotBlank(ifOrder.KUNNR_ZM__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_ZM__c)); }
                if(String.isNotBlank(ifOrder.KUNNR_Z2__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_Z2__c)); }

                if(ifOrder.POSNR__c == '000010' && ifOrder.AUART__c != 'ZUSO') {
                    productCodeSet.add(ifOrder.MATNR__c);
                    productCodeNewSet.add(ifOrder.MATNR__c);
                } 

                orderKeySet.add(ifOrder.VBELN__c + '_' + ifOrder.POSNR__c);
            } else if(ifOrder.TABLE_NAME__c == 'T_ZCRMS0094') {
                psoMap.put(ifOrder.VBELN_SO__c, ifOrder);
            }
        }
        
        // previous order item
        List<OrderItem> prevOrderItems = [SELECT Id, IF_POSNR__c, Key__c, Order.OrderType__c, Product2Id, PricebookEntryId FROM OrderItem WHERE Key__c =: orderKeySet];
        Set<String> prevOrderItemKeys = new Set<String>();
        Map<String, OrderItem> optionOnlyMap = new Map<String, OrderItem>();
        for(OrderItem oItem : prevOrderItems) {
            prevOrderItemKeys.add(oItem.Key__c);

            if(oItem.IF_POSNR__c == '000010' && oItem.Order.OrderType__c == 'ZUSO') {
                optionOnlyMap.put(oItem.Key__c, oItem);
            }
        }

        // account
        List<Account> accList = [SELECT Id, CustomerCode__c, RecordType.DeveloperName, CountryLookup__r.CountryCode__c FROM Account WHERE CustomerCode__c =: customerNoSet];
        Map<String, Account> accCodeMap = new Map<String, Account>(); // key : account customer code, value : account
        // account record type 우선순위 : *DNSACustomer -> Dealer -> ShipToParty
        for(Account acc : accList) {
            if(acc.RecordType.DeveloperName == 'DNSACustomer') continue;
            String accNo = ordSvc.formatCodeForSAP(10, acc.CustomerCode__c);
            if(accCodeMap.containsKey(accNo)) {
                if(acc.RecordType.DeveloperName == 'Dealer') { accCodeMap.put(accNo, acc); }
            } else {
                accCodeMap.put(accNo, acc);
            }
        }

        for(Account acc : accList) {
            String accNo = ordSvc.formatCodeForSAP(10, acc.CustomerCode__c);
            if(acc.RecordType.DeveloperName == 'DNSACustomer') { accCodeMap.put(accNo, acc); }
        }

        // Pricebook2
        Id stdPriceBookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE ]?.Id;

        // Product Record Type
        Id prodRecordType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(ordSvc.PROD_RECORDTYPE).getRecordTypeId();

        // product (Option Only는 무조건 L220LC-F0TD-0-U10)
        List<Product2> prodList = [
            SELECT Id, Name, ProductCode, Name__c 
            FROM Product2 
            WHERE (ProductCode =: productCodeSet OR ProductCode =: 'L220LC-F0TD-0-U10')
        ];
        Map<String, Id> prodCodeMap = new Map<String, Id>(); // key : product code, value : product2 id
        for(Product2 prod : prodList) {
            prodCodeMap.put(prod.ProductCode, prod.Id);
            productCodeNewSet.remove(prod.ProductCode);
        }

        if(!productCodeNewSet.isEmpty()) {
            List<Product2> newProdList = new List<Product2>();
            for(IF_Order__c ifOrder : rsoTarget) {
                if(productCodeNewSet.contains(ifOrder.MATNR__c) && ifOrder.POSNR__c == '000010') {
                    Product2 prod         = new Product2();
                    prod.Name             = ifOrder.MATNR__c;
                    prod.ProductCode      = ifOrder.MATNR__c;
                    prod.Name__c          = ifOrder.MAKTX__c;
                    prod.CurrencyIsoCode  = ifOrder.WAERK__c;
                    prod.IsActive         = true;
                    prod.RecordTypeId     = prodRecordType;
                    prod.ERP_Key__c       = ifOrder.MATNR__c;
    
                    newProdList.add(prod);
                }
            }
            insert newProdList;

            List<PriceBookEntry> newEntryList = new List<PriceBookEntry>();
            for(Product2 prod : newProdList) {
                prodCodeMap.put(prod.ProductCode, prod.Id);

                PriceBookEntry entry  = new PriceBookEntry();
                entry.Product2Id      = prod.Id;
                entry.Pricebook2Id    = stdPriceBookId;
                entry.CurrencyIsoCode = prod.CurrencyIsoCode;
                entry.UnitPrice       = 0;
                entry.IsActive        = true;
                entry.ProductCode_Currency_Key__c = prod.Name + '_' + prod.CurrencyIsoCode;
                newEntryList.add(entry);
            }
            insert newEntryList;
        }

        // PriceBookEntry
        List<PriceBookEntry> entryList = [SELECT Id, CurrencyIsoCode, Product2Id FROM PriceBookEntry WHERE Pricebook2.IsStandard = TRUE AND Product2Id =: prodCodeMap.values()];
        Map<String, Id> entryMap = new Map<String, Id>(); // key : prod id + _ + curr code, value : pricebookentry id
        for(PriceBookEntry entry : entryList) {
            entryMap.put(entry.Product2Id + '_' + entry.CurrencyIsoCode, entry.Id);
        }

        Id DNSARecordTypeId = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

        List<String> sqTarget = new List<String>{'PS100', 'PS200', 'PS300', 'SQ100', 'SQ200', 'SQ300'};
        Map<String, OrderItem> prodItemMap  = new Map<String, OrderItem>(); // key : erp order no, value : order item (base code only)

        List<Order>     toUpsertOrders = new List<Order>();
        List<OrderItem> targetItems  = new List<OrderItem>();
        for(IF_Order__c ifOrder : rsoTarget) {

            String erpOrderNo = ifOrder.VBELN__c;
            String erpPOSNR   = ifOrder.POSNR__c;
            String itemKey    = erpOrderNo + '_' + erpPOSNR;
            String entryKey   = prodCodeMap.get(ifOrder.MATNR__c) + '_' + ifOrder.WAERK__c;
            Boolean isNew     = !prevOrderItemKeys.contains(itemKey);

            OrderItem newOItem  = new OrderItem();
            if(erpPOSNR == '000010') {

                if(ifOrder.AUART__c == 'ZUSO') { // Option Only Order
                    if(optionOnlyMap.containsKey(itemKey)) {
                        OrderItem prvZUSOItem     = optionOnlyMap.get(itemKey);
                        newOItem.Product2Id       = prvZUSOItem.Product2Id;
                        newOItem.PricebookEntryId = prvZUSOItem.PricebookEntryId;
                    } else {
                        newOItem.Product2Id       = prodCodeMap.get('L220LC-F0TD-0-U10');
                        newOItem.PricebookEntryId = entryMap.get(newOItem.Product2Id + '_' + ifOrder.WAERK__c);
                    }
                } else {
                    newOItem.Product2Id       = prodCodeMap.get(ifOrder.MATNR__c);
                    newOItem.PricebookEntryId = entryMap.get(entryKey);
                }

                // order
                Order newOrder                 = new Order();
                newOrder.ERPRSONo__c           = erpOrderNo;
                newOrder.ERPPSONo__c           = ifOrder.PSO_NUM__c;
                newOrder.StockOrder__c         = ifOrder.IHREZ__c;
                newOrder.PaymentTerms__c       = ifOrder.ZTERM__c;
                newOrder.ActualShippingDate__c = ifOrder.WADAT_IST__c.startsWith('0000') ? null : Date.valueOf(ifOrder.WADAT_IST__c);
                newOrder.RequestedShipDate__c  = ifOrder.VDATU__c.startsWith('0000') ? null : Date.valueOf(ifOrder.VDATU__c);
                newOrder.ShipTo__c             = accCodeMap.get(ifOrder.KUNNR_WE__c)?.Id;

                newOrder.IF_IsERPConfirmed__c   = ifOrder.ZZSTATUS__c == 'C';
                newOrder.IsOrderDeleted__c      = ifOrder.ZDELFLAG__c == 'X';
                newOrder.CancelReason__c        = ifOrder.ABGRU__c;
                newOrder.ReturnOrderNumber__c   = ifOrder.ZRETURNS__c;
                newOrder.Incoterms__c           = ifOrder.INCO1__c;
                newOrder.ShippingConditions__c  = ifOrder.VSBED__c;
                newOrder.Product__c             = ifOrder.MATNR__c;
                newOrder.SerialNumber__c        = ifOrder.EQUNR__c;


                if(isNew) {
                    newOItem.ItemCategory__c    = ifOrder.AUART__c == 'ZUSO' ? ordSvc.ITEM_ACCESSORY : ordSvc.ITEM_PRODUCT;
                    
                    newOrder.RecordTypeId       = DNSARecordTypeId;
                    newOrder.OrderType__c       = ifOrder.AUART__c;
                    newOrder.PurchaseOrderNo__c = ifOrder.BSTKD__c;
                    newOrder.CustomerOrderNo__c = ifOrder.BSTKD__c;
                    newOrder.CurrencyIsoCode    = ifOrder.WAERK__c;
                    newOrder.DNSA_SalesOffice__c= ifOrder.VKBUR__c;
                    newOrder.EffectiveDate      = Date.today();
                    newOrder.Pricebook2Id       = stdPriceBookId;

                    newOrder.SoldTo__c          = accCodeMap.get(ifOrder.KUNNR_AG__c)?.Id;
                    newOrder.BillTo__c          = accCodeMap.get(ifOrder.KUNNR_RE__c)?.Id;
                    newOrder.Payer__c           = accCodeMap.get(ifOrder.KUNNR_RG__c)?.Id;
                    newOrder.SalesRep__c        = accCodeMap.get(ifOrder.KUNNR_ZM__c)?.Id;
                    newOrder.CreditDealer__c    = accCodeMap.get(ifOrder.KUNNR_Z2__c)?.Id;
                    newOrder.AccountId          = newOrder.ShipTo__c;

                    newOrder.SalesOrganization__c   = ifOrder.VKORG__c;
                    newOrder.DistributionChannel__c = ifOrder.VTWEG__c;
                    newOrder.Division__c            = ifOrder.SPART__c;
                    newOrder.Country__c = accCodeMap.get(ifOrder.KUNNR_WE__c)?.CountryLookup__r.CountryCode__c;
                    if(newOrder.Country__c == null) newOrder.Country__c = 'None';

                    String tempStatus = ordSvc.ORDER_SUBMITTED;
                    if(String.isNotBlank(newOrder.ReturnOrderNumber__c)) { tempStatus = ordSvc.ORDER_Returned; }
                    else if(newOrder.CancelReason__c != null) { tempStatus = ordSvc.ORDER_CANCELED; }
                    else if(newOrder.IF_IsERPConfirmed__c) { tempStatus = ordSvc.ORDER_CONFIRMED_DNSA; }
                    newOrder.Status = tempStatus;

                    newOrder.SalesChannelType__c = ordSvc.CHANNER_DNSA;
                } 

                if(psoMap.containsKey(erpOrderNo)) {
                    IF_Order__c ifPSOOrder = psoMap.get(erpOrderNo);
                    newOrder.IF_DO__c               = ifPSOOrder.VBELN__c;
                    newOrder.ERPPSONo__c            = ifPSOOrder.PSO_NUM__c;
                    newOrder.PSO_ShippingCompany__c = ifPSOOrder.NAME1__c;

                    newOrder.PSO_ETD__c = ifPSOOrder.ZFETD__c.startsWith('0000') ? null : Date.valueOf(ifPSOOrder.ZFETD__c);
                    newOrder.PSO_ETA__c = ifPSOOrder.ZFETA__c.startsWith('0000') ? null : Date.valueOf(ifPSOOrder.ZFETA__c);
                    newOrder.ActualShippingDate__c = ifPSOOrder.WADAT_IST__c.startsWith('0000') ? null : Date.valueOf(ifPSOOrder.WADAT_IST__c);
                }
                
                toUpsertOrders.add(newOrder);
                prodItemMap.put(erpOrderNo, newOItem);
            } else if (sqTarget.contains(ifOrder.MATNR__c)){ // SQ
                if(isNew) {
                    newOItem.ItemCategory__c  = ordSvc.ITEM_SQ;
                    newOItem.SQTitle__c       = ifOrder.MAKTX__c;
                }
            } else { // Accessory
                if(isNew) {
                    newOItem.ItemCategory__c  = ordSvc.ITEM_SQ;
                    newOItem.AccessoryCode__c = ifOrder.MATNR__c;
                }
            }
            newOItem.Key__c      = itemKey;
            newOItem.IF_POSNR__c = erpPOSNR;

            newOItem.ShipTo__c      = accCodeMap.get(ifOrder.KUNNR_WE__c)?.Id;
            newOItem.BillingDate__c = ifOrder.FKDAT__c.startsWith('0000') ? null : Date.valueOf(ifOrder.FKDAT__c);
            newOItem.ReqShipDate__c = ifOrder.VDATU__c.startsWith('0000') ? null : Date.valueOf(ifOrder.VDATU__c);
            newOItem.Unit__c        = ifOrder.VRKME__c;
            newOItem.Quantity       = Decimal.valueOf(ifOrder.BMENG__c);

            newOItem.UnitPrice = Decimal.valueOf(ifOrder.NETWR_AMT__c);
            newOItem.Tax__c    = Decimal.valueOf(ifOrder.TAX_AMT__c);

            if(newOItem.Quantity > 1) {
                newOItem.UnitPrice = newOItem.UnitPrice == 0 ? 0 : (newOItem.UnitPrice / newOItem.Quantity).setScale(2, System.RoundingMode.HALF_UP);
                newOItem.Tax__c    = newOItem.Tax__c == 0 ? 0 : (newOItem.Tax__c / newOItem.Quantity).setScale(2, System.RoundingMode.HALF_UP);
            }

            targetItems.add(newOItem);
        }

        Map<String, String> errorOrderMap = new Map<String, String>();
        List<Database.UpsertResult> addedOrder = Database.upsert(toUpsertOrders, Order.Fields.ERPRSONo__c, false);
        Map<String, Id> allOrderIdMap = new Map<String, Id>(); // key : erp order no, value : order id
        for(Integer i = 0; i < addedOrder.size(); i++) {
            Database.UpsertResult ur = addedOrder[i];
            Order targetOrder = toUpsertOrders[i];
            if(ur.isSuccess()) {
                allOrderIdMap.put(targetOrder.ERPRSONo__c, ur.getId());
                orderIds.add(ur.getId());
            } else {
                errorOrderMap.put(targetOrder.ERPRSONo__c, String.valueOf(ur.getErrors()));
            }
        }

        // Upsert Order Items
        List<OrderItem> toUpsertItems  = new List<OrderItem>();
        Map<String, String> errorOrderItemMap = new Map<String, String>();
        for(OrderItem item : targetItems) {
            String orderNo = item.Key__c.split('_')[0];

            String errorMsg = errorOrderMap.containsKey(orderNo) ? errorOrderMap.get(orderNo) + ' / ' : '';
            Boolean hasError = false;
            if(!allOrderIdMap.containsKey(orderNo)) { // No Order
                errorMsg += 'No Order to mapping';
                hasError = true;
            } else if(!prodItemMap.containsKey(orderNo)) { // NO Product
                errorMsg += 'No product to mapping (000010)';
                hasError = true;
            } 

            if(hasError) {
                errorMsg = errorMsg.length() > 254 ? errorMsg.substring(0, 254) : errorMsg;
                errorOrderItemMap.put(item.Key__c, errorMsg);
                continue;
            }

            item.OrderId = allOrderIdMap.get(orderNo);
            if(item.ItemCategory__c != 'Product') {
                OrderItem prodItem    = prodItemMap.get(orderNo);
                item.Product2Id       = prodItem.Product2Id;
                item.PricebookEntryId = prodItem.PricebookEntryId;
            }
            toUpsertItems.add(item);
        }
        
        List<Database.UpsertResult> addedItems = Database.upsert(toUpsertItems, OrderItem.Fields.Key__c, false);
        Set<Id> newSQIdSet = new Set<Id>();
        for(Integer i = 0; i < addedItems.size(); i++) {
            Database.UpsertResult ur = addedItems[i];
            if(ur.isSuccess()) {
                if(ur.isCreated()) { newSQIdSet.add(ur.getId()); }
            } else {
                OrderItem failOrderItem = toUpsertItems[i];
                String orderNo = failOrderItem.Key__c.split('_')[0];
                String errorMsg = errorOrderMap.containsKey(orderNo) ? errorOrderMap.get(orderNo) + ' / ' + String.valueOf(ur.getErrors()) : String.valueOf(ur.getErrors());
                errorMsg = errorMsg.length() > 254 ? errorMsg.substring(0, 254) : errorMsg;
                errorOrderItemMap.put(failOrderItem.Key__c, errorMsg);
            }
        }

        // Update new SQ items
        List<OrderItem> newSQItems = new List<OrderItem>();
        for(OrderItem oItem : toUpsertItems) {
            if(newSQIdSet.contains(oItem.Id) && oItem.ItemCategory__c == ordSvc.ITEM_SQ) {
                oItem.IsERPSQ__c = true;
                newSQItems.add(oItem);
            }
        }
        if(!newSQItems.isEmpty()) update newSQItems;

        List<IF_Order__c> convertFlags = new List<IF_Order__c>();
        for(IF_Order__c if_order : ifOrders) {
            String orderNo = if_order.TABLE_NAME__c == 'T_ORDER' ? if_order.VBELN__c : if_order.VBELN_SO__c;
            String key = orderNo + '_' + if_order.POSNR__c;

            if(errorOrderItemMap.containsKey(key))  {
                if_order.ERRORMSG__c = errorOrderItemMap.get(key);
            } else {
                if_order.IsConverted__c = true;
                if_order.ERRORMSG__c    = '';
            }
            convertFlags.add(if_order);
        }

        update convertFlags; // IsConverted__c
        
    }

    global void finish(Database.BatchableContext bc){
        System.debug('DNSA_OrderERPToCRMBatch - finished');
        IF_AssetOrderUpdateBatch assetOrderUpdateBatch  = new IF_AssetOrderUpdateBatch(orderIds);
        Database.executeBatch(assetOrderUpdateBatch,200);        
    }

    public void execute( SchedulableContext SC){
        DataBase.executeBatch( new DNSA_OrderERPToCRMBatch(), 50 );
        /*
        String cron10 = '0 10 * * * ?';
        System.schedule('DNSA_OrderERPToCRMBatch10', cron10, new DNSA_OrderERPToCRMBatch());
        
        String cron40 = '0 40 * * * ?';
        System.schedule('DNSA_OrderERPToCRMBatch40', cron40, new DNSA_OrderERPToCRMBatch());
        */

        /*
        [T_ORDER]
        - Order
        VBELN__c     : ERPRSONo__c
        PSO_NUM__c   : ERPPSONo__c
        AUART__c     : OrderType__c
        BSTKD__c     : CustomerOrderNo__c, PurchaseOrderNo__c
        WAERK__c     : CurrencyIsoCode
        ZTERM__c     : PaymentTerms__c
        VDATU__c     : RequestedShipDate__c
        KUNNR_AG__c  : SoldTo__r.CustomerCode__c
        KUNNR_WE__c  : ShipTo__r.CustomerCode__c
        KUNNR_RE__c  : BillTo__r.CustomerCode__c
        KUNNR_RG__c  : Payer__r.CustomerCode__c
        KUNNR_ZM__c  : SalesRep__r.CustomerCode__c
        KUNNR_Z2__c  : CreditDealer__r.CustomerCode__c
        ZZSTATUS__c  : IF_IsERPConfirmed__c
        ABGRU__c     : CancelReason__c
        EQUNR__c     : SerialNumber__c
        AUGRU__c     : OrderReason__c
        WADAT_IST__c : ActualShippingDate__c
        ZDELFLAG__c  : IsOrderDeleted__c
        ZRETURNS__c  : ReturnOrderNumber__c
        INCO1__c     : Incoterms__c
        VKBUR__c     : DNSA_SalesOffice__c
        IHREZ__c     : StockOrder__c
        VSBED__c     : ShippingConditions__c
        MATNR__c(10) : Product__c
        VKORG__c     : SalesOrganization__c
        VTWEG__c     : DistributionChannel__c
        SPART__c     : Division__c

        - Order Product
        POSNR__c     : IF_POSNR__c
        MATNR__c     : Product.ProductCode
        MAKTX__c     : Product.ProductName
        BMENG__c     : Quantity
        VRKME__c     : Unit__c
        NETWR_AMT__c : UnitPrice
        TAX_AMT__c   : Tax__c
        FKDAT__c     : BillingDate__c
        VDATU__c     : ReqShipDate__c
        KUNNR_WE__c  : ShipTo__c

        [T_ZCRMS0094]
        VBELN_SO__c : ERPRSONo__c
        PSO_NUM__c  : ERPPSONo__c
        VBELN__c    : IF_DO__c
        ZFETD__c    : PSO_ETD__c
        ZFETA__c    : PSO_ETA__c
        NAME1__c    : PSO_ShippingCompany__c
        */
    }
}