/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-12-26   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_PartProgressController {
    public DN_PartProgressController() {}

    // 부품진행상태 component의 Init
    @AuraEnabled
    public static SearchObject getInit() {

        Datetime endDate = Datetime.now();
        Datetime startDate = endDate.addMonths(-6);

        SearchObject searchObj = new SearchObject();
        searchObj.searchStartDate = startDate.format('yyyy-MM-dd');
        searchObj.searchEndDate = endDate.format('yyyy-MM-dd');

        return searchObj;
    }

    // 부품진행상태의 기종검색 모달 검색 메서드
    @AuraEnabled
    public static ResultWrapper searchGijongList(String searchTemp) {
        ResultWrapper result = new ResultWrapper();
        try {
            System.debug('searchTemp ::: ' + searchTemp);

            String nameSearch = '%' + searchTemp + '%';

            List<ModelManager__c> modelList = [SELECT Id, Name, ModelCode__c FROM ModelManager__c WHERE Name LIKE :nameSearch];
            System.debug('modelList ::: ' + modelList);

            List<GiJongWrapper> wrappers = new List<GiJongWrapper>();
            for (ModelManager__c model : modelList) {
                GiJongWrapper wrapper = new GiJongWrapper();
                wrapper.id = model.Id;
                wrapper.name = model.Name;
                wrapper.modelCode = model.ModelCode__c == null ? '' : model.ModelCode__c;
                wrappers.add(wrapper);
            }

            if (wrappers.size() > 0) {
                result.giJongList = wrappers;
            } else {
                result.isSuccess = false;
                result.message = '조건에 맞는 기종이 없습니다.';
            }
        } catch (Exception e) {
            System.debug('ErrorMessage ::: ' + e.getMessage());
            System.debug('ErrorLine ::: ' + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'ErrorMessage ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }

        return result;
    }

    // 부품진행상태의 검색 조건으로 필터링해서 Interface로 부품진행상태를 가져와서 부품청부에 upsert하거나(오더번호가 검색조건에 들어갈경우) 부품청구를 필터링 해서 가져오는 메서드 
    @AuraEnabled
    public static PartsResultWrapper getPartsList(SearchObject searchObject) {

        PartsResultWrapper result = new PartsResultWrapper();

        try {
            if (searchObject.searchOrderNumber == '') {
                String searchStartDate = searchObject.searchStartDate;
                String searchEndDate = searchObject.searchEndDate;
                // Date startDate = convertDate(searchStartDate);
                // Date endDate = convertDate(searchEndDate);
                String status = '';
                switch on searchObject.searchStatus {
                    when '1' {
                        status = '확보 중';
                    }
                    when '2' {
                        status = '재고보유';
                    }
                    when '3' {
                        status = '포장완료';
                    }
                    when '4' {
                        status = '배송완료';
                    }
                }

                String query = 'SELECT Id, Product__c, ProductCode__c, Product__r.FM_MaterialDetails__c, OrderQuantity__c, Inventory__c, PackagingCompleted__c, DeliveryCompleted__c, toLabel(ProgressStatus__c), TransportsDivision__c, ';
                query += 'DeliveryDate__c, VNDNM__c, QDATU__c, ReturnStatus__c, WorkOrderId, WorkOrder.ServiceOrderNumber__c, SALES__c, TrackingNumber__c, WarehouseReleaseNumber__c, ShipTo__c, ShipToName__c, CompanyName__c,  SendTo__c,';
                query += 'DealerCode__c, WorkCenter__r.Name, WorkCenterId__r.CustomerCode__c, WorkCenterId__r.Name, MachineName__c, AssetName__c, RECV_DT__c, PartsRequestDate__c, InstallationDate__c, Shipment__c, DODAT__c, Seq__c FROM ProductRequest WHERE IsDealerPortalDelete__c = false AND RECV_DT__c >= ' + searchStartDate + ' AND RECV_DT__c <= ' + searchEndDate;
                if (searchObject.searchPartName != '') query += ' AND Product__r.FM_MaterialDetails__c LIKE \'%' + searchObject.searchPartName + '%\'';
                if (searchObject.searchStatus != '0') query += ' AND ProgressStatus__c = \'' + status + '\'';
                if (searchObject.searchCustomerName != '') query += ' AND CompanyName__c LIKE \'%' + searchObject.searchCustomerName + '%\'';
                if (searchObject.searchGijong != '') query += ' AND MachineName__c LIKE \'%' + searchObject.searchGijong + '%\'';
                if (searchObject.searchHogi != '') query += ' AND AssetName__c LIKE \'%' + searchObject.searchHogi + '%\'';
                if (searchObject.searchPartNumber != '') query += ' AND ProductCode__c = \'' + searchObject.searchPartNumber + '\'';
                if (searchObject.CNFCheck) query += ' AND FM_OrderConfirm__c  = false';
                query += ' ORDER BY RECV_DT__c, WorkOrder.ServiceOrderNumber__c, Seq__c';
    
                System.debug('query 1::: ' + query);
    
                List<ProductRequest> objList = Database.query(query);
    
                if (objList.size() == 0) {
    
                    result.isSuccess = false;
                    result.message = 'No data found !';
    
                } else {
    
                    for (ProductRequest obj : objList) {
    
                        partsWrapper parts = new partsWrapper();
    
                        parts.MATNR         = obj.ProductCode__c;
                        parts.MAKTX         = obj.Product__r.FM_MaterialDetails__c;
                        parts.KWMENG        = String.valueOf(obj.OrderQuantity__c);
                        parts.BMENG         = obj.Inventory__c;
                        parts.VSMNG         = String.valueOf(obj.PackagingCompleted__c);
                        parts.GSMNG         = String.valueOf(obj.DeliveryCompleted__c);
                        parts.MATNR_TXT     = obj.ProgressStatus__c;
                        parts.DIVISION      = obj.TransportsDivision__c == null ? '' : getDIVISION(obj.TransportsDivision__c);
                        parts.PRETD3        = obj.DeliveryDate__c == null ? '0000-00-00' : convertDateString(obj.DeliveryDate__c);
                        parts.VNDNM         = obj.VNDNM__c;
                        parts.QDATU         = obj.QDATU__c == null ? '0000-00-00' : convertDateString(obj.QDATU__c);
                        parts.RETURN_YN     = obj.ReturnStatus__c;
                        parts.AUFNR         = obj.WorkOrder.ServiceOrderNumber__c;
                        parts.VBELN         = obj.SALES__c;
                        parts.INVOICE       = obj.TrackingNumber__c;
                        parts.VBELN_VL1     = obj.WarehouseReleaseNumber__c;
                        parts.NAME4         = obj.ShipToName__c;
                        parts.NAME2         = obj.CompanyName__c;
                        parts.DEALER_CD     = obj.WorkCenterId__r.CustomerCode__c == null ? '' : obj.WorkCenterId__r.CustomerCode__c.leftPad(10, '0');
                        parts.NAME1         = obj.WorkCenterId__r.Name == null ? '' : obj.WorkCenterId__r.Name;
                        parts.TYPBZ         = obj.MachineName__c;
                        parts.SERNR         = obj.AssetName__c;
                        parts.RECV_DT       = obj.RECV_DT__c == null ? '0000-00-00' : convertDateString(obj.RECV_DT__c);
                        parts.REQDATE       = obj.PartsRequestDate__c == null ? '0000-00-00' : convertDateString(obj.PartsRequestDate__c);
                        parts.GWLDT         = obj.InstallationDate__c == null ? '0000-00-00' : convertDateString(obj.InstallationDate__c);
                        parts.TKNUM         = obj.Shipment__c;
                        parts.DODAT         = obj.DODAT__c == null ? '0000-00-00' : convertDateString(obj.DODAT__c);
                        parts.QMSEQ         = obj.Seq__c;
                        parts.VTEXT         = obj.SendTo__c; // 송부처
    
                        System.debug('@@ 11 obj.SendTo__c :'+ obj.SendTo__c);
                        result.resultList.add(parts);
    
                    }
    
                    result.isSuccess = true;
                    result.message = '';
    
                }
    
            } else {
                IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();
                req.FR_RECV_DAT = searchObject.searchStartDate;
                req.TO_RECV_DAT = searchObject.searchEndDate;
                req.I_MAKTX = searchObject.searchPartName;
                req.I_STATUS = searchObject.searchStatus == '0' ? 'X' : searchObject.searchStatus;
                req.I_NAME2 = searchObject.searchCustomerName;
                req.I_TYPBZ = searchObject.searchGijong;
                req.I_MATNR = searchObject.searchPartNumber;
                req.I_EQUNR = searchObject.searchHogi;
                req.I_CHK = searchObject.CNFCheck ? 'X' : '';
        
                if (searchObject.searchOrderNumber != '') {
                    IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2 t_i_list2 = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2();
                    t_i_list2.LOW = searchObject.searchOrderNumber;
                    req.T_I_LIST2 = new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2>{t_i_list2};
                }
        
                IF_ERP_Material instance = new IF_ERP_Material();
                IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = instance.IF_CSPLUS_007(req);
    
                // Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST> partsProgressMap = new Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>();
                if (response.O_RETURN.TYPE == 'S') {
                    System.debug('response Size ::: ' + response.T_O_LIST.size());

                    updateProductRequest(response.T_O_LIST, searchObject.searchOrderNumber);

                    String searchStartDate = searchObject.searchStartDate;
                    String searchEndDate = searchObject.searchEndDate;
                    // Date startDate = convertDate(searchStartDate);
                    // Date endDate = convertDate(searchEndDate);
                    String status = '';
                    switch on searchObject.searchStatus {
                        when '1' {
                            status = '확보 중';
                        }
                        when '2' {
                            status = '재고보유';
                        }
                        when '3' {
                            status = '포장완료';
                        }
                        when '4' {
                            status = '배송완료';
                        }
                    }

                    String query = 'SELECT Id, Product__c, ProductCode__c, Product__r.FM_MaterialDetails__c, OrderQuantity__c, Inventory__c, PackagingCompleted__c, DeliveryCompleted__c, toLabel(ProgressStatus__c), TransportsDivision__c, ';
                    query += 'DeliveryDate__c, VNDNM__c, QDATU__c, ReturnStatus__c, WorkOrderId, WorkOrder.ServiceOrderNumber__c, SALES__c, TrackingNumber__c, WarehouseReleaseNumber__c,  ShipToName__c, CompanyName__c,  SendTo__c,';
                    query += 'DealerCode__c, WorkCenter__r.Name, WorkCenterId__r.Name, WorkCenterId__r.CustomerCode__c, MachineName__c, AssetName__c, RECV_DT__c, PartsRequestDate__c, InstallationDate__c, Shipment__c, DODAT__c, Seq__c FROM ProductRequest WHERE IsDealerPortalDelete__c = false';
                    if (searchObject.searchPartName != '') query += ' AND Product__r.FM_MaterialDetails__c LIKE \'%' + searchObject.searchPartName + '%\'';
                    if (searchObject.searchStatus != '0') query += ' AND ProgressStatus__c = \'' + status + '\'';
                    if (searchObject.searchCustomerName != '') query += ' AND CompanyName__c LIKE \'%' + searchObject.searchCustomerName + '%\'';
                    if (searchObject.searchGijong != '') query += ' AND MachineName__c LIKE \'%' + searchObject.searchGijong + '%\'';
                    if (searchObject.searchHogi != '') query += ' AND AssetName__c LIKE \'%' + searchObject.searchHogi + '%\'';
                    if (searchObject.searchPartNumber != '') query += ' AND ProductCode__c = \'' + searchObject.searchPartNumber + '\'';
                    if (searchObject.CNFCheck) query += ' AND FM_OrderConfirm__c  = false';
                    query += ' AND WorkOrder.ServiceOrderNumber__c = \'' + searchObject.searchOrderNumber + '\' ORDER BY RECV_DT__c, WorkOrder.ServiceOrderNumber__c, Seq__c';
        
                    System.debug('query 2 ::: ' + query);
        
                    List<ProductRequest> objList = Database.query(query);

                    for (ProductRequest obj : objList) {

                        partsWrapper parts = new partsWrapper();
    
                        parts.MATNR         = obj.ProductCode__c;
                        parts.MAKTX         = obj.Product__r.FM_MaterialDetails__c;
                        parts.KWMENG        = String.valueOf(obj.OrderQuantity__c);
                        parts.BMENG         = obj.Inventory__c;
                        parts.VSMNG         = String.valueOf(obj.PackagingCompleted__c);
                        parts.GSMNG         = String.valueOf(obj.DeliveryCompleted__c);
                        parts.MATNR_TXT     = obj.ProgressStatus__c;
                        parts.DIVISION      = obj.TransportsDivision__c == null ? '' : getDIVISION(obj.TransportsDivision__c);
                        parts.PRETD3        = obj.DeliveryDate__c == null ? '0000-00-00' : convertDateString(obj.DeliveryDate__c);
                        parts.VNDNM         = obj.VNDNM__c;
                        parts.QDATU         = obj.QDATU__c == null ? '0000-00-00' : convertDateString(obj.QDATU__c);
                        parts.RETURN_YN     = obj.ReturnStatus__c;
                        parts.AUFNR         = obj.WorkOrder.ServiceOrderNumber__c;
                        parts.VBELN         = obj.SALES__c;
                        parts.INVOICE       = obj.TrackingNumber__c;
                        parts.VBELN_VL1     = obj.WarehouseReleaseNumber__c;
                        parts.NAME4         = obj.ShipToName__c;
                        parts.NAME2         = obj.CompanyName__c;
                        parts.DEALER_CD     = obj.WorkCenterId__r.CustomerCode__c == null ? '' : obj.WorkCenterId__r.CustomerCode__c.leftPad(10, '0');
                        parts.NAME1         = obj.WorkCenterId__r.Name == null ? '' : obj.WorkCenterId__r.Name;
                        parts.TYPBZ         = obj.MachineName__c;
                        parts.SERNR         = obj.AssetName__c;
                        parts.RECV_DT       = obj.RECV_DT__c == null ? '0000-00-00' : convertDateString(obj.RECV_DT__c);
                        parts.REQDATE       = obj.PartsRequestDate__c == null ? '0000-00-00' : convertDateString(obj.PartsRequestDate__c);
                        parts.GWLDT         = obj.InstallationDate__c == null ? '0000-00-00' : convertDateString(obj.InstallationDate__c);
                        parts.TKNUM         = obj.Shipment__c;
                        parts.DODAT         = obj.DODAT__c == null ? '0000-00-00' : convertDateString(obj.DODAT__c);
                        parts.QMSEQ         = obj.Seq__c;
                        parts.VTEXT         = obj.SendTo__c; // 송부처
    
                        result.resultList.add(parts);
                        
                    }
    
                    result.isSuccess = true;
                    result.message = '';
                    result.type = 'Callout';
    
                    // DN_PartsProgressBatch batch = new DN_PartsProgressBatch();
                    // batch.partsProgressMap = partsProgressMap;
                    // Database.executeBatch(batch, 200);
    
                } else if (response.O_RETURN.TYPE == 'E'){

                    if (response.O_RETURN.MESSAGE == 'No data found ! [ZCS05001]') {
                        List<ProductRequest> prList = [SELECT Id, Seq__c, PartsRequestDate__c, TransportsDivision__c, CreatedDate, WorkOrderId, IsDealerPortalDelete__c, Quantity__c, QDATU__c, MENGE_GI__c 
                        FROM ProductRequest 
                        WHERE WorkOrder.ServiceOrderNumber__c = :searchObject.searchOrderNumber
                        AND IsDealerPortalDelete__c = false
                        AND WorkOrder.Status != 'Confirm'
                        AND Status != 'New'];

                        if (prList.size() > 0) {
                            for (ProductRequest pr : prList) {
                                pr.IsDealerPortalDelete__c = true;
                            }
                            update prList;
                        }
                    }

                    result.isSuccess = false;
                    result.message = response.O_RETURN.MESSAGE;
                }
    
            }
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }

        return result;
    }

    // 부품진행상태의 IF_CSPLUS_007로 Interface해서 가져온 정보로 부품청구를 upsert하는 메서드
    public static void updateProductRequest(List<IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST> objList, String serviceOrderNum) {

        List<ProductRequest> upsertList = new List<ProductRequest>();
        Map<String, ProductRequest> prMap = new Map<String, ProductRequest>();
        Map<String, Product2> productMap = new Map<String, Product2>();
        Map<String, String> serviceTerritoryMap = new Map<String, String>();
        Map<String, String> serviceTerritoryAccountMap = new Map<String, String>();
        Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST> partsProgressMap = new Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>();

        for (IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST obj : objList) {
            if (obj.AUFNR != '' && obj.QMSEQ != '') {
                // System.debug(obj.AUFNR + '!' + obj.QMSEQ);
                partsProgressMap.put(obj.AUFNR + '!' + obj.QMSEQ, obj);
            }
        }

        List<ProductRequest> prList = [SELECT Id, Seq__c, PartsRequestDate__c, TransportsDivision__c, CreatedDate, WorkOrderId, IsDealerPortalDelete__c, Quantity__c, QDATU__c, MENGE_GI__c, WorkOrder.Status 
        FROM ProductRequest 
        WHERE WorkOrder.ServiceOrderNumber__c = :serviceOrderNum
        AND IsDealerPortalDelete__c = false
        AND Status != 'New'
        ORDER BY CreatedDate ASC];

        for (ProductRequest pr : prList) {
            if (!partsProgressMap.containsKey(serviceOrderNum + '!' + pr.Seq__c)) {
                pr.IsDealerPortalDelete__c = true;
                upsertList.add(pr);
            } else {
                prMap.put(serviceOrderNum + '!' + pr.Seq__c, pr);
            }
        }

        Set<String> productCodes = new Set<String>();
        Set<String> accountCodes = new Set<String>();
        for (IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST interfaceObj : objList) {
            productCodes.add(interfaceObj.MATNR);
            accountCodes.add(interfaceObj.DEALER_CD.replaceFirst('^0+', ''));
            accountCodes.add(interfaceObj.SOLDTO.replaceFirst('^0+', ''));
        }
        
        List<Product2> productList = [SELECT Id, ProductCode FROM Product2 WHERE RecordType.DeveloperName = 'Part' AND ProductCode IN :productCodes];

        for (Product2 product : productList) {
            productMap.put(product.ProductCode, product);
        }

        List<WorkOrder> workOrderList = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder WHERE ServiceOrderNumber__c = :serviceOrderNum];
        Map<String, String> serviceOrderIdMap = new Map<String, String>();
        

        for (WorkOrder wo : workOrderList) {
            serviceOrderIdMap.put(wo.ServiceOrderNumber__c, wo.Id);
        }

        List<ServiceTerritory> workcenterList = [SELECT Id, WCID__c, ServiceWorkCenter__c  FROM ServiceTerritory WHERE WCID__c IN :accountCodes];

        for (ServiceTerritory st : workcenterList) {
            serviceTerritoryMap.put(st.WCID__c, st.Id);
            serviceTerritoryAccountMap.put(st.WCID__c, st.ServiceWorkCenter__c);
        }

        for (IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST interfaceObj : objList) {
            String key = interfaceObj.AUFNR + '!' + interfaceObj.QMSEQ;

            if (prMap.containsKey(key)) {
                ProductRequest obj = prMap.get(key);

                // if (obj.WorkOrder.Status == 'Confirm') continue;
                if (obj.IsDealerPortalDelete__c) continue;
                // obj.Name = interfaceObj.AUFNR + ' ' + interfaceObj.QMSEQ;
                // obj.ProductCode__c = interfaceObj.MATNR; // 품번 ProductCode__c

                if (productMap.get(interfaceObj.MATNR) == null) {
                    continue;
                } else {
                    obj.Product__c = productMap.get(interfaceObj.MATNR).Id; // 품명 Product__c
                }
                // obj.OrderQuantity__c = Decimal.valueOf(interfaceObj.KWMENG); // 오더수(수량?) OrderQuantity__c
                // obj.Quantity__c = Decimal.valueOf(interfaceObj.KWMENG); // 오더수(수량?) Quantity__c
                // obj.Status = 'Approved'; // 상태 (Mig만 필요) Status
                // obj.Inventory__c = interfaceObj.BMENG; // 재고할당 Inventory__c
                // obj.PackagingCompleted__c = Decimal.valueOf(interfaceObj.VSMNG); // 포장완료 PackagingCompleted__c
                // obj.DeliveryCompleted__c = Decimal.valueOf(interfaceObj.GSMNG); // 배송완료 DeliveryCompleted__c
                // obj.ProgressStatus__c = interfaceObj.MATNR_TXT == '확보중' ? '확보 중' : interfaceObj.MATNR_TXT; // 상태 ProgressStatus__c
                obj.TransportsDivision__c = interfaceObj.VSBED; // 탁송구분 TransportsDivision__c
                obj.DeliveryDate__c = interfaceObj.PRETD3 == '0000-00-00' ? null : convertDate(interfaceObj.PRETD3); // 납기일 DeliveryDate__c
                obj.PRETD__c = interfaceObj.PRETD == '0000-00-00' ? null : convertDate(interfaceObj.PRETD); // 공급예정일 PRETD__c
                obj.VNDNM__c = interfaceObj.VNDNM; // 납품업체 VNDNM__c
                // obj.QDATU__c = interfaceObj.QDATU == '0000-00-00' ? null : convertDate(interfaceObj.QDATU); // 불출일 QDATU__c
                obj.ReturnStatus__c = interfaceObj.RETURN_YN; // 반납대상 ReturnStatus__c	
                // obj.AUFNR__c = interfaceObj.AUFNR; // 오더번호 WorkOrder.ServiceOrderNumber__c
                obj.WorkOrderId = serviceOrderIdMap.get(interfaceObj.AUFNR); // 오더번호 WorkOrder.ServiceOrderNumber__c
                obj.SALES__c = interfaceObj.VBELN; // SALES SALES__c
                obj.TrackingNumber__c = interfaceObj.INVOICE; // 송장번호 TrackingNumber__c
                obj.WarehouseReleaseNumber__c = interfaceObj.VBELN_VL1; // 창고불출번호 WarehouseReleaseNumber__c
                obj.ShipToName__c = interfaceObj.NAME4; // 배송처Text ShipToName__c
                obj.ShipTo__c = interfaceObj.SOLDTO == '' ? '고객직송' : serviceTerritoryMap.get(interfaceObj.SOLDTO.replaceFirst('^0+', '')); // 배송처 ShipTo__c
                obj.CompanyName__c = interfaceObj.NAME2; // 업체명 CompanyName__c (CustomerCode로 넣는다면 interfaceObj.KUNUM)
                obj.DealerCode__c = interfaceObj.DEALER_CD; // 대리점코드 DealerCode__c
                obj.WorkCenter__c = serviceTerritoryMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', '')); // 대리점명 WorkCenter__c
                obj.WorkCenterId__c = serviceTerritoryAccountMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', '')); // 대리점명 WorkCenter__c
                obj.MachineName__c = interfaceObj.TYPBZ; // 기종 MachineName__c
                obj.AssetName__c = interfaceObj.SERNR; // 호기 AssetName__c
                obj.RECV_DT__c = interfaceObj.RECV_DT == '0000-00-00' ? null : convertDate(interfaceObj.RECV_DT); // 접수일 (String) RECV_DT__c
                // obj.RequestDate__c = convertDate(interfaceObj.RECV_DT);
                // obj.REQDATE__c = prMap.get(key) != null && prMap.get(key).PartsRequestDate__c != null ? convertDateString(prMap.get(key).PartsRequestDate__c) : ''; // 부품청구일 PartsRequestDate__c
                obj.InstallationDate__c = interfaceObj.GWLDT == '0000-00-00' ? null : convertDate(interfaceObj.GWLDT); // 설치일자 InstallationDate__c
                obj.Shipment__c = interfaceObj.TKNUM; // Sipment Shipment__c
                obj.DODAT__c = interfaceObj.DODAT == '0000-00-00' ? null : convertDate(interfaceObj.DODAT); // D/O 생성일 DODAT__c
                obj.Seq__c = interfaceObj.QMSEQ; // 시퀀스 Seq__c
                System.debug('기존 상태(SAP) : ' + interfaceObj.MATNR_TXT);
                if (interfaceObj.VSBED == '1' || interfaceObj.VSBED == '2' || interfaceObj.VSBED == '3' || interfaceObj.VSBED == '4') {
                    obj.OrderQuantity__c = obj.Quantity__c; // 오더수(수량?) OrderQuantity__c
                    obj.Inventory__c = obj.MENGE_GI__c == null ? '0' : String.valueOf(obj.MENGE_GI__c); // 재고할당 Inventory__c
                    obj.PackagingCompleted__c = obj.MENGE_GI__c == null ? 0 : obj.MENGE_GI__c; // 포장완료 PackagingCompleted__c
                    obj.DeliveryCompleted__c = obj.MENGE_GI__c == null ? 0 : obj.MENGE_GI__c; // 배송완료 DeliveryCompleted__c
                    obj.ProgressStatus__c = obj.MENGE_GI__c == 0 || obj.MENGE_GI__c == null ? '재고보유' : '배송완료'; // 상태 ProgressStatus__c
                    // obj.QDATU__c = obj.QDATU__c // 불출일 QDATU__c
                } else {
                    obj.OrderQuantity__c = Decimal.valueOf(interfaceObj.KWMENG); // 오더수(수량?) OrderQuantity__c
                    obj.Inventory__c = interfaceObj.BMENG; // 재고할당 Inventory__c
                    obj.PackagingCompleted__c = Decimal.valueOf(interfaceObj.VSMNG); // 포장완료 PackagingCompleted__c
                    obj.DeliveryCompleted__c = Decimal.valueOf(interfaceObj.GSMNG); // 배송완료 DeliveryCompleted__c
                    obj.ProgressStatus__c = interfaceObj.MATNR_TXT == '확보중' ? '확보 중' : interfaceObj.MATNR_TXT; // 상태 ProgressStatus__c
                    obj.QDATU__c = interfaceObj.QDATU == '0000-00-00' ? null : convertDate(interfaceObj.QDATU); // 불출일 QDATU__c
                }
                System.debug('변경 상태 : ' + obj.ProgressStatus__c);

                if (interfaceObj.VTEXT != '') {
                    obj.SendTo__c = interfaceObj.VTEXT; // 송부처
                } else {
                    if (interfaceObj.NAME1 != '') {
                        obj.SendTo__c = interfaceObj.NAME1; // 송부처
                    } else {
                        obj.SendTo__c = interfaceObj.DEALER_CD; // 송부처
                    }
                }

                upsertList.add(obj);
            } else {
                ProductRequest obj = new ProductRequest();
                // obj.Name = interfaceObj.AUFNR + ' ' + interfaceObj.QMSEQ;
                // obj.ProductCode__c = interfaceObj.MATNR; // 품번 ProductCode__c

                if (productMap.get(interfaceObj.MATNR) == null) {
                    continue;
                } else {
                    obj.Product__c = productMap.get(interfaceObj.MATNR).Id; // 품명 Product__c
                }
                System.debug('기존 상태(SAP) : ' + interfaceObj.MATNR_TXT);
                obj.Status = 'Approved';
                obj.OrderQuantity__c = Decimal.valueOf(interfaceObj.KWMENG); // 오더수(수량?) OrderQuantity__c
                obj.Quantity__c = Decimal.valueOf(interfaceObj.KWMENG); // 오더수(수량?) OrderQuantity__c
                obj.Inventory__c = interfaceObj.BMENG; // 재고할당 Inventory__c
                obj.PackagingCompleted__c = Decimal.valueOf(interfaceObj.VSMNG); // 포장완료 PackagingCompleted__c
                obj.DeliveryCompleted__c = Decimal.valueOf(interfaceObj.GSMNG); // 배송완료 DeliveryCompleted__c
                obj.ProgressStatus__c = interfaceObj.MATNR_TXT == '확보중' ? '확보 중' : interfaceObj.MATNR_TXT; // 상태 ProgressStatus__c
                obj.TransportsDivision__c = interfaceObj.VSBED; // 탁송구분 TransportsDivision__c
                obj.DeliveryDate__c = interfaceObj.PRETD3 == '0000-00-00' ? null : convertDate(interfaceObj.PRETD3); // 납기일 DeliveryDate__c
                obj.PRETD__c = interfaceObj.PRETD == '0000-00-00' ? null : convertDate(interfaceObj.PRETD); // 공급예정일 PRETD__c
                obj.VNDNM__c = interfaceObj.VNDNM; // 납품업체 VNDNM__c
                obj.QDATU__c = interfaceObj.QDATU == '0000-00-00' ? null : convertDate(interfaceObj.QDATU); // 불출일 QDATU__c
                obj.ReturnStatus__c = interfaceObj.RETURN_YN; // 반납대상 ReturnStatus__c	
                // obj.AUFNR__c = interfaceObj.AUFNR; // 오더번호 WorkOrder.ServiceOrderNumber__c
                System.debug('변경 상태(SAP) : ' + obj.ProgressStatus__c);
                if (serviceOrderIdMap.get(interfaceObj.AUFNR) == null) {
                    continue;
                } else {
                    obj.WorkOrderId = serviceOrderIdMap.get(interfaceObj.AUFNR);// 
                }
                obj.SALES__c = interfaceObj.VBELN; // SALES SALES__c
                obj.TrackingNumber__c = interfaceObj.INVOICE; // 송장번호 TrackingNumber__c
                obj.WarehouseReleaseNumber__c = interfaceObj.VBELN_VL1; // 창고불출번호 WarehouseReleaseNumber__c
                obj.ShipToName__c = interfaceObj.NAME4; // 배송처Text ShipToName__c
                obj.ShipTo__c = interfaceObj.SOLDTO == '' ? '고객직송' : serviceTerritoryMap.get(interfaceObj.SOLDTO.replaceFirst('^0+', '')); // 배송처 ShipTo__c
                obj.CompanyName__c = interfaceObj.NAME2; // 업체명 CompanyName__c (CustomerCode로 넣는다면 interfaceObj.KUNUM)
                obj.DealerCode__c = interfaceObj.DEALER_CD; // 대리점코드 DealerCode__c
                obj.WorkCenter__c = serviceTerritoryMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', '')); // 대리점명 WorkCenter__c
                obj.WorkCenterId__c = serviceTerritoryAccountMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', ''));
                obj.MachineName__c = interfaceObj.TYPBZ; // 기종 MachineName__c
                obj.AssetName__c = interfaceObj.SERNR; // 호기 AssetName__c
                obj.RECV_DT__c = interfaceObj.RECV_DT == '0000-00-00' ? null : convertDate(interfaceObj.RECV_DT); // 접수일 (String) RECV_DT__c
                // obj.RequestDate__c = convertDate(interfaceObj.RECV_DT);
                // obj.REQDATE__c = prMap.get(key) != null && prMap.get(key).PartsRequestDate__c != null ? convertDateString(prMap.get(key).PartsRequestDate__c) : ''; // 부품청구일 PartsRequestDate__c
                obj.InstallationDate__c = interfaceObj.GWLDT == '0000-00-00' ? null : convertDate(interfaceObj.GWLDT); // 설치일자 InstallationDate__c
                obj.Shipment__c = interfaceObj.TKNUM; // Sipment Shipment__c
                obj.DODAT__c = interfaceObj.DODAT == '0000-00-00' ? null : convertDate(interfaceObj.DODAT); // D/O 생성일 DODAT__c
                obj.Seq__c = interfaceObj.QMSEQ; // 시퀀스 Seq__c

                if (interfaceObj.VTEXT != '') {
                    obj.SendTo__c = interfaceObj.VTEXT; // 송부처
                } else {
                    if (interfaceObj.NAME1 != '') {
                        obj.SendTo__c = interfaceObj.NAME1; // 송부처
                    } else {
                        obj.SendTo__c = interfaceObj.DEALER_CD; // 송부처
                    }
                }
                upsertList.add(obj);
            }
        }
        System.debug(upsertList.size() > 0);
        System.debug('update : ' + upsertList.size());
        if (upsertList.size() > 0) upsert upsertList;

    }

    // 해당 Service Order의 부품청구에서 부품청구일자를 가져오는 메서드
    @AuraEnabled
    public static Map<String, PartsInfo> getPartsInfo(List<String> orderNumberList) {
        Map<String, PartsInfo> resultMap = new Map<String, PartsInfo>();
        // List<PartsInfo> resultList = new List<PartsInfo>();
        try {
            
            Set<String> orderNumberSet = new Set<String>(orderNumberList);

            List<ProductRequest> prList = [SELECT Id, Seq__c, PartsRequestDate__c, CreatedDate, WorkOrder.ServiceOrderNumber__c FROM ProductRequest WHERE WorkOrder.ServiceOrderNumber__c IN :orderNumberSet];

            for (ProductRequest pr : prList) {
                PartsInfo wrapper = new PartsInfo();
                wrapper.seq = pr.Seq__c;
                wrapper.notiNum = pr.WorkOrder.ServiceOrderNumber__c;

                wrapper.createDate = pr.CreatedDate.format('yyyy-MM-dd');
                wrapper.PartsRequestDate = pr.PartsRequestDate__c == null ? '0000-00-00' : convertDateString(pr.PartsRequestDate__c);
                resultMap.put(pr.WorkOrder.ServiceOrderNumber__c + '!' + pr.Seq__c, wrapper);
            }

        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }

        return resultMap;
    }

    // Date값을 yyyy-MM-dd 형태의 String으로 전환하는 메서드
    private static String convertDateString(Date requestDate) {

        String year = String.valueOf(requestDate.year());
        String month = String.valueOf(requestDate.month()).leftPad(2, '0');
        String day = String.valueOf(requestDate.day()).leftPad(2, '0');

        String dateString = year + '-' + month + '-' + day;

        return dateString;
    }

    // yyyy-MM-dd형태의 String값을 Date형태로 변경하는 메서드
    private static Date convertDate(String dateString) {
        Date result = null;
        if (dateString != '') {
            Integer year = Integer.valueOf(dateString.split('-')[0]);
            if (year > 3000 ) year = 2999;
            Integer month = Integer.valueOf(dateString.split('-')[1]);
            Integer day = Integer.valueOf(dateString.split('-')[2]);
            result = Date.newInstance(year, month, day);
        }

        return result;
    }

    // 탁송구분 코드를 코드에 맞는 텍스트로 전환하는 메서드
    private static String getDIVISION(String VSBED) {

        String result = '';

        switch on VSBED {
            when '20' {
                result = '[본사]화물영업소';
            }
            when '10' {
                result = '[본사]택배직송';
            }
            when '90' {
                result = '[본사]퀵서비스';
            }
            when '99' {
                result = '[본사]방문수령';
            }
            when '2' {
                result = '[대리점]화물영업소';
            }
            when '1' {
                result = '[대리점]택배직송';
            }
            when '3' {
                result = '[대리점]퀵서비스';
            }
            when '4' {
                result = '[대리점]방문수령';
            }
            when else {
                result = '';
            }
        }

        return result;
    }

    public class ResultWrapper {
        @AuraEnabled public Boolean                 isSuccess       { get; set; }
        @AuraEnabled public String                  message         { get; set; }
        @AuraEnabled public List<GiJongWrapper>     giJongList      { get; set; }

        public ResultWrapper() {
            this.isSuccess = true;
            this.message = '';
            this.giJongList = new List<GiJongWrapper>();
        }

    }

    public class PartsResultWrapper {
        @AuraEnabled public Boolean                isSuccess        { get; set; }
        @AuraEnabled public String                 message          { get; set; }
        @AuraEnabled public String                 type             { get; set; }
        @AuraEnabled public List<PartsWrapper>     resultList       { get; set; }

        public PartsResultWrapper() {
            this.isSuccess = true;
            this.message = '';
            this.type = '';
            this.resultList = new List<PartsWrapper>();
        }

    }

    public class GiJongWrapper {
        @AuraEnabled public String id           { get; set; }
        @AuraEnabled public String name         { get; set; }
        @AuraEnabled public String modelCode    { get; set; }

        public GiJongWrapper() {
            this.id = '';
            this.name = '';
            this.modelCode = '';
        }
    }

    public class SearchObject {
        @AuraEnabled public String  searchStartDate      { get; set; }
        @AuraEnabled public String  searchEndDate        { get; set; }
        @AuraEnabled public String  searchOrderNumber    { get; set; }
        @AuraEnabled public String  searchStatus         { get; set; }
        @AuraEnabled public String  searchPartName       { get; set; }
        @AuraEnabled public String  searchPartNumber     { get; set; }
        @AuraEnabled public String  searchCustomerName   { get; set; }
        @AuraEnabled public String  searchGijong         { get; set; }
        @AuraEnabled public String  searchHogi           { get; set; }
        @AuraEnabled public String  searchSerialNumber   { get; set; }
        @AuraEnabled public Boolean CNFCheck             { get; set; }

        public SearchObject() {
            this.searchStartDate = '';
            this.searchEndDate = '';
            this.searchOrderNumber = '';
            this.searchStatus = '0';
            this.searchPartName = '';
            this.searchPartNumber = '';
            this.searchCustomerName = '';
            this.searchGijong = '';
            this.searchHogi = '';
            this.searchSerialNumber = '';
            this.CNFCheck = false;
        }
    }

    public class PartsWrapper {

        @AuraEnabled public String  MATNR      { get; set; }
        @AuraEnabled public String  MAKTX      { get; set; }
        @AuraEnabled public String  KWMENG     { get; set; }
        @AuraEnabled public String  BMENG      { get; set; }
        @AuraEnabled public String  VSMNG      { get; set; }
        @AuraEnabled public String  GSMNG      { get; set; }
        @AuraEnabled public String  MATNR_TXT  { get; set; }
        @AuraEnabled public String  DIVISION   { get; set; }
        @AuraEnabled public String  PRETD3     { get; set; }
        @AuraEnabled public String  VNDNM      { get; set; }
        @AuraEnabled public String  QDATU      { get; set; }
        @AuraEnabled public String  RETURN_YN  { get; set; }
        @AuraEnabled public String  AUFNR      { get; set; }
        @AuraEnabled public String  VBELN      { get; set; }
        @AuraEnabled public String  INVOICE    { get; set; }
        @AuraEnabled public String  VBELN_VL1  { get; set; }
        @AuraEnabled public String  NAME4      { get; set; }
        @AuraEnabled public String  NAME2      { get; set; }
        @AuraEnabled public String  DEALER_CD  { get; set; }
        @AuraEnabled public String  NAME1      { get; set; }
        @AuraEnabled public String  TYPBZ      { get; set; }
        @AuraEnabled public String  SERNR      { get; set; }
        @AuraEnabled public String  RECV_DT    { get; set; }
        @AuraEnabled public String  REQDATE    { get; set; }
        @AuraEnabled public String  GWLDT      { get; set; }
        @AuraEnabled public String  TKNUM      { get; set; }
        @AuraEnabled public String  DODAT      { get; set; }
        @AuraEnabled public String  QMSEQ      { get; set; }
        @AuraEnabled public String  VTEXT      { get; set; }

        public PartsWrapper() {

        }
    }

    public class PartsInfo {
        @AuraEnabled public String  notiNum             { get; set; }
        @AuraEnabled public String  seq                 { get; set; }
        @AuraEnabled public String  transportsDivision  { get; set; }
        @AuraEnabled public String  createDate          { get; set; }
        @AuraEnabled public String  PartsRequestDate    { get; set; }

        public PartsInfo() {
            this.notiNum = '';
            this.seq = '';
            this.transportsDivision = '';
            this.createDate = '';
            this.PartsRequestDate = '';
        }
    }

}