/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-09-01
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-07   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public class DN_PartsProgressBatch implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts {
    // 부품진행상태를 저장해놓는 배치
    public String jsonString = '';
    public Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST> partsProgressMap = new Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>();
    Map<String, String> serviceOrderIdMap = new Map<String, String>();
    public Map<String, ProductRequest> prMap = new Map<String, ProductRequest>();
    public Map<String, Product2> productMap = new Map<String, Product2>();
    public Map<String, String> serviceTerritoryMap = new Map<String, String>();
    public Map<String, String> serviceTerritoryAccountMap = new Map<String, String>();
    public List<ProductRequest> upsertList = new List<ProductRequest>();

    public DN_PartsProgressBatch() {}

    public List<Object> start(Database.BatchableContext bc) {
        if (!jsonString.equals('')) {
            IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = (IF_ERP_Material_Classes.IF_CSPLUS_007_Res) JSON.deserialize(jsonString, IF_ERP_Material_Classes.IF_CSPLUS_007_Res.class);
            for (IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST obj : response.T_O_LIST) {
                if (obj.AUFNR != '' && obj.QMSEQ != '') {
                    partsProgressMap.put(obj.AUFNR + '!' + obj.QMSEQ, obj);
                }
            }
        }

        Map<String, ServiceTerritory> workcenterMap = new Map<String, ServiceTerritory>();
        Set<String> productCodes = new Set<String>();
        Set<String> accountCodes = new Set<String>();
        Set<String> serviceOrderNumSet = new Set<String>();
        for (String key : partsProgressMap.keySet()) {
            IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST obj = partsProgressMap.get(key);
            serviceOrderNumSet.add(obj.AUFNR);
            productCodes.add(obj.MATNR);
            accountCodes.add(obj.DEALER_CD.replaceFirst('^0+', ''));
            accountCodes.add(obj.SOLDTO.replaceFirst('^0+', ''));
        }

        List<WorkOrder> workOrderList = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder WHERE ServiceOrderNumber__c IN :serviceOrderNumSet];
        Map<String, String> serviceOrderMap = new Map<String, String>();
        

        for (WorkOrder wo : workOrderList) {
            serviceOrderMap.put(wo.Id, wo.ServiceOrderNumber__c);
            serviceOrderIdMap.put(wo.ServiceOrderNumber__c, wo.Id);
        }

        List<ProductRequest> prList = [SELECT Id, Seq__c, PartsRequestDate__c, TransportsDivision__c, CreatedDate, WorkOrderId, IsDealerPortalDelete__c, Quantity__c, QDATU__c, MENGE_GI__c, WorkOrder.Status,SendTo__c
                                       FROM ProductRequest 
                                       WHERE WorkOrderId IN :serviceOrderMap.keySet() 
                                       AND IsDealerPortalDelete__c = false
                                       AND Status != 'New'
                                       ORDER BY CreatedDate ASC];
        
        for (ProductRequest pr : prList) {
            String serviceOrderNum = serviceOrderMap.get(pr.WorkOrderId);

            if (!partsProgressMap.containsKey(serviceOrderNum + '!' + pr.Seq__c)) {
                pr.IsDealerPortalDelete__c = true;
                upsertList.add(pr);
            } else {
                prMap.put(serviceOrderNum + '!' + pr.Seq__c, pr);
            }
        }

        List<Product2> productList = [SELECT Id, ProductCode FROM Product2 WHERE RecordType.DeveloperName = 'Part' AND ProductCode IN :productCodes];

        for (Product2 product : productList) {
            productMap.put(product.ProductCode, product);
        }

        List<ServiceTerritory> workcenterList = [SELECT Id, WCID__c, ServiceWorkCenter__c  FROM ServiceTerritory WHERE WCID__c IN :accountCodes];

        for (ServiceTerritory st : workcenterList) {
            serviceTerritoryMap.put(st.WCID__c, st.Id);
            serviceTerritoryAccountMap.put(st.WCID__c, st.ServiceWorkCenter__c);
        }

        return partsProgressMap.values();
    }

    public void execute(Database.BatchableContext bc, List<Object> scope) {
        List<IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST> progressObjList = (List<IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>) scope;


        for (IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST interfaceObj : progressObjList) {
            String key = interfaceObj.AUFNR + '!' + interfaceObj.QMSEQ;
            if (prMap.containsKey(key)) {
                ProductRequest obj = prMap.get(key);
                if (obj.WorkOrder.Status == 'Confirm') continue;
                if (obj.IsDealerPortalDelete__c) continue;
                if (productMap.get(interfaceObj.MATNR) == null) {
                    continue;
                } else {
                    obj.Product__c = productMap.get(interfaceObj.MATNR).Id; // 품명 Product__c
                }
                obj.TransportsDivision__c = interfaceObj.VSBED; // 탁송구분 TransportsDivision__c
                obj.DeliveryDate__c = interfaceObj.PRETD3 == '0000-00-00' ? null : convertDate(interfaceObj.PRETD3); // 납기일 DeliveryDate__c
                obj.PRETD__c = interfaceObj.PRETD == '0000-00-00' ? null : convertDate(interfaceObj.PRETD); // 공급예정일 PRETD__c
                obj.VNDNM__c = interfaceObj.VNDNM; // 납품업체 VNDNM__c
                obj.ReturnStatus__c = interfaceObj.RETURN_YN; // 반납대상 ReturnStatus__c	
                obj.WorkOrderId = serviceOrderIdMap.get(interfaceObj.AUFNR); // 오더번호 WorkOrder.ServiceOrderNumber__c
                obj.SALES__c = interfaceObj.VBELN; // SALES SALES__c
                obj.TrackingNumber__c = interfaceObj.INVOICE; // 송장번호 TrackingNumber__c
                obj.WarehouseReleaseNumber__c = interfaceObj.VBELN_VL1; // 창고불출번호 WarehouseReleaseNumber__c
                obj.ShipToName__c = interfaceObj.NAME4;
                obj.ShipTo__c = interfaceObj.SOLDTO == '' ? '고객직송' : serviceTerritoryMap.get(interfaceObj.SOLDTO.replaceFirst('^0+', '')); // 배송처 ShipTo__c
                obj.CompanyName__c = interfaceObj.NAME2; // 업체명 CompanyName__c (CustomerCode로 넣는다면 interfaceObj.KUNUM)
                obj.DealerCode__c = interfaceObj.DEALER_CD; // 대리점코드 DealerCode__c
                obj.WorkCenter__c = serviceTerritoryMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', '')); // 대리점명 WorkCenter__c
                obj.WorkCenterId__c = serviceTerritoryAccountMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', '')); // 대리점명 WorkCenter__c
                obj.MachineName__c = interfaceObj.TYPBZ; // 기종 MachineName__c
                obj.AssetName__c = interfaceObj.SERNR; // 호기 AssetName__c
                obj.RECV_DT__c = interfaceObj.RECV_DT == '0000-00-00' ? null : convertDate(interfaceObj.RECV_DT); // 접수일 (String) RECV_DT__c
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

                if (interfaceObj.VSBED == '1' || interfaceObj.VSBED == '2' || interfaceObj.VSBED == '3' || interfaceObj.VSBED == '4') {
                    obj.OrderQuantity__c = obj.Quantity__c; // 오더수(수량?) OrderQuantity__c
                    obj.Inventory__c = obj.MENGE_GI__c == null ? '0' : String.valueOf(obj.MENGE_GI__c); // 재고할당 Inventory__c
                    obj.PackagingCompleted__c = obj.MENGE_GI__c == null ? 0 : obj.MENGE_GI__c; // 포장완료 PackagingCompleted__c
                    obj.DeliveryCompleted__c = obj.MENGE_GI__c == null ? 0 : obj.MENGE_GI__c; // 배송완료 DeliveryCompleted__c
                    obj.ProgressStatus__c = obj.MENGE_GI__c == 0 || obj.MENGE_GI__c == null ? '재고보유' : '배송완료'; // 상태 ProgressStatus__c
                } else {
                    obj.OrderQuantity__c = Decimal.valueOf(interfaceObj.KWMENG); // 오더수(수량?) OrderQuantity__c
                    obj.Inventory__c = interfaceObj.BMENG; // 재고할당 Inventory__c
                    obj.PackagingCompleted__c = Decimal.valueOf(interfaceObj.VSMNG); // 포장완료 PackagingCompleted__c
                    obj.DeliveryCompleted__c = Decimal.valueOf(interfaceObj.GSMNG); // 배송완료 DeliveryCompleted__c
                    obj.ProgressStatus__c = interfaceObj.MATNR_TXT == '확보중' ? '확보 중' : interfaceObj.MATNR_TXT; // 상태 ProgressStatus__c
                    obj.QDATU__c = interfaceObj.QDATU == '0000-00-00' ? null : convertDate(interfaceObj.QDATU); // 불출일 QDATU__c
                }

                upsertList.add(obj);

            } else {
                ProductRequest obj = new ProductRequest();
                if (productMap.get(interfaceObj.MATNR) == null) {
                    continue;
                } else {
                    obj.Product__c = productMap.get(interfaceObj.MATNR).Id; // 품명 Product__c
                }
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
                if (serviceOrderIdMap.get(interfaceObj.AUFNR) == null) {
                    continue;
                } else {
                    obj.WorkOrderId = serviceOrderIdMap.get(interfaceObj.AUFNR);// 
                }
                obj.SALES__c = interfaceObj.VBELN; // SALES SALES__c
                obj.TrackingNumber__c = interfaceObj.INVOICE; // 송장번호 TrackingNumber__c
                obj.WarehouseReleaseNumber__c = interfaceObj.VBELN_VL1; // 창고불출번호 WarehouseReleaseNumber__c
                obj.ShipToName__c = interfaceObj.NAME4;
                obj.ShipTo__c = interfaceObj.SOLDTO == '' ? '고객직송' : serviceTerritoryMap.get(interfaceObj.SOLDTO.replaceFirst('^0+', '')); // 배송처 ShipTo__c
                obj.CompanyName__c = interfaceObj.NAME2; // 업체명 CompanyName__c (CustomerCode로 넣는다면 interfaceObj.KUNUM)
                obj.DealerCode__c = interfaceObj.DEALER_CD; // 대리점코드 DealerCode__c
                obj.WorkCenter__c = serviceTerritoryMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', '')); // 대리점명 WorkCenter__c
                obj.WorkCenterId__c = serviceTerritoryAccountMap.get(interfaceObj.DEALER_CD.replaceFirst('^0+', ''));
                obj.MachineName__c = interfaceObj.TYPBZ; // 기종 MachineName__c
                obj.AssetName__c = interfaceObj.SERNR; // 호기 AssetName__c
                obj.RECV_DT__c = interfaceObj.RECV_DT == '0000-00-00' ? null : convertDate(interfaceObj.RECV_DT); // 접수일 (String) RECV_DT__c
                obj.InstallationDate__c = interfaceObj.GWLDT == '0000-00-00' ? null : convertDate(interfaceObj.GWLDT); // 설치일자 InstallationDate__c
                obj.Shipment__c = interfaceObj.TKNUM; // Sipment Shipment__c
                obj.DODAT__c = interfaceObj.DODAT == '0000-00-00' ? null : convertDate(interfaceObj.DODAT); // D/O 생성일 DODAT__c
                obj.Seq__c = interfaceObj.QMSEQ; // 시퀀스 Seq__c
                obj.SendTo__c = interfaceObj.VTEXT; // 송부처

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

    }

    public void finish(Database.BatchableContext bc) {
        if (upsertList.size() > 0) upsert upsertList;
    }

    // Interface로 가져온 날짜중 년도가 3000이상인 값들을 2999년도로 변경하는 메서드 (Saleforce에서 2999년도까지만 지원)
    private Date convertDate(String dateString) {
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
    
}