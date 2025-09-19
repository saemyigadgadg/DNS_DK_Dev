/** 
 * @Class :  DN_WarrantyPartsManagement
 * 
 * @Test: DN_WarrantyPartsManagement_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 03. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-03 | Hyunwook Jin   | 최초작성 
 */ 
public without sharing class DN_WarrantyPartsManagement {
    public DN_WarrantyPartsManagement() {}

    /*
    * @ Description : 현재 유저 정보
    */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /*******************************************  무상 부품 관리 화면 ********************************************************/
    /*
    * @ Method : init
    * @ Description : 무상 부품 관리 목록 조회
    */
    @AuraEnabled
    public static Map<String,Object> init(){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            SchemaInfo warrantySchema = new SchemaInfo('DealerFreeDispatch__c');
            
            List<Map<String,String>> dealerOptionList = new List<Map<String,String>>();
            for(DealerCustomer__c dealerCustomer : [SELECT Id, Name, CustomerCode__c, SourceAccount__c, SourceAccount__r.Name, SourceAccount__r.CustomerCode__c, IsDealer__c FROM DealerCustomer__c where SourceAccount__c != null]) {
                dealerOptionList.add(
                    new Map<String,String>{
                        'label'=>dealerCustomer.SourceAccount__r.Name,
                        'value'=>dealerCustomer.SourceAccount__c
                    }
                );
            }
            List<Map<String,Object>> statusOptionList = new List<Map<String,Object>>();
            for(Map<String,Object> statusOption : warrantySchema.getPicklistValuesForOptions('Status__c', false)) {
                String value = String.valueOf(statusOption.get('value'));
                switch on value {
                    when '1' {
                        statusOption.put('label', '진행');
                        statusOptionList.add(statusOption);        
                    }
                    when '3' {
                        statusOption.put('label', '취소');
                        statusOptionList.add(statusOption);
                    }
                }
            }

            result.put('shippingOptionList', warrantySchema.getPicklistValuesForOptions('ShippingType__c', false));
            result.put('statusOptionList' , statusOptionList);
            result.put('dealerOptionList', dealerOptionList);
            result.put('isAdmin', currentUser.getIsAdmin());
            result.put('dealerGradeRateMap', currentUser.getDealerGradeRateAll());

        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug(e.getStackTraceString());
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : searchWarrnatyItems
    * @ Description : 무상 부품 아이템 목록 조회
    */
    @AuraEnabled
    public static Map<String,Object> searchWarrnatyItems(String status,
                                                              Date approvalDateStart, 
                                                              Date approvalDateEnd,
                                                              DN_DealerPortalDisplayController.PageReturn page,
                                                              Integer nextPage
    ){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();

            String querySelect = ' SELECT ';
            String queryFields ='     Id,  '
                            + ' OrderItem__c, '
                            + ' OrderItem__r.WorkOrder.Worker__r.Name,  '           //
                            + ' OrderItem__r.WorkOrder.Worker__r.PhoneNumber__c,  '//서비스기사 서비스 오더 Phone
                            + ' OrderItem__r.WorkOrder.ServiceTerritory.Name, '
                            + ' OrderItem__r.WorkOrder.ServiceTerritory.ServiceWorkCenter__r.FM_Address__c, '
                            + ' OrderItem__r.WorkOrder.ServiceTerritory.ServiceWorkCenter__r.TransportationZoneL__r.Name, '
                            + ' OrderItem__r.WorkOrderId, '
                            + ' OrderItem__r.FM_DaysElapsed__c, '
                            + ' Status__c, '
                            + ' toLabel(Status__c) statusLabel, '
                            + ' Dealer__c, '
                            + ' Dealer__r.Name, '
                            + ' Dealer__r.DealerGrade__c, '
                            + ' Dealer__r.DealerGrade_Parts__c, '
                            + ' Dealer__r.TransportationZoneL__r.Name, ' // 대리점 x
                            + ' DeliveryDateTime__c, '
                            + ' ShippingType__c, '
                            + ' toLabel(ShippingType__c) shippingTypeLabel, '
                            + ' ShippingQuantity__c, '
                            + ' FM_RequestQuantity__c,  '
                            + ' OrderItem__r.Product__c, '
                            + ' OrderItem__r.Product__r.ProductCode, '
                            + ' OrderItem__r.Product__r.FM_MaterialDetails__c, '
                            + ' FM_OrderItemNumber__c, '
                            + ' FM_OrderNumber__c, '
                            + ' FM_Unit__c, '
                            + ' FM_ApprovalDate__c, '
                            + ' ConfirmDateTime__c, ' //정산대상인 경우 - 확정일
                            +'  OrderItem__r.WorkOrder.Case.Asset.MachineName__c,      '//기종
                            +'  OrderItem__r.WorkOrder.Case.Asset.Name,                '//장비번호
                            +'  OrderItem__r.WorkOrder.Case.Account.Phone,             '//전화
                            +'  OrderItem__r.WorkOrder.Case.Account.Mobile__c,         '//핸드폰
                            +'  OrderItem__r.WorkOrder.Case.Account.FM_Address__c,     '//고객주소
                            +'  OrderItem__r.WorkOrder.Case.ReceptionDetails__c,        '//요청내용
                            +'  OrderItem__r.WorkOrder.ConfirmedDate__c, ' // 확정일	서비스 오더 확정일
                            +'  OrderItem__r.WorkOrder.Account.Name, '// 고객명	서비스 오더의 고객명
                            +'  OrderItem__r.WorkOrder.Account.FM_Address__c, '
                            +'  OrderItem__r.WorkOrder.Account.Phone, ' 
                            // +'  OrderItem__r.WorkOrder.Account.TransportationZoneL__r.Name, ' //화물영업소 
                            +'  OrderItem__r.ShipTo__c '; //ShipTo
                                           
            String queryFrom = ' FROM  DealerFreeDispatch__c '
                             +' WHERE Id != null And Status__c IN (\'1\', \'3\') AND Delete__c != \'Y\' ';

            String additionalWhereClause = '';
            String queryOrderBy = ' ORDER BY FM_ApprovalDate__c desc';
            
            if(approvalDateStart != null && approvalDateEnd != null) additionalWhereClause += ' AND ( FM_ApprovalDate__c >= :approvalDateStart AND FM_ApprovalDate__c <= :approvalDateEnd ) ';
            else if(approvalDateStart != null && approvalDateEnd == null) additionalWhereClause += ' AND FM_ApprovalDate__c >= :approvalDateStart ';
            else if(approvalDateStart == null && approvalDateEnd != null) additionalWhereClause += ' AND FM_ApprovalDate__c <= :approvalDateEnd ';

            if(String.isNotBlank(status) && !'All'.equals(status)) additionalWhereClause += ' AND Status__c = :status ';

            Boolean isAdmin = currentUser.getIsAdmin();
            if(!isAdmin) additionalWhereClause += ' AND Dealer__c = \'' + agencyId + '\'';


            Set<String> partIdList = new Set<String>();
            Set<String> shipToWorkCenterIdList = new Set<String>();
            List<DealerFreeDispatch> warrantyList = new List<DealerFreeDispatch>();
            for(DealerFreeDispatch__c warrnty : Database.query(querySelect + queryFields + queryFrom + additionalWhereClause + queryOrderBy)) {
                if(String.isNotBlank(warrnty.OrderItem__r.Product__c))partIdList.add(warrnty.OrderItem__r.Product__c);
                if(warrnty.OrderItem__r.ShipTo__c != null) shipToWorkCenterIdList.add(warrnty.OrderItem__r.ShipTo__c);
                
                warrantyList.add(new DealerFreeDispatch(warrnty));
            }

            Map<Id,ServiceTerritory> shipToWorkCenterMap = new Map<Id,ServiceTerritory>([
                SELECT Id, 
                       ServiceWorkCenter__r.Name, 
                       ServiceWorkCenter__r.Phone, 
                       ServiceWorkCenter__r.ShippingStreet, 
                       ServiceWorkCenter__r.ShippingCity, 
                       ServiceWorkCenter__r.ShippingState, 
                       ServiceWorkCenter__r.DetailAddress__c,
                       ServiceWorkCenter__r.FM_Address__c,
                       ServiceWorkCenter__r.transportationzonel__r.Name
                FROM ServiceTerritory where Classify__c = 'W/C' and Id IN :shipToWorkCenterIdList
            ]);
            for (DealerFreeDispatch dfd : warrantyList) {
                Id shipToId = dfd.shipToId;
                if (shipToWorkCenterMap.containsKey(shipToId)) {
                    ServiceTerritory st = shipToWorkCenterMap.get(shipToId);

                    // 예: WorkCenter 관련 데이터 세팅
                    if(dfd.shippingType == '2') {
                        dfd.shipTo = st.ServiceWorkCenter__r.Name;
                        dfd.shipToAddress = st.ServiceWorkCenter__r.transportationzonel__r.Name;
                    } else {
                        dfd.shipTo = st.ServiceWorkCenter__r.Name;
                        dfd.shipToAddress = st.ServiceWorkCenter__r.FM_Address__c;
                    }
                }
            }
            //공급품목의 재고 변환
            if(partIdList.size() > 0) {
                Map<String, Map<String, DealerStock__c>> dealerStockMap = DN_DealerStockManager.getAvailableStockMapMutiple(null, salesOranization, distributionChannel, division, partIdList);
                for(DealerFreeDispatch warranty : warrantyList) {
                    if(dealerStockMap.containsKey(warranty.dealer)) {
                        Map<String, DealerStock__c> stockMap = dealerStockMap.get(warranty.dealer);
                        if(stockMap.containsKey(warranty.part)) {
                            DealerStock__c stock = stockMap.get(warranty.part);
                            warranty.locName = stock.DealerLocation__r.FM_Loc__c;
                            warranty.loc = stock.DealerLocation__c; 
                            
                            switch on warranty.status {
                                when  '1'{ //출고대기
                                    //( 가용재고 ) 상태가 출고대기일 경우 가용재고에 요청 수량만큼 더해준다. (요청 수량이 예약 수량으로 빠져 있으므로)
                                    //Service Order 에서 무상불출시 예약재고 업데이트 됨
                                    warranty.avaiableQuantity = stock.AvailableQuantity__c + warranty.requestQuantity;
                                }
                                when else {
                                    warranty.avaiableQuantity = stock.AvailableQuantity__c;        
                                }
                            }
                        }
                    }

                    if(warranty.shipToId != null) {
                        try {
                            //Id 외에 값도 들어감
                            Id serviceTerrorityId = Id.valueOf(warranty.shipToId);
                        } catch (Exception e) {
                            System.debug(e.getMessage());
                        }
                    }

                    
                }
            }

            result.put('warrantyList', warrantyList);
            
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : completeGoodsIssue
    * @ Description : 출고 완료
    */
    @AuraEnabled
    public static Map<String,Object> completeGoodsIssue(List<DealerFreeDispatch> requestGoodsIssueList, Map<String, Decimal> dealerGradeRateAllMap){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Map<String, Decimal> priceMap = new Map<String, Decimal>();
        Map<String, Map<String, Decimal>> priceAllMap = new Map<String, Map<String, Decimal>>();
        if(dealerGradeRateAllMap == null) dealerGradeRateAllMap = new Map<String, Decimal>();
        String salesOranization = currentUser.getSalesOranization();
        String distributionChannel = currentUser.getDistributionChannel();
        String division = currentUser.getDivision();
        Set<String> partIdList = new Set<String>();
        Set<String> agencyIdList = new Set<String>();
        Set<String> warrantyIds = new Set<String>();

        result.put('status', resultStatus);
        try {
            //
            Set<String> partCodeSet = new Set<String>();
            for(DealerFreeDispatch requestGoodIssue : requestGoodsIssueList) {
                partCodeSet.add(requestGoodIssue.partName);
                partIdList.add(requestGoodIssue.part);
                if(String.isNotBlank(requestGoodIssue.dealer)) agencyIdList.add(requestGoodIssue.dealer);
                warrantyIds.add(requestGoodIssue.warrantyId);
            }
            priceMap = getCustomerPriceByIf(currentUser.getAgencyCustomerCode(), salesOranization, distributionChannel, division, currentUser.getCountry(), partCodeSet);

        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        if(resultStatus.code != 200) return result;

        Savepoint sp = Database.setSavepoint(); 
        try {
        
            SchemaInfo goodsIssueSchema = new SchemaInfo('DealerInventoryMovements__c');
            String recordTypeDeveloperName = 'GoodsIssue';
            Id goodsIssueRecordTypeId = goodsIssueSchema.getRecordTypeByDeveloperName(recordTypeDeveloperName).getRecordTypeId();
            List<DealerFreeDispatch__c> updateWarrantyList = new List<DealerFreeDispatch__c>();
            Set<String> alreadyGoodsIssueses = new Set<String>();
            for(DealerFreeDispatch__c warranty : [
                SELECT Id, ShippingQuantity__c, OrderItem__r.Quantity__c, Dealer__r.Name, OrderItem__r.Product__r.ProductCode
                FROM DealerFreeDispatch__c
                WHERE Id IN :warrantyIds
                FOR UPDATE
            ]) {
                if(warranty.ShippingQuantity__c >= warranty.OrderItem__r.Quantity__c) {
                    alreadyGoodsIssueses.add(warranty.OrderItem__r.Product__r.ProductCode);
                }
            }

            if(alreadyGoodsIssueses.size() > 0) {
                throw new CustomException('[N] '+ String.join(alreadyGoodsIssueses, ',') + ' 부품이 이미 출고 되었습니다. 다시 조회 후 출고 부탁 드립니다.');
            }
            
            DateTime updateDateTime = System.now();
            List<DealerInventoryMovements__c> goodsIssueList = new List<DealerInventoryMovements__c>();

            SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
            String goodsIssueSeq = seqGenerator.generate(recordTypeDeveloperName);
            //출고완료 품목의 재고 변환
            Integer itemSeqNum = 1;
            Map<String, Map<String, DealerStock__c>> dealerStockMap = DN_DealerStockManager.getAvailableStockMapMutiple(agencyIdList, salesOranization, distributionChannel, division, partIdList);
            List<ProductRequest> partsClaims = new List<ProductRequest>();
            for(DealerFreeDispatch requestGoodIssue : requestGoodsIssueList) {
                if(dealerStockMap.containsKey(requestGoodIssue.dealer)) {
                    Map<String, DealerStock__c> stockMap = dealerStockMap.get(requestGoodIssue.dealer);
                    if(stockMap.containsKey(requestGoodIssue.part)) {
                        DealerStock__c stock = stockMap.get(requestGoodIssue.part);
                        //서비스 오더의 Warranty 예약 수량 차감 후 가용재고 업데이트
                        stock.WarrantyRequiredQuantity__c -= requestGoodIssue.requestQuantity;
                        stock.CurrentStockQuantity__c -= requestGoodIssue.requestQuantity;
                        stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                        stock.LastExportDateTime__c = updateDateTime;
                        if(stock.CurrentStockQuantity__c < 0) throw new CustomException('[N] 대리점('+ requestGoodIssue.dealerName +') 의 ' + requestGoodIssue.partName + ' 재고가 부족합니다.');
                        //+ ' [ '+ requestGoodIssue.d+']'
                        partsClaims.add(
                            new ProductRequest(Id = requestGoodIssue.itemId, ShippingCheck__c='Y', MENGE_GI__c = requestGoodIssue.requestQuantity, QDATU__c = Date.today())
                        );
                    }
                    //재고가 존재해야 출고가능
                    DealerFreeDispatch__c updateFreeDispatch = new DealerFreeDispatch__c (
                        Id = requestGoodIssue.warrantyId,
                        DeliveryDateTime__c = requestGoodIssue.plannedDeliveryDateTime,
                        Status__c = '2',
                        ShippingQuantity__c = requestGoodIssue.requestQuantity
                    );
                    updateWarrantyList.add(updateFreeDispatch);
                    String itemSeq = String.valueOf((itemSeqNum++) * 10);
                    DealerInventoryMovements__c goodsIssueDoc = new DealerInventoryMovements__c(
                        RecordTypeId = goodsIssueRecordTypeId,
                        Type__c = 'W', //Service Order
                        SalesOrganization__c = salesOranization,
                        DistributionChannel__c = distributionChannel,
                        Division__c = division,
                        InventoryChange__c = 'H', 
                        Dealer__c = requestGoodIssue.dealer,
                        Part__c = requestGoodIssue.part,
                        Quantity__c = requestGoodIssue.requestQuantity,
                        ServiceOrderItem__c = requestGoodIssue.itemId,
                        InventoryNumber__c = goodsIssueSeq,                 // EXPT_NO 출고문서 Seq
                        InventoryItemNumber__c = itemSeq.leftPad(6,'0')    // EXPT_SEQ
                        //TODO
                        //CurrencyIsoCode = requestGoodIssue.currencyCode,
                    );

                    //TODO: 부품 대리점 DealerGrade 가져올때까지 임시 주석
                    String deaelrGrade = requestGoodIssue.dealerGrade.trim();
                    if(dealerGradeRateAllMap.containsKey(deaelrGrade)) {
                        Decimal dealerGradeRate = dealerGradeRateAllMap.get(deaelrGrade);
                        updateFreeDispatch.NETPR__c = priceMap.get(requestGoodIssue.partName);
                        updateFreeDispatch.DealerGrade__c = requestGoodIssue.dealerGrade;

                        //dealerGradeRate : 음수 DNS 내수 판매가에 대리점 등급별 할인율 반영
                        goodsIssueDoc.CustomerPrice__c = priceMap.containsKey(requestGoodIssue.partName) ? priceMap.get(requestGoodIssue.partName) * (1 + dealerGradeRate) : 0 ;
                        
                        // 2025 05 07 서일태 무상부품 출고 완료 시 출고문서에 CustomerPrice__c 그대로 노출시키고 비용정산항목에서 수량을 곱하여 표시
                        // System.debug('goodsIssueDoc.CustomerPrice__c * goodsIssueDoc.Quantity__c : '+ goodsIssueDoc.CustomerPrice__c * goodsIssueDoc.Quantity__c);
                        goodsIssueDoc.DiscountedFreePartsTotalAmount__c = roundAndFloorToTen(goodsIssueDoc.CustomerPrice__c * goodsIssueDoc.Quantity__c);
                        // System.debug('goodsIssueDoc.DiscountedFreePartsTotalAmount__c : '+ goodsIssueDoc.DiscountedFreePartsTotalAmount__c);
                        goodsIssueDoc.CustomerPrice__c = roundAndFloorToTen(goodsIssueDoc.CustomerPrice__c);
                        updateFreeDispatch.NETPR_ETC__c = goodsIssueDoc.CustomerPrice__c;
                        goodsIssueDoc.DiscountPrice__c = goodsIssueDoc.CustomerPrice__c * 1.2;
                        goodsIssueDoc.DiscountPrice__c = roundAndFloorToTen(goodsIssueDoc.DiscountPrice__c);

                        //부품 1개의 20% 보상금액
                        goodsIssueDoc.CompensationAmount__c = goodsIssueDoc.DiscountPrice__c - goodsIssueDoc.CustomerPrice__c; //20% 보상금액
                        goodsIssueDoc.DealerGradeRate__c = dealerGradeRate; //대리점별 할인율

                        // 20250509  반올림(1개의 부품가격 *1.2) * 수량 > 반올림( 부품금액 * 1.2 )로 변경
                        goodsIssueDoc.DiscountAmount__c = (goodsIssueDoc.CustomerPrice__c * goodsIssueDoc.Quantity__c * 1.2);
                        // goodsIssueDoc.DiscountAmount__c = goodsIssueDoc.DiscountPrice__c * goodsIssueDoc.Quantity__c;
                        goodsIssueDoc.DiscountAmount__c = roundAndFloorToTen(goodsIssueDoc.DiscountAmount__c); //최종 보상금액

                    }else {
                        throw new CustomException('[N] 대리점('+ requestGoodIssue.dealerName +') 의 등급이 존재하지 않습니다. 관리자에게 문의하세요.');
                    }

                    if(String.isNotBlank(requestGoodIssue.loc)) goodsIssueDoc.Location__c = requestGoodIssue.loc;
                    goodsIssueList.add(goodsIssueDoc);
                }
                
            }

            List<DealerStock__c> dealerStockList = new List<DealerStock__c>();
            for(String dealerId : dealerStockMap.keySet()) {
                dealerStockList.addAll(dealerStockMap.get(dealerId).values());
            }

            if(updateWarrantyList.size() > 0) {
                seqGenerator.updateNextSequenceInfo();
                update updateWarrantyList;
                upsert dealerStockList ExternalKey__c;
                insert goodsIssueList;
                
                if(partsClaims.size() > 0) update partsClaims;

                result.put('goodsIssueList', goodsIssueList);
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        
        return result;
    }

    /*
    * @ Method : getCustomerPriceByIf
    * @ Description : 부품별 고객판매가 I/F
    */
    @TestVisible 
    private static Map<String, Decimal>  getCustomerPriceByIf(String dealerCode, String salesOrganization, String distributionChannel, String division, String countryCode, Set<String> partCodeSet) {
        Map<String, Decimal> priceMap = new Map<String, Decimal>();

        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req req = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();
        req.I_LANGU = 'ko'; 
        List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL> D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();
        
        for(String partCode : partCodeSet) {
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
            D_DETAIL.MATNR = partCode.toUpperCase();
            D_DETAIL_List.add(D_DETAIL);
        }
        req.D_DETAIL = D_DETAIL_List;
        
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
        I_USERINFO.KUNNR        = dealerCode;
        I_USERINFO.VKORG        = salesOrganization;
        I_USERINFO.VTWEG        = distributionChannel;
        I_USERINFO.SPART        = division;
        I_USERINFO.LAND1        = countryCode;
        I_USERINFO.DF_CHK       = 'X';
        req.I_USERINFO          = I_USERINFO;

        IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
        // instance.interfaceUtil.isInsertLog = false;
        IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res ifResult = instance.IF_PARTS_022(req);
        
        if('S'.equals(ifResult.O_RETURN.TYPE)) {
            for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL partInfo : ifResult.D_DETAIL) {
                //고객판매가
                priceMap.put(partInfo.MATNR, Decimal.valueOf(partInfo.NETPR));
            }
        }

        return priceMap;
    }

    /*
    * @ Method : getStockByChangeDealer
    * @ Description : 대리점 변경시 해당 대리점에서 관리하고 있는 재고 정보 조회
    */
    @AuraEnabled
    public static Map<String,Object> getStockByChangeDealer(String dealerId, List<String> partIdList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();

            Map<String,DealerStock__c> dealerStockMap = DN_DealerStockManager.getAvailableStockMap(dealerId, salesOranization, distributionChannel, division, new Set<String>(partIdList));
            result.put('dealerStockMap', dealerStockMap);
            
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : updateWarranty
    * @ Description : 저장 - 상태, 배송방법, 공급대리점
    */
    @AuraEnabled
    public static Map<String,Object> updateWarranty(List<DealerFreeDispatch> requestGoodsIssueList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();

            System.debug(' salesOranization : '+ salesOranization);
            System.debug(' distributionChannel : '+ distributionChannel);
            System.debug(' division : '+ division);

            Set<String> warrantyIdSet = new Set<String>();
            Set<String> partIdList = new Set<String>();
            Set<String> agencyIdList = new Set<String>();
            List<DealerFreeDispatch__c> updateWarrantyList = new List<DealerFreeDispatch__c>();
            for(DealerFreeDispatch requestGoodIssue : requestGoodsIssueList) {
                warrantyIdSet.add(requestGoodIssue.warrantyId);
                partIdList.add(requestGoodIssue.part);
                if(String.isNotBlank(requestGoodIssue.dealer)) agencyIdList.add(requestGoodIssue.dealer);

            }
            
            Map<Id, DealerFreeDispatch__c> beforeWarrantyMap = new Map<Id, DealerFreeDispatch__c>([
                SELECT Id, Dealer__c, Status__c, FM_RequestQuantity__c
                FROM DealerFreeDispatch__c WHERE Id IN :warrantyIdSet
            ]);

            for(DealerFreeDispatch__c beforeWarranty : beforeWarrantyMap.values()) {
                if(String.isNotBlank(beforeWarranty.Dealer__c)) agencyIdList.add(beforeWarranty.Dealer__c);
            }

            //공급 대리점 재고 변환시 품목의 재고 변환
            Map<String, Map<String, DealerStock__c>> dealerStockMap = DN_DealerStockManager.getAvailableStockMapMutiple(agencyIdList, salesOranization, distributionChannel, division, partIdList);
            for(DealerFreeDispatch requestGoodIssue : requestGoodsIssueList) {
                //- 공급대리점 변경이 있을 경우 재고 조정 필요 
                DealerFreeDispatch__c updateWarranty = new DealerFreeDispatch__c (
                    Id = requestGoodIssue.warrantyId,
                    Status__c = requestGoodIssue.status,
                    ShippingType__c = requestGoodIssue.shippingType
                );
                updateWarrantyList.add(updateWarranty);

                String beforeDealerId = '';
                String beforeStatus = '';
                String afterDealerId = requestGoodIssue.dealer;
                String afterStatus = requestGoodIssue.status;
                if(beforeWarrantyMap.containsKey(requestGoodIssue.warrantyId)) {
                    DealerFreeDispatch__c beforeWarranty = beforeWarrantyMap.get(requestGoodIssue.warrantyId);
                    beforeDealerId = beforeWarranty.Dealer__c;
                    beforeStatus = beforeWarranty.Status__c;
                }

                if(!dealerStockMap.containsKey(beforeDealerId)) throw new CustomException('[N] ' + ' 판매조직('+ salesOranization + ' / '+ distributionChannel +' / '+ division +') 에서 ' + requestGoodIssue.partName + ' 재고를 관리하지 않는 대리점이 있습니다.');
                if(!dealerStockMap.containsKey(afterDealerId)) throw new CustomException('[N] ' + ' 판매조직('+ salesOranization + ' / '+ distributionChannel +' / '+ division +') 에서 ' + requestGoodIssue.partName + ' 재고를 관리하지 않는 대리점이 있습니다.');
                //1. 단순 상태값 변경
                if(beforeStatus != afterStatus && beforeDealerId == afterDealerId) {
                    //상태값만 변경 된 경우: 
                    System.debug('상태값만 변경 된 경우');
                    Map<String, DealerStock__c> stockMap = dealerStockMap.get(afterDealerId);
                    if(stockMap.containsKey(requestGoodIssue.part)) {
                        //상태값에 따라 예약재고 및 가용재고 변환
                        DealerStock__c stock = stockMap.get(requestGoodIssue.part);
                        processFreeDispatchStockChange(updateWarranty , beforeWarrantyMap.get(requestGoodIssue.warrantyId), stock);
                    }
                    
                }else if(beforeStatus == afterStatus && afterDealerId != beforeDealerId) {
                    //2. 대리점만 변경 된 경우
                    System.debug('대리점만 변경 된 경우');
                    //진행 상태일 경우만 재고 변환
                    if('3'.equals(afterStatus)) continue;
                    System.debug('beforeDealerId : '+ beforeDealerId + ' | afterDealerId : '+afterDealerId);
                    Map<String, DealerStock__c> beforeStockMap = dealerStockMap.get(beforeDealerId);
                    if(beforeStockMap.containsKey(requestGoodIssue.part)) {
                        DealerStock__c stock = beforeStockMap.get(requestGoodIssue.part);
                        //변경 전 대리점 서비스 오더 예약량 삭제 및 가용재고 조정
                        stock.WarrantyRequiredQuantity__c -= requestGoodIssue.requestQuantity;
                        stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                    }
                    
                    Map<String, DealerStock__c> afterStockMap = dealerStockMap.get(afterDealerId);
                    if(afterStockMap.containsKey(requestGoodIssue.part)) {
                        DealerStock__c stock = afterStockMap.get(requestGoodIssue.part);
                        //변경 후 대리점 서비스 오더 예약량 추가 및 가용재고 조정
                        stock.WarrantyRequiredQuantity__c += requestGoodIssue.requestQuantity;
                        stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                    }
                    updateWarranty.Dealer__c = afterDealerId;
                    
                }else if(beforeStatus != afterStatus && afterDealerId != beforeDealerId) {
                    System.debug('상태값, 대리점 변경 된 경우');
                    DealerFreeDispatch__c beforeWarranty = beforeWarrantyMap.get(requestGoodIssue.warrantyId);
                    if(afterStatus != beforeStatus && '3'.equals(afterStatus) && '1'.equals(beforeStatus)) {
                        // 진행 -> 취소일 경우 
                        // 이전 대리점 재고만 변환 (증감)
                        Map<String, DealerStock__c> stockMap = dealerStockMap.get(beforeDealerId);
                        DealerStock__c stock = stockMap.get(requestGoodIssue.part);
                        stock.WarrantyRequiredQuantity__c -= beforeWarranty.FM_RequestQuantity__c;
                        stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
            
                    }else if(afterStatus != beforeStatus && '1'.equals(afterStatus) && '3'.equals(beforeStatus)) {
                        // 취소 -> 진행
                        // 변경된 대리점 재고만 변환 (증가)
                        Map<String, DealerStock__c> stockMap = dealerStockMap.get(afterDealerId);
                        DealerStock__c stock = stockMap.get(requestGoodIssue.part);
                        stock.WarrantyRequiredQuantity__c += beforeWarranty.FM_RequestQuantity__c;
                        stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                    }
                    updateWarranty.Dealer__c = afterDealerId;
                }
            }

            List<DealerStock__c> dealerStockList = new List<DealerStock__c>();
            for(String dealerId : dealerStockMap.keySet()) {
                dealerStockList.addAll(dealerStockMap.get(dealerId).values());
            }

            if(updateWarrantyList.size() > 0) {
                update updateWarrantyList;
                upsert dealerStockList ExternalKey__c;
            }

            result.put('updateWarrantyList', updateWarrantyList);
            
        } catch (Exception e) {
            Database.rollback(sp);
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : processFreeDispatchStockChange
    * @ Description : 단순 상태값 변경에 따른 재고 수량 변경
    */
    private static void processFreeDispatchStockChange(DealerFreeDispatch__c updateWarranty, DealerFreeDispatch__c beforeWarranty, DealerStock__c stock) {
        // 추가 확인 내용
        if(stock != null) {
            if(updateWarranty.Status__c != beforeWarranty.Status__c && '3'.equals(updateWarranty.Status__c) && '1'.equals(beforeWarranty.Status__c)) {
                // 진행 -> 취소일 경우 
                // 대리점 재고의 예약량 삭제 및 가용재고 조정 
                stock.WarrantyRequiredQuantity__c -= beforeWarranty.FM_RequestQuantity__c;
                stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
    
            }else if(updateWarranty.Status__c != beforeWarranty.Status__c && '1'.equals(updateWarranty.Status__c) && '3'.equals(beforeWarranty.Status__c)) {
                // 취소 -> 진행
                // 대리점 재고의 예약량 추가 및 가용재고 조정 
                stock.WarrantyRequiredQuantity__c += beforeWarranty.FM_RequestQuantity__c;
                stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
            }
        }
    }

    /*******************************************  Claim Order 화면 ********************************************************/

    /*
    * @ Method : warrantyDetailInit
    * @ Description : Claim Order 상세 정보
    */
    @AuraEnabled
    public static Map<String,Object> warrantyDetailInit(String warrantySeq){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            ClaimOrder claimDetails;
            for(WorkOrder serviceOrder : [
                SELECT
                WorkOrderNumber,
                 Noti_Number__c,                //통지번호
                 ServiceOrderNumber__c,         //서비스오더
                 Case.ApplicationDateTime__c,   //접수일
                 Case.Asset.MachineName__c,     //기종
                 Case.Asset.Name,               //장비번호
                 Case.Account.Representative__c,//대표자명
                 Case.Account.Phone,            //전화
                 Case.Account.Mobile__c,        //핸드폰
                 Case.Account.FM_Address__c,    //고객주소
                 Case.ReceptionDetails__c       //요청내용
                FROM WorkOrder
                WHERE WorkOrderNumber = :warrantySeq OR ServiceOrderNumber__c = :warrantySeq
            ]) {
                claimDetails = new ClaimOrder(serviceOrder);
            }
            result.put('claimDetails', claimDetails);

        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug(e.getStackTraceString());
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*******************************************  비용정산 대상항목 조회 화면 ********************************************************/
    /*
    * @ Method : searchCostWarrnatyItems
    * @ Description : 비용정산 대상항목 조회
    */
    @AuraEnabled
    public static Map<String,Object> searchCostWarrnatyItems(String status,
                                                              Date approvalDateStart, 
                                                              Date approvalDateEnd,
                                                              String customerId,
                                                              Map<String, Decimal> dealerGradeRateAllMap
    ){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        DateTime approvalDateStartDateTime;
        if(approvalDateStart != null) approvalDateStartDateTime = DateTime.newInstance(approvalDateStart.year(), approvalDateStart.month(), approvalDateStart.day());
        DateTime approvalDateEndDateTime;
        if(approvalDateEnd != null) approvalDateEndDateTime = DateTime.newInstance(approvalDateEnd.year(), approvalDateEnd.month(), (approvalDateEnd.day()+1));
        Map<String, Decimal> priceMap = new Map<String, Decimal>();
        if(dealerGradeRateAllMap == null) dealerGradeRateAllMap = new Map<String, Decimal>();
        String agencyId = currentUser.getAgencyId();
        String salesOranization = currentUser.getSalesOranization();
        String distributionChannel = currentUser.getDistributionChannel();
        String division = currentUser.getDivision();
        try {

            String querySelect = ' SELECT ';
            String queryFields ='     Id,  '
                            + ' OrderItem__c, '
                            + ' OrderItem__r.WorkOrder.Worker__r.Name,  '  //서비스기사	서비스 오더 Person 
                            + ' OrderItem__r.WorkOrder.Worker__r.PhoneNumber__c,  '//서비스기사 서비스 오더 Phone
                            + ' OrderItem__r.WorkOrder.ServiceTerritory.Name, ' //정비업체	서비스 오더 Main work center 
                            + ' OrderItem__r.WorkOrder.ServiceTerritory.ServiceWorkCenter__r.FM_Address__c, '
                            + ' OrderItem__r.WorkOrder.ServiceTerritory.ServiceWorkCenter__r.TransportationZoneL__r.Name,'
                            + ' OrderItem__r.WorkOrderId, '
                            + ' OrderItem__r.FM_DaysElapsed__c, '
                            + ' Status__c, '
                            + ' toLabel(Status__c) statusLabel, '
                            + ' Dealer__c, '
                            + ' Dealer__r.TransportationZoneL__r.Name,'
                            + ' Dealer__r.FM_Address__c,'
                            + ' Dealer__r.Name, '
                            + ' Dealer__r.DealerGrade__c, '
                            + ' Dealer__r.DealerGrade_Parts__c, '
                            // + ' Dealer__r.TransportationZoneL__r.Name, '
                            + ' DeliveryDateTime__c, '
                            + ' ShippingType__c, '
                            + ' toLabel(ShippingType__c) shippingTypeLabel, '
                            + ' ShippingQuantity__c, '
                            + ' FM_RequestQuantity__c,  '
                            + ' OrderItem__r.Product__c, '
                            + ' OrderItem__r.Product__r.ProductCode, '
                            + ' OrderItem__r.Product__r.FM_MaterialDetails__c, '
                            + ' FM_OrderItemNumber__c, '
                            + ' FM_OrderNumber__c, '
                            + ' FM_Unit__c, '
                            + ' FinalSettlementAmount__c, '
                            + ' ConfirmDateTime__c, ' //정산대상인 경우 - 확정일
                            + ' FM_ApprovalDate__c, ' //접수일	 ZSST8070-QMDAT
                            +'  OrderItem__r.WorkOrder.Case.Asset.MachineName__c,      '//기종
                            +'  OrderItem__r.WorkOrder.Case.Asset.Name,                '//장비번호
                            +'  OrderItem__r.WorkOrder.Case.Account.Phone,             '//전화
                            +'  OrderItem__r.WorkOrder.Case.Account.Mobile__c,         '//핸드폰
                            +'  OrderItem__r.WorkOrder.Case.Account.FM_Address__c,     '//고객주소
                            +'  OrderItem__r.WorkOrder.Case.ReceptionDetails__c,        '//요청내용
                            +'  OrderItem__r.WorkOrder.ConfirmedDate__c, ' // 확정일	서비스 오더 확정일
                            +'  OrderItem__r.WorkOrder.Account.Name, '// 고객명	서비스 오더의 고객명
                            +'  OrderItem__r.WorkOrder.Account.FM_Address__c, '
                            +'  OrderItem__r.WorkOrder.Account.Phone, '
                            // +'  OrderItem__r.WorkOrder.Account.TransportationZoneL__r.Name, ' //화물영업소  
                            +'  OrderItem__r.ShipTo__c '; //ShipTo                            

            String queryFrom = ' FROM  DealerFreeDispatch__c '
                             +' WHERE Id != null AND Delete__c != \'Y\' ';

            String additionalWhereClause = '';
            String queryOrderBy = ' ORDER BY FM_ApprovalDate__c desc LIMIT 2000';
            System.debug(customerId + ' ::: customerId');            
            

            if(String.isNotBlank(status) && !'All'.equals(status)) {
                

                switch on status {
                    when  '1' {

                        if(approvalDateStart != null && approvalDateEnd != null) additionalWhereClause += ' AND ( FM_ApprovalDate__c >= :approvalDateStart AND FM_ApprovalDate__c <= :approvalDateEnd ) ';
                        else if(approvalDateStart != null && approvalDateEnd == null) additionalWhereClause += ' AND FM_ApprovalDate__c >= :approvalDateStart ';
                        else if(approvalDateStart == null && approvalDateEnd != null) additionalWhereClause += ' AND FM_ApprovalDate__c <= :approvalDateEnd ';        

                        additionalWhereClause += ' AND Status__c = \'2\' AND OrderItem__r.WorkOrder.ConfirmedDate__c = null ';
                    }
                    //확정대기가 아닐경우 
                    when '2', '4' {
                        //출고 완료, 정산대상
                        
                        if(approvalDateStartDateTime != null && approvalDateEndDateTime != null) additionalWhereClause += ' AND ( OrderItem__r.WorkOrder.ConfirmedDate__c  >= :approvalDateStartDateTime AND OrderItem__r.WorkOrder.ConfirmedDate__c  < :approvalDateEndDateTime ) ';
                        else if(approvalDateStartDateTime != null && approvalDateEndDateTime == null) additionalWhereClause += ' AND OrderItem__r.WorkOrder.ConfirmedDate__c  >= :approvalDateStartDateTime ';
                        else if(approvalDateStartDateTime == null && approvalDateEndDateTime != null) additionalWhereClause += ' AND OrderItem__r.WorkOrder.ConfirmedDate__c  < :approvalDateEndDateTime ';            
                        additionalWhereClause += ' AND Status__c = :status ';
                    }

                    when '5' {
                        //정산완료
                        if(approvalDateStartDateTime != null && approvalDateEndDateTime != null) additionalWhereClause += ' AND ( ConfirmDateTime__c >= :approvalDateStartDateTime AND ConfirmDateTime__c < :approvalDateEndDateTime ) ';
                        else if(approvalDateStartDateTime != null && approvalDateEndDateTime == null) additionalWhereClause += ' AND ConfirmDateTime__c >= :approvalDateStartDateTime ';
                        else if(approvalDateStartDateTime == null && approvalDateEndDateTime != null) additionalWhereClause += ' AND ConfirmDateTime__c < :approvalDateEndDateTime ';        
                        additionalWhereClause += ' AND Status__c = :status ';
                    }
                }


                
            }

            
            Boolean isAdmin = currentUser.getIsAdmin();
            if(!isAdmin) additionalWhereClause += ' AND Dealer__c = \'' + agencyId + '\'';

            if(isAdmin && String.isNotBlank(customerId) && !'All'.equals(customerId)) {
                List<DealerCustomer__c> customer = [SELECT Id, SourceAccount__c FROM DealerCustomer__c WHERE Id=:customerId AND SourceAccount__c !=null];
                additionalWhereClause += ' AND Dealer__c = \'' + customer[0].SourceAccount__c + '\''; 
            }

            List<DealerFreeDispatch> warrantyList = new List<DealerFreeDispatch>();
            System.debug(querySelect + queryFields + queryFrom + additionalWhereClause + queryOrderBy + ' :: QUERY');
            Set<String> shipToWorkCenterIdList = new Set<String>();
            Set<String> serviceOrderItemIdList = new Set<String>();
            Set<String> partCodeSet = new Set<String>();
            for(DealerFreeDispatch__c warrnty : Database.query(querySelect + queryFields + queryFrom + additionalWhereClause + queryOrderBy)) {
                if(warrnty.OrderItem__r.ShipTo__c != null) shipToWorkCenterIdList.add(warrnty.OrderItem__r.ShipTo__c);
                if(warrnty.OrderItem__r.Product__r.ProductCode != null) partCodeSet.add(warrnty.OrderItem__r.Product__r.ProductCode);

                serviceOrderItemIdList.add(warrnty.OrderItem__c);
                warrantyList.add(new DealerFreeDispatch(warrnty));
            }

            Map<String, DealerInventoryMovements__c> goodsIssueMap = new Map<String, DealerInventoryMovements__c>();
            for(DealerInventoryMovements__c goodsIssues : [ 
                SELECT 
                    Id, ServiceOrderItem__c, Quantity__c ,CustomerPrice__c, DiscountPrice__c, DiscountAmount__c, FM_CreatedDate__c
                    , FM_DiscountedFreePartsTotalAmount__c, DealerGradeRate__c
                FROM DealerInventoryMovements__c WHERE ServiceOrderItem__c IN :serviceOrderItemIdList AND ServiceOrderItem__c != null
                LIMIT 3000
            ]) {
                goodsIssueMap.put(goodsIssues.ServiceOrderItem__c, goodsIssues);
            }

            Map<Id,ServiceTerritory> shipToWorkCenterMap = new Map<Id,ServiceTerritory>([
                SELECT Id, 
                       ServiceWorkCenter__r.Name, 
                       ServiceWorkCenter__r.Phone, 
                       ServiceWorkCenter__r.ShippingStreet, 
                       ServiceWorkCenter__r.ShippingCity, 
                       ServiceWorkCenter__r.ShippingState, 
                       ServiceWorkCenter__r.DetailAddress__c,
                       ServiceWorkCenter__r.FM_Address__c
                FROM ServiceTerritory where Classify__c = 'W/C' and Id IN :shipToWorkCenterIdList LIMIT 2000
            ]);

            for(DealerFreeDispatch warranty : warrantyList) {
                if(warranty.shipToId != null) {
                    try {
                        //Id 외에 값도 들어감
                        //
                        Id serviceTerrorityId = Id.valueOf(warranty.shipToId); 
                    } catch (StringException e) {
                        System.debug(e.getMessage());
                        //고객직송인경우 WorkOrder 의 Account 의 주소
                    }
                    //화물인 경우 화물영업소의 정보
                }
                if(goodsIssueMap.containsKey(warranty.itemId)) {
                    DealerInventoryMovements__c goodsIssue = goodsIssueMap.get(warranty.itemId);
                    setAmountByStatus(goodsIssue, warranty);
                }
            }

            result.put('settlementAmountList', warrantyList);
            
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : roundAndFloorToTen
    * @ Description : 일의 자리 절삭에서 반올림으로 변경
    */
    @TestVisible
    private static Decimal roundAndFloorToTen(Decimal customerPrice) {
        if(customerPrice == null) {
            customerPrice = 0;
            return customerPrice;
        }
        //일의자리에서 반올림
        customerPrice = (customerPrice/10).setScale(0, RoundingMode.HALF_UP);
        customerPrice = customerPrice *10;
        // customerPrice = Math.round((customerPrice / 10))* 10;
        
        // customerPrice = customerPrice.setScale(0, RoundingMode.HALF_UP) *10;
        return customerPrice;
    }

    /*
    * @ Method : setAmountByStatus
    * @ Description : 상태별 금액
    */
    @TestVisible
    private static void setAmountByStatus(DealerInventoryMovements__c goodsIssue, DealerFreeDispatch warranty) {
        warranty.deliveryDate = goodsIssue.FM_CreatedDate__c;
        //25.05.07 출고문서 화면로직에서 수량까지 곱하여 부품가격구함
        switch on warranty.status {
            //정산대상, 정산완료
            when '4', '5' {
                //1. 20% 보상금액 : 반올림 (최종 보상금액 / 120 * 20)
                //2. 단가(할인율 반영한 단가) : 반올림 (최종 보상금액 - 20% 보상금액)
                warranty.compensationAmount = roundAndFloorToTen(warranty.finalCompensationAmount / 120 * 20);
                warranty.customerPrice = warranty.finalCompensationAmount - warranty.compensationAmount;

            }
            when else {
                
                //정산대상이 아닐경우 (확정 대기, 출고 완료 일 경우)
                warranty.customerPrice = (goodsIssue.CustomerPrice__c != null) ? roundAndFloorToTen(goodsIssue.CustomerPrice__c) * goodsIssue.Quantity__c : 0;
                //DiscountPrice: 반올림( (할인율적용한단가) * 1.2) >  반올림(부품금액 * 1.2)으로 변경
                warranty.finalCompensationAmount = roundAndFloorToTen(warranty.customerPrice * 1.2);
                // warranty.finalCompensationAmount = (goodsIssue.DiscountPrice__c != null) ? (roundAndFloorToTen(goodsIssue.DiscountPrice__c) * goodsIssue.Quantity__c) : 0;
                warranty.compensationAmount = warranty.finalCompensationAmount - warranty.customerPrice;
                
                //임시 주석 TODO: 필드항목 확정 받고 수정
                warranty.dealerGradeRate = goodsIssue.DealerGradeRate__c;
                
            }
        }
        
    }

    /*
    * @ Method : statusUpdate
    * @ Description : 상태저장
    */
    @AuraEnabled
    public static void statusUpdate(List<DealerFreeDispatch> updateList, String statusCode){
        try {
            System.debug(updateList + ' :::updateList');
            System.debug(statusCode + ' :::statusCode');
            String errorMessage = errorMessage(updateList,statusCode);
            if(errorMessage !='') {
                throw new CustomException(errorMessage);    
            }
            set<String> freeIds = new set<String>();
            Map<String, DealerFreeDispatch> updateMap = new Map<String, DealerFreeDispatch>();
            for(DealerFreeDispatch patch : updateList) {
                updateMap.put(patch.warrantyId, patch);
            }
            List<DealerFreeDispatch__c> freeDispatchList = [select Id, Status__c from DealerFreeDispatch__c where Id IN :updateMap.keySet()]; //FOR UPDATE
            DateTime now = System.now();
            Boolean isERPUpdate = false;
            List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST> updateErpList = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST>();

            for(DealerFreeDispatch__c free : freeDispatchList) {
                free.Status__c = statusCode;
                switch on free.Status__c {
                    when '2' {
                        //출고완료 == 확정완료
                        //ZSST8070-WRAMT	Blank 로 업데이트
                        free.FinalSettlementAmount__c = 0; //최종보상금액
                        free.ConfirmDateTime__c = null; //확정일(ZSST8070-ERSDA)	Blank 로 업데이트
                        free.SettlementStatusUpdateDateTime__c = null; //실제 정산 업데이트일
                        //임시 주석 TODO: 필드항목 확정 받고 수정
                        free.CompensationAmount__c = 0; //20% 보상금액 
                        free.DealerGradeRate__c = 0;    //대리점 할인율
                        free.CustomerPrice__c = 0;      //부품금액 (대리점 할인율 적용한 단가 * 수량(?))
                    }
                    when '4' {
                        //정산대상
                        //ZSST8070-WRAMT	최종보상금액
                        DealerFreeDispatch updatePatch = updateMap.get(free.Id);

                        free.FinalSettlementAmount__c = updatePatch.finalCompensationAmount;
                        free.ConfirmDateTime__c = updatePatch.confirmDate; //ZSST8070-ERSDA	확정일
                        free.SettlementStatusUpdateDateTime__c = now;

                        //임시 주석 TODO: 필드항목 확정 받고 수정
                        free.CompensationAmount__c = updatePatch.compensationAmount;
                        free.DealerGradeRate__c = updatePatch.dealerGradeRate;   
                        free.CustomerPrice__c = updatePatch.customerPrice;
                        isERPUpdate = true;

                        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST IT_LIST = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST();
                        IT_LIST.AUFNR = updatePatch.serviceOrderSeq;
                        IT_LIST.POSNR = updatePatch.itemSeq;
                        IT_LIST.BMENG = String.valueOf(updatePatch.giQuantity);
                        IT_LIST.PDATE = updatePatch.plannedDeliveryDateTime?.format('YYYYMMdd');
                        IT_LIST.PTIME = updatePatch.plannedDeliveryDateTime?.format('HH:mm:ss');
                        IT_LIST.WRAMT = String.valueOf(updatePatch.finalCompensationAmount);
                        IT_LIST.WAERS = 'KRW';
                        IT_LIST.ERSDA = updatePatch.confirmDate?.format('YYYYMMdd');
                        updateErpList.add(IT_LIST);
                    }
                    when '5' {
                        //정산완료
                        isERPUpdate = true;
                        
                        DealerFreeDispatch updatePatch = updateMap.get(free.Id);

                        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST IT_LIST = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_IT_LIST();
                        IT_LIST.AUFNR = updatePatch.serviceOrderSeq;
                        IT_LIST.POSNR = updatePatch.itemSeq;
                        IT_LIST.BMENG = String.valueOf(updatePatch.giQuantity);
                        IT_LIST.PDATE = updatePatch.plannedDeliveryDateTime?.format('YYYYMMdd');
                        IT_LIST.PTIME = updatePatch.plannedDeliveryDateTime?.format('HH:mm:ss');
                        IT_LIST.WRAMT = String.valueOf(updatePatch.finalCompensationAmount);
                        IT_LIST.WAERS = 'KRW';
                        IT_LIST.ERSDA = updatePatch.confirmDate?.format('YYYYMMdd');
                        updateErpList.add(IT_LIST);
                    }
                }
            }

            if(isERPUpdate) {
                // ERP 상태 업데이트 
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req request = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req();                
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_I_ORG I_ORG   = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Req_I_ORG();
                I_ORG.VKORG = '1846';
                I_ORG.VTWEG = '10';
                I_ORG.SPART = '40';
                
                request.I_ORG = I_ORG;
                request.I_STAT = statusCode;
                // request.I_STAT = I_STAT;
                request.IT_LIST = updateErpList;
                
                IF_ERP_DealerStock method = new IF_ERP_DealerStock();
                System.debug('IF-DEALERSTOCK-015.RequestParams: ' + JSON.serialize(request));
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_015_Res response = method.IF_DEALERSTOCK_015(request);
                System.debug('IF-DEALERSTOCK-015 : '+JSON.serialize(response));
                if(response.ES_RETURN.TYPE == 'E') {
                    //Exception
                    throw new CustomException(response.ES_RETURN.MESSAGE);
                }

            }

            update freeDispatchList;
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }

    /*
    * @ Method : errorMessage
    * @ Description : 비용 정산 상태값 업데이트 시 벨리데이션
    */
    public static String errorMessage(List<DealerFreeDispatch> updateList, String statusCode) {
        for(DealerFreeDispatch dispatch :updateList) {
            switch on dispatch.status {
                when '2' {
                    if(statusCode !='4') {
                        return '진행상태가 완료인 항목만 정산대상 상태로 변경 가능합니다.';
                    }
                    else if(dispatch.confirmDate == null) {
                        return '확정대기 리스트는 상태저장 대상이 아닙니다.';
                    }
                }
                when '5' {
                    // if(statusCode !='4') {
                        return '진행상태가 완료인 항목은 상태값 변경이 불가능합니다. 관리자에게 문의해주세요.';
                    // }
                }
                when '4' {
                    if( statusCode !='5' && statusCode !='2') {
                        return '진행상태가 정산대상인 항목만 정산완료 및 확정완료 상태로 변경 가능합니다.';
                    }
                }
                when '1' {
                    return '확정대기 리스트는 상태저장 대상이 아닙니다.';
                }
            }
        }
        return '';
    }


    /*
    * @ Class : ClaimOrder
    * @ Description : ClaimOrder Class
    */
    public class ClaimOrder {
        @AuraEnabled public String  notiNumber           {get; set;}
        @AuraEnabled public String  serviceOrderSeq      {get; set;}
        @AuraEnabled public DateTime receivedDateTime    {get; set;} //접수일
        @AuraEnabled public String machineName           {get; set;} //기종
        @AuraEnabled public String equipment             {get; set;} //장비
        @AuraEnabled public String representative        {get; set;} //대표자명
        @AuraEnabled public String phone                 {get; set;} //
        @AuraEnabled public String mobile                {get; set;} //
        @AuraEnabled public String address               {get; set;} //
        @AuraEnabled public String receptionDetails      {get; set;} //
        public ClaimOrder(){}
        
        /*
        * @ 생성자 : ClaimOrder
        * @ Description : serviceOrder 정보 매핑
        */
        public ClaimOrder(WorkOrder serviceOrder){
            this.notiNumber = serviceOrder.Noti_Number__c;                      //통지번호
            this.serviceOrderSeq = serviceOrder.ServiceOrderNumber__c;          //서비스오더
            this.receivedDateTime = serviceOrder.Case.ApplicationDateTime__c;   //접수일
            this.machineName = serviceOrder.Case.Asset.MachineName__c;          //기종
            this.equipment = serviceOrder.Case.Asset.Name;                      //장비번호
            this.representative = serviceOrder.Case.Account.Representative__c;  //대표자명
            this.phone = serviceOrder.Case.Account.Phone;                       //전화
            this.mobile = serviceOrder.Case.Account.Mobile__c;                  //핸드폰
            this.address = serviceOrder.Case.Account.FM_Address__c;             //고객주소
            this.receptionDetails = serviceOrder.Case.ReceptionDetails__c;      //요청내용
        }
    }

    /*
    * @ 생성자 : DealerFreeDispatch
    * @ Description : 무상출고 클래스
    */
    public class DealerFreeDispatch {
        @AuraEnabled public String  warrantyId            {get; set;} //무상부품Id
        @AuraEnabled public String  serviceOrderId       {get; set;} //WorkOrder 
        @AuraEnabled public String  serviceOrderSeq      {get; set;}
        @AuraEnabled public String  itemId               {get; set;} //서비스 주문ItemId ProductRequest
        @AuraEnabled public String  itemSeq              {get; set;}
        @AuraEnabled public String  part                 {get; set;}
        @AuraEnabled public String  partName             {get; set;}
        @AuraEnabled public String  partDetails          {get; set;}
        @AuraEnabled public Decimal requestQuantity      {get; set;} //서비스 요청수량
        @AuraEnabled public Decimal giQuantity           {get; set;} //서비스 출고수량
        @AuraEnabled public Decimal avaiableQuantity     {
            get{
                if(avaiableQuantity == null) avaiableQuantity = 0;
                return avaiableQuantity;
            } 
            set;
        } //가용재고
        @AuraEnabled public Decimal reservedQuantity     {
            get{
                if(reservedQuantity == null) reservedQuantity = 0;
                 return reservedQuantity;
            }
            set;
        } //예약수량
        @AuraEnabled public Decimal currentStockQuantity {
            get{
                if(currentStockQuantity == null) currentStockQuantity = 0;
                return currentStockQuantity;
            } 
            set;
        } //현재고
        @AuraEnabled public String  currencyCode         {get; set;}
        @AuraEnabled public Date    approvalDate         {get; set;} //승인일
        @AuraEnabled public String  shippingType         {get; set;} //배송방법
        @AuraEnabled public String  shippingTypeLabel    {get; set;} //배송방법
        @AuraEnabled public String  shipToId             {get; set;} //배송처Id
        @AuraEnabled public String  shipTo               {get; set;} //배송처
        @AuraEnabled public String  shipToAddress        {get; set;} //배송처 주소
        @AuraEnabled public String  shipToPhone          {get; set;} //배송처 연락처
        @AuraEnabled public String  serviceEngineer      {get; set;} //서비스 기사
        @AuraEnabled public String  centerName           {get; set;} //정비업체
        @AuraEnabled public String  dealer               {get; set;} //공급 대리점Id
        @AuraEnabled public String  dealerName           {get; set;} //공급 대리점명
        @AuraEnabled public String  dealerGrade          {
            get {
                if(dealerGrade == null) dealerGrade = '';
                return dealerGrade;
            } 
            set;
        } //공급 대리점 등급
        @AuraEnabled public Decimal durationInDays       {get; set;} //경과일
        @AuraEnabled public String  status               {get; set;} //
        @AuraEnabled public String  statusLabel          {get; set;} //
        @AuraEnabled public String  loc                  {get; set;} //재고위치Id
        @AuraEnabled public String  locName              {get; set;} //재고위치
        @AuraEnabled public Boolean isSelected = false;
        @AuraEnabled public DateTime plannedDeliveryDateTime {get; set;} //배송 예정 시간
        @AuraEnabled public String plannedDeliveryDateTimeString {get; set;} //배송 예정 시간
        @AuraEnabled public Date deliveryDate            {get; set;} //배송 완료 일자
        @AuraEnabled public DateTime confirmDate         {get; set;} //서비스 오더 확정일
        @AuraEnabled public String confirmDateStr        {get; set;} //서비스 오더 확정일 (yyyy-mm-dd)
        @AuraEnabled public String machineName           {get; set;} //기종
        @AuraEnabled public String equipment             {get; set;} //장비
        @AuraEnabled public String customerName          {get; set;} //서비스 오더의 고객명
        @AuraEnabled public Decimal customerPrice        {
            get {
                if(customerPrice == null) customerPrice = 0;
                return customerPrice;
            }
            set;
        } //부픔금액
        @AuraEnabled public Decimal compensationAmount   {
            get{
                if(compensationAmount == null) compensationAmount = 0;
                return compensationAmount;
            } 
            set;
        } //보상금액
        @AuraEnabled public Decimal finalCompensationAmount {
            get{
                if(finalCompensationAmount == null) finalCompensationAmount = 0;
                return finalCompensationAmount;
            }
            set;
        }//최종 보상 금액

        @AuraEnabled public Decimal dealerGradeRate {
            get {
                if(dealerGradeRate == null) dealerGradeRate = 0;
                return dealerGradeRate;
            }
            set;
        }//대리점별 할인율

        /*
        * @ 생성자 : DealerFreeDispatch
        * @ Description : 무상출고 데이터 매핑
        */
        public DealerFreeDispatch() {}
        public DealerFreeDispatch(DealerFreeDispatch__c warranty) {
            this.warrantyId      = warranty.Id;
            this.serviceOrderId  = warranty.OrderItem__r.WorkOrderId;
            this.itemId          = warranty.OrderItem__c;
            this.itemSeq         = warranty.FM_OrderItemNumber__c; // 
            this.serviceEngineer = warranty.OrderItem__r.WorkOrder.Worker__r.Name;
            this.centerName      = warranty.OrderItem__r.WorkOrder.ServiceTerritory.Name;
            this.status          = warranty.Status__c;
            this.statusLabel     = String.valueOf(warranty.get('statusLabel'));
            this.dealer          = warranty.Dealer__c;
            this.dealerName      = warranty.Dealer__r.Name;
            this.dealerGrade     = warranty.Dealer__r.DealerGrade_Parts__c; // Dealer__r.DealerGrade__c > DealerGrade_Parts__c 로 변경
            this.shippingType    = warranty.ShippingType__c;
            this.shippingTypeLabel = String.valueOf(warranty.get('shippingTypeLabel'));
            this.giQuantity = warranty.ShippingQuantity__c;
            this.requestQuantity = warranty.FM_RequestQuantity__c;
            this.part            = warranty.OrderItem__r.Product__c;
            this.partName        = warranty.OrderItem__r.Product__r.ProductCode;
            this.partDetails     = warranty.OrderItem__r.Product__r.FM_MaterialDetails__c;
            
            this.serviceOrderSeq = warranty.FM_OrderNumber__c;
            this.approvalDate = warranty.FM_ApprovalDate__c;
            this.durationInDays = warranty.OrderItem__r.FM_DaysElapsed__c;
            this.machineName = warranty.OrderItem__r.WorkOrder.Case.Asset.MachineName__c;          //기종
            this.equipment = warranty.OrderItem__r.WorkOrder.Case.Asset.Name;                      //장비번호
            this.customerName = warranty.OrderItem__r.WorkOrder.Account.Name;
            this.shipToId = warranty.OrderItem__r.ShipTo__c;
                
            try {
                //Id 외에 값도 들어감
                Id serviceTerrorityId = Id.valueOf(this.shipToId); 
                this.shipTo = warranty.OrderItem__r.WorkOrder.ServiceTerritory.Name; //warranty.OrderItem__r.WorkOrder.Account.Name;
                this.shipToAddress = warranty.OrderItem__r.WorkOrder.ServiceTerritory.ServiceWorkCenter__r.FM_Address__c;
                this.shipToPhone =   warranty.OrderItem__r.WorkOrder.Worker__r.PhoneNumber__c;

            }catch (Exception e) {
                //고객직송
                this.shipTo = warranty.OrderItem__r.WorkOrder.Account.Name;
                this.shipToAddress = warranty.OrderItem__r.WorkOrder.Account.FM_Address__c;
                this.shipToPhone = warranty.OrderItem__r.WorkOrder.Account.Phone;
            }

            //1: 택배, 2: 화물, 3: 퀵서비스, 4: 방문수령
            if(this.shippingType == '2') {
                //화물일 경우 화물 영업소 정보 필요
                // this.shipToAddress = warranty.OrderItem__r.WorkOrder.ServiceTerritory.ServiceWorkCenter__r.TransportationZoneL__r.Name;
                this.shipToAddress = warranty.Dealer__r.TransportationZoneL__r.Name;
            }

            this.plannedDeliveryDateTime = warranty.DeliveryDateTime__c;
            this.plannedDeliveryDateTimeString = warranty.DeliveryDateTime__c?.format('YYYY-MM-dd HH:mm:ss');
            this.finalCompensationAmount = warranty.getPopulatedFieldsAsMap().containsKey('FinalSettlementAmount__c') ? warranty.FinalSettlementAmount__c : 0;
            
            switch on this.status {
                when '2', '4' {
                    //출고완료 == 확정완료, 정산대상
                    //서비스 오더의 확정일
                    this.confirmDate = warranty.OrderItem__r.WorkOrder.ConfirmedDate__c;
                }
                when '5' {
                    // 정산완료
                    this.confirmDate = warranty.ConfirmDateTime__c;
                }
            }

            if(this.confirmDate != null) this.confirmDateStr = this.confirmDate.format();
        }
    }
    
    
    public enum StatusCode { SUCCESS, ERROR }

    /*
    * @ 생성자 : StatusInfo
    * @ Description : StatusInfo Class
    */
    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        /*
        * @ Method : setCode
        * @ Description : 상태 코드
        */
        public void setCode(Integer code) {
            this.code = code;
        }

        /*
        * @ Method : setMessage
        * @ Description : 메세지
        */
        public void setMessage(String msg) {
            this.msg = msg;
        }

        /*
        * @ Method : setError
        * @ Description : 에러 메세지 및 에로코드
        */
        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }

    public class CustomException extends Exception {}
}