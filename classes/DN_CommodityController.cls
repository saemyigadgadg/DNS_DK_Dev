/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-04-2024   Hanyeong Choi   Initial Version
**/
public with sharing class DN_CommodityController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    private static final Id   recordTypeIdCommo = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    private static final Id   recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
    private static final User currentUser = getCurrentUser();

    /* 견적 status 조회 */
    @AuraEnabled
    public static String getStatus(String recordId){

        try {
            List<Quote> finalCheck = 
            [
                SELECT
                Id,
                IsFinal__c
                FROM
                Quote
                WHERE
                Id =: recordId
            ];
            if(!finalCheck.isEmpty()){
                if(finalCheck[0].IsFinal__c == true){
                    return 'Access is restricted once the final quotation has been finalized.';
                }else{
                    return 'SUCCESS';
                }
            }else{
                return 'SUCCESS';
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return e.getMessage();
        }
    }

    /* DNSA 모델 정보 */
    @AuraEnabled
    public static Map<String, Object> dnsaModelInit(String recordId, String objectName) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getFieldList', getFieldSet(objectName));
            resMap.put('getModelId', getDNSAModelId(recordId));

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* DNSA stock 조회 */
    @AuraEnabled
    public static Map<String, Object> getStockList(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            if(recordId != null) {
                List<QuoteLineItem> qliList = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :recordId];
                if(!qliList.isEmpty()) {
                    resMap.put('flag', 'qliList');
                    resMap.put('msg', 'There is already reserved equipment.');
                    return resMap;
                }
                List<Order> order = [SELECT Id FROM Order WHERE QuoteId = :recordId];
                if(!order.isEmpty()) resMap.put('flag', 'isOrder');
    
                User user = [SELECT Id, SalesOrganization__c, DistributionChannel__c, Division__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                Quote quote = [SELECT Id, DNSAModel__c, DNSAModel__r.BaseCode__c, DNSAModel__r.Name FROM Quote WHERE Id = :recordId LIMIT 1];
                IF_ERP_Order_Classes.IF_ORDER_010_Req req = new IF_ERP_Order_Classes.IF_ORDER_010_Req();
                req.I_ORDER_STS = 'DUELIST';
                req.I_VKORG = '4140';
                if(quote.DNSAModel__c != null) req.I_MATNR = quote.DNSAModel__r.BaseCode__c;
                else req.I_MATNR = '';
            
                IF_ERP_Order instance = new IF_ERP_Order();
                IF_ERP_Order_Classes.IF_ORDER_010_Res result = instance.IF_ORDER_010(req);
    
                if(result.O_RECODE == 'S') {
                    resMap.put('flag', 'success');
    
                    List<InventoryWrapper> iwList = new List<InventoryWrapper>();
                    for(IF_ERP_Order_Classes.IF_ORDER_010_Res_T_ITEM item : result.T_ITEM) {
                        for(IF_ERP_Order_Classes.IF_ORDER_010_Res_T_SQTXT txt : result.T_SQTXT) {
                            if(item.VBELN_ST == txt.VBELN_ST) {
                                InventoryWrapper wrapper = new InventoryWrapper();
                                wrapper.VBELN_ST        = item.VBELN_ST;
                                wrapper.BASE_CODE       = item.BASE_CODE;
                                wrapper.SERIAL_NUMBER   = item.SERIAL_NUMBER;
                                wrapper.LIST_PRICE      = item.LIST_PRICE;
                                wrapper.ADJUSTED_LIST   = item.ADJUSTED_LIST;
                                wrapper.PERCENT_OFF     = item.PERCENT_OFF;
                                wrapper.DEPT            = item.DEPT;
                                wrapper.DNSA_MODEL      = item.DNSA_MODEL;
                                wrapper.ETA_DATE        = item.ETA_DATE != '0000-00-00' ? item.ETA_DATE : '';
                                wrapper.INVENTORY_STS   = item.INVENTORY_STS;
                                wrapper.LOCATION        = item.LOCATION;
                                wrapper.MC_TC           = item.MC_TC;
                                wrapper.ORDER_STS       = item.ORDER_STS;
                                wrapper.PORT            = item.PORT;
                                wrapper.PROD_DATE       = item.PROD_DATE;
                                wrapper.WAERK           = item.WAERK;
                                wrapper.NC              = item.NC;
                                wrapper.OPEN_NOTES      = item.OPEN_NOTES;
                                wrapper.dealerName      = item.DEALER_NAME;
                                wrapper.userName        = item.CUSTOMER_NAME;
                                wrapper.crm1            = item.CRM_ID1;
                                wrapper.crm2            = item.CRM_ID2;
                                wrapper.crm3            = item.CRM_ID3;
                                wrapper.cssClass        = '';
                                wrapper.SQTXT           = txt.SQTXT;
                                iwList.add(wrapper);
                            }
                        }
                    }
                    if(!iwList.isEmpty()) {
                        resMap.put('data', iwList);
                        resMap.put('isPortal', currentUser.IsPortalEnabled);
                        resMap.put('userId', currentUser.Id);
                    }
                } else {
                    resMap.put('flag', 'error');
                    if(result.O_REMSG == 'Error') {
                        resMap.put('msg', 'ERP : Inventory is empty');    
                    } else {
                        resMap.put('msg', 'ERP : ' + result.O_REMSG);
                    }
                }
            } else {
                IF_ERP_Order_Classes.IF_ORDER_010_Req req = new IF_ERP_Order_Classes.IF_ORDER_010_Req();
                req.I_ORDER_STS = 'DUELIST';
                req.I_VKORG = '4140';
                req.I_MATNR = '';
            
                IF_ERP_Order instance = new IF_ERP_Order();
                IF_ERP_Order_Classes.IF_ORDER_010_Res result = instance.IF_ORDER_010(req);
    
                if(result.O_RECODE == 'S') {
                    resMap.put('flag', 'success');
    
                    List<InventoryWrapper> iwList = new List<InventoryWrapper>();
                    for(IF_ERP_Order_Classes.IF_ORDER_010_Res_T_ITEM item : result.T_ITEM) {
                        for(IF_ERP_Order_Classes.IF_ORDER_010_Res_T_SQTXT txt : result.T_SQTXT) {
                            if(item.VBELN_ST == txt.VBELN_ST) {
                                InventoryWrapper wrapper = new InventoryWrapper();
                                wrapper.VBELN_ST        = item.VBELN_ST;
                                wrapper.BASE_CODE       = item.BASE_CODE;
                                wrapper.SERIAL_NUMBER   = item.SERIAL_NUMBER;
                                wrapper.LIST_PRICE      = item.LIST_PRICE;
                                wrapper.ADJUSTED_LIST   = item.ADJUSTED_LIST;
                                wrapper.PERCENT_OFF     = item.PERCENT_OFF;
                                wrapper.DEPT            = item.DEPT;
                                wrapper.DNSA_MODEL      = item.DNSA_MODEL;
                                wrapper.ETA_DATE        = item.ETA_DATE != '0000-00-00' ? item.ETA_DATE : '';
                                wrapper.INVENTORY_STS   = item.INVENTORY_STS;
                                wrapper.LOCATION        = item.LOCATION;
                                wrapper.MC_TC           = item.MC_TC;
                                wrapper.ORDER_STS       = item.ORDER_STS;
                                wrapper.PORT            = item.PORT;
                                wrapper.PROD_DATE       = item.PROD_DATE;
                                wrapper.WAERK           = item.WAERK;
                                wrapper.NC              = item.NC;
                                wrapper.OPEN_NOTES      = item.OPEN_NOTES;
                                wrapper.dealerName      = item.DEALER_NAME;
                                wrapper.userName        = item.CUSTOMER_NAME;
                                wrapper.crm1            = item.CRM_ID1;
                                wrapper.crm2            = item.CRM_ID2;
                                wrapper.crm3            = item.CRM_ID3;
                                wrapper.cssClass        = '';
                                wrapper.SQTXT           = txt.SQTXT;
                                iwList.add(wrapper);
                            }
                        }
                    }
                    if(!iwList.isEmpty()) {
                        resMap.put('data', iwList);
                        resMap.put('userId', currentUser.Id);
                    } 
                } else {
                    resMap.put('flag', 'error');
                    if(result.O_REMSG == 'Error') {
                        resMap.put('msg', 'ERP : Inventory is empty');    
                    } else {
                        resMap.put('msg', 'ERP : ' + result.O_REMSG);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('msg', e.getMessage());
        }
        return resMap;
    }

    /* 예약 취소 화면 init */
    @AuraEnabled
    public static Map<String, Object> cancelInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getCancelProductInfo', getCancelProductInfo(recordId));
            
            List<Order> orderList = [SELECT Id, Status, ERPRSONo__c FROM Order WHERE QuoteId = :recordId];
            if(!orderList.isEmpty()) {
                if(orderList[0].Status != 'Created' && orderList[0].ERPRSONo__c != null) {
                    resMap.put('flag', 'order');
                    resMap.put('message', 'You can\'t cancel a booking because an Order already exists.');
                }
            }

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 견적 행 아이템 생성 */
    @AuraEnabled
    public static string insertQuoteLineItem(String product, String recordId, String VBELN_ST, String SQTXT) {
        try {
            Quote quote = [
                SELECT  Id
                        , OpportunityId
                        , Pricebook2Id
                        , IsBooking__c
                        , MachinePartsWarranty__c
                        , CurrencyIsoCode
                        , RecordType.Name
                        , RequestedShipDate__c
                        , ReserveExpirationDate__c
                        , DNSA_SalesOffice__c
                        , ReserveStatus__c
                        , AccountId
                        , Account.CustomerCode__c
                        , CreatedBy.Account.CustomerCode__c
                        , Waiting_Seq__c
                        , Canceller__c
                FROM Quote
                WHERE Id = :recordId
                LIMIT 1
            ];
            
            Integer seq = 0;

            IF_ERP_ORDER_Classes.IF_ORDER_011_Res result = bookingInterface(VBELN_ST, 'R', quote, '');
            System.debug('result ::: ' + result);
            if(result.O_RECODE == 'S') {
                if(Test.isRunningTest()) seq = 1;
                if(result.T_ITEM[0].CRM_ID1 != null && result.T_ITEM[0].CRM_ID1 != '' && result.T_ITEM[0].CRM_ID1 == currentUser.Id) seq = 1;
                else if(result.T_ITEM[0].CRM_ID2 != null && result.T_ITEM[0].CRM_ID2 != '' && result.T_ITEM[0].CRM_ID2 == currentUser.Id) seq = 2;
                else if(result.T_ITEM[0].CRM_ID3 != null && result.T_ITEM[0].CRM_ID3 != '' && result.T_ITEM[0].CRM_ID3 == currentUser.Id) seq = 3;
                Opportunity oppty = [SELECT Id, StageName FROM Opportunity WHERE Id = :quote.OpportunityId LIMIT 1];
    
                List<Product2> prList = [
                    SELECT Id, Name, ProductCode, CurrencyIsoCode
                    FROM Product2
                    WHERE ProductCode = :product
                    // AND CurrencyIsoCode = :quote.CurrencyIsoCode
                    LIMIT 1
                ];
    
                List<PricebookEntry> pbeList = [
                    SELECT  Id
                            , Pricebook2Id
                    FROM PricebookEntry 
                    WHERE Product2Id = :prList[0].Id
                    AND CurrencyIsoCode = :quote.CurrencyIsoCode
                    LIMIT 1
                ];
                System.debug('quote.CurrencyIsoCode ::: ' + quote.CurrencyIsoCode);
                System.debug('prList ::: ' + prList);
                System.debug('pbeList ::: ' + pbeList);

                if(quote.Pricebook2Id == null) {
                    quote.Pricebook2Id = pbeList[0].Pricebook2Id;
                    update quote;
                }
    
                if(!prList.isEmpty()) {
                    QuoteLineItem qli       = new QuoteLineItem();
                    qli.QuoteId             = quote.Id;
                    qli.Product2Id          = prList[0].Id;
                    qli.Quantity            = 1;
                    qli.UnitPrice           = Decimal.valueOf(result.T_ITEM[0].LIST_PRICE) + Decimal.valueOf(result.T_ITEM[0].ADJUSTED_LIST);
                    qli.ListPrice__c        = Decimal.valueOf(result.T_ITEM[0].LIST_PRICE);
                    qli.Adjustment_Price__c = Decimal.valueOf(result.T_ITEM[0].ADJUSTED_LIST);
                    qli.Dealer_Price__c     = Decimal.valueOf(result.T_ITEM[0].LIST_PRICE) + Decimal.valueOf(result.T_ITEM[0].ADJUSTED_LIST);
                    qli.ExtraDisc__c        = Decimal.valueOf(result.T_ITEM[0].PERCENT_OFF);

                    qli.SerialNumber__c     = result.T_ITEM[0].SERIAL_NUMBER;
                    qli.NC__c               = result.T_ITEM[0].NC;
                    qli.MC_TC__c            = result.T_ITEM[0].MC_TC;
                    qli.Port__c             = result.T_ITEM[0].PORT;
                    qli.ETA_Date__c         = result.T_ITEM[0].ETA_DATE != '0000-00-00' ? Date.valueOf(result.T_ITEM[0].ETA_DATE) : null;
                    qli.Location__c         = result.T_ITEM[0].LOCATION;
                    qli.DetailOption__c     = SQTXT.replace('#$', '<br>');

                    qli.PricebookEntryId    = pbeList[0].Id;
                    qli.Quote_RecordType__c = quote.RecordType.Name;
                    qli.Requested_Ship_Date__c = quote.RequestedShipDate__c;
                    qli.BookingDate__c      = Date.today();
                    qli.StockResSO__c       = VBELN_ST;
                    qli.OpenNotes__c = result.T_ITEM[0].OPEN_NOTES != null ? result.T_ITEM[0].OPEN_NOTES.replace('#$', '\r\n') : null;
                    
                    // TriggerHandler.bypass('QuoteLineItemTriggerHandler');
                    insert qli;
                    // TriggerHandler.clearBypass('QuoteLineItemTriggerHandler');
                    
                    quote.IsBooking__c = seq == 1 ? true : false;
                    quote.Waiting_Seq__c = String.valueOf(seq);
                    quote.ReserveStatus__c = 'RESERVED';
                    quote.DNSA_SalesOffice__c = String.valueOf(result.T_ITEM[0].DEPT);
                    quote.ReserveExpirationDate__c = seq == 1 ? Date.today().addDays(1) : null;
                    quote.StockResSO__c = VBELN_ST;
                    if(quote.Canceller__c != null) quote.Canceller__c = null;
                    update quote;

                    oppty.StageName = 'Conditional Agreement';
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    update oppty;
                    TriggerHandler.clearBypass('OpportunityTriggerHandler');

                    sendWatingAlert(quote, VBELN_ST, result.T_ITEM[0], seq);

                    return 'Success';
                } else {
                    return 'none';
                }
            } else {
                return result.O_REMSG;
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'error';
        }
    }

    /* 예약 대기 알람 */
    private static void sendWatingAlert(Quote quote, String stockOrder, IF_ERP_Order_Classes.IF_ORDER_011_Res_T_ITEM result, Integer seq) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiverEN = new Set<Id>();
        List<String> receiverEmailEN = new List<String>();

        receiverEN.add(currentUser.Id);
        User u = DN_WithoutSharingClass.getUserEmail(currentUser.Id);
        receiverEmailEN.add(u.Email);
        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Send Wating Alert' LIMIT 1];

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        String recordLink = baseUrl + '/' + quote.Id;

        if(!am.isEmpty()) {
            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(stockOrder);
                history.elementList.add(seq == 1 ? 'first' : seq == 2 ? 'second' : seq == 3 ? 'third' : '');
                history.alertID         = am[0].Id;
                history.targetID        = quote.Id;
                history.receiverforID   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }

            if(!receiverEmailEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList.add(seq == 1 ? 'first' : seq == 2 ? 'second' : seq == 3 ? 'third' : '');
                history.elementList.add(stockOrder);
                history.elementList.add(recordLink);
                history.alertID             = am[0].Id;
                history.targetID            = quote.Id;
                history.receiverforEmail    = receiverEmailEN;
                history.alertLanguage       = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 예약 취소 */
    @AuraEnabled
    public static string cancelReservation(String recordId, String reason) {
        try {
            IF_ERP_Order_Classes.IF_ORDER_011_Res result = new IF_ERP_Order_Classes.IF_ORDER_011_Res();
            Quote q = [
                SELECT  Id
                        , IsBooking__c
                        , ServiceReimbursement__c
                        , ServiceReimbursementPrice__c
                        , TotalPrice__c
                        , Accessory_TotalPrice__c
                        , ExtWarranty__c
                        , ReserveStatus__c
                        , AccountId
                        , Account.CustomerCode__c
                        , CreatedBy.Account.CustomerCode__c
                        , Canceller__c
                        , QuoteCancelDate__c
                        , IsRequestPending__c
                        , Pending_Reason__c
                        , PendingExpirationDate__c
                        , DicisionReason__c
                FROM Quote 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            List<QuoteLineItem> qli = [SELECT Id, Product2Id, BookingDate__c, OpportunityLineItemId, StockResSO__c, CreatedById, QuoteId FROM QuoteLineItem WHERE QuoteId = :recordId LIMIT 1];
            System.debug('cancel qli ::: ' + qli);
            List<Order> orders = [SELECT Id FROM Order WHERE QuoteId = :recordId];
            String stockNumber = !Test.isRunningTest() ? qli[0].StockResSO__c : '1234321';
            System.debug('stockNumber ::: ' + stockNumber);
            if(!qli.isEmpty()) {
                result = bookingInterface(qli[0].StockResSO__c, 'C', q, qli[0].CreatedById);
            } else if(Test.isRunningTest()) {
                result = bookingInterface(stockNumber, 'C', q, UserInfo.getUserId());
                System.debug('Cancel result ::: ' + result);
            }

            if(result.O_RECODE == 'S') {
                q.IsBooking__c                  = false;
                q.TotalPrice__c                 = null;
                q.Accessory_TotalPrice__c       = null;
                q.ExtWarranty__c                = null;
                q.ServiceReimbursement__c       = null;
                q.ServiceReimbursementPrice__c  = null;
                q.ReserveExpirationDate__c      = null;
                q.PendingExpirationDate__c      = null;
                q.ReserveStatus__c              = 'Cancel';
                q.Waiting_Seq__c                = null;
                q.Pending_Reason__c             = null;
                q.StockResSO__c                 = null;
                q.IsRequestPending__c           = false;
                q.Canceller__c                  = UserInfo.getUserId();
                q.QuoteCancelDate__c            = Date.today();
                q.DicisionReason__c             = reason;
                List<Accessory__c> acce = [SELECT Id FROM Accessory__c WHERE Quote__c = :recordId];
                if(!qli.isEmpty()) DN_WithoutSharingClass.deleteQuoteLineItems(qli);
                if(!acce.isEmpty()) DN_WithoutSharingClass.deleteAccessories(acce);
                if(!orders.isEmpty()) DN_WithoutSharingClass.deleteOrders(orders);
                update q;
                
                nextReserveSetting(stockNumber, qli, reason);
                
                return 'success';
            } else {
                return result.O_REMSG;
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'fail';
        }
    }

    /* 다음 예약 세팅 */
    private static void nextReserveSetting(String stockNumber, List<QuoteLineItem> qlis, String reason) {
        System.debug('stockNumber ::: ' + stockNumber);
        Set<Id> quoteIds = new Set<Id>();
        List<Quote> updateList = new List<Quote>();
        List<QuoteLineItem> qliList = DN_WithoutSharingClass.queryQuoteLineItems(stockNumber);
        System.debug('qliList ::: ' + qliList);
        if(!qliList.isEmpty()) {
            for(QuoteLineItem qli : qliList) {
                quoteIds.add(qli.QuoteId);
            }

            List<Quote> quoteList = DN_WithoutSharingClass.queryQuotes(quoteIds);
            for(Quote q : quoteList) {
                if(q.Waiting_Seq__c == '2') {
                    q.Waiting_Seq__c = '1';
                    q.IsBooking__c = true;
                    q.ReserveExpirationDate__c = Date.today().addDays(1);
                } else if(q.Waiting_Seq__c == '3') {
                    q.Waiting_Seq__c = '2';
                }
                updateList.add(q);
            }
        }
        if(!updateList.isEmpty()) {
            DN_WithoutSharingClass.updateQuotes(updateList);
            // sendNextReserveConfirmAlert(qliList);
        }
        if(qlis[0].CreatedById != UserInfo.getUserId()) {
            sendCancelStockAlert(stockNumber, qlis, reason);
        }
        return;
    }

    /* 예약 취소 알람 */
    private static void sendCancelStockAlert(String stockNumber, List<QuoteLineItem> qlis, String reason) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> notiReceiverEN = new Set<Id>();
        List<String> emailReceiverEN = new List<String>();

        User curr = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        notiReceiverEN.add(qlis[0].CreatedById);
        User user = DN_WithoutSharingClass.getUserEmail(qlis[0].CreatedById);
        emailReceiverEN.add(user.Email);

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        String recordLink = baseUrl + '/' + qlis[0].QuoteId;
        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Booking Cancel Alert' LIMIT 1];
        if(!am.isEmpty()) {
            if(!notiReceiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(qlis[0].StockResSO__c);
                history.alertID         = am[0].Id;
                history.targetID        = qlis[0].QuoteId;
                history.receiverforID   = notiReceiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!emailReceiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList.add(qlis[0].StockResSO__c);
                history.elementList.add(curr.Name);
                history.elementList.add(reason);
                history.elementList.add(recordLink);
                history.alertID             = am[0].Id;
                history.targetID            = qlis[0].QuoteId;
                history.receiverforEmail    = emailReceiverEN;
                history.alertLanguage       = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 다음 예약 확인 알람 */
    private static void sendNextReserveConfirmAlert(List<QuoteLineItem> qliList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> createdByIds = new Set<Id>();
        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Send Wating Alert' LIMIT 1];

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
    
        if(!am.isEmpty() && !qliList.isEmpty()) {
            for(QuoteLineItem ql : qliList) {
                if(ql.CreatedById != null) {
                    createdByIds.add(ql.CreatedById);
                }
            }
    
            Map<Id, User> userMap = new Map<Id, User>();
            List<User> users = DN_WithoutSharingClass.getUserEmails(createdByIds);
            for(User u : users) {
                userMap.put(u.Id, u);
            }
    
            for(QuoteLineItem ql : qliList) {
                if(ql.CreatedById != null) {
                    UTIL_Alert.HistoryWrapper notificationHistory = new UTIL_Alert.HistoryWrapper();
                    notificationHistory.alertType = 'Notification';
                    notificationHistory.elementList.add(ql.StockResSO__c);
                    notificationHistory.elementList.add(ql.Quote.Waiting_Seq__c == '2' ? 'first' : ql.Quote.Waiting_Seq__c == '3' ? 'second' : '');
                    notificationHistory.alertID = am[0].Id;
                    notificationHistory.targetID = ql.QuoteId;
                    notificationHistory.receiverforID = new Set<Id>{ql.CreatedById};
                    notificationHistory.alertLanguage = 'en';
                    ahwList.add(notificationHistory);
    
                    User user = userMap.get(ql.CreatedById);
                    if(user != null && String.isNotBlank(user.Email)) {
                        UTIL_Alert.HistoryWrapper emailHistory = new UTIL_Alert.HistoryWrapper();
                        emailHistory.alertType = 'Email';
                        emailHistory.elementList.add(ql.Quote.Waiting_Seq__c == '2' ? 'first' : ql.Quote.Waiting_Seq__c == '3' ? 'second' : '');
                        emailHistory.elementList.add(ql.StockResSO__c);
                        emailHistory.elementList.add(baseUrl + '/' + ql.QuoteId);
                        emailHistory.alertID = am[0].Id;
                        emailHistory.targetID = ql.QuoteId;
                        emailHistory.receiverforEmail = new List<String>{user.Email};
                        emailHistory.alertLanguage = 'en';
                        ahwList.add(emailHistory);
                    }
                }
            }
    
            if(!ahwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(ahwList);
            }
        }
        return;
    }

    /* Order 생성 화면 Init */
    @AuraEnabled
    public static Map<String, Object> createOrderInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            List<Order> orderList = [SELECT Id FROM Order WHERE QuoteId = :recordId AND Status NOT IN ('Canceled', 'Returned')];
            if(!orderList.isEmpty()) {
                resMap.put('flag', 'order');
                resMap.put('message', 'An Order already exists that has been created.');
                return resMap;
            }
            List<QuoteLineItem> qliList = [SELECT Id, TotalPrice__c, DetailOption__c, OpenNotes__c FROM QuoteLineItem WHERE QuoteId = :recordId LIMIT 1];
            if(qliList.isEmpty() || qliList.size() == 0 ) {
                resMap.put('flag', 'empty');
                resMap.put('message', 'The Quote Line Item does not exist.');
                return resMap;
            }

            Quote recordInfo = [
                SELECT 
                    Id, 
                    RecordTypeId, 
                    Account.CountryLookup__r.CountryCode__c, 
                    Opportunity.Country__c,
                    OwnerId,
                    IsFinal__c,
                    PaymentTerms_DNSA__c,
                    DNSA_SalesOffice__c,
                    Waiting_Seq__c,
                    Opportunity.Owner.AccountId
                FROM 
                    Quote 
                WHERE 
                    Id =: recordId 
            ];
            User userInfo = [
                SELECT 
                    SalesOrganization__c, 
                    DistributionChannel__c, 
                    Division__c, 
                    AccountId 
                FROM 
                    USER 
                WHERE 
                    Id =: recordInfo.OwnerId 
            ];
            List<SalesAreaData__c> saData = [
                SELECT 
                    Incoterms__c 
                FROM 
                    SalesAreaData__c 
                WHERE 
                    SalesOrganization__c =: UserInfo.SalesOrganization__c 
                AND DistributionChannel__c =: UserInfo.DistributionChannel__c 
                AND Division__c =: UserInfo.Division__c 
                AND Account__c =: UserInfo.AccountId 
            ];

            List<QuoteLineItem> warranty = 
            [
                SELECT
                    Warranty__c, OpenNotes__c
                FROM
                    QuoteLineItem  
                WHERE 
                    QuoteId =: recordId
            ];
            resMap.put('Warranty', warranty[0].Warranty__c);

            resMap.put('seq', recordInfo.Waiting_Seq__c);
            resMap.put('CountryCode', recordInfo.Opportunity.Country__c);
            resMap.put('payment', recordInfo.PaymentTerms_DNSA__c);
            resMap.put('salesOffice', recordInfo.DNSA_SalesOffice__c);
            if(!saData.isEmpty()){
                resMap.put('Incoterms', saData[0].Incoterms__c);
            }
            if(recordInfo.RecordTypeId == recordTypeIdFactory){
                resMap.put('recordType', 'Factory');
                resMap.put('final', recordInfo.IsFinal__c);
                // if(!saData.isEmpty()){
                //     resMap.put('Incoterms', saData[0].Incoterms__c);
                // }
            }else if(recordInfo.RecordTypeId == recordTypeIdCommo){
                resMap.put('recordType', 'Commodity');
                resMap.put('sqTXT', qliList[0].DetailOption__c);
                resMap.put('openNote', qliList[0].OpenNotes__c);
            }
            if(recordInfo.Account.CountryLookup__r.CountryCode__c == 'US'){
                resMap.put('Country','ZDOB');
                resMap.put('dcValue','10');
            }else{
                resMap.put('Country','ZEXB');
                resMap.put('dcValue','20');
            }
            resMap.put('ShipTo', recordInfo.Opportunity.Owner.AccountId);
            resMap.put('checkRequiredFields', checkRequiredFields(recordId));
            resMap.put('getLookupId', getLookupId(recordId));
            
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 견적 정보 */
    @AuraEnabled
    public static Quote getQuoteInfo(String recordId) {
        try {
            Quote quote = [SELECT Id, AccountId, OpportunityId, RecordTypeId FROM Quote WHERE Id = :recordId LIMIT 1];
            return quote;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 필드셋 조회 */
    @AuraEnabled
    public static List<String> getFieldSet(String objectName) {
        try {
            List<String> result = new List<String>();
            for(Schema.FieldSetMember f : getFields(objectName)) {
                result.add(f.getFieldPath());
            }
            return result;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* Orer Product 생성 */
    @AuraEnabled
    public static String insertOrderItems(String orderId, String quoteId) {
        try {
            List<QuoteLineItem> toUpdateItem = new List<QuoteLineItem>();
            List<OrderItem> toCreateItem = new List<OrderItem>();

            Order ord = [SELECT Id, DiscountfromSalesAvailabilityList__c, WarrantyPrice__c, ExtWarranty__c, MachinePartsWarranty__c FROM Order WHERE Id = :orderId LIMIT 1];
            List<QuoteLineItem> qliList = [
                SELECT  Id
                        , Quantity
                        , UnitPrice
                        , Product2Id
                        , Adjustment_Price__c
                        , Dealer_Price__c
                        , TotalPrice__c
                        , ListPrice__c
                        , RequestedDelivDate__c
                        , Requested_Ship_Date__c
                        , ExtraDisc__c
                        , StockResSO__c
                        , SerialNumber__c
                        , NC__c
                        , MC_TC__c
                        , Port__c
                        , ETA_Date__c
                        , Warranty_Price__c
                        , Quote.RecordTypeId
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId
                LIMIT 1
            ];
            Quote quote = [SELECT Id, CurrencyIsoCode, OpportunityId, AccountId, RecordTypeId, ReserveExpirationDate__c FROM Quote WHERE Id = :quoteId LIMIT 1];
            Opportunity oppty = [SELECT Id, StageName FROM Opportunity WHERE Id = :quote.OpportunityId LIMIT 1];
            List<PriceBookEntry> entryList = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id =: qliList[0].Product2Id AND CurrencyIsoCode =:quote.CurrencyIsoCode];
            if(!qliList.isEmpty()) {
                List<Accessory__c> accList = [SELECT Id, Name, QuoteLineItem__c, Key__c, Description__c, Quantity__c, Price__c, Category__c, POSNR__c, MaterialCode__c, ShipTo__c, MachineRequestShipDate__c FROM Accessory__c WHERE QuoteLineItem__c =: qliList[0].Id AND Delete__c != 'D' ORDER BY CreatedDate ASC];
                Map<Id, List<Accessory__c>> itemAccMap = new Map<Id, List<Accessory__c>>();
                for(Accessory__c acc : accList) {
                    if(itemAccMap.containsKey(acc.QuoteLineItem__c)) {
                        List<Accessory__c> innerAccList = itemAccMap.get(acc.QuoteLineItem__c);
                        innerAccList.add(acc);
                        itemAccMap.put(acc.QuoteLineItem__c, innerAccList);
                    } else {
                        itemAccMap.put(acc.QuoteLineItem__c, new List<Accessory__c>{acc});
                    }
                }

                List<SQ_QuoteLineitem_Junction__c> sqList = [SELECT SQ__c, FM_SQ_Stage__c, SQ__r.Name, SQ__r.Category__c, SalesPrice__c, SQ__r.SQ_Registration__r.Account__c, QuoteLineItem__c FROM SQ_QuoteLineitem_Junction__c WHERE QuoteLineItem__c =: qliList[0].Id AND UPDATEFLAG__c != 'D' ORDER BY CreatedDate ASC];
                Map<Id, List<SQ_QuoteLineitem_Junction__c>> itemSQMap = new Map<Id, List<SQ_QuoteLineitem_Junction__c>>();
                if(!sqList.isEmpty()){
                    for(SQ_QuoteLineitem_Junction__c sq : sqList) {
                        if(itemSQMap.containsKey(sq.QuoteLineItem__c)) {
                            List<SQ_QuoteLineitem_Junction__c> innerSQList = itemSQMap.get(sq.QuoteLineItem__c);
                            innerSQList.add(sq);
                            itemSQMap.put(sq.QuoteLineItem__c, innerSQList);
                        } else {
                            itemSQMap.put(sq.QuoteLineItem__c, new List<SQ_QuoteLineitem_Junction__c>{sq});
                        }
                    }
                }

                List<DNSA_Factory_Option_Junction__c> factoryOpList = [SELECT Id, DNSA_Factory_Option__r.SAPDescription__c, Quantity__c, DNSA_Factory_Option__r.Kit__c, Quote_Line_Item__c FROM DNSA_Factory_Option_Junction__c WHERE Quote_Line_Item__c =: qliList[0].Id AND UPDATEFLAG__c != 'D' AND Type__c = 'SQ' ORDER BY CreatedDate ASC];
                Map<Id, List<DNSA_Factory_Option_Junction__c>> itemFOMap = new Map<Id, List<DNSA_Factory_Option_Junction__c>>();
                if(!factoryOpList.isEmpty()){
                    for(DNSA_Factory_Option_Junction__c fo : factoryOpList) {
                        if(itemFOMap.containsKey(fo.Quote_Line_Item__c)) {
                            List<DNSA_Factory_Option_Junction__c> innerFOList = itemFOMap.get(fo.Quote_Line_Item__c);
                            innerFOList.add(fo);
                            itemFOMap.put(fo.Quote_Line_Item__c, innerFOList);
                        } else {
                            itemFOMap.put(fo.Quote_Line_Item__c, new List<DNSA_Factory_Option_Junction__c>{fo});
                        }
                    }
                }

                String warranty = ord.MachinePartsWarranty__c;
                Decimal warr = 0;
                if(warranty != '' && warranty != null) {
                    List<Warranty__c> wrList = new List<Warranty__c>();
                    if(currentUser.AccountId != null) {
                        wrList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :warranty AND BZIRK__c = :currentUser.Account.SalesDistrict__c LIMIT 1];
                    } else {
                        wrList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :warranty AND BZIRK__c = :currentUser.SalesDistrict__c LIMIT 1];
                    }
    
                    if(!wrList.isEmpty()) {
                        if(warranty != 'M24') {
                            ord.ExtWarranty__c = qliList[0].ListPrice__c * (wrList[0].Percent__c / 100);
                            warr = qliList[0].ListPrice__c * (wrList[0].Percent__c / 100);
                        } else {
                            ord.ExtWarranty__c = 0;
                        }
                    }
                }

                OrderItem orderItem          = new OrderItem();
                orderItem.Quantity           = qliList[0].Quantity;
                if(qliList[0].Quote.RecordTypeId == recordTypeIdFactory){
                    if(qliList[0].Adjustment_Price__c != null){
                    orderItem.UnitPrice          = qliList[0].UnitPrice + qliList[0].Adjustment_Price__c;
                    }else{
                        orderItem.UnitPrice          = qliList[0].UnitPrice;
                    }
                }else{
                    orderItem.UnitPrice          = warr != null ? qliList[0].UnitPrice + warr : qliList[0].UnitPrice ;
                }
                // orderItem.UnitPrice          = qliList[0].Dealer_Price__c;
                
                orderItem.StandardPrice__c   = qliList[0].ListPrice__c;
                orderItem.AdjustmentPrice__c = qliList[0].Adjustment_Price__c;
                orderItem.DealerPrice__c     = qliList[0].Dealer_Price__c;
                orderItem.CommodityInventoryPrice__c = qliList[0].UnitPrice;
                orderItem.ExtraDisc__c       = qliList[0].ExtraDisc__c;
                orderItem.StockResSO__c      = qliList[0].StockResSO__c;
                orderItem.ItemCategory__c    = 'Product';
                // orderItem.IF_POSNR__c        = ordSvc.formatCodeForSAP(6, '10');
                
                orderItem.SerialNumber__c     = qliList[0].SerialNumber__c;
                orderItem.NC__c               = qliList[0].NC__c;
                orderItem.MC_TC__c            = qliList[0].MC_TC__c;
                orderItem.Port__c             = qliList[0].Port__c;
                orderItem.ETA_Date__c         = qliList[0].ETA_Date__c;

                orderItem.OrderId            = orderId;
                orderItem.QuoteLineItemId    = qliList[0].Id;
                orderItem.Product2Id         = qliList[0].Product2Id;
                orderItem.PricebookEntryId   = entryList[0].Id;
                orderItem.ReqShipDate__c     = qliList[0].Requested_Ship_Date__c;
                orderItem.ShipTo__c          = quote.AccountId;
                toCreateItem.add(orderItem);
    
                QuoteLineItem quoteItem = new QuoteLineItem();
                quoteItem.Id            = qliList[0].Id;
                quoteItem.Order__c      = orderId;
                System.debug('quoteItem::: ' + quoteItem);
                toUpdateItem.add(quoteItem);
                Integer posnr = 20;
    
                if(itemAccMap.containsKey(qliList[0].Id)) {

                    for(Accessory__c acc : itemAccMap.get(qliList[0].Id)) {
                        OrderItem accItem        = new OrderItem();
                        accItem.Quantity         = acc.Quantity__c;
                        accItem.UnitPrice        = acc.Price__c ?? 0;
                        accItem.StandardPrice__c = acc.Price__c ?? 0;
                        accItem.ItemCategory__c  = 'Accessory';
                        // if(quote.RecordTypeId == recordTypeIdCommo) {
                            accItem.IF_POSNR__c      = ordSvc.formatCodeForSAP(6, String.valueOf(posnr));
                        // }
                        
                        accItem.Accessory__c     = acc.Id;
                        // accItem.AccessoryCode__c = acc.MaterialCode__c;
                        accItem.AccessoryCode__c = acc.Key__c;
                        accItem.AccessoryName__c = acc.Name;
                        accItem.AccessoryCategory__c = acc.Category__c;
    
                        accItem.OrderId          = orderId;
                        accItem.QuoteLineItemId  = qliList[0].Id;
                        accItem.Product2Id       = qliList[0].Product2Id;
                        accItem.PricebookEntryId = entryList[0].Id;
                        accItem.ReqShipDate__c   = acc.MachineRequestShipDate__c;
                        accItem.ShipTo__c        = acc.ShipTo__c;
                        toCreateItem.add(accItem);
                        posnr += 10;
                    }
                }

                if(itemSQMap.containsKey(qliList[0].Id)) {

                    for(SQ_QuoteLineitem_Junction__c sq : itemSQMap.get(qliList[0].Id)){
                        OrderItem sqItem        = new OrderItem();
                        sqItem.Quantity         = 1;
                        // sqItem.UnitPrice        = sq.SalesPrice__c ?? 0;
                        sqItem.UnitPrice        = 0;
                        sqItem.ItemCategory__c  = 'SQ';

                        sqItem.IF_POSNR__c      = ordSvc.formatCodeForSAP(6, String.valueOf(posnr));

                        sqItem.SQ__c            = sq.SQ__c;
                        sqItem.SQTitle__c       = sq.SQ__r.Name;
                        sqItem.IsInspection__c  = sq.SQ__r.Category__c == '입회검사';
                        
                        sqItem.OrderId          = orderId;
                        sqItem.QuoteLineItemId  = qliList[0].Id;
                        sqItem.Product2Id       = qliList[0].Product2Id;
                        sqItem.PricebookEntryId = entryList[0].Id;
                        sqItem.ReqShipDate__c   = qliList[0].Requested_Ship_Date__c;
                        sqItem.ShipTo__c        = sq.SQ__r.SQ_Registration__r.Account__c;

                        posnr += 10;
                        toCreateItem.add(sqItem);
                    }
                }

                if(itemFOMap.containsKey(qliList[0].Id)) {
        
                            for(DNSA_Factory_Option_Junction__c fo : itemFOMap.get(qliList[0].Id)){
                                OrderItem foItem        = new OrderItem();
                                foItem.Quantity         = fo.Quantity__c;
                                foItem.UnitPrice        = 0;
                                foItem.ItemCategory__c  = 'SQ';
        
                                foItem.IF_POSNR__c      = ordSvc.formatCodeForSAP(6, String.valueOf(posnr));
        
                                // foItem.SQ__c            = fo.SQ__c;
                                // foItem.SQTitle__c       = fo.DNSA_Factory_Option__r.Kit__c;
                                foItem.SQTitle__c       = fo.DNSA_Factory_Option__r.SAPDescription__c;
                                foItem.AccessoryName__c = fo.DNSA_Factory_Option__r.Kit__c;
                                foItem.OrderId          = orderId;
                                foItem.QuoteLineItemId  = qliList[0].Id;
                                foItem.Product2Id       = qliList[0].Product2Id;
                                foItem.PricebookEntryId = entryList[0].Id;
                                foItem.ReqShipDate__c   = qliList[0].Requested_Ship_Date__c;
                                foItem.ShipTo__c        = quote.AccountId;
        
                                posnr += 10;
                                toCreateItem.add(foItem);
                            }
                        }
            } else {
                return 'empty';
            }
            
            if(!toUpdateItem.isEmpty()) update toUpdateItem;
            if(!toCreateItem.isEmpty()) {
                for(Integer i = 0; i < toCreateItem.size(); i++){
                    System.debug('toCreateItem : ' + toCreateItem[i]);
                }
                insert toCreateItem;

                if(oppty.StageName != 'Closed Won') {
                    oppty.StageName = 'Closed Won';
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    update oppty;
                    TriggerHandler.clearBypass('OpportunityTriggerHandler');
                }

                // if(quote.ReserveExpirationDate__c != null) {
                //     quote.ReserveExpirationDate__c = null;
                //     update quote;
                // }
                ord.DiscountfromSalesAvailabilityList__c = qliList[0].ExtraDisc__c;
                ord.WarrantyPrice__c    = qliList[0].Warranty_Price__c;
                update ord;
            }
            return 'Success';

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            // throw new AuraHandledException(e.getMessage());
            return 'error';
        }
    }

    /**
    * @description  Order와 연결 된 Opportunity가 Closed이고, 
                    Order의 Status가 'Order Create'일 때 버튼 클릭 가능
                    (= ERP에 전송한 적 없을 때 / DNS-A 전용)
    * @author hanyeong choi | 2024-12-31
    * @param orderId
    * @return ResultWrapper
    **/
    @AuraEnabled
    public static ResultWrapper dnsaValidateOrderConfrim(String orderId){
        ResultWrapper result = new ResultWrapper();

        try {
            Order order = [SELECT Id, OrderNumber, Status, OpportunityId, Opportunity.StageName, HasPricingProcessed__c, HasScheduleCompleted__c FROM Order WHERE Id =: orderId];
            Opportunity opty = [SELECT Id, StageName FROM Opportunity WHERE Id =: order.OpportunityId WITH SECURITY_ENFORCED];

            List<String> pickValues = ordSvc.getPicklist('Order', 'Status');
            pickValues.remove(pickValues.indexOf(ordSvc.ORDER_CREATE));
            pickValues.remove(pickValues.indexOf(ordSvc.ORDER_PROGRESS));

            List<PaymentSchedule__c> psList = [SELECT Id, DraftCheck__c FROM PaymentSchedule__c WHERE Order__c =: orderId];

            if(order.Status == ordSvc.ORDER_PROGRESS) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_AlreadyRequested; // This order has already been requested for confirmation.
            } else if(pickValues.contains(order.Status)) {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_AlreadyConfirmed; // This order has already been confirmed.
            } 
            // else if(opty.StageName != 'Closed Won') { // SLS-ORD-023
            //     result.isSuccess  = false;
            //     result.errMessage = System.Label.DNS_M_RequestOptyClosed; // Please close the associated Opportunity to proceed with the order confirmation.
            // }
        } catch (Exception e) {
            System.debug('dnsaValidateOrderConfrim : ' + e.getLineNumber() + ' / ' + e.getMessage());
            result.isSuccess  = false;
            result.errMessage = e.getMessage();
        }
        return result;
    }

    /* pricing 모달 화면 init */
    @AuraEnabled
    public static Map<String, Object> initPricing(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('stageName', getStageName(recordId));
            resMap.put('dealerPrice', getDealerPrice(recordId));
            resMap.put('initDatas', getInterface018(recordId));
            // 0330 이주현 수정
            Order order = [SELECT Id, Quote.RecordTypeId, OrderType__c FROM Order WHERE Id = :recordId LIMIT 1];
            if(order.Quote.RecordTypeId == recordTypeIdFactory || order.OrderType__c == 'ZUSO') {
                resMap.put('checkRecordType', true);
            }

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* order필드에 pricing 적용 */
    @AuraEnabled
    public static string applyPricing(String recordId, Map<String, Object> fieldData) {
        System.debug('fieldData ::: ' + fieldData);
        try {
            Order order = [
                SELECT  Id
                        , DiscountfromSalesAvailabilityList__c
                        , PromotionalPackage__c
                        , ProfitMarginSubsidyPlan__c
                        , OtherDiscount__c
                        , ServiceReimbursement__c
                        , ExtWarranty__c
                        , TotalPrice__c
                        , ServiceReimbursementPrice__c
                        , IsPricing__c
                        , MachinePartsWarranty__c
                FROM Order
                WHERE Id = :recordId
                LIMIT 1
            ];

            order.DiscountfromSalesAvailabilityList__c  = String.valueOf(fieldData.get('DiscountfromSalesAvailabilityList__c')) == ''|| fieldData.get('DiscountfromSalesAvailabilityList__c') == null ? 0 : Decimal.valueOf(String.valueOf(fieldData.get('DiscountfromSalesAvailabilityList__c')));
            order.PromotionalPackage__c                 = String.valueOf(fieldData.get('PromotionalPackage__c')) == '' || fieldData.get('PromotionalPackage__c') == null ? 0 : Decimal.valueOf(String.valueOf(fieldData.get('PromotionalPackage__c')));
            order.ProfitMarginSubsidyPlan__c            = String.valueOf(fieldData.get('ProfitMarginSubsidyPlan__c')) == '' || fieldData.get('ProfitMarginSubsidyPlan__c') == null ? 0 : Decimal.valueOf(String.valueOf(fieldData.get('ProfitMarginSubsidyPlan__c')));
            order.OtherDiscount__c                      = String.valueOf(fieldData.get('OtherDiscount__c')) == '' || fieldData.get('OtherDiscount__c') == null ? 0 : Decimal.valueOf(String.valueOf(fieldData.get('OtherDiscount__c')));
            order.ServiceReimbursement__c               = String.valueOf(fieldData.get('ServiceReimbursement__c'));
            order.ServiceReimbursementPrice__c          = Decimal.valueOf(String.valueOf(fieldData.get('O_Price')));
            order.IsPricing__c = true;
            order.MachinePartsWarranty__c               = String.valueOf(fieldData.get('MachinePartsWarranty__c'));
            order.ExtWarranty__c                        = String.valueOf(fieldData.get('ExtWarranty__c')) == '' || fieldData.get('ExtWarranty__c') == null ? 0 : Decimal.valueOf(String.valueOf(fieldData.get('ExtWarranty__c')));
            // update order;

            Decimal extw;
            if(order.ExtWarranty__c == null) {
                extw = 0;
            } else {
                extw = order.ExtWarranty__c;
            }

            List<OrderItem> oliList = [SELECT Id, TotalPrice__c, DealerPrice__c, UnitPrice FROM OrderItem WHERE OrderId = :order.Id AND Accessory__c = null LIMIT 1];
            if(!oliList.isEmpty()) {
                List<OrderItem> updateList = new List<OrderItem>();
                for(OrderItem oli : oliList) {
                    if(order.ServiceReimbursement__c == 'Y') {
                        oli.UnitPrice = oli.DealerPrice__c - (oli.DealerPrice__c * (order.DiscountfromSalesAvailabilityList__c / 100)) + order.OtherDiscount__c + order.PromotionalPackage__c + order.ProfitMarginSubsidyPlan__c + extw + order.ServiceReimbursementPrice__c;
                    } else {
                        oli.UnitPrice = oli.DealerPrice__c - (oli.DealerPrice__c * (order.DiscountfromSalesAvailabilityList__c / 100)) + order.OtherDiscount__c + order.PromotionalPackage__c + order.ProfitMarginSubsidyPlan__c + extw;
                    }
                    // oli.TotalPrice__c = oli.DealerPrice__c - (oli.DealerPrice__c * (order.DiscountfromSalesAvailabilityList__c / 100)) - order.OtherDiscount__c - order.PromotionalPackage__c - order.ProfitMarginSubsidyPlan__c + extw;
                    // order.TotalPrice__c = oli.DealerPrice__c - (oli.DealerPrice__c * (order.DiscountfromSalesAvailabilityList__c / 100)) - order.OtherDiscount__c - order.PromotionalPackage__c - order.ProfitMarginSubsidyPlan__c + extw;
                    updateList.add(oli);
                }
                if(!updateList.isEmpty()) {
                    TriggerHandler.bypass('OrderItemTriggerHandler');
                    update updateList;
                    TriggerHandler.clearBypass('OrderItemTriggerHandler');
                }
                update order;
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            // throw new AuraHandledException(e.getMessage());
            return 'fail';
        }
        return 'success';
    }

    /* pending 확인 */
    @AuraEnabled
    public static Map<String, Object> checkPending(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            User user = [SELECT Id, IsPartner FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            resMap.put('isPartner', user.IsPartner);
            Quote quote = [SELECT Id, IsRequestPending__c, Waiting_Seq__c FROM Quote WHERE Id = :recordId LIMIT 1];
            resMap.put('isPending', quote.IsRequestPending__c);
            resMap.put('seq', quote.Waiting_Seq__c);
            List<QuoteLineItem> qli = [SELECT Id, StockResSO__c FROM QuoteLineItem WHERE QuoteId = :recordId LIMIT 1];
            if(!qli.isEmpty())  {
                resMap.put('isProduct', true);
                resMap.put('stockNum', qli[0].StockResSO__c);
            } else {
                resMap.put('isProduct', false);
            }

            List<Order> order = [SELECT Id, ERPRSONo__c, OrderType__c FROM Order WHERE QuoteId = :recordId];
            if( !order.isEmpty() && order[0].ERPRSONo__c != null) resMap.put('isOrder', true);

            List<ContentDocumentLink> links = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            if(!links.isEmpty()) {
                resMap.put('isFile', true);
            } else {
                resMap.put('isFile', false);
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return resMap;
    }

    /* pending 요청 */
    @AuraEnabled
    public static string requestPending(String recordId, String reason, String VBELN_ST) {
        try {
            Quote quote = [SELECT Id, Name, IsRequestPending__c, DNSAModel__r.Name, DNSAModel__c, ReserveStatus__c, Pending_Reason__c, DNSA_SalesOffice__c, CreatedBy.Account.CustomerCode__c, Account.CustomerCode__c, Owner.Name FROM Quote WHERE Id = :recordId LIMIT 1];

            IF_ERP_ORDER_Classes.IF_ORDER_011_Res result = bookingInterface(VBELN_ST, 'PR', quote, '');
            System.debug('result ::: ' + result);
            if(result.O_RECODE == 'S') {

                quote.IsRequestPending__c = true;
                // quote.ReserveExpirationDate__c = null;
                quote.PendingExpirationDate__c = Date.today().addDays(30);
                quote.ReserveStatus__c = 'P REQUEST';
                quote.Pending_Reason__c = reason;
                update quote;

                sendRequestPendingNoti(quote);
                sendRequestPendingEmail(quote, reason, VBELN_ST);
                return 'Success';
            } else {
                return result.O_REMSG;
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'error';
        }
    }

    /* pending 확정 */
    @AuraEnabled
    public static string pendingConfirm(String recordId, String VBELN_ST, String reason) {
        try {
            Quote quote = [
                SELECT  Id
                        , Name
                        , IsRequestPending__c
                        , ReserveExpirationDate__c
                        , OwnerId
                        , DNSAModel__r.Name
                        , DNSAModel__c
                        , ReserveStatus__c
                        , Pending_Reason__c
                        , CreatedBy.Account.CustomerCode__c
                        , Account.CustomerCode__c 
                        , DicisionReason__c
                FROM Quote 
                WHERE Id = :recordId 
                LIMIT 1
            ];

            IF_ERP_ORDER_Classes.IF_ORDER_011_Res result = bookingInterface(VBELN_ST, 'P', quote, '');
            System.debug('result ::: ' + result);
            if(result.O_RECODE == 'S') {

                quote.IsRequestPending__c = false;
                quote.ReserveStatus__c = 'PENDING';
                quote.ReserveExpirationDate__c = Date.today().addDays(14);
                quote.Pending_Reason__c = null;
                quote.DicisionReason__c = reason;
                update quote;

                sendConfirmPendingNoti(quote);
                sendConfirmPendingEmail(quote, reason);
                return 'Success';
            } else {
                return result.O_REMSG;
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            return 'error';
        }
    }

    /* 견적 확인 요청 알람 */
    @AuraEnabled
    public static string sendControlAlert(String recordId){
        String result = 'Success';
        try {
            List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
            Set<Id> notiReceiverEN = new Set<Id>();
            List<String> emailReceiverEN = new List<String>();

            Quote quote = [SELECT Id, Name, DNSA_SalesOffice__c FROM Quote WHERE Id = :recordId LIMIT 1];
            // Group gr = [SELECT Id FROM Group WHERE DeveloperName  = 'DNSA_SalesControl' LIMIT 1];
            // List<GroupMember> members = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :gr.Id];
            String SalesofficeName;
            if(quote.DNSA_SalesOffice__c == '414P'){
                SalesofficeName = 'Quote Request (414P)';
            }else{
                SalesofficeName = 'Quote Request (414A)';
            }
            MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE Name  =: SalesofficeName LIMIT 1];
            List<Message_Group_Junction__c> members = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c =: mg.Id AND User__r.IsActive = true];
            if(!members.isEmpty()) {
                // for(GroupMember member : members) {
                //     notiReceiverEN.add(member.UserOrGroupId);
                // }
                for(Message_Group_Junction__c member : members) {
                    notiReceiverEN.add(member.User__c);
                }
                List<User> userList = DN_WithoutSharingClass.getUserEmails(notiReceiverEN);
                if(!userList.isEmpty()) {
                    for(User user : userList) {
                        emailReceiverEN.add(user.Email);
                    }
                }

                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New Factory Quote Alert' LIMIT 1];

                if(!am.isEmpty()) {
                    if(!notiReceiverEN.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType       = 'Notification';
                        history.elementList.add(quote.Name);
                        history.alertID         = am[0].Id;
                        history.targetID        = quote.Id;
                        history.receiverforID   = notiReceiverEN;
                        history.alertLanguage   = 'en';
                        ahwList.add(history);
                    }
                    if(!emailReceiverEN.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType           = 'Email';
                        history.elementList.add(quote.Name);
                        history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + quote.Id);
                        history.alertID             = am[0].Id;
                        history.targetID            = quote.Id;
                        //기존코드
                        //history.receiverforEmail    = emailReceiverEN;
                        //Padilla 만 수신인으로(임시)
                        history.receiverforEmail = new List<String>{
                            'michael.padilla@dncompany.com'
                        };
                        //Kyle Multz, Chris Avila, Harvey Chae 참조인으로(임시)
                        history.receiverforEmailCC = new List<String>{
                            'kyle.multz@dncompany.com',
                            'mark.christopher@dncompany.com',
                            'heedong1.chae@dncompany.com',
                            'yewon1.lee@dncompany.com'
                        };
                        history.alertLanguage       = 'en';
                        ahwList.add(history);
                    }
                    if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
                }
            }

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result = e.getLineNumber() + ' / ' + e.getMessage();
            // throw new AuraHanedledException(e.getMessage());
        }
        return result;
    }

    /* DNSA Sales팀에게 알람 */
    @AuraEnabled
    public static string sendQuoteDNSASalesTeamAlert(String recordId){
        String result = 'Success';
        try {
            List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
            Set<Id> notiReceiverEN = new Set<Id>();
            List<String> emailReceiverEN = new List<String>();

            Quote quote = [SELECT Id, Name, DNSA_SalesOffice__c FROM Quote WHERE Id = :recordId LIMIT 1];
            List<MessageGroup__c> mgList = [SELECT Id FROM MessageGroup__c WHERE SalesOffice__c = :quote.DNSA_SalesOffice__c LIMIT 1];

            if(!mgList.isEmpty()) {
                List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c, FM_UserEmail__c FROM Message_Group_Junction__c WHERE Message_Group__c = :mgList[0].Id AND User__r.IsActive = true];
                if(!mgjList.isEmpty()) {
                    for(Message_Group_Junction__c mgj : mgjList) {
                        notiReceiverEN.add(mgj.User__c);
                        emailReceiverEN.add(mgj.FM_UserEmail__c);
                    }

                    List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Person in Charge Assigned Alert' LIMIT 1];

                    if(!am.isEmpty()) {
                        if(!notiReceiverEN.isEmpty()) {
                            UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                            history.alertType       = 'Notification';
                            history.elementList.add(quote.Name);
                            history.alertID         = am[0].Id;
                            history.targetID        = quote.Id;
                            history.receiverforID   = notiReceiverEN;
                            history.alertLanguage   = 'en';
                            ahwList.add(history);
                        }
                        if(!emailReceiverEN.isEmpty()) {
                            UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                            history.alertType           = 'Email';
                            history.elementList.add(quote.Name);
                            history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + quote.Id);
                            history.alertID             = am[0].Id;
                            history.targetID            = quote.Id;
                            history.receiverforEmail    = emailReceiverEN;
                            history.alertLanguage       = 'en';
                            ahwList.add(history);
                        }
                        if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result = e.getLineNumber() + ' / ' + e.getMessage();
            // throw new AuraHanedledException(e.getMessage());
        }
        return result;
    }

    /* DNSA Sales팀에게 SQ 알람 */
    @AuraEnabled
    public static string sendSQRegistrationDNSASalesTeamAlert(String recordId) {
        String result = 'Success';
        try {
            List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
            Set<Id> notiReceiverEN = new Set<Id>();
            List<String> emailReceiverEN = new List<String>();

            SQRegistration__c sqr = [SELECT Id, Name, DNSA_Sales_Team__c, Stage__c FROM SQRegistration__c WHERE Id = :recordId LIMIT 1];

            if(sqr.DNSA_Sales_Team__c != null) {
                List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c, FM_UserEmail__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.DNSA_Sales_Team__c AND User__r.IsActive = true];
                if(!mgjList.isEmpty()) {
                    for(Message_Group_Junction__c mgj : mgjList) {
                        notiReceiverEN.add(mgj.User__c);
                        emailReceiverEN.add(mgj.FM_UserEmail__c);
                    }

                    List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'SQ Send DSNA Sales Team Alert' LIMIT 1];

                    if(!am.isEmpty()) {
                        if(!notiReceiverEN.isEmpty()) {
                            UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                            history.alertType       = 'Notification';
                            history.elementList.add(sqr.Name);
                            history.alertID         = am[0].Id;
                            history.targetID        = sqr.Id;
                            history.receiverforID   = notiReceiverEN;
                            history.alertLanguage   = 'en';
                            ahwList.add(history);
                        }
                        if(!emailReceiverEN.isEmpty()) {
                            UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                            history.alertType           = 'Email';
                            history.elementList.add(sqr.Name);
                            history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id);
                            history.alertID             = am[0].Id;
                            history.targetID            = sqr.Id;
                            history.receiverforEmail    = emailReceiverEN;
                            history.alertLanguage       = 'en';
                            ahwList.add(history);
                        }
                        if(!ahwList.isEmpty()) {
                            UTIL_Alert.runAlertEvent(ahwList);
                            sqr.Stage__c = 'DNSSalesConfirm';
                            update sqr;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result = e.getLineNumber() + ' / ' + e.getMessage();
            // throw new AuraHanedledException(e.getMessage());
        }
        return result;
    }

    /* 워랜티 변경 */
    @AuraEnabled
    public static String changeWarranty(String recordId, String value) {
        String result;
        try {
            List<Warranty__c> warList = new List<Warranty__c>();
            if(currentUser.AccountId != null) {
                warList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :value AND BZIRK__c = :currentUser.Account.SalesDistrict__c LIMIT 1];
            } else {
                warList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :value AND BZIRK__c = :currentUser.SalesDistrict__c LIMIT 1];
            }

            List<OrderItem> oliList = [SELECT StandardPrice__c FROM OrderItem WHERE OrderId = :recordId AND Accessory__c = null LIMIT 1];
            if(!warList.isEmpty() && !oliList.isEmpty()) {
                if(value != 'M24') {
                    result = String.valueOf(oliList[0].StandardPrice__c * (warList[0].Percent__c / 100));
                } else {
                    result = '0';
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            // throw new AuraHandledException(e.getMessage());
            result = 'error';
        }
        return result;
    }

    /* Order Stage명 조회 */
    private static String getStageName(String recordId) {
        Order  order = [SELECT Id, Status FROM Order WHERE Id = :recordId LIMIT 1];
        return order.Status;
    }

    /* Dealer Price 조회 */
    private static Map<String, Decimal> getDealerPrice(String recordId) {
        Map<String, Decimal> resMap = new Map<String, Decimal>();
        List<OrderItem> oli = [SELECT Id, DealerPrice__c, ExtraDisc__c, Order.ExtWarranty__c, StandardPrice__c, AdjustmentPrice__c FROM OrderItem WHERE OrderId = :recordId AND Accessory__c = null LIMIT 1];
        if(!oli.isEmpty()) {
            resMap.put('flag', 0);
            resMap.put('dealerPrice', oli[0].DealerPrice__c);
            resMap.put('disc', oli[0].ExtraDisc__c);
            resMap.put('warr', oli[0].Order.ExtWarranty__c);
            resMap.put('listPrice', oli[0].StandardPrice__c);
            resMap.put('adjustmentPrice', oli[0].AdjustmentPrice__c);
        } else {
            resMap.put('flag', 1);
        }
        return resMap;
    }

    /* Order관련 가격 정보 가져오기 */
    private static IF_ERP_Order_Classes.IF_ORDER_018_Res getInterface018(String recordId) {
        IF_ERP_Order_Classes.IF_ORDER_018_Res result = new IF_ERP_Order_Classes.IF_ORDER_018_Res();
        Order order = [SELECT Id, CurrencyIsoCode, MachinePartsWarranty__c FROM Order WHERE Id = :recordId LIMIT 1];
        User currentUser = [SELECT Id, AccountId, Account.DistributionChannel__c, DistributionChannel__c, Account.SalesDistrict__c, SalesDistrict__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<OrderItem> oli = [SELECT Id, Product2.Model__r.MaterialCode__c, BookingDate__c FROM OrderItem WHERE OrderId = :recordId AND Accessory__c = null LIMIT 1];
        if(!oli.isEmpty()) {
            IF_ERP_Order_Classes.IF_ORDER_018_Req req = new IF_ERP_Order_Classes.IF_ORDER_018_Req();
            // req.I_VKORG = currentUser.AccountId != null ? currentUser.Account.SalesOrganization__c : currentUser.SalesOrganization__c;
            req.I_VKORG = '4140';
            req.I_VTWEG = currentUser.AccountId != null ? currentUser.Account.DistributionChannel__c : currentUser.DistributionChannel__c;
            req.I_MATNR = oli[0].Product2.Model__r.MaterialCode__c;
            req.I_WAERK = order.CurrencyIsoCode;
            req.I_DATE  = oli[0].BookingDate__c != null ? ordSvc.formatDateForSAP(oli[0].BookingDate__c, false) : '';
            req.I_BZIRK = currentUser.AccountId != null ? currentUser.Account.SalesDistrict__c : currentUser.SalesDistrict__c;
        
            IF_ERP_Order method = new IF_ERP_Order();
            result = method.IF_ORDER_018(req);
        }
        return result;
    }

    /* 룩업 필드 조회 */
    private static Map<String, String> getLookupId(String recordId) {
        Map<String, String> resMap = new Map<String, String>();
        Id orderDNSAId = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
        User user = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Quote q = [SELECT AccountId, OpportunityId, Opportunity.PO__c, Pricebook2Id, CurrencyIsoCode FROM Quote WHERE Id = :recordId LIMIT 1];
        List<QuoteLineItem> qli = [SELECT Id, Requested_Ship_Date__c FROM QuoteLineItem WHERE QuoteId = :recordId LIMIT 1];
        resMap.put('accId', q.AccountId);
        resMap.put('opptyId', q.OpportunityId);
        resMap.put('prbId', q.Pricebook2Id);
        resMap.put('recordTypeId', orderDNSAId);
        resMap.put('currency', q.CurrencyIsoCode);
        resMap.put('userAccId', user.AccountId != null ? user.AccountId : null);
        resMap.put('opptyPO', q.Opportunity.PO__c);

        if(!qli.isEmpty()) {
            resMap.put('rddValue', String.valueOf(qli[0].Requested_Ship_Date__c));
        } else {
            resMap.put('rddValue', '');
        }
        return resMap;
    }

    /* 필수 필드 확인 */
    private static Map<String, Boolean> checkRequiredFields(String recordId) {
        Map<String, Boolean> resMap = new Map<String, Boolean>();
        Quote quote = [SELECT Id, TermsOfPayment__c, FOBPoint__c, MachinePartsWarranty__c FROM Quote WHERE Id = :recordId LIMIT 1];
        if(String.isBlank(quote.TermsOfPayment__c)) {
            resMap.put('TermsOfPayment__c', true);
        } else {
            resMap.put('TermsOfPayment__c', false);
        }

        // if(String.isBlank(quote.MachinePartsWarranty__c)) {
        //     resMap.put('MachinePartsWarranty__c', true);
        // } else {
        //     resMap.put('MachinePartsWarranty__c', false);
        // }

        if(String.isBlank(quote.FOBPoint__c)) {
            resMap.put('FOBPoint__c', true);
        } else {
            resMap.put('FOBPoint__c', false);
        }
        return resMap;
    }

    /* DNSA  Modal과 Order 필드 조회 */
    private static List<Schema.FieldSetMember> getFields(String objectName) {
        List<Schema.FieldSetMember> result = new List<Schema.FieldSetMember>();
        if(objectName == 'DNSAModel__c') {
            result = SObjectType.DNSAModel__c.FieldSets.DNSAModelLayout.getFields();
        } else if(objectName == 'Order') {
            result = SObjectType.Order.FieldSets.DNSA_CreateOrder.getFields();
        }
        return result;
    }

    /* 견적에 DNSA Model 아이디 조회 */
    private static String getDNSAModelId(String recordId) {
        Quote quote = [SELECT Id, DNSAModel__c FROM Quote WHERE Id = :recordId LIMIT 1];
        return quote.DNSAModel__c;
    }

    /* 취소 제품 정보 */
    private static List<QuoteLineItem> getCancelProductInfo(String recordId) {
        List<QuoteLineItem> qliList = [
            SELECT  Id
                    , Product2.Name__c
                    , Product2.Model__r.Name
                    , Quantity
                    , UnitPrice
                    , BookingDate__c
                    , StockResSO__c
            FROM QuoteLineItem
            WHERE QuoteId = :recordId
        ];
        return qliList;
    }

    /* 예약 인터페이스 호출 */
    private static IF_ERP_Order_Classes.IF_ORDER_011_Res bookingInterface(String VBELN_ST, String code, Quote quote, String ownerId) {
        User user = [SELECT Id, Name, AccountId, Account.CustomerCode__c, Portal_EmployeeNumber__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String ownerCustomerCode = '';
        if(String.isNotBlank(ownerId)) {
            User owner = DN_WithoutSharingClass.getUserEmail(ownerId);
            ownerCustomerCode = owner.Account.CustomerCode__c;
        }

        String customerCode = (user.AccountId != null) ? user.Account.CustomerCode__c : ownerCustomerCode;
        if(Test.isRunningTest()) {
            customerCode = '112233';
        }
        // String customerCode = (user.Account.CustomerCode__c != null) ? user.Account.CustomerCode__c : '';
        while (customerCode.length() < 10) {
            customerCode = '0' + customerCode;
        }

        String shipToCode = (quote.Account.CustomerCode__c != null) ? quote.Account.CustomerCode__c : '';

        while (shipToCode.length() < 10) {
            shipToCode = '0' + shipToCode;
        }
        
        if(code == 'R' || code == 'C') {
    
            IF_ERP_Order_Classes.IF_ORDER_011_Req req = new IF_ERP_Order_Classes.IF_ORDER_011_Req();
            req.I_OKCODE        = code;
            req.I_CRM_ID        = ownerId == '' ? user.Id : ownerId != user.Id ? ownerId : user.Id;
            req.I_CRM_NAME      = user.Name;
            req.I_CRM_SOLD_TO   = customerCode;
            // req.I_KUNNR         = customerCode;
    
        
            List<IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM> T_ITEM_List = new List<IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM>();
            IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM T_ITEM1 = new IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM();
            T_ITEM1.VBELN_ST    = VBELN_ST;
            T_ITEM1.DEALER      = customerCode;
            T_ITEM1.CUSTOMER    = shipToCode;
            T_ITEM1.CRM_REID    = quote.Id;
        
            T_ITEM_List.add(T_ITEM1);
            System.debug('T_ITEM_Listv ::: ' + T_ITEM_List);
            req.T_ITEM = T_ITEM_List;
        
            IF_ERP_Order instance = new IF_ERP_Order();
            return instance.IF_ORDER_011(req);
        } else {
            IF_ERP_Order_Classes.IF_ORDER_011_Req req = new IF_ERP_Order_Classes.IF_ORDER_011_Req();
            req.I_OKCODE        = code;
            req.I_CRM_ID        = user.Id;    
            req.I_CRM_NAME      = user.Name;
            req.I_CRM_SOLD_TO   = customerCode;
        
            List<IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM> T_ITEM_List_P = new List<IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM>();
            IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM T_ITEM1_P = new IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM();
            T_ITEM1_P.VBELN_ST    = VBELN_ST;
            T_ITEM1_P.DEALER      = customerCode;
            T_ITEM1_P.CUSTOMER      = shipToCode;
            T_ITEM1_P.CRM_REID    = quote.Id;
        
            T_ITEM_List_P.add(T_ITEM1_P);
            req.T_ITEM = T_ITEM_List_P;
        
            IF_ERP_Order instance = new IF_ERP_Order();
            return instance.IF_ORDER_011(req);
        }
    }

    /* 현재 유저 정보 조회 */
    private static User getCurrentUser() {
        User user = [
            SELECT  Id
                    , IsPortalEnabled
                    , SalesOrganization__c
                    , SalesOffice__c
                    , SalesDistrict__c
                    , DistributionChannel__c
                    , Division__c
                    , AccountId
                    , Account.CustomerCode__c
                    , Account.SalesOrganization__c
                    , Account.SalesOffice__c
                    , Account.DistributionChannel__c
                    , Account.Division__c
                    , Account.SalesDistrict__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return user;
    }

    /* pending 요청 알람 */
    private static void sendRequestPendingNoti(Quote quote) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiverEN = new Set<Id>();
        
        List<MessageGroup__c> mgList = [SELECT Id FROM MessageGroup__c WHERE Name = 'Commodity Reserves'];
        if(!mgList.isEmpty()) {
            List<Message_Group_Junction__c> mgjuncs = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :mgList[0].Id AND User__r.IsActive = true];
            if(!mgjuncs.isEmpty()) {
                for(Message_Group_Junction__c mgj : mgjuncs) {
                    receiverEN.add(mgj.User__c);
                }
            }
        }
        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Request Pending Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(quote.Name);
                history.alertID         = am[0].Id;
                history.targetID        = quote.Id;
                history.receiverforID   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* pending 요청 이메일 알람 */
    private static void sendRequestPendingEmail(Quote quote, String reason, String stockNumber) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiverEN = new List<String>();
        Set<Id> userIds = new Set<Id>();

        List<MessageGroup__c> mgList = [SELECT Id FROM MessageGroup__c WHERE Name = 'Commodity Reserves'];
        if(!mgList.isEmpty()) {
            List<Message_Group_Junction__c> mgjuncs = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c = :mgList[0].Id AND User__r.IsActive = true];
            if(!mgjuncs.isEmpty()) {
                for(Message_Group_Junction__c mgj : mgjuncs) {
                    userIds.add(mgj.User__c);
                }
            }
        }

        if(!userIds.isEmpty()) {
            List<User> users = DN_WithoutSharingClass.getUserEmails(userIds);
            for(User u : users) {
                receiverEN.add(u.Email);    
            }
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Request Pending Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList.add(quote.Name);
                history.elementList.add(quote.Owner.Name);
                history.elementList.add(stockNumber);
                history.elementList.add(reason);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + quote.Id);
                history.alertID             = am[0].Id;
                history.targetID            = quote.Id;
                history.receiverforEmail    = receiverEN;
                history.alertLanguage       = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* pending 확정 알람 */
    private static void sendConfirmPendingNoti(Quote quote) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiverEN = new Set<Id>();
        
        receiverEN.add(quote.OwnerId);
        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Confirm Pending Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(quote.Name);
                history.alertID         = am[0].Id;
                history.targetID        = quote.Id;
                history.receiverforID   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* pending 확정 이메일 */
    private static void sendConfirmPendingEmail(Quote quote, String reason) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiverEN = new List<String>();

        User u = DN_WithoutSharingClass.getUserEmail(quote.OwnerId);
        receiverEN.add(u.Email);

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Confirm Pending Alert' LIMIT 1];

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        String recordLink = baseUrl + '/' + quote.Id;

        if(!am.isEmpty()) {
            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList.add(quote.Name);
                history.elementList.add(quote.DNSAModel__c != null ? quote.DNSAModel__r.Name : '');
                history.elementList.add(reason);
                history.elementList.add(recordLink);
                history.alertID             = am[0].Id;
                history.targetID            = quote.Id;
                history.receiverforEmail    = receiverEN;
                history.alertLanguage       = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* Account 주소 정보 조회 */
    @AuraEnabled
    public static List<Account> getAccountShipAddress(List<Id> accountIds){
        try {
            System.debug('accountIds : ' + accountIds);
            List<Account> accList = [
                SELECT  Id, ShippingAddress
                FROM    Account 
                WHERE   Id =: accountIds[0]
            ];
            
            return accList;
            
        } catch (Exception e) {
            System.debug('getAccountAddress : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* holding 세팅 */
    @AuraEnabled
    public static String setHolding(String recordId) {
        try {
            Quote quote = [SELECT Id, ReserveExpirationDate__c FROM Quote WHERE Id = :recordId LIMIT 1];
            if(quote.ReserveExpirationDate__c != null) {
                quote.ReserveExpirationDate__c = quote.ReserveExpirationDate__c.addDays(1);
                update quote;
            } else {
                return 'null';
            }
            
        } catch (Exception e) {
            System.debug('getAccountAddress : ' + e.getLineNumber() + ' / ' + e.getMessage());
            // throw new AuraHandledException(e.getMessage());
            return e.getMessage();
        }
        return 'Success';
    }

    /* 인벤토리 정보 wrapper */
    public class InventoryWrapper {
        @AuraEnabled public String VBELN_ST         {get;set;}
        @AuraEnabled public String BASE_CODE        {get;set;}
        @AuraEnabled public String NC               {get;set;}
        @AuraEnabled public String LIST_PRICE       {get;set;}
        @AuraEnabled public String SERIAL_NUMBER    {get;set;}

        @AuraEnabled public String ADJUSTED_LIST    {get;set;}
        @AuraEnabled public String PERCENT_OFF      {get;set;}
        @AuraEnabled public String DEPT             {get;set;}
        @AuraEnabled public String DNSA_MODEL       {get;set;}
        @AuraEnabled public String ETA_DATE         {get;set;}
        @AuraEnabled public String INVENTORY_STS    {get;set;}
        @AuraEnabled public String LOCATION         {get;set;}
        @AuraEnabled public String MC_TC            {get;set;}
        @AuraEnabled public String ORDER_STS        {get;set;}
        @AuraEnabled public String PORT             {get;set;}
        @AuraEnabled public String PROD_DATE        {get;set;}
        @AuraEnabled public String WAERK            {get;set;}
        @AuraEnabled public String OPEN_NOTES       {get;set;}
        @AuraEnabled public String dealerName       {get;set;}
        @AuraEnabled public String userName         {get;set;}
        @AuraEnabled public String crm1             {get;set;}
        @AuraEnabled public String crm2             {get;set;}
        @AuraEnabled public String crm3             {get;set;}
        @AuraEnabled public String cssClass         {get;set;}

        @AuraEnabled public String SQTXT            {get;set;}
        @AuraEnabled public String modelName        {get;set;}

        public InventoryWrapper() {
            this.VBELN_ST       = '';
            this.BASE_CODE      = '';
            this.NC             = '';
            this.LIST_PRICE     = '';
            this.SERIAL_NUMBER  = '';
            this.ADJUSTED_LIST  = '';
            this.PERCENT_OFF    = '';
            this.DEPT           = '';
            this.DNSA_MODEL     = '';
            this.ETA_DATE       = '';
            this.INVENTORY_STS  = '';
            this.LOCATION       = '';
            this.MC_TC          = '';
            this.ORDER_STS      = '';
            this.PORT           = '';
            this.PROD_DATE      = '';
            this.WAERK          = '';
            this.OPEN_NOTES     = '';
            this.dealerName     = '';
            this.userName       = '';
            this.crm1           = '';
            this.crm2           = '';
            this.crm3           = '';
            this.cssClass       = '';
            this.SQTXT          = '';
            this.modelName      = '';
        }
    }

    /* 결과 wrapper */
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errMessage {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}
        
        public ResultWrapper(){
            this.isSuccess  = true;
            this.errMessage = '';
            this.data = new Map<String, Object>();
        }
    }
}