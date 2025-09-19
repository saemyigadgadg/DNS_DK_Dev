/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/

global with sharing class ReservationAutoCancelBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            System.debug('ReservationAutoCancelBatch Start ------------');
            String query;
            if(!Test.isRunningTest()) {
                query =  'SELECT Id, BookingDate__c, Quote.IsBooking__c, StockResSO__c, CreatedById, QuoteId, FM_Model__c, Quote.ReserveExpirationDate__c, Quote.PendingExpirationDate__c, ' +
                                'Quote.ReserveStatus__c, Quote.IsRequestPending__c, Quote.AccountId, Quote.Account.CustomerCode__c, Quote.CreatedBy.Account.CustomerCode__c ' +
                                'FROM QuoteLineItem ' +
                                'WHERE Quote.IsBooking__c = true ' +
                                'AND Order__r.ERPRSONo__c = NULL ';
            } else {
                query =  'SELECT Id, BookingDate__c, Quote.IsBooking__c, StockResSO__c, CreatedById, QuoteId, FM_Model__c, Quote.ReserveExpirationDate__c, Quote.PendingExpirationDate__c, ' +
                                'Quote.ReserveStatus__c, Quote.IsRequestPending__c, Quote.AccountId, Quote.Account.CustomerCode__c, Quote.CreatedBy.Account.CustomerCode__c ' +
                                'FROM QuoteLineItem ' +
                                'WHERE Quote.IsBooking__c = true ' +
                                'AND Order__r.ERPRSONo__c = NULL LIMIT 10';
            }
            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            System.debug('ReservationAutoCancelBatch Execute ------------');
            Map<String, QuoteLineItem> qliMap = new Map<String, QuoteLineItem>(); /// StockResSO__c -> QuoteLineItem
            Map<String, List<QuoteLineItem>> toDeleteMap = new Map<String, List<QuoteLineItem>>(); /// StockResSO__c -> List<QuoteLineItem>
            Map<String, Set<Id>> quoteIdsMap = new Map<String, Set<Id>>(); /// StockResSO__c -> Set<QuoteId>
            Set<String> stockNumbers = new Set<String>();
            Date today = Date.today();

            /// 조건에 따라 삭제 대상 분류
            for (QuoteLineItem qli : (List<QuoteLineItem>) scope) {
                if (qli.StockResSO__c == null) continue;

                Boolean shouldDelete = false;
                if (qli.Quote.ReserveStatus__c == 'PENDING' || qli.Quote.ReserveStatus__c == 'P REQUEST') {
                    if (today >= qli.Quote.PendingExpirationDate__c) {
                        shouldDelete = true;
                    }
                } else if (qli.Quote.ReserveStatus__c == 'RESERVED') {
                    if (today >= qli.Quote.ReserveExpirationDate__c) {
                        shouldDelete = true;
                    }
                }

                if (shouldDelete) {
                    if (!toDeleteMap.containsKey(qli.StockResSO__c)) {
                        toDeleteMap.put(qli.StockResSO__c, new List<QuoteLineItem>());
                        quoteIdsMap.put(qli.StockResSO__c, new Set<Id>());
                    }
                    toDeleteMap.get(qli.StockResSO__c).add(qli);
                    qliMap.put(qli.StockResSO__c, qli);
                    stockNumbers.add(qli.StockResSO__c);
                    quoteIdsMap.get(qli.StockResSO__c).add(qli.QuoteId);
                }
            }

            if (!toDeleteMap.isEmpty()) {
                List<QuoteLineItem> allQliList = DN_WithoutSharingClass.queryQuoteLineItemsSet(stockNumbers);
                Map<String, List<QuoteLineItem>> stockToQliMap = new Map<String, List<QuoteLineItem>>();
                Set<Id> allQuoteIds = new Set<Id>();
                for (QuoteLineItem qli : allQliList) {
                    if (!stockToQliMap.containsKey(qli.StockResSO__c)) {
                        stockToQliMap.put(qli.StockResSO__c, new List<QuoteLineItem>());
                    }
                    stockToQliMap.get(qli.StockResSO__c).add(qli);
                    allQuoteIds.add(qli.QuoteId);
                }

                List<Quote> allQuoteList = DN_WithoutSharingClass.queryQuotes(allQuoteIds);
                Map<Id, Quote> quoteMap = new Map<Id, Quote>(allQuoteList);

                Map<Id, Quote> quotesToUpdateMap = new Map<Id, Quote>();
                List<Quote> qList = [
                    SELECT  Id
                            , IsBooking__c
                            , TotalPrice__c
                            , Accessory_TotalPrice__c
                            , ExtWarranty__c
                            , ServiceReimbursement__c
                            , serviceReimbursementPrice__c
                            , ReserveStatus__c
                            , PendingExpirationDate__c
                            , IsRequestPending__c
                            , Waiting_Seq__c
                            , Pending_Reason__c
                            , Canceller__c
                            , QuoteCancelDate__c
                    FROM Quote 
                    WHERE Id IN :allQuoteIds
                ];
                List<Accessory__c> accessoriesToDelete = [SELECT Id, Quote__c FROM Accessory__c WHERE Quote__c IN :allQuoteIds];
                List<Order> orderToDelete = [SELECT Id, QuoteId FROM Order WHERE QuoteId IN :allQuoteIds];
                Map<Id, List<Accessory__c>> accessoryMap = new Map<Id, List<Accessory__c>>();
                if(!accessoriesToDelete.isEmpty()) {
                    for (Accessory__c acc : accessoriesToDelete) {
                        if (!accessoryMap.containsKey(acc.Quote__c)) {
                            accessoryMap.put(acc.Quote__c, new List<Accessory__c>());
                        }
                        accessoryMap.get(acc.Quote__c).add(acc);
                    }
                }

                Map<Id, List<Order>> orderMap = new Map<Id, List<Order>>();
                if(!orderToDelete.isEmpty()) {
                    for (Order ord : orderToDelete) {
                        if (!orderMap.containsKey(ord.QuoteId)) {
                            orderMap.put(ord.QuoteId, new List<Order>());
                        }
                        orderMap.get(ord.QuoteId).add(ord);
                    }
                }

                Map<String, String> responseMap = processBooking(qliMap, 'C');

                for (String stockResSO : responseMap.keySet()) {
                    String recode = responseMap.get(stockResSO);
                    
                    if (recode == 'S') {
                        List<QuoteLineItem> toDelete = toDeleteMap.get(stockResSO);
                        Set<Id> quoteIds = quoteIdsMap.get(stockResSO);

                        if (toDelete != null && !toDelete.isEmpty()) {
                            sendCancelAlert(toDelete);
                            delete toDelete;
    
                            List<QuoteLineItem> relatedQlis = stockToQliMap.get(stockResSO) != null ? stockToQliMap.get(stockResSO) : new List<QuoteLineItem>();
                            List<Quote> quotesToUpdate = nextReserveSetting(stockResSO, new List<QuoteLineItem>{qliMap.get(stockResSO)}, relatedQlis, quoteMap);
                            if (!quotesToUpdate.isEmpty()) {
                                quotesToUpdateMap.putAll(quotesToUpdate);
                            }
    
                            for (Quote q : qList) {
                                if (quoteIds.contains(q.Id)) {
                                    q.IsBooking__c                  = false;
                                    q.TotalPrice__c                 = null;
                                    q.Accessory_TotalPrice__c       = null;
                                    q.ExtWarranty__c                = null;
                                    q.ServiceReimbursement__c       = null;
                                    q.ServiceReimbursementPrice__c  = null;
                                    q.ReserveExpirationDate__c      = null;
                                    q.ReserveStatus__c              = 'Cancel';
                                    q.PendingExpirationDate__c      = null;
                                    q.IsRequestPending__c           = false;
                                    q.Waiting_Seq__c                = null;
                                    q.Pending_Reason__c             = null;
                                    q.StockResSO__c                 = null;
                                    q.Canceller__c                  = UserInfo.getUserId();
                                    q.QuoteCancelDate__c            = Date.today();
                                    quotesToUpdateMap.put(q.Id, q);
                                }
                            }
    
                            List<Accessory__c> acceToDelete = new List<Accessory__c>();
                            List<Order> ordToDelete = new List<Order>();
                            for (Id quoteId : quoteIds) {
                                if (accessoryMap.containsKey(quoteId)) {
                                    acceToDelete.addAll(accessoryMap.get(quoteId));
                                }
                                if (orderMap.containsKey(quoteId)) {
                                    ordToDelete.addAll(orderMap.get(quoteId));
                                }
                            }
                            if (!acceToDelete.isEmpty()) {
                                delete acceToDelete;
                            }
                            if (!ordToDelete.isEmpty()) {
                                delete ordToDelete;
                            }
                        }
                    } else {
                        System.debug('Auto Cancel ERROR for stockResSO ' + stockResSO + ' ::: ' + recode);
                    }
                }

                if (!quotesToUpdateMap.isEmpty()) {
                    DN_WithoutSharingClass.updateQuotes(quotesToUpdateMap.values());
                }
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        try {
            System.debug('ReservationAutoCancelBatch Finish ------------');
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void execute(SchedulableContext sc) {
        ReservationAutoCancelBatch batch = new ReservationAutoCancelBatch();
        Database.executeBatch(batch, 200);        
    }

    private static Map<String, String> processBooking(Map<String, QuoteLineItem> qliMap, String code) {
        Map<String, String> responseMap = new Map<String, String>();
        IF_ERP_Order_Classes.IF_ORDER_011_Res response = new IF_ERP_Order_Classes.IF_ORDER_011_Res();
        Set<Id> ownerIds = new Set<Id>();
        for (QuoteLineItem qli : qliMap.values()) {
            if (qli.CreatedById != null) {
                ownerIds.add(qli.CreatedById);
            }
        }
        List<User> users = [SELECT Id, AccountId, Account.CustomerCode__c, Name FROM User WHERE Id IN :ownerIds];

        IF_ERP_Order instance = new IF_ERP_Order();

        for (String stockResSO : qliMap.keySet()) {
            QuoteLineItem qli = qliMap.get(stockResSO);
            Quote quote = qli.Quote;
            String ownerId = qli.CreatedById;

            User matchingUser = null;
            for (User u : users) {
                if (u.Id == ownerId) {
                    matchingUser = u;
                    break;
                }
            }

            if (matchingUser != null) {
                String customerCode = (matchingUser.AccountId != null && matchingUser.Account.CustomerCode__c != null) 
                                    ? matchingUser.Account.CustomerCode__c 
                                    : quote.CreatedBy.Account.CustomerCode__c != null 
                                    ? quote.CreatedBy.Account.CustomerCode__c 
                                    : '0001323499';
                while (customerCode.length() < 10) {
                    customerCode = '0' + customerCode;
                }

                String shipToCode = (quote.Account.CustomerCode__c != null) ? quote.Account.CustomerCode__c : '0001323499';
                while (shipToCode.length() < 10) {
                    shipToCode = '0' + shipToCode;
                }

                IF_ERP_Order_Classes.IF_ORDER_011_Req req = new IF_ERP_Order_Classes.IF_ORDER_011_Req();
                req.I_OKCODE        = code;
                req.I_CRM_ID        = ownerId;
                req.I_CRM_NAME      = matchingUser.Name;
                req.I_CRM_SOLD_TO   = customerCode;

                List<IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM> T_ITEM_List = new List<IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM>();
                IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM T_ITEM1 = new IF_ERP_Order_Classes.IF_ORDER_011_Req_T_ITEM();
                T_ITEM1.VBELN_ST    = stockResSO;
                T_ITEM1.DEALER      = customerCode;
                T_ITEM1.CUSTOMER    = shipToCode;
                T_ITEM1.CRM_REID    = quote.Id;

                T_ITEM_List.add(T_ITEM1);
                req.T_ITEM = T_ITEM_List;

                instance.interfaceUtil.isInsertLog = false;
                response = instance.IF_ORDER_011(req);
                responseMap.put(stockResSO, response.O_RECODE);
            }
        }
        instance.interfaceUtil.saveInterfaceLog();
        return responseMap;
    }

    private static void sendCancelAlert(List<QuoteLineItem> cancelQliList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Booking Auto Cancel Alert' LIMIT 1];

        if (!am.isEmpty()) {
            Set<Id> ownerSet = new Set<Id>();
            Map<Id, String> ownerEmailMap = new Map<Id, String>();
            
            for (QuoteLineItem qli : cancelQliList) {
                if (qli.CreatedById != null) {
                    ownerSet.add(qli.CreatedById);
                }
            }
            
            List<User> users = [SELECT Id, Email FROM User WHERE Id IN :ownerSet];
            for (User user : users) {
                ownerEmailMap.put(user.Id, user.Email);
            }
    
            if (!ownerSet.isEmpty()) {
                for (QuoteLineItem qli : cancelQliList) {
                    if (ownerSet.contains(qli.CreatedById)) {
                        Set<Id> receiverEN = new Set<Id>{qli.CreatedById};
    
                        // Notification
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType       = 'Notification';
                        history.elementList     = new List<String>();
                        history.elementList.add(qli.FM_Model__c);
                        history.alertID         = am[0].Id;
                        history.targetID        = qli.QuoteId;
                        history.receiverforID   = receiverEN;
                        history.alertLanguage   = 'en';
                        ahwList.add(history);
    
                        // Email
                        UTIL_Alert.HistoryWrapper emailHistory = new UTIL_Alert.HistoryWrapper();
                        emailHistory.alertType       = 'Email';
                        emailHistory.elementList     = new List<String>();
                        emailHistory.elementList.add(qli.FM_Model__c);
                        emailHistory.elementList.add(String.valueOf(qli.BookingDate__c));
                        emailHistory.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + qli.QuoteId);
                        emailHistory.alertID         = am[0].Id;
                        emailHistory.targetID        = qli.QuoteId;
                        List<String> receiverEmailList = new List<String>();
                        if (ownerEmailMap.containsKey(qli.CreatedById)) {
                            receiverEmailList.add(ownerEmailMap.get(qli.CreatedById));
                        }
                        emailHistory.receiverforEmail   = receiverEmailList;
                        emailHistory.alertLanguage      = 'en';
                        ahwList.add(emailHistory);
                    }
                }
            }
    
            if (!ahwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(ahwList);
            }
        }
    }

    private static List<Quote> nextReserveSetting(String stockNumber, List<QuoteLineItem> deletedQlis, List<QuoteLineItem> relatedQlis, Map<Id, Quote> quoteMap) {
        List<Quote> updateList = new List<Quote>();

        if (!relatedQlis.isEmpty()) {
            for (QuoteLineItem qli : relatedQlis) {
                Quote q = quoteMap.get(qli.QuoteId);
                if (q != null) {
                    if (q.Waiting_Seq__c == '2') {
                        q.Waiting_Seq__c = '1';
                        q.IsBooking__c = true;
                        q.ReserveExpirationDate__c = Date.today().addDays(1);
                        updateList.add(q);
                    } else if (q.Waiting_Seq__c == '3') {
                        q.Waiting_Seq__c = '2';
                        updateList.add(q);
                    }
                }
            }
        }
        return updateList;
    }
}