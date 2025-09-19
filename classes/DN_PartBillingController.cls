/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_PartBillingController {
    // 제품 검색 메서드
    @AuraEnabled
    public static List<Product2> searchProducts(String searchKey, String filter) {
        String query = 'SELECT Id, Name, ProductSpec__c, ProductCode, FM_MaterialDetails__c, NameEN__c FROM Product2 WHERE RecordType.Name = \'Part\' AND ';
        String likeKey = '%' + searchKey + '%';

        if (filter == 'productNumber') {
            query += 'ProductCode LIKE :likeKey';
        } else if (filter == 'FM_MaterialDetails__c') {
            query += 'FM_MaterialDetails__c LIKE :likeKey';
        } else if (filter == 'productSpec') {
            query += 'ProductSpec__c LIKE :likeKey';
        }

        return Database.query(query);
    }

    // @AuraEnabled
    // public static Product2 getProductDetails(Id productId) { 
    //     return [
    //         // 품번, 품명, 대체품, 재질, 규격, 단위, 중량, 중량단위, 납품포장 가져와야됨
    //         SELECT Name, ProductCode
    //         FROM Product2 
    //         WHERE Id = :productId AND RecordType.Name = 'Part'
    //         LIMIT 1
    //     ];
    // }

    // 부품 재고 조회 메서드
    @AuraEnabled
    public static List<DealerStock__c> getDealerStocks(Id productId) {
        return [
            // 현재고, 가용재고, 주문예약재고
            SELECT Part__c, CurrentStockQuantity__c, AvailableQuantity__c, OrderRequiredQuantity__c, Dealer__c, Name, Dealer__r.Name
            FROM DealerStock__c 
            WHERE Part__c = :productId
        ];
    }

    // 부품청구 조건을 확인하기 위한 데이터 가져오기
    @AuraEnabled
    public static WorkOrder getWorkOrder(Id recordId) {
        return [
            SELECT Id, OrderType__c, Case.checkBillingStatus__c, FM_isDirect__c,
            Case.Asset.FM_EquipmentWarrantyEquipmentParts__c, Case.FM_PartsWarranty__c
            FROM WorkOrder 
            WHERE Id = :recordId 
            LIMIT 1
        ];
    }

    // ProductRequest 오브젝트의 데이터를 가져오기
    @AuraEnabled
    public static List<ProductRequest> getPartRequests(String workOrderId) {
        return [
            SELECT Id, ProductCode__c, Product__r.Name, ToLabel(Status), Quantity__c, WorkOrderId, Product__r.FM_MaterialDetails__c
            FROM ProductRequest
            WHERE WorkOrderId = :workOrderId
            // WHERE Status = 'Request'
        ];
    }
    // WorkOrder 조회하는 메서드
    @AuraEnabled
    public static String getWorkOrders(String workOrderId) {
        WorkOrder wo = [SELECT Id, Noti_Number__c, ServiceOrderNumber__c
        FROM WorkOrder 
        WHERE Id = :workOrderId LIMIT 1];
        return wo.ServiceOrderNumber__c;
    }

    // 부품진행사항 조회 인터페이스
    @AuraEnabled
    public static Object getPartProgress(String notiNum) {
        System.debug('notiNum:::'+notiNum);

        IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();

        List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2> t_i_list2_list = new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2>();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2 t_i_list2 = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2();
        t_i_list2.SIGN = 'I';
        t_i_list2.OPTION = 'EQ';
        t_i_list2.LOW = notiNum;

        t_i_list2_list.add(t_i_list2);

        req.T_I_LIST2 = t_i_list2_list;
     
        IF_ERP_Material instance = new IF_ERP_Material();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = instance.IF_CSPLUS_007(req);
        System.debug('response007 ::: ' + response);

        return response;
    }
    
    // 본사재고 조회 인터페이스
    // @AuraEnabled
    // public static String getDealerInventory(Id productId){
    //     try {

    //         Product2 product = [
    //             SELECT Id, ProductCode, Name, ProductSpec__c,  Description, IsActive
    //             FROM Product2 WHERE Id = :productId AND RecordType.Name = 'Part'
    //             LIMIT 1
    //         ];

    //         IF_ERP_Material_Classes.IF_CSPLUS_021_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_021_Req();
    //         req.I_USERID = 'MITP0002';
    //         // req.I_MATNR = 'R18181';
    //         req.I_MATNR = product.ProductCode;
    //         IF_ERP_Material_Classes.IF_CSPLUS_021_I_ORG I_ORG = new IF_ERP_Material_Classes.IF_CSPLUS_021_I_ORG();
    //         // I_ORG.VKORG = '1846';
    //         // I_ORG.VTWEG = '20';
    //         // I_ORG.SPART = '40';
    //         // I_ORG.WERKS = '10';
    //         // I_ORG.ARBPL = '';
    //         // I_ORG.AMSCCTL = '';
    //         req.I_ORG = I_ORG;
    //         System.debug('{"Input":' + JSON.serialize(req) + '}');

    //         // IF_ERP_Material 클래스 호출
    //         IF_ERP_Material instance = new IF_ERP_Material();
    //         IF_ERP_Material_Classes.IF_CSPLUS_021_Res response = instance.IF_CSPLUS_021(req);

    //         // JSON 변환 및 반환
    //         return JSON.serialize(response);
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    // 딜러재고 조회하는 I/F 메서드
    @AuraEnabled
    public static String getDealerInventory(Id productId){
        try {
            Product2 product = [
                SELECT Id, ProductCode, Name, ProductSpec__c, Description, IsActive
                FROM Product2 WHERE Id = :productId AND RecordType.Name = 'Part'
                LIMIT 1
            ];
     
            // 1차 요청
            IF_ERP_Material_Classes.IF_CSPLUS_021_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_021_Req();
            req.I_USERID = 'MITP0002';
            req.I_MATNR = product.ProductCode;
            req.I_ORG = new IF_ERP_Material_Classes.IF_CSPLUS_021_I_ORG();
     
            IF_ERP_Material instance = new IF_ERP_Material();
            instance.interfaceUtil.isInsertLog = false;
            IF_ERP_Material_Classes.IF_CSPLUS_021_Res response = instance.IF_CSPLUS_021(req);
     
            if (response == null || response.ES_INFO == null) {
                throw new AuraHandledException('ERP 응답이 없습니다. 품번을 다시 확인해주세요.');
            }
     
            String repnr = response.ES_INFO.REPNR;
            String repnetpr = null;
     
            // 2차 요청 (대체품 품번)
            if (!String.isBlank(repnr)) {
                System.debug('repnr:::' + repnr);
                IF_ERP_Material_Classes.IF_CSPLUS_021_Req req2 = new IF_ERP_Material_Classes.IF_CSPLUS_021_Req();
                req2.I_USERID = 'MITP0002';
                req2.I_MATNR = repnr;
                req2.I_ORG = new IF_ERP_Material_Classes.IF_CSPLUS_021_I_ORG();
     

                IF_ERP_Material_Classes.IF_CSPLUS_021_Res response2 = instance.IF_CSPLUS_021(req2);
                
                System.debug('req2:::' + JSON.serialize(req2));
                if (response2 != null && response2.ES_INFO != null) {
                    repnetpr = response2.ES_INFO.NETPR;
                } else {
                    System.debug('대체품 품번 조회 실패 (repnr=' + repnr + ')');
                }
            }
     
            instance.interfaceUtil.saveInterfaceLog();

            // 결과 맵 구성
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('ES_INFO', response.ES_INFO);
            resultMap.put('REPLACEMENT_NETPR', repnetpr);
     
            return JSON.serialize(resultMap);
     
        } catch (Exception e) {
            System.debug('예외 발생: ' + e.getMessage());
            throw new AuraHandledException('오류 발생: ' + e.getMessage());
        }
    }

    // 부품청구 생성 메서드
    @AuraEnabled
    public static String createProductRequest(Id productId, Id workOrderId, Decimal quantity) {
        try {
            System.debug('productId:::' + productId);
            System.debug('workOrderId:::' + workOrderId);
            System.debug('quantity:::' + quantity);
            WorkOrder workOrder = [
                SELECT Id, CaseId, Case.OwnerId, WorkOrderNumber, Case.Owner.Name, OrderType__c, 
                Case.checkBillingStatus__c, FM_isDirect__c,
                Case.Asset.FM_EquipmentWarrantyEquipmentParts__c, Case.FM_PartsWarranty__c, ServiceOrderNumber__c
                FROM WorkOrder 
                WHERE Id = :workOrderId 
                LIMIT 1];

            System.debug('workOrder:::' + workOrder);
            Product2 product = [
                SELECT Id, ProductCode, Name, ProductSpec__c,  Description, IsActive, FM_MaterialDetails__c, NameEN__c
                FROM Product2 WHERE Id = :productId AND RecordType.Name = 'Part'
                LIMIT 1
            ];
            System.debug('product:::' + product);

            // if (workOrder.Case.checkBillingStatus__c == 'N') {
            //     System.debug('빌링처리가 되지 않은 장비는 부품 청구가 불가능합니다. 관리자에게 문의해주세요');
            //     return 'NO_BILLING';
            // }
    
            // Set<String> validOrderTypes = new Set<String>{'201', '202', '217'};
            // if (!(workOrder.Case.Asset.FM_EquipmentWarrantyEquipmentParts__c == 'Y / Y' 
            //       && validOrderTypes.contains(workOrder.OrderType__c))) {
            //     System.debug('무상Claim, 유상 Claim, 부품만청구 이면서 장비의 부품보증이 "Y / Y"가 아닙니다.');
            //     return 'NOT_ORDERTYPE';
            // }
    
            // if (!(workOrder.FM_isDirect__c)) {
            //     System.debug('오더의 출동 W/C가 직영이 아닙니다.');
            //     return 'NOT_DIRECTCLAIM';
            // }
            // if (!(workOrder.FM_isDirect__c && workOrder.OrderType__c == '202')) {
            //     System.debug('유상 Claim(202) 오더의 출동 W/C가 직영이 아닙니다.');
            //     return 'NOT_DIRECTCLAIM';
            // }
    
            // if (!(workOrder.OrderType__c == '204')) {
            //     System.debug('P-Claim(204) 오더 타입이 아닙니다.');
            //     return 'NOT_PCLAIM';
            // }
    
            // Set<String> validSPOrderTypes = new Set<String>{'215', '214'};
            // if (!validSPOrderTypes.contains(workOrder.OrderType__c)) {
            //     System.debug('유/무상 SP 입고수리(215, 214) 오더 타입이 아닙니다.');
            //     return 'NOT_SPREPAIR';
            // }
    
            // if (!(workOrder.OrderType__c == '202')) {
            //     System.debug('스핀들 버튼 활성화 조건(유상 Claim(202))이 아닙니다.');
            //     return 'NOT_SPINDLEELIGIBLE';
            // }


            List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
            String alertManagerID = [
                SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Part Billing Noti' LIMIT 1
            ].Id;
            NotiReceptionList__c indirectRecep = NotiReceptionList__c.getInstance('IndirectReception');
            String indirectRecepName = indirectRecep.UserName__c;
            User indrectUser = [SELECT Id FROM User WHERE UserName =:indirectRecepName];

            UTIL_Alert.historyWrapper hwrapper = new UTIL_Alert.historyWrapper();
            hwrapper.alertID = alertManagerID;
            hwrapper.targetID = workOrder.Id;
            hwrapper.alertType = 'Notification';
            hwrapper.alertLanguage = 'ko';
            // hwrapper.elementList.add(product.ProductCode, workOrder.WorkOrderNumber);
            hwrapper.elementList = new List<String>{product.ProductCode, workOrder.ServiceOrderNumber__c};
            hwrapper.title = '새로운 부품청구가 등록되었습니다. 품번:' + product.ProductCode + ' Ticket 소유자: ' + workOrder.Case.Owner.Name;
            hwrapper.receiverforID = new Set<Id>{indrectUser.Id, workOrder.Case.OwnerId};
            // hwrapper.receiverforID = mobileUserIds;

            hwList.add(hwrapper);
            if (!hwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(hwList);
                System.debug('Notification Sent for Board__c Insert');
            }

            ProductRequest newRequest = new ProductRequest();
            newRequest.Product__c = productId;
            newRequest.Status = 'New';
            newRequest.WorkOrderId = workOrderId;
            newRequest.Quantity__c = quantity;
            newRequest.CaseId = workOrder.CaseId;
            // newRequest.ProductName__c = product.FM_MaterialDetails__c;

            insert newRequest;

            // UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
            // hw.alertID = alertManagerID;
            // hw.targetID = workOrder.Id;
            // hw.alertType = 'Notification';
            // hw.alertLanguage = 'ko';
            // // hw.elementList.add(product.ProductCode, workOrder.WorkOrderNumber);
            // hw.elementList = new List<String>{product.ProductCode, workOrder.WorkOrderNumber};
            // hw.title = '새로운 부품청구가 등록되었습니다. 품번:' + product.ProductCode;
            // hw.receiverforID = new Set<Id>{workOrder.Case.OwnerId};
            // // hw.receiverforID = mobileUserIds;

            // hwList.add(hw);
            // if (!hwList.isEmpty()) {
            //     UTIL_Alert.runAlertEvent(hwList);
            //     System.debug('Notification Sent for Board__c Insert');
            // }
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 부품청구 삭제하는 메서드
    @AuraEnabled
    public static void deleteProductRequest(Id partId, Id workOrderId) {
        try {
            System.debug('partId:::' + partId);
            System.debug('workOrderId:::' + workOrderId);
            WorkOrder workOrder = [
                SELECT Id, CaseId, Case.OwnerId, WorkOrderNumber, 
                Case.Owner.Name, OrderType__c, Case.checkBillingStatus__c, FM_isDirect__c,
                Case.Asset.FM_EquipmentWarrantyEquipmentParts__c, Case.FM_PartsWarranty__c, ServiceOrderNumber__c
                FROM WorkOrder 
                WHERE Id = :workOrderId 
                LIMIT 1];

            System.debug('workOrder:::' + workOrder);
            ProductRequest partRequest = [SELECT Id, Status, Product__c FROM ProductRequest WHERE Id = :partId LIMIT 1];
            System.debug('partRequest:::' + partRequest);
            

            Product2 product = [
                SELECT Id, ProductCode, Name, ProductSpec__c,  Description, IsActive
                FROM Product2 WHERE Id = :partRequest.Product__c AND RecordType.Name = 'Part'
                LIMIT 1
            ];
            System.debug('product:::' + product);


            if (partRequest.Status == 'New') {
                List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
                String alertManagerID = [
                    SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Part Delete Billing Noti' LIMIT 1
                ].Id;
                NotiReceptionList__c indirectRecep = NotiReceptionList__c.getInstance('IndirectReception');
                String indirectRecepName = indirectRecep.UserName__c;
                User indrectUser = [SELECT Id FROM User WHERE UserName =:indirectRecepName];
    
                UTIL_Alert.historyWrapper hwrapper = new UTIL_Alert.historyWrapper();
                hwrapper.alertID = alertManagerID;
                hwrapper.targetID = workOrder.Id;
                hwrapper.alertType = 'Notification';
                hwrapper.alertLanguage = 'ko';
                // hwrapper.elementList.add(product.ProductCode, workOrder.WorkOrderNumber);
                hwrapper.elementList = new List<String>{product.ProductCode, workOrder.ServiceOrderNumber__c};
                hwrapper.title = '부품청구가 취소되었습니다. 품번:' + product.ProductCode + ' Ticket 소유자: ' + workOrder.Case.Owner.Name;
                hwrapper.receiverforID = new Set<Id>{indrectUser.Id};
                // hwrapper.receiverforID = mobileUserIds;
    
                hwList.add(hwrapper);
                if (!hwList.isEmpty()) {
                    UTIL_Alert.runAlertEvent(hwList);
                    System.debug('Notification Sent for Board__c Insert');
                }

                delete partRequest;
            } else {
                throw new AuraHandledException('상태가 "신규"인 경우에만 삭제할 수 있습니다.');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}