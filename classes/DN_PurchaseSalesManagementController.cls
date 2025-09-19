/**
 * @description       : DN_PurchaseSalesManagementController| 매입매출관리 컨트롤러 
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : kyjung@yangwoodatapotion.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0  01-13-2025   Kyongyun Jung    Initial Version

**/
public with sharing class DN_PurchaseSalesManagementController {
    public DN_PurchaseSalesManagementController() {}

    @AuraEnabled
    public static Map<String, Object> getData(String agencyId, String type, String detailType, Date searchDateStart, Date searchDateEnd) {
        Map<String, Object> result = new Map<String, Object>();
        StatusInfo resultStatus = new StatusInfo();

        try {
            system.debug('Type >> '+type);
          
            String querySelect = ' SELECT ';
            String queryFields ='    Id '
                                +' , DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_CustomerName__c ' //구매/대리점명
                                +' , DealerOrderItem__r.Order__r.FM_CustomerName__c ' //구매/대리점명
                                +' , DealerOrderItem__r.Order__r.FM_ShipToName__c '
                                +' , DealerOrderItem__r.Order__r.Name '
                                +' , DealerOrderItem__r.Order__c '
                                +' , Dealer__r.Name  ' 
                                +' , Type__c  ' 
                                +' , toLabel(Type__c) typeName  ' 
                                +' , RecordType.Name  ' 
                                +' , FM_CreatedDate__c  ' 
                                +' , Quantity__c  ' 
                                +' , DiscountAmount__c  ' 
                                +' , CurrencyIsoCode  ' 
                                +' , SalesOrganization__c  ' 
                                +' , InventoryChange__c ' 
                                +' , Location__r.FM_Loc__c '  //저장위치
                                +///////////////입출고 문서번호 및 참고문헌 관련 필드
                                +' , InventoryNumber__c  ' 
                                +' , DealerPurchaseOrderItem__r.DealerPurchaseOrder__c  ' 
                                +' , DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c  ' 
                                +' , DealerOrderItem__c  ' 
                                +' , ServiceOrderItem__c  ' 
                                +' , Comment__c ' 
                                +' , toLabel(Reason__c) reason '
                                +' , DealerOrderItem__r.FM_OrderNumber__c '
                                +' , DealerOrderItem__r.ReplacingPart__r.ProductCode  '  // 품번
                                +' , DealerOrderItem__r.ReplacingPart__r.FM_MaterialDetails__c  '  //품명
                                +' , Part__r.ProductCode '
                                +' , Part__r.FM_MaterialDetails__c '
                                +' , PurchaseOrderItem__r.PurchaseOrder__c '
                                +' , PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c'
                                +' , ServiceOrderItem__r.WorkOrder.Account.Name '
                                +' , ServiceOrderItem__r.WorkOrder.WorkOrderNumber'
                                +' , ServiceOrderItem__r.WorkOrder.ServiceOrderNumber__c'
                                +' , CreatedDate  ';
            String queryFrom = ' FROM DealerInventoryMovements__c  '
                              +' WHERE Dealer__c =:agencyId '
                              +' AND ( FM_CreatedDate__c >= :searchDateStart AND FM_CreatedDate__c <= :searchDateEnd ) ';
            String queryCondition = '';

            String query = querySelect + queryFields + queryFrom + queryCondition + ' ORDER BY FM_CreatedDate__c ';
            system.debug('query>>>>'+query);
            List<GoodsRIWrapper> recordListSet = new List<GoodsRIWrapper>();
            Set<String> returnId = new Set<String>(); 

            for(DealerInventoryMovements__c giList : Database.query(query)) {
                GoodsRIWrapper wrap = new GoodsRIWrapper();
                if (giList.RecordType.Name == '입고'){  
                    if (giList.InventoryChange__c =='S') { //입고데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = giList.RecordType.Name;
                        wrap.reordDTName     = giList.Type__c  == '3' ? String.valueOf(giList.get('typeName')) : '구매입고';
                        wrap.recordDetail    = giList.Type__c;
                        wrap.inventoryChange = giList.InventoryChange__c;
                        wrap.customerName    = giList.Type__c =='2' ? 'DN Solutions' : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_CustomerName__c : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c;
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c); 
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.Type__c =='2' ? giList.PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c : giList.InventoryNumber__c ; //대리점 구매
                        wrap.searchFileter   = 'GR';
                        wrap.searchDtFileter = giList.InventoryChange__c+(giList?.Type__c =='3' ? '3' :'1');
                        Wrap.oCreatedDate    = giList.CreatedDate;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;
                    } else { //입고취소데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = '출고';
                        wrap.reordDTName     = '입고취소';
                        wrap.recordDetail    = giList.Type__c;
                        wrap.inventoryChange = giList.InventoryChange__c;
                        wrap.customerName    = giList.Type__c =='2' ? 'DN Solutions' : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_CustomerName__c : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c;
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c); 
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.Type__c =='2' ? giList.PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c : giList.InventoryNumber__c ; //대리점 구매
                        wrap.searchFileter   = 'GI';
                        wrap.searchDtFileter = 'HH';
                        Wrap.oCreatedDate    = giList.CreatedDate;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;
                    }
                    
                } else { //(giList.RecordType.Name == '출고')
                    returnId.add(giList.DealerOrderItem__c); // '출고'일 경우만 처리 (반품입고용)
                    if (giList.InventoryChange__c =='H') { //출고데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = giList.RecordType.Name;
                        wrap.reordDTName     = String.valueOf(giList.get('typeName'));
                        wrap.recordDetail    = giList.Type__c;
                        wrap.inventoryChange = giList.InventoryChange__c ;
                        wrap.customerName    = giList.Type__c == 'W' ? giList.ServiceOrderItem__r.WorkOrder.Account.Name : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c;
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c); 
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.Type__c == 'S' ? giList.DealerOrderItem__r.FM_OrderNumber__c : (giList.Type__c == 'O' ?giList.InventoryNumber__c  : giList.ServiceOrderItem__r.WorkOrder.ServiceOrderNumber__c);
                        wrap.searchFileter   = 'GI';
                        wrap.searchDtFileter = giList.InventoryChange__c+giList.Type__c;
                        Wrap.oCreatedDate    = giList.CreatedDate;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;
                    } else { //출고취소데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = '입고';
                        wrap.reordDTName     = '출고취소'; ///출고취소
                        wrap.recordDetail    = giList.Type__c; 
                        wrap.inventoryChange = giList.InventoryChange__c;
                        wrap.customerName    = giList.Type__c == 'W' ? giList.ServiceOrderItem__r.WorkOrder.Account.Name : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c;
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c);
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.InventoryNumber__c;
                        wrap.searchFileter   = 'GR';
                        wrap.searchDtFileter = 'SH';
                        Wrap.oCreatedDate    = giList.CreatedDate;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;
                    }
                }// end of if~else

                recordListSet.add(wrap);
            }// end of for
               
            //if (returnId.size() > 0) {
                Map<String, String> returnOrderQueryMap = returnOrderQuery(returnId,searchDateStart,searchDateEnd,agencyId); 
                String returnOrderQuery = returnOrderQueryMap.get('query');
                Map<String, DealerReturnOrderItem__c> returnOrderMap = new Map<String, DealerReturnOrderItem__c>();
            
                // returnOrderQuery에 맞는 쿼리 실행
                for (DealerReturnOrderItem__c rObj : Database.query(returnOrderQuery)) { 
                    GoodsRIWrapper reWrap = new GoodsRIWrapper();
                    reWrap.Id             = rObj.Id;
                    reWrap.reordType      = '입고';
                    reWrap.reordDTName    = '반품입고';///출고취소
                    reWrap.recordDetail   = 'S';
                    reWrap.inventoryChange= 'S';  //원래 S
                    reWrap.customerName   = setString(rObj.OrderItem__r.Order__r.FM_CustomerName__c) != '' ? rObj.OrderItem__r.Order__r.FM_CustomerName__c  : rObj.Dealer__r.Name;
                    reWrap.giDocNumber    = rObj.ReturnOrderNumber__c;
                    reWrap.createdDate    = rObj.FM_ReturnDate__c;
                    reWrap.quantity       = setNulltoZero(rObj.ReturnQuantity__c); 
                    reWrap.discountAmount = setNulltoZero(rObj.OrderItem__r.DiscountPrice__c) * setNulltoZero(rObj.ReturnQuantity__c);
                    reWrap.currencyValue  = rObj.CurrencyIsoCode;
                    reWrap.refDocNumber   = rObj.FM_Order__c;
                    reWrap.searchFileter  = 'GR';
                    reWrap.searchDtFileter= 'SH';
                    reWrap.oCreatedDate   = rObj.CreatedDate;
                    reWrap.orderId        = rObj.OrderItem__r.Order__c;
                    recordListSet.add(reWrap);
                }
            //}
            system.debug('recordListSet');
            system.debug(recordListSet);
            // recordDetail에 맞는 데이터만 필터링
            List<GoodsRIWrapper> filteredList = new List<GoodsRIWrapper>();
            for (GoodsRIWrapper wrapper : recordListSet) {
                if(type !='All'){
                    if(wrapper.searchFileter == type) {
                        if(detailType !='All'){
                            if(wrapper.searchDtFileter == detailType){
                                if(detailType =='S1'){
                                    if(wrapper.searchDtFileter == 'S1' || wrapper.searchDtFileter == 'S2' ) {
                                        filteredList.add(wrapper);
                                    }
                                } else {
                                    filteredList.add(wrapper);
                                }
                            }
                        } else {
                            filteredList.add(wrapper);
                        } 
                    }
                } else {
                    filteredList.add(wrapper);
                }
            }
            filteredList.sort();
            result.put('recordListSet', filteredList);
                
        } catch (Exception e) {
            System.debug('매입매출 관리 : ' + e.getLineNumber() + ' / ' + e.getMessage());
            String errorMessage = 'Exception : ' + e.getMessage();
            resultStatus.setError(errorMessage, null);
        }

        result.put('status', resultStatus);
        return result;
    }

    //반품 수량 쿼리
    // returnOrderQuery 메서드 수정
    private static Map<String,String> returnOrderQuery(Set<String> returnId,Date searchDateStart, Date searchDateEnd, String agencyId) {
        String querySelect = ' SELECT ';
        String queryFields ='     Id '
                            +'     , SalesOrganization__c '
                            +'     , DistributionChannel__c '
                            +'     , Division__c '
                            +'     , Dealer__c '
                            +'     , Dealer__r.Name '
                            +'     , ReturnOrderNumber__c ' //입출고문서
                            +'     , FM_Order__c ' //참고문헌문서
                            +'     , ReturnQuantity__c '
                            +'     , OrderItem__c '
                            +'     , OrderItem__r.FM_OrderNumber__c ' 
                            +'     , OrderItem__r.OrderItemNumber__c ' 
                            +'     , OrderItem__r.Quantity__c ' // 주문수량
                            +'     , OrderItem__r.Part__c '
                            +'     , OrderItem__r.Part__r.FM_MaterialDetails__c ' // 주문품명
                            +'     , OrderItem__r.Order__r.Customer__c '
                            +'     , OrderItem__r.Order__r.CustomerCode__c '
                            +'     , OrderItem__r.Order__r.FM_CustomerName__c '
                            +'     , OrderItem__r.Order__r.Name '
                            +'     , OrderItem__r.Order__c '
                            +'     , FM_Part__c '
                            +'     , Note__c '
                            +'     , CurrencyIsoCode '
                            +'     , OrderItem__r.Order__r.FM_ShipToName__c '
                            +'     , OrderItem__r.DiscountPrice__c '
                            +'     , CreatedDate  '
                            +'     , FM_ReturnDate__c ';
        String queryFrom  = '  FROM DealerReturnOrderItem__c  '
                            +' WHERE Id != null  AND Delete__c != \'Y\' ' ///AND OrderItem__c IN :returnId 
                            +' AND Dealer__c = :agencyId '
                            +' AND ( FM_ReturnDate__c >= :searchDateStart AND FM_ReturnDate__c <= :searchDateEnd ) ';
                      

        // 쿼리 반환
        return new Map<String,String>{
            'query' => querySelect + queryFields + queryFrom 
        };
    }

    /// 매입매출Wrapper
    public class GoodsRIWrapper implements Comparable {
        @AuraEnabled public String  Id              {get; set;}
        @AuraEnabled public String  reordType       {get; set;} //입출고구분
        @AuraEnabled public String  reordDTName     {get; set;} //입출고세부이름
        @AuraEnabled public String  recordDetail    {get; set;} //입출고세부분류 //type__c
        @AuraEnabled public String  inventoryChange {get; set;} //입고(H:정상,S;취소) 출고(S:정상,H:취소)            
        @AuraEnabled public String  customerName    {get; set;} //구매처/고객사명
        @AuraEnabled public String  giDocNumber     {get; set;} //입출고문서번호
        @AuraEnabled public Date    createdDate     {get; set;} //생성일자
        @AuraEnabled public Decimal quantity           {
            get{
                if(quantity == null) quantity = 0;
                return quantity;
            } 
            set;
        } //입출고수량
        @AuraEnabled public Decimal discountAmount   {get; set;} //금액
        @AuraEnabled public String  currencyValue    {get; set;} //통화
        @AuraEnabled public String  refDocNumber     {get; set;} //참고문서번호   
        @AuraEnabled public String  searchFileter    {get; set;} //데이터검색조건  
        @AuraEnabled public String  searchDtFileter  {get; set;} //데이터검색세부조건
        @AuraEnabled public Datetime oCreatedDate    {get; set;} //오더링
        @AuraEnabled public String   orderId         {get; set;} //주문Id
        @AuraEnabled public String   delerOId        {get; set;} //대리점구매ID
        @AuraEnabled public String   dnsBuyId        {get; set;} //DNS구매ID

        // public GoodsRIWrapper(){}
        // public GoodsRIWrapper(DealerInventoryMovements__c sObj) {
        //     this.Id             = sObj.SalesOrganization__c;
        //     this.reordType      = sObj.RecordType.Name;
        //     this.reordDTName    = sObj.getPopulatedFieldsAsMap().containsKey('Type__c') ? String.valueOf(sObj.get('Type__c')) : '';
        //     this.recordDetail   = sObj.Type__c;
        //     this.customerName   = sObj.Dealer__r.Name;
        //     this.giDocNumber    = sObj.InventoryNumber__c;
        //     this.createdDate    = sObj.FM_CreatedDate__c;
        //     this.quantity       = sObj.Quantity__c;
        //     this.discountAmount = sObj?.DiscountAmount__c == null? 0 : sObj.DiscountAmount__c;
        //     this.currencyValue  = sObj.CurrencyIsoCode;
        //     this.refDocNumber   = sObj.InventoryNumber__c;
        //     this.inventoryChange= sObj.InventoryChange__c;
        //     this.searchFileter  = sObj.RecordType.Name =='입고' ? 'GR' : 'GI';
        //     this.searchDtFileter= sObj.InventoryChange__c + sObj.Type__c;
        //     this.oCreatedDate   = sObj.CreatedDate;
        //     this.orderId        = sObj.DealerOrderItem__r.Order__c;
        //     this.delerOId       = sObj.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
        //     this.dnsBuyId       = sObj.PurchaseOrderItem__r.PurchaseOrder__c;
        // }

        public Integer compareTo(Object cObj) {
            GoodsRIWrapper comGoods = (GoodsRIWrapper)cObj;
            
            if (oCreatedDate < comGoods.oCreatedDate) return 1;
            if (oCreatedDate > comGoods.oCreatedDate) return -1;

            // 모든 값이 같다면 0 반환
            return 0;
        }

    }
    public enum StatusCode { SUCCESS, ERROR }

    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        public void setCode(Integer code) {
            this.code = code;
        }

        public void setMessage(String msg) {
            this.msg = msg;
        }

        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }
    private static Decimal setNulltoZero(Decimal num) {
        return (num == null) ? 0 : num;
    }
    private static String setString(String str) {
        return str != null ? str : '';
    }

}