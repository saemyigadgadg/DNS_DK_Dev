/**
 * @description       : (포탈) 부품 > 오더 조회
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 09-02-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-26-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalPartOrderInquiryController {
    public DN_PortalPartOrderInquiryController() {}


    // @description 로그인한 사용자의 정보
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
            String userId = System.UserInfo.getUserId();
            DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
            return dealerInfo;
    }

    
    // @description (포탈) 오더 조회 - 조회
    @AuraEnabled
    public static Map<String, Object> GetPurchaseOrderList(PurchaseOrderTerm poTerm) {
        try {
            Id recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
            
            String userId      = poTerm.dealerInfo.dealerId;
            String userProfile = poTerm.dealerInfo.userProfile;

            // Date sDate = poTerm.startDate == null ? null : Date.valueOf(poTerm.startDate);
            // Date eDate = poTerm.endDate   == null ? null : Date.valueOf(poTerm.endDate).addDays(1);

            Datetime sDate = poTerm.startDate == null ? null : DateTime.newInstance(Date.valueOf(poTerm.startDate), Time.newInstance(0, 0, 0, 0));
            Datetime eDate = poTerm.endDate   == null ? null : DateTime.newInstance(Date.valueOf(poTerm.endDate).addDays(1), Time.newInstance(0, 0, 0, 0));


            // (부품)주문번호 Part Order No
            String po = poTerm != null && poTerm.partOrderNo != null ? poTerm.partOrderNo.trim() : '';

            // 고객주문번호 Customer Order No
            String co = poTerm != null && poTerm.customerOrderNo != null ? poTerm.customerOrderNo.trim() : '';

            // 주문유형 Order Type
            String ot = poTerm.orderType;

            String partOrderQuery = 'SELECT PartOrderNo__c, CustomerOrderNo__c, CreatedDate, TotalItems__c, ItemsAmount__c, CurrencyIsoCode '
                                    +'FROM PurchaseOrder__c '
                                    +'WHERE RecordTypeId = :recordTypeId ';

            // 프로필에 따른 검색 결과
            if (userProfile != 'System Administrator' && userProfile != '시스템 관리자') {
                partOrderQuery += 'AND OwnerId = :userId ';
            }

            // 날짜에 따른 검색 결과
            if(sDate != null && eDate != null) {
                partOrderQuery += 'AND CreatedDate >= : sDate '
                                + 'AND CreatedDate <= : eDate ';
            }
            
            // (부품)주문번호 입력시 검색 조건
            if (po != null && po != '') {
                partOrderQuery += 'AND PartOrderNo__c = :po ';
            }

            // 고객주문번호 입력시 검색 조건
            if (co != null && co != '') {
                partOrderQuery += 'AND CustomerOrderNo__c = :co ';
            }

            // 주문 유형 선택시 검색 조건
            if (ot != null && ot != '' && ot != 'All') {
                partOrderQuery += 'AND OrderType__c = :ot ';
            }
            
            // 주문날짜 정렬 후 (부품) 주문 번호 정렬(DN 요청사항)
            partOrderQuery += 'ORDER BY FM_OrderDate__c DESC, PartOrderNo__c DESC ';
            system.debug('test partOrderQuery >>' + partOrderQuery);
            List<PurchaseOrder__c> poInfo = Database.query(partOrderQuery);

            Map<String, Object> orderList = new Map<String, Object>();

            Decimal totalItemsAmount   = 0;
            Decimal totalItemsQuantity = 0;

            List<OrderInquiryList> oiList = new List<OrderInquiryList>();
            system.debug('test poInfo >> ' + poInfo);
            for(PurchaseOrder__c pco : poInfo) {
                oiList.add(new OrderInquiryList(pco));
            }
            system.debug('test oiList >> ' + oiList);
            orderList.put('oiList', oiList);
            
            for(OrderInquiryList oil : oiList) {
                totalItemsAmount   += (oil.itemsAmount != null)   ? oil.itemsAmount   : 0;
                totalItemsQuantity += (oil.itemsQuantity != null) ? oil.itemsQuantity : 0;
            }
            orderList.put('totalItemsAmount', totalItemsAmount);
            orderList.put('totalItemsQuantity', totalItemsQuantity);

            return orderList;
        } catch (Exception e) {
            system.debug('오더 조회 에러 >>> '+e.getMessage());
            throw new AuraHandledException('오더 조회 에러 >>> '+e.getMessage());
        }
    }

    // 오더 조회시 조건 값
    public class PurchaseOrderTerm {
        @AuraEnabled public DN_PortalLoginUser.DealerInfo  dealerInfo {get; set;}

        @AuraEnabled public String partOrderNo     {get; set;} // (부품)주문번호
        @AuraEnabled public String customerOrderNo {get; set;} // 고객 주문 번호
        @AuraEnabled public String orderType       {get; set;} // 오더 유형
        @AuraEnabled public String startDate       {get; set;} // 검색 시작 날짜
        @AuraEnabled public String endDate         {get; set;} // 검색 종료 날짜
    }

    // 오더 조회 결과에 주문금액 총합 추가
    public class OrderInquiryList {
        @AuraEnabled public String  partOrderNo     {get; set;} // (부품) 주문 번호
        @AuraEnabled public String  customerOrderNo {get; set;} // 고객 주문 번호
        @AuraEnabled public String  orderDate       {get; set;} // 주문일
        @AuraEnabled public Decimal itemsQuantity   {get; set;} // 품목 수량
        @AuraEnabled public Decimal itemsAmount     {get; set;} // 주문 금액
        @AuraEnabled public String  poCurrency      {get; set;} // 통화

        public OrderInquiryList(PurchaseOrder__c pco) {
            this.partOrderNo     = pco.PartOrderNo__c;      // (부품)주문 번호
            this.customerOrderNo = pco.CustomerOrderNo__c;  // 고객 주문 번호
            this.orderDate       = String.valueOf(pco.CreatedDate)
                                    .split(' ')[0]
                                    .replace('-','.');      // 주문일
            this.itemsQuantity   = pco.TotalItems__c;       // 품목 수량
            this.itemsAmount     = pco.ItemsAmount__c*1.1;  // 주문 금액
            this.poCurrency      = pco.CurrencyIsoCode;     // 통화
        }
    }

    @AuraEnabled
    public static PurchaseOrder__c GetDetailInfo(String pon){
        try {
            PurchaseOrder__c orderDetail = [
                SELECT toLabel(OrderType__c), CustomerOrderNo__c, RequestedDeliveryDate__c, ConsolidatedShipping__c, ShippingAddress__c, ZipCode__c, Street__c, ShippingDestination__c, PartManager__c, PartManagerMobilePhone__c, 
                    ShippingTerm__c, ShippingRoute__c, PaymentTerm__c, TransportationTermOne__c, TransportationTermTwo__c, City__c, 
                    ItemsAmount__c, CurrencyIsoCode, 
                    (
                        SELECT ItemNo__c, OrderPartNo__c, SupplyPartNo__c, 
                            PartName__c, Quantity__c, Unit__c, UnitPrice__c, PartAmount__c, CurrencyIsoCode, MachineName__c, EquipmentNo__c, DepartureSite__c
                        FROM PurchaseOrderItems__r
                    )
                FROM PurchaseOrder__c
                WHERE PartOrderNo__c = :pon
                LIMIT 1
            ];

            return orderDetail;
        } catch (Exception e) {
            system.debug('오더 상세 조회(ODI) 에러 >>> '+e.getMessage());
            throw new AuraHandledException('오더 상세 조회(ODI) 에러 >>> '+e.getMessage());
        }
    }

    // 부품 정보 >> 부품 기본 정보 에서 가져옴.
    @AuraEnabled
    public static Map<String, Object> GetBasicPartInfo(DN_PortalLoginUser.DealerInfo dli, String pon){
        try {
            system.debug('test dli >> '+dli);
            system.debug('test pon >> '+pon);
            Map<String, Object> pbiRecord = DN_PortalPartsInfoController.SeachPart(pon, dli);
            system.debug('test pbiRecord >> '+pbiRecord);
            return pbiRecord;
        } catch (Exception e) {
            system.debug('부품 기본 정보 조회 에러 >>> '+e.getMessage());
            throw new AuraHandledException('부품 기본 정보 조회 에러 >>> '+e.getMessage());
        }
    }

    // 부품 정보 >> 부품 기본 정보 의 대체품 정보 에서 가져옴.
    @AuraEnabled
    public static List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST> GetReplacePart(String pon, DN_PortalLoginUser.DealerInfo dli){
        try {
            system.debug('pon >>> ' + pon);
            system.debug('dli >>> ' + dli);
            List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST> replacePart = DN_PortalPartsInfoController.SeachPart2(pon, dli);
            return replacePart;
        } catch (Exception e) {
            system.debug('부품 대체품 조회 에러 >>> '+e.getMessage());
            system.debug('부품 대체품 조회 위치 >>> '+e.getStackTraceString());
            throw new AuraHandledException('부품 대체품 조회 에러 >>> '+e.getMessage());
        }
    }
}