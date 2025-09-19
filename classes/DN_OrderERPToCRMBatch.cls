/**
 * @description       : ERP To CRM
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-26   yeongju.yun   Initial Version
 * 1.1   2025-03-20   yeongju.yun   Edit01. 필드 추가 (Incoterms__c, MainCategory__c, SubCategory__c, IsTooling__c, PriceList__c, SalesDistrict__c)
 *                                  Edit02. Account 정보는 같은 customer code면 dealer 우선으로 맵핑
 * 1.2   2025-04-15   yeongju.yun   Edit03. 일반 주문도 upsert로 변경
 * 1.3   2025-04-21   yeongju.yun   Edit04. 주문 타입에 ZSQ 추가
 * 1.4   2025-04-23   yeongju.yun   Edit05. 주문 타입이 ZPSA일 경우 2번대 번호가 없어도 Confirm만 되면 Mapped 상태로 변경
 * 1.5   2025-04-25   yeongju.yun   Edit06. RDD, Ship To, 2번대 번호 있을 때와 없을 때 적재 필드 변경
 * 1.6   2025-05-09   yeongju.yun   Edit07. LIFSK__c (IsDOBlock__c) 값이 있으면 DO Block
 * 1.7   2025-05-14   yeongju.yun   Edit08. ZRE(반품오더)
 * 1.8   2025-05-16   yeongju.yun   Edit09. ZZAPPNO 포탈ID Owner지정
 * 1.9   2025-05-28   yeongju.yun   Edit10. ZZSOCHAN__c 추가 / Consignment(CON), Wholesale(HOL), Direct(DRT)
 * 2.0   2025-05-29   yeongju.yun   Edit11. 글로벌(Distribution Channel == 20), Status(Confirm, Mapped)일 때는 신규가 아니어도 가격 업데이트
**/
global without sharing class DN_OrderERPToCRMBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static DN_OrderService ordSvc = new DN_OrderService();

    public DN_OrderERPToCRMBatch() {}

    public Set<String> orderIds = new Set<String>(); 

    public Set<String> completedSet = new Set<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('IF_ORDER__c').getDescribe().fields.getMap();
        String queryFields = String.join(new List<String>(fieldMap.keySet()), ', ');
        String query = ' SELECT ' + queryFields + ' FROM IF_ORDER__c WHERE IsConverted__c = false AND IsDNSA__c = false AND POSNR__c = \'000010\'';

        System.debug('DN_OrderERPToCRMBatch - QueryLocator - query ::: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<IF_Order__c> scope) {

        Set<String> targetOrderNoSet = new Set<String>();
        for(IF_Order__c ifOrder : scope) {
            if(completedSet.contains(ifOrder.VBELN__c)) continue;
            completedSet.add(ifOrder.VBELN__c);

            targetOrderNoSet.add(ifOrder.VBELN__c);
        }
        List<String> targetOrderNos = new List<String>(targetOrderNoSet);

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('IF_ORDER__c').getDescribe().fields.getMap();
        String queryFields = String.join(new List<String>(fieldMap.keySet()), ', ');
        String query = ' SELECT ' + queryFields + ' FROM IF_ORDER__c '
                     + ' WHERE IsConverted__c = false AND IsDNSA__c = false AND VBELN__c IN :targetOrderNos '
                     + ' ORDER BY VBELN__c, POSNR__c ';
        List<IF_ORDER__c> ifOrders = Database.query(query);

        List<Order> toUpsertOrders = new List<Order>();
        List<OrderItem> orderItems = new List<OrderItem>();

        Set<String> orderNoSet     = new Set<String>();
        Set<String> orderKeySet    = new Set<String>();
        Set<String> customerNoSet  = new Set<String>();
        Set<String> prodSet        = new Set<String>();
        Set<String> erpOptySet     = new Set<String>();
        Set<String> erpQuoteSet    = new Set<String>();
        Set<String> prodNewCodeSet = new Set<String>();

        List<IF_Order__c> targetIFList = new List<IF_Order__c>();

        // Edit04. 주문 타입에 ZSQ 추가
        Set<String> targetOrderType = new Set<String>{'ZPO', 'ZPS', 'ZPSA', 'ZSQ'};
        Set<String> employeeNoSet   = new Set<String>();
        Map<String, List<IF_Order__c>> returnMap = new Map<String, List<IF_Order__c>>(); // key : erp no, value : if order, Edit08. ZRE(반품오더)
        for(IF_Order__c ifOrder : ifOrders) {
            if(ifOrder.AUART__c == 'ZRE') { 
                List<IF_Order__c> innerRetruns = returnMap.containsKey(ifOrder.VBELN__c) ? returnMap.get(ifOrder.VBELN__c) : new List<IF_Order__c>();
                innerRetruns.add(ifOrder);
                returnMap.put(ifOrder.VBELN__c, innerRetruns); 
            }
            
            if(!targetOrderType.contains(ifOrder.AUART__c)) continue;
            targetIFList.add(ifOrder);
            if(String.isNotBlank(ifOrder.ZZAPPNO__c)) employeeNoSet.add(ifOrder.ZZAPPNO__c);

            orderKeySet.add(ifOrder.VBELN__c + '_' + ifOrder.POSNR__c);
            if(String.isNotBlank(ifOrder.KUNNR_AG__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_AG__c)); }
            if(String.isNotBlank(ifOrder.KUNNR_RE__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_RE__c)); }
            if(String.isNotBlank(ifOrder.KUNNR_RG__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_RG__c)); }
            if(String.isNotBlank(ifOrder.KUNNR_WE__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_WE__c)); }
            if(String.isNotBlank(ifOrder.KUNNR_ZM__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_ZM__c)); }
            if(String.isNotBlank(ifOrder.KUNNR_ZI__c)) { customerNoSet.add(ordSvc.formatCodeForSAP(ifOrder.KUNNR_ZI__c)); }

            if(String.isNotBlank(ifOrder.VBELN_I__c)) {
                erpOptySet.add(ordSvc.formatCodeForSAP(ifOrder.VBELN_I__c));
                erpOptySet.add(ordSvc.formatCodeForSAP(10, ifOrder.VBELN_I__c));
            }
            if(String.isNotBlank(ifOrder.VBELN_Q__c)) {
                erpQuoteSet.add(ordSvc.formatCodeForSAP(ifOrder.VBELN_Q__c));
                erpQuoteSet.add(ordSvc.formatCodeForSAP(10, ifOrder.VBELN_Q__c));
            }
            
            if(ifOrder.MTART__c == 'FPRO' || (ifOrder.AUART__c == 'ZPSA' && ifOrder.POSNR__c == '000010' )) {
                prodSet.add(ifOrder.MATNR__c);
                prodNewCodeSet.add(ifOrder.MATNR__c);
            }
        }

        // previous order
        List<OrderItem> prevOrderItems = [SELECT Id, F_Key__c, Order.ERPOrderNo__c, Order.Status FROM OrderItem WHERE F_Key__c =: orderKeySet];
        Set<String> prevOrderItemKeys = new Set<String>();
        Map<String, String> orderStatusMap = new Map<String, String>(); // key : order erp no, value : order status
        for(OrderItem oItem : prevOrderItems) {
            prevOrderItemKeys.add(oItem.F_Key__c);
            orderStatusMap.put(oItem.Order.ERPOrderNo__c, oItem.Order.Status);
        }

        // order owner 
        List<User> owners = [SELECT Id, Portal_EmployeeNumber__c, CustomerCode__c FROM User WHERE IsActive = TRUE AND (Portal_EmployeeNumber__c =: employeeNoSet OR CustomerCode__c =:employeeNoSet ) ];
        Map<String, Id> ownerMap = new Map<String, Id>(); // key : employee no, value : user id (owner)
        for(User u : owners) {
            String emp = String.isNotBlank(u.Portal_EmployeeNumber__c) ? u.Portal_EmployeeNumber__c : u.CustomerCode__c;
            ownerMap.put(emp, u.Id);
        }

        // Account (SoldTo__c, BillTo__c, Payer__c, ShipTo__c, SalesRep__c, RelatedDealer__c)
        List<Account> accList = [SELECT Id, CustomerCode__c, RecordType.DeveloperName, Country__c FROM Account WHERE CustomerCode__c =: customerNoSet];
        Map<String, Account> accCodeMap = new Map<String, Account>(); // key : account customer code, value : account
        for(Account acc : accList) {
            String accNo = ordSvc.formatCodeForSAP(10, acc.CustomerCode__c);

            // 20250320 같은 customer code면 dealer 우선
            if(accCodeMap.containsKey(accNo)) {
                if(acc.RecordType.DeveloperName == 'Dealer') { accCodeMap.put(accNo, acc); }
            } else {
                accCodeMap.put(accNo, acc);
            }
        }

        // Pricebook2
        Pricebook2 priceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true ];

        // Product Record Type
        RecordType prodType = [SELECT Id FROM RecordType WHERE SobjectType = 'Product2' AND DeveloperName =: ordSvc.PROD_RECORDTYPE];
        
        // Product
        List<Product2> prodList = [SELECT Id, Name, ProductCode, Name__c FROM Product2 WHERE ProductCode =: prodSet AND RecordTypeId =: prodType.Id];
        Map<String, Id> prodCodeMap = new Map<String, Id>(); // key : product code, value : product2 id
        for(Product2 prod : prodList) {
            prodCodeMap.put(prod.ProductCode, prod.Id);
            prodNewCodeSet.remove(prod.ProductCode);
        }

        if(!prodNewCodeSet.isEmpty()) {
            List<Product2> newProdList = new List<Product2>();
            for(IF_Order__c ifOrder : targetIFList) {
                if(prodNewCodeSet.contains(ifOrder.MATNR__c)) {
                    Product2 prod         = new Product2();
                    prod.Name             = ifOrder.MATNR__c;
                    prod.ProductCode      = ifOrder.MATNR__c;
                    prod.Name__c          = ifOrder.MAKTX__c;
                    prod.CurrencyIsoCode  = ifOrder.WAERK__c;
                    prod.IsActive         = true;
                    prod.RecordTypeId     = prodType.Id;
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
                entry.Pricebook2Id    = priceBook.Id;
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

        // Opportunity
        List<OpportunityLineItem> optyList = [SELECT Id, OpportunityId, ERPInquiryNo__c, Opportunity.AccountId, Opportunity.OwnerId FROM OpportunityLineItem WHERE ERPInquiryNo__c =: erpOptySet];
        Map<String, OpportunityLineItem> optyMap = new Map<String, OpportunityLineItem>(); // key : erp inquiry no, value : opportunity line item
        for(OpportunityLineItem optyItem : optyList) {
            String optyInqNo = ordSvc.formatCodeForSAP(10, optyItem.ERPInquiryNo__c);
            optyMap.put(optyInqNo, optyItem);
        }

        // Quote VBELN_Q__c
        List<QuoteLineItem> quoteList = [SELECT Id, QuoteId, ERPQuotationNo__c FROM QuoteLineItem WHERE ERPQuotationNo__c =: erpQuoteSet];
        Map<String, QuoteLineItem> quoteMap = new Map<String, QuoteLineItem>(); // key : erp quote no, value : quote line item
        for(QuoteLineITem quoteItem : quoteList) {
            String quoteNo = ordSvc.formatCodeForSAP(10, quoteItem.ERPQuotationNo__c);
            quoteMap.put(quoteNo, quoteItem);
        }

        List<String> sqTarget = new List<String>{'PS100', 'PS200', 'PS300', 'SQ100', 'SQ200', 'SQ300'};
        List<String> globalUdtStatus = new List<String>{ordSvc.ORDER_MAPPED, ordSvc.ORDER_CONFIRMED};
        Map<String, OrderItem> prodItemMap  = new Map<String, OrderItem>(); // key : erp order no, value : order item (base code only)
        Map<String, String> errorOrderMap = new Map<String, String>();
        Map<String, String> updatedStatusMap = new Map<String, String>(); // key : erp order no, value : status
        for(IF_Order__c ifOrder : targetIFList) {

            String erpOrderNo = ifOrder.VBELN__c;
            String erpPOSNR   = ifOrder.POSNR__c;
            String itemKey    = erpOrderNo + '_' + erpPOSNR;
            String entryKey   = prodCodeMap.get(ifOrder.MATNR__c) + '_' + ifOrder.WAERK__c;

            Boolean isTurnKey = ifOrder.AUART__c != 'ZPO' && ifOrder.AUART__c != 'ZSQ';
            Boolean isNew     = !prevOrderItemKeys.contains(itemKey);

            OrderItem newOItem = new OrderItem();

            if(ifOrder.MTART__c == 'FPRO' || (ifOrder.AUART__c == 'ZPSA' && ifOrder.POSNR__c == '000010' )) { // product

                if(prodCodeMap.containsKey(ifOrder.MATNR__c) && entryMap.containsKey(entryKey)){
                    newOItem.PricebookEntryId = entryMap.get(entryKey);
                    newOItem.Product2Id       = prodCodeMap.get(ifOrder.MATNR__c);
                } else {
                    String prodErrorMsg = '';
                    if(!prodCodeMap.containsKey(ifOrder.MATNR__c)) prodErrorMsg = 'no prod : ' + ifOrder.MATNR__c + ' / ';
                    if(!entryMap.containsKey(entryKey)) prodErrorMsg += 'no price entry : ' + entryKey;
                    errorOrderMap.put(erpOrderNo, prodErrorMsg);
                    continue;
                }
                
                // order
                Order newOrder     = new Order();
                newOrder.ERPOrderNo__c          = erpOrderNo;
                newOrder.PaymentTerms__c        = ifOrder.ZTERM__c;
                newOrder.ERPPSONo__c            = ifOrder.IHREZ__c;
                newOrder.RelatedDealer__c       = accCodeMap.get(ifOrder.KUNNR_ZI__c)?.Id;
                newOrder.CancelReason__c        = ifOrder.ABGRU__c;
                newOrder.ActualShippingDate__c  = ifOrder.WADAT_IST__c.startsWith('0000') ? null : Date.valueOf(ifOrder.WADAT_IST__c);
                newOrder.IF_DO__c               = ifOrder.VBELN_D__c;
                newOrder.SerialNumber__c        = ifOrder.SERNR__c;
                newOrder.IF_IsERPConfirmed__c   = ifOrder.ZZSTATUS__c == 'C';
                newOrder.IsOrderDeleted__c      = ifOrder.ZDELFLAG__c == 'X';
                newOrder.Incoterms__c           = ifOrder.INCO1__c;
                newOrder.Product__c             = ifOrder.MATNR__c;
                newOrder.IsDOBlock__c           = String.isNotBlank(ifOrder.LIFSK__c); // Edit07. LIFSK__c (IsDOBlock__c) 값이 있으면 DO Block
                
                if(String.isNotBlank(ifOrder.ZZSOCHAN__c)) {
                    String segStr = ifOrder.ZZSOCHAN__c == 'DRT' ? 'DirectSales' : ifOrder.ZZSOCHAN__c == 'CON' ? 'Consignment' : 'Wholesale';
                    newOrder.OrderSegmentation__c = segStr; // Edit10. ZZSOCHAN__c 추가 / Consignment(CON), Wholesale(HOL), Direct(DRT)
                }

                // Edit06. RDD, Ship To, 2번대 번호 있을 때와 없을 때 적재 필드 변경
                if(String.isBlank(ifOrder.IHREZ__c)) { 
                    newOrder.ReqDeliveryDate__c = ifOrder.VDATU__c.startsWith('0000') ? null : Date.valueOf(ifOrder.VDATU__c);
                    newOrder.ShipTo__c          = accCodeMap.get(ifOrder.KUNNR_WE__c)?.Id;
                 } else {
                    newOrder.ReqDeliveryDate_PSO__c = ifOrder.VDATU__c.startsWith('0000') ? null : Date.valueOf(ifOrder.VDATU__c);
                    newOrder.ShipTo_PSO__c          = accCodeMap.get(ifOrder.KUNNR_WE__c)?.Id;
                 }
                 //Order Type이 ZPSA인 경우에도 그냥 SHipTo_PSO__c에 ShipTo__c 동일 정보를 넣어서 DO생성에 문제 없게 추가_250818_권세진
                 if(ifOrder.AUART__c == 'ZPSA') {
                    newOrder.ReqDeliveryDate_PSO__c = ifOrder.VDATU__c.startsWith('0000') ? null : Date.valueOf(ifOrder.VDATU__c);
                    newOrder.ShipTo_PSO__c          = accCodeMap.get(ifOrder.KUNNR_WE__c)?.Id;
                 }

                 // Edit09. ZZAPPNO 포탈ID Owner지정
                 if(ownerMap.containsKey(ifOrder.ZZAPPNO__c)) {
                    newOrder.OwnerId = ownerMap.get(ifOrder.ZZAPPNO__c);
                 }

                newOrder.IF_FreePass__c = true;

                String tempStatus = orderStatusMap.get(erpOrderNo) == null ? ordSvc.ORDER_PROGRESS : orderStatusMap.get(erpOrderNo);
                if(String.isNotBlank(ifOrder.ZRETURNS__c) || tempStatus == ordSvc.ORDER_Returned) { tempStatus = ordSvc.ORDER_Returned; }
                else if(String.isNotBlank(ifOrder.ABGRU__c) || tempStatus == ordSvc.ORDER_CANCELED) { tempStatus = ordSvc.ORDER_CANCELED; }
                else if(String.isNotBlank(ifOrder.VBELN_D__c) || tempStatus == ordSvc.ORDER_DELIVERY) { tempStatus = ordSvc.ORDER_DELIVERY; }
                else if(String.isNotBlank(ifOrder.IHREZ__c) || tempStatus == ordSvc.ORDER_MAPPED) { tempStatus = ordSvc.ORDER_MAPPED; }
                else if(ifOrder.ZZSTATUS__c == 'C' && ifOrder.AUART__c == 'ZPSA') { tempStatus = ordSvc.ORDER_MAPPED; }
                else if(ifOrder.ZZSTATUS__c == 'C' || tempStatus == ordSvc.ORDER_CONFIRMED) { tempStatus = ordSvc.ORDER_CONFIRMED; }
                newOrder.Status = tempStatus;

                updatedStatusMap.put(erpOrderNo, tempStatus);

                if(isNew) {
                    newOrder.CurrencyIsoCode    = ifOrder.WAERK__c;
                    newOrder.EffectiveDate      = Date.today();
                    newOrder.Pricebook2Id       = priceBook.Id;
                    newOrder.CustomerOrderNo__c = ifOrder.BSTKD__c;
                    newOrder.PurchaseOrderNo__c = ifOrder.BSTKD__c;
                    newOrder.OrderType__c       = ifOrder.AUART__c;

                    newOrder.SoldTo__c          = accCodeMap.get(ifOrder.KUNNR_AG__c)?.Id;
                    newOrder.BillTo__c          = accCodeMap.get(ifOrder.KUNNR_RE__c)?.Id;
                    newOrder.Payer__c           = accCodeMap.get(ifOrder.KUNNR_RG__c)?.Id;
                    newOrder.SalesRep__c        = accCodeMap.get(ifOrder.KUNNR_ZM__c)?.Id;
                    newOrder.ShipTo__c          = accCodeMap.get(ifOrder.KUNNR_WE__c)?.Id;

                    newOrder.ReqDeliveryDate__c = ifOrder.VDATU__c.startsWith('0000') ? null : Date.valueOf(ifOrder.VDATU__c);

                    newOrder.SalesOrganization__c   = ifOrder.VKORG__c;
                    newOrder.DistributionChannel__c = ifOrder.VTWEG__c;
                    newOrder.Division__c            = ifOrder.SPART__c;
                    newOrder.SalesOffice__c         = ifOrder.VKBUR__c;
                    newOrder.SalesDistrict__c       = ifOrder.BZIRK__c;

                    newOrder.MainCategory__c        = ifOrder.KVGR1__c;
                    newOrder.SubCategory__c         = ifOrder.KVGR2__c;
                    newOrder.IsTooling__c           = ifOrder.KVGR3__c;
                    newOrder.PriceList__c           = ifOrder.PLTYP__c;
                    newOrder.SalesChannelType__c    = newOrder.DistributionChannel__c == '20' ? ordSvc.CHANNER_OVERSEAS : 'None'; // temp value

                    if(optyMap.containsKey(ifOrder.VBELN_I__c)) {
                        OpportunityLineItem tempOptyItem = optyMap.get(ifOrder.VBELN_I__c);

                        newOrder.OpportunityId = tempOptyItem.OpportunityId;
                        newOrder.AccountId     = tempOptyItem.Opportunity.AccountId;
                        newOrder.IsTurnKey__c  = isTurnKey;

                        newOrder.OpportunityProduct__c = tempOptyItem.Id;

                        if(newOrder.OwnerId == null) { newOrder.OwnerId = tempOptyItem.Opportunity.OwnerId; }

                        if(isTurnKey) {
                            toUpsertOrders.add(newOrder);
                        } else { // general -> update only -> 250415 upsert
                            if(quoteMap.containsKey(ifOrder.VBELN_Q__c)) {
                                QuoteLineItem tempQuoteItem = quoteMap.get(ifOrder.VBELN_Q__c);
                                newOItem.QuoteLineItemId = tempQuoteItem.Id;
                                newOrder.QuoteId = tempQuoteItem.QuoteId;
                                toUpsertOrders.add(newOrder);
                            } else {
                                toUpsertOrders.add(newOrder);
                            }
                        }
                    } else {
                        newOrder.AccountId  = newOrder.ShipTo__c;
                        newOrder.Country__c = ifOrder.WAERK__c == 'KRW' ? 'KR' : accCodeMap.get(ifOrder.KUNNR_WE__c)?.Country__c;
                        if(newOrder.Country__c == null) { newOrder.Country__c = 'None'; }
                        toUpsertOrders.add(newOrder); 
                    }
                } else { // old
                    toUpsertOrders.add(newOrder);
                }

                // order product
                newOItem.ItemCategory__c = ifOrder.AUART__c == 'ZPSA' ? ordSvc.ITEM_SQ : ordSvc.ITEM_PRODUCT;
                prodItemMap.put(erpOrderNo, newOItem);

            } else if (sqTarget.contains(ifOrder.MATNR__c)) { // SQ
                newOItem.ItemCategory__c  = ordSvc.ITEM_SQ;
                newOItem.SQTitle__c       = ifOrder.ARKTX__c;
                // IsInspection__c : ERP > CRM 생성 시 입회검사 여부 판단 불가.

            } else { // Accessory
                newOItem.ItemCategory__c  = ordSvc.ITEM_ACCESSORY;
                newOItem.AccessoryCode__c = ifOrder.MATNR__c;
            }

            newOItem.Key__c      = itemKey;
            newOItem.IF_POSNR__c = erpPOSNR;

            newOItem.BillingDate__c = ifOrder.FKDAT__c.startsWith('0000') ? null : Date.valueOf(ifOrder.FKDAT__c);
            
            // Edit11. 글로벌(Distribution Channel == 20), Status(Confirm, Mapped)일 때는 신규가 아니어도 가격 업데이트
            String orderStatus = updatedStatusMap.containsKey(erpOrderNo) ? updatedStatusMap.get(erpOrderNo) : 'No Status';
            if(isNew || (!isNew && ifOrder.VTWEG__c == '20' && globalUdtStatus.contains(orderStatus))) {
                newOItem.UnitPrice        = Decimal.valueOf(ifOrder.NETWR_AMT__c);
                newOItem.Tax__c           = Decimal.valueOf(ifOrder.TAX_AMT__c);
                newOItem.Quantity         = Decimal.valueOf(ifOrder.BMENG__c);
                newOItem.Unit__c          = ifOrder.VRKME__c;

                if(ifOrder.WAERK__c == 'KRW') {
                    newOItem.UnitPrice = newOItem.UnitPrice * 100;
                    newOItem.Tax__c    = newOItem.Tax__c * 100;
                }

                if(newOItem.Quantity > 1) {
                    newOItem.UnitPrice = (newOItem.UnitPrice / newOItem.Quantity).setScale(2, System.RoundingMode.HALF_UP);
                    newOItem.Tax__c    = (newOItem.Tax__c / newOItem.Quantity).setScale(2, System.RoundingMode.HALF_UP);
                }
            }
            
            orderItems.add(newOItem);
        }

        // Upsert Orders
        List<Database.UpsertResult> addedOrder = Database.upsert(toUpsertOrders, Order.Fields.ERPOrderNo__c, false);
        Map<String, Id> allOrderIdMap = new Map<String, Id>(); // key : erp order no, value : order id
        for(Integer i = 0; i < addedOrder.size(); i++) {
            Database.UpsertResult ur = addedOrder[i];
            Order targetOrder = toUpsertOrders[i];
            if(ur.isSuccess()) {
                orderIds.add(ur.id);
                allOrderIdMap.put(targetOrder.ERPOrderNo__c, ur.getId());
            } else {
                String errorMsgOrder = errorOrderMap.containsKey(targetOrder.ERPOrderNo__c) ? errorOrderMap.get(targetOrder.ERPOrderNo__c) : '';
                errorMsgOrder += String.valueOf(ur.getErrors()) + ' / ';
                errorOrderMap.put(targetOrder.ERPOrderNo__c, errorMsgOrder);
            }
        }

        // Upsert Order Items
        List<OrderItem> toUpsertItems = new List<OrderItem>();
        Map<String, String> errorOrderItemMap = new Map<String, String>();
        for(OrderItem item : orderItems) {
            String orderNo = item.Key__c.split('_')[0];

            String errorMsg = errorOrderMap.containsKey(orderNo) ? errorOrderMap.get(orderNo) : '';
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
                item.QuoteLineItemId  = prodItem.QuoteLineItemId;
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
                String errorMsg = errorOrderMap.containsKey(orderNo) ? errorOrderMap.get(orderNo) + String.valueOf(ur.getErrors()) : String.valueOf(ur.getErrors());
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

        // Update Return Order // Edit08. ZRE(반품오더)
        List<Order> returnOrders = new List<Order>();
        List<Order> targetOrders = [SELECT Id, Status, ERPOrderNo__c, ReturnOrderNumber__c FROM Order WHERE Status <> :ordSvc.ORDER_Returned AND ERPOrderNo__c =: returnMap.keySet()];
        Map<Id, String> returnErrorMap = new Map<Id, String>();
        for(Order tOrder : targetOrders) {

            List<IF_Order__c> innerReturns = returnMap.get(tOrder.ERPOrderNo__c);
            tOrder.Status = ordSvc.ORDER_Returned;
            tOrder.ReturnOrderNumber__c = innerReturns[0].ZRETURNS__c;
            returnOrders.add(tOrder);
        }
        if(!returnOrders.isEmpty()) {
            List<Database.SaveResult> returnResults = Database.update(returnOrders, false);
            for(Integer i = 0; i < returnResults.size(); i++) {
                Database.UpsertResult ur = addedItems[i];
                if(!ur.isSuccess()) {
                    Order failedOrder  = returnOrders[i];
                    String returnError = String.valueOf(ur.getErrors());
                    returnError = returnError.length() > 254 ? returnError.substring(0, 254) : returnError;

                    List<IF_Order__c> innerReturns = returnMap.get(failedOrder.ERPOrderNo__c);
                    for(IF_Order__c innerReturn : innerReturns) {
                        returnErrorMap.put(innerReturn.Id, returnError);
                    }
                }
            }
        }

        List<IF_Order__c> convertFlags = new List<IF_Order__c>();
        for(IF_Order__c if_order : ifOrders) {
            if(if_order.AUART__c == 'ZRE') {
                if(returnErrorMap.containsKey(if_order.Id)) {
                    if_order.ERRORMSG__c = returnErrorMap.get(if_order.Id);
                } else {
                    if_order.IsConverted__c = true;
                    if_order.ERRORMSG__c = '';
                }
            } else {
                String key = if_order.VBELN__c + '_' + if_order.POSNR__c;
                if(errorOrderItemMap.containsKey(key))  {
                    if_order.ERRORMSG__c = errorOrderItemMap.get(key);
                } else {
                    if_order.IsConverted__c = true;
                    if_order.ERRORMSG__c = '';
                }
            }
            convertFlags.add(if_order);
        }

        update convertFlags; // IsConverted__c
    }

    global void finish(Database.BatchableContext bc){
        IF_AssetOrderUpdateBatch assetOrderUpdateBatch  = new IF_AssetOrderUpdateBatch(this.orderIds);
        Database.executeBatch(assetOrderUpdateBatch,200);
    }

    public void execute( SchedulableContext SC){
        DataBase.executeBatch( new DN_OrderERPToCRMBatch(), 50 );

        /*
        VBELN__c     : ERPOrderNo__c
        AUART__c     : OrderType__c
        WAERK__c     : CurrencyIsoCode
        ZTERM__c     : PaymentTerms__c
        VDATU__c     : ReqDeliveryDate__c
        KUNNR_AG__c  : SoldTo__r.CustomerCode__c
        KUNNR_RE__c  : BillTo__r.CustomerCode__c
        KUNNR_RG__c  : Payer__r.CustomerCode__c
        KUNNR_WE__c  : ShipTo__r.CustomerCode__c
        KUNNR_ZM__c  : SalesRep__r.CustomerCode__c
        KUNNR_ZI__c  : RelatedDealer__r.CustomerCode__c
        ABGRU__c     : CancelReason__c
        VKORG__c     : SalesOrganization__c
        VTWEG__c     : DistributionChannel__c
        SPART__c     : Division__c
        WADAT_IST__c : ActualShippingDate__c
        VBELN_D__c   : IF_DO__c
        IHREZ__c     : ERPPSONo__c
        VKBUR__c     : SalesOffice__c
        SERNR__c     : SerialNumber__c
        ZZSTATUS__c  : IF_IsERPConfirmed__c
        BSTKD__c     : CustomerOrderNo__c, PurchaseOrderNo__c
        VBELN_I__c   : QuoteLineItem.ERPInquiryNo__c
        VBELN_Q__c   : QuoteLineItem.ERPQuotationNo__c
        ZDELFLAG__c  : IsOrderDeleted__c
        ZRETURNS__c  : ReturnOrderNumber__c
        MATNR__c     : Product.ProductCode, AccessoryCode__c
        NETWR_AMT__c : UnitPrice
        TAX_AMT__c   : Tax__c
        MAKTX__c     : Product.ProductName
        POSNR__c     : IF_POSNR__c
        MTART__c     : ItemCategory__c
        FKDAT__c     : BillingDate__c
        // MBDAT__c     : DeliveryDate__c 
        BMENG__c     : Quantity
        VRKME__c     : Unit__c
        ARKTX__c     : SQTitle__c
        INCO1__c     : Incoterms__c
        KVGR1__c     : MainCategory__c
        KVGR2__c     : SubCategory__c
        KVGR3__c     : IsTooling__c
        PLTYP__c     : PriceList__c
        BZIRK__c     : SalesDistrict__c
        ZZSOCHAN__c  : OrderSegmentation__c, Consignment(CON), Wholesale(HOL), Direct(DRT)
        */
    }

}