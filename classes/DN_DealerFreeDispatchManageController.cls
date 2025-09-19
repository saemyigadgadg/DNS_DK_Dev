/** 
 * @Class :  DN_DealerFreeDispatchManageController
 * 
 * @Test: DN_DealerFreeDispatchManageCon_TEST
 * @Author : Hyunwook Jin
 * @Date : 2025. 03. 26. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-26 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_DealerFreeDispatchManageController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 데이터 조회
    **/
    @AuraEnabled
    public static Map<String,Object> getDataList(Map<String,Object> whereCondition, PageReturn pageInfo){
        System.debug(whereCondition + ' ::: whereCondition');
        System.debug(pageInfo + ' ::: pageInfo');
        Map<String,Object> result = new Map<String,Object>();
        try {
            // List<DealerFreeDispatch>
            set<String> orderNumberIds = new set<String>();
            String query =' select Id,';
            query += ' OrderItem__r.Seq__c,FM_OrderNumber__c,';
            query += ' Status__c,toLabel(Status__c) statusDesc,';
            query += ' Dealer__r.CustomerCode__c,Dealer__r.Name,';
            query += ' FM_ApprovalDate__c,FM_Part__c,';
            query += ' OrderItem__r.Product__r.ProductSpec__c,';
            query += ' OrderItem__r.Product__r.FM_MaterialDetails__c,';
            query += ' FM_RequestQuantity__c,ShippingQuantity__c,';
            query += ' FM_Unit__c,FinalSettlementAmount__c,';
            query += ' CurrencyIsoCode,OrderItem__c,';
            query += ' ShippingType__c,toLabel(ShippingType__c) shipDesc,';
            query += ' DeliveryDateTime__c,';
            //query += ' OrderItem__r.TrackingNumber__c,';
            query += ' CreatedDate,CreatedBy.Name,Owner.Name, ';
            query += ' LastModifiedDate,LastModifiedBy.Name';
            query += ' from DealerFreeDispatch__c where Dealer__c != null AND OrderItem__c != null';
            // 오더
            String orderNumber = (String) whereCondition.get('OrderNumber');
            if(String.isNotBlank(orderNumber)) {
                query += ' AND FM_OrderNumber__c=\''+orderNumber+'\'';
            }
            //생성일자
            DateTime startDate = DateTime.now();
            DateTime endDate = DateTime.now();
            if(whereCondition.get('CreatedOnStart') !=null) {
                List<String> startSet = String.valueOf(whereCondition.get('CreatedOnStart')).split('-');
                startDate = DateTime.newInstanceGMT(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));   
                query += ' AND CreatedDate >=:startDate';
            }
            if(whereCondition.get('CreatedOnEnd') !=null) {
                List<String> endSet = String.valueOf(whereCondition.get('CreatedOnEnd')).split('-');
                endDate = DateTime.newInstanceGMT(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]),23,59,59);           
                query += ' AND CreatedDate <=:endDate';
            }
            // 상태값 
            String strStatus;
            if(whereCondition.get('Status') !=null) {
                strStatus = (String) whereCondition.get('Status');
            }
             
            // 삭제 여부
            Boolean isCheck = whereCondition.get('ReadDeleteHistory') != null ? (Boolean) whereCondition.get('ReadDeleteHistory') : false;
            if(isCheck) query += ' AND Delete__c = \'Y\' ';
            else query += ' AND Delete__c != \'Y\' ';

            if(String.isNotBlank(strStatus) && !'All'.equals(strStatus)){ 
                query += ' AND Status__c =:strStatus ';
            }
            
            
            // 부품번호
            String productCode = (String)whereCondition.get('productCode');
            if(String.isNotBlank(productCode)) {
                query += ' AND OrderItem__r.Product__c =\''+productCode+'\'';
            }
            Date approvalDateStart = Date.today();
            Date approvalDateEnd = Date.today();
            if(whereCondition.get('approvalDateStart') !=null) {
                List<String> startSet = String.valueOf(whereCondition.get('approvalDateStart')).split('-');
                approvalDateStart = Date.newInstance(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));
                query += ' AND FM_ApprovalDate__c >=:approvalDateStart';
            }
            if(whereCondition.get('approvalDateEnd') !=null) {
                List<String> endSet = String.valueOf(whereCondition.get('approvalDateEnd')).split('-');
                approvalDateEnd =  Date.newInstance(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]));
                query += ' AND FM_ApprovalDate__c <=:approvalDateEnd';
            }
            String queryOrder = ' ORDER BY FM_ApprovalDate__c desc, FM_OrderNumber__c asc , OrderItem__r.Seq__c asc ';
            
            List<DealerFreeDispatch__c> freeList = DataBase.query(query + queryOrder + ' LIMIT 2000 ');
            List<DealerFreeDispatch> returnList = new List<DealerFreeDispatch>();
            System.debug(query + ' LIMIT 2000 ');

            if(pageInfo == null) {
                pageInfo = new PageReturn();
                pageInfo.totalRecordSize = freeList.size();
            }
            setpageSetting(pageInfo);
            
            for(Integer i = pageInfo.startIdx; i < pageInfo.endIdx; i++) {
                
                System.debug('startIdx : ' +i);
                if(i < freeList.size()) {
                    DealerFreeDispatch__c freeDispatch = freeList[i];
                    orderNumberIds.add(freeDispatch.FM_OrderNumber__c);
                    returnList.add(new DealerFreeDispatch(freeDispatch));
                }
            }

            //orderNumber 기준으로 배송정보 조회
            IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();
            req.T_I_LIST2 = new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2>();
            for(String orders : orderNumberIds) {
                IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2 t_i_list2 = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2();
                t_i_list2.LOW = orders;
                req.T_I_LIST2.add(t_i_list2);
            }
            IF_ERP_Material instance = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = instance.IF_CSPLUS_007(req);
            Map<String,String> ifMap = new Map<String,String>();
            for(IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST toList : response.T_O_LIST) {
                ifMap.put(toList.AUFNR,toList.INVOICE);
            }
            for(DealerFreeDispatch freeDis : returnList) {
                System.debug(ifMap.get(freeDis.order) + ' Invoce');
                freeDis.invoice = ifMap.get(freeDis.order) !=null? ifMap.get(freeDis.order) : '';
            }
            System.debug(returnList.size());
            // returnList.sort();
            result.put('returnList', returnList);
            result.put('pageInfo', pageInfo);
            
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DealerFreeDispatchManageControllerException(e.getMessage());
        }
        return result;
    }

    /**
     * @Description
     * 	- 페이지 설정
    **/
    public static void setpageSetting(PageReturn returnPages) {
        
        // Stage Idx, Last Idx - 인덱스 설정
        Integer startIdx = 0;
        Integer endIdx = 0;
        //페이지 클릭한 경우 처리로직 - 같은 경우 뒤로가기 또는 현재 페이지 클릭
        if(returnPages.currentPage == returnPages.nextPage) {
            startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
            startIdx = (startIdx - returnPages.itemsPerPage); // + 1
            endIdx = (returnPages.nextPage*returnPages.itemsPerPage);    
        } else {
            returnPages.currentPage = returnPages.nextPage;
            startIdx = (returnPages.nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage);//(returnPages.currentPage * returnPages.itemsPerPage)+1;
            endIdx = (returnPages.nextPage*returnPages.itemsPerPage);       
        }
        returnPages.startIdx = startIdx;
        returnPages.endIdx = endIdx;
    }

    public class PageReturn {
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public Integer itemsPerPage { 
            get {
                if(itemsPerPage == null) itemsPerPage = 15;
                return itemsPerPage;
            }
            set; 
        } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { 
            get {
                if(currentPage == null) currentPage = 1;
                return currentPage;
            }
            set; 
        } // 현재 페이지
        @AuraEnabled public Integer nextPage {
            get {
                if(nextPage == null) nextPage = currentPage;
                return nextPage;
            }
            set;
        }// 다음 페이지
        @AuraEnabled public Integer pagesPerGroup {
            get {
                if(pagesPerGroup == null) pagesPerGroup = 1;
                return pagesPerGroup;
            }
            set;
        } // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx { // 시작인덱스
            get {
                if(startIdx == null) startIdx = 0;
                return startIdx;
            }
            set;
        } 
        @AuraEnabled public Integer endIdx {
            get {
                if(endIdx == null) endIdx = 0;
                return endIdx;
            }
            set;
        } // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        @AuraEnabled public String query {get;set;}
        public PageReturn() {}
    }

    /**
     * @Description
     * 	- Detail I/F 조회
    **/
    @AuraEnabled
    public static Map<String, Object> getDetailList(DealerFreeDispatch search){
        Map<String, Object> returnMap = new Map<String,Object>();
        System.debug(search);

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res ifRes = getDetailInfo(search);        
        System.debug(ifRes + ' ::: ifRes');
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_O_RETURN  returnMsg = ifRes.O_RETURN;
        List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_RESB> serviceList = ifRes.T_O_RESB;
        List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093> notificationList = ifRes.T_O_ZCRMS0093;
        List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCST0040> domesticList = ifRes.T_O_ZCST0040;
        List<DealerFreeDispatch> serviceOrder  = new List<DealerFreeDispatch>();
        List<DealerFreeDispatch> notification  = new List<DealerFreeDispatch>();
        List<DealerFreeDispatch> domesticClaim = new List<DealerFreeDispatch>();

        for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_RESB resb : serviceList) {
            DealerFreeDispatch ser = new DealerFreeDispatch(resb);
            serviceOrder.add(ser);
        }
        for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093 zcrms : notificationList) {
            DealerFreeDispatch noti = new DealerFreeDispatch(zcrms);
            notification.add(noti);
        }
        for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCST0040 zcst : domesticList) {
            DealerFreeDispatch claim = new DealerFreeDispatch(zcst);
            domesticClaim.add(claim);
        }
        returnMap.put('type' ,returnMsg.TYPE);
        returnMap.put('code' ,returnMsg.CODE);
        returnMap.put('msg'  ,returnMsg.MESSAGE);
        returnMap.put('serviceOrder' ,serviceOrder);
        returnMap.put('notification' ,notification);
        returnMap.put('domesticClaim',domesticClaim);

        return returnMap;
    }

    /**
     * @Description
     * 	- Detail 추가 상세정보 인터페이스
    **/
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res getDetailInfo(DealerFreeDispatch search){
        try {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req();
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req_I_DETAIL_INFO I_DETAIL = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Req_I_DETAIL_INFO();
            I_DETAIL.AUFNR     = search.order;
            I_DETAIL.MATNR     = search.productCode;
            I_DETAIL.BDMNG     = search.reqQty.toString();   
            I_DETAIL.MEINS     = search.uom; 
            I_DETAIL.DEALER_CD = search.dealerCode;
            I_DETAIL.POSNR     = search.item; //잠시 주석
            // I_DETAIL.DEDAT     = search.
            // I_DETAIL.DEZIT     = search.
            // I_DETAIL.DENAM     = search.
          
            req.I_DETAIL_INFO = I_DETAIL;
            req.I_HISTORY     = search.historyYN == 'Y' ? 'X':'';
            IF_ERP_DealerStock instance = new IF_ERP_DealerStock();

            return instance.IF_DEALERSTOCK_003(req);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DealerFreeDispatchManageControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- return : 반납
    **/
    @AuraEnabled
    public static Map<String, Object> addReturn(DealerFreeDispatch pat, String notiItemNumber, String domesticItemNumber){
        Map<String, Object> resultMap = new Map<String,Object>();
        try {
            String giType ='';
            System.debug(pat + ' ::: pat');
            if(pat.status == '1') {
                giType ='GIWaiting';
            } else {
                giType ='GICancel';
            }

            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res returnRes = createReturnIF(pat, notiItemNumber, domesticItemNumber);
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res_O_RETURN  returnMsg = returnRes.O_RETURN;
            System.debug('returnRes ::: ' + returnRes);

            if(returnMsg.TYPE == '' || returnMsg.TYPE == 'S') {
                // 반품 처리 => 반품완료 시 삭제여부 Y:삭제로 변경
                DealerFreeDispatch__c updateFree = new DealerFreeDispatch__c(
                    Id =pat.id,
                    Delete__c = 'Y'
                );
                update updateFree;
                // 서비스 오더 업데이트
                ProductRequest updateProdcutRequest = new ProductRequest(
                    Id = pat.orderId,
                    IsDealerPortalDelete__c = true
                );
                update updateProdcutRequest;
                // 제품정보
                Product2 prod = [select Id, ProductCode from Product2 where ProductCode =:pat.productCode];
                Map<String,Decimal> giMap = new Map<String,Decimal>();
                giMap.put(prod.Id, pat.reqQty);
                System.debug(giMap+ ' ::: giMap');
                //출고문서가 있는 경우 출고취소로 수량 업데이트
                List<DealerInventoryMovements__c> giList = getGIList(pat);
                System.debug(giList + ' ::: giList');
                System.debug(giList.size() + ' ::: giList.size()');
                if(giList.size() > 0) {
                    List<DealerInventoryMovements__c> insertList = new List<DealerInventoryMovements__c>();
                    RecordType recType = [select Id, Name, DeveloperName from RecordType where RecordType.DeveloperName ='GoodsIssue'];
                    //채번
                    SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
                    String grNumber = seqGenerator.generate(recType.DeveloperName);
                    
                    for(DealerInventoryMovements__c inven : giList) {
                        Decimal qty = giMap.get(inven.Part__c) !=null ? giMap.get(inven.Part__c) + inven.Quantity__c : inven.Quantity__c;
                        DealerInventoryMovements__c insertInven = new DealerInventoryMovements__c();
                        insertInven.RecordTypeId                        = recType.Id;
                        insertInven.Part__c                             = inven.Part__c;
                        insertInven.Type__c                             = 'W';
                        insertInven.SalesOrganization__c                = inven.SalesOrganization__c;
                        insertInven.DistributionChannel__c              = inven.DistributionChannel__c;                
                        insertInven.Division__c                         = inven.Division__c;    
                        insertInven.Dealer__c                           = inven.Dealer__c;    
                        insertInven.Location__c                         = inven.Location__c;                                                            
                        insertInven.InventoryItemNumber__c              = inven.InventoryItemNumber__c;                                            
                        insertInven.InventoryNumber__c                  = grNumber;                                        
                        insertInven.InventoryChange__c                  = 'S';                                        
                        insertInven.Quantity__c                         = inven.Quantity__c;                                
                        insertInven.Comment__c                          = '신품반납';                                
                        insertInven.CustomerPrice__c                    = inven.CustomerPrice__c;                                        
                        insertInven.DiscountPrice__c                    = inven.DiscountPrice__c;                                        
                        insertInven.DiscountAmount__c                   = inven.DiscountAmount__c;                                        
                        insertInven.ServiceOrderItem__c                 = inven.ServiceOrderItem__c;
                        insertInven.GoodsIssue__c                       = inven.Id;
                        insertList.add(insertInven);
                        //giMap.put(inven.Part__c,inven.Quantity__c);
                    }
                    System.debug(insertList + ' :::insertList');
                    insert insertList;
                    seqGenerator.updateNextSequenceInfo();
                }
                System.debug(giType+ '::giType');
                System.debug(pat.dealerCode + ' ::: pat.dealerCode');
                // DN_DealerStockManager.getAvailable(giMap,giType,pat.dealerCode);

                Map<String, DealerStock__c> dealerStockMap = DN_DealerStockManager.getAvailableStockMapMutipleForCode(new Set<String>{pat.dealerCode}, currentUser.getSalesOranization(), currentUser.getDistributionChannel(), currentUser.getDivision(), new Set<String>{pat.productCode});
                String key = pat.productCode + '_'+ pat.dealerCode;
                if(dealerStockMap.containsKey(key)) {
                    DealerStock__c stock = dealerStockMap.get(key);
                    // Decimal availableQty = stock.AvailableQuantity__c;
                    Decimal currentStockQty = stock.CurrentStockQuantity__c;
                    Decimal warrantyRequiredQuantity = dealerStockMap.get(key).WarrantyRequiredQuantity__c;

                    switch on giType {
                        when 'GICancel' {
                            stock.LastImportDateTime__c = DateTime.now();
                            stock.CurrentStockQuantity__c = (giMap.get(prod.Id) + currentStockQty);
                        }
                        when 'GIWaiting' {
                            //무상부품 청구 반납 처리시 
                            stock.WarrantyRequiredQuantity__c = warrantyRequiredQuantity - giMap.get(prod.Id);
                        }
                    }
                    
                    stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                    upsert dealerStockMap.values() ExternalKey__c;
                }

                resultMap.put('msg','S');
                resultMap.put('returnOrder',pat);
                
            } else {
                resultMap.put('msg','F');
            }   
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DealerFreeDispatchManageControllerException(e.getMessage());
        }

        return resultMap;
    }

    /**
     * @Description
     * 	- CRM 레코드 정상적으로 분할 하는지 체크
    **/
    @AuraEnabled
    public static Map<String, Object> partitionCheck(DealerFreeDispatch pat, Decimal qty, Decimal copyQty){
        Map<String, Object> result = new Map<String, Object> {
            'isPassCrmDml'=> true
        };

        Savepoint sp = Database.setSavepoint(); 
        try {
            DealerFreeDispatch__c currentFree = [
                select 
                OrderItem__c, SourceSystem__c,
                Status__c, Dealer__c,
                DeliveryDateTime__c, ShippingType__c,
                FinalSettlementAmount__c, 
                FM_Unit__c, 
                ShippingQuantity__c, ApprovalDate__c,  IsDemandCapture__c,
                FM_RequestQuantity__c,
                CustomerPrice__c
                from DealerFreeDispatch__c where Id=:pat.Id FOR UPDATE
            ];
            System.debug(currentFree + ' ::: currentFree');
            // 서비스 오더 수량 업데이트
            SchemaInfo claimPartSchema = new SchemaInfo('ProductRequest');
            Set<String> exculdeFields = new Set<String>{'ExternalKey__c'};
            String clainmQuery = ' SELECT ' + claimPartSchema.getAllFieldsForQueryExcept(exculdeFields) + ' FROM ' + claimPartSchema.getTypeToString() + ' WHERE  Id = \''+currentFree.OrderItem__c +'\' ';
            ProductRequest prod = Database.query(clainmQuery);

            ProductRequest copy = prod.clone(false,true,true,false);
            copy.Quantity__c = copyQty;
            copy.DeliveryCompleted__c = copyQty;
            copy.IsDealerPortalPartition__c = true;
            System.debug(' ::: copy : ' + JSON.serialize(copy));
            insert copy;
            // 출고문서 분할처리
            List<DealerInventoryMovements__c> giList = getGIList(pat);
            Decimal giDOcPrice = 0;
            Decimal copyDOcPrice = 0;
            if(giList.size() > 0) {
                DealerInventoryMovements__c giDOc = giList[0];
                System.debug(giDOc  +' ::giDOc');
                giDOc.Quantity__c = qty;
                giDOc.DiscountAmount__c = (giDOc.CustomerPrice__c*giDOc.Quantity__c * 1.2);
                giDOc.DiscountAmount__c = roundAndFloorToTen(giDOc.DiscountAmount__c);
                giDOcPrice = giDOc.CustomerPrice__c;
                update giDOc;
                DealerInventoryMovements__c insertGI = giDOc.clone(false,true,true,false);
                
                System.debug(insertGI + ' :: insertGI');
                insertGI.Quantity__c = copyQty;
                insertGI.DiscountAmount__c =  (insertGI.CustomerPrice__c*insertGI.Quantity__c * 1.2);
                insertGI.DiscountAmount__c = roundAndFloorToTen(insertGI.DiscountAmount__c);
                insertGI.ServiceOrderItem__c = copy.Id;
                copyDOcPrice = insertGI.CustomerPrice__c;
                insert insertGI;
                
            }

            DealerFreeDispatch__c partitionFree = new DealerFreeDispatch__c();
            partitionFree.OrderItem__c                          = copy.Id;
            partitionFree.SourceSystem__c                       = currentFree.SourceSystem__c;                                     
            partitionFree.Status__c                             = currentFree.Status__c;                               
            partitionFree.Dealer__c                             = currentFree.Dealer__c;                               
            partitionFree.DeliveryDateTime__c                   = currentFree.DeliveryDateTime__c;                                     
            partitionFree.ShippingType__c                       = currentFree.ShippingType__c;                                 
            if(currentFree.Status__c == '2' || currentFree.Status__c=='4') {
                partitionFree.ShippingQuantity__c               = copyQty;
            }
            partitionFree.ApprovalDate__c                       = currentFree.ApprovalDate__c;                                 
            partitionFree.IsDemandCapture__c                    = currentFree.IsDemandCapture__c;  
            //출고완료일때 ShippingQty Udpate
            if(currentFree.Status__c =='2' || currentFree.Status__c=='4') {
                currentFree.ShippingQuantity__c                =  qty;
            }
            if(currentFree.Status__c=='4') {
                partitionFree.FinalSettlementAmount__c  = (copyDOcPrice * partitionFree.ShippingQuantity__c * 1.2);
                partitionFree.FinalSettlementAmount__c  = roundAndFloorToTen(partitionFree.FinalSettlementAmount__c);
                currentFree.FinalSettlementAmount__c  = (giDOcPrice * currentFree.ShippingQuantity__c * 1.2);
                currentFree.FinalSettlementAmount__c  = roundAndFloorToTen(currentFree.FinalSettlementAmount__c);
            } else {
                partitionFree.FinalSettlementAmount__c              = currentFree.FinalSettlementAmount__c;                                                
            } 
            update currentFree;
            insert partitionFree;

        }catch (Exception e) {
            result.put('isPassCrmDml', false);
            System.debug(e.getStackTraceString() + ' ::: statck');
            result.put('errorMsg', e.getMessage());
        }
        Database.rollback(sp);
        return result;
    }

    /**
     * @Description
     * 	- I/F 추가 -> I/F 성공 후 업데이트로 로직 변경 
    **/
    @AuraEnabled
    public static Map<String, Object> partition(DealerFreeDispatch pat, Decimal qty, Decimal copyQty){
        Map<String, Object> resultMap = new Map<String,Object>();
        System.debug(pat + ' :::: pat');
        try {//OrderItem__c, SourceSystem__c, Status__c, Dealer__c, DeliveryDateTime__c, ShippingType__c, FinalSettlementAmount__c, Unit__c, ShippingQuantity__c, ApprovalDate__c,  IsDemandCapture__c
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res partitionRes = createPartitionIF(pat,qty,copyQty);
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_O_RETURN  returnMsg = partitionRes.O_RETURN;
            String newSeq ='';
            System.debug('partitionRes ::: ' + partitionRes);

            if(returnMsg.TYPE == '' || returnMsg.TYPE == 'S') {
                 // 무상부품관리 
                 Map<String, DealerFreeDispatch> mainFree = new Map<String,DealerFreeDispatch>();

                for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res_T_MAIN main : partitionRes.T_MAIN) {
                    if(pat.item != main.POSNR){
                        newSeq = main.POSNR;
                    }
                }

                System.debug('newSeq ::: ' + newSeq);
                DealerFreeDispatch__c currentFree = [
                    select 
                    OrderItem__c, SourceSystem__c,
                    Status__c, Dealer__c,
                    DeliveryDateTime__c, ShippingType__c,
                    FinalSettlementAmount__c, 
                    FM_Unit__c, 
                    ShippingQuantity__c, ApprovalDate__c,  IsDemandCapture__c,
                    FM_RequestQuantity__c,
                    CustomerPrice__c
                    from DealerFreeDispatch__c where Id=:pat.Id FOR UPDATE
                ];
                System.debug(currentFree + ' ::: currentFree');
                // 서비스 오더 수량 업데이트
                SchemaInfo claimPartSchema = new SchemaInfo('ProductRequest');
                Set<String> exculdeFields = new Set<String>{'ExternalKey__c'};
                String clainmQuery = ' SELECT ' + claimPartSchema.getAllFieldsForQueryExcept(exculdeFields) + ' FROM ' + claimPartSchema.getTypeToString() + ' WHERE  Id = \''+currentFree.OrderItem__c +'\' ';
                ProductRequest prod = Database.query(clainmQuery);
                 
                prod.Quantity__c = qty;
                prod.DeliveryCompleted__c = qty;
                System.debug( ' ::: prod : ' +  JSON.serialize(prod));
                update prod;

                //서비스 오더 분할 처리
                ProductRequest copy = prod.clone(false,true,true,false);
                copy.Quantity__c = copyQty;
                copy.DeliveryCompleted__c = copyQty;
                copy.Seq__c = newSeq;//String.valueOf(newSeq);
                copy.IsDealerPortalPartition__c = true;
                System.debug(' ::: copy : ' + JSON.serialize(copy));
                insert copy;
                // 출고문서 분할처리
                List<DealerInventoryMovements__c> giList = getGIList(pat);
                Decimal giDOcPrice = 0;
                Decimal copyDOcPrice = 0;
                if(giList.size() > 0) {
                    DealerInventoryMovements__c giDOc = giList[0];
                    System.debug(giDOc  +' ::giDOc');
                    giDOc.Quantity__c = qty;
                    giDOc.DiscountAmount__c = (giDOc.CustomerPrice__c*giDOc.Quantity__c * 1.2);
                    giDOc.DiscountAmount__c = roundAndFloorToTen(giDOc.DiscountAmount__c);
                    giDOcPrice = giDOc.CustomerPrice__c;
                    update giDOc;
                    DealerInventoryMovements__c insertGI = giDOc.clone(false,true,true,false);
                    
                    System.debug(insertGI + ' :: insertGI');
                    insertGI.Quantity__c = copyQty;
                    insertGI.DiscountAmount__c =  (insertGI.CustomerPrice__c*insertGI.Quantity__c * 1.2);
                    insertGI.DiscountAmount__c = roundAndFloorToTen(insertGI.DiscountAmount__c);
                    insertGI.ServiceOrderItem__c = copy.Id;
                    copyDOcPrice = insertGI.CustomerPrice__c;
                    insert insertGI;
                }

                DealerFreeDispatch__c partitionFree = new DealerFreeDispatch__c();
                partitionFree.OrderItem__c                          = copy.Id;
                partitionFree.SourceSystem__c                       = currentFree.SourceSystem__c;                                     
                partitionFree.Status__c                             = currentFree.Status__c;                               
                partitionFree.Dealer__c                             = currentFree.Dealer__c;                               
                partitionFree.DeliveryDateTime__c                   = currentFree.DeliveryDateTime__c;                                     
                partitionFree.ShippingType__c                       = currentFree.ShippingType__c;                                 
                if(currentFree.Status__c == '2' || currentFree.Status__c=='4') {
                    partitionFree.ShippingQuantity__c               = copyQty;
                }
                partitionFree.ApprovalDate__c                       = currentFree.ApprovalDate__c;                                 
                partitionFree.IsDemandCapture__c                    = currentFree.IsDemandCapture__c;  
                //출고완료일때 ShippingQty Udpate
                if(currentFree.Status__c =='2' || currentFree.Status__c=='4') {
                    currentFree.ShippingQuantity__c                =  qty;
                    
                }
                if(currentFree.Status__c=='4') {
                    partitionFree.FinalSettlementAmount__c  = (copyDOcPrice * partitionFree.ShippingQuantity__c * 1.2);
                    partitionFree.FinalSettlementAmount__c  = roundAndFloorToTen(partitionFree.FinalSettlementAmount__c);
                    currentFree.FinalSettlementAmount__c  = (giDOcPrice * currentFree.ShippingQuantity__c * 1.2);
                    currentFree.FinalSettlementAmount__c  = roundAndFloorToTen(currentFree.FinalSettlementAmount__c);
                } else {
                    partitionFree.FinalSettlementAmount__c              = currentFree.FinalSettlementAmount__c;                                                
                } 
                update currentFree;
                insert partitionFree;
                
                resultMap.put('msg','S');
                resultMap.put('returnOrder',pat);
            } else {
                resultMap.put('msg','F');
                resultMap.put('ifErrorMsg', returnMsg.MESSAGE);
            }   
           
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DealerFreeDispatchManageControllerException(e.getMessage());
        }
        return resultMap;
    }

    /**
     * @Description
     * 	- 출고 취소문서 생성
    **/
    public static Boolean insertGIList(List<DealerInventoryMovements__c> giList) {
        if(giList.size() > 0) {
            insert giList;
            return true;
        }
        return false;
    }

    /**
     * @Description
     * 	- Return I/F
    **/
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Res createReturnIF(DealerFreeDispatch pat, String notiItemNumber, String domesticItemNumber){
        try {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_005_Req();
            req.I_AUFNR = pat.order;
            req.I_POSNR = pat.item;
            req.I_QMSEQ = notiItemNumber;
            if(String.isNotBlank(domesticItemNumber)) {
                req.I_DOMESTIC = 'X';
                req.I_ITEM_NUMBER = domesticItemNumber;
            }
            
            IF_ERP_DealerStock instance = new IF_ERP_DealerStock();

            return instance.IF_DEALERSTOCK_005(req);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DealerFreeDispatchManageControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Partition Creation I/F
    **/
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Res createPartitionIF(DealerFreeDispatch deal, Decimal qty, Decimal copyQty){
        try {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_004_Req();
            req.I_AUFNR = deal.order;
            req.I_POSNR = deal.item;
            req.I_QTY1  = qty.toString();
            req.I_QTY2  = copyQty.toString();
            
            IF_ERP_DealerStock instance = new IF_ERP_DealerStock();

            return instance.IF_DEALERSTOCK_004(req);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DealerFreeDispatchManageControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 출고문서 확인
    **/
    public static List<DealerInventoryMovements__c> getGIList(DealerFreeDispatch dealerFreeDispatch) {
        List<DealerInventoryMovements__c> giList = new List<DealerInventoryMovements__c>();
        giList = [
            select Id, OwnerId, IsDeleted, Name, 
            CurrencyIsoCode, RecordTypeId, CreatedDate, 
            CreatedById, LastModifiedDate, LastModifiedById, 
            SystemModstamp, LastActivityDate, InventoryNumber__c, 
            InventoryItemNumber__c, SalesOrganization__c, 
            DistributionChannel__c, Division__c, Type__c, 
            Dealer__c, GoodsIssue__c, InventoryChange__c, 
            Part__c, Quantity__c, CustomerPrice__c, 
            DiscountPrice__c, DiscountAmount__c, Currency__c, 
            FM_PurchaseOrder__c, DealerPurchaseOrderItem__c, 
            FM_DealerPurchaseOrder__c, DealerOrderItem__c, 
            ServiceOrderItem__c, FM_ServiceOrder__c, 
            SourceSystem__c, Location__c, PurchaseOrderItem__c, 
            Reason__c, Comment__c, FM_CreatedDate__c, 
            GoodsReceiptNumber__c
            from DealerInventoryMovements__c 
            where ServiceOrderItem__c=:dealerFreeDispatch.orderId
            AND Part__r.ProductCode=:dealerFreeDispatch.productCode
            ANd Dealer__r.CustomerCode__c =:dealerFreeDispatch.dealerCode
        ];
        return giList;
    }

    /**
     * @Description
     * 	- 일의 자리 절삭에서 반올림으로 변경
    **/
    @TestVisible
    private static Decimal roundAndFloorToTen(Decimal customerPrice) {
        if(customerPrice == null) {
            customerPrice = 0;
            return customerPrice;
        }
        //일의자리에서 반올림
        customerPrice = (customerPrice/10).setScale(0, RoundingMode.HALF_UP);
        customerPrice = customerPrice *10;
        return customerPrice;
    }

    /**
     * @Description
     * 	- DealerFreeDispatch 데이터 클래스
    **/
    public class DealerFreeDispatch implements Comparable{
        @AuraEnabled public Boolean  isSelected     {get;set;}
        @AuraEnabled public String   id             {get;set;} //recordId
        @AuraEnabled public String   order          {get;set;} //주문번호
        @AuraEnabled public String   orderId        {get;set;} //주문번호
        @AuraEnabled public String   item           {get;set;} //아이템번호
        @AuraEnabled public String   status         {get;set;} //상태코드
        @AuraEnabled public String   statDesc       {get;set;} //상태라벨
        @AuraEnabled public String   dealerCode     {get;set;} //대리점 코드
        @AuraEnabled public String   dealerName     {get;set;} //대리점명
        @AuraEnabled public Date     notifDate      {get;set;} //승인일자
        @AuraEnabled public String   productCode    {get;set;} //품번
        @AuraEnabled public String   productSpec    {get;set;} //제품 spec
        @AuraEnabled public Decimal  reqQty         {get;set;} //요청수량
        @AuraEnabled public Decimal  giQTY          {get;set;} //출고수량
        @AuraEnabled public String   uom            {get;set;} // UOM
        @AuraEnabled public Decimal  amount         {get;set;} // 금액
        @AuraEnabled public String   currencyCode   {get;set;} // Currency
        @AuraEnabled public String   ShipType       {get;set;} // Ship.Typ.(배송타입코드)
        @AuraEnabled public String   ShipTypeDesc   {get;set;} // 배송타입 라벨명
        @AuraEnabled public DateTime plannedGiDate  {get;set;} // 배송예정날짜
        @AuraEnabled public String   invoice        {get;set;} // 배송상태 //OrderItem__r.TrackingNumber__c
        @AuraEnabled public DateTime createdOn      {get;set;} // Created Date
        @AuraEnabled public String   createdBy      {get;set;} // CreatedTime
        @AuraEnabled public DateTime changedOn      {get;set;} // LastModiFy
        @AuraEnabled public String   changedBy      {get;set;} // LastModiFy

        @AuraEnabled public String   historyYN      {get;set;} // delete history 여부
        @AuraEnabled public String   reservation    {get;set;}       
        @AuraEnabled public String   reserveItem    {get;set;}       
        @AuraEnabled public String   plant          {get;set;}       
        @AuraEnabled public String   itemCategory   {get;set;}    
        @AuraEnabled public Decimal  pQty           {get;set;}   
        @AuraEnabled public String   notification   {get;set;}       
        @AuraEnabled public String   nItem          {get;set;}       
        @AuraEnabled public String   supply         {get;set;}       
        @AuraEnabled public String   returnYN       {get;set;}           
        @AuraEnabled public String   returnType     {get;set;}
        
        public DealerFreeDispatch() {}
        public DealerFreeDispatch(DealerFreeDispatch__c free) {
            this.id               = free.Id;
            this.order            = free.FM_OrderNumber__c; 
            this.orderId          = free.OrderItem__c;
            this.item             = free.OrderItem__r.Seq__c;        
            this.status           = free.Status__c;
            this.statDesc         = (String) free.get('statusDesc');
            this.dealerCode       = free.Dealer__r.CustomerCode__c;            
            this.dealerName       = free.Dealer__r.Name;            
            this.notifDate        = free.FM_ApprovalDate__c;            
            this.productCode      = free.FM_Part__c;                
            this.productSpec      = free.OrderItem__r.Product__r.FM_MaterialDetails__c;
            this.reqQty           = free.FM_RequestQuantity__c;        
            this.giQTY            = free.ShippingQuantity__c;        
            this.uom              = free.FM_Unit__c;        
            this.amount           = free.FinalSettlementAmount__c;      
            this.currencyCode     = free.CurrencyIsoCode;                
            this.ShipType         = free.ShippingType__c;            
            this.ShipTypeDesc     = (String) free.get('shipDesc');                
            this.plannedGiDate    = free.DeliveryDateTime__c;
            this.createdOn        = free.CreatedDate;
            this.createdBy        = free.Owner.Name;
            this.changedOn        = free.LastModifiedDate;
            this.changedBy        = free.LastModifiedBy.Name;            
        }
       
        public DealerFreeDispatch (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_RESB resb) {
            this.order          = removeZeros(resb.AUFNR);
            this.item           = resb.POSNR;
            this.reservation    = resb.RSNUM;
            this.reserveItem    = removeZeros(resb.RSPOS);
            this.productCode    = resb.MATNR;
            this.productSpec    = resb.MAKTX;
            this.plant          = resb.WERKS;
            this.itemCategory   = resb.POSTP;
            this.reqQty         = Decimal.valueOf(resb.BDMNG);
            this.uom            = resb.MEINS;
        }
        public DealerFreeDispatch (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093 zcrms) {
            this.notification = removeZeros(zcrms.QMNUM);
            this.item         = zcrms.QMSEQ;
            this.productCode  = zcrms.MATNR;
            this.productSpec  = zcrms.MAKTX;
            this.reqQty       = Decimal.valueOf(zcrms.MENGE); //확인
            this.uom          = zcrms.MEINS;
            this.supply       = zcrms.ZSUPPLY;
            this.dealerCode   = zcrms.LIFNR;
            this.dealerName   = zcrms.NAME1;
            this.returnYN     = zcrms.RETURN_YN;

        }
        public DealerFreeDispatch (IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_003_Res_T_O_ZCST0040 zcst) {
            this.order          = removeZeros(zcst.AUFNR);
            this.item           = zcst.ITEM_NUMBER; //확인
            this.productCode    = zcst.MATNR;
            this.productSpec    = zcst.MAKTX;
            this.giQTY          = Decimal.valueOf(zcst.PGMNG); 
            this.reqQty         = Decimal.valueOf(zcst.MENGE);
            this.uom            = zcst.MEINS;
            this.returnYN       = zcst.RETURN_YN;
            this.returnType     = zcst.RETURN_TYPE;
            this.itemCategory   = zcst.ITEM_CAT;
          
        }
       
        public Integer compareTo(Object cmparTo) {
            DealerFreeDispatch cmtp = (DealerFreeDispatch)cmparTo;
            
            if (order < cmtp.order) return -1;
            if (order > cmtp.order) return 1;

            return item.compareTo(cmtp.item);
        }
    }
    
    /**
     * @Description
     * 	- 0 제거
    **/
    private static String removeZeros(String input) {
        if (String.isBlank(input)) {
            return input;  
        }
        return input.replaceFirst('^0+', '');
    }

    public class DN_DealerFreeDispatchManageControllerException extends Exception {}
}