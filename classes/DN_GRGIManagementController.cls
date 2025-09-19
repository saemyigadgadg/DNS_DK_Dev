/**
 * @description       : DN_GRGIManagementController | 입출고
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 01-14-2025
 * @last modified by  : kyjung@yangwoodatapotion.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0  01-14-2025   Kyongyun Jung    Initial Version

**/
public with sharing class DN_GRGIManagementController {

    @AuraEnabled
    public static Map<String, Object> getSearchData( String agencyId
                                                    ,String type
                                                    ,String detailType
                                                    ,Date searchDateStart
                                                    ,Date searchDateEnd
                                                    ,String productCode
                                                    ,String customerId
                                                    ,String productLabel
                                                    ) 
    {
        Map<String, Object> result = new Map<String, Object>();
        StatusInfo resultStatus = new StatusInfo();
        /*구매처/고객사명	ZSMT6010-NAME1 (대리점구매) DealerPurchaseOrder__c
                          Company 1800 Desc. (DNS 구매) DN Solustion
                          ZSST8050-NAME1 (주문서 출고, 주문 반품) DealerOrder__r.
                          서비스오더의 고객명 (무상 출고)" //  나머지 모두..inventoryManage
        문서번호	       ZSLT0320-IMPT_NO    InventoryNumber
                          ZSLT0330-EXPT_NO
                            ZSST8080-RTN_NO
        생성일자	        "ZSLT0320-ERDAT
                            ZSLT0330-ERDAT
                            ZSST8080-ERDAT
        품번	            ZSLT0320-MATNR
                            ZSLT0330-MATNR
                            ZSST8080-MATNR
        품명	            Material Master 의 품명
        수량	            ZSLT0320-MENGE
                            ZSLT0330-MENGE
                            ZSST8080-MENGE" //DealerReturnOrder__c
        저장위치	        ZSLT0320-LOC
                            ZSLT0330-LOC
                            ZSST8060-LOC (주문 반품)"
        금액	             ZSLT0320-DMBTR
                            ZSLT0330-DMBTR
                            ZSST8060-DISPR * ZSST8080-MENGE (주문 반품)"DealerOrderItem__c.qty-반품수량
        통화                ZSLT0320-WAERS
                            ZSLT0330-WAERS
                            ZSST8060-WAERS (주문 반품)"
        참고문서번호	"ZSLT0320-EBELN (대리점구매) VBELN DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c
                        ZSLT0320-VBELN (DNS구매)  PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c  
                        ZSLT0320-IMPT_NO(기타입고) InventoryNumber__c
                        ZSLT0330-VBELN (주문서 출고)  DealerOrderItem__r.FM_OrderNumber__c
                        ZSLT0330-AUFNR (무상 출고) FM_ServiceOrder__c -> WorkOrder.ServiceOrderNumber__c
                        ZSLT0330-EXPT_NO(기타 출고) InventoryNumber__c
                        ZSST8080-VBELN (주문 반품)" FM_Order__c

        기타	        "ZSLT0320-NOTE
                        ZSLT0330-NOTE
                        ZSST8080-NOTE"
        배송처	         각 참고문서에 해당하는 주소
                        대리점구매 :DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_ShipToName__c
                        DNS구매 : DealerOrderItem__r.Order__r.FM_ShipToName__c
                        기타입고 : DealerOrderItem__r.Order__r.FM_ShipToName__c
                        주문서 출고 : DealerOrderItem__r.Order__r.FM_ShipToName__c
                        무상 출고 : ServiceOrderItem__r.ShipTo__c
                        기타 출고 : // 딜러반품

        */ 
        try {

            Schema.DescribeSObjectResult r = ServiceTerritory.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();

            String querySelect = ' SELECT ';
            String queryFields ='    Id '
                                +' , DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_CustomerName__c ' //구매/대리점명
                                +' , DealerOrderItem__r.Order__r.FM_CustomerName__c ' //구매/대리점명
                                +' , DealerOrderItem__r.Order__r.FM_ShipToName__c '
                                +' , DealerOrderItem__r.Order__r.Name '
                                +' , DealerOrderItem__r.Order__c '
                                +' , Dealer__r.Name  ' 
                                +' , ServiceOrderItem__r.WorkOrder.Account.Name	' //무상출고 고객사명
                                +' , Type__c  ' 
                                +' , toLabel(Type__c) typeName  ' 
                                +' , RecordType.DeveloperName ' 
                                +' , RecordType.Name ' 
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
                                +' , PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c '
                                +' , ServiceOrderItem__r.WorkOrder.ServiceOrderNumber__c '
                                +' , ServiceOrderItem__r.WorkOrder.WorkOrderNumber '
                                +' , ServiceOrderItem__r.ShipTo__c '
                                +' , DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_ShipToName__c '
                                +' , CreatedDate  ';
            String queryFrom = ' FROM DealerInventoryMovements__c  '
                             +' WHERE Dealer__c =:agencyId '
                             +' AND ( FM_CreatedDate__c >= :searchDateStart AND FM_CreatedDate__c <= :searchDateEnd ) ';
            String queryCondition = '';
            System.debug(productCode + ' ::: productCode');
            System.debug(productLabel + ' ::: productLabel');
            System.debug(customerId + ' :: customerId');
            System.debug(agencyId+ ' :: agencyId');
            if(String.isNotBlank(productCode)) {
                set<String> partCodeSet = new set<String>(productCode.split(','));
                queryCondition += 'AND Part__r.Id IN:partCodeSet ';
            }
            else if(String.isNotBlank(productLabel)) {
                System.debug('productLabel : '+productLabel);
                Set<String> partLabelSet = new set<String>();
                queryCondition += 'AND Part__r.ProductCode IN:partLabelSet ';
            }


            if(String.isNotBlank(customerId)) {
                if(customerId.lastIndexOf('9999999999') == -1) {
                    queryCondition += 'AND DealerOrderItem__r.Order__r.Customer__c =:customerId ';
                } else {
                    queryCondition += 'AND DealerOrderItem__r.Order__r.CustomerCode__c =:customerId ';
                }
            }

            String query = querySelect + queryFields + queryFrom + queryCondition + ' ORDER BY FM_CreatedDate__c DESC';
            system.debug('query>>>>'+query);
            List<GRGIWrapper> recordListSet = new List<GRGIWrapper>();
            Set<String> returnId = new Set<String>(); 
            Set<String> serviceTId = new Set<String>(); 

            for(DealerInventoryMovements__c giList : Database.query(query)) {
                GRGIWrapper wrap = new GRGIWrapper();
                if (giList.RecordType.DeveloperName == 'GoodsReceipt'){  
                    if (giList.InventoryChange__c =='S') { //입고데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = giList.RecordType.Name; 
                        wrap.recordDetail    = giList.Type__c;              
                        wrap.inventoryChange = giList.InventoryChange__c;   
                        wrap.customerName    = giList.Type__c =='2' ? 'DN Solutions' : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_CustomerName__c : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c; //!= '' ? giList.DealerOrderItem__r.Order__r.FM_CustomerName__c : giList.Dealer__r.Name; //구매처/
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.productCode     = giList.Part__r.ProductCode;//DealerOrderItem__r.ReplacingPart__r.ProductCode;
                        wrap.productName     = giList.Part__r.FM_MaterialDetails__c;//DealerOrderItem__r.ReplacingPart__r.FM_MaterialDetails__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c); 
                        wrap.location        = giList.Location__r.FM_Loc__c;
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.Type__c =='2' ? giList.PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c : giList.InventoryNumber__c ; //대리점 구매
                        wrap.comment         = giList.Comment__c;
                        wrap.shipToName      = giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_ShipToName__c : giList.DealerOrderItem__r.Order__r.FM_ShipToName__c;
                        wrap.searchFileter   = 'GR';
                        wrap.searchDtFileter = giList.InventoryChange__c+giList.Type__c;
                        wrap.reason          = setString(String.valueOf(giList.get('reason')));
                        wrap.reordDTName     = setDetailName(wrap.searchDtFileter, giList.Type__c =='2' ? '' : wrap.reason );
                        wrap.orderName       = giList.DealerOrderItem__r.Order__r.Name;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.dCreatedDate    = giList.CreatedDate;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;

                    } else { //입고취소데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = '출고';
                        wrap.recordDetail    = giList.Type__c;              
                        wrap.inventoryChange = giList.InventoryChange__c;   
                        wrap.customerName    = giList.Type__c =='2' ? 'DN Solutions' : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_CustomerName__c : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c;// != '' ?  giList.DealerOrderItem__r.Order__r.FM_CustomerName__c : giList.Dealer__r.Name; //구매처/
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.productCode     = giList.Part__r.ProductCode;
                        wrap.productName     = giList.Part__r.FM_MaterialDetails__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c); 
                        wrap.location        = giList.Location__r.FM_Loc__c;
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.Type__c =='2' ? giList.PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c : giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c : giList.InventoryNumber__c ; //대리점 구매
                        wrap.comment         = giList.Comment__c;
                        wrap.shipToName      = giList.Type__c =='1' ? giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.FM_ShipToName__c : giList.DealerOrderItem__r.Order__r.FM_ShipToName__c;
                        wrap.searchFileter   = 'GI';
                        wrap.searchDtFileter = giList.InventoryChange__c+giList.Type__c; 
                        wrap.reason          = setString(String.valueOf(giList.get('reason')));
                        wrap.reordDTName     = setDetailName(wrap.searchDtFileter, giList.Type__c =='2' ? '' : wrap.reason );
                        wrap.orderName       = giList.DealerOrderItem__r.Order__r.Name;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.dCreatedDate    = giList.CreatedDate;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;
                    }
                    
                } else { //(giList.RecordType.DeveloperName =='GoodsIssue 출고')
                    returnId.add(giList.DealerOrderItem__c); // '출고'일 경우만 처리 (반품입고용)
                    if (giList.InventoryChange__c =='H') { //출고데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = giList.RecordType.Name; //입출고 구분
                        wrap.recordDetail    = giList.Type__c;              
                        wrap.inventoryChange = giList.InventoryChange__c;  
                        wrap.customerName    = giList.Type__c == 'W' ? giList.ServiceOrderItem__r.WorkOrder.Account.Name : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c;// != '' ?  giList.DealerOrderItem__r.Order__r.FM_CustomerName__c :giList.Dealer__r.Name;
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.productCode     = giList.Part__r.ProductCode;
                        wrap.productName     = giList.Part__r.FM_MaterialDetails__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c); 
                        wrap.location        = giList.Location__r.FM_Loc__c;
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.Type__c == 'S' ? giList.DealerOrderItem__r.FM_OrderNumber__c : (giList.Type__c == 'O' ?giList.InventoryNumber__c  : giList.ServiceOrderItem__r.WorkOrder.ServiceOrderNumber__c);
                        wrap.comment         = giList.Comment__c;
                        wrap.shipToName      = giList.Type__c == 'W' ? giList.ServiceOrderItem__r.ShipTo__c :giList.DealerOrderItem__r.Order__r.FM_ShipToName__c;
                        wrap.searchFileter   = 'GI';
                        wrap.searchDtFileter = giList.InventoryChange__c+giList.Type__c;
                        wrap.reason          = setString(String.valueOf(giList.get('reason')));
                        wrap.reordDTName     = setDetailName(wrap.searchDtFileter, giList.Type__c =='2' ? '' :wrap.reason );
                        wrap.dCreatedDate    = giList.CreatedDate;
                        wrap.orderName       = giList.DealerOrderItem__r.Order__r.Name;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;

                        if(giList.Type__c == 'W'){
                            //TEXT필드지만 고객직송이 아니면 SerivceTerritory Id로 들어가서 해당 ID로 데이터 Update해야함
                            serviceTId.add(giList.ServiceOrderItem__r.ShipTo__c); 
                        }
                    } else { //출고취소데이터
                        wrap.Id              = giList.Id;
                        wrap.reordType       = '입고';
                        wrap.recordDetail    = giList.Type__c;              
                        wrap.inventoryChange = giList.InventoryChange__c;  
                        wrap.customerName    = giList.Type__c == 'W' ? giList.ServiceOrderItem__r.WorkOrder.Account.Name : giList.DealerOrderItem__r.Order__r.FM_CustomerName__c;// != '' ?  giList.DealerOrderItem__r.Order__r.FM_CustomerName__c : giList.Dealer__r.Name;
                        wrap.giDocNumber     = giList.InventoryNumber__c;
                        wrap.createdDate     = giList.FM_CreatedDate__c;
                        wrap.productCode     = giList.Part__r.ProductCode;
                        wrap.productName     = giList.Part__r.FM_MaterialDetails__c;
                        wrap.quantity        = setNulltoZero(giList.Quantity__c); 
                        wrap.location        = giList.Location__r.FM_Loc__c;
                        wrap.discountAmount  = setNulltoZero(giList.DiscountAmount__c);
                        wrap.currencyValue   = giList.CurrencyIsoCode;
                        wrap.refDocNumber    = giList.Type__c == 'W' ? giList.ServiceOrderItem__r.WorkOrder.ServiceOrderNumber__c : giList.InventoryNumber__c;
                        wrap.comment         = giList.Comment__c;
                        wrap.shipToName      = giList.Type__c == 'W' ? giList.ServiceOrderItem__r.ShipTo__c : giList.DealerOrderItem__r.Order__r.FM_ShipToName__c;
                        wrap.searchFileter   = 'GR';
                        wrap.searchDtFileter = giList.InventoryChange__c+giList.Type__c;
                        wrap.reason          = setString(String.valueOf(giList.get('reason')));
                        wrap.reordDTName     = setDetailName(wrap.searchDtFileter, giList.Type__c =='2' ? '' :wrap.reason );
                        wrap.dCreatedDate    = giList.CreatedDate;
                        wrap.orderName       = giList.DealerOrderItem__r.Order__r.Name;
                        wrap.orderId         = giList.DealerOrderItem__r.Order__c;
                        wrap.delerOId        = giList.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c;
                        wrap.dnsBuyId        = giList.PurchaseOrderItem__r.PurchaseOrder__c;
                    }
                }// end of if~else

                recordListSet.add(wrap);
                System.debug('returnId ++++++ ' + returnId.size());
            }// end of for
               
            // if (returnId.size() > 0) {
                Map<String, String> returnOrderQueryMap = returnOrderQuery(returnId,agencyId,searchDateStart,searchDateEnd,productCode,customerId,productLabel); 
                String returnOrderQuery = returnOrderQueryMap.get('query');
                System.debug(returnOrderQuery + ' :: returnOrderQuery');
                Map<String, DealerReturnOrderItem__c> returnOrderMap = new Map<String, DealerReturnOrderItem__c>();
                System.debug('returnOrderQuery ++++++ ' +Database.query(returnOrderQuery).size());
                // returnOrderQuery에 맞는 쿼리 실행
                for (DealerReturnOrderItem__c rObj : Database.query(returnOrderQuery)) { 
                    GRGIWrapper reWrap = new GRGIWrapper();
                    reWrap.Id             = rObj.Id;
                    reWrap.reordType      = '입고';
                    reWrap.recordDetail   = 'S';     
                    reWrap.inventoryChange= 'S';  
                    reWrap.customerName   = setString(rObj.OrderItem__r.Order__r.FM_CustomerName__c) != '' ? rObj.OrderItem__r.Order__r.FM_CustomerName__c  : rObj.Dealer__r.Name;
                    reWrap.giDocNumber    = rObj.ReturnOrderNumber__c;
                    reWrap.createdDate    = rObj.FM_ReturnDate__c;
                    reWrap.productCode    = rObj.FM_Part__c;
                    reWrap.productName    = rObj.OrderItem__r.Part__r.FM_MaterialDetails__c ;
                    reWrap.quantity       = setNulltoZero(rObj.ReturnQuantity__c); 
                    reWrap.location       = '';
                    reWrap.discountAmount = rObj.OrderItem__r.DiscountPrice__c * rObj.ReturnQuantity__c;
                    reWrap.currencyValue  = rObj.CurrencyIsoCode;
                    reWrap.refDocNumber   = rObj.FM_Order__c;
                    reWrap.comment        = rObj.Note__c;
                    reWrap.shipToName     = rObj.OrderItem__r.Order__r.FM_ShipToName__c;
                    reWrap.searchFileter  = 'GR';
                    reWrap.searchDtFileter= 'SS';
                    reWrap.reason         = '';
                    reWrap.reordDTName    = setDetailName(reWrap.searchDtFileter, reWrap.reason );
                    reWrap.dCreatedDate   = rObj.CreatedDate;
                    reWrap.orderNAme      = rObj.OrderItem__r.Order__r.Name;
                    reWrap.orderId        = rObj.OrderItem__r.Order__c;
                    recordListSet.add(reWrap);
                }
            // }

            if (serviceTId.size() > 0) {
                // System.debug('stId : ');
                Map<String, ServiceTerritory> returnSTMap = returnSTQuery(serviceTId); 
                if(returnSTMap.size()>0){
                    for (GRGIWrapper wrap : recordListSet) {
                        if (wrap.searchDtFileter.indexOf('W') != -1) {
                            ServiceTerritory stt = returnSTMap.get(wrap.shipToName);
                            // System.debug(stt);
                            if (stt != null) {
                                wrap.shipToName = stt.ServiceWorkCenter__r.FM_Address__c;
                            }
                        }
                    }
                }
            }
          
            // recordDetail에 맞는 데이터만 필터링
            List<GRGIWrapper> filteredList = new List<GRGIWrapper>();
            for (GRGIWrapper wrapper : recordListSet) {
                if(type !='All'){
                    if(wrapper.searchFileter == type) {
                        if(detailType !='All'){
                            if(wrapper.searchDtFileter == detailType){
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

            filteredList.sort();
            result.put('recordListSet',  filteredList);
                
        } catch (Exception e) {
            System.debug('입출고 관리 : ' + e.getLineNumber() + ' / ' + e.getMessage());
            String errorMessage = 'Exception : ' + e.getMessage();
            resultStatus.setError(errorMessage, null);
        }

           
        result.put('status', resultStatus);
        return result;
    }

    //반품 수량 쿼리
    private static Map<String,String> returnOrderQuery(Set<String> returnId,String agencyId,Date searchDateStart,Date searchDateEnd,String productCode,String customerId, String productLabel) {
        String querySelect = ' SELECT ';
        String queryFields ='   Id '
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
                       +'     , OrderITem__r.ReplacingPart__r.ProductCode  '  // 품번
                       +'     , OrderITem__r.ReplacingPart__r.FM_MaterialDetails__c  '  //품명
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
        String queryFrom = ' FROM DealerReturnOrderItem__c  '
                        +' WHERE Id != null  AND Delete__c != \'Y\' ' //AND OrderItem__c IN :returnId
                        +' AND Dealer__c=:agencyId'
                        + ' AND ( FM_ReturnDate__c >= :searchDateStart AND FM_ReturnDate__c <= :searchDateEnd ) ';
        //Product Code
        if(String.isNotBlank(productCode)) {
            set<String> partCodeSet = new set<String>(productCode.split(','));
            queryFrom += 'AND OrderItem__r.ReplacingPart__c IN(\''+String.join(partCodeSet, '\',\'') + '\')';
        }else if(String.isNotBlank(productLabel)) {
            System.debug('productLabel : '+productLabel);
            Set<String> partLabelSet = new set<String>();
            queryFrom += 'AND OrderItem__r.ReplacingPart__r.ProductCode IN:partLabelSet ';
        }
        // 고객
        if(String.isNotBlank(customerId)) {
            // queryFrom += 'AND OrderItem__r.Order__r.Customer__c =:customerId ';
            if(customerId.lastIndexOf('9999999999') == -1) {
                queryFrom += 'AND OrderItem__r.Order__r.Customer__c =:customerId ';
            } else {
                queryFrom += 'AND OrderItem__r.Order__r.CustomerCode__c =:customerId ';
            }
        }

        // 쿼리 반환
        return new Map<String,String>{
            'query' => querySelect + queryFields + queryFrom 
        };
    }

    //배송처...
    private static Map<String ,ServiceTerritory> returnSTQuery(Set<String> serviceTId) {
        return new AllAccessRecord().returnSTQuery(serviceTId);
    }
    
    /// 매입매출Wrapper
    public class GRGIWrapper implements Comparable {
        @AuraEnabled public String   Id              {get; set;}
        @AuraEnabled public String   reordType       {get; set;} //입출고구분
        @AuraEnabled public String   reordDTName     {get; set;} //입출고세부분류이름
        @AuraEnabled public String   recordDetail    {get; set;} //입출고세부분류코드 //type__c
        @AuraEnabled public String   inventoryChange {get; set;} //입고(H:정상,S;취소) 출고(S:정상,H:취소)            
        @AuraEnabled public String   customerName    {get; set;} //구매처/고객사명
        @AuraEnabled public String   giDocNumber     {get; set;} //입출고문서번호
        @AuraEnabled public Date     createdDate     {get; set;} //생성일자
        @AuraEnabled public String   productCode     {get; set;} //품번
        @AuraEnabled public String   productName     {get; set;} //품명
        @AuraEnabled public String   location        {get; set;} //저장위치
        @AuraEnabled public Decimal  discountAmount  {get; set;} //금액
        @AuraEnabled public String   currencyValue   {get; set;} //통화
        @AuraEnabled public String   refDocNumber    {get; set;} //참고문서번호  
        @AuraEnabled public String   comment         {get; set;} //기타  
        @AuraEnabled public String   shipToName      {get; set;} //배송지
        @AuraEnabled public String   searchFileter   {get; set;} //데이터검색조건  
        @AuraEnabled public String   searchDtFileter {get; set;} //데이터검색세부조건
        @AuraEnabled public Datetime dCreatedDate    {get; set;} //Ordering
        @AuraEnabled public String   reason          {get; set;} //reason
        @AuraEnabled public String   orderName       {get; set;}
        @AuraEnabled public String   orderId         {get; set;} //주문Id
        @AuraEnabled public String   delerOId        {get; set;} //대리점구매ID
        @AuraEnabled public String   dnsBuyId        {get; set;} //DNS구매ID
        @AuraEnabled public Decimal  quantity        { // 수량
            get{
                if(quantity == null) quantity = 0;
                return quantity;
            } 
            set;
        } //입출고수량

        public GRGIWrapper(){}

        public Integer compareTo(Object cObj) {
            GRGIWrapper comWrap = (GRGIWrapper)cObj;
            
            if (dCreatedDate < comWrap.dCreatedDate) return 1;
            if (dCreatedDate > comWrap.dCreatedDate) return -1;

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

    private static String setString(String str) {
        return str != null ? str : '';
    }

    private static Decimal setNulltoZero(Decimal num) {
        return (num == null) ? 0 : num;
    }

    private static String setDetailName(String codeName,String rName) {
        String rtnName = '';
        switch on codeName {
            when 'S2' { rtnName = 'DNS구매'; }
            when 'S1' { rtnName = '대리점구매'; }
            when 'S3' { rtnName = '기타입고'; }
            when 'SO' { rtnName = '기타출고취소'; }
            when 'SW' { rtnName = '무상출고취소'; }
            when 'SS' { rtnName = '주문서반품'; }
            when 'H2' { rtnName = 'DNS반품'; }
            when 'H1' { rtnName = '대리점구매반품'; }
            when 'H3' { rtnName = '기타입고취소'; }
            when 'HO' { rtnName = '기타출고'; }
            when 'HS' { rtnName = '주문서출고'; }
            when 'HW' { rtnName = '무상출고'; }
            when else { rtnName = ''; }
        }
        if(rName != '') rtnName =rtnName+'/'+rName;
        return rtnName;
    }

    public without sharing class AllAccessRecord {
        public Map<String ,ServiceTerritory> returnSTQuery(Set<String> serviceTId) {
            Map<String, ServiceTerritory> stMap = new Map<String, ServiceTerritory>();
            
            List<ServiceTerritory> stList = [
                SELECT  Id, Name,
                           ServiceWorkCenter__r.ShippingStreet, 
                           ServiceWorkCenter__r.ShippingCity, 
                           ServiceWorkCenter__r.ShippingState, 
                           ServiceWorkCenter__r.DetailAddress__c,
                           ServiceWorkCenter__r.FM_Address__c
                FROM ServiceTerritory WHERE Id IN :serviceTId ];
                //AND IsActive = true 
                //AND Branch__c = 'DNS' 삭제
    
            for (ServiceTerritory st : stList) {
                stMap.put(st.Id, st);
            }
    
            return stMap;
        }
    }
}