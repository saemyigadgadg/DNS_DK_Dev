/**
 * @description       : (포탈) 부품주문 >> 오더 상태
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-17-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-22-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalPartsOrderStatusController {
    public DN_PortalPartsOrderStatusController() {}

    // 오더 상태 - 로그인 사용자 정보 확인
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
            String userId = System.UserInfo.getUserId();
            return DN_PortalLoginUser.GetUserInfo(userId);
    } 
    
    // 오더 상태 - 검색(조회)
    @AuraEnabled
    public static List<PurchaseOrder__c> GetOrderStatus(OrderStatusTerm osi){
        try {
            String recordTypeName = 'Order';
            Id recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();

            String userId = osi.dealerInfo.dealerId;
            String userProfile = osi.dealerInfo.userProfile;

            Date sDate = Date.valueOf(osi.startDate);
            Date eDate = Date.valueOf(osi.endDate).addDays(1);

            // 배송 상태
            String ss = osi.shippingState;

            // (부품)주문번호 Part Order No
            String po = osi != null && osi.partOrderNo != null ? osi.partOrderNo.trim() : '';

            // 고객주문번호 Customer Order No
            String co = osi != null && osi.customerOrderNo != null ? osi.customerOrderNo.trim() : '';

            // 부품번호 Part No
            String pn = osi != null && osi.partNo != null ? osi.partNo.trim() : '';

            // 주문유형 Order Type
            String ot = osi.orderType;
            System.debug('들어온 ot :: ' + ot);

            String partOrderQuery = 'SELECT Id, OwnerId, RecordTypeId, CurrencyIsoCode, CreatedById, CreatedDate, ItemsAmount__c, TotalItems__c, '
                                    +'toLabel(OrderType__c), CustomerOrderNo__c, ConsolidatedShipping__c, ShippingAddress__c, PartManager__c, PartManagerMobilePhone__c, '
                                    +'ShippingTerm__c, PaymentTerm__c, TransportationTermOne__c, TransportationTermTwo__c, RequestedDeliveryDate__c, '
                                    +'Buyer__c, buyerNo__c, Supplier__c, Currency__c, PartOrderNo__c, '
                                    +'ShippingDestination__c, '
                                    +'BLOCK__c, OrderQty__c, ConfirmedQty__c, PackingQty__c, DeliveryQty__c, CarryoverQty__c, ' // 오더 상태용 조건 추가
                                    +'('
                                    +'SELECT Id, PartNo__c, PurchaseOrder__c, Part__c, '
                                    +'ItemNo__c, ItemSpr__c, Invoice__c, OrderPartNo__c, Quantity__c, Unit__c, UnitPrice__c, Currency__c, '
                                    +'PartName__c, PartAmount__c, MachineName__c, EquipmentNo__c, SupplyPartNo__c, ' 
                                    +'SalesUnit__c, AvailableStock__c, TWP__c, Bulletin__c, Note__c, Urgency__c, ReceivedStatus__c, NetValue__c, '
                                    +'ConfirmedQty__c, PenddingQty__c, CompletedQty__c, ExpectedSupplyDate__c, RevisedSupplyDate__c, ShipmentDate__c, DepartureSite__c, '
                                    +'ComplaintReason1__c, ComplaintReason2__c, Description__c, OriginDocDate__c '
                                    +'FROM PurchaseOrderItems__r '
                                    + ') '
                                    +'FROM PurchaseOrder__c '
                                    +'WHERE RecordTypeId = :recordTypeId '
                                    +'AND CreatedDate >= : sDate '
                                    +'AND CreatedDate <= : eDate ';

            // 프로필에 따른 검색 결과
            if (userProfile != 'System Administrator' && userProfile != '시스템 관리자') {
                partOrderQuery += 'AND OwnerId = :userId ';
            }

            // 공급 품번 일치 여부
            if(pn != null && pn != '') {
                partOrderQuery += 'AND Id IN ('
                                + 'SELECT PurchaseOrder__c '
                                + 'FROM PurchaseOrderItems__c '
                                + 'WHERE SupplyPartNo__c =:pn) ';
            }
            
            // (부품)주문번호 입력시 검색 조건
            if (po != null && po != '') {
                partOrderQuery += 'AND PartOrderNo__c = :po ';
            }

            // 주문 유형 선택시 검색 조건
            if (ot != null && ot != '' && ot != 'All') {
                partOrderQuery += 'AND OrderType__c = :ot ';
            }

            // 고객주문번호 입력시 검색 조건
            if (co != null && co != '') {
                partOrderQuery += 'AND CustomerOrderNo__c = :co ';
            }

            if (ss == 'Shipped') {
                partOrderQuery += 'AND DeliveryQty__c > 0 ';
            } else if(ss == 'Carryover') {
                partOrderQuery += 'AND CarryoverQty__c > 0 ';
            }
            
            partOrderQuery += 'ORDER BY PartOrderNo__c ASC ';

            List<PurchaseOrder__c> poInfo = Database.query(partOrderQuery);

            return poInfo;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    // 오더상태 >> 납기조회 모달 >> 레코드 업데이트
    @AuraEnabled
    public static List<PurchaseOrderItems__c> GetPoiList(String pon, List<Map<String, Object>> poi) {
        try {
            // 1. 부모 PurchaseOrder__c Id 조회
            Id poId = [
                SELECT Id 
                FROM PurchaseOrder__c 
                WHERE PartOrderNo__c = :pon
                LIMIT 1
            ].Id;

            // 2. 기존 데이터 조회
            List<PurchaseOrderItems__c> poiList = [
                SELECT Id, ItemNo__c
                FROM PurchaseOrderItems__c
                WHERE PurchaseOrder__c = :poId
            ];

            // 3. ItemNo__c 기준으로 기존 레코드를 Map에 저장 (마지막 값 덮어쓰기 위해)
            Map<String, PurchaseOrderItems__c> itemMap = new Map<String, PurchaseOrderItems__c>();
            
            for (PurchaseOrderItems__c rePo : poiList) {
                itemMap.put(rePo.ItemNo__c, rePo);
            }

            // 4. 외부 데이터 ItemNo Set
            Set<String> incomingItemNoSet = new Set<String>();
            for (Map<String, Object> poItem : poi) {
                incomingItemNoSet.add(String.valueOf(poItem.get('itemNo')));
            }

            // 5. 삭제 대상 확인 (DB에는 있지만 외부에는 없는 경우)
            List<PurchaseOrderItems__c> deletePoiList = new List<PurchaseOrderItems__c>();
            for (PurchaseOrderItems__c rePo : poiList) {
                if (!incomingItemNoSet.contains(rePo.ItemNo__c)) {
                    deletePoiList.add(rePo);
                    itemMap.remove(rePo.ItemNo__c); // Map에서도 제거
                }
            }

            if (!deletePoiList.isEmpty()) {
                delete deletePoiList;
            }

            // 4. poi 데이터 순회
            for (Map<String, Object> poItem : poi) {
                String itemNo = String.valueOf(poItem.get('itemNo'));

                PurchaseOrderItems__c target;
                if (itemMap.containsKey(itemNo)) {
                    target = itemMap.get(itemNo);
                } else {
                    String supplyPartNo = (String)poItem.get('supplyPartNo');
                    List<Product2> getProducts = [SELECT Id, ProductCode, MaterialDetailsKO__c, Unit__c FROM Product2 WHERE ProductCode =:supplyPartNo];
                    if (getProducts.size() > 0) {
                        target = new PurchaseOrderItems__c(PurchaseOrder__c = poId, ItemNo__c = itemNo, Currency__c = 'KRW', 
                        OrderPartId__c = getProducts[0].Id, SupplyPartId__c = getProducts[0].Id, OrderPartNo__c = getProducts[0].ProductCode, 
                        SupplyPartNo__c = getProducts[0].ProductCode, PartName__c = getProducts[0].MaterialDetailsKO__c, Unit__c = getProducts[0].Unit__c);
                    }
                }

                // 필드 매핑 (마지막 항목이 최종 덮어씀)
                target.Quantity__c           = Integer.valueOf(poItem.get('orderQty'));
                target.ConfirmedQty__c       = Integer.valueOf(poItem.get('confirmQty'));
                target.PackingCompleted__c   = Integer.valueOf(poItem.get('packingQty'));
                target.PenddingQty__c        = Integer.valueOf(poItem.get('stayQty'));
                target.CompletedQty__c       = Integer.valueOf(poItem.get('completeQty'));
                target.Urgency__c            = Boolean.valueOf(poItem.get('urgency'));
                target.UnitPrice__c          = Integer.valueOf(poItem.get('netPrice'));
                target.Currency__c           = String.valueOf(poItem.get('netCurrency'));
                target.ExpectedSupplyDate__c = poItem.get('estimatedSupplyDate') != null 
                    ? Date.valueOf(String.valueOf(poItem.get('estimatedSupplyDate')).replace('.', '-')) 
                    : null;
                target.RevisedSupplyDate__c  = poItem.get('changeSupplyDate') != null    
                    ? Date.valueOf(String.valueOf(poItem.get('changeSupplyDate')).replace('.', '-'))    
                    : null;
                target.ShipmentDate__c       = poItem.get('shippingDate') != null        
                    ? Date.valueOf(String.valueOf(poItem.get('shippingDate')).replace('.', '-'))        
                    : null;
                target.DepartureSite__c      = String.valueOf(poItem.get('shippingSpot'));

                // Map에 덮어쓰기 (중복 itemNo의 경우 마지막 데이터가 저장됨)
                itemMap.put(itemNo, target);
            }

            // 5. upsert 실행 (Map 값만 리스트로 변환)
            upsert itemMap.values();

            return new List<PurchaseOrderItems__c>(itemMap.values());

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    // 오더상태 >> 납기조회 모달 >> 레코드 업데이트
    @AuraEnabled
    public static List<OrderStatusDetail> GetOrderStatusDetail(List<String> pon, String sDate, String eDate, DN_PortalLoginUser.DealerInfo dli){
        try {
            IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res result = InterFace_Parts_013(pon, sDate, eDate, dli);
            List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL> t_List = (List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL>) result.T_DETAIL;
            List<OrderStatusDetail> d_List = new List<OrderStatusDetail>();
            for(IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL td : t_List) {
                OrderStatusDetail osd = new OrderStatusDetail(pon, td);
                d_List.add(osd);
            }
            return d_List;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 오더상태 >> 납기조회 모달 >> 레코드 업데이트
    @AuraEnabled
    public static List<PurchaseOrderItems__c> ChangeUrgency(String pon, List<PurchaseOrderItems__c> poi, DN_PortalLoginUser.DealerInfo dli) {
        try {
            IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res result = InterFace_Parts_026(pon, poi, dli);
            if (poi != null && !poi.isEmpty()) update poi;
            return poi;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* ***************************************************************************************************************************************************** */
    /* ***************************************************************************************************************************************************** */

    // 오더 상태 >> 납기 조회
    private static IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res InterFace_Parts_013 (List<String> pon, String sDate, String eDate, DN_PortalLoginUser.DealerInfo dli) {
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req();

        req.I_FDATE     = sDate;
        req.I_TDATE     = eDate;
        req.I_DROP      = '0';
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_I_USERINFO();

        I_USERINFO.KUNNR        = dli.dealerCode;
        I_USERINFO.VKORG        = dli.salesOrganization;
        I_USERINFO.VTWEG        = dli.distributionChannel;
        I_USERINFO.SPART        = dli.division;
        I_USERINFO.LAND1        = dli.country;

        req.I_USERINFO          = I_USERINFO;

        List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN> LT_VBELN_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN>();
        for(String item : pon){
            IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN LT_VBELN = new IF_ERP_Parts_Order_Classes.IF_PARTS_013_Req_LT_VBELN();
            LT_VBELN.VBELN = item;
            LT_VBELN_List.add(LT_VBELN);
        }
        req.LT_VBELN = LT_VBELN_List;

        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res result = instance.IF_PARTS_013(req);
        return result;
    }

    // 오더 상태 >> 납기 조회 - 긴급 변경 
    private static IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res InterFace_Parts_026(String pon, List<PurchaseOrderItems__c> poi, DN_PortalLoginUser.DealerInfo dli) {
        try{
            IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req req = new IF_ERP_Parts_Order_Classes.IF_Parts_026_Req();

            system.debug('pon >> ' +pon);
            system.debug('poi >> ' +poi);
            system.debug('dli >> ' +dli);
            
            req.I_VBELN = pon;                       // 주문번호
            req.I_VKORG = dli.salesOrganization;     // 딜러 so
            req.I_VTWEG = dli.distributionChannel;   // 딜러 dc
            req.I_SPART = dli.division;              // 딜러 di
            req.I_KUNNR = dli.dealerCode.leftPad(10, '0'); // 딜러 코드 10자리 0 채우기

            List<IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req_IT_ITEM> IT_ITEM_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req_IT_ITEM>();
            for(PurchaseOrderItems__c pi : poi) {
                IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req_IT_ITEM item = new IF_ERP_Parts_Order_Classes.IF_PARTS_026_Req_IT_ITEM();
                item.POSNR = pi.ItemNo__c;  // 항목
                // item.ETENR = poi.ItemSpr__c; 
                item.ETENR = '001';
                item.EMERC = pi.Urgency__c == true ? 'T' : ''; // T면 긴급, ''면 긴급 해제
                IT_ITEM_List.add(item);
            }
            req.IT_ITEM = IT_ITEM_List;

            IF_ERP_Parts_Order method = new IF_ERP_Parts_Order();
            IF_ERP_Parts_Order_Classes.IF_PARTS_026_Res result = method.IF_PARTS_026(req);

            return result;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* ***************************************************************************************************************************************************** */
    /* ***************************************************************************************************************************************************** */
    /* ***************************************************************************************************************************************************** */
    public class OrderStatusTerm {
        @AuraEnabled public String partOrderNo      {get; set;}
        @AuraEnabled public String customerOrderNo  {get; set;}
        @AuraEnabled public String orderType        {get; set;}
        @AuraEnabled public String startDate        {get; set;}
        @AuraEnabled public String endDate          {get; set;}
        @AuraEnabled public String partNo           {get; set;}
        @AuraEnabled public String shippingState    {get; set;}
        @AuraEnabled public DN_PortalLoginUser.DealerInfo dealerInfo   {get; set;}
    }

    public class OrderStatusDetail {
        @AuraEnabled public String partOrderNo          {get; set;} // (부품)주문번호
        @AuraEnabled public String customerOrderNo      {get; set;} // 고객주문번호
        @AuraEnabled public String orderDate            {get; set;} // 주문날짜

        @AuraEnabled public String itemNo               {get; set;} // 품목
        // @AuraEnabled public String itemSpr              {get; set;} // 부분 품목
        @AuraEnabled public String supplyPartNo         {get; set;} // 공급품번
        @AuraEnabled public String partName             {get; set;} // 품명
        @AuraEnabled public String urgency              {get; set;} // 긴급도
        @AuraEnabled public String orderQty             {get; set;} // 수량-주문
        @AuraEnabled public String confirmQty           {get; set;} // 수량-확정
        @AuraEnabled public String stayQty              {get; set;} // 수량-대기
        @AuraEnabled public String packingQty           {get; set;} // 수량-포장 (화면에 안 나오는 필드)
        @AuraEnabled public String completeQty          {get; set;} // 수량-완료
        @AuraEnabled public String estimatedSupplyDate  {get; set;} // 예상공급일
        @AuraEnabled public String changeSupplyDate     {get; set;} // 변경 공급 예정일
        @AuraEnabled public String shippingDate         {get; set;} // 출고일
        @AuraEnabled public String shippingSpot         {get; set;} // 발송지점
        @AuraEnabled public String netPrice             {get; set;} // 단가
        @AuraEnabled public String netCurrency          {get; set;} // 통화

        public OrderStatusDetail(List<String> pon, IF_ERP_Parts_Order_Classes.IF_PARTS_013_Res_T_DETAIL td) {
            this.partOrderNo          = pon[0];   // (부품)주문번호
            this.customerOrderNo      = td.BSTKD; // 고객주문번호
            this.orderDate            = td.ERDAT.replace('-','.'); // 주문날짜

            this.itemNo               = td.POSNR;    // 품목
            // this.itemSpr              = td.ETENR;    // 품목 스페어
            this.supplyPartNo         = td.MATNR_SH; // 공급품번
            this.partName             = td.MAKTX;    // 품명
            this.urgency              = td.EMERC == 'T' ? 'true' : 'false';         // 긴급도
            this.orderQty             = String.valueOf(td.SO_QTY).split('\\.')[0];  // 수량-주문 0.000
            this.confirmQty           = String.valueOf(td.CFM_QTY).split('\\.')[0]; // 수량-확정
            this.stayQty              = String.valueOf(td.STB_QTY).split('\\.')[0]; // 수량-대기 >> 오더가 생성되는 순간 대기로 감.
            this.packingQty           = String.valueOf(td.PI_QTY).split('\\.')[0];  // 수량-포장 >> 포장 필드지만 실질 배송이 된 상태가 되야 업데이트 되는 듯
            this.completeQty          = String.valueOf(td.SH_QTY).split('\\.')[0];  // 수량-완료
            this.estimatedSupplyDate  = td.FST_ETD.startsWith('0') ? null : td.FST_ETD.replace('-','.'); // 예상공급일
            this.changeSupplyDate     = td.LST_ETD.startsWith('0') ? null : td.LST_ETD.replace('-','.'); // 변경 공급 예정일
            this.shippingDate         = td.DODAT.startsWith('0')   ? null : td.DODAT.replace('-','.');   // 출고일
            this.shippingSpot         = td.VTEXT;    // 발송지점
            this.netPrice             = td.NETPR;    // 단가
            this.netCurrency          = td.WAERK;    // 통화
        }
        public OrderStatusDetail() {}
    }
}