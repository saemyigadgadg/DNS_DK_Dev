/**
 * @description       : 오더 생성
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-17-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-26-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalPartOrderCreateController {
    public DN_PortalPartOrderCreateController() {}

    // 오더 생성 - 로그인 사용자 정보 확인
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        try {
            String userId = System.UserInfo.getUserId();
            DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
            return dealerInfo;

        } catch (Exception e) {
            system.debug('사용자 정보 에러 >>> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 오더 생성 - 오더 유형 picklist
    @AuraEnabled
    public static List<Map<String, String>> GetOrderTypeList(){
        try {
            List<Map<String, String>> orderTypeList = new List<Map<String, String>>();
            Schema.DescribeFieldResult fieldResult = PurchaseOrder__c.OrderType__c.getDescribe();

            List<Schema.PicklistEntry> picklistEnties = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry entry : picklistEnties) {
                Map<String, String> otRecord = new Map<String, String>();
                otRecord.put('label', entry.getLabel());
                otRecord.put('value', entry.getValue());
                orderTypeList.add(otRecord);
            }

            return orderTypeList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    
    
    // 오더 생성 - 배송정보 I/F
    @AuraEnabled
    public static List<ShippingInfo> GetShippingInfo(DN_PortalLoginUser.DealerInfo di){
        try {
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res result002 = InterFace_Parts_002(di);
            List <IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_LIST> tList = (List <IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_LIST>) result002.T_LIST;

            List<ShippingInfo> sInfo = new List<ShippingInfo>();
            for(IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_LIST sl : tList) {
                ShippingInfo si = new ShippingInfo(sl);
                sInfo.add(si);
            }

            return sInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    
    
    // 오더 생성 - CRM Product2 등록 확인
    @AuraEnabled
    public static List<Product2> SearchPartNo(List<String> pn){
        try { 
            system.debug('SearchPartNo');
            List<Product2> part = [
                SELECT Id, Name, ProductCode, FM_MaterialDetails__c
                FROM Product2
                WHERE ProductCode = :pn
                AND FM_MaterialDetails__c != null
            ];

            Map<String, Product2> productMap = new Map<String, Product2>();
            for (Product2 p : part) {
                productMap.put(p.ProductCode, p);
            }

            List<Product2> sortedPart = new List<Product2>();
            for (String code : pn) {
                if (productMap.containsKey(code)) {
                    sortedPart.add(productMap.get(code));
                }
            }
            system.debug('SearchPartNo sortedPart >>' +sortedPart);
            return sortedPart;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 오더생성 - 대체품 조회
    @AuraEnabled
    public static IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res CheckReplacement(DN_PortalLoginUser.DealerInfo dli, List<PartsList> plt){
        try {
            system.debug('CheckReplacement');
            IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res part004 = InterFace_Parts_004(dli, plt);
            system.debug('CheckReplacement part004 >> '+part004);
            return part004;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 오더생성 - 시뮬레이션
    @AuraEnabled
    public static IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res GetSimulationInfo(DN_PortalLoginUser.DealerInfo dli, List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM> plt, String odt){
        // public static IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res GetSimulationInfo(DN_PortalLoginUser.DealerInfo dli, List<PartsList> plt, String odt){
        try {
            system.debug('GetSimulationInfo');
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res part003 = InterFace_Parts_003(dli, plt, odt); 
            system.debug('GetSimulationInfo >>' +part003);
            return part003;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 오더생성 - 시뮬레이션
    @AuraEnabled
    public static IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res GetSimulationInfoMass(DN_PortalLoginUser.DealerInfo dli, List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM> plt, String odt, String odkey){
        // public static IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res GetSimulationInfo(DN_PortalLoginUser.DealerInfo dli, List<PartsList> plt, String odt){
        try {
            system.debug('GetSimulationInfo');
            IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res part009 = InterFace_Parts_009(dli, plt, odt, odkey); 
            system.debug('GetSimulationInfo >>' +part009);
            return part009;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 오더 생성 - 저장
    @AuraEnabled
    public static String SavePartOrder(OrderCreateInfo oci, Boolean custom){
        try {
            system.debug('all data >>> ' +oci);
            String pon = InterFace_Parts_005(oci, custom);
            String recordTypeName = 'Order';
            Id rTId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
            
            if(pon == '') {
                return '인터페이스 생성 실패';
            }else {
                PurchaseOrder__c purchaseOrder = oci.toPurchaseOrder(pon, rTId);
                insert purchaseOrder;
                List<PurchaseOrderItems__c> items = oci.toPurchaseOrderItems(purchaseOrder.Id);
                if (!items.isEmpty()) {
                    insert items;
                }
                return pon;
            }

        } catch (Exception e) {
            system.debug('오더 생성 에러 >>> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */
    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */

    
    // 배송정보 I/F
    private static IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res InterFace_Parts_002(DN_PortalLoginUser.DealerInfo di){
        try {
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Req part002 = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Req();

            part002.I_VKORG = di.salesOrganization;
            part002.I_VTWEG = di.distributionChannel;
            part002.I_SPART = di.division;
            part002.I_LANG  = di.language == 'en_US' ? 'EN' : di.language;
            // part002.I_LANG  = 'EN'; // 언어에 따라 표기 방법이 달라짐.
            part002.I_KUNNR = di.dealerCode.leftPad(10, '0');

            IF_ERP_Parts_Shipping method = new IF_ERP_Parts_Shipping();
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res result = method.IF_PARTS_002(part002);  
            return result;

        } catch (Exception e) {
            system.debug('배송 정보 I/F 에러 >>> '+e.getMessage());
            throw new AuraHandledException('배송 정보 I/F 에러 >>>  '+e.getMessage());
        }
    }

    // 시뮬레이션 I/F
    private static IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res InterFace_Parts_003(DN_PortalLoginUser.DealerInfo dli, List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM> plt, String odt){
        try {
            system.debug('InterFace_Parts_003');
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req();
            req.LV_AUART                    = odt;          // 주문 유형 >> YDOR
            // req.I_LANGU                     = dli.language; // 언어 >> ko
            req.I_LANGU                     = 'EN'; // 언어 >> ko

            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_USERINFO();

            // 딜러 10자리 반드시 들어가야 함. (딜러코드가 어디든 7자리고 어딘 10자리가 다 들어가야 작동되서 헷갈림. 그냥 10자리로 고정해서 넣기.)
            I_USERINFO.KUNNR              = dli.dealerCode.leftPad(10, '0'); // 딜러코드 >> 1057644
            I_USERINFO.VKORG              = dli.salesOrganization;   // 판매조직 >> 1846
            I_USERINFO.VTWEG              = dli.distributionChannel; // 채널     >> 10
            I_USERINFO.SPART              = dli.division;            // 분서     >> 40
            I_USERINFO.LAND1              = dli.country;             // 국가     >> KR
        
            req.I_USERINFO                = I_USERINFO;            

            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_MAIN_HEAD LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_MAIN_HEAD();
            LS_MAIN_HEAD.KONDA              = odt == 'YDOR' ? '28' : odt == 'YDEO' ? '20' : '40'; // 일반-28, 긴급-20, 스톡-40
            LS_MAIN_HEAD.KUNNR              = dli.dealerCode.leftPad(10, '0'); // 딜러코드 >> 1057644
            LS_MAIN_HEAD.KUNAG              = dli.dealerCode.leftPad(10, '0'); // 딜러코드 >> 1057644
            LS_MAIN_HEAD.KVGR5              = dli.division;   // 부서(?) >> 40

            req.LS_MAIN_HEAD                = LS_MAIN_HEAD;
        
            // 주석 처리시 에러 관리가 안 됨.
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_ERROR_IGNORE LS_ERROR_IGNORE = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_ERROR_IGNORE();
            LS_ERROR_IGNORE.IGNORE              = 'X';
            LS_ERROR_IGNORE.IGNORE_QTY          = 'X';
            LS_ERROR_IGNORE.IGNORE_PRICE        = 'X';
            LS_ERROR_IGNORE.IGNORE_DIVISION     = 'X';
            LS_ERROR_IGNORE.IGNORE_PURCHASE     = 'X';
        
            req.LS_ERROR_IGNORE                 = LS_ERROR_IGNORE;
        
            List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM> LT_ITEM_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM>();
            for(IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM pl : plt) {
                IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM LT_ITEM = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM();
                
                LT_ITEM.ITEM         = pl.ITEM;          // 항목
                LT_ITEM.MATERIAL     = pl.MATERIAL;      // 주문품번
                LT_ITEM.QTY          = pl.QTY;           // 수량
                LT_ITEM.REQ_QTY      = pl.REQ_QTY;       // 수량
                LT_ITEM.ZZAPPMACHINE = pl.ZZAPPMACHINE;  // 기종
                LT_ITEM.ZZEQMASTER   = pl.ZZEQMASTER;    // 장비번호
    
                LT_ITEM_List.add(LT_ITEM);
            }
            req.LT_ITEM = LT_ITEM_List;
        
            IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res result = instance.IF_PARTS_003(req);
            system.debug('InterFace_Parts_003 result >> ' +result);
            return result;

        } catch (Exception e) {
            system.debug('시뮬레이션 I/F 에러 >>> '+e.getMessage());
            throw new AuraHandledException('시뮬레이션 I/F 에러 >>> '+e.getMessage());
        }
    }

    // 시뮬레이션 I/F
    private static IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res InterFace_Parts_009(DN_PortalLoginUser.DealerInfo dli, List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM> plt, String odt, String getOdkey){
        try {
            system.debug('InterFace_Parts_009');
            Long random = Crypto.getRandomLong(); // 랜덤 Long 값
            String randomStr = String.valueOf(Math.abs(random)); // 음수 방지

            DateTime now = DateTime.now(); 
            String dateStr = now.format('yyMMdd');

            String oDkey = getOdkey != null ? getOdkey : randomStr + '_' + dateStr;
            System.debug('oDkey : ' + oDkey);
            IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req();
            req.LV_AUART                    = odt;          // 주문 유형 >> YDOR
            // req.I_LANGU                     = dli.language; // 언어 >> ko
            req.I_LANGU                     = 'EN'; // 언어 >> ko
            req.ODKEY                       = oDkey; // 오더 부품 고유 키키

            IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_I_USERINFO();

            // 딜러 10자리 반드시 들어가야 함. (딜러코드가 어디든 7자리고 어딘 10자리가 다 들어가야 작동되서 헷갈림. 그냥 10자리로 고정해서 넣기.)
            I_USERINFO.KUNNR              = dli.dealerCode.leftPad(10, '0'); // 딜러코드 >> 1057644
            I_USERINFO.VKORG              = dli.salesOrganization;   // 판매조직 >> 1846
            I_USERINFO.VTWEG              = dli.distributionChannel; // 채널     >> 10
            I_USERINFO.SPART              = dli.division;            // 분서     >> 40
            I_USERINFO.LAND1              = dli.country;             // 국가     >> KR
        
            req.I_USERINFO                = I_USERINFO;            

            IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LS_MAIN_HEAD LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LS_MAIN_HEAD();
            LS_MAIN_HEAD.KONDA              = odt == 'YDOR' ? '28' : odt == 'YDEO' ? '20' : '40'; // 일반-28, 긴급-20, 스톡-40
            LS_MAIN_HEAD.KUNNR              = dli.dealerCode.leftPad(10, '0'); // 딜러코드 >> 1057644
            LS_MAIN_HEAD.KUNAG              = dli.dealerCode.leftPad(10, '0'); // 딜러코드 >> 1057644
            LS_MAIN_HEAD.KVGR5              = dli.division;   // 부서(?) >> 40

            req.LS_MAIN_HEAD                = LS_MAIN_HEAD;
        
            // 주석 처리시 에러 관리가 안 됨.
            IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LS_ERROR_IGNORE LS_ERROR_IGNORE = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LS_ERROR_IGNORE();
            LS_ERROR_IGNORE.IGNORE              = 'X';
            LS_ERROR_IGNORE.IGNORE_QTY          = 'X';
            LS_ERROR_IGNORE.IGNORE_PRICE        = 'X';
            LS_ERROR_IGNORE.IGNORE_DIVISION     = 'X';
            LS_ERROR_IGNORE.IGNORE_PURCHASE     = 'X';
        
            req.LS_ERROR_IGNORE                 = LS_ERROR_IGNORE;
        
            List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_ITEM> LT_ITEM_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_ITEM>();
            for(IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM pl : plt) {
                IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_ITEM LT_ITEM = new IF_ERP_Parts_Order_Classes.IF_PARTS_009_Req_LT_ITEM();
                
                LT_ITEM.ITEM         = pl.ITEM;          // 항목
                LT_ITEM.MATERIAL     = pl.MATERIAL;      // 주문품번
                LT_ITEM.QTY          = pl.QTY;           // 수량
                LT_ITEM.REQ_QTY      = pl.REQ_QTY;       // 수량
                LT_ITEM.ZZAPPMACHINE = pl.ZZAPPMACHINE;  // 기종
                LT_ITEM.ZZEQMASTER   = pl.ZZEQMASTER;    // 장비번호
    
                LT_ITEM_List.add(LT_ITEM);
            }
            req.LT_ITEM = LT_ITEM_List;
        
            IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
            IF_ERP_Parts_Order_Classes.IF_PARTS_009_Res result = instance.IF_PARTS_009(req);
            result.ODKEY = oDkey; // 오더 부품 고유 키키
            system.debug('InterFace_Parts_009 result >> ' +result);
            return result;

        } catch (Exception e) {
            system.debug('시뮬레이션 I/F 에러 >>> '+e.getMessage());
            throw new AuraHandledException('시뮬레이션 I/F 에러 >>> '+e.getMessage());
        }
    }

    // 시뮬레이션 전 대체품 조회 I/F
    private static IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res InterFace_Parts_004(DN_PortalLoginUser.DealerInfo dli, List<PartsList> plt){
        try {
            system.debug('InterFace_Parts_004');
            IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req req = new IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req();
            req.I_WERKS             = dli.salesOrganization;
        
            List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req_T_ITEM> T_ITEM_List = new List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req_T_ITEM>();
            for(PartsList pl : plt) {
                IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req_T_ITEM T_ITEM = new IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Req_T_ITEM();
                T_ITEM.ITEM            = pl.hang;
                T_ITEM.MATERIAL        = pl.orderPartNo;
                T_ITEM.QTY             = pl.quantity;
                T_ITEM.REQ_QTY         = pl.quantity;
                T_ITEM.ZZAPPMACHINE    = pl.machine;
                T_ITEM.ZZEQMASTER      = pl.equipment;
                // T_ITEM.MITEM           = 'X';
                
                T_ITEM_List.add(T_ITEM);
            }

            req.T_ITEM  = T_ITEM_List;

            IF_ERP_Parts_Substitute instance = new IF_ERP_Parts_Substitute();
            instance.interfaceUtil.isInsertLog = false;
            IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res result = instance.IF_PARTS_004(req);
            system.debug('InterFace_Parts_004 result >> ' +result);

            return result;

        } catch (Exception e) {
            system.debug('시뮬레이션 전 대체품 조회 I/F 에러 >>> '+e.getMessage());
            throw new AuraHandledException('시뮬레이션 전 대체품 조회 I/F 에러 >>> '+e.getMessage());
        }
    }

    // @description 오더 생성 I/F
    private static String InterFace_Parts_005(OrderCreateInfo oci, Boolean custom) {
        try {          
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req();
            req.LV_AUART                = oci.orderType; // 오더 유형
            req.I_LANGU                 = oci.dealerInfo.language;
            req.I_VKORG                 = oci.dealerInfo.salesOrganization;
            req.I_VTWEG                 = oci.dealerInfo.distributionChannel;
            req.I_SPART                 = oci.dealerInfo.division;
            req.I_KUNNR                 = oci.dealerInfo.dealerCode.leftPad(10, '0'); // 딜러코드            
            // req.I_USERID                = 'P_MTDO'; // userId 따로 관리 안하지만 이상한 값이 들어가서 일단 고정 값으로 변경

            // 주소 입력(수기)
            if(custom) {
                IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_EP_ONETIME LS_EP_ONETIME = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_EP_ONETIME();
                LS_EP_ONETIME.CITY        = oci.shippingLocation.city;                // 도시
                LS_EP_ONETIME.NAME        = oci.shippingLocation.shippingDestination; // 고객사 이름
                LS_EP_ONETIME.POSTL_CODE  = oci.shippingLocation.zipCode;             // 우편 번호
                LS_EP_ONETIME.STREET      = oci.shippingLocation.street;              // 상세 주소
                LS_EP_ONETIME.NAME_2      = oci.shippingLocation.partManager;         // 담당자 이름
                LS_EP_ONETIME.TELEPHONE   = oci.shippingLocation.partManagerMP;       // 담당자 전화번호
                req.LS_EP_ONETIME         = LS_EP_ONETIME;    
            }

            // 배송처 선택시
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_MAIN_HEAD LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_MAIN_HEAD();
            LS_MAIN_HEAD.KONDA          = oci.orderType == 'YDOR' ? '28' : oci.orderType == 'YDEO' ? '20' : '40'; // 일반-28, 긴급-20, 스톡-40
            LS_MAIN_HEAD.KUNNR          = oci.dealerInfo.dealerCode.leftPad(10, '0');   // 딜러코드
            LS_MAIN_HEAD.KUNAG          = oci.shippingLocation.customerCode;            // 고객 코드
            LS_MAIN_HEAD.KVGR5          = oci.dealerInfo.division;                      // 딜러부서
        
            req.LS_MAIN_HEAD            = LS_MAIN_HEAD;
            
            // 배송 방법
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_GENERAL LS_GENERAL = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_GENERAL();
            LS_GENERAL.BSTNK            = oci.customerOrderNo;                       // 고객주문번호
            LS_GENERAL.COMPLETE_DELIVERY= oci.consolidatedShipping == 'YES' ? 'X' : ''; //일괄배송 여부
            LS_GENERAL.INCO1            = oci.shippingInfo.transportationTermOne;    // 배송조건 1
            LS_GENERAL.INCO2            = oci.shippingInfo.transportationTermTwo;    // 배송조건 2
            LS_GENERAL.VDATU            = String.valueOf(oci.shippingInfo.requestedDeliveryDate);  // 요청날짜
            LS_GENERAL.VSBED            = oci.shippingInfo.shippingCode;             // 배송조건 아이디 (택배, 트럭, 퀵, 수령)
        
            req.LS_GENERAL              = LS_GENERAL;
        
            // ??
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_I_ORG I_ORG = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_I_ORG();
            req.I_ORG                   = I_ORG;

            List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM> LT_GERNERAL_ZTERM_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM>();
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM LT_GERNERAL_ZTERM = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM();
            LT_GERNERAL_ZTERM.ZTERM     = oci.shippingInfo.paymentTerm2;
        
            LT_GERNERAL_ZTERM_List.add(LT_GERNERAL_ZTERM);
            req.LT_GERNERAL_ZTERM = LT_GERNERAL_ZTERM_List;
        
            // parts List
            List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM> LT_ITEM_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM>();

            List<PartsList> psl = (List<PartsList>)oci.sapPartsList;
            for(PartsList pl : psl) {
                IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM re = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM();
                
                re.ITEM         = pl.hang;          // 항목
                re.EMERC        = pl.urgency == true ? 'T' : '';  // 긴급도
                re.MATERIAL     = pl.orderPartNo;   // 주문품번
                re.QTY          = pl.quantity;      // 수량
                re.REQ_QTY      = pl.quantity;      // 수량2
                re.ZZAPPMACHINE = pl.machine;       // 기종
                re.ZZEQMASTER   = pl.equipment;     // 장비번호
    
                LT_ITEM_List.add(re);
            }
            req.LT_ITEM       = LT_ITEM_List;
        
            IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res result = instance.IF_PARTS_005(req);
            String recordNo = result.LV_VENLR;
            return recordNo;
    
        } catch (Exception e) {
            system.debug('오더 저장 I/F 에러 >>> '+e.getMessage());
            system.debug('오더 저장 I/F 추적 >>> '+e.getStackTraceString());
            throw new AuraHandledException('오더 저장 I/F 에러 >>> '+e.getMessage());
        }
    }

    /* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */
    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    /* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */
    /* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */

    // 오더 생성 - 배송정보 wrapper
    public class ShippingInfo {
        @AuraEnabled public String shippingTerm          {get; set;}  // 선적 조건
        @AuraEnabled public String shippingCode          {get; set;}  // 선적 코드
        @AuraEnabled public String shippingRoute         {get; set;}  // 배송 경로
        @AuraEnabled public String shippingRoute2        {get; set;}  // 배송 경로(약어)
        @AuraEnabled public String paymentTerm           {get; set;}  // 지급 조건
        @AuraEnabled public String paymentTerm2          {get; set;}  // 지급 조건(약어)
        @AuraEnabled public String transportationTermOne {get; set;}  // 운송 조건 1
        @AuraEnabled public String transportationTermTwo {get; set;}  // 운송 조건 2
        @AuraEnabled public Date   requestedDeliveryDate {get; set;}  // 요청배송일자

        // 오더 생성시 사용
        public ShippingInfo(IF_ERP_Parts_Shipping_Classes.IF_PARTS_002_Res_T_LIST sl) {
            this.shippingTerm          = sl.VSBED_TX;  // 선적 조건
            this.shippingCode          = sl.VSBED;     // 선적 코드
            this.shippingRoute         = sl.ROUTE_TX;  // 배송 경로
            this.shippingRoute2        = sl.ROUTE;     // 배송 경로(약어)
            this.paymentTerm           = sl.ZTERM_TX == '' ? sl.ZTERM : sl.ZTERM_TX; // 지급 조건 (EN 인 경우 두비즈와 같은 값이 잇지만 KO 인 경우 해당 값이 빈값으로 들어옴)
            this.paymentTerm2          = sl.ZTERM;     // 지급 조건(약어-저장시 필요)
            this.transportationTermOne = sl.INCO1;     // 운송 조건 1
            this.transportationTermTwo = sl.INCO2;     // 운송 조건 2
        }
        public ShippingInfo() {}
    }

    // 오더 생성 - 배송처 Wrapper
    public class ShippingLocation {
        @AuraEnabled public String supplier              {get; set;}  // 공급업체
        @AuraEnabled public String buyerNo               {get; set;}  // 구매자 번호
        @AuraEnabled public String buyerId               {get; set;}  // 구매자 Id
        @AuraEnabled public String buyer                 {get; set;}  // 구매자

        // 수취자(고객) Id는 못씀. 수기입력일 경우 Id를 넣을 수 없음.
        @AuraEnabled public String customerId            {get; set;}  // 고객 Id 
        @AuraEnabled public String customerCode          {get; set;}  // 고객 코드

        @AuraEnabled public String shippingDestination   {get; set;}  // 배송처
        @AuraEnabled public String shippingAddress       {get; set;}  // 배송처 주소
        @AuraEnabled public String city                  {get; set;}  // 도시
        @AuraEnabled public String street                {get; set;}  // 거리
        @AuraEnabled public String zipCode               {get; set;}  // 우편번호
        @AuraEnabled public String partManager           {get; set;}  // 부품 담당자
        @AuraEnabled public String partManagerMP         {get; set;}  // 배송처 전화번호

        public ShippingLocation() {}
    }

    // 오더 생성 - PartsList Wrapper
    public class PartsList {
        @AuraEnabled public String hang             {get; set;} // hang
        @AuraEnabled public String partId           {get; set;} // partId
        @AuraEnabled public String orderPartNo      {get; set;} // orderPartNo
        @AuraEnabled public String supplyPartNo     {get; set;} // supplyPartNo
        @AuraEnabled public String partName         {get; set;} // partName
        @AuraEnabled public Boolean urgency         {get; set;} // urgency
        @AuraEnabled public String quantity         {get; set;} // quantity
        @AuraEnabled public String salesUnit        {get; set;} // salesUnit
        @AuraEnabled public String unit             {get; set;} // unit
        @AuraEnabled public String unitPrice        {get; set;} // unitPrice
        @AuraEnabled public String partsAmount      {get; set;} // partsAmount
        @AuraEnabled public String piCurrency       {get; set;} // currency
        @AuraEnabled public String availableStock   {get; set;} // availableStock
        @AuraEnabled public String twp              {get; set;} // twp
        @AuraEnabled public String bulletin         {get; set;} // bulletin
        @AuraEnabled public String note             {get; set;} // note
        @AuraEnabled public String machine          {get; set;} // machine
        @AuraEnabled public String equipment        {get; set;} // equipment
        @AuraEnabled public String orderPartId      {get; set;} // orderPartId
        @AuraEnabled public String supplyPartId     {get; set;} // supplyPartId

        public PartsList () {}
    }

    // 오더 생성 - CRM 저장 Wrapper
    public class OrderCreateInfo {
        @AuraEnabled public String orderType                    {get; set;}  // 주문 유형
        @AuraEnabled public String customerOrderNo              {get; set;}  // 고객주문번호
        @AuraEnabled public String consolidatedShipping         {get; set;}  // 일괄배송여부
        @AuraEnabled public ShippingLocation shippingLocation   {get; set;}  // 배송처 정보
        @AuraEnabled public ShippingInfo shippingInfo           {get; set;}  // 배송방법 정보

        @AuraEnabled public DN_PortalLoginUser.DealerInfo dealerInfo {get; set;}  // 딜러 정보

        @AuraEnabled public List<PartsList> crmPartsList        {get; set;}  // CRM 부품정보
        @AuraEnabled public List<PartsList> sapPartsList        {get; set;}  // SAP 부품정보

        // PurchaseOrder__c
        public PurchaseOrder__c toPurchaseOrder(String pon, Id rTId) {
            PurchaseOrder__c pco = new PurchaseOrder__c();
            // 기타
            pco.PartOrderNo__c              = pon;
            pco.RecordTypeId                = rTId;
            pco.CustomerOrderNo__c          = customerOrderNo;
            pco.ConsolidatedShipping__c     = consolidatedShipping;
            pco.OrderType__c                = orderType;

            // 배송방법
            pco.PaymentTerm__c              = shippingInfo.paymentTerm != null ? shippingInfo.paymentTerm : '';
            pco.ShippingTerm__c             = shippingInfo.shippingTerm != null ? shippingInfo.shippingTerm : '';
            pco.RequestedDeliveryDate__c    = shippingInfo.requestedDeliveryDate;
            pco.TransportationTermOne__c    = shippingInfo.transportationTermOne != null ? shippingInfo.transportationTermOne : '';
            pco.TransportationTermTwo__c    = shippingInfo.transportationTermTwo != null ? shippingInfo.transportationTermTwo : '';
            
            // 주문자
            pco.Buyer__c                    = dealerInfo.accountId != '' ? dealerInfo.accountId : null;
            pco.BuyerNo__c                  = dealerInfo.dealerCode;

            // 배송처
            pco.PartManager__c              = shippingLocation.partManager != null ? shippingLocation.partManager : '';
            pco.PartManagerMobilePhone__c   = shippingLocation.partManagerMP != null ? shippingLocation.partManagerMP : '';
            pco.ShippingDestination__c      = shippingLocation.shippingDestination != null ? shippingLocation.shippingDestination : '';
            pco.Supplier__c                 = shippingLocation.supplier != null ? shippingLocation.supplier : '';
            pco.ZipCode__c                  = shippingLocation.zipCode != null ? shippingLocation.zipCode : '';
            pco.Street__c                   = shippingLocation.street != null ? shippingLocation.street : '';
            pco.City__c                     = shippingLocation.city != null ? shippingLocation.city : '';
            pco.ShippingAddress__c          = '('+pco.ZipCode__c+')'+' '+pco.Street__c;
            pco.CustomerCode__c             = shippingLocation.customerCode;

            return pco;
        }

        // PurchaseOrderItems__c
        public List<PurchaseOrderItems__c> toPurchaseOrderItems(Id purchaseOrderId) {
            List<PurchaseOrderItems__c> items = new List<PurchaseOrderItems__c>();
            for (PartsList part : crmPartsList) {
                PurchaseOrderItems__c item = new PurchaseOrderItems__c();
                item.PurchaseOrder__c      = purchaseOrderId;
                item.ItemNo__c             = part.hang;
                item.OrderPartNo__c        = part.orderPartNo;
                item.PartName__c           = part.partName;
                item.Currency__c           = part.piCurrency;
                item.Quantity__c           = Integer.valueOf(part.quantity);
                item.SupplyPartNo__c       = part.supplyPartNo;
                item.Unit__c               = part.unit;
                item.UnitPrice__c          = part.unitPrice == '' ? 0 : Decimal.valueOf(part.unitPrice.replace(',',''));
                item.MachineName__c        = part.machine;
                item.EquipmentNo__c        = part.equipment;
                item.OrderPartId__c        = part.orderPartId;
                item.SupplyPartId__c       = part.supplyPartId == '' ? null : part.supplyPartId;
                items.add(item);
            }
            return items;
        }

        public OrderCreateInfo() {}
    }        
}