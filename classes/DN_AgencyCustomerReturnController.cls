/** 
 * @Class :  DN_AgencyCustomerReturnController
 * 
 * @Test: DN_AgencyCustomerReturnController_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 02. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-02 | Hyunwook Jin   | 최초작성 
 */ 
public class DN_AgencyCustomerReturnController {
    
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /*******************************************  고객 주문 반품 생성 화면 ********************************************************/
    /*
    * @ Method : init
    * @ Description : 고객 주문 반품 생성 초기 설정
    */
    @AuraEnabled
    public static Map<String,Object> init(String siteName){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            if(String.isBlank(siteName)) siteName = 'Partners';

            List<DomainSite> domian = [SELECT Domain.Domain, Site.UrlPathPrefix FROM DomainSite WHERE Site.Name = :siteName ];
            if(domian.size() > 0) {
                //String url = 'https://' +domian[0].Domain.Domain + '/s'; //domian[0].Site.UrlPathPrefix
                String url = Label.DN_DealerPortalURL;
                result.put('url', url);
            }else {
                result.put('url', URL.getOrgDomainURL().toExternalForm());
            }

            SchemaInfo returnOrderSchema = new SchemaInfo('DealerReturnOrderItem__c');
            result.put('reason1Options', returnOrderSchema.getPicklistValuesForOptions('Reason1__c', false));
            result.put('reason2Options', returnOrderSchema.getDependentPicklistValuesForOptions('Reason2__c'));
            
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
    * @ Method : searchReturnRequestOrderQuery
    * @ Description : 반품 요청 쿼리
    */
    private static Map<String,String> searchReturnRequestOrderQuery(String orderSeq,      
                                                                   String partId,
                                                                   Date giDateStart, 
                                                                   Date giDateEnd,
                                                                   String customerName,
                                                                   String customerCode)
                                                       {
            String querySelect = ' SELECT ';
            String queryFields ='     Id '
                               +'     , InventoryNumber__c '
                               +'     , InventoryItemNumber__c '
                               +'     , SalesOrganization__c '
                               +'     , DistributionChannel__c '
                               +'     , Division__c '
                               +'     , Dealer__c '
                               +'     , Dealer__r.Name '
                               +'     , Type__c '
                               +'     , InventoryChange__c '
                               +'     , Part__c '
                               +'     , Part__r.Name '
                               +'     , Quantity__c '
                               +'     , FM_Unit__c '
                               +'     , DealerOrderItem__c '
                               +'     , DealerOrderItem__r.FM_OrderNumber__c ' 
                               +'     , DealerOrderItem__r.OrderItemNumber__c ' 
                               +'     , DealerOrderItem__r.Quantity__c ' // 주문수량
                               +'     , DealerOrderItem__r.Part__r.FM_MaterialDetails__c ' // 주문품명
                               +'     , DealerOrderItem__r.Order__r.Customer__c '
                               +'     , DealerOrderItem__r.Order__r.CustomerCode__c '
                               +'     , DealerOrderItem__r.Order__r.FM_CustomerName__c '
                               +'     , Location__c '
                               +'     , Reason__c '
                               +'     , Comment__c '
                               +'     , FM_CreatedDate__c ';
            String queryFrom = ' FROM DealerInventoryMovements__c  '
                             +' WHERE RecordType.DeveloperName = \'GoodsIssue\' AND Type__c = \'S\' ';
            
            //Admin 사용자도 CustomPermission 있으면 볼 수 있게 변경
            if(String.isNotBlank(currentUser.getAgencyId())) queryFrom += ' AND DealerOrderItem__r.Order__r.Dealer__c = \''+currentUser.getAgencyId()+'\'';
            
            String additionalWhereClause = '';
            if(String.isNotBlank(orderSeq)) additionalWhereClause += ' AND DealerOrderItem__r.FM_OrderNumber__c like \'%'+ orderSeq +'%\'';
            
            if(giDateStart != null && giDateEnd != null) additionalWhereClause += ' AND ( FM_CreatedDate__c >= :giDateStart AND FM_CreatedDate__c <= :giDateEnd ) ';
            else if(giDateStart != null && giDateEnd == null) additionalWhereClause += ' AND FM_CreatedDate__c >= :giDateStart ';
            else if(giDateStart == null && giDateEnd != null) additionalWhereClause += ' AND FM_CreatedDate__c <= :giDateEnd ';
            
            if(String.isNotBlank(partId)) additionalWhereClause += ' AND Part__c = :partId ';
            System.debug(partId + ' ::: partId');
            //대리점 고객일 경우
            if(String.isNotBlank(customerName)) additionalWhereClause += ' AND DealerOrderItem__r.Order__r.Customer__c = \''+ customerName +'\'';
            //일반고객일경우
            else if(String.isNotBlank(customerCode)) additionalWhereClause += ' AND DealerOrderItem__r.Order__r.CustomerCode__c like \'%'+ customerCode +'%\'';

            return new Map<String,String>{
                'query' => querySelect + queryFields + queryFrom + additionalWhereClause + ' ORDER BY Part__r.Name, FM_CreatedDate__c  LIMIT 25000 ',
                'queryCount' => querySelect + ' count() ' + queryFrom + additionalWhereClause
            };
    }

    /*
    * @ Method : returnOrderQuery
    * @ Description : 기반품 수량 쿼리
    */
    private static Map<String,String> returnOrderQuery(Set<String> orderItemSet)
                                                       {
            String querySelect = ' SELECT ';
            String queryFields ='     Id '
                               +'     , SalesOrganization__c '
                               +'     , DistributionChannel__c '
                               +'     , Division__c '
                               +'     , Dealer__c '
                               +'     , Dealer__r.Name '
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
                               +'     , toLabel(Reason1__c) reason1Label '
                               +'     , Reason1__c ';
            String queryFrom = ' FROM DealerReturnOrderItem__c  '
                             +' WHERE Id != null  AND OrderItem__c IN :orderItemSet AND Delete__c != \'Y\' ';

            return new Map<String,String>{
                'query' => querySelect + queryFields + queryFrom + ' LIMIT 25000 '
                //'queryCount' => querySelect + ' count() ' + queryFrom + additionalWhereClause
            };
    }

    /*
    * @ Method : searchReturnRequestOrder
    * @ Description : 반품 주문 요청 - 출하 완료 된 주문 기준으로 조회
    */
    @AuraEnabled
    public static Map<String,Object> searchReturnRequestOrder(String orderSeq,      
                                                       String partId,
                                                       Date giDateStart, 
                                                       Date giDateEnd,
                                                       String customerName,
                                                       String customerCode,
                                                       DN_DealerPortalDisplayController.PageReturn page,
                                                       Integer nextPage
    ){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            System.debug('giDateStart : '+giDateStart);
            System.debug('giDateEnd : '+giDateEnd);
            Map<String,String> queryMap = searchReturnRequestOrderQuery(orderSeq,partId,giDateStart,giDateEnd,customerName,customerCode);
            String query = queryMap.get('query');
            System.debug(query + ' ::: query');
            System.debug(partId + ' ::: partId');
            String totalQuery = queryMap.get('queryCount');

            System.debug('page : ' +JSON.serializePretty(page));

            System.debug('totalQuery :: '+ totalQuery);
            Integer totalSize = Database.countQuery(totalQuery);
            page.totalRecordSize = totalSize;

            System.debug('query :: '+ query);
            
            List<ReturnOrderItem> returnRequestList = new List<ReturnOrderItem>();
            Map<String,ReturnOrderItem> returnRequestMap = new Map<String,ReturnOrderItem>();
            
            for(DealerInventoryMovements__c goodIssueSObject : (List<DealerInventoryMovements__c>)Database.query(query)) {
                ReturnOrderItem returnRequest = new ReturnOrderItem(goodIssueSObject);
                if(!returnRequestMap.containsKey(returnRequest.itemId)) returnRequestMap.put(returnRequest.itemId, returnRequest);
                else {
                    //출고문서는 여러개 생길 수 있어 OrderItem별 총 반품수량 및 출고수량 Summary
                    returnRequestMap.get(returnRequest.itemId).returnQuantity += returnRequest.returnQuantity;
                    //giQuantity   
                    returnRequestMap.get(returnRequest.itemId).giQuantity += returnRequest.giQuantity;
                }
            }

            //출고 수량이 기 반품수량 보다 작거나 같을 경우 조회 대상에서 제외
            Set<String> orderItemSet = returnRequestMap.keySet();
            Map<String,String> returnOrderQueryMap = returnOrderQuery(orderItemSet);
            String returnOrderQuery = returnOrderQueryMap.get('query');
            Map<String, DealerReturnOrderItem__c> returnOrderMap = new Map<String, DealerReturnOrderItem__c>();
            for(DealerReturnOrderItem__c returnOrderSObject : Database.query(returnOrderQuery)) { 
                if(!returnOrderMap.containsKey(returnOrderSObject.OrderItem__c)) returnOrderMap.put(returnOrderSObject.OrderItem__c, returnOrderSObject);
                else {
                    returnOrderMap.get(returnOrderSObject.OrderItem__c).ReturnQuantity__c += returnOrderSObject.ReturnQuantity__c;
                }
            }
            List<ReturnOrderItem> recordListSet = new List<ReturnOrderItem>();
            for(ReturnOrderItem returnRequestOrderItem : returnRequestMap.values()) {
                if(returnOrderMap.containsKey(returnRequestOrderItem.itemId)) {
                    Decimal returnQuantity = returnOrderMap.get(returnRequestOrderItem.itemId).ReturnQuantity__c;
                    // System.debug('returnRequestOrderItem.giQuantity : ' + returnRequestOrderItem.giQuantity);
                    // System.debug('ReturnQuantity__c : ' + returnOrderMap.get(returnRequestOrderItem.itemId).ReturnQuantity__c);
                    returnRequestOrderItem.giQuantity -= returnQuantity;
                    if(returnRequestOrderItem.giQuantity <= 0) {
                        //TEST 로 잠시 주석
                        returnRequestMap.remove(returnRequestOrderItem.itemId);
                    }
                }
            }

            for(ReturnOrderItem returnRequestOrderItem : returnRequestMap.values()) {
                if(recordListSet.size() < 2000) recordListSet.add(returnRequestOrderItem);
            }
            result.put('query', query);
            result.put('returnRequestList', recordListSet); //returnRequestMap.values()
            // result.put('page', page);

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
    * @ Method : createReturnRequestOrder
    * @ Description : 반품 요청 생성
    */
    @AuraEnabled
    public static Map<String,Object> createReturnRequestOrder(List<ReturnOrderItem> returnRequestList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();
            
            SequenceGenerator seqGenerator = new SequenceGenerator('DealerReturnOrderItem__c');
            String returnOrderSeq = seqGenerator.generate('ReturnOrder');
            List<DealerReturnOrderItem__c> returnOrderItemList = new List<DealerReturnOrderItem__c>();
            Map<String, ReturnOrderItem> orderItemMap = new Map<String, ReturnOrderItem>(); //orderItem 별 WrapperClass
            Set<String> partIdList = new Set<String>();
            Integer itemSeq = 1;
            for(ReturnOrderItem returnRequestOrder : returnRequestList) {
                returnRequestOrder.returnOrderSeq = returnOrderSeq;
                returnRequestOrder.returnItemSeq = String.valueOf(itemSeq++);
                
                returnOrderItemList.add(returnRequestOrder.convertToSObject());
                orderItemMap.put(returnRequestOrder.itemId, returnRequestOrder);
                partIdList.add(returnRequestOrder.part);
            }
            

            if(returnOrderItemList.size() > 0) {
                insert returnOrderItemList;
                seqGenerator.updateNextSequenceInfo();

                //입고 문서 생성
                //공급품목의 재고 변환
                Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, partIdList);
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                DateTime updateTime = System.now();
                for(DealerReturnOrderItem__c returnOrderItem : returnOrderItemList) {
                    
                    if(orderItemMap.containsKey(returnOrderItem.OrderItem__c)) {
                        ReturnOrderItem returnRequestOrder = orderItemMap.get(returnOrderItem.OrderItem__c); 
                        
                        //반품 첨부파일
                        for(File file : returnRequestOrder.fileList) {
                            cdlList.add(file.convertToSObject(returnOrderItem.Id));
                        }

                        //재고 증가
                        if(stockMap.containsKey(returnRequestOrder.part)) {
                            DealerStock__c stock = stockMap.get(returnRequestOrder.part);
                            System.debug('stock.CurrentStockQuantity__c : '+ stock.CurrentStockQuantity__c + ' / returnOrderItem.ReturnQuantity__c: '+ returnOrderItem.ReturnQuantity__c + ' / stock.AvailableQuantity__c : '+stock.AvailableQuantity__c);
                            stock.CurrentStockQuantity__c += returnOrderItem.ReturnQuantity__c;
                            System.debug('1. stock.CurrentStockQuantity__c : '+ stock.CurrentStockQuantity__c + ' / stock.AvailableQuantity__c : '+stock.AvailableQuantity__c);
                            stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                            System.debug('2. stock.CurrentStockQuantity__c : '+ stock.CurrentStockQuantity__c + ' / stock.AvailableQuantity__c : '+stock.AvailableQuantity__c);
                            stock.LastImportDateTime__c = updateTime;
                            returnRequestOrder.loc = stock.DealerLocation__r.FM_Loc__c;

                        }
                    }                    
                }

                // if(goodsReceiptList.size() > 0) insert goodsReceiptList;
                if(stockMap.size() > 0) upsert stockMap.values() ExternalKey__c;
                if(cdlList.size() > 0) insert cdlList;

                result.put('returnOrderSeq', returnOrderSeq);
                result.put('createDate',updateTime.format('yyyy-MM-dd'));
                result.put('createTime',updateTime.format('HH:mm:ss'));
                result.put('returnRequestOrder',returnRequestList);
                result.put('returnOrderItemList' , returnOrderItemList);
            }

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
    * @ Method : fileRemove
    * @ Description : 파일 삭제
    */
    @AuraEnabled
    public static Boolean fileRemove(String fileId){
        try {
            System.debug(fileId + ' >< ==fileId');
            ContentDocument getContentDocument = [select Id from ContentDocument where Id=:fileId];
            delete getContentDocument;

            return true;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' < ===e.getMessage()');
            System.debug(e.getLineNumber() + ' < ===e.getLineNumber()');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*******************************************  고객 주문 반품 관리 화면 ********************************************************/
    /*
    * @ Method : searchReturnOrder
    * @ Description : 주문 반품 데이터 조회
    */
    @AuraEnabled
    public static Map<String,Object> searchReturnOrder(String returnOrderSeq,      
                                                       List<String> partIdList,
                                                       Date returnDateStart, 
                                                       Date returnDateEnd,
                                                       String customerName,
                                                       String customerCode,
                                                       DN_DealerPortalDisplayController.PageReturn page,
                                                       Integer nextPage
    ){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String querySelect = 'SELECT '
                         +' SalesOrganization__c ,'
                         +' DistributionChannel__c ,'
                         +' Division__c ,'
                         +' Id ,'
                         +' ReturnOrderNumber__c ,'
                         +' ReturnOrderItemNumber__c ,'
                         +' OrderItem__r.Order__r.Customer__c ,'
                         +' OrderItem__r.Order__r.CustomerCode__c ,'
                         +' OrderItem__r.Order__r.FM_CustomerName__c ,'
                         +' OrderItem__c ,'
                         +' OrderItem__r.OrderItemNumber__c ,'
                         +' FM_Order__c ,'
                         +' OrderItem__r.Order__c ,'
                         +' OrderItem__r.ReplacingPart__c ,'
                         +' OrderItem__r.ReplacingPart__r.Name ,'
                         +' OrderItem__r.ReplacingPart__r.FM_MaterialDetails__c ,'
                         +' OrderItem__r.FM_Unit__c ,'
                         +' OrderItem__r.Quantity__c ,'
                         +' ReturnQuantity__c ,'
                         +' Reason1__c ,'
                         +' toLabel(Reason1__c) reason1Label , '
                         +' Reason2__c ,'
                         +' FM_ReturnDate__c, '
                         +' FM_ReturnNumber__c, '
                         +' Note__c ';
            String queryFrom = 'FROM DealerReturnOrderItem__c WHERE Id != null AND Delete__c != \'Y\' ';
            String additionalWhereClause = '';
            if(String.isNotBlank(returnOrderSeq)) additionalWhereClause += ' AND ReturnOrderNumber__c = \''+ returnOrderSeq +'\'';
            //' AND FM_ReturnNumber__c like \'%'+ returnOrderSeq +'%\'';
            
            if(returnDateStart != null && returnDateEnd != null) additionalWhereClause += ' AND ( FM_ReturnDate__c >= :returnDateStart AND FM_ReturnDate__c <= :returnDateEnd ) ';
            else if(returnDateStart != null && returnDateEnd == null) additionalWhereClause += ' AND FM_ReturnDate__c >= :returnDateStart ';
            else if(returnDateStart == null && returnDateEnd != null) additionalWhereClause += ' AND FM_ReturnDate__c <= :returnDateEnd ';

            if(partIdList?.size() > 0) additionalWhereClause += ' AND 	OrderItem__r.ReplacingPart__c IN :partIdList ';

            //대리점 고객일 경우
            if(String.isNotBlank(customerName)) additionalWhereClause += ' AND OrderItem__r.Order__r.Customer__c = \''+ customerName +'\'';
            //일반고객일경우
            else if(String.isNotBlank(customerCode)) additionalWhereClause += ' AND OrderItem__r.Order__r.CustomerCode__c like \'%'+ customerCode +'%\'';

            //Admin 사용자도 CustomPermission 있으면 볼 수 있게 변경
            if(String.isNotBlank(currentUser.getAgencyId())) additionalWhereClause += ' AND OrderItem__r.Order__r.Dealer__c = \''+currentUser.getAgencyId()+'\'';

            List<ReturnOrderItem> recordListSet = new List<ReturnOrderItem>();
            Set<String> returnOrderIdSet = new Set<String>();
            String query = querySelect + queryFrom;
            if(String.isNotBlank(additionalWhereClause)) query += additionalWhereClause;

            for(DealerReturnOrderItem__c returnOrderItem : Database.query(query + ' LIMIT 2000 ')) {
                recordListSet.add(new ReturnOrderItem(returnOrderItem));
                returnOrderIdSet.add(returnOrderItem.Id);
            }

            String url =(String) init('Partners').get('url');
            Map<String,List<File>> fileMap = new Map<String, List<File>>();
            if(returnOrderIdSet.size() > 0) {
                for(ContentDocumentLink cdl :[
                    SELECT
                        LinkedEntityId,
                        ContentDocumentId,
                        ContentDocument.Title,
                        ContentDocument.FileExtension
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :returnOrderIdSet
                ]) {
                    if(!fileMap.containsKey(cdl.LinkedEntityId)) fileMap.put(cdl.LinkedEntityId, new List<File>());
                    File file = new File(cdl);
                    file.previewUrl = url + 'contentdocument/'+file.documentId;
                    fileMap.get(cdl.LinkedEntityId).add(file);
                }
            }

            for(ReturnOrderItem returnOrder : recordListSet) {
                if(fileMap.containsKey(returnOrder.returnItemId)) 
                    returnOrder.fileList =  fileMap.get(returnOrder.returnItemId);
            }
            result.put('query', query);
            result.put('returnOrderList', recordListSet);
            result.put('page', page);

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
    * @ Method : deleteReturnOrder
    * @ Description : 주문 반품 삭제 - 삭제 상태값으로 변경
    */
    @AuraEnabled
    public static Map<String,Object> deleteReturnOrder(List<ReturnOrderItem> returnOrderList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();
            
            List<DealerReturnOrderItem__c> updateDeleteList = new List<DealerReturnOrderItem__c>();
            Set<String> partIdList = new Set<String>();
            for(ReturnOrderItem returnOrder : returnOrderList) {
                partIdList.add(returnOrder.part);

                updateDeleteList.add(new DealerReturnOrderItem__c(
                    Id = returnOrder.returnItemId,
                    Delete__c = 'Y'
                ));
            }

            if(updateDeleteList.size() > 0) {
                update updateDeleteList;

                //공급품목의 재고 변환
                Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, partIdList);
                DateTime updateTime = System.now();
                for(ReturnOrderItem returnOrder : returnOrderList) {
                    // 재고 감소
                    // 대리점 현재고에서 삭제 수량만큼 차감
                    if(stockMap.containsKey(returnOrder.part)) {
                        DealerStock__c stock = stockMap.get(returnOrder.part);
                        stock.CurrentStockQuantity__c -= returnOrder.returnQuantity;
                        stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                        stock.LastExportDateTime__c = updateTime;
                    }
                }

                if(stockMap.size() > 0) upsert stockMap.values() ExternalKey__c;

                result.put('updateDeleteList', updateDeleteList);
            }

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
    * @ Class : ReturnOrderItem
    * @ Description : ReturnOrderItem Class
    */
    public class ReturnOrderItem {
        @AuraEnabled public String  salesOrganization    {get; set;}
        @AuraEnabled public String  distributionChannel  {get; set;}
        @AuraEnabled public String  division             {get; set;}
        @AuraEnabled public String  giId                 {get; set;} //출고Id
        @AuraEnabled public String  orderId              {get; set;} //주문Id
        @AuraEnabled public String  orderSeq             {get; set;} //주문Seq
        @AuraEnabled public String  customerCode         {get; set;} //일반고객일 경우만 값이 존재 (9999999999)
        @AuraEnabled public String  customer             {get; set;} //
        @AuraEnabled public String  customerName         {get; set;} //
        @AuraEnabled public String  dealer               {get; set;} //Dealer__c
        @AuraEnabled public String  dealerName           {get; set;} //Dealer__r.Name
        @AuraEnabled public String  itemId               {get; set;} //주문ItemId
        @AuraEnabled public String  itemSeq              {get; set;} //주문ItemSeq
        @AuraEnabled public String  returnOrderSeq       {get; set;} //반품주문Seq
        @AuraEnabled public String  returnItemId         {get; set;} //반품주문ItemId
        @AuraEnabled public String  returnItemSeq        {get; set;} //반품주문ItemSeq
        @AuraEnabled public String  part                 {get; set;} //출고문서정보
        @AuraEnabled public String  partName             {get; set;} //출고문서정보
        @AuraEnabled public String  partDetails          {get; set;} //출고문서정보 
        @AuraEnabled public String  unit                 {get; set;} //주문Item Unit
        @AuraEnabled public Decimal orderQuantity        {get; set;} //주문Item 수량
        @AuraEnabled public Decimal customerPrice        {get; set;} //Decimal?
        @AuraEnabled public Decimal discountPrice        {get; set;} //Decimal?
        @AuraEnabled public Decimal discountAmount       {get; set;} //Decimal?
        @AuraEnabled public Decimal giQuantity           {
            get{
                if(giQuantity == null) giQuantity = 0;
                return giQuantity;
            } 
            set;
        } //출고수량
        @AuraEnabled public Decimal returnQuantity       {
            get {
                if(returnQuantity == null) returnQuantity = 0;
                return returnQuantity;
            } 
            set;
        }
        @AuraEnabled public Date    giDate                {get;set;}  // 출고일자
        @AuraEnabled public Date    returnDate            {get;set;}  // 반품일자
        @AuraEnabled public String  reason1               {get;set;}  // 사유1
        @AuraEnabled public String  reason1Label          {get;set;}  // 사유1 라벨
        @AuraEnabled public String  reason2               {get;set;}  // 사유2
        @AuraEnabled public String  note                  {get;set;}  // 반품내용
        @AuraEnabled public String  loc                   {get;set;}
        @AuraEnabled public Boolean isFile                {get;set;}  // 파일첨부여부
        @AuraEnabled public Boolean isSelected = false;
        @AuraEnabled public Boolean iscomplaintRow = false;
        @AuraEnabled public List<File> fileList           {
            get {
                if(this.fileList == null) this.fileList = new List<File>();
                return this.fileList;
            }
            set;
        }

        /*
        * @ 생성자 : ReturnOrderItem
        * @ Description : DealerInventoryMovements__c 데이터 매핑
        */
        public ReturnOrderItem(){}
        public ReturnOrderItem(DealerInventoryMovements__c goodIssueSObject) {
            this.salesOrganization   = goodIssueSObject.SalesOrganization__c;
            this.distributionChannel = goodIssueSObject.DistributionChannel__c;
            this.division            = goodIssueSObject.Division__c;

            this.giId          = goodIssueSObject.Id;
            this.orderId       = goodIssueSObject.DealerOrderItem__c;
            this.orderSeq      = goodIssueSObject.DealerOrderItem__r.FM_OrderNumber__c;
            this.customerCode  = goodIssueSObject.DealerOrderItem__r.Order__r.CustomerCode__c;
            this.customer      = goodIssueSObject.DealerOrderItem__r.Order__r.Customer__c;
            this.customerName  = goodIssueSObject.DealerOrderItem__r.Order__r.FM_CustomerName__c;
            this.dealer        = goodIssueSObject.Dealer__c;
            this.dealerName    = goodIssueSObject.Dealer__r.Name;
            this.itemId        = goodIssueSObject.DealerOrderItem__c;
            this.itemSeq       = goodIssueSObject.DealerOrderItem__r.OrderItemNumber__c;
            this.part          = goodIssueSObject.Part__c;
            this.partName      = goodIssueSObject.Part__r.Name;
            this.partDetails   = goodIssueSObject.DealerOrderItem__r.Part__r.FM_MaterialDetails__c;
            this.unit          = goodIssueSObject.FM_Unit__c;
            this.orderQuantity = goodIssueSObject.DealerOrderItem__r.Quantity__c;
            this.giQuantity    = goodIssueSObject.Quantity__c;
            this.giDate        = goodIssueSObject.FM_CreatedDate__c;
        }

        /*
        * @ 생성자 : ReturnOrderItem
        * @ Description : DealerReturnOrderItem__c 데이터 매핑
        */
        public ReturnOrderItem(DealerReturnOrderItem__c returnOrderSObject){
            salesOrganization  = returnOrderSObject.SalesOrganization__c;
            distributionChannel= returnOrderSObject.DistributionChannel__c;
            division           = returnOrderSObject.Division__c;
            returnItemId       = returnOrderSObject.Id;
            returnOrderSeq     = returnOrderSObject.ReturnOrderNumber__c;
            returnItemSeq      = returnOrderSObject.ReturnOrderItemNumber__c;
            customerCode       = returnOrderSObject.OrderItem__r.Order__r.Customer__c;
            customer           = returnOrderSObject.OrderItem__r.Order__r.CustomerCode__c;
            customerName       = returnOrderSObject.OrderItem__r.Order__r.FM_CustomerName__c;
            itemId             = returnOrderSObject.OrderItem__c;
            itemSeq            = returnOrderSObject.OrderItem__r.OrderItemNumber__c;
            orderSeq           = returnOrderSObject.FM_Order__c;
            orderId            = returnOrderSObject.OrderItem__r.Order__c;
            part               = returnOrderSObject.OrderItem__r.ReplacingPart__c;
            partName           = returnOrderSObject.OrderItem__r.ReplacingPart__r.Name;
            partDetails        = returnOrderSObject.OrderItem__r.ReplacingPart__r.FM_MaterialDetails__c;
            unit               = returnOrderSObject.OrderItem__r.FM_Unit__c;
            orderQuantity      = returnOrderSObject.OrderItem__r.Quantity__c;
            returnQuantity     = returnOrderSObject.ReturnQuantity__c;
            reason1            = returnOrderSObject.Reason1__c;
            reason1Label       = returnOrderSObject.getPopulatedFieldsAsMap().containsKey('reason1Label') ? String.valueOf(returnOrderSObject.get('reason1Label')) : '';
            reason2            = returnOrderSObject.Reason2__c;
            note               = returnOrderSObject.Note__c;
            returnDate         = returnOrderSObject.FM_ReturnDate__c;
        }

        /*
        * @ Method : convertToSObject
        * @ Description : DealerReturnOrderItem__c 데이터 매핑
        */
        public DealerReturnOrderItem__c convertToSObject() {
            DealerReturnOrderItem__c returnOrderSObject = new DealerReturnOrderItem__c(
                OrderItem__c = itemId,
                ReturnQuantity__c = returnQuantity,
                Reason1__c = reason1,
                Reason2__c = reason2,
                Note__c = note,
                ReturnOrderNumber__c = returnOrderSeq,
                ReturnOrderItemNumber__c = returnItemSeq
            );

            returnOrderSObject.SalesOrganization__c      = (String.isBlank(salesOrganization)) ? currentUser.getSalesOranization() : salesOrganization;
            returnOrderSObject.DistributionChannel__c    = (String.isBlank(distributionChannel)) ? currentUser.getDistributionChannel() : distributionChannel;
            returnOrderSObject.Division__c               = (String.isBlank(division)) ? currentUser.getDivision() : division;
            returnOrderSObject.Dealer__c                 = (String.isBlank(dealer)) ? currentUser.getAgencyId() : dealer;

            return returnOrderSObject;
        }
    }
    
    /*
    * @ Class : File
    * @ Description : File Class
    */
    public class File {
        @AuraEnabled public String returnItemId {get; set;}
        @AuraEnabled public String documentId   {get; set;}
        @AuraEnabled public String title        {get; set;}
        @AuraEnabled public String previewUrl   {get; set;}
        public File() {}
        /*
        * @ 생성자 : File
        * @ Description : ContentDocumentLink 데이터 설정
        */
        public File(ContentDocumentLink cdl) {
            documentId = cdl.ContentDocumentId;
            title = cdl.ContentDocument.Title + '.'+cdl.ContentDocument.FileExtension;
            returnItemId = cdl.LinkedEntityId;
        }
        /*
        * @ Method : convertToSObject
        * @ Description : ContentDocumentLink 데이터로 변환
        */
        public ContentDocumentLink convertToSObject() {
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = documentId,
                Visibility = 'AllUsers',
                ShareType = 'V'
            );
            return cdl;
        }
        /*
        * @ Method : convertToSObject
        * @ Description : ContentDocumentLink 데이터로 변환
        */
        public ContentDocumentLink convertToSObject(String linkedEntityId) {
            ContentDocumentLink cdl = convertToSObject();
            cdl.LinkedEntityId = linkedEntityId;
            return cdl;
        }
    }

    public enum StatusCode { SUCCESS, ERROR }

    /*
    * @ class : StatusInfo
    * @ Description : 상태값 Class
    */
    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        /*
        * @ 생성자 : StatusInfo
        * @ Description : 초기값 설정
        */
        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        /*
        * @ Method : setCode
        * @ Description : 코드값 설정
        */
        public void setCode(Integer code) {
            this.code = code;
        }

        /*
        * @ Method : setCode
        * @ Description : 메세지 설정
        */
        public void setMessage(String msg) {
            this.msg = msg;
        }

        /*
        * @ Method : setError
        * @ Description : 에러인 경우 메세지 및 코드 반환
        */
        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }

    public class CustomException extends Exception {}

}