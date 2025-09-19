/**PartsInquiryInfo
 * @description       : (포탈) 반품 생성 및 조회 래퍼
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 05-19-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-28-2024   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalPartWrapper {
    public DN_PortalPartWrapper() {} 

    // 반품 오더 조회 조건
    public class ReturnOrderTerms {
        @AuraEnabled public DN_PortalLoginUser.DealerInfo dealerInfo   {get; set;}
        @AuraEnabled public String returnOrderNo    {get; set;}
        @AuraEnabled public String referenceNo      {get; set;}
        @AuraEnabled public String orderPartNo      {get; set;}
        @AuraEnabled public Date   startDate        {get; set;}
        @AuraEnabled public Date   endDate          {get; set;}
    }

    // 반품 오더 생성 조건
    public class RefundOrderInfo {
        @AuraEnabled public DN_PortalLoginUser.DealerInfo dealerInfo {get; set;}  // 딜러 정보
        @AuraEnabled public String refundOrderNo             {get; set;}  // 반품번호
        @AuraEnabled public String partOrderNo               {get; set;}  // 주문번호
        @AuraEnabled public String refundCustomerOrderNo     {get; set;}  // 고객주문번호
        @AuraEnabled public List<RefundDetail> refundList    {get; set;}  // 환불 부품 상세 정보
    }

    public class RefundDetail {
        @AuraEnabled public String customerOrderNo           {get; set;}  // customerOrderNo
        @AuraEnabled public String partOrderId               {get; set;}  // partOrderId
        @AuraEnabled public String machineName               {get; set;}  // machineName
        @AuraEnabled public String equipmentNo               {get; set;}  // equipmentNo
        @AuraEnabled public String purchaseOrder             {get; set;}  // purchaseOrder
        @AuraEnabled public String poiId                     {get; set;}  // poiId
        @AuraEnabled public String urgency                   {get; set;}  // urgency
        
        @AuraEnabled public String invoice              {get; set;}  // invoice
        @AuraEnabled public String itemNo               {get; set;}  // itemNo
        @AuraEnabled public String orderPartNo          {get; set;}  // orderPartNo
        @AuraEnabled public String note                 {get; set;}  // note
        @AuraEnabled public String orderQty             {get; set;}  // quantity
        @AuraEnabled public String unit                 {get; set;}  // unit
        @AuraEnabled public Decimal unitPrice           {get; set;}  // 단가
        @AuraEnabled public String netValue             {get; set;}  // netValue
        @AuraEnabled public String complaintReason1     {get; set;}  // complaintReason1
        @AuraEnabled public String complaintReason2     {get; set;}  // complaintReason2
        @AuraEnabled public String description          {get; set;}  // description
        @AuraEnabled public String attachFile           {get; set;}  // attachFile
        @AuraEnabled public Date originDocDate          {get; set;}  // originDocDate
        @AuraEnabled public Date orderDate              {get; set;}  // orderDate

        // @AuraEnabled public String filesInfo            {get; set;}  // fileIds
        // @AuraEnabled public List<String> fileIds        {get; set;}  // fileNames
        // @AuraEnabled public List<String> fileNames      {get; set;}  // fileNames

        @AuraEnabled public String itemSpr              {get; set;}  // 중복방지 key value
        @AuraEnabled public List<FileInfo> fileInfo     {get; set;}  // SAP 업로드 파일 정보
        @AuraEnabled public List<CrmFileInfo> crmFileInfo {get; set;}  // CRM 업로드 파일 정보
    }

    public class FileInfo {
        @AuraEnabled public String INT_NO       {get; set;}  // INT_NO
        @AuraEnabled public String DOCU_ITEM    {get; set;}  // DOCU_ITEM
        @AuraEnabled public String FILE_ID      {get; set;}  // FILE_ID
        @AuraEnabled public String FILE_DOC_ID  {get; set;}  // FILE_DOC_ID
        @AuraEnabled public String FILE_NAME    {get; set;}  // FILE_NAME
        @AuraEnabled public String DESCRIPTION  {get; set;}  // DESCRIPTION
        @AuraEnabled public String FILE_NO      {get; set;}  // FILE_NO
        @AuraEnabled public String FILE_DATA    {get; set;}  // FILE_DATA
    }

    public class CrmFileInfo {
        @AuraEnabled public String Id          {get; set;}  // Id
        @AuraEnabled public String ContentSize {get; set;}  // file size
        @AuraEnabled public String Title       {get; set;}  // title
        @AuraEnabled public String verId       {get; set;}  // version Id
    }

    public class ReturnPDF {
        @AuraEnabled public String customerAccName {get; set;}  // 고객 회사 명
        @AuraEnabled public String customerAccCEO  {get; set;}  // 고객 회사 대표자 명
        @AuraEnabled public String customerCode    {get; set;}  // Customer Code
        @AuraEnabled public String returnOrderNo   {get; set;}  // 문서 번호
        @AuraEnabled public String customerOrderNo {get; set;}  // 문서 번호
        @AuraEnabled public String originDocDate   {get; set;}  // 문서 일자
        @AuraEnabled public String roCurrency      {get; set;}  // 통화
        @AuraEnabled public Decimal allQuantity    {get; set;}  // items totalAmount의 총합
        @AuraEnabled public Decimal allAmount      {get; set;}  // items allAmount 총합
        @AuraEnabled public String  amount         {get; set;}  // items allAmount 총합
        @AuraEnabled public List<RoiList> roiList  {get; set;}  // 리턴 아이템 리스트

        public ReturnPDF (PurchaseOrder__c pco, DN_PortalLoginUser.DealerInfo dli) {
            this.customerAccName = dli.accountName;         // 고객 회사 명
            this.customerAccCEO  = dli.accountCEO;          // 고객 회사 대표자 명
            this.customerCode    = dli.dealerCode;          // Customer Code
            this.returnOrderNo   = pco.PartOrderNo__c;      // 문서 번호
            this.customerOrderNo = pco.CustomerOrderNo__c;  // 고객 주문 번호
            this.originDocDate   = String.valueOf(pco.CreatedDate).split(' ')[0].replace('-','.');    // 문서 일자
            this.roCurrency      = pco.CurrencyIsoCode;     // 통화
            this.allQuantity     = 0;                       // 초기화
            this.allAmount       = 0;                       // 초기화

            this.roiList         = new List<RoiList>();     // 리턴 아이템 리스트
            Integer sequence = 10;
            for (PurchaseOrderItems__c roi : pco.PurchaseOrderItems__r) {
                RoiList roiListItem = new RoiList(roi);
                roiListItem.sequenceNumber = sequence;
                this.roiList.add(roiListItem);
                sequence += 10;

                // totalAmount 누적 합산
                this.allAmount += roiListItem.totalAmount;
                this.allQuantity += roiListItem.returnQuantity;
            }

            this.amount          = this.allAmount.format();
        }
        public ReturnPDF () {}
    }

    public class RoiList {
        @AuraEnabled public Integer sequenceNumber {get; set;}  // 번호
        @AuraEnabled public String orderPartNo     {get; set;}  // 주문품번
        @AuraEnabled public String partName        {get; set;}  // 품명
        @AuraEnabled public String cpReasonOne     {get; set;}  // 불만 1
        @AuraEnabled public String cpReasonTwo     {get; set;}  // 불만 2
        @AuraEnabled public String cpNote          {get; set;}  // 노트
        @AuraEnabled public String invoiceNo       {get; set;}  // 참조문서번호
        @AuraEnabled public String salesDate       {get; set;}  // 고객 판매일
        @AuraEnabled public String returnStatus    {get; set;}  // 수락 코드
        @AuraEnabled public Decimal returnQuantity {get; set;}  // 반품 수량
        @AuraEnabled public String unit            {get; set;}  // 단위
        @AuraEnabled public String unitPrice       {get; set;}  // 단가
        @AuraEnabled public Decimal totalAmount    {get; set;}  // 금액
        @AuraEnabled public String totalA          {get; set;}  // 금액

        public RoiList(PurchaseOrderItems__c  roi) {
            this.sequenceNumber = 0;                        // 번호
            this.orderPartNo    = roi.OrderPartNo__c;       // 주문품번
            this.partName       = roi.PartName__c;          // 품명
            this.cpReasonOne    = roi.ComplaintReason1__c == 'A' ? '이종품' : roi.ComplaintReason1__c == 'B' ? '불량품' : roi.ComplaintReason1__c == 'C' ? '수량차이' : roi.ComplaintReason1__c == 'D' ? '[대리점귀책]청구착오' : roi.ComplaintReason1__c == 'E' ? '판매금액오류' : roi.ComplaintReason1__c == 'M' ? '본사요청' : '기타';  // 불만 1
            this.cpReasonTwo    = roi.ComplaintReason2__c == 'A01' ? '좌우바뀜' : roi.ComplaintReason2__c == 'A02' ? '규격불량' : roi.ComplaintReason2__c == 'A03' ? '성능미달' : roi.ComplaintReason2__c == 'A04' ? '내·외경 불량' : roi.ComplaintReason2__c == 'A05' ? '도금불량' : roi.ComplaintReason2__c == 'A06' ? '도장불량' : roi.ComplaintReason2__c == 'A07' ? '균열(틈)' : roi.ComplaintReason2__c == 'A08' ? '오조립' : roi.ComplaintReason2__c == 'A09' ? '불출착오' : roi.ComplaintReason2__c == 'A10' ? '파츠북 오류' : roi.ComplaintReason2__c == 'B01' ? '파손·파멸' : roi.ComplaintReason2__c == 'B02' ? '용접불량' : roi.ComplaintReason2__c == 'B03' ? '흠,찍힘' : roi.ComplaintReason2__c == 'B04' ? '찌그러짐' : roi.ComplaintReason2__c == 'B05' ? '휨, 변형' : roi.ComplaintReason2__c == 'B06' ? '작동불량' : roi.ComplaintReason2__c == 'B07' ? '누수' : roi.ComplaintReason2__c == 'B08' ? '누유' : roi.ComplaintReason2__c == 'B09' ? '누기' : roi.ComplaintReason2__c == 'B10' ? '충전불량' : roi.ComplaintReason2__c == 'B11' ? '방진불량' : roi.ComplaintReason2__c == 'B12' ? '배선불량' : roi.ComplaintReason2__c == 'B13' ? '압력불량' : roi.ComplaintReason2__c == 'B14' ? '이음,소음,잡음' : roi.ComplaintReason2__c == 'B15' ? '내열불량' : roi.ComplaintReason2__c == 'B16' ? '변색' : roi.ComplaintReason2__c == 'B17' ? '소착' : roi.ComplaintReason2__c == 'B18' ? '절단면불량/면취불량' : roi.ComplaintReason2__c == 'B19' ? '단선/소손' : roi.ComplaintReason2__c == 'C01' ? '수량차이' : roi.ComplaintReason2__c == 'D01' ? '[대리점귀책]청구착오' : roi.ComplaintReason2__c == 'E01' ? '판매금액오류' : roi.ComplaintReason2__c == 'E02' ? '운송비 오류' : roi.ComplaintReason2__c == 'M01' ? '대리점 본사 지원' : '기타';  // 불만 2
            this.cpNote         = roi.Note__c;              // 노트
            this.invoiceNo      = roi.Invoice__c;           // 참조문서번호
            this.salesDate      = String.valueOf(roi.OriginDocDate__c);     // 고객판매일
            // this.returnStatus   = roi.;                     // 수락코드
            this.returnQuantity = roi.Quantity__c;  // 반품 수량
            this.unit           = roi.Unit__c;      // 단위
            this.unitPrice      = roi.UnitPrice__c.format(); // 단가
            this.totalAmount    = roi.Quantity__c * roi.UnitPrice__c;  // 금액
            this.totalA         = (roi.Quantity__c * roi.UnitPrice__c).format();  // 금액
        }

        public RoiList() {}
    }
}