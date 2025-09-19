/**
 * @description       : (포탈) 부품 주문 > 반품 생성 & 조회
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-17-2025
 * @last modified by  : deokjun.kim@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-02-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalPartsReturnController {
    public DN_PortalPartsReturnController() {}


    // 로그인 유저 정보
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        String userId = System.UserInfo.getUserId();
        return DN_PortalLoginUser.GetUserInfo(userId);
    }

    // 반품 생성 - 컴플레인1,2 픽리스트 가져오기.
    @AuraEnabled
    public static Map<String, Object> GetPicklistInfo() {
        try {            
            // 결과를 저장할 Map
            Map<String, Object> picklists = new Map<String, Object>();
    
            // 첫 번째 Picklist
            Schema.DescribeFieldResult ot1 = PurchaseOrderItems__c.ComplaintReason1__c.getDescribe();
            List<Schema.PicklistEntry> otpl1 = ot1.getPicklistValues();
            List<Map<String, String>> cpReasonPicklist1 = new List<Map<String, String>>();
    
            for (Schema.PicklistEntry entry : otpl1) {
                Map<String, String> picklistMap = new Map<String, String>();
                picklistMap.put('label', entry.getLabel());
                picklistMap.put('value', entry.getValue());
                cpReasonPicklist1.add(picklistMap);
            }
            picklists.put('cpReasonPicklist1', cpReasonPicklist1);
    
            // 두 번째 Picklist
            Schema.DescribeFieldResult ot2 = PurchaseOrderItems__c.ComplaintReason2__c.getDescribe();
            List<Schema.PicklistEntry> otpl2 = ot2.getPicklistValues();
            List<Map<String, String>> cpReasonPicklist2 = new List<Map<String, String>>();
    
            for (Schema.PicklistEntry entry : otpl2) {
                Map<String, String> picklistMap = new Map<String, String>();
                picklistMap.put('label', entry.getLabel());
                picklistMap.put('value', entry.getValue());
                cpReasonPicklist2.add(picklistMap);
            }
            picklists.put('cpReasonPicklist2', cpReasonPicklist2);
    
            return picklists;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    // 반품 대상 찾기 - 조회
    @AuraEnabled
    public static List<FindReturnItems> GetReturnOrder(DN_PortalLoginUser.DealerInfo dli, String son, String sop){
        try {
            List<FindReturnItems> result = InterFace_parts_017(dli, son, sop);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    // 생성한 반품인지 확인 - 중복확인
    @AuraEnabled
    public static List<PurchaseOrderItems__c> GetReturnOrderItems(DN_PortalLoginUser.DealerInfo dli){
            return [ SELECT ItemSpr__c
                    FROM PurchaseOrderItems__c 
                    WHERE ItemSpr__c != null
                    AND CreatedById =: dli.dealerId
                ];
    }

    // 반품 생성 - 업로드한 파일 용량 확인
    @AuraEnabled
    public static List<ContentDocument> checkFileSize(List<String> fId){
        return [ SELECT Id, ContentSize, Title FROM ContentDocument WHERE Id IN :fId ];            
    }

    // 업로드한 파일 삭제
    @AuraEnabled
    public static String DeleteFiles(List<String> fileId, String idType) {
        try {
            system.debug('fileId >> ' + fileId);
            system.debug('idType >> ' + idType);

            List<String> dId = new List<String>();
            List<ContentVersion> cvId = new List<ContentVersion>();

            if(fileId.size() == 0) {
                return '삭제할 파일 없음';
            } 

            dId = fileId;
            system.debug('dId>>>'+dId);
            List<ContentDocument> df = [
                SELECT Id, Title FROM ContentDocument WHERE Id =: dId
            ];
            String name = df[0].Title;
            delete df;

            string result = name + ' is deleted';
            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  


    // html 로 파일 전환하기
    @AuraEnabled
    public static List<Id> ConvertFile (List<String> docIds) {
        try {
            List<ContentVersion> versions = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: docIds];
            List<Id> versionIds = new List<Id>();

            for(ContentVersion ver : versions) {
                Id vId = ver.Id;
                versionIds.add(vId);
            }
            IF_FilePackingService service = new IF_FilePackingService(); 
            List<Id> packedFileConversionIds =  service.packingToListByHTML(versionIds);
    
            return packedFileConversionIds;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // html 파일 분할하기
    @AuraEnabled
    public static List<Map<String, Object>> SplitFile (List<String> urlId){
        try {
            List<Map<String, Object>> fileTable = new List<Map<String, Object>>();
    
            // ContentVersion 데이터를 한번에 쿼리
            Map<String, List<ContentVersion>> contentMap = new Map<String, List<ContentVersion>>();

            List<ContentVersion> cvList = [
                SELECT Id, ContentDocumentId, Title, VersionNumber, ContentSize, FileExtension, VersionData
                FROM ContentVersion
                WHERE Id IN :urlId
            ];

            for (ContentVersion cv : cvList) {
                if (!contentMap.containsKey(cv.Id)) {
                    contentMap.put(cv.Id, new List<ContentVersion>());
                }
                contentMap.get(cv.Id).add(cv);
            }            

            system.debug('VV contentMap >> '+contentMap);

            for (String id : urlId) {
                system.debug('id >> '+id);
                system.debug('contentMap.containsKey(id) >> '+contentMap.containsKey(id));

                if (contentMap.containsKey(id)) {
                    for (ContentVersion cv : contentMap.get(id)) {
                        system.debug('cv.VersionData >>>>>>>> ' +cv.VersionData);
                        Blob fileData = cv.VersionData;
                        Integer startPos = 0;
                        
                        Integer filePartIndex = 1;
    
                        // Base64 변환은 한 번만 수행
                        String base64Data = EncodingUtil.base64Encode(fileData);
                        Integer fileLength = base64Data.length();

                        system.debug('base64Data >> ' +base64Data);
                        system.debug('fileLength >> ' +fileLength);

                        while (startPos < fileLength) {
                            Integer BUFFER_SIZE = 1024;
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

                            // fileMap.put('FILE_NAME', cv.Title);
                            fileMap.put('FILE_NAME', EncodingUtil.urlEncode(cv.Title, 'UTF-8'));

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

    // 반품생성 - 저장
    @AuraEnabled
    public static String saveRefundOrder(DN_PortalPartWrapper.RefundOrderInfo ri){
        try {
            system.debug('반품 생성 받은 값 : ' +ri);
            String recordTypeName = 'Return Order';
            Id recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
            
            String pon = InterFace_Parts_018(ri);

            if(pon == null) {
                return '생성 실패';
            } else {
                purchaseOrder__c refundRecord = new purchaseOrder__c();
            
                // 미입력 자동 생성
                refundRecord.PartOrderNo__c           = pon;                        // 주문번호
                refundRecord.recordTypeId             = recordTypeId;               // 레코드 타입
                refundRecord.OriginDocDate__c         = ri.refundList[0].orderDate; // 레코드 타입
                refundRecord.Buyer__c                 = ri.dealerInfo.accountId != '' ? ri.dealerInfo.accountId : null;    // buyer__c
                
                // 고객 주문 번호
                refundRecord.CustomerOrderNo__c       = ri.refundCustomerOrderNo; // 고객주문번호

                insert refundRecord;
    
                List<PurchaseOrderItems__c> poiRecords = new List<PurchaseOrderItems__c>();
                List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
                
                Integer j = 0;
                if (ri.refundList != null && !ri.refundList.isEmpty()) {
                    for (DN_PortalPartWrapper.RefundDetail part : ri.refundList) {
                        PurchaseOrderItems__c poiRecord = new PurchaseOrderItems__c();
                        j++;
                        // MD 관계
                        poiRecord.PurchaseOrder__c   = refundRecord.Id; 
    
                        // 받아온 값
                        poiRecord.Invoice__c         = part.invoice;                    // invoice
                        poiRecord.ItemNo__c          = part.itemNo;                     // 항목
                        poiRecord.OrderNo__c          = '0000'+String.valueOf(j*10);    // 순서
                        poiRecord.OrderPartNo__c     = part.orderPartNo;                // (주문)품번
                        poiRecord.Note__c            = part.note;                       // 설명
                        poiRecord.Quantity__c        = Integer.valueOf(part.orderQty);  // (주문)수량
                        poiRecord.Unit__c            = part.unit;                       // 단위
                        poiRecord.UnitPrice__c       = part.unitPrice;                  // 단가
                        poiRecord.NetValue__c        = part.netValue;                   // Net Value
                        // poiRecord.FileId__c          = part.filesInfo == null ? '' : part.filesInfo;  // 파일 ID List
    
                        // 사용자가 입력한 값
                        poiRecord.ComplaintReason1__c     = part.complaintReason1;      // 반품 사유 1
                        poiRecord.ComplaintReason2__c     = part.complaintReason2;      // 반품 사유 2
                        poiRecord.Description__c          = part.description;           // 반품 설명
                        poiRecord.OriginDocDate__c        = part.orderDate;             // 문서 작업 날짜 
                        
                        // 중복 방지 키 값
                        poiRecord.ItemSpr__c              = part.itemSpr;              // 중복 방지용 key value
    
                        // 리스트에 추가
                        poiRecords.add(poiRecord);
                    }
    
                    if (!poiRecords.isEmpty()) {
                        insert poiRecords;
                    }

                    for (Integer i = 0; i < poiRecords.size(); i++) {
                        PurchaseOrderItems__c insertedPoi = poiRecords[i];
                        DN_PortalPartWrapper.RefundDetail part = ri.refundList[i];
                        if (part.crmFileInfo != null && !part.crmFileInfo.isEmpty()) {
                            for (DN_PortalPartWrapper.CrmFileInfo info : part.crmFileInfo) {
                                ContentDocumentLink docLink = new ContentDocumentLink();
                                docLink.LinkedEntityId = insertedPoi.Id;
                                docLink.ContentDocumentId = info.Id;
                                docLink.ShareType = 'V';
                                docLink.Visibility = 'AllUsers';
                                documentLinks.add(docLink);
                            }
                        }
                    }
                
                    if (!documentLinks.isEmpty()) {
                        insert documentLinks;
                    }                  
                }
            return pon;
            }

        } catch (Exception e) {
            system.debug('에러 : ' +e.getMessage());
            system.debug('위치 : ' +e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 반품 조회 - 조회
    @AuraEnabled
    public static List<PurchaseOrderItems__c> GetReturnOrderInfo(DN_PortalPartWrapper.ReturnOrderTerms rft){
        try {
            String recordTypeName = 'Return Order';
            Id recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();

            String userId        = rft.dealerInfo.dealerId;
            String userProfile   = rft.dealerInfo.userProfile;
            
            String ron   = rft != null && rft.returnOrderNo != null ? rft.returnOrderNo.trim() : '';
            String rfn   = rft != null && rft.referenceNo != null   ? rft.referenceNo.trim() : '';
            String opn   = rft != null && rft.orderPartNo != null   ? rft.orderPartNo.trim() : '';

            Date sDate = Date.valueOf(rft.startDate);
            Date eDate = Date.valueOf(rft.endDate).addDays(1);

            String poiQuery = 'SELECT PurchaseOrder__c, PurchaseOrder__r.PartOrderNo__c, PurchaseOrder__r.CustomerOrderNo__c, PurchaseOrder__r.FM_OrderDate__c, PurchaseOrder__r.CreatedDate, FileId__c, '
                            + 'Id, ItemNo__c, OrderNo__c, Invoice__c, OrderPartNo__c, SupplyPartNo__c,  Description__c, Quantity__c, Unit__c, UnitPrice__c, CurrencyIsoCode, NetValue__c, Note__c, OriginDocDate__c, ReturnStatus__c, toLabel(ComplaintReason1__c), toLabel(ComplaintReason2__c), '
                            + 'HQOrderNo__c, Status__c, '
                            + '(SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) '
                            + 'FROM PurchaseOrderItems__c '
                            + 'WHERE PurchaseOrder__r.RecordTypeId = :recordTypeId '
                            + 'AND IsGRCancel__c = false '
                            + 'AND PurchaseOrder__r.CreatedDate >= : sDate '
                            + 'AND PurchaseOrder__r.CreatedDate <= : eDate ';


            if (userProfile != 'System Administrator' && userProfile != '시스템 관리자') {
                poiQuery += 'AND PurchaseOrder__r.OwnerId = :userId ';
            }

            // (반품)주문번호 입력시 검색 조건
            if (ron != null && ron != '') {
                poiQuery += 'AND PurchaseOrder__r.PartOrderNo__c =: ron ';
            }

            // Reference 번호 입력시 검색 조건
            if (rfn != null && rfn != '') {
                poiQuery += 'AND Invoice__c =: rfn ';
            }

            // 주문 부품 번호 입력시 검색 조건
            if (opn != null && opn != '') {
                poiQuery += 'AND OrderPartNo__c =:opn ';
            }
            
            List<PurchaseOrderItems__c> poiInfo  = Database.query(poiQuery);
            return poiInfo;
                
        } catch (Exception e) {
            system.debug('에러 : ' +e.getMessage());
            system.debug('어디 : ' +e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    // 반품 조회 -  삭제
    @AuraEnabled
    public static IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res DeleteReturnOrderItems(DN_PortalLoginUser.DealerInfo dli, List<String> dol){
        try {
            system.debug('dli : '+dli);
            system.debug('dol : '+dol);
            IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res result = InterFace_Parts_028(dli, dol);
            
            if (dol == null || dol.isEmpty()) {
                throw new AuraHandledException('No PartOrderNo__c values provided.');
            }

            List<PurchaseOrder__c> recordsToDelete = [
                SELECT Id
                FROM PurchaseOrder__c
                WHERE PartOrderNo__c IN :dol
            ];

            if (!recordsToDelete.isEmpty()) {
                delete recordsToDelete;
                System.debug('Deleted ' + recordsToDelete.size() + ' records.');
            } else {
                System.debug('No matching records found for deletion.');
            }

            return result;
        } catch (Exception e) {
            system.debug('환불 삭제 에러 : ' +e.getMessage());
            system.debug('환불 삭제 라인 : ' +e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* ************************************************************************************************************************************************************************************************ */    
    /* ************************************************************************************************************************************************************************************************ */
    /* ************************************************************************************************************************************************************************************************ */

    // 반품 대상 찾기 모달
    private static List<FindReturnItems> InterFace_Parts_017(DN_PortalLoginUser.DealerInfo dli, String son, String sop) {
        IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req req = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req();
        req.I_VKORG = dli.salesOrganization;
    
        IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req_I_USERINFO();

        I_USERINFO.KUNNR        = dli.dealerCode;
        I_USERINFO.VKORG        = dli.salesOrganization;
        I_USERINFO.VTWEG        = dli.distributionChannel;
        I_USERINFO.SPART        = dli.division;
        I_USERINFO.LAND1        = dli.country;
        I_USERINFO.DF_CHK       = 'X';
    
        req.I_USERINFO          = I_USERINFO;
    
        IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req_LS_SEARCH LS_SEARCH = new IF_ERP_Parts_Return_Classes.IF_PARTS_017_Req_LS_SEARCH();
        LS_SEARCH.VBELN = son;
        LS_SEARCH.MATNR = sop;
        req.LS_SEARCH       = LS_SEARCH;
    
        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res result = instance.IF_PARTS_017(req);
        List<IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res_LT_SEARCH2> list017 = (List<IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res_LT_SEARCH2>) result.LT_SEARCH2;

        List<FindReturnItems> friList = new List<FindReturnItems>();
        for(IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res_LT_SEARCH2 rcd : list017) {
            FindReturnItems fri = new FindReturnItems(rcd);
            friList.add(fri);
        }
        return friList;
    }

    public class FindReturnItems {
        @AuraEnabled Public String itemNo          {get; set;} // 항목
        @AuraEnabled Public String customerOrderNo {get; set;} // 고객주문번호
        @AuraEnabled Public String invoice         {get; set;} // Invoice
        @AuraEnabled Public String orderPartNo     {get; set;} // 주문품번
        @AuraEnabled Public String description     {get; set;} // 설명(품명)
        @AuraEnabled Public Decimal orderQty       {get; set;} // 주문수량
        @AuraEnabled Public String unit            {get; set;} // 단위
        @AuraEnabled Public Decimal unitPrice      {get; set;} // 단가
        @AuraEnabled Public String friCurrency     {get; set;} // 통화

        // 본문에서 사용
        @AuraEnabled Public String netValue        {get; set;} // net Value
        @AuraEnabled Public String orderDate       {get; set;} // 주문날짜

        public FindReturnItems(IF_ERP_Parts_Return_Classes.IF_PARTS_017_Res_LT_SEARCH2 rcd) {
            itemNo          = rcd.POSNR; // 항목
            customerOrderNo = rcd.BSTKD; // 고객주문번호
            invoice         = rcd.VBELN; // invocie
            orderPartNo     = rcd.MATNR; // 주문번호 >> MATWA 일수도 있음. 주문품번과 공급풉번이 뭔지 모름.
            description     = rcd.MAKTX; // 설명(품명) >> 이거 품명인데 왜 두비즈에선 갑자기 설명으로 바꿤.
            orderQty        = Decimal.valueOf(rcd.FKIMG); // 주문 수량
            unit            = rcd.VRKME; // 단위
            unitPrice       = Decimal.valueOf(rcd.NETPR); // 단가 >> 이건 또 이상하게 소수점을 그대로 사용함... 왜지?
            friCurrency     = rcd.WAERS; // 통화
            
            // 본문에서 사용
            netValue        = rcd.NETWR; // net Value
            orderDate       = rcd.BUDAT; // 주문날짜 >> 혹은 ERDAT. 이거 검색 조건에선 시작 혹은 끝 기간인데 이걸 하나로 해서 생성날짜로 쓰는 듯.
        }
    }

    // 반품 생성 - 저장
    private static String InterFace_Parts_018(DN_PortalPartWrapper.RefundOrderInfo ri){

        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req req = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req();
        req.I_REF_ORDER         = ri.refundList[0].invoice; // invoice
        req.I_COMPLAIN          = 'X'; // ??
        
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_I_USERINFO();

        I_USERINFO.KUNNR        = ri.dealerInfo.dealerCode.LeftPad(10, '0'); // 딜러코드
        I_USERINFO.VKORG        = ri.dealerInfo.salesOrganization;           // 판매조직
        I_USERINFO.VTWEG        = ri.dealerInfo.distributionChannel;         // 채널
        I_USERINFO.SPART        = ri.dealerInfo.division;                    // 부서
        I_USERINFO.LAND1        = ri.dealerInfo.country;                     // 나라
        I_USERINFO.HIER         = 'A';  // ??
        I_USERINFO.DF_CHK       = 'X';  // ??

        req.I_USERINFO          = I_USERINFO;
        
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_I_HEAD I_HEAD = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_I_HEAD();
        I_HEAD.BSTKD            = ri.refundCustomerOrderNo; // 고객 주문번호 (입력값)

        I_HEAD.REF_DOC          = ri.refundList[0].invoice; // invoice 값
        I_HEAD.REFDOC_CAT       = 'M'; // ????
        
        req.I_HEAD              = I_HEAD;
        
        // 레코드
        List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_ITEM> T_ITEM_List = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_ITEM>();

        // 메모
        List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_NOTES> T_NOTES_List = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_NOTES>();

        // 파일 첨부
        List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE> T_FILE_List = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE>();

        Integer initCounter = 10;

        for(DN_PortalPartWrapper.RefundDetail item : ri.refundList) {
            // 레코드
            IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_ITEM T_ITEM = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_ITEM();
            T_ITEM.POSNR               = String.valueOf(initCounter).Leftpad(6, '0');  // 신규 항목
            T_ITEM.MATNR               = item.orderPartNo;       // 공급품번
            T_ITEM.KWMENG              = item.orderQty;          // 반품 수량
            T_ITEM.REF_DOC             = item.invoice;           // invoice
            T_ITEM.REF_DOC_IT          = item.itemNo;            // 공급시 할당받은 항목
            T_ITEM.REF_DOC_CA          = 'M';                    // ??
            T_ITEM.ZZDEALDT            = String.valueOf(item.orderDate);    // 아마도 생성일
            T_ITEM.ZZCMPCD             = item.complaintReason1;  // 불평 1
            T_ITEM.ZZREASON            = item.complaintReason2;  // 불평 2
        
            T_ITEM_List.add(T_ITEM);

            // 내용
            IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_NOTES T_NOTE = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_NOTES();
            T_NOTE.POSNR              = String.valueOf(initCounter).Leftpad(6, '0'); //
            T_NOTE.TDID               = 'Y002';
            T_NOTE.LINE               = item.note;

            T_NOTES_List.add(T_NOTE);
            
            // 파일업로드
            if(item.fileInfo != null) {
                for(DN_PortalPartWrapper.FileInfo file : item.fileInfo) {
                    IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE T_FILE = new IF_ERP_Parts_Return_Classes.IF_PARTS_018_Req_T_FILE();
                    T_FILE.INT_NO        = file.INT_NO;
                    // T_FILE.DOCU_ITEM     = String.valueOf(initCounter).Leftpad(6, '0');  // 신규 항목
                    T_FILE.DOCU_ITEM     = file.DOCU_ITEM;
                    T_FILE.FILE_NAME     = file.FILE_NAME;
                    T_FILE.DESCRIPTION   = file.DESCRIPTION;
                    T_FILE.FILE_DATA     = file.FILE_DATA;
                    T_FILE.FILE_NO       = file.FILE_NO;
    
                    T_FILE_List.add(T_FILE);
                }
            }

            initCounter += 10;
        }

        req.T_ITEM                  = T_ITEM_List;
        req.T_NOTES                 = T_NOTES_List;
        req.T_FILE                  = T_FILE_List;
        
        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        IF_ERP_Parts_Return_Classes.IF_PARTS_018_Res result = instance.IF_PARTS_018(req);
        String ron = result.O_VBELN;
        return ron;
    }
    
    // 반품 대상 삭제
    private static IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res InterFace_Parts_028(DN_PortalLoginUser.DealerInfo dli, List<String> dol) {
        IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req req = new IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req();
        req.I_VKORG         = dli.salesOrganization;
     
        List<IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req_T_LIST> T_LIST_List = new List<IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req_T_LIST>();
        for(String dor : dol) {
            IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req_T_LIST T_LIST = new IF_ERP_Parts_Return_Classes.IF_PARTS_028_Req_T_LIST();
            T_LIST.VBELN = dor;
            T_LIST_List.add(T_LIST);
        }
        
        req.T_LIST = T_LIST_List;
     
        IF_ERP_Parts_Return instance = new IF_ERP_Parts_Return();
        IF_ERP_Parts_Return_Classes.IF_PARTS_028_Res result = instance.IF_PARTS_028(req);

        return result;
    }
}