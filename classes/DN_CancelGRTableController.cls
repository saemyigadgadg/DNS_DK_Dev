/** 
 * @Class : DN_CancelGRTableController
 * 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 02. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-02 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_CancelGRTableController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 검색 타입에 따라 DNS 구매 목록 또는 대리점 구매 목록 메소드 호출
    **/ 
    @AuraEnabled
    public static List<CancelGR> getDataList(SearchOption search){
        try {
            List<CancelGR> returnCancelGRList = new List<CancelGR>(); 
            if(search.gRtype !='2') {
                returnCancelGRList = agencyList(search);
            } else { // DNS 구매
                returnCancelGRList = dnsList(search);
            }
            return returnCancelGRList;
        } catch (Exception e) {
            System.debug(e.getMessage() +' >==e.getMessage()');
            System.debug(e.getLineNumber() +' >==e.getLineNumber()');
            throw new DN_CancelGRTableControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 입고 취소
    **/ 
    @AuraEnabled
    public static GRExcel gRCancel(List<CancelGR> cancelList, String type){
        try {
            System.debug(cancelList + ' :: cancelList');
            set<String> partIds = new set<String>();
            GRExcel returnGRExcel = new GRExcel();
            set<String> invenIds = new set<String>();
            set<String> dnsIds = new set<String>();
            List<DealerInventoryMovements__c> dmlCancelList = new List<DealerInventoryMovements__c>();
            RecordType recType = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='DealerInventoryMovements__c' AND DeveloperName='GoodsReceipt'];
            for(CancelGR gr : cancelList) {
                invenIds.add(gr.id);  
                dnsIds.add(gr.dNSId);
                partIds.add(gr.partId);
            }
            List<DealerStock__c> stockList = [
                SELECT Id, Name, DealerLocation__c,Part__c
                FROM DealerStock__c 
                where Part__c IN :partIds AND Dealer__c =:currentUser.getAgencyId()
            ];
            Map<String,String> stockMap = new Map<String,String>();
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__c,stock.Id);
            }
            Map<String,DealerInventoryMovements__c> invenMap = new Map<String,DealerInventoryMovements__c>();
            List<DealerInventoryMovements__c> invenList = 
                [
                    select Id,Name,Quantity__c, Location__c, CustomerPrice__c,DiscountPrice__c,Reason__c
                        ,DiscountAmount__c,CurrencyIsoCode,Type__c,DealerPurchaseOrderItem__c
                        from DealerInventoryMovements__c 
                        where Id IN:invenIds 
                        AND InventoryChange__c ='S' FOR UPDATE
                ];
            for(DealerInventoryMovements__c del : invenList) {
                invenMap.put(del.Id, del);
            }
            // DNS 반품 정보
            set<String> purOrderItemIds = new set<String>();
            List<PurchaseOrderItems__c> purchaseOrderList = [select Id, Name, UnitPrice__c from PurchaseOrderItems__c where Id IN: dnsIds];
            Map<String,PurchaseOrderItems__c> itemMap = new Map<String,PurchaseOrderItems__c>();
            for(PurchaseOrderItems__c items : purchaseOrderList) {
                itemMap.put(items.Id,items);   
            }
            //채번
            SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
            String grNumber = seqGenerator.generate(recType.DeveloperName);
            map<String,Decimal> cancelQtyMap = new Map<String,Decimal>();
            for(CancelGR cGr : cancelList) {
                DealerInventoryMovements__c parntInven = invenMap.get(cGr.id);
                DealerInventoryMovements__c cancel = new DealerInventoryMovements__c();
                cancel.Quantity__c = cGr.cancelGRQty;
                //cancel.Location__c = cGr.locationId;
                cancel.DealerStock__c = stockMap.get(cGr.partId);
                cancel.Part__c = cGr.partId;
                cancel.RecordTypeId = recType.Id;
                cancel.SalesOrganization__c = currentUser.getSalesOranization();
                cancel.DistributionChannel__c = currentUser.getDistributionChannel();
                cancel.Division__c = currentUser.getDivision();
                cancel.dealer__c = currentUser.getAgencyId();
                cancel.InventoryChange__c = 'H';
                if(parntInven !=null) {
                    cancel.Type__c = parntInven.Type__c;
                    cancel.CustomerPrice__c = parntInven.CustomerPrice__c;
                    cancel.DiscountPrice__c = parntInven.DiscountPrice__c;
                    cancel.DiscountAmount__c = (parntInven.DiscountPrice__c * cGr.cancelGRQty);
                    cancel.CurrencyIsoCode = parntInven.CurrencyIsoCode;
                    cancel.DealerPurchaseOrderItem__c = parntInven.DealerPurchaseOrderItem__c;
                    cancel.Reason__c = parntInven.Reason__c;
                    cancel.GoodsReceiptNumber__c = parntInven.Id;
                } 
                cancel.Type__c = type;
                cancel.InventoryNumber__c = grNumber;
                cancel.InventoryItemNumber__c =  cGr.itemNumber;  //itemNumber
                
                
                // DNS 반품
                if(type=='2') {
                    cancel.PurchaseOrderItem__c = cGr.dNSId;
                    cancel.CustomerPrice__c = itemMap.get(cGr.dNSId).UnitPrice__c;
                    cancel.DiscountPrice__c = itemMap.get(cGr.dNSId).UnitPrice__c;
                    cancel.DiscountAmount__c = (itemMap.get(cGr.dNSId).UnitPrice__c * cGr.cancelGRQty );
                    purOrderItemIds.add(cGr.dNSId);
                }             
                
                dmlCancelList.add(cancel);
            }
            System.debug(dmlCancelList + ' :L:: dmlCancelList');
            insert dmlCancelList;
            Map<String,Decimal> returnOrderMap = new Map<String,Decimal>();
            // 반품 오더별로 반품 수량 조회
            List<AggregateResult> invenCancelList = [
                    SELECT PurchaseOrderItem__c,SUM(Quantity__c) Quantity__c
                    FROM DealerInventoryMovements__c
                    where PurchaseOrderItem__c IN:purOrderItemIds 
                    AND PurchaseOrderItem__c !=null
                    AND InventoryChange__c ='H'
                    GROUP BY PurchaseOrderItem__c
                ];
            for(AggregateResult age : invenCancelList) {
                returnOrderMap.put( (String)age.get('PurchaseOrderItem__c'), (Decimal)age.get('Quantity__c'));
            }
            //DNS 반품정보
            if(purOrderItemIds.size() > 0) {
                //IsGRCancel__c
                List<PurchaseOrderItems__c> updateList = new List<PurchaseOrderItems__c>();
                List<PurchaseOrderItems__c> returnOrList = [select Id,IsGRCancel__c,Quantity__c from PurchaseOrderItems__c where Id IN:purOrderItemIds ];
                for(PurchaseOrderItems__c purs : returnOrList) {
                    if(returnOrderMap.get(purs.Id) == purs.Quantity__c) {
                        purs.IsGRCancel__c = true;
                        updateList.add(purs);
                    }
                }
                update updateList;
            }   

            set<String> dmlCancelIds = new set<String>();
            for(DealerInventoryMovements__c cancels : dmlCancelList) {
                cancelQtyMap.put(cancels.Part__c, -cancels.Quantity__c);
                dmlCancelIds.add(cancels.Id);
            }
            List<DealerInventoryMovements__c> returnList = 
                [
                    select Id,DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c,GoodsReceiptNumber__c,Part__r.FM_MaterialDetails__c,
                        PurchaseOrderItem__r.PurchaseOrder__r.Name, Name,InventoryNumber__c,Part__r.Name,GoodsReceiptNumber__r.InventoryNumber__c,
                        Part__r.ProductCode, Quantity__c,Location__r.FM_Loc__c,CreatedDate,Part__c,
                        PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c,DealerStock__r.DealerLocation__r.FM_Loc__c
                        from DealerInventoryMovements__c 
                        where Id IN:dmlCancelIds
                ];
            DN_DealerStockManager.getAvailable(cancelQtyMap, 'GR','');
            returnGRExcel.doc = grNumber;
            for(DealerInventoryMovements__c inven : returnList) {
                returnGRExcel.createdDate = inven.CreatedDate.format('yyyy-MM-dd'); 
                returnGRExcel.createdTime = inven.CreatedDate.format('HH:mm:ss'); 
            }
            returnGRExcel.agencyName = currentUser.getAgencyName();
            returnGRExcel.returnGRList = returnList;
            //채번 업데이트
            seqGenerator.updateNextSequenceInfo();
            return returnGRExcel;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 대리점 구매, 기타입고
    **/ 
    public static List<CancelGR> agencyList(SearchOption search) {
        try {
            System.debug(' search ::: '+search);
            List<CancelGR> returnCancelGR = new List<CancelGR>();
            List<CancelGR> returnCancelSetGR = new List<CancelGR>();
            RecordType recType = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='DealerInventoryMovements__c' AND DeveloperName='GoodsReceipt'];
            String query = 'select Id,InventoryNumber__c,  PurchaseOrderItem__c,InventoryItemNumber__c ,Part__r.ProductCode,Part__r.Name,Part__c,Part__r.ProductSpec__c, Quantity__c,DiscountAmount__c,CreatedDate';
            query += ',InventoryChange__c,Part__r.FM_MaterialDetails__c from DealerInventoryMovements__c';
            query +=' where Dealer__c =\''+currentUser.getAgencyId()+'\'';
            query += ' AND Type__c =\''+search.gRtype+'\'';
            query += ' AND InventoryChange__c =\'S\'';
            // 주문일자 필터
            List<String> startSet = search.dateGRStart.split('-');
            List<String> endSet = search.dateGREnd.split('-');
            DateTime startDate = DateTime.newInstanceGMT(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));
            DateTime endDate = DateTime.newInstanceGMT(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]),23,59,59);            
            System.debug(startDate + ' < ==startDate');
            System.debug(endDate + ' < ==endDate');
            query += ' AND (CreatedDate >=:startDate AND CreatedDate <=:endDate )';
            //InventoryChange__c == H

            // 입고문서
            if(String.isNotBlank(search.docNumber)) {
                query += ' AND InventoryNumber__c =\''+search.docNumber+'\'';
            }
            System.debug(search.productCode + ' :: search.partId');
            //품번
            if(String.isNotBlank(search.productCode)) {
                query += ' AND Part__c =\''+search.partId+'\'';
            }
            System.debug( 'query :::: '+query);
            List<DealerInventoryMovements__c> grList = Database.query(query);
            System.debug(grList  +' :::grList');
            // 취소수량 멥
            Map<String,AggregateResult> canCelMap = new Map<String,AggregateResult>();
            Map<String,DealerStock__c> dealerStockMap = new Map<String,DealerStock__c>();
            set<String> partIds = new set<String>();
            for(DealerInventoryMovements__c inventoryM : grList) {
                partIds.add(inventoryM.Part__c);              
                CancelGR grC = new CancelGR(inventoryM);
                returnCancelGR.add(grC);
            }
            System.debug(returnCancelGR + ' ::::returnCancelGR');
            // 재고관리
            List<DealerStock__c> stockList = [select Id, DealerLocation__c ,DealerLocation__r.FM_Loc__c, Part__c,CurrentStockQuantity__c from DealerStock__c where Part__c IN : partIds AND Dealer__c =:currentUser.getAgencyId()];
            for(DealerStock__c stoc : stockList) {
                dealerStockMap.put(stoc.Part__c, stoc);
            }
            
            //취소 목록
            List<AggregateResult> cancelList = 
                [
                    select GoodsReceiptNumber__c, SUM(Quantity__c) Quantity__c FROM DealerInventoryMovements__c where Dealer__c =:currentUser.getAgencyId() 
                        AND SalesOrganization__c =:currentUser.getSalesOranization() AND Division__c =:currentUser.getDivision() AND DistributionChannel__c =:currentUser.getDistributionChannel()  AND GoodsReceiptNumber__c !=null AND InventoryChange__c = 'H' 
                        group by GoodsReceiptNumber__c
                ];
            for(AggregateResult	 invenCancel : cancelList) {
                canCelMap.put((String)invenCancel.get('GoodsReceiptNumber__c'), invenCancel);
            }

            for(CancelGR canGr: returnCancelGR) {
                AggregateResult cencalInventory = canCelMap.get(canGr.id);// == null?new DealerInventoryMovements__c() : canCelMap.get(canGr.partId);
                DealerStock__c currentStock = dealerStockMap.get(canGr.partId) == null ? new DealerStock__c() : dealerStockMap.get(canGr.partId);
                System.debug(currentStock.get('DealerLocation__c') + ' ::: currentStock.DealerLocation__c');
                canGr.location = currentStock.get('DealerLocation__c') !=null ? currentStock.DealerLocation__r.FM_Loc__c : '';
                canGr.stockQty = currentStock.CurrentStockQuantity__c;
                //System.debug(canGr.partId +' < ==canGr.partId');
                System.debug(cencalInventory + ' < ==cencalInventory');
                canGr.canceledlGRQty = cencalInventory == null ? 0 : (Decimal)cencalInventory.get('Quantity__c');
                
                canGr.cancelAvailableGRQty = canGr.firstGRQty - canGr.canceledlGRQty;
                System.debug(canGr.cancelAvailableGRQty+' < ==canGr.cancelAvailableGRQty');
                canGr.cancelGRQty = 0;
                if(canGr.cancelAvailableGRQty >= 1) {
                    returnCancelSetGR.add(canGr);
                }
            }
            System.debug(returnCancelSetGR + ' ::: returnCancelSetGR');
            return returnCancelSetGR;
            
        } catch (Exception e) {
            System.debug(e.getMessage() +' >==e.getMessage()');
            System.debug(e.getLineNumber() +' >==e.getLineNumber()');
            throw new DN_CancelGRTableControllerException(e.getMessage());
        } 
       
    }

    /**
     * @Description
     * 	- DNS 반품정보
    **/ 
    public static List<CancelGR> dnsList(SearchOption search) {
        try {
            List<CancelGR> returnCancelGR = new List<CancelGR>();
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res ifRes = getDNSReturnList(search);
        
            List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ET_LIST> dnsReturnList = ifRes.ET_LIST;
            Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ET_LIST> dnsResMap = new Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ET_LIST>();
            Map<String,Product2> partMap = new Map<String,Product2>();
            Map<String,DealerStock__c> stockMap = new Map<String,DealerStock__c>();
            set<String> dnsReturnSet = new set<String>();
            set<String> dnsReturnDocSet = new set<String>();
            Map<String,AggregateResult> cancelMap = new Map<String,AggregateResult>();
            Map<String,AggregateResult> lastGRMap = new Map<String,AggregateResult>();
            Map<String,DealerInventoryMovements__c> invenMap = new Map<String,DealerInventoryMovements__c>();
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res_ET_LIST dnsRet : dnsReturnList) {
                System.debug(dnsRet + ' :::::dnsRet');
                dnsReturnSet.add(dnsRet.RETNO);
                dnsResMap.put(dnsRet.RETNO, dnsRet);
                partMap.put(dnsRet.MATNR, null);
            }
            System.debug(dnsReturnSet + ' ::: dnsReturnSet');
            //CRM에 DNS 반품 정보
            List<PurchaseOrderItems__c> crmReturnList = [
                select Id,Name,
                PurchaseOrder__r.Buyer__c,
                OrderPartNo__c,
                PurchaseOrder__r.PartOrderNo__c
                from PurchaseOrderItems__c 
                where PurchaseOrder__r.RecordType.DeveloperName ='ReturnOrder'
                AND PurchaseOrder__r.Buyer__c =:currentUser.getAgencyId()
                AND PurchaseOrder__r.PartOrderNo__c	 IN : dnsReturnSet
                AND IsGRCancel__c = false
            ];
            //기존 입고 정보
            List<DealerInventoryMovements__c> invenList = [
                select Id,
                PurchaseOrderItem__c,
                Part__c
                from DealerInventoryMovements__c
                where PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c IN : dnsReturnSet
                AND InventoryChange__c ='S' 
            ];
            System.debug(invenList  + ' ::: invenList');
            System.debug(dnsReturnSet  + ' ::: dnsReturnSet');
            for(DealerInventoryMovements__c inven : invenList) {
                invenMap.put(inven.PurchaseOrderItem__c, inven);
            }

            // 제품정보
            List<Product2> productList = [select Id, Name, ProductCode, ProductSpec__c, FM_MaterialDetails__c from Product2 where ProductCode IN : partMap.keySet()];
            for(Product2 prod : productList) {
                partMap.put(prod.ProductCode, prod);
            }
            // 재고 정보
            List<DealerStock__c> stockList = [select Id,Part__r.ProductCode, DealerLocation__c ,DealerLocation__r.FM_Loc__c, Part__c,CurrentStockQuantity__c from DealerStock__c where Dealer__c =:currentUser.getAgencyId() AND Part__r.ProductCode IN : partMap.keySet()];
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__r.ProductCode, stock);
            }
            System.debug(stockMap + ' ::: stockMap');
            // 취소 수량
            List<AggregateResult> cancelQTY = [
                select
                PurchaseOrderItem__c, 
                SUM(Quantity__c) Quantity__c,MAX(CreatedDate)CreatedDate
                from DealerInventoryMovements__c 
                where InventoryChange__c ='H' 
                AND PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c IN:dnsReturnSet
                group by PurchaseOrderItem__c
            ];
            for(AggregateResult ages : cancelQTY) {
                String orderId = (String) ages.get('PurchaseOrderItem__c');
                cancelMap.put(orderId, ages);
            }
            // 입고 일자
            List<AggregateResult> lastGrList = [
                select 
                PurchaseOrderItem__c, 
                Max(CreatedDate) CreatedDate
                from DealerInventoryMovements__c 
                where InventoryChange__c ='S' 
                AND PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c IN:dnsReturnSet
                group by PurchaseOrderItem__c
            ];
            for(AggregateResult ages : lastGrList) {
                String orderId = (String) ages.get('PurchaseOrderItem__c');
                lastGRMap.put(orderId, ages);
            }
            System.debug(crmReturnList.size() + ' size !!');
            for(PurchaseOrderItems__c purItem : crmReturnList) {
                System.debug(purItem.OrderPartNo__c + ' :: purItem.OrderPartNo__c');
                System.debug( purItem.PurchaseOrder__r.PartOrderNo__c + ' PurchaseOrder__r.PartOrderNo__c');
                CancelGR canGr = new CancelGR();
                if(invenMap.get(purItem.Id) !=null) {
                    System.debug(invenMap + ' ::: invenMap');
                    System.debug(purItem.Id + ' ::: invenMap');
                    canGr.id = invenMap.get(purItem.Id).Id;
                }
                canGr.dNSId = purItem.Id;//purItem.Id;
                System.debug(dnsResMap + ' :::: dnsResMap');
                // DNS Return 정보
                canGr.gRDocument           = dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c) == null ? '' : dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).RETNO; 
                canGr.dNSDocument           = dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c) == null ? '' : dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).DOCNO; 
                canGr.itemNumber            = dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c) == null ? '' : dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).DOCIT;
                canGr.firstGRQty            = dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c) == null ? 0  : Decimal.valueOf(dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).MENGE);
                // 연도, 월, 일을 분리
                String year = dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).ERDAT.substring(0, 4);
                String month = dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).ERDAT.substring(4, 6);
                String day = dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).ERDAT.substring(6, 8);
                System.debug(purItem.Id + ' :: purItem.Id');
                canGr.lastImportDateTime    = lastGRMap.get(purItem.Id) == null ? year +'-'+month+'-'+day : DateTime.valueOf(lastGRMap.get(purItem.Id).get('CreatedDate')).format('YYYY-MM-dd');
                // 부품 정보
                canGr.pratNumber            = partMap.get(purItem.OrderPartNo__c) == null ? '' : partMap.get(purItem.OrderPartNo__c).ProductCode;
                canGr.partName              = partMap.get(purItem.OrderPartNo__c) == null ? '' : partMap.get(purItem.OrderPartNo__c).FM_MaterialDetails__c;
                canGr.partId                = partMap.get(purItem.OrderPartNo__c) == null ? '' : partMap.get(purItem.OrderPartNo__c).Id;
                canGr.productSpec           = partMap.get(purItem.OrderPartNo__c) == null ? '' : partMap.get(purItem.OrderPartNo__c).ProductSpec__c ;
                // 저장위치 및 현재고
                canGr.location              = stockMap.get(purItem.OrderPartNo__c) == null ? '' : stockMap.get(purItem.OrderPartNo__c).DealerLocation__r.FM_Loc__c;
                canGr.locationId            = stockMap.get(purItem.OrderPartNo__c) == null ? '' : stockMap.get(purItem.OrderPartNo__c).DealerLocation__c;
                canGr.stockQty              = stockMap.get(purItem.OrderPartNo__c) == null ? 0  : stockMap.get(purItem.OrderPartNo__c).CurrentStockQuantity__c;
                System.debug(canGr.stockQty + ' ::: canGr.stockQty');
                System.debug(dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c) + ' :L::dnsResMap.get(purItem.OrderPartNo__c)');
                //계산식 //RMQTY 취소 가능 수량;;
                canGr.canceledlGRQty        = cancelMap.get(purItem.Id) == null ? 0 : (Decimal) cancelMap.get(purItem.Id).get('Quantity__c');//dnsResMap.get(purItem.OrderPartNo__c) == null ? 0  : Decimal.valueOf(dnsResMap.get(purItem.OrderPartNo__c).RMQTY);//
                canGr.cancelAvailableGRQty  = Decimal.valueOf(dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).RMQTY) - canGr.canceledlGRQty; // 취소 가능 수량 //dnsResMap.get(purItem.OrderPartNo__c) == null ? 0  : Decimal.valueOf(dnsResMap.get(purItem.OrderPartNo__c).RMQTY);
                canGr.cancelGRQty           = canGr.cancelAvailableGRQty; // 취소 요청 수량 //dnsResMap.get(purItem.OrderPartNo__c) == null ? 0  : Decimal.valueOf(dnsResMap.get(purItem.OrderPartNo__c).RMQTY);
                System.debug(Decimal.valueOf(dnsResMap.get(purItem.PurchaseOrder__r.PartOrderNo__c).RMQTY) + ' :: RMQTY');
                System.debug(canGr.canceledlGRQty + ' ::: canGr.canceledlGRQty');
                System.debug(canGr.cancelGRQty + ' ::: canGr.cancelGRQty');
                //if(canGr.cancelGRQty > 0) {
                    returnCancelGR.add(canGr);
                //}
            }
            System.debug(returnCancelGR + ' ::: DNS returnCancelGR');
            /**
             * MENGE -> 주문 수량
                ERDAT(출고일) -> 입고일
                DOCIT -> 항목
                MATNR -> 품번
                MAKTX -> 품명
                THREAD = > 규격
             */

            return returnCancelGR;    
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: e.getMessage()');
            System.debug(e.getStackTraceString() + ' :: e.getStackTraceString()');
            throw new DN_CancelGRTableControllerException(e.getMessage());
        } 
    }

    /**
     * @Description
     * 	- DNS 반품 정보 인터페이스
    **/
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Res getDNSReturnList(SearchOption search){
        try {
            
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req();
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req_IS_INPUT IS_INPUT = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req_IS_INPUT();
            IS_INPUT.TYPE        = search.gRtype;
            IS_INPUT.DATE_F      = search.dateGRStart.replace('-',''); //'20250201';//search.dateGRStart;
            IS_INPUT.DATE_T      = search.dateGREnd.replace('-','');//search.dateGREnd;
            IS_INPUT.DOCNO       = search.docNumber;
            IS_INPUT.MATNR       = search.productCode;

            req.IS_INPUT = IS_INPUT;

            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req_I_USERINFO I_USERINFO = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_014_Req_I_USERINFO();
            I_USERINFO.KUNNR     = '000'+ currentUser.getAgencyCustomerCode();
            I_USERINFO.VKORG     = currentUser.getSalesOranization();
            I_USERINFO.VTWEG     = currentUser.getDistributionChannel();
            I_USERINFO.SPART     = currentUser.getDivision();

            req.I_USERINFO = I_USERINFO;

            IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
            return instance.IF_DEALERSTOCK_014(req);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_CancelGRTableControllerException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- 검색 옵션
    **/
    public class SearchOption {
        @AuraEnabled public String gRtype {get;set;} // 입고유형 : 1 - 대리점 구매입고, 2-DNS 반품, 3-기타입고
        @AuraEnabled public String docNumber {get;set;} // 입고(DNS 반품) 문서번호
        @AuraEnabled public String dateGRStart {get;set;} // 입고기간 - 시작
        @AuraEnabled public String dateGREnd {get;set;} //  입고기간 -종료
        @AuraEnabled public String productCode {get;set;} //  품번
        @AuraEnabled public String partId {get;set;} //  부품 Id
    }

    /**
     * @Description
     * 	- 입고 취소 후 입고 액셀 데이터
    **/
    public class GRExcel {
        @AuraEnabled public String agencyName {get;set;} // 대리점명
        @AuraEnabled public String doc {get;set;} // 참고문서
        @AuraEnabled public String createdDate {get;set;} 
        @AuraEnabled public String createdTime {get;set;} 
        @AuraEnabled public List<DealerInventoryMovements__c> returnGRList {get;set;} 
        public GRExcel() {
            this.returnGRList = new List<DealerInventoryMovements__c>();
        }
    }

    /**
     * @Description
     * 	- 입고취소 데이터 클래스
    **/
    public class CancelGR {
        @AuraEnabled public String id {get;set;} // id
        @AuraEnabled public String gRDocument {get;set;} // 대리점 입고번호
        @AuraEnabled public String dNSDocument {get;set;} // DNS반품번호
        @AuraEnabled public String dNSId {get;set;} // DNS 반품 Id
        @AuraEnabled public String itemNumber {get;set;} // 항목
        @AuraEnabled public String pratNumber {get;set;} // 부품번호
        @AuraEnabled public String partName {get;set;}  // 부품명
        @AuraEnabled public String partId {get;set;}  // 부품 Id
        @AuraEnabled public String productSpec {get;set;} // 규격
        @AuraEnabled public Decimal firstGRQty {get;set;} // 최초입고수량 // InventoryNumber__c,InventoryItemNumber__c,Part__c
        @AuraEnabled public String lastImportDateTime {get;set;} // 입고일
        @AuraEnabled public Decimal cancelGRQty {get;set;} // 취소요청수량 
        
        //계산식
        @AuraEnabled public Decimal canceledlGRQty {get;set;} // 취소수량 // Type =H
        @AuraEnabled public Decimal cancelAvailableGRQty {get;set;} //취소가능수량 :  최초입고수량 - 취소수량
        
        
        // 딜러 재고
        @AuraEnabled public String location {get;set;} // 저장위치
        @AuraEnabled public String locationId {get;set;} // 저장위치
        @AuraEnabled public Decimal stockQty {get;set;} // 현재고
        public CancelGR() {
            

        }
        public CancelGR(DealerInventoryMovements__c inventoryM) {
            this.id = inventoryM.Id;
            this.gRDocument = inventoryM.InventoryNumber__c;
            this.dNSDocument  = '';
            this.itemNumber = inventoryM.InventoryItemNumber__c;
            this.pratNumber = inventoryM.Part__r.ProductCode;
            this.partName = inventoryM.Part__r.FM_MaterialDetails__c;
            this.productSpec = inventoryM.Part__r.ProductSpec__c;
            this.firstGRQty = inventoryM.Quantity__c;
            this.lastImportDateTime = inventoryM.CreatedDate.format('YYYY.MM.dd');
            this.partId = inventoryM.Part__c;
        }
        public CancelGR(DealerStock__c stock) {
            this.locationId = stock.DealerLocation__c;
            this.location = stock.DealerLocation__r.FM_Loc__c;
            this.stockQty = stock.CurrentStockQuantity__c;
        }
    }

    public class DN_CancelGRTableControllerException extends Exception {}
}