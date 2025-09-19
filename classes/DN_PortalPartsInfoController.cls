/**
 * @description       : 부품정보 > 부품기본정보/멀티부품정보
 * @author            : Daewook.KIM
 * @last modified on  : 07-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   11-07-2024   Daewook.KIM   Initial Version
**/
public with sharing class DN_PortalPartsInfoController {
    public DN_PortalPartsInfoController() {}

    // 부품 정보 - 사용자 정보
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        try {
            String userId = System.UserInfo.getUserId();
            DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
            return dealerInfo;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 부품정보 >> 부품 기본 정보 - 검색(조회)
    @AuraEnabled
    public static List<Product2> SearchPartNo(List<String> pn){
        try { 
            system.debug('pn >> '+pn);
            List<Product2> part = [
                SELECT Id, Name, ProductCode, FM_MaterialDetails__c
                FROM Product2
                WHERE ProductCode = :pn
                AND RecordType.Name = 'Part'
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
            return sortedPart;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 부품 기본 정보 && 오더조회>>오더상세정보>>부품기본정보 에서 호출함.
    @AuraEnabled
    public static Map<String, Object> SeachPart(String partNo, DN_PortalLoginUser.DealerInfo userInfo){
        try {
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req req = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req();
            req.I_MATNR = partNo;
            // 부품 정보가 언어 설정에 따라 변경됨. DN 에서 영어로 표시되는 걸 원해 EN 으로 하드코딩한 상태임.
            req.I_LANGU = 'EN';
    
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO i_userinfo = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO();
            i_userinfo.KUNNR = userInfo.dealerCode;
            i_userinfo.VKORG = userInfo.salesOrganization;
            i_userinfo.VTWEG = userInfo.distributionChannel;
            i_userinfo.SPART = userInfo.division;

            req.I_USERINFO = i_userinfo;
            IF_ERP_Service_PartsDetail method = new IF_ERP_Service_PartsDetail();
    
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res result = method.IF_SERVICE_037(req);
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_O_RETURN returnM = (IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_O_RETURN) result.O_RETURN;
            
            Map<String, Object> partBasicInfoRecord = new Map<String, Object>();
    
            List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS> et_cross = new List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS>();
            List<ReplacementInfo> replacementInfo = new List<ReplacementInfo>();
    
            if(result.ET_CROSS.size() > 0) {
                et_cross = (List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS>) result.ET_CROSS;
                for(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS rp : et_cross) {
                    ReplacementInfo rpi = new ReplacementInfo(rp);
                    replacementInfo.add(rpi);
                }
            }
            system.debug('result >> ' +result);
            PartsBasicInfo partBasicInfo = new PartsBasicInfo(result);
            system.debug('partBasicInfo >> ' +partBasicInfo);
            partBasicInfoRecord.put('replacementInfo', replacementInfo);
            partBasicInfoRecord.put('partBasicInfo', partBasicInfo);
            partBasicInfoRecord.put('message', returnM.MESSAGE);

            return partBasicInfoRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 대체품 정보 && 오더조회>>오더상세정보>>부품기본정보 에서 호출함.
    @AuraEnabled
    public static List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST> SeachPart2(String partNo, DN_PortalLoginUser.DealerInfo userInfo){
        try {
            system.debug('partNo >> ' + partNo);
            system.debug('userInfo >> ' + userInfo);
            List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST> result038 = InterFace_Service_038(partNo, userInfo);

            return  result038;
        } catch (Exception e) {
            // system.debug()
            throw new AuraHandledException(e.getMessage());
        }
    }    

    // 멀티 부품 조회 - 엑셀 업로드 부품 검사용
    @AuraEnabled
    public static List<Product2> CheckProduct(List<String> psl){
            return [ SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode =: psl AND RecordType.Name = 'Part'];
    }

    // 부품기본정보 - 대리점별 대체품 재고 파악
    @AuraEnabled
    public static List<DealerStock__c> GetCurrentStock(DN_PortalLoginUser.DealerInfo dli, String ptn){
        try {
            system.debug('dli :: ' + dli);
            system.debug('ptn :: ' + ptn);
            List<String> partList = new List<String>();
            partList.add(ptn);
            List<Product2> productList = CheckProduct(partList);

            if (productList.isEmpty()) {
                return null; // 빈 리스트일 경우 바로 리턴
            }
            
            String partId = productList[0].Id;
            
            system.debug('partId >>>>> ' + partId);
            AllAccessRecord allAccess = new AllAccessRecord();

            String queryStr = 'SELECT Id, Dealer__c, Dealer__r.Name, CurrentStockQuantity__c, Note__c, AvailableQuantity__c '
            +' FROM DealerStock__c '
            +' WHERE Part__c = \''+ partId +'\' '
            +' AND Dealer__c IN( SELECT AccountId FROM User '
            +' WHERE UserType = \'PowerPartner\''
            +' AND Profile.Name =\'DNS CS Parts_Partner\''
            +' AND IsActive =true)';

            List<DealerStock__c> partStock = (List<DealerStock__c>) allAccess.query(queryStr);
            system.debug('partStock >> '+partStock);

            return partStock;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public without sharing class AllAccessRecord {
        public List<SObject> query(String query) {
            return Database.query(query);
        }
    }

    // 부품정보 >> 멀티부품정보조회 - 검색(조회)
    @AuraEnabled
    public static List<PartsBasicInfo> MultiSearch(List<String> dl, DN_PortalLoginUser.DealerInfo ui){
        try {
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req req002 = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();
            req002.I_LANGU         = 'EN'; // 화면에 영어로 보여게 해달라는 요청으로 고정
        
            List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL> D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();

            if (dl != null && !dl.isEmpty()) { 
                for (String searchItem : dl) { 
                    IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
                    D_DETAIL.MATNR = searchItem;
                    D_DETAIL_List.add(D_DETAIL);
                }
            }
            req002.D_DETAIL            = D_DETAIL_List;

            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
        
            I_USERINFO.KUNNR        = ui.dealerCode;
            I_USERINFO.VKORG        = ui.salesOrganization;
            I_USERINFO.VTWEG        = ui.distributionChannel;
            I_USERINFO.SPART        = ui.division;
            // I_USERINFO.LAND1        = ui.country;
            I_USERINFO.DF_CHK       = 'X';

            req002.I_USERINFO        = I_USERINFO;
        
            IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res result = instance.IF_PARTS_022(req002);

            List<PartsBasicInfo> multiList = new List<PartsBasicInfo>();
            for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL mlt : result.D_DETAIL) {
                PartsBasicInfo mList = new PartsBasicInfo(mlt);
                multiList.add(mList);
            }
            return multiList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    

    /* ********************************************************************************************************************************************************************** */
    /* ********************************************************************************************************************************************************************** */

    public class PartsBasicInfo {
        @AuraEnabled public String partNo               {get; set;}  // 품번
        @AuraEnabled public String partName             {get; set;}  // 품명
        @AuraEnabled public Decimal stockQuantity       {get; set;}  // 재고수량(창원)
        @AuraEnabled public Decimal stockQuantity2       {get; set;}  // 재고수량(천안)
        @AuraEnabled public Integer unitPrice           {get; set;}  // 단가
        @AuraEnabled public Integer consumerPrice       {get; set;}  // 소비자 가격
        @AuraEnabled public String priceEffectiveDate   {get; set;}  // 가격 적용일
        @AuraEnabled public String purchaseLeadTime     {get; set;}  // 구매 Lead Time(days)
        @AuraEnabled public String specification        {get; set;}  // 규격
        @AuraEnabled public String unit                 {get; set;}  // 단위
        @AuraEnabled public String serviceLeadTime      {get; set;}  // Service Lead Time(day)
        @AuraEnabled public String replacementPart      {get; set;}  // 대체품
        @AuraEnabled public String pbiCurrency          {get; set;}  // Currency

        @AuraEnabled public String serviceSupply        {get; set;}  // 서비스 공급 여부
        @AuraEnabled public String serviceNotSupply     {get; set;}  // 서비스 미 공급 사유
        // @AuraEnabled public String partMemo             {get; set;}  // 부품 메모 => 타 대리점 재고 관리에서 가져올 정보(아직 설정 값 없음)

        public PartsBasicInfo(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res pi) {
            this.partName             = pi.O_RESULT.MAKTX;  // 품명
            // this.stockQuantity        = Integer.valueOf(pi.O_AVAIL_QTY) <= 0 ? 0 : Integer.valueOf(pi.O_AVAIL_QTY);  // 재고수량 
            this.stockQuantity        = Decimal.valueOf(pi.O_AVAIL_QTY) <= 0 ? 0 : Decimal.valueOf(pi.O_AVAIL_QTY);  // 재고수량 (창원)
            this.stockQuantity2        = Decimal.valueOf(pi.O_AVAIL_QTY2) <= 0 ? 0 : Decimal.valueOf(pi.O_AVAIL_QTY2);  // 재고수량 (천안)
            this.unitPrice            = Integer.valueOf(pi.O_RESULT.NETPR_ETC);  // 단가 >> COND_VALUE 일지도?
            this.consumerPrice        = Integer.valueOf(pi.O_RESULT.NETPR);  // 소비자 가격
            this.priceEffectiveDate   = String.valueOf(pi.O_RESULT.DATAB).split('-')[0] == '0000' ? '' : pi.O_RESULT.DATAB.replaceAll('-', '.');  // 가격 적용일
            this.purchaseLeadTime     = pi.O_RESULT.PLIFZ;  // 구매 Lead Time(days)
            
            this.specification        = pi.O_THREAD;  // 규격
            this.unit                 = pi.O_RESULT.MEINS;  // 단위
            this.serviceLeadTime      = pi.O_RESULT.AVRLT;  // Service Lead Time(day)
            this.pbiCurrency          = pi.O_RESULT.CURRENCY2;  // 통화
            this.serviceSupply        = pi.O_RESULT.SVRCD_TEXT;  // 서비스 공급 사유
            this.serviceNotSupply     = pi.O_RESULT.NOTCD_TEXT;  // 서비스 미 공급 사유
        }

        // 멀티 부품 조회 WRAPPER
        public PartsBasicInfo(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL mtl) {
            this.partNo             = mtl.MATNR;        // 품번
            this.partName           = mtl.MAKTX;        // 품명
            // this.stockQuantity      = mtl.AVAIL_QTY == '0.00' ? 0 : Integer.valueOf(mtl.AVAIL_QTY); // 재고수량
            this.stockQuantity      = mtl.AVAIL_QTY == '0.00' ? 0 : Decimal.valueOf(mtl.AVAIL_QTY);
            this.stockQuantity2      = mtl.AVAIL_QTY2 == '0.00' ? 0 : Decimal.valueOf(mtl.AVAIL_QTY2);
            this.unitPrice          = mtl.NETPR_ETC == '0.00' ? 0 : Integer.valueOf(mtl.NETPR_ETC); // 단가
            this.consumerPrice      = mtl.NETPR == '0' ? 0 : Integer.valueOf(mtl.NETPR);            // 소비자 가격
            this.priceEffectiveDate = mtl.DATAB.split('-')[0] == '0000' ? '' : mtl.DATAB.replace('-','.'); // 가격 적용일
            this.purchaseLeadTime   = mtl.PLIFZ;        // 구매 Lead Time(days)
            this.serviceLeadTime    = mtl.SVCLT;        // Service Lead Time(day)
            this.replacementPart    = mtl.SUB_MATERIAL; // 대체품
            this.specification      = mtl.THREAD;       // 규격
            this.unit               = mtl.MEINS;        // 단위
            this.pbiCurrency        = mtl.CURRENCY2;    // 통화
        }

        public PartsBasicInfo() {}
    }
    
    public class ReplacementInfo {
        @AuraEnabled public String seq              {get; set;}  // Seq
        @AuraEnabled public String material         {get; set;}  // Material
        @AuraEnabled public String mamterialDesc    {get; set;}  // Material Desc.
        @AuraEnabled public String ica              {get; set;}  // ICA
        @AuraEnabled public String nsr              {get; set;}  // NSR
        @AuraEnabled public Decimal avilQty         {get; set;}  // Avil.Qty
        @AuraEnabled public Decimal avilQty2         {get; set;}  // Avil.Qty

        public ReplacementInfo(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS rp) {
            this.seq           = rp.SEQ;    // Seq
            this.material      = rp.MATNR;  // Material
            this.mamterialDesc = rp.MAKTX;  // Material Desc.
            this.ica           = rp.ITCCD;  // ICA
            // this.nsr           = rp.DDTEXT; // NSR >> NOTCD 일 수도
            this.nsr           = rp.NOTCD; // NSR >> NOTCD 일 수도
            this.avilQty       = Decimal.valueOf(rp.LABST);  // Avil.Qty
            this.avilQty2       = Decimal.valueOf(rp.LABST2);  // Avil.Qty
        }
        public ReplacementInfo() {}
    }

    /* ******************************************************************** Interface ******************************************************************** */

    // 대체품 정보 I/F
    private static List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST> InterFace_Service_038(String partNo, DN_PortalLoginUser.DealerInfo userInfo) {
        try {

            system.debug('partNo >> ' + partNo);
            system.debug('userInfo >> ' + userInfo);
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req req038 = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req();

            req038.I_MATNR = partNo;
            // req038.I_LANGU = userInfo.language;
            req038.I_LANGU = 'EN';
    
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req_I_USERINFO i_userinfo = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Req_I_USERINFO();
    
            i_userinfo.VKORG = userInfo.salesOrganization;
            i_userinfo.VTWEG = userInfo.distributionChannel;
            i_userinfo.SPART = userInfo.division;
    
            req038.I_USERINFO = i_userinfo ;
            IF_ERP_Service_PartsDetail method = new IF_ERP_Service_PartsDetail();
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res result038 = method.IF_SERVICE_038(req038);
    
            List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST> result = (List<IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_038_Res_T_LIST>) result038.T_LIST;
    
            return result;
        } catch(Exception e){
            system.debug('038 인터페이스 >>' +e.getMessage());
            system.debug('038 인터페이스 >>' +e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

    }
}