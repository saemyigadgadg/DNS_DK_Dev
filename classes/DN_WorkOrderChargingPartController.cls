/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-18
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-12-02   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_WorkOrderChargingPartController {
    private static final Id accDealerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    /**
     * @Description
     * 	- 해당 Service Order에 청구된 Product Request에서 마지막 Sequence Number 반환
     * @author Hayeong Min
    **/ 
    @AuraEnabled
    public static Integer getDeleteLastIndex(String workOrderId, String seq){
        List<ProductRequest> partsList = [SELECT ID FROM ProductRequest
                                          WHERE IsDealerPortalDelete__c = true
                                          AND WorkOrderId =: workOrderId
                                          AND Seq__c =: seq];
        return partsList.size();
    }

    /**
     * @Description
     * 	- 해당 Service Order에 청구된 부품(Product Request) 목록 반환
     * @author Hayeong Min
    **/ 
    @AuraEnabled
    public static List<ChargingPartWrapper> getChargingPartList(String workOrderId){

        List<ChargingPartWrapper> wrapperList = new List<ChargingPartWrapper>();
        try {
            List<ProductRequest> tempList = [SELECT Id, Status, Product__c, ProductCode__c, Product__r.Name, Quantity__c, 
                                                    Inventory__c, ReturnStatus__c, TransportsDivision__c, ShipTo__c, WorkCenterId__c, WorkCenterId__r.Name, 
                                                    Product__r.Weight__c,ProductType__c, Product__r.FM_MaterialDetails__c,
                                                    Product__r.WeightUnit__c, Seq__c 
                                            FROM ProductRequest 
                                            WHERE WorkOrderId =: workOrderId 
                                            AND IsDealerPortalDelete__c = false 
                                            
                                            ORDER BY Seq__c NULLS LAST];
            
            for(ProductRequest pr :  tempList){
                ChargingPartWrapper instance = new ChargingPartWrapper();
                instance.ProductRequestRecordId = pr.Id;                           // 레코드 ID
                instance.ProductId = pr.Product__c;                                // 품목 ID
                instance.ProgressStatus = pr.Status;                               // 상태 ( 부품진행상태 )
                
                if(pr.ProductCode__c != null){
                    instance.ProductCode = pr.ProductCode__c;                      // 품번
                }
                instance.ProductName = pr.Product__r.FM_MaterialDetails__c;        // 품명
                
                if(pr.Quantity__c != null){
                    instance.PartAmount = Integer.valueOf(pr.Quantity__c);         // 수량
                }
                
                if(pr.Inventory__c != null){
                    instance.PartInventory = Integer.valueOf(pr.Inventory__c);     // 재고
                }
                
                instance.HandInFlag = pr.ReturnStatus__c;                          // 반납여부
                instance.TransportDivision = pr.TransportsDivision__c;             // 탁송구분
                instance.ShipTo = pr.ShipTo__c;                                    // 배송처
                instance.WorkCenterId = pr.WorkCenterId__c;                          // 대리점 ID
                instance.WorkCenterName = pr.WorkCenterId__r.Name;                   // 대리점명
                if(pr.Product__r.Weight__c != null){
                   instance.Weight = String.valueOf(pr.Product__r.Weight__c);      // 무게
                }
                instance.UnitCode = pr.Product__r.WeightUnit__c;                   // 단위
                instance.PartNo = pr.Seq__c;                                       // 순번
                
                instance.EditMode = false;                                         // 수정모드
                instance.ProductType = pr.ProductType__c;                          // 스핀들구분(R,N)

                System.debug('ProductId: ' + instance.ProductId);
                System.debug('ProductCode: ' + instance.ProductCode);
                System.debug('ProductUrl: /lightning/r/Product2/' + instance.ProductId + '/view');
                
                wrapperList.add(instance);
            }
        } catch (Exception e) {
            system.debug('에러 내역 :::: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperList;
    }

    /**
     * @Description
     * 	- 해당 Product의 부품코드 반환
     * @author Hayeong Min
    **/ 
    @AuraEnabled
    public static string getProductName(String productID){
        string returnVal;
        try {
            returnVal = [SELECT Id, ProductCode FROM Product2 WHERE Id =: productID].ProductCode;
        } catch (Exception e) {
            system.debug('errorrrrr ::: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return returnVal;
    }

    /**
     * @Description
     * 	- ProductCode(부품코드)로 해당 Product 정보 반환
     * @author Hayeong Min
    **/ 
    @AuraEnabled
    public static Product2 getProductId(String productName){
        Product2 res = new Product2();
        try {
            res = [SELECT Id, Name, ProductCode, FM_MaterialDetails__c FROM Product2 WHERE ProductCode =: productName LIMIT 1];
        } catch (Exception e) {
            system.debug('errorrrrr ::: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return res;
    }

    /**
     * @Description
     * 	- ProductCode(부품코드)로 해당 Product 정보 반환
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static Product2 getProductDetails(String productId) {
        System.debug('getProductDetails called with productId: ' + productId);
        try {
            if(String.isBlank(productId)) {
                return null;
            }
            List<Product2> products = [
                SELECT Id, ProductCode, Name, 
                        Weight__c, FM_MaterialDetails__c,
                        WeightUnit__c, Replacement__c, 
                       ExpectedPrice__c, ProductSpec__c, Unit__c
                FROM Product2 
                WHERE Id = :productId
                LIMIT 1
            ];
            return !products.isEmpty() ? products[0] : null;
        } catch (Exception e) {
            System.debug('getProductDetails error: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @Description
     * 	- 해당 Opportunity과 관련된 OpportunityLineItem 목록 반환
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static List<OpportunityLineItem> getOptyLI(String opportunityId) {
        try {
            return [
                SELECT Id, Name, Product2Id, ProductCode, Quantity, UnitPrice, Description, Unit__c, PricebookEntryId, OpportunityId, Product2.Name, TotalPrice
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 해당 Opportunity와 OpportunityLineItem upsert
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static String upsertOptyProduct(List<ChargingPartWrapper> requestProductList, String opportunityId) {
        List<OpportunityLineItem> insertOliList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> updateOliList = new List<OpportunityLineItem>();
        String pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;

        try {
            // 현재 Opportunity의 기존 OpportunityLineItem 조회
            Map<Id, OpportunityLineItem> existingOliMap = new Map<Id, OpportunityLineItem>(
                [SELECT Id, Product2Id, UnitPrice, Quantity, Unit__c 
                FROM OpportunityLineItem 
                WHERE OpportunityId = :opportunityId]
            );

            for (ChargingPartWrapper wrapper : requestProductList) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opportunityId;
                oli.Product2Id = wrapper.ProductId;
                oli.UnitPrice = wrapper.PartAmountUnit;
                oli.Quantity = wrapper.PartAmount;
                oli.Unit__c = wrapper.UnitCode;

                if (existingOliMap.containsKey(wrapper.ProductRequestRecordId)) {
                    // 기존 레코드가 있으면 업데이트 리스트에 추가
                    oli.Id = wrapper.ProductRequestRecordId;
                    updateOliList.add(oli);
                } else {
                    // 기존 레코드가 없으면 삽입 리스트에 추가
                    insertOliList.add(oli);
                }
            }

            // Pricebook2 업데이트
            Opportunity opportunityToUpdate = new Opportunity(Id = opportunityId, Pricebook2Id = pricebook2Id);
            update opportunityToUpdate;

            // OpportunityLineItem 업데이트
            if (!updateOliList.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(updateOliList, false);
                for (Database.SaveResult sr : updateResults) {
                    if (!sr.isSuccess()) {
                        return '업데이트 오류 발생: ' + sr.getErrors()[0].getMessage();
                    }
                }
            }

            // OpportunityLineItem 삽입
            if (!insertOliList.isEmpty()) {
                Database.SaveResult[] insertResults = Database.insert(insertOliList, false);
                for (Database.SaveResult sr : insertResults) {
                    if (!sr.isSuccess()) {
                        return '삽입 오류 발생: ' + sr.getErrors()[0].getMessage();
                    }
                }
            }

            return 'SUCCESS';
        } catch (Exception e) {
            return '오류 발생: ' + e.getMessage();
        }
    }

    /**
     * @Description
     * 	- 실시간 부품 확보 상태 조회 I/F
     * @author Hayeong Min
    **/
    public static IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res getIF033(String workOrderId) {
        System.debug('IF_CSPLUS_033 START ::: woId: '+workOrderId);

        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req();

        List<IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR> t_i_aufnr_list = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR>();
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR t_i_aufnr = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR();
        t_i_aufnr.LOW = workOrderId;
        t_i_aufnr_list.add(t_i_aufnr);
        req.T_I_AUFNR = t_i_aufnr_list;
     
        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res response = instance.IF_CSPLUS_033(req);

        System.debug('response033 ::: ' + response);

        return response;
    }

    /**
     * @Description
     * 	- 해당 Product Request 제거
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static void deleteRequestProduct(String recordId){
        try {
            productrequest instance = new productrequest();
            System.debug('recordId 대해 == ' + recordId);
            instance.Id = recordId;
            System.debug('instance에 대해 == ' + instance);
            delete instance;
        } catch (Exception err) {
            system.debug('err ::: ' + err);
            throw new AuraHandledException(err.getMessage());
        }
    }

    /**
     * @Description
     * 	- WCID가 존재하는 활성화된 184S로 등록된 Work Center 목록 반환
     * @author Hayeong Min
    **/
    @AuraEnabled(cacheable=true)
    public static List<ServiceTerritory> getServiceTerritories() {
        return [
            SELECT Id, Name, Street, City, State, PostalCode, Country
            FROM ServiceTerritory 
            WHERE ServiceWorkCenter__c != null AND IsActive = true AND PlanningPlant__c = '184S' AND WCID__c != null
            ORDER BY Name
        ];
    }

    /**
     * @Description
     * 	- GPES로 선택한 부품 청구
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static PartsListWrapper getGPESProducts(List<Object> gpesPartsList) {
        // List<Product2> resultList = new List<Product2>();
        PartsListWrapper result = new PartsListWrapper();
        try {
            System.debug('gpesPartsList ::: ' + gpesPartsList);
            Set<String> partNos = new Set<String>();
            for(object obj : gpesPartsList){
                String tempJson = Json.serialize(obj);
                Map<String, Object> objMap = (Map<String, Object>)Json.deserializeUntyped(tempJson);
                partNos.add(String.valueOf(objMap.get('partNo')));
            }
    
            List<Product2> partList= [SELECT Id, ProductCode, Name, Weight__c, WeightUnit__c FROM Product2 WHERE ProductCode IN :partNos];
            
            Map<String, Boolean> codeMap = new Map<String, Boolean>();
            for (Product2 part : partList) {
                codeMap.put(part.ProductCode, true);
            }

            List<String> notParts = new List<String>();

            if (!partList.isEmpty()) {
                for(String key : partNos){
                    if (!codeMap.containsKey(key)) {
                        notParts.add(key);
                    }
                }

                if (notParts.size() > 0) {
                    String notcode = String.join(notParts, ', ');
                    result.isSuccess = false;
                    result.message = notcode + ' not registered in CRM.';
                    result.partsList = partList;
                } else {
                    result.partsList = partList;
                } 
            } else {
                result.isSuccess = false;
                result.message = 'Parts not registered in CRM.';
            }
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
            // return resultList;
        }
        return result;
    }

    /**
     * @Description
     * 	- 해당 Service Order에 등록된 장비번호 반환
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static String getAssetName(String recordId) {
        System.debug('recordId ::: ' + recordId);
        WorkOrder wo = [SELECT Id, Asset.Name FROM WorkOrder WHERE Id = :recordId LIMIT 1];
        System.debug('assetName ::: ' + wo.Asset.Name);

        return wo.Asset.Name;
        
    }
    
    /**
     * @Description
     * 	- 해당 Service Order정보 반환
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static WorkOrder getWorkOrder(Id recordId) {
        return [
            SELECT Id, OrderType__c, FM_isDirect__c, Status, IsDirectPaidService__c, 
            Case.FM_PartsWarranty__c,
            Case.FM_IsBilled__c, Case.isBilled__c, Case.checkBillingStatus__c
            FROM WorkOrder 
            WHERE Id = :recordId 
            LIMIT 1
        ];
    }

    /**
     * @Description
     * 	- 해당 Service Order에 등록된 장비번호를 통해 I/F로 스핀들 입고수리 부품 목록 조회
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static IF_ERP_Material_Classes.IF_CSPLUS_031_Res searchSpindle(String equipmentNumber) {
        try {
            // WorkOrder 조회
            WorkOrder wo = [
                SELECT Id, Asset.SoldTo__r.CustomerCode__c, Asset.Name
                FROM WorkOrder 
                WHERE Id = :equipmentNumber 
                LIMIT 1
            ];

            // 필수 파라미터 설정
            IF_ERP_Material_Classes.IF_CSPLUS_031_Req request = new IF_ERP_Material_Classes.IF_CSPLUS_031_Req();
            request.I_VKORG = '1846';
            request.I_EQUNR = wo.Asset.Name;
            // request.I_KUNNR = wo.Asset?.Account?.CustomerCode__c; // 고객번호
            request.I_KUNNR = wo.Asset?.SoldTo__r?.CustomerCode__c; // 고객번호
            
            // IF_CSPLUS_031 인터페이스 호출
            IF_ERP_Material ifErpMaterial = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_031_Res response = ifErpMaterial.IF_CSPLUS_031(request);
            system.debug('response ::: ' + response);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀 데이터로 부품 등록 시, 해당 부품의 Plant 정보가 184S, 1846인지 조건 확인
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static String checkProduct(String prCodesStr){
        String missingStr = '';
        Set<String> missingPrCodes = new Set<String>();

        List<String> prCodeList = prCodesStr.split(',');
        Set<String> prCodes = new Set<String>();
        if(prCodeList.size()>0){
            for(String pr : prCodeList){
                prCodes.add(pr);
            }
            System.debug('prCodeList ::: '+prCodeList);
            System.debug('prCodes ::: '+prCodes);
        }

        if(!prCodes.isEmpty()){
            List<Product2> prList = [SELECT ID, ProductCode FROM Product2 WHERE Plant__c LIKE '%184S%' AND Plant__c LIKE '%1846%' AND ProductCode IN :prCodes];
            if(prList.size()>0){
                if(prList.size() != prCodes.size()){
                    Set<String> foundCodes = new Set<String>();
                    for (Product2 pr : prList) {
                        foundCodes.add(pr.ProductCode);
                    }

                    // prCodes 중 누락된 항목 계산
                    missingPrCodes = prCodes.clone();
                    missingPrCodes.removeAll(foundCodes);

                    if (!missingPrCodes.isEmpty()) {
                        System.debug('Missing ProductCodes ::: ' + missingPrCodes);
                        missingStr = String.join(new List<String>(missingPrCodes), ',');
                    }
                }
            }else{
                missingStr = String.join(new List<String>(prCodes), ',');
            }
        }
        System.debug('missingStr ::: ' + missingStr);
        return missingStr; 
    }

    /**
     * @Description
     * 	- 품번으로 Product 조회
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static Product2 getProductByCode(String productCode) {
        try {
            List<Product2> products = [
                SELECT Id, ProductCode, Name, FM_MaterialDetails__c,
                       WeightUnit__c, Replacement__c, 
                       ExpectedPrice__c, ProductSpec__c
                FROM Product2 
                WHERE ProductCode = :productCode
                LIMIT 1
            ];
            return !products.isEmpty() ? products[0] : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 실시간 대리점 부품 재고 조회 I/F
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static Map<String, Object> searchDealerStock(String productId, String partAmount) {
        try {
            // 1. ProductCode로 Product2 레코드 조회
            List<Product2> products = [SELECT Id, ProductCode 
                                       FROM Product2 
                                       WHERE Id = :productId 
                                       LIMIT 1];
            
            if(products.isEmpty()) {
                throw new AuraHandledException('해당 품번의 제품을 찾을 수 없습니다.');
            }
            
            String productRecordId = products[0].Id;
            String productCode = products[0].ProductCode;
            
            // 2. 기존 인터페이스 호출 (샘플 데이터 사용)
            IF_ERP_Material_Classes.IF_CSPLUS_021_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_021_Req();
            IF_ERP_Material_Classes.IF_CSPLUS_021_I_ORG I_ORG = new IF_ERP_Material_Classes.IF_CSPLUS_021_I_ORG();
            
            req.I_USERID = 'MITP0002';  // ERP userid
            req.I_MATNR = productCode;  // Material Number
            req.I_ORG = I_ORG;
            
            // 인터페이스 호출
            IF_ERP_Material instance = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_021_Res response = instance.IF_CSPLUS_021(req);

            System.debug('인터페이스 결과::::'+JSON.serialize(response.ES_INFO));

            // 3. 대리점 재고 정보 조회 (실제 productId 사용)
            String queryWhere=' WHERE Part__c=\''+productId+'\' AND Dealer__c != \'\'';
            if(partAmount != ''){
                queryWhere += ' AND AvailableQuantity__c >='+partAmount;
            }
            // 2025-04-24 현재 사용중인 대리점만 조회하도록 sub쿼리 추가, 서일태
            queryWhere += ' AND Dealer__c IN ( SELECT AccountId';
            queryWhere += ' FROM User where UserType = \'PowerPartner\'  AND Profile.Name =\'DNS CS Parts_Partner\' AND IsActive =true )';
            String query = 'SELECT Id, Dealer__c, Dealer__r.Name, Dealer__r.CustomerCode__c, FM_Unit__c, AvailableQuantity__c,'+
                            'CurrentStockQuantity__c, OrderRequiredQuantity__c, WarrantyRequiredQuantity__c'+
                        ' FROM DealerStock__c ';
    
            List<SObject> sObj = Database.query(query+queryWhere);
            List<DealerStock__c> dealerStocks = (List<DealerStock__c>) sObj;

            // 4. 결과 맵 생성
            Map<String, Object> result = new Map<String, Object>();
            
            // 4.1 인터페이스 결과 추가
            if (response != null && response.ES_INFO != null) {
                result.put('ES_INFO', response.ES_INFO);
            }

            // 4.2 대리점 재고 정보 추가
            List<Map<String, Object>> stockList = new List<Map<String, Object>>();
            for(DealerStock__c stock : dealerStocks) {
                Map<String, Object> stockInfo = new Map<String, Object>();
                stockInfo.put('DEALER_CD', stock.Dealer__r.CustomerCode__c);
                stockInfo.put('NAME1', stock.Dealer__r.Name);
                stockInfo.put('CURRENT_QTY', stock.CurrentStockQuantity__c);
                stockInfo.put('AVAIL_QTY', stock.AvailableQuantity__c);
                stockInfo.put('ORDER_QTY', stock.OrderRequiredQuantity__c+stock.WarrantyRequiredQuantity__c);
                stockInfo.put('UNIT', stock.FM_Unit__c);
                stockInfo.put('DEALER', stock.Dealer__c);
                stockList.add(stockInfo);
            }
            result.put('productCode', productCode);
            result.put('stockList', stockList);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- CRM에 등록된 대리점별 해당 부품 재고 조회
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static List<Map<String, Object>> searchMultipleProductStock(List<Map<String, Object>> products) {
        try {
            List<Map<String, Object>> result = new List<Map<String, Object>>();
            String queryWhere = ' WHERE Dealer__c != \'\'';
            if(!products.isEmpty()){
                String conditions = '';
                
                for(Integer i = 0; i < products.size(); i++){
                    Map<String, Object> product = products[i];
                    String proId = (String)product.get('ProductId');
                    Decimal quant = (Decimal)product.get('PartAmount');
                    
                    if(i > 0){
                        conditions += ' OR ';
                    }

                    conditions += ' (Part__c =\'' + proId + '\' AND AvailableQuantity__c >=' + quant + ')';
                }
                queryWhere += ' AND (' + conditions + ')';
            }

            String query = 'SELECT Id, Dealer__c, Dealer__r.Name, Dealer__r.CustomerCode__c, FM_Unit__c, AvailableQuantity__c,'+
                                  'Part__c, Part__r.Name, Part__r.ProductCode, CurrentStockQuantity__c, OrderRequiredQuantity__c,'+
                                  'WarrantyRequiredQuantity__c,BlockQuantity__c'+
                            ' FROM DealerStock__c ';
            System.debug('쿼리:::'+query+queryWhere);
            List<SObject> sObj = Database.query(query+queryWhere);
            List<DealerStock__c> dealerStocks = (List<DealerStock__c>) sObj;

            //대리점 선택 할 때 배송처 값 넣어주기 위해서 쿼리해옴
            Map<String, Id> serviceTerritoryMap = new Map<String, Id>();
            List<ServiceTerritory> serviceTerritories = [SELECT Name, Id FROM ServiceTerritory WHERE ServiceWorkCenter__c != null AND IsActive = true AND PlanningPlant__c = '184S'];

            for (ServiceTerritory st : serviceTerritories) {
                serviceTerritoryMap.put(st.Name, st.Id);
            }

            Map<String, Set<String>> dealerPartsMap = new Map<String, Set<String>>();
            Map<String, Map<String, Object>> dealerMap = new Map<String, Map<String, Object>>();
    
            for (DealerStock__c ds : dealerStocks) {                
                String dealerId = ds.Dealer__r.CustomerCode__c;
    
                if (!dealerPartsMap.containsKey(ds.Dealer__c)) {
                    dealerPartsMap.put(ds.Dealer__c, new Set<String>());
                }
                dealerPartsMap.get(ds.Dealer__c).add(ds.Part__c);
    
                if (!dealerMap.containsKey(ds.Dealer__c)) {
                    Map<String, Object> dealerInfo = new Map<String, Object>();
                    dealerInfo.put('DEALER_CD', dealerId);
                    dealerInfo.put('NAME1', ds.Dealer__r.Name);
                    dealerInfo.put('CURRENT_QTY', ds.CurrentStockQuantity__c);
                    dealerInfo.put('AVAIL_QTY', ds.AvailableQuantity__c);
                    dealerInfo.put('ORDER_QTY', ds.OrderRequiredQuantity__c+ds.WarrantyRequiredQuantity__c);
                    dealerInfo.put('UNIT', ds.FM_Unit__c);
                    dealerInfo.put('DEALER', ds.Dealer__c);
                    dealerMap.put(ds.Dealer__c, dealerInfo);
                }
            }
    
            for (String dealerId : dealerPartsMap.keySet()) {
                Boolean satisfiesAllParts = true;
                for (Map<String, Object> product : products) {
                    String proId = (String)product.get('ProductId');
                    if (!dealerPartsMap.get(dealerId).contains(proId)) {
                        satisfiesAllParts = false;
                        break;
                    }
                }
                if (satisfiesAllParts) {
                    result.add(dealerMap.get(dealerId));
                }
            }
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 해당 Service Order에 등록된 Product Request 중 마지막 Sequence Number 추출
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static String getLastSequence(String recordId){
        String seqNo = '0000';
        List<ProductRequest> prList = [SELECT Id, Seq__c FROM ProductRequest 
                                            WHERE IsDealerPortalPartition__c = FALSE 
                                            AND WorkOrderId = :recordId AND Seq__c != ''
                                            ORDER BY Seq__c ASC];
        if(prList.size()>0){
            for (ProductRequest pr : prList) {
                if (!pr.Seq__c.startsWith('9')) {
                    seqNo = pr.Seq__c;
                }
            }
        }

        return seqNo;
    }


    /*
     * @Description 
     *  - 부품 청구 Wrapper
     */ 
    public class ChargingPartWrapper{
        @AuraEnabled public String ProductRequestRecordId           { get;set; }    //레코드 ID
        @AuraEnabled public String ProductId                        { get;set; }    //품목 ID
        @AuraEnabled public String ProgressStatus                   { get;set; }    //결재진행상태
        @AuraEnabled public String ProductName                      { get;set; }    //품명
        @AuraEnabled public String ProductCode                      { get;set; }    //품번
        @AuraEnabled public Integer PartAmount                      { get;set; }    //수량
        @AuraEnabled public Integer PartInventory                   { get;set; }    //재고
        @AuraEnabled public String HandInFlag                       { get;set; }    //반납여부
        @AuraEnabled public String TransportDivision                { get;set; }    //탁송구분
        @AuraEnabled public String ShipTo                           { get;set; }    //배송처
        @AuraEnabled public String WorkCenterId                     { get;set; }    //대리점 ID
        @AuraEnabled public String WorkCenterName                   { get;set; }    //대리점명
        @AuraEnabled public String Weight                           { get;set; }    //무게
        @AuraEnabled public String UnitCode                         { get;set; }    //단위
        @AuraEnabled public Boolean EditMode                        { get;set; }    //수정모드
        @AuraEnabled public String ProductType                      { get;set; }    //구분(신품/교체품)
        @AuraEnabled public String PartNo                           { get;set; }    //순번
        @AuraEnabled public String Product2Id                       { get;set; }    //제품 ID
        @AuraEnabled public Integer PartAmountUnit                  { get;set; }    //단가
        @AuraEnabled public String Description                      { get;set; }    //설명
        @AuraEnabled public String PricebookEntryId                 { get;set; }    //제품가격
        @AuraEnabled public String Amount                           { get;set; }    //총 금액
    }

    /*
     * @Description 
     *  - 부품 조회 결과 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - message 	    : 조회 결과 Message
     *  - partsList 	: 조회된 부품 목록
     */ 
    public class PartsListWrapper {
        @AuraEnabled public Boolean         isSuccess       { get;set; }
        @AuraEnabled public String          message         { get;set; }
        @AuraEnabled public List<Product2>  partsList       { get;set; }

        public PartsListWrapper() {
            this.isSuccess = true;
            this.message = '';
            this.partsList = new List<Product2>();
        }
    }


    /**
     * @Description
     * 	- 부품 청구하여 Product Request upsert
     * @author Hayeong Min
    **/
    @AuraEnabled
    public static String upsertPRData(List<ChargingPartWrapper> requestProductList, String workOrderId) {
        List<ProductRequest> rpUpsertList = new List<ProductRequest>();
        List<DealerFreeDispatch__c> dealerDispatchList = new List<DealerFreeDispatch__c>();
        Set<String> saveSeqNum = new Set<String>();
        List<Database.Error> errList = new List<Database.Error>();
        String ticketId = '';
        String assetId = '';
        String resouceId = '';

        try {
            WorkOrder wo = [SELECT CaseId, AssetId, FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, OrderType__c,
                            Case.FailureArea__c, Case.FailureAreaDetail__c, Case.FailurePhenomenon__c, 
                            IsDirectPaidService__c, Worker__c, Worker__r.FM_isDirect__c
                            FROM WorkOrder WHERE Id =: workOrderId];

            if(String.isNotEmpty(wo.CaseId)) ticketId = wo.CaseId;
            if(String.isNotEmpty(wo.AssetId)) assetId = wo.AssetId;
            if(String.isNotEmpty(wo.Worker__c)) resouceId = wo.Worker__c;

            if(String.isEmpty(wo.FailureArea__c)|| String.isEmpty(wo.FailureAreaGroup__c) || String.isEmpty(wo.FailurePhenomenon__c)){
                if(String.isEmpty(wo.Case.FailureArea__c)|| String.isEmpty(wo.Case.FailureArea__c) || String.isEmpty(wo.Case.FailureArea__c)){
                    return System.Label.DNS_E_EnterTicketFailureInfo;
                }
            }

            if(wo.IsDirectPaidService__c == true && wo.OrderType__c != '202'){
                return System.Label.DNS_E_CheckDirectWarranty;
            }

            if(wo.IsDirectPaidService__c == true && wo.Worker__r.FM_isDirect__c == false){
                return System.Label.DNS_E_NoDirectResource;
            }
            
        } catch (Exception e) {
            System.debug(e.getLineNumber() + '__' +e.getMessage());
            return '오류 발생: ' + e.getMessage();
        }

        for(ChargingPartWrapper wrapper:requestProductList){
            saveSeqNum.add(wrapper.PartNo);
        }

        //인터페이스 보내기
        System.debug('requestProductList ::: '+ requestProductList);
        System.debug('requestProductListJSON ::: '+ JSON.serialize(requestProductList));
        IFCSPLUS010Wrapper rw = get_IF_CSPLUS_010(ticketId, workOrderId, assetId, resouceId, requestProductList);
        if(String.isNotEmpty(rw.errMessage)){
            return rw.errMessage;
        }

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res ifres = rw.response;


        saveSeqNum = rw.seqSet;
        Map<String, List<String>> resultMap = rw.resultMap;
        System.debug('resultMap ::: '+resultMap);
        
        System.debug('인터페이스 결과 ifres ::'+ifres);

        if(ifres.O_RETURN.TYPE == 'S'){
            //부품진행상태
            String woNum = [SELECT ServiceOrderNumber__c FROM WorkOrder WHERE Id =: workOrderId].ServiceOrderNumber__c;
            IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res ifres2 = getIF033(woNum);
            System.debug('부품 진행상태 인터페이스 결과::'+ifres2);

            if(ifres2.O_RETURN.TYPE == 'S'){
                Map<String, Id> productIdMap = new Map<String, Id>();
                Map<String, Id> serviceTerritoryIdMap = new Map<String, Id>();
                Map<String, Id> workCenterIdMap = new Map<String, Id>();

                //=============================================
                Set<String> matnrSet = new Set<String>();
                Set<String> soldToSet = new Set<String>();
                Set<String> vendorSet = new Set<String>();
                Map<String, Id> matnrMap = new Map<String, Id>();
                Map<String, Id> soldToMap = new Map<String, Id>();
                Map<String, Id> vendorMap = new Map<String, Id>();

                for(IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res_T_O_LIST i : ifres2.T_O_LIST){
                    //MATNR 
                    if(i.MATNR != '') matnrSet.add(i.MATNR);

                    //SOLDTO
                    String soldto = i.SOLDTO.replaceFirst('^0+', '');
                    soldToSet.add(soldto);

                    //VENDOR
                    if(i.VENDOR != '') vendorSet.add(i.VENDOR);
                }

                if(matnrSet.size()>0){
                    List<Product2> prList = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN :matnrSet];
                    if(prList.size()>0){
                        for(Product2 pr : prList){
                            if(!matnrMap.containsKey(pr.ProductCode)){
                                matnrMap.put(pr.ProductCode, pr.Id);
                            }
                        }
                    }
                }

                if(soldToSet.size()>0){
                    List<ServiceTerritory> serviceTerritoryList = [SELECT Id, WCID__c FROM ServiceTerritory WHERE WCID__c IN :soldToSet];
                    if(serviceTerritoryList.size()>0){
                        for(ServiceTerritory st : serviceTerritoryList){
                            if(!soldToMap.containsKey(st.WCID__c)){
                                soldToMap.put(st.WCID__c, st.Id);
                            }
                        }
                    }
                }

                if(vendorSet.size()>0){
                    List<ServiceTerritory> workCnterList = [SELECT ServiceWorkCenter__c, WCCode__c FROM ServiceTerritory WHERE WCCode__c IN :vendorSet];
                    if(workCnterList.size()>0){
                        for(ServiceTerritory st : workCnterList){
                            if(!vendorMap.containsKey(st.WCCode__c)){
                                vendorMap.put(st.WCCode__c, st.ServiceWorkCenter__c);
                            }
                        }
                    }
                }

                System.debug('matnrMap ::: '+matnrMap);
                System.debug('soldToMap ::: '+soldToMap);
                System.debug('vendorMap ::: '+vendorMap);


                for (IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res_T_O_LIST i : ifres2.T_O_LIST) {
                    if (!serviceTerritoryIdMap.containsKey(i.MATNR) && matnrMap.containsKey(i.MATNR)) {
                        productIdMap.put(i.MATNR, matnrMap.get(i.MATNR));
                    }

                    //SOLDTO
                    String soldto = i.SOLDTO.replaceFirst('^0+', '');
                    if (!serviceTerritoryIdMap.containsKey(i.SOLDTO) && soldToMap.containsKey(soldto)) {
                        serviceTerritoryIdMap.put(i.SOLDTO, soldToMap.get(soldto));
                    }

                    //VENDOR
                    if (!workCenterIdMap.containsKey(i.VENDOR) && i.VENDOR != '' && vendorMap.containsKey(i.VENDOR)) {
                        workCenterIdMap.put(i.VENDOR, vendorMap.get(i.VENDOR));
                    }
                }
                
                // 부품 청구 Upsert

                //이건 기존에 해당 오더에 등록된 ProductRequest
                List<ProductRequest> prSeqList = [SELECT Id, Seq__c FROM ProductRequest WHERE WorkOrderId = :workOrderId];
                for(ProductRequest pr : prSeqList){
                    String key = workOrderId + '_' + pr.Id; 
                    if(resultMap.containsKey(key)){ // Seq 없는 등록된 Product Request
                    System.debug('resultMap.get(pr.Id) ::: '+resultMap.get(key));
                        pr.Status = 'Approved';
                        pr.Seq__c = resultMap.get(key)[0];
                    }
                }
                update prSeqList;

                //여긴 아예 새로 생성해야 하는 Product Request
                List<ProductRequest> existPrList = [SELECT Id, WorkOrderId, Seq__c
                                                   FROM ProductRequest 
                                                   WHERE WorkOrderId = :workOrderId 
                                                   AND Seq__c != NULL];
                Map<String, ProductRequest> prMap = new Map<String, ProductRequest>();
                for(ProductRequest pr : existPrList){
                    prMap.put(pr.Seq__c, pr);
                }
                
                for (IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res_T_O_LIST i : ifres2.T_O_LIST) {
                    ProductRequest instance;
                    System.debug('i.MATNR ::: '+i.MATNR);
                    String productId = productIdMap.get(i.MATNR);
                    System.debug('productId ::: '+productId);
                    String serviceTerritoryId = serviceTerritoryIdMap.get(i.SOLDTO);
                    String workCenterId = workCenterIdMap.get(i.VENDOR);

                    if(prMap.containsKey(i.QMSEQ)) {
                        instance = prMap.get(i.QMSEQ);
                    }else{
                        instance = new ProductRequest(); // 새 레코드 생성
                        instance.Seq__c = i.QMSEQ; 
                        instance.PartsRequestDate__c = System.now().date(); // 부품 요청 날짜
                    }

                    System.debug('productId ::: '+productIdMap.get(i.MATNR));
                    instance.Product__c = productId;
                    instance.Quantity__c = Decimal.valueOf(i.MENGE); // 수량
                    if(workCenterId != null) instance.WorkCenterId__c = workCenterId; //대리점
                    instance.Status = 'Approved'; // 상태
                    instance.TransportsDivision__c = i.VSBED; // 탁송구분
                    instance.ShipTo__c = (serviceTerritoryId == null) ? '고객직송' : serviceTerritoryId; //requestProductList[0].ShipTo
                    instance.WorkOrderId = workOrderId; 
                    instance.CaseId = ticketId;
                    if(i.QMSEQ=='0010' && i.SPIND != ''){
                        instance.ProductType__c = i.SPIND; //스핀들구분
                    }
                    instance.ReturnStatus__c = i.RETURN_YN;
                    

                    System.debug('instance :: '+instance);
                    rpUpsertList.add(instance);
                }
            } else {
                System.debug('Error code: ' + ifres2.O_RETURN.CODE);
                System.debug('Error message: ' + ifres2.O_RETURN.MESSAGE);
                return '부품 진행상태 인터페이스 오류 발생: ' +ifres2.O_RETURN.MESSAGE;
            }
        } else {
            System.debug('Error code: ' + ifres.O_RETURN.CODE);
            System.debug('Error message: ' + ifres.O_RETURN.MESSAGE);
            return '인터페이스 오류 발생: ' +ifres.O_RETURN.MESSAGE;
        }

        Savepoint sp = Database.setSavepoint(); 
        try {
            // ProductRequest upsert
            System.debug('Upserting ProductRequest records: ' + JSON.serialize(rpUpsertList));
            Database.UpsertResult[] rslt = Database.upsert(rpUpsertList, false);
            System.debug('저장 결과::'+rslt);
            for(Database.UpsertResult r: rslt) {
                if(!r.isSuccess()) {
                    System.debug('Upsert error: ' + r.getErrors());
                    return '오류 발생: ' + r.getErrors()[0].getMessage();
                }
            }

            // 탁송구분이 [대리점] 일 때, 딜러무상출고 Insert, 딜러재고 Update
            Map<String, DealerStock__c> dealerStockMap = new Map<String, DealerStock__c>();
            List<ProductRequest> prList = [SELECT Id, TransportsDivision__c, WorkCenterId__c, Product__c, Quantity__c
                                           FROM ProductRequest 
                                           WHERE TransportsDivision__c IN ('1', '2', '3', '4') 
                                           AND WorkOrderId =: workOrderId
                                           AND Seq__c IN:saveSeqNum];
            System.debug('prList :: '+ prList);
            for(ProductRequest p : prList) {
                DealerFreeDispatch__c dealerDispatch = new DealerFreeDispatch__c();
                dealerDispatch.OrderItem__c = p.Id;
                dealerDispatch.ShippingType__c = p.TransportsDivision__c;
                dealerDispatch.Status__c = '1';
                dealerDispatch.SourceSystem__c = 'CRM';
                dealerDispatch.Dealer__c = p.WorkCenterId__c;
                
                dealerDispatchList.add(dealerDispatch);
                
                // 딜러재고에 예약수량, 가용수량 Update 
                String mapKey = p.WorkCenterId__c + ':' + p.Product__c;
                if (!dealerStockMap.containsKey(mapKey)) {
                    DealerStock__c ds = [SELECT Id, WarrantyRequiredQuantity__c, CurrentStockQuantity__c, OrderRequiredQuantity__c, BlockQuantity__c, AvailableQuantity__c
                                        FROM DealerStock__c 
                                        WHERE Dealer__c =: p.WorkCenterId__c
                                        AND Part__c =: p.Product__c LIMIT 1 FOR UPDATE];
                    dealerStockMap.put(mapKey, ds);
                }

                DealerStock__c ds = dealerStockMap.get(mapKey);
                ds.WarrantyRequiredQuantity__c = (ds.WarrantyRequiredQuantity__c + p.Quantity__c);
                ds.AvailableQuantity__c = (ds.CurrentStockQuantity__c - ds.OrderRequiredQuantity__c - ds.WarrantyRequiredQuantity__c - ds.BlockQuantity__c);
            }
            System.debug('dealerDispatchList :: '+ dealerDispatchList);
            insert dealerDispatchList;
            update dealerStockMap.values();

            return 'SUCCESS';

        } catch (Exception e) {
            Database.rollback(sp);
            return '오류 발생: ' + e.getMessage();
        }
    }

    /**
     * @Description
     * 	- 부품 청구 I/F
     * @author Hayeong Min
    **/
    public static IFCSPLUS010Wrapper get_IF_CSPLUS_010(String ticketId, String workOrderId, String assetId, String resouceId, List<ChargingPartWrapper> requestProductList){
        IFCSPLUS010Wrapper rw = new IFCSPLUS010Wrapper();
        System.debug('IF_CSPLUS_010 START ::: caseId: '+ticketId+' woID: '+workOrderId+' assID: '+assetId+' resID: '+resouceId);
        System.debug('IF_CSPLUS_010 START ::: List: '+requestProductList);

        Case ticket = [SELECT Id, FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c, AccountId, Requester__c, Requester__r.Name,
                              Requester__r.Phone, Requester__r.MobilePhone, InternalTicketType__c, Asset.SoldTo__c, FM_PartsWarranty__c, Asset.AccountId,
                              BreakdownDateTime__c, ApplicationDateTime__c, RepairRequestDateTime__c
                       FROM Case 
                       WHERE Id =: ticketId];
        WorkOrder wo = [SELECT Id, OrderType__c, ServiceTerritoryId, ServiceTerritory.Name, ServiceOrderNumber__c, FM_isDirect__c, 
                               Account.CustomerCode__c, SPTask__c, SoldTo__c, SoldTo__r.CustomerCode__c,ReceptionDetail__c, 
                               FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, IsDirectPaidService__c,
                               Noti_Number__c, ScheduledDispatchTime__c
                       FROM WorkOrder 
                       WHERE Id =: workOrderId]; 
        Asset equip = [SELECT Id, Name, MachineName__c, SerialNumber
                       FROM Asset 
                       WHERE Id =: assetId];
        String warranty = ticket.FM_PartsWarranty__c;

        Account acc = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode, ShippingStreet, ShippingCity
                       FROM Account
                       WHERE Id =: ticket.Asset.AccountId];
        ServiceResource resouce = [SELECT Id, StaffNumber__c, Service_Territory__c, Service_Territory__r.WCID__c, Service_Territory__r.WCCode__c 
                                   FROM ServiceResource 
                                   WHERE Id = :resouceId];
        List<ProductRequest> proReq = [SELECT Id, WorkCenterId__c, WorkCenterId__r.Name, Quantity__c, ProductType__c, Seq__c, TransportsDivision__c, Product__r.ProductCode, ReturnStatus__c
                                       FROM ProductRequest
                                       WHERE WorkOrderId =: workOrderId AND Status='Approved' 
                                       AND IsDealerPortalDelete__c = false 
                                    //    AND IsDealerPortalPartition__c = false 
                                       ORDER BY Seq__c];
        //Last SeqNumber
        String lastNumStr = getLastSequence(workOrderId);
        if(lastNumStr.right(1) != '0'){
            lastNumStr = lastNumStr.substring(0, lastNumStr.length() - 1) + '0';
        }
        Integer lastNum = Integer.valueOf(lastNumStr);
        
        Set<String> seqSet= new Set<String>();
        Map<String, List<String>> seqListMap = new Map<String, List<String>>();


        String isWarranty = ''; //유상 여부 (X:유상)
        String isDirect = ''; //직영유상 여부 (X:직영유상)
        if(wo.OrderType__c == '202' || wo.OrderType__c == '215'){
            isWarranty = 'X';
        }
        if(isWarranty == 'X'){//유상일 때
            if(wo.FM_isDirect__c) {
                isDirect = 'X';
            }
        }

        String qmCode = ''; // 하자유형 코드
        switch on wo.OrderType__c {
            when '201', '202' { qmCode = '01'; }
            when '204', '218' { qmCode = '06'; }
            when '214', '215' { qmCode = '10'; } // 유.무상 SP입고수리
            when '203'        { qmCode = '11'; }
            when '216'        { qmCode = '12'; }
            when '217'        { qmCode = '14'; }
            when '219', '220' { qmCode = '20'; }
            when else         { qmCode = '19'; }
        }

        Boolean isSpin = false; //true: 스핀들구분O, false:스핀들구분X
        Boolean isSoldAcc = true; //true: 고객사코드, false: 워크센터코드         

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER i_header = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER();

        //FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c
        String failureArea = wo.FailureAreaValue__c;
        String failureAreaDetail = wo.FailureAreaGroupValue__c;
        String failurePhenomenon = wo.FailurePhenomenonValue__c;
        if(String.isEmpty(wo.FailureAreaValue__c) || String.isEmpty(wo.FailureAreaGroupValue__c) || String.isEmpty(wo.FailurePhenomenonValue__c)){
            failureArea = ticket.FailureAreaValue__c;
            failureAreaDetail = ticket.FailureAreaDetailValue__c;
            failurePhenomenon = ticket.FailurePhenomenonValue__c;
        }

        i_header.QMCOD = qmCode; // 하자유형 코드
        i_header.WHR_YN = (wo.OrderType__c == '218' || wo.OrderType__c == '219') ? 'Y':'N'; // P-Claim 입고처리 : Y / P - Claim : N, Value Fund : Y, Customer Care : N
        i_header.OTGRP = failureArea + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
        i_header.OTEIL = failureAreaDetail.right(2); //고장부위 (중) Value
        i_header.FEGRP = failureArea + failureAreaDetail + '00'; // 대 + 중 + '00'
        i_header.FECOD = failurePhenomenon; //고장현상 Value

        DateTime failureDate = ticket.BreakdownDateTime__c != null ? ticket.BreakdownDateTime__c : ticket.ApplicationDateTime__c;
        i_header.TRBL_DT = failureDate.format('yyyyMMdd'); //'20241101'; //고장일자
        i_header.TRBL_TM = failureDate.format('HH:mm:ss'); //'110000'; //고장시간
        i_header.RECV_DT = ticket.ApplicationDateTime__c.format('yyyyMMdd'); //'20241101'; //접수일자
        i_header.RECV_TM = ticket.ApplicationDateTime__c.format('HH:mm:ss'); //'120000'; //접수시간
        i_header.LTRMN = ticket.RepairRequestDateTime__c.format('yyyyMMdd');//'20241101'; //수리요청일자
        i_header.LTRUR = ticket.RepairRequestDateTime__c.format('HH:mm:ss');//'120000'; //수리요청일시

        i_header.QMNAM = UserInfo.getName(); //상담자명(기술상담사)
        i_header.ARBPL = resouce.Service_Territory__r.WCCode__c; //워크센터 코드
        i_header.DAUNO ='1'; //작업요구시간(고정값)
        i_header.S_DATE = wo.ScheduledDispatchTime__c.format('yyyyMMdd');//작업시작일자 = 출동예정일시
        i_header.INPUT_NO ='1';
        i_header.PERNR = resouce.StaffNumber__c; //서비스요원 코드
        i_header.TYPBZ = equip.MachineName__c; //장비 기종
        i_header.SERNR = equip.SerialNumber; // 장비 호기정보

        System.debug('IF_CSPLUS_010 i_header ::: '+i_header);

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2 i_header2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2();        
        i_header2.TEL_NUMBER = ticket.Requester__r.MobilePhone != null ? ticket.Requester__r.MobilePhone:ticket.Requester__r.Phone; //요청자의 번호
        i_header2.ERNAM = 'SYSTEM'; //접수자
        i_header2.POST_CODE1 = acc.ShippingPostalCode; //우편번호
        i_header2.STREET = acc.ShippingStreet;
        i_header2.CITY1 = acc.ShippingCity;
        i_header2.NAME1 = ticket.Requester__r.Name; //고객명(=요청자명)
        i_header2.AENAM = 'SYSTEM'; //변경자 ID
        i_header2.KUNNR = acc.CustomerCode__c; // 고객사 코드
        i_header2.NAME = acc.Name; //업체명
        
        System.debug('IF_CSPLUS_010 i_header2 ::: '+i_header2);
        
        List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST> t_i_list = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST>();
        List<String> transportDivisions = new List<String>{'1', '2', '3', '4'}; //대리점
        String spindelType = '';
        //기존 부품청구 건들
        Set<Id> wcSet = new Set<Id>();
        Map<Id, String> wcMap = new Map<Id, String>();
        for(ProductRequest pr : proReq){
            if(String.isNotEmpty(pr.WorkCenterId__c)){
                wcSet.add(pr.WorkCenterId__c);
            } 
        }
        List<ServiceTerritory> wcList = [SELECT Id, WCCode__c, ServiceWorkCenter__c FROM ServiceTerritory WHERE ServiceWorkCenter__c IN :wcSet];
        for(ServiceTerritory wc : wcList){
            if(String.isNotEmpty(wc.ServiceWorkCenter__c) && String.isNotEmpty(wc.WCCode__c)){
                wcMap.put(wc.ServiceWorkCenter__c, wc.WCCode__c);
            }
        }
        System.debug('wcMap ::: '+ wcMap);
        List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2> t_i_list2 = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2 tiItem2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2();
        tiItem2.TEXT = wo.ReceptionDetail__c;
        t_i_list2.add(tiItem2);

        for(ProductRequest pr : proReq){
            IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST tiItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST();
            String tranDiv = ''; //공급구분
            if(transportDivisions.contains(pr.TransportsDivision__c)){
                tranDiv = 'N';
            } else {
                tranDiv = 'L';
            }

            if(pr.ProductType__c != null){
                spindelType = pr.ProductType__c;
                isSpin = true;
            }       
            String wcCode = '';
            if(wcMap.containsKey(pr.WorkCenterId__c)){
                wcCode = wcMap.get(pr.WorkCenterId__c);
            }            
            tiItem.SUPPLY_TP = tranDiv; // L:부품부청구(본사) , N:대리점구입(대리점)
            tiItem.VENDOR = wcCode; //ProductRequest 의 대리점 명
            tiItem.RSPOS = '0';// 부품예약순번
            tiItem.MENGE = String.valueOf(pr.Quantity__c); //수량  
            tiItem.RSNUM = '0';// 부품예약번호
            tiItem.SPIND = spindelType; //스핀들구분 
            tiItem.POSNR = pr.Seq__c; //순번 
            tiItem.VSBED = pr.TransportsDivision__c;// 탁송구분
            tiItem.MATNR = pr.Product__r.ProductCode; //부품번호(품번)
            tiItem.RETURN_YN = pr.ReturnStatus__c; //폐품반납

            t_i_list.add(tiItem);

            
            
        }
        System.debug('스핀들구분:::'+isSpin);
        
        //새로 부품청구 하는 건들\
        Set<Id> accSet = new Set<Id>();
        Map<Id,String> accMap = new Map<Id,String>();
        Map<String, String> acc_wcMap = new Map<String, String>(); 
        for(ChargingPartWrapper wrapper : requestProductList){ //부품 정보
            if(wrapper.WorkCenterName != null){
                System.debug('wrapper.WorkCenterId ::: ' + wrapper.WorkCenterId);
                accSet.add(wrapper.WorkCenterId);
            } 
        }

        if(accSet.size()>0){
            List<Account> accList = [SELECT Id, CustomerCode__c FROM Account WHERE Id IN :accSet];
            Map<String, String> accCodeMap = new Map<String, String>();
            for(Account account : accList){
                accCodeMap.put(account.CustomerCode__c, account.Id);
            }

            if(!accCodeMap.isEmpty()){
                List<ServiceTerritory> stList = [SELECT Id, WCCode__c, WCID__c FROM ServiceTerritory WHERE WCID__c IN : accCodeMap.keySet()];
                for(ServiceTerritory st : stList){
                    if(accCodeMap.containsKey(st.WCID__c)){
                        acc_wcMap.put(accCodeMap.get(st.WCID__c), st.WCCode__c);
                    }
                }
            }
        }
        System.debug('acc_wcMap :: '+acc_wcMap);
        for(ChargingPartWrapper wrapper : requestProductList){ //부품 정보
            System.debug('wrapper ::: ' + wrapper);
            lastNum += 10;        
            wrapper.PartNo = String.valueOf(lastNum).leftPad(4, '0');// 4자리 숫자로 포맷 (앞에 0 추가)
            seqSet.add(wrapper.PartNo);

            String key = workOrderId + '_';
            key += String.isNotEmpty(wrapper.ProductRequestRecordId) ? wrapper.ProductRequestRecordId : 'New';
            
            if(seqListMap.containsKey(key)){
                List<String> existList = seqListMap.get(key);
                existList.add(wrapper.PartNo);
                seqListMap.put(key, existList);
            }else{
                List<String> newList = new List<String>();
                newList.add(wrapper.PartNo);
                seqListMap.put(key, newList);
            }


            IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST tiItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST();
            String tranDiv = ''; //공급구분
            if(transportDivisions.contains(wrapper.TransportDivision)){
                tranDiv = 'N';
            } else {
                tranDiv = 'L';
            }

            if(wrapper.ProductType != null){
                isSpin = true;
                spindelType = wrapper.ProductType;
            }
            String wcCode = '';
           
            if(wrapper.WorkCenterName != null){
                if(acc_wcMap.containsKey(wrapper.WorkCenterId)){
                    wcCode = acc_wcMap.get(wrapper.WorkCenterId);
                }else{
                    rw.errMessage = '해당 대리점 정보가 조회되지 않습니다.';
                    return rw;
                }
            }  
            System.debug('wcCode ::: ' + wcCode);          
            tiItem.SUPPLY_TP = tranDiv; // L:부품부청구(본사) , N:대리점구입(대리점)
            tiItem.VENDOR = wcCode; //ProductRequest 의 대리점 명
            tiItem.RSPOS = '';// 부품예약순번
            tiItem.MENGE = String.valueOf(wrapper.PartAmount); //수량  
            tiItem.RSNUM = ''; // 부품예약번호
            tiItem.SPIND = spindelType; //스핀들구분
            tiItem.POSNR = wrapper.PartNo; //순번 
            tiItem.VSBED = wrapper.TransportDivision;// 탁송구분
            tiItem.MATNR = wrapper.ProductCode; //부품번호(품번)
            tiItem.RETURN_YN = 'N'; //폐품반납

            t_i_list.add(tiItem);
        }

        rw.seqSet = seqSet;
        rw.resultMap = seqListMap;

        System.debug('seqListMap :: '+ seqListMap);
        
        String shiptoResouce = '';        
        if(ticket.InternalTicketType__c == 'Failure receipt' && isSpin
            && (wo.OrderType__c == '202' || wo.OrderType__c == '215') && isDirect == 'X'){ // 고장접수+유상체크+직영유상+스핀들부품: 고객사코드
            shiptoResouce = wo.SoldTo__r.CustomerCode__c;
        } else {
            if(requestProductList[0].ShipTo == '고객직송'){
                shiptoResouce = '9999999999';
            } else {
                shiptoResouce = [SELECT WCID__c FROM ServiceTerritory WHERE Id = :requestProductList[0].ShipTo].WCID__c; //배송처코드

            }
        }

        // 영업오더유형
        String docType='';      
        if(isSpin) {
            docType = 'YDOR';
        } else {
            if(wo.OrderType__c == '201'){
                docType = 'YDCO';
            } else if (wo.OrderType__c == '202') {
                if (warranty == 'N') {
                    docType = 'YDOW';
                }else {
                    docType = wo.IsDirectPaidService__c ? 'YDOW' : 'YDCO'; 
                }
            } else if (wo.OrderType__c == '215') {
                docType = 'YDOW'; 
            }  else if (wo.OrderType__c == '203' || wo.OrderType__c == '204' || wo.OrderType__c == '214' || wo.OrderType__c == '217' || wo.OrderType__c == '218') {
                docType = 'YDCO';
            } else if (wo.OrderType__c == '219') {
                docType='YDVF';
            } else {
                docType = 'YDCO';
            }
        }
        // 영업오더유형
        // String docType='';
        // if (wo.IsDirectPaidService__c) {
        //     docType='YDOW';
        // } else {
        //     if(isSpin) { //(유)스핀들 
        //         docType='YDOR';
        //     } else if(wo.OrderType__c == '215'){ // 유상SP입고수리
        //         docType='YDOW';
        //     } else if(wo.OrderType__c == '219'){
        //         docType='YDVF';
        //     } else if(wo.OrderType__c == '220'){
        //         docType='YDCO';
        //     } else if(isDirect=='X'){ //직영유상
        //         if(warranty == 'Y'){ //보증내
        //             docType='YDCO';
        //         } else { //보증외
        //             docType='YDOW';
        //         }
        //     } else {
        //         docType='YDCO';
        //     }
        // }
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req();
        req.I_AUFNR = wo.ServiceOrderNumber__c; //erp의 wo번호
        req.I_QMNUM = '0'+wo.Noti_Number__c; //noti번호        
        req.I_WARR_YN = warranty; // 보증여부 (Y : 보증내, N : 보증외) 
        req.I_MAT_CLICK = 'Y'; //부품요청 FLAG (Y:요청)
        req.I_NEW_CLICK = 'C';
        req.I_EQUNR = equip.Name; //장비번호 
        req.I_SKIP_SBOM = 'X'; //S-BOM
        req.I_SAFETY = (wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '218') ? 'X' : ''; //스핀들수리여부
        req.I_OUT_WARR = isWarranty; //유상여부
        req.I_DIRECT = isDirect; // 직영유상여부
        req.I_TASKLIST = (wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '218') ? wo.SPTask__c:''; // 스핀들입고수리 일 경우 필수
        req.I_MAT_CONFIRM = 'Y'; //sales_order 생성 FLAG
        req.I_SOLDTO = shiptoResouce; // 고객사 코드/배송처의 워크센터 코드
        req.I_DOC_TYPE = docType;// 영업오더유형
        req.I_PART_OUT_WARR = warranty; //부품보증 / 'X' : Out warranty

        req.I_HEADER = i_header;
        req.I_HEADER2 = i_header2;
        req.T_I_LIST = t_i_list;
        req.T_I_LIST2 = t_i_list2;
        
        System.debug('IF_CSPLUS_010 req ::: '+req);

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        instance.interfaceUtil.isInsertLog = false;
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res res = instance.IF_CSPLUS_010(req);
        System.debug('IF_CSPLUS_010 res ::: '+res);

        rw.response = res;
        System.debug('rw ::: '+rw);
        return rw;
    }

    /*
     * @Description 
     *  - CSPLUS_010 I.F 결과 Wrapper
     * 
     * @Variable 
     *  - response 	    : IF_CSPLUS_010 Response
     *  - seqSet 	    : Product Request의 Seq__c Set
     *  - resultMap 	: IF_CSPLUS_010 결과로 Upsert할 ProductRequest Map
     *  - errMessage 	: IF_CSPLUS_010 실패시 Error Messege
     */
    public class IFCSPLUS010Wrapper {
        @AuraEnabled public IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res  response        { get;set; }
        @AuraEnabled public Set<String>                                 seqSet          { get;set; }
        @AuraEnabled public Map<String,List<String>>                    resultMap       { get;set; }
        @AuraEnabled public String                                      errMessage       { get;set; }

        public IFCSPLUS010Wrapper() {
            this.response = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res();
            this.seqSet = new Set<String>();
            this.resultMap = new Map<String,List<String>>();
            this.errMessage = '';
        }
    } 




}