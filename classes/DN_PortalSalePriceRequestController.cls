/**
 * @description       : (포탈) 판매가 > 판매가 조정 요청
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-17-2025
 * @last modified by  : deokjun.kim@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-27-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalSalePriceRequestController {
    public DN_PortalSalePriceRequestController() {}

    // 로그인한 사용자 정보
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        String userId = System.UserInfo.getUserId();
        return DN_PortalLoginUser.GetUserInfo(userId);
    }

    // 업로드하는 파일 사이즈 확인
    @AuraEnabled
    public static List<ContentDocument> CheckFileSize(List<String> fId){
            return [SELECT Id, ContentSize, Title FROM ContentDocument WHERE Id IN :fId];
    }    

    // html 로 파일 전환하기
    @AuraEnabled
    public static List<Id> ConvertFile (List<String> versionIds) {
        try {
            system.debug('test versionIds >> '+ versionIds);
            IF_FilePackingService service = new IF_FilePackingService(); 
            List<Id> packedFileConversionIds =  service.packingToListByHTML(versionIds);
    
            system.debug('test packedFileConversionIds >> '+ packedFileConversionIds);
            return packedFileConversionIds;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // base64 로 파일 쪼개기
    @AuraEnabled
    public static List<Map<String, Object>> SplitFile (List<String> urlId){
        try {
            system.debug('test split>>>> ' + urlId);
            List<Map<String, Object>> fileTable = new List<Map<String, Object>>();
    
            // ContentVersion 데이터를 한번에 쿼리
            Map<String, List<ContentVersion>> contentMap = new Map<String, List<ContentVersion>>();

            List<ContentVersion> cvList = [
                SELECT Id, ContentDocumentId, Title, VersionNumber, ContentSize, FileExtension, VersionData, OriginVersionId__c
                FROM ContentVersion
                WHERE Id IN :urlId
            ];

            system.debug('test split>>>> ' + cvList);
            Set<Id> oriCVIds = new Set<Id>();
            for (ContentVersion cv : cvList) {
                if (!contentMap.containsKey(cv.Id)) {
                    contentMap.put(cv.Id, new List<ContentVersion>());
                }
                contentMap.get(cv.Id).add(cv);
                oriCVIds.add(cv.OriginVersionId__c);
            }

            Map<String, String> cdbMaps = new Map<String, String>();
            for (ContentDistribution cdb : [SELECT ContentVersionId, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId IN :oriCVIds]) {
                cdbMaps.put(cdb.ContentVersionId, cdb.DistributionPublicUrl);
            }

            for (String id : urlId) {
                if (contentMap.containsKey(id)) {
                    for (ContentVersion cv : contentMap.get(id)) {
                        Blob fileData = cv.VersionData;
                        Integer startPos = 0;
                        
                        Integer filePartIndex = 1;
    
                        // Base64 변환은 한 번만 수행
                        String base64Data = EncodingUtil.base64Encode(fileData);
                        Integer fileLength = base64Data.length();

                        system.debug('base64Data >> ' +base64Data);
                        system.debug('fileLength >> ' +fileLength);

                        while (startPos < fileLength) {
                            Integer BUFFER_SIZE = 7902;
                            // 청크로 나눠서 처리
                            String buffer = base64Data.substring(
                                startPos,
                                Math.min(startPos + BUFFER_SIZE, base64Data.length())
                            );
                            
                            system.debug('buffer >> ' +buffer);

                            Map<String, Object> fileMap = new Map<String, Object>();
                            fileMap.put('INT_NO', String.valueOf(urlId.indexOf(id) + 1));
                            fileMap.put('DOCU_ITEM', '0000' + String.valueOf(filePartIndex) + '0');
                            fileMap.put('FILE_ID', cv.Id);
                            fileMap.put('FILE_DOC_ID', cv.ContentDocumentId);
                            // fileMap.put('FILE_NAME', cv.Title + '.' + cv.FileExtension);
                            
                            // 2025.03.27 판매가조정요청 첨부파일 개선
                            // 파일명에 링크 전달
                            String FILENAME = cdbMaps.containsKey(cv.OriginVersionId__c) ? cdbMaps.get(cv.OriginVersionId__c) : cv.Title;
                            // String FILENAME = cdbMaps.containsKey(cv.OriginVersionId__c) ? cdbMaps.get(cv.OriginVersionId__c) : EncodingUtil.urlEncode(cv.Title, 'UTF-8');
                            fileMap.put('FILE_NAME', FILENAME);
                            // fileMap.put('FILE_NAME', cv.Title);
                            // fileMap.put('DESCRIPTION', 'https://dn-solutions--dev.sandbox.file.force.com');
                            fileMap.put('DESCRIPTION', 'https://dn-solutions.file.force.com');
                            fileMap.put('FILE_NO', String.valueOf(filePartIndex));
                
                            buffer = EncodingUtil.urlEncode(buffer, 'UTF-8');
                            fileMap.put('FILE_DATA', buffer);
                            fileTable.add(fileMap);
                            startPos += BUFFER_SIZE;
                            filePartIndex++;
                        }
    
                        // 메모리 해제
                        fileData = null;
                    }
                }
            }
            return fileTable;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //업로드한 파일 삭제
    @AuraEnabled
    public static String DeleteFile(List<String> fileId) {
        try {
            List<ContentDocument> df = [
                SELECT Id FROM ContentDocument WHERE Id =: fileId
            ];
            delete df;

            return '삭제 완료';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // CRM 에 등록된 부품인지 조회
    @AuraEnabled
    public static String SearchPartCode(String ptn){
        String pdt = '';
        List<Product2> pd2 = [
            SELECT Id, ProductCode
            FROM Product2
            WHERE ProductCode = :ptn
            AND FM_MaterialDetails__c != null
        ];
        if(pd2.size() > 0) {
            return pd2[0].ProductCode;    
        }else {
            return pdt;
        }
    }

    // 시스템 가격 찾기(실행 버튼)
    @AuraEnabled
    public static List<PartsList> GetPriceInfo(DN_PortalLoginUser.DealerInfo dli, List<PartsList> pon){
        try {
            IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req req = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req();
    
            req.I_USERINFO              = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_I_USERINFO();
            req.I_USERINFO.KUNNR        = dli.dealerCode;
            req.I_USERINFO.VKORG        = dli.salesOrganization;
            req.I_USERINFO.VTWEG        = dli.distributionChannel;
            req.I_USERINFO.SPART        = dli.division;
        
            List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_IT_MAT> IT_MAT = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_IT_MAT>();

            for(PartsList poi : pon) {
                IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_IT_MAT mat = new IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Req_IT_MAT();
                mat.PEITEM               = poi.itemNo;
                mat.MATNR                = poi.partNo;

                IT_MAT.add(mat);
            }

            req.IT_MAT = IT_MAT;

            IF_ERP_PE_Inquery instance = new IF_ERP_PE_Inquery();
            IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res result = instance.IF_PARTS_030(req);

            List<PartsList> psl = new List<PartsList>();
            List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SAP> sap = (List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SAP>) result.ET_SAP;
            // List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SIMUL> simul = (List<IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SIMUL>) result.ET_SIMUL;
            for(IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SAP sim : sap) {
                PartsList psr = new PartsList(sim);
                psl.add(psr);
            }

            return psl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+'_____'+e.getStackTraceString());
        }
    }

    public class PartsList {
        @AuraEnabled public String itemNo      {get; set;} // 항목
        @AuraEnabled public String partNo      {get; set;} // 품번
        @AuraEnabled public String partName    {get; set;} // 품명
        @AuraEnabled public String curr        {get; set;} // 통화
        @AuraEnabled public String systemPrice {get; set;} // 시스템 가격
        @AuraEnabled public String sugestPrice {get; set;} // 제안 가격
        @AuraEnabled public String request     {get; set;} // 요청사항

        public PartsList(IF_ERP_PE_Inquery_Classes.IF_PARTS_030_Res_ET_SAP sim) {
            this.itemNo      = sim.PEITEM; // 항목
            this.partNo      = sim.MATNR;  // 품번
            this.partName    = sim.MAKTX;  // 품명
            this.curr        = sim.WAERS;  // 통화
            this.systemPrice = String.valueOf(Decimal.valueOf(sim.SPRICE) * 100); // 시스템 가격
        }
        
        public PartsList() {}
    }

    // 판매가 요청(완료 버튼)
    @AuraEnabled
    public static String CreatePriceRequest(DN_PortalLoginUser.DealerInfo dli, Params params, List<String> poeFile, List<Upload> upload){
        try {
            String pen = InterFace_Parts_031(dli, params, upload);
            if (pen == null || !pen.startsWith('5')) {
                return 'FAIL';
            } else {
                PriceEscalation__c pea = new PriceEscalation__c();
                pea.PEINo__c          = pen;                   // sap 부여 값
                pea.IPONo__c          = params.inquiryPONo;    // inquiryNo
                pea.Dealer__c         = dli.dealerName;        // 딜러 이름
                pea.Requester__c      = params.requester;      // 요청자
                pea.RequesterEmail__c = params.requesterEmail; // 이메일
                pea.EquipmentName__c  = params.equipmentName;  // 장비명
                pea.EquipmentNo__c    = params.equipmentNo;    // 장비 호기
                insert pea;

                if (poeFile.size() > 0) {
                    List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                    for (String cdId : poeFile) {
                        ContentDocumentLink link = new ContentDocumentLink();
                        link.ContentDocumentId = cdId;
                        link.LinkedEntityId    = pea.Id;
                        link.ShareType         = 'I';
                        link.Visibility        = 'AllUsers';
                        links.add(link);
                    }
                    insert links;
                }   
                return pen;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Params{
        @AuraEnabled public String inquiryPONo    {get; set;}
        @AuraEnabled public String requester      {get; set;}
        @AuraEnabled public String requesterEmail {get; set;}
        @AuraEnabled public String equipmentName  {get; set;}
        @AuraEnabled public String equipmentNo    {get; set;}
        @AuraEnabled public String today          {get; set;}

        @AuraEnabled public List<PartsList> partsList   {get; set;}

        public Params() {}
    }

    public class Upload{
        @AuraEnabled public String INT_NO      {get; set;} //  파일 순서
        @AuraEnabled public String DOCU_ITEM   {get; set;} //  항목(필요 없음)
        @AuraEnabled public String FILE_ID     {get; set;} //  version ID
        @AuraEnabled public String FILE_NAME   {get; set;} // 파일 이름
        @AuraEnabled public String DESCRIPTION {get; set;} // url
        @AuraEnabled public String FILE_NO     {get; set;} // 파일 넘버(쪼갠 개수??)
        @AuraEnabled public String FILE_DATA   {get; set;} // base64

        public Upload() {}
    }

/* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */

    // 부품 정보 조회 I/F
    private static String InterFace_Parts_031 (DN_PortalLoginUser.DealerInfo dli, Params params, List<Upload> upload) {
        IF_ERP_PE_Inquery execute = new IF_ERP_PE_Inquery();
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req req = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req();
        
        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IS_HD IS_HD = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IS_HD();
        IS_HD.KUNNR  = dli.dealerCode.leftpad(10, '0'); // 딜러코드 10자리
        IS_HD.NAME1  = dli.dealerName;        // 딜러 이름
        IS_HD.INQUIRY = params.inquiryPONo;   // inquiryNo
        IS_HD.PERSON = params.requester;      // 요청자
        IS_HD.EMAIL  = params.requesterEmail; // 이메일
        IS_HD.DOCDT  = params.today;          // 생성일
        IS_HD.SERNR  = params.equipmentNo;    // 장비번호
        IS_HD.TYPBZ  = params.equipmentName;  // 기종
        
        req.IS_HD      = IS_HD;

        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_I_USERINFO USERINFO = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_I_USERINFO();
        USERINFO.BNAME = dli.dealerId;
        USERINFO.RNAME = dli.erpKey;
        USERINFO.KUNNR = dli.dealerCode.leftpad(10, '0');
        USERINFO.VKORG = dli.salesOrganization;   // 1846
        USERINFO.VTWEG = dli.distributionChannel; // 10
        USERINFO.SPART = dli.division;            // 40
        
        req.IS_USERINFO = USERINFO;
        
        List<IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ITEM> IT_ITEM = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ITEM>();
        
        for(PartsList psr : params.partsList) {
            IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ITEM item = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ITEM();
            item.PEITEM = psr.itemNo;      // 항목
            item.MATNR  = psr.partNo;      // 품번
            item.MAKTX  = psr.partName;    // 품명
            item.WAERS  = psr.curr;        // 통화
            item.SPRICE = psr.systemPrice; // 시스템 가격
            item.MPRICE = psr.sugestPrice; // 제안 가격
            item.COMMNT = psr.request;     // 요청사항
            IT_ITEM.add(item);
        }
        
        req.IT_ITEM   = IT_ITEM;

        List<IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH> IT_ATTACH = new List<IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH>();

        for(Upload upl : upload) {
            IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH attach = new IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Req_IT_ATTACH();
            attach.FILE_NO   = upl.INT_NO; // 파일의 순서
            attach.FILE_SEQ  = upl.FILE_NO; //파일 내 분할 순서
            attach.FILE_NAME = upl.FILE_NAME; // 파일 이름
            // 2025.03.27 판매가조정요청 첨부파일 개선
            // CLUSTR, CLUST 공란으로 값 전달
            attach.CLUSTD    = '';
            attach.CLUSTR    = '';
            // attach.CLUSTD    = upl.FILE_DATA; // 변환한 내용
            // attach.CLUSTR    = String.valueOf(upl.FILE_DATA.length()); // 고정 값??
            system.debug('length >> ' +String.valueOf(upl.FILE_DATA.length()));
            // attach.CLUSTR    = '7902'; // 고정 값??

            // attach.CLUSTD    = upl.DESCRIPTION +'/'+upl.FILE_ID; // 변환한 내용
            // attach.FILE_NAME = 'https://dn-solutions--dev.sandbox.file.force.com' + verFile[0];

            IT_ATTACH.add(attach);
        }
        req.IT_ATTACH = IT_ATTACH;

        IF_ERP_PE_Inquery_Classes.IF_PARTS_031_Res result = execute.IF_PARTS_031(req);
        String pen = result.E_PENUM;
        return pen;
    }
}