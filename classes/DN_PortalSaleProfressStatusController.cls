/**
 * @description       : 판매가 조회
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-05-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public withOut sharing class DN_PortalSaleProfressStatusController {
    public DN_PortalSaleProfressStatusController() {}

    // 사용자 정보
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        String userId = System.UserInfo.getUserId();
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
        return dealerInfo;
    }

    
    // 판매가 조회
    @AuraEnabled
    public static Map<String, Object> GetStatusList(DN_PortalLoginUser.DealerInfo dli, Params param){
        try {
            system.debug('param >>> '+param);
            String status = param.status;
            String poNo   = param.poNo;
            String peNo   = param.peNo;

            IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req req = new IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req();
            req.I_DOCDT_FR = param.startDate;
            req.I_DOCDT_TO = param.endDate;
            req.I_PAGENO   = param.pageNo; // 값을 안 주면 전체 데이터 불러옴.
            req.I_ROWNO    = '20';
            req.I_STAT     = status;
        
            req.I_USERINFO              = new IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Req_I_USERINFO();
            req.I_USERINFO.KUNNR        = dli.dealerCode.leftPad(10, '0'); // 어떤 경우는 7자리만 넣어도 되지만 이번에는 000을 붙여서 10자리 들어가야 함.
            req.I_USERINFO.VKORG        = dli.salesOrganization;
            req.I_USERINFO.VTWEG        = dli.distributionChannel;
            req.I_USERINFO.SPART        = dli.division;
            req.I_USERINFO.LAND1        = dli.country;

            IF_ERP_PE_Inquery instance = new IF_ERP_PE_Inquery();
            instance.interfaceUtil.isInsertLog = false;
            IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res result = instance.IF_PARTS_029(req);
            system.debug('029 >>' + result);

            Map<String, Object> result029 = new Map<String, Object>();
            String line = result.O_LINES;

            result029.put('line', line);

            List<IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_T_LIST> T_LIST = (List<IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_T_LIST>) result.T_LIST;

            List<StatusResult> resultList = new List<StatusResult>();
            for(IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_T_LIST tl : T_LIST) {
                StatusResult resultRecord = new StatusResult(tl);
                resultList.add(resultRecord);
            }

            result029.put('list', resultList);
            return result029;
        } catch (Exception e) {
            System.debug('판매가 조회 추적 >>> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'.________.'+e.getStackTraceString());
        }
    }

    public class Params {
        @AuraEnabled public String startDate {get; set;} // 시작 일자
        @AuraEnabled public String endDate   {get; set;} // 종료 일자
        @AuraEnabled public String poNo      {get; set;} // po No
        @AuraEnabled public String peNo      {get; set;} // pe No
        @AuraEnabled public String status    {get; set;} // status
        @AuraEnabled public String pageNo    {get; set;} // page No

        public Params() {}
    }

    public class StatusResult {
        @AuraEnabled public String status        {get; set;} // 상태(아이콘)
        @AuraEnabled public String workStatus    {get; set;} // 작업상태
        @AuraEnabled public String remark        {get; set;} // remark
        @AuraEnabled public String rejectReason  {get; set;} // 거절 사유
        @AuraEnabled public String poNo          {get; set;} // PO No
        @AuraEnabled public String peNo          {get; set;} // PE No
        @AuraEnabled public String creationDate  {get; set;} // 생성일
        @AuraEnabled public String equipmentName {get; set;} // 장비명
        @AuraEnabled public String equipmentNo   {get; set;} // 장비호기

        public StatusResult(IF_ERP_PE_Inquery_Classes.IF_PARTS_029_Res_T_LIST tl) {
            this.status        = tl.STAT;     // 상태(아이콘) Q = 확인 /  A = 검토중 / R = 거절
            // this.workStatus    = tl.STAT_TXT == 'In Progress' ? '확인중' : tl.STAT_TXT == 'Accepted' ? '검토중' : '거절'; // 작업상태
            this.workStatus    = tl.STAT == 'Q' ? '확인중' : tl.STAT == 'A' ? '승인' : '거절'; // 작업상태
            this.remark        = tl.REMARK;   // remark
            this.rejectReason  = tl.RJ_REASON; // 거절 사유
            this.poNo          = tl.INQUIRY; // PO No
            this.peNo          = tl.PENUM;   // PE No
            this.creationDate  = tl.DOCDT;   // 생성일
            this.equipmentName = tl.TYPBZ;   // 장비명
            this.equipmentNo   = tl.SERNR;   // 장비호기    
        }

        public StatusResult() {}
    }

    // 상세조회(첨부파일 제외)
    @AuraEnabled
        public static StatusDetail GetStatusDetail(DN_PortalLoginUser.DealerInfo dli, String pen){
        try {
            IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req request = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req();
            request.I_PENUM    = pen;
 
            IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req_I_USERINFO I_USERINFO = new IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Req_I_USERINFO();
            I_USERINFO.KUNNR = dli.dealerCode.leftPad(10, '0');
            I_USERINFO.VKORG = dli.salesOrganization;
            I_USERINFO.VTWEG = dli.distributionChannel;
            I_USERINFO.SPART = dli.division;
            
            request.I_USERINFO =  I_USERINFO;

            IF_ERP_PE_Inquery execute = new IF_ERP_PE_Inquery();
            // PDF 페이지 호출을 위해 인터페이스 로그 적재 막았습니다.
            // 포탈 - 부품 - 판매가 - 상세조회 프린트 입니다.
            execute.interfaceUtil.isInsertLog = false;
            IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res result = execute.IF_PARTS_032(request);
            
            StatusDetail sdl = new StatusDetail(result);
            system.debug('sdl >>> ' + sdl);
            return sdl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class StatusDetail {
        @AuraEnabled public String peNo           {get; set;} // PE Inquiry No
        @AuraEnabled public String poNo           {get; set;} // Inquiry PO No
        @AuraEnabled public String partDealer     {get; set;} // 부품대리점
        @AuraEnabled public String requester      {get; set;} // 요청인
        @AuraEnabled public String requesterEmail {get; set;} // 요청인 이메일
        @AuraEnabled public String equipmentName  {get; set;} // 장비명
        @AuraEnabled public String equipmentNo    {get; set;} // 장비호기
        @AuraEnabled public String creationDate   {get; set;} // 생성일
        @AuraEnabled public String status         {get; set;} // 상태
        @AuraEnabled public String remark         {get; set;} // remark
        @AuraEnabled public String rjReason       {get; set;} // 거절 이유
        @AuraEnabled public String returnStatus   {get; set;} // 반환 성공 여부

        @AuraEnabled public List<AttachFile> attachFile {get; set;} // 첨부파일 리스트
        @AuraEnabled public List<StatusRecord> statusRecord {get; set;} // 리스트

        public StatusDetail(IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res res) {
            this.peNo           = res.ES_HD.PENUM;     // PE Inquiry No
            this.poNo           = res.ES_HD.INQUIRY;   // Inquiry PO No
            this.partDealer     = res.ES_HD.NAME1;     // 부품대리점
            this.requester      = res.ES_HD.PERSON;    // 요청인
            this.requesterEmail = res.ES_HD.EMAIL;     // 요청인 이메일
            this.equipmentName  = res.ES_HD.TYPBZ;     // 장비명
            this.equipmentNo    = res.ES_HD.SERNR;     // 장비호기
            this.creationDate   = res.ES_HD.DOCDT;     // 생성일
            this.status         = res.ES_HD.STAT == 'Q' ? '확인중' : res.ES_HD.STAT == 'A' ? '승인' : '거절';      // 상태
            this.remark         = res.ES_HD.REMARK;    // remark
            this.rjReason       = res.ES_HD.RJ_REASON; // 거절 사유
            this.returnStatus   = res.ES_RETURN.TYPE;  // 성공 여부

            this.attachFile = new List<AttachFile>();
            for(IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ATTACH file : res.ET_ATTACH) {
                AttachFile afs = new AttachFile(file);
                this.attachFile.add(afs);
            }

            this.statusRecord = new List<StatusRecord>();  // 가격 제안 리스트
            for(IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ITEM item : res.ET_ITEM) {
                StatusRecord srd = new StatusRecord(item);
                this.statusRecord.add(srd);
            }
        }
        public StatusDetail() {}
    }

    public class AttachFile {
        @AuraEnabled public String fileName {get; set;} // Name
        @AuraEnabled public String fileNo   {get; set;} // Nubmer

        public AttachFile(IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ATTACH file) {
            this.fileName = file.FILE_NAME.split('\\.')[0];
            this.fileNo   = file.FILE_NO;
        }
    }

    public class StatusRecord {
        @AuraEnabled public String itemNo       {get; set;} // No
        @AuraEnabled public String partNo       {get; set;} // 품번
        @AuraEnabled public String partName     {get; set;} // 품명
        @AuraEnabled public String curr         {get; set;} // 통화
        @AuraEnabled public String systemPrice  {get; set;} // 시스템 가격
        @AuraEnabled public String suggestPrice {get; set;} // 제안 가격
        @AuraEnabled public String newPrice     {get; set;} // 신규 가격
        @AuraEnabled public String request      {get; set;} // 요청 사항

        public StatusRecord(IF_ERP_PE_Inquery_Classes.IF_PARTS_032_Res_ET_ITEM item) {
            this.itemNo       = item.PEITEM; // No
            this.partNo       = item.MATNR; // 품번
            this.partName     = item.MAKTX; // 품명
            this.curr         = item.WAERS; // 통화
            this.systemPrice  = item.SPRICE; // 시스템 가격
            this.suggestPrice = item.MPRICE; // 제안 가격
            this.newPrice     = item.NPRICE; // 신규 가격
            this.request      = item.COMMNT; // 요청 사항
    
        }
        public StatusRecord() {}
    }

    // 첨부파일 조회
    @AuraEnabled
    public static List<PriceEscalation__c> GetCrmFile(DN_PortalLoginUser.DealerInfo dli, String pen){

            return [
                SELECT Id, OwnerId, PEINo__c, (SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks)
                FROM PriceEscalation__c
                WHERE PEINo__c =:pen
                AND OwnerId =: dli.dealerId
            ];

    }
}