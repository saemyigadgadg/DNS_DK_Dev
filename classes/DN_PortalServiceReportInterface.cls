/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 05-26-2025
 * @last modified by  : Chungwoo Lee
**/
public without sharing class DN_PortalServiceReportInterface {
    
    /**
     * @description 현재 User getter/setter 
     */
    public static User currentUser {
        get {
            if (currentUser == null) {
                currentUser = [SELECT 
                                Id, UserCode__c, Division__c, SalesOrganization__c, DistributionChannel__c, ERP_Key__c, EmployeeNumber, 
                                // Portal_EmployeeNumber__c,
                                Account.CustomerCode__c, Country__c
                                FROM User WHERE Id = :userInfo.getUserID() LIMIT 1];
            }
            return currentUser;
        }
        set;
    }

    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-015
         * SFDC interface Id    : IF_CSPLUS_015
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_MT_SUB_ENGINEER_SAVE              
         * Description          : 확정 시 공동 작업자 생성
     */ 
    public Map<String, Object> interfaceCall015(Id recordId, Boolean isConfirmed) {
        Map<String, Object> resMap = new Map<String, Object>();

        List<Collaborator__c> collaboratorList = getCollaborator(recordId);

        IF_ERP_WorkOrder method = new IF_ERP_WorkOrder();
        method.interfaceUtil.isInsertLog = false;

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req request = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req();
        List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req_T_I_LIST> t_i_list = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req_T_I_LIST>();

        if (!collaboratorList.isEmpty()) {
            for (Collaborator__c collabo : collaboratorList) {
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req_T_I_LIST item = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Req_T_I_LIST();
                item.PERNR = collabo.ServiceResource__r.StaffNumber__c !=null ? collabo.ServiceResource__r.StaffNumber__c : '';
                t_i_list.add(item);
            }
            request.I_AUFNR  = collaboratorList[0].WorkOrder__r.ServiceOrderNumber__c !=null ? collaboratorList[0].WorkOrder__r.ServiceOrderNumber__c : '';
            request.T_I_LIST = t_i_list;  
            IF_ERP_WorkOrder_Classes.IF_CSPLUS_015_Res resParam015 = method.IF_CSPLUS_015(request);
            resMap.put('res015', resParam015);
        } else {
            resMap.put('res015', '해당 서비스 오더에 공동작업자가 존재 하지 않습니다.');
        }
        
        return resMap;
    }

    /**
     * Wrapper Name         : IF_SERVICE_054
     * SFDC interface Id    : IF-SERVICE-054
     * New I/F              : ZCRM_CS_SEARCH_CLAIM_RECEIPT
     * Description          : 서비스리포트 조회
     */ 
    public IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res interfaceCall054(Id recordId, String orderType) {
        Map<String, Object> resMap = new Map<String, Object>();
        
        WorkOrder workOrder = getWorkOrderData(recordId);

        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req reqParam = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req();
        IF_ERP_Service_Report method = new IF_ERP_Service_Report();
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_ORDER temp_I_ORDER = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_ORDER();
        temp_I_ORDER.AUFNR  = '000' + workOrder.ServiceOrderNumber__c;

        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_USERINFO temp_I_USERINFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req_I_USERINFO();
        temp_I_USERINFO.BNAME       = currentUser?.Id == null ? '' : currentUser.Id;
        temp_I_USERINFO.RNAME       = currentUser?.ERP_Key__c == null ? '' : String.valueOf(currentUser.ERP_Key__c);
        temp_I_USERINFO.HIER        = '';
        temp_I_USERINFO.KUNNR       = currentUser?.Account?.CustomerCode__c == null ? '' : currentUser.Account.CustomerCode__c;
        temp_I_USERINFO.VKORG       = currentUser?.SalesOrganization__c == null ? '' : currentUser.SalesOrganization__c;
        temp_I_USERINFO.VTWEG       = currentUser?.DistributionChannel__c == null ? '' : currentUser.DistributionChannel__c;
        temp_I_USERINFO.SPART       = currentUser?.Division__c == null ? '' : currentUser.Division__c;
        temp_I_USERINFO.ARBPL       = workOrder?.ServiceTerritory?.WCCode__c == null ? '' : workOrder.ServiceTerritory.WCCode__c;
        temp_I_USERINFO.WERKS       = workOrder?.ServiceTerritory?.PlanningPlant__c == null ? '' : workOrder.ServiceTerritory.PlanningPlant__c;
        
        reqParam.I_ORDER            = temp_I_ORDER;
        reqParam.I_USERINFO         = temp_I_USERINFO;

        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res resParam = method.IF_SERVICE_054(reqParam);

        List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

        List<Id> contentDocumentIdList = new List<Id>();
        for (ContentDocumentLink link : contentLinks) {
            contentDocumentIdList.add(link.ContentDocumentId);
        }

        // if (resParam.O_RETURN.TYPE == 'S') {

            if ((resParam.O_STATUS == 'REL' || resParam.O_STATUS == 'PCNF') && workOrder.Status == 'Confirm') {
                workOrder.Status = 'Completed';
                workOrder.ConfirmedDate__c = null;
                update workOrder;
            }

            if ((orderType == 'RT04' || orderType == 'RT05') && workOrder.Status != 'Confirm') {
                List<ProductRequest> productRequestsToUpdate = new List<ProductRequest>(); 

                // 부품사용내역 업데이트
                Map<String, ProductRequest> mappingProductRequests = new Map<String, ProductRequest>();
                for (ProductRequest pr : getProductRequests(recordId)) {
                    mappingProductRequests.put(pr.Seq__c, pr); 
                }

                for (IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_MATERIAL material : resParam.T_MATERIAL) {
                    ProductRequest pr;
                    
                    // 기존 레코드가 있으면 업데이트
                    if (mappingProductRequests.containsKey(material.ITEM_NUMBER)) { 
                        pr = mappingProductRequests.get(material.ITEM_NUMBER);
                    } else {
                        continue;
                    }

                    pr.Seq__c                   = String.isBlank(material.ITEM_NUMBER) ? '' : material.ITEM_NUMBER;
                    pr.PGMNG__c                 = !String.isBlank(material.PGMNG) ? Decimal.valueOf(material.PGMNG) : 0;
                    pr.IsCause__c               = material.CAUSE_PRT == 'X';
                    // 대리점재고관리에서 불출수량 및 발송여부 업데이트
                    if(material.SUPPLY_TYPE != '대리점') {
                        System.debug('여기 오는지 확인 : ' + material.GR);
                        pr.MENGE_GI__c              = !String.isBlank(material.MENGE_GI) ? Decimal.valueOf(material.MENGE_GI) : 0;
                        pr.ShippingCheck__c         = material.GR != null ? material.GR : '';
                    }
                    if (String.isNotBlank(material.RETURN_YN)) {
                        pr.ReturnStatus__c          = material.RETURN_YN;
                    }   
                    pr.SupplyType__c            = String.isBlank(material.SUPPLY_TYPE) ? '' : material.SUPPLY_TYPE;
                    pr.SAPPartsPrice__c         = String.isBlank(material.NETWR) ? 0 : Decimal.valueOf(material.NETWR);
                    pr.SAPItemCategory__c       = String.isBlank(material.ITEM_CAT) ? '' : material.ITEM_CAT;

                    productRequestsToUpdate.add(pr);
                    
                }   
                // 업데이트 실행
                if (!productRequestsToUpdate.isEmpty()) {
                    update productRequestsToUpdate;
                }
            }

            if (orderType == 'RT04' || orderType == 'RT05') {

                System.debug('contentDocumentIdList ::: ' + JSON.serialize(contentDocumentIdList));
                System.debug('resParam ::: ' + JSON.serialize(resParam));

                // 서비스 리포트 
                if (resParam.T_DOC_SR != null && !resParam.T_DOC_SR.isEmpty()) {
                    Map<String, String> fileNameToDocNoMap = new Map<String, String>();
                
                    for (IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_SR doc : resParam.T_DOC_SR) {
                        fileNameToDocNoMap.put(doc.FILENAME, doc.DOCNO);
                    }
                
                    List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion>();

                    List<ContentVersion> contentVersionList = [SELECT Id, Title, FileExtension, DealerPotalFileType__c, ERPDocNo__c, IsDealerPotalERP__c
                                                FROM ContentVersion 
                                                WHERE DealerPotalFileType__c = 'report' AND ContentDocumentId IN :contentDocumentIdList];

                                                System.debug('fileNameToDocNoMap by SR ::: ' + JSON.serialize(fileNameToDocNoMap));  
                                                System.debug('contentVersionList by SR ::: ' + JSON.serialize(contentVersionList));        
                
                    for (ContentVersion contentVersion : contentVersionList) {
                        System.debug('test SR Check ::: ' + JSON.serialize(contentVersion));     

                        if (fileNameToDocNoMap.containsKey(contentVersion.Title + '.htm') && contentVersion.ERPDocNo__c == null ) {
                            contentVersion.ERPDocNo__c  = fileNameToDocNoMap.get(contentVersion.Title  + '.htm');
                            contentVersion.IsDealerPotalERP__c = true;
                            contentVersionsToUpdate.add(contentVersion);
                        }
                    }
                    
                    if (!contentVersionsToUpdate.isEmpty()) {
                        System.debug('contentVersionsToUpdate by SR ::: ' + JSON.serialize(contentVersionsToUpdate));
                        update contentVersionsToUpdate;
                    }
                }

                if (resParam.T_DOC_INFO != null && !resParam.T_DOC_INFO.isEmpty()) {
                    Map<String, String> fileNameToDocNoMap = new Map<String, String>();
                
                    for (IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res_T_DOC_INFO doc : resParam.T_DOC_INFO) {
                        fileNameToDocNoMap.put(doc.FILENAME, doc.DOCNO);
                    }
                
                    List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion>();

                    List<ContentVersion> contentVersionList = [SELECT Id, Title, FileExtension, DealerPotalFileType__c, ERPDocNo__c, IsDealerPotalERP__c
                                                FROM ContentVersion 
                                                WHERE DealerPotalFileType__c != 'report' AND ContentDocumentId IN :contentDocumentIdList];

                                                System.debug('contentVersionList ::: ' + JSON.serialize(contentVersionList));                         
                
                    for (ContentVersion contentVersion : contentVersionList) {
                        System.debug('test ETC Check ::: ' + JSON.serialize(contentVersion));       
                        if (
                            fileNameToDocNoMap.containsKey(contentVersion.Title + '.htm') && 
                            contentVersion.ERPDocNo__c == null && 
                            contentVersion.IsDealerPotalERP__c == false
                            ) 
                        {
                            contentVersion.ERPDocNo__c  = fileNameToDocNoMap.get(contentVersion.Title + '.htm');
                            contentVersion.IsDealerPotalERP__c = true;
                            contentVersionsToUpdate.add(contentVersion);
                        }
                    }
                    
                    if (!contentVersionsToUpdate.isEmpty()) {
                        System.debug('contentVersionsToUpdate ::: ' + JSON.serialize(contentVersionsToUpdate));
                        update contentVersionsToUpdate;
                    }
                }
            }        
        return resParam;
    }

    /**
         * Apex Class           : IF_ERP_DeliveryTraining
         * Wrapper Class        : IF_ERP_DeliveryTraining_Classes
         * Wrapper Name         : IF_PARTS_025
         * SFDC interface Id    : IF_PARTS_025
         * AS-IS RFC            : Z_CS_WEB_PERIODIC_INSP_SAVE_ME
         * New I/F              : ZCRM_CS_WEB_PERIODIC_INSP_SAVE => ZCRM_CS_WORKWORDER_MANAGE               
         * Description          : 납품 후 교육 / 직영 서비스 결과 입력 저장/확정
     */  
    public IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res interfaceCall025(Id recordId, Boolean isConfirmed, List<Map<String, String>> docMapList, List<String> convertVersionIdList) {

        WorkOrder wObj = getWorkOrderData(recordId);
        Map<String, Object> workOrderResults = getWorkOrderResults(recordId);

        List<WorkOrderResult__c> workHistory = (List<WorkOrderResult__c>) workOrderResults.get('WH');
        WorkOrderResult__c wor = (WorkOrderResult__c) workOrderResults.get('COM');
        if (wor == null) {
            wor = new WorkOrderResult__c();
        }
        String rtNo = wObj.FM_WorkOrderResult_Template__c;
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req reqParam = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req();
        
        reqParam.I_COUNSEL = wor.ActionDetail__c;

        if (rtNo == 'RT07') {
            reqParam.I_IPOINT  = wObj.InspectionScore__c != null ? String.valueOf(wObj.InspectionScore__c) : '';
        }   
        if (isConfirmed) {
            reqParam.I_CONF = 'X'; // Confirm = 'X' 
        } else {
            reqParam.I_CONF = ''; // Save = ''
        }

        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_I_USERINFO i_USERINFO = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_I_USERINFO();
            i_USERINFO.BNAME    =   currentUser?.Id == null ? '' : currentUser.Id;
            i_USERINFO.RNAME    =   currentUser?.ERP_Key__c == null ? '' : String.valueOf(currentUser.ERP_Key__c);
            i_USERINFO.KUNNR    =   currentUser?.Account?.CustomerCode__c == null ? '' : currentUser.Account.CustomerCode__c;
            i_USERINFO.VKORG    =   currentUser?.SalesOrganization__c == null ? '' : currentUser.SalesOrganization__c;
            i_USERINFO.VTWEG    =   currentUser?.DistributionChannel__c == null ? '' : currentUser.DistributionChannel__c;
            i_USERINFO.SPART    =   currentUser?.Division__c == null ? '' : currentUser.Division__c;
            i_USERINFO.WERKS    =   wObj?.ServiceTerritory?.PlanningPlant__c == null ? '' : wObj.ServiceTerritory.PlanningPlant__c;
            i_USERINFO.ARBPL    =   wObj?.ServiceTerritory?.WCCode__c == null ? '' : wObj.ServiceTerritory.WCCode__c;
        
        reqParam.I_USERINFO = i_USERINFO;
        
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_I_SEL reqParam_isel = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_I_SEL();

            reqParam_isel.AUFNR = wObj.ServiceOrderNumber__c != null ? '000' + wObj.ServiceOrderNumber__c : '';
            reqParam_isel.CUST_NM = wObj?.Case?.Account?.Name == null ? '' : wObj.Case.Account.Name;
            reqParam_isel.EQUNR = wObj?.Asset?.Name == null ? '' : wObj.Asset.Name; 
            reqParam_isel.INSPECTION_TP = wObj.OrderType__c == null ? '' : wObj.OrderType__c;
            if (wObj.Asset != null && wObj.Asset.SerialNumber != null && wObj.Asset.SerialNumber.contains('0000000000')) {
                reqParam_isel.SERNR = String.valueOf(Integer.valueOf(wObj.Asset.SerialNumber));
            } else {
                reqParam_isel.SERNR = (wObj.Asset != null && wObj.Asset.SerialNumber != null) ? wObj.Asset.SerialNumber : '';
            }
            
            reqParam_isel.TYPBZ = wObj.Asset.MachineName__c == null ? '' : wObj.Asset.MachineName__c;
            reqParam_isel.DEALER = wObj?.ServiceTerritory?.WCCode__c == null ? '' : wObj.ServiceTerritory.WCCode__c;
            reqParam_isel.DEALER_NM = wObj?.ServiceTerritory?.Name == null ? '': wObj.ServiceTerritory.Name;

        reqParam.I_SEL = reqParam_isel;

        /**
        * T_MOTION : list  
        */
        List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_MOTION> temp_t_motion_list = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_MOTION>();
        for (WorkOrderResult__c work : workHistory) {
            /**
            * T_MOTION
            */
            IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_MOTION temp_t_motion = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_MOTION();
            temp_t_motion.AUFNR = wObj.ServiceOrderNumber__c != null ? wObj.ServiceOrderNumber__c : '';
            temp_t_motion.PERNR = work.ServiceResource__r.StaffNumber__c != null ? work.ServiceResource__r.StaffNumber__c : '';
            temp_t_motion.SVCMAN_NAME = work.ServiceResource__r != null && work.ServiceResource__r.Name != null ? (work.ServiceResource__r.AD_ID__c != null ? work.ServiceResource__r.AD_ID__c + ' ' + work.ServiceResource__r.Name : work.ServiceResource__r.Name) : '';
            temp_t_motion.ISDD = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
            temp_t_motion.ISDZ = work.WorkStartTime__c != null ? String.valueOf(work.WorkStartTime__c).subString(0,8) : '';
            temp_t_motion.AUSBS = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
            temp_t_motion.AUZTB = work.WorkEndTime__c != null ? String.valueOf(work.WorkEndTime__c).subString(0,8) : '';
            temp_t_motion.ISMNW = work.WorkTime__c != null ? String.valueOf(work.WorkTime__c) : '';
            temp_t_motion.WORKCD = work.WorkType__c != null ? String.valueOf(work.WorkType__c) : '';
            temp_t_motion.LTXA1 = work.Description__c != null ? String.valueOf(work.Description__c) : '';
            temp_t_motion.HOL_CHK = work.IsHoliday__c == true ? 'X' : '';

            temp_t_motion_list.add(temp_t_motion);
        }
        reqParam.T_MOTION = temp_t_motion_list;

        List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP> temp_t_tmp_list = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP>();

        // 2025.03.28 추가 : 저장이 아닌 확정을 하는 경우에만 파일 관련 데이터 전송
        if (isConfirmed && !convertVersionIdList.isEmpty()) {
            /**
            * T_TMP List : 파일 리스트
            */
            List<Map<String, Object>> fileMapList = getConvertFile(convertVersionIdList, 'IF_PARTS_025',  wObj.ServiceOrderNumber__c);

            for (Map<String, Object> fileMap : fileMapList) {
                IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP t_Tmp = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP();
                    t_Tmp.FILENAME = (String) fileMap.get('FILENAME');
                    t_Tmp.IF_DESC  = (String) fileMap.get('IF_DESC');
                    t_Tmp.EVISEQX  = (String) fileMap.get('EVISEQX');
                    t_Tmp.FILE_SIZE = (String) fileMap.get('FILESIZE');
                    t_Tmp.LINE     = (String) fileMap.get('FILE_DATA');
                    
                    temp_t_tmp_list.add(t_Tmp);
            }

            List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL> t_DEL_list = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL>();
            if (!docMapList.isEmpty()) {
                for (Map<String, String> docMap : docMapList) {
                    IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL t_DEL = new IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_DEL();
                    t_DEL.DOCNO = docMap.get('erpDocNo');
                    t_DEL_list.add(t_DEL);
                }
            }
            reqParam.T_DEL = t_DEL_list;
        }

        reqParam.T_TMP = temp_t_tmp_list;

        /**
         * @ApiConnection
        *  */    
        IF_ERP_DeliveryTraining method = new IF_ERP_DeliveryTraining();
        method.interfaceUtil.isInsertLog = true;
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res resParam =  method.IF_PARTS_025(reqParam);
            
        return resParam;
    }

    /**
         * Apex Class           : IF_ERP_Service_InstAndComm
         * Wrapper Class        : IF_ERP_Service_InstAndComm_Classes
         * Wrapper Name         : IF-SERVICE-045
         * SFDC interface Id    : IF_SERVICE_045
         * AS-IS RFC            : Z_CS_WEB_PERIODIC_INSP_SAVE_MT
         * New I/F              : ZCRM_CS_WEB_PERIODIC_SAVE_MT
         * Description          : 설치 / 시운전 내역 생성 
     */ 
    public IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res interfaceCall045(Id recordId, Boolean isConfirmed, List<Map<String, String>> docMapList, List<String> convertVersionIdList) {

        WorkOrder workOrder = getWorkOrderData(recordId);
        Map<String, Object> workOrderResults = getWorkOrderResults(recordId);

        List<WorkOrderResult__c> workHistory = (List<WorkOrderResult__c>) workOrderResults.get('WH');
        List<WorkOrderResult__c> defectResults = (List<WorkOrderResult__c>) workOrderResults.get('ITD');
        WorkOrderResult__c completionResult = (WorkOrderResult__c) workOrderResults.get('COM'); 

        if (completionResult == null) {
            completionResult = new WorkOrderResult__c();
        }

        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req wrapper = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req();

        /**
         * I_SEL
        */
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_SEL temp_i_sel = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_SEL();
        
            temp_i_sel.AUFNR = '000' + workOrder.ServiceOrderNumber__c;
            temp_i_sel.EQUNR = workOrder.Asset != null && workOrder.Asset.Name != null ? workOrder.Asset.Name : '';
            temp_i_sel.TYPBZ = workOrder.Asset != null && workOrder.Asset.MachineName__c != null ? workOrder.Asset.MachineName__c : '';

            if (workOrder.Asset.SerialNumber.contains('0000000000')) {
                temp_i_sel.SERNR = workOrder.Asset.SerialNumber == null ? '' : Integer.valueOf(workOrder.Asset.SerialNumber).toString();
            } else {
                temp_i_sel.SERNR = workOrder.Asset != null && workOrder.Asset.SerialNumber != null ? workOrder.Asset.SerialNumber : ''; 
            }

            temp_i_sel.INSPECTION_TP = workOrder.OrderType__c; // Order Type : 104 = 설치시운전
            temp_i_sel.DEALER = workOrder.ServiceTerritory != null && workOrder.ServiceTerritory.WCCode__c != null ? workOrder.ServiceTerritory.WCCode__c : '';
            temp_i_sel.INBDT  = workOrder.InstallTestFinish__c != null ? String.valueOf(workOrder.InstallTestFinish__c).replace('-', '') : '';
            
            temp_i_sel.NAME1 = workOrder.FieldManagerName__c != null ? workOrder.FieldManagerName__c : '';
            temp_i_sel.TELF1 = workOrder.FieldManagerMobilePhone__c != null ? workOrder.FieldManagerMobilePhone__c : '';
            temp_i_sel.WO_NAME1 = workOrder.WorkerName__c != null ? workOrder.WorkerName__c : '';
            temp_i_sel.WO_TELF1 = workOrder.WorkerMobilePhone__c != null ? workOrder.WorkerMobilePhone__c : '';
            
        /**
         * I_COS
         */
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_COS temp_i_cos = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_COS();
            temp_i_cos.AUFNR = workOrder.ServiceOrderNumber__c;
            temp_i_cos.EQUNR = workOrder.Asset != null && workOrder.Asset.Name != null ? workOrder.Asset.Name : '';
            temp_i_cos.COMPANY = workOrder.Case.Account != null && workOrder.Case.Account.Name != null ? workOrder.Case.Account.Name : '';
            temp_i_cos.SRV_NM  = workOrder.Case.Account != null && workOrder.Case.Account.Representative__c != null ? workOrder.Case.Account.Representative__c : '';
            temp_i_cos.TEL_NO  = workOrder.Case.FM_AccountPhone__c != null ? workOrder.Case.FM_AccountPhone__c : '';
            temp_i_cos.MOBILE_NO = workOrder.Case.FM_PhoneNumber__c != null ? workOrder.Case.FM_PhoneNumber__c : '';
            if (String.isNotBlank(workOrder.Case.Account.sggNm__c)) {
                temp_i_cos.ADDR2 = workOrder.Case.Account.sggNm__c;
                temp_i_cos.ADDR = workOrder.Case.Account.FM_Address__c.replace(workOrder.Case.Account.sggNm__c,'').trim();    
            } else {
                temp_i_cos.ADDR2 = workOrder.Case.Account !=null && workOrder.Case.Account.FM_Address__c != null ? workOrder.Case.Account.FM_Address__c : '';
            }

        /**
         * I_OPTM
         */
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_OPTM temp_i_optm = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_OPTM();

            temp_i_optm.MAINHR  = completionResult.MainInstallationTime__c != null ? String.valueOf(completionResult.MainInstallationTime__c) : '';
            temp_i_optm.TEMPHR  = completionResult.TemporaryInstallationTime__c != null ? String.valueOf(completionResult.TemporaryInstallationTime__c) : '';
            temp_i_optm.OPTNHR1 = completionResult.FenseAPCCover__c != null ? String.valueOf(completionResult.FenseAPCCover__c) : '';
            temp_i_optm.OPTNHR2 = completionResult.SemiSplashGuard__c != null ? String.valueOf(completionResult.SemiSplashGuard__c) : '';
            temp_i_optm.OPTNHR3 = completionResult.OverTools__c != null ? String.valueOf(completionResult.OverTools__c) : '';
            temp_i_optm.OPTNHR4 = completionResult.PMG__c != null ? String.valueOf(completionResult.PMG__c) : '';
            temp_i_optm.OPTNHR5 = completionResult.AAC__c != null ? String.valueOf(completionResult.AAC__c) : '';
        
            
            temp_i_optm.CHK_FLAG    = completionResult.IsTemporaryInstallationTime__c == true ? 'X' : '';
            temp_i_optm.OPTCHK1     = completionResult.IsFenseAPCCover__c == true ? 'X' : '';
            temp_i_optm.OPTCHK2     = completionResult.IsSemiSplashGuard__c == true ? 'X' : '';
            temp_i_optm.OPTCHK3     = completionResult.IsOverTools__c == true ? 'X' : '';
            temp_i_optm.OPTCHK4     = completionResult.IsPMG__c == true ? 'X' : '';
            temp_i_optm.OPTCHK5     = completionResult.IsAAC__c == true ? 'X' : '';
            temp_i_optm.ETC_HR      = completionResult.EtcTime__c != null ? String.valueOf(completionResult.EtcTime__c) : '';
            temp_i_optm.ETC_TXT     = completionResult.ReasonOfETC__c != null ? completionResult.ReasonOfETC__c : '';
            temp_i_optm.HDAYWDV     = completionResult.IsHoliday__c == true ? 'X' : '';
            temp_i_optm.TOTALHR     = completionResult.TotalInstallationTime__c != null ? String.valueOf(completionResult.TotalInstallationTime__c) : '';

        /**
         * I_CST_PRP
         */
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_CST_PRP temp_i_cst_prp = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_I_CST_PRP();
            temp_i_cst_prp.AUFNR    = workOrder.ServiceOrderNumber__c;
            temp_i_cst_prp.EQUNR    = workOrder.Asset.Name;
            
            if (completionResult.ReadinessStatus__c != null) {
                List<String> readinessStatus = completionResult.ReadinessStatus__c.split(';');

                if (readinessStatus.contains('ZELEC')) {
                    temp_i_cst_prp.ZELEC = 'X';
                }
                if (readinessStatus.contains('ZLUB')) {
                    temp_i_cst_prp.ZLUB     = 'X';
                }
                if (readinessStatus.contains('ZHYD')) {
                    temp_i_cst_prp.ZHYD     = 'X';
                }
                if (readinessStatus.contains('ZPNEU')) {
                    temp_i_cst_prp.ZPNEU    = 'X';
                }
                if (readinessStatus.contains('ZLAYOUT')) {
                    temp_i_cst_prp.ZLAYOUT  = 'X';
                }
                if (readinessStatus.contains('ZFOUND')) {
                    temp_i_cst_prp.ZFOUND   = 'X';
                }
            }

        /**
        * T_MOTION : list  
        */
        List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_MOTION> temp_t_motion_list = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_MOTION>();
        for (WorkOrderResult__c work : workHistory) {
            /**
            * T_MOTION
            */
            IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_MOTION temp_t_motion = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_MOTION();
            temp_t_motion.AUFNR         = workOrder.ServiceOrderNumber__c;
            temp_t_motion.PERNR         = work.ServiceResource__r.StaffNumber__c != null ?  work.ServiceResource__r.StaffNumber__c : '';
            temp_t_motion.SVCMAN_NAME   = work.ServiceResource__r != null && work.ServiceResource__r.Name != null ? (work.ServiceResource__r.AD_ID__c != null ? work.ServiceResource__r.AD_ID__c + ' ' + work.ServiceResource__r.Name : work.ServiceResource__r.Name) : '';

            temp_t_motion.ISDD          = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
            temp_t_motion.ISDZ          = work.WorkDate__c != null ? String.valueOf(work.WorkStartTime__c).subString(0,8) : '';
            temp_t_motion.AUSBS         = work.WorkDate__c != null ? String.valueOf(work.WorkEndDate__c).replace('-', '') : '';
            temp_t_motion.AUZTB         = work.WorkDate__c != null ? String.valueOf(work.WorkEndTime__c).subString(0,8) : '';

            temp_t_motion_list.add(temp_t_motion);
        }

        /**
        * T_CODE_INFO : list  
        */
        List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_CODE_INFO> temp_t_code_list = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_CODE_INFO>();
            for (Integer i = 0; i < defectResults.size(); i++) {
                WorkOrderResult__c defect = defectResults[i];     
                /**
                * T_CODE_INFO
                */
                IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_CODE_INFO temp_t_code_info = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_CODE_INFO();
                temp_t_code_info.ZSEQ  = String.valueOf(i + 1);
                temp_t_code_info.ZSEQ1 = defect.InitialDefectType__c;
                temp_t_code_info.ZISE  = defect.InitialDefectDetail__c;
                temp_t_code_info.ZISR  = defect.ActionDetail__c;
                temp_t_code_info.ZECT  = defect.Note__c;

                temp_t_code_list.add(temp_t_code_info);
            }

        List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP> temp_t_tmp_list = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP>();
        // 2025.03.28 추가 : 저장이 아닌 확정을 하는 경우에만 파일 관련 데이터 전송
        if (isConfirmed) {
            /**
            * T_TMP List : 파일 리스트
            */
            List<Map<String, Object>> fileMapList = getConvertFile(convertVersionIdList, 'IF_SERVICE_045',  workOrder.ServiceOrderNumber__c);
                System.debug('Test File Check ::: ' + JSON.serialize(fileMapList));
            for (Map<String, Object> fileMap : fileMapList) {
                IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP t_Tmp = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP();
                    t_Tmp.FILENAME = (String) fileMap.get('FILENAME');
                    t_Tmp.IF_DESC  = (String) fileMap.get('IF_DESC');
                    t_Tmp.EVISEQX  = (String) fileMap.get('EVISEQX');
                    t_Tmp.FILE_SIZE = (String) fileMap.get('FILESIZE');
                    t_Tmp.LINE     = (String) fileMap.get('FILE_DATA');
                    
                    temp_t_tmp_list.add(t_Tmp);
            }
            wrapper.T_TMP = temp_t_tmp_list;

            /**
            * T_DEL List : 삭제할 파일 리스트
            */
            List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_DEL> temp_t_tdel_list = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_DEL>();
            System.debug('Test Deleted File Check ::: ' + JSON.serialize(fileMapList));
            if (!docMapList.isEmpty()) {
                for (Map<String, String> docMap : docMapList) {
                    IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_DEL temp_t_tdel = new IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_DEL();
                    temp_t_tdel.DOCNO = docMap.get('erpDocNo');
                    temp_t_tdel_list.add(temp_t_tdel);
                }
            }
            wrapper.T_DEL = temp_t_tdel_list;
        }
        
        /**
        * Wrapper
        */
        IF_ERP_Service_InstAndComm method = new IF_ERP_Service_InstAndComm();
        
            wrapper.I_WERKS = workOrder.ServiceTerritory.PlanningPlant__c != null ? workOrder.ServiceTerritory.PlanningPlant__c : '184S';
            wrapper.I_ARBPL = workOrder.ServiceTerritory.WCCode__c;
            wrapper.I_COUNSEL = completionResult.InspectionDetail__c;
            wrapper.I_HECARE = workOrder.HECare__c == true ? 'Y' : 'N';

            if (isConfirmed) {
                wrapper.I_CONF = 'X'; // Confirm = 'X'
                method.interfaceUtil.isInsertLog = false;
            } else {
                wrapper.I_CONF = ''; // Save = SPACE    
            }

            wrapper.I_SEL = temp_i_sel;
            wrapper.I_COS = temp_i_cos;
            wrapper.I_OPTM = temp_i_optm;
            wrapper.I_CST_PRP = temp_i_cst_prp;
            wrapper.T_MOTION = temp_t_motion_list; 
            wrapper.T_CODE_INFO = temp_t_code_list; 
            
        /**
         * @ApiConnection
         */    
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res resParam = method.IF_SERVICE_045(wrapper);

            if (isConfirmed) {
                DN_AssetIFRunController.updateAssetFromERP(workOrder.Case.AssetId);
            }

        return resParam;
    }

    /**
         * Apex Class           : IF_ERP_Service_ServRepInput
         * Wrapper Class        : IF_ERP_Service_ServRepInput_Classes
         * Wrapper Name         : IF_SERVICE_046
         * SFDC interface Id    : IF-SERVICE-046
         * AS-IS RFC            : Z_CS_WEB_JOB_RESULT_CONFIRM
         * New I/F              : ZCRM_CS_WEB_JOB_RESULT_CONFIRM
         * Description          : 서비스리포트 생성 후 서비스 리포트 ERP 저장
     */ 
    public Map<String, Object> interfaceCall046(Id recordId, Boolean isConfirmed, List<Map<String, String>> docMapList, List<String> convertVersionIdList ) {
        Map<String, Object> resMap = new Map<String, Object>();

        WorkOrder workOrder = getWorkOrderData(recordId);
        Map<String, Object> workOrderResults = getWorkOrderResults(recordId);
        List<ProductRequest> productRequestList = getProductRequests(recordId);

        List<WorkOrderResult__c> workHistory = (List<WorkOrderResult__c>) workOrderResults.get('WH');
        WorkOrderResult__c completionResult = (WorkOrderResult__c) workOrderResults.get('COM'); 

        if (completionResult == null) {
            completionResult = new WorkOrderResult__c();
        }

        /**
         * PARAMETERS
         */
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req  parameters  = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req();
        
        /**
         * I_USERINFO
         */
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_USERINFO temp_i_userinfo = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_USERINFO();
            temp_i_userinfo.BNAME        = currentUser?.Id == null ? '' : currentUser.Id;
            temp_i_userinfo.RNAME        = currentUser?.ERP_Key__c == null ? '' : String.valueOf(currentUser.ERP_Key__c);
            temp_i_userinfo.KUNNR        = currentUser?.Account?.CustomerCode__c == null ? '' : currentUser.Account.CustomerCode__c;
            temp_i_userinfo.VKORG        = currentUser?.SalesOrganization__c == null ? '' : currentUser.SalesOrganization__c;
            temp_i_userinfo.VTWEG        = currentUser?.DistributionChannel__c == null ? '' : currentUser.DistributionChannel__c;
            temp_i_userinfo.SPART        = currentUser?.Division__c == null ? '' : currentUser.Division__c;
            temp_i_userinfo.WERKS        = workOrder?.ServiceTerritory?.PlanningPlant__c == null ? '' : workOrder.ServiceTerritory.PlanningPlant__c;
            temp_i_userinfo.ARBPL        = workOrder?.ServiceTerritory?.WCCode__c == null ? '' : workOrder.ServiceTerritory.WCCode__c;
    
        /**
         * I_INFO
        */
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_INFO temp_i_info = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_INFO();
            temp_i_info.AUART       = workOrder.PMActivityType__c != null ? workOrder.PMActivityType__c : '';
            temp_i_info.AUFNR       = workOrder.ServiceOrderNumber__c != null ? workOrder.ServiceOrderNumber__c : '';
            temp_i_info.CONTACT_TEL = workOrder.Case != null && workOrder.Case.FM_AccountPhone__c != null ? workOrder.Case.FM_AccountPhone__c : '';    
            temp_i_info.EQUNR       = workOrder.Asset != null && workOrder.Asset.Name != null ? workOrder.Asset.Name : '';
            temp_i_info.GSTRP       = workOrder.CreatedDate != null ? String.valueOf(workOrder.CreatedDate.format('yyyyMMdd')) : '';
            temp_i_info.ILART       = workOrder.OrderType__c != null ? workOrder.OrderType__c : '';
            temp_i_info.INBDT       = workOrder.Asset != null && workOrder.Asset.InstallationFinish__c != null ? String.valueOf(workOrder.Asset.InstallationFinish__c).replace('-', '') : '';
            temp_i_info.LTRMN       = workOrder.ActionCallDate__c != null ? String.valueOf(workOrder.ActionCallDate__c).replace('-', '') : '';
            temp_i_info.MOBILE      = workOrder.Case != null && workOrder.Case.FM_PhoneNumber__c != null ? String.valueOf(workOrder.Case.FM_PhoneNumber__c) : '';
            temp_i_info.NAME        = workOrder.Case.Account != null ? workOrder.Case.Account.Name : '';
            temp_i_info.QMDAT       = workOrder.Case.ApplicationDateTime__c != null ? String.valueOf(workOrder.Case.ApplicationDateTime__c.format('yyyyMMdd')): '';      
            temp_i_info.REP_NAME    = workOrder.Case.Account != null && workOrder.Case.Account.Representative__c != null ? workOrder.Case.Account.Representative__c : '';

            if (workOrder.Asset.SerialNumber.contains('0000000000')) {
                temp_i_info.SERNR = workOrder.Asset.SerialNumber == null ? '' : Integer.valueOf(workOrder.Asset.SerialNumber).toString();
            } else {
                temp_i_info.SERNR = workOrder.Asset != null && workOrder.Asset.SerialNumber != null ? workOrder.Asset.SerialNumber : ''; 
            }

            temp_i_info.TXTQM       = workOrder.FailureStatus__c != null ? workOrder.FailureStatus__c : '';
            temp_i_info.TYPBZ       = workOrder.Asset != null && workOrder.Asset.MachineName__c != null ? workOrder.Asset.MachineName__c : '';
            temp_i_info.WAERS       = workOrder.CurrencyIsoCode != null ? workOrder.CurrencyIsoCode : '';
            temp_i_info.QMNUM       = workOrder.Noti_Number__c != null ? '000' + workOrder.Noti_Number__c : '';
            temp_i_info.QMTXT       = workOrder.ReceptionDetail__c != null ? workOrder.ReceptionDetail__c : '';
            temp_i_info.WTY_TYPE    = workOrder.Case.FM_LaborWarranty__c == 'Y' ? 'IN' : 'OUT';

        /**
         * I_CODE
         */
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_CODE temp_i_code = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_CODE();
            temp_i_code.CODE_01 = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '';
            temp_i_code.CODE_02 = '0';
            temp_i_code.CODE_03 = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c.right(2) : '';
            temp_i_code.TEXT    = (workOrder.FailureArea__c != null ? workOrder.FailureArea__c: '') + ' - ' + 
            (workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '');

        /**
         * I_HISTORY
         */
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_HISTORY temp_i_history = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_I_HISTORY();            
            temp_i_history.BLCOD    = workOrder.ResponsibleDepartment__c != null ? workOrder.ResponsibleDepartment__c : '';
            temp_i_history.FECOD    = workOrder.FailurePhenomenonValue__c != null ? workOrder.FailurePhenomenonValue__c : '';

            String failureArea = (workOrder.FailureAreaValue__c != null) ? workOrder.FailureAreaValue__c : '';
            String failureGroup = (workOrder.FailureAreaGroupValue__c != null) ? workOrder.FailureAreaGroupValue__c : '';
            
            // failureGroup이 2자리면 앞에 0을 붙여서 3자리로 맞춤
            if (failureGroup.length() == 2) {
                failureGroup = '0' + failureGroup;
            }
            
            temp_i_history.FEGRP = failureArea + failureGroup + '00';
            temp_i_history.FETXT    = workOrder.FailurePhenomenonDetail__c != null ? workOrder.FailurePhenomenonDetail__c : '';
            temp_i_history.KURZTEXT = (workOrder.FailureArea__c != null ? workOrder.FailureArea__c : '') + ' - ' + (workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '');
            temp_i_history.MATXT    = workOrder.PendingOrCustomerMatters__c != null ? workOrder.PendingOrCustomerMatters__c : '';
            temp_i_history.MNCOD    = workOrder.RepairActionValue__c != null ? workOrder.RepairActionValue__c : '';
            temp_i_history.MNGRP    = '90000001'; // Doobiz에서 하드코딩되어 저장되는 값
            temp_i_history.OTEIL    = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c.right(2) : '';
            temp_i_history.OTGRP    = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c + '00000' : '';
            temp_i_history.QMNUM    = workOrder.Noti_Number__c  != null ? '000'+ workOrder.Noti_Number__c  : '';
            temp_i_history.TXTCDFE  = workOrder.FailurePhenomenon__c != null ? workOrder.FailurePhenomenon__c : '';
            temp_i_history.TXTCDMA  = workOrder.RepairAction__c != null ? workOrder.RepairAction__c : '';
            temp_i_history.TXTCDUR  = workOrder.CauseOfFailure__c != null ? workOrder.CauseOfFailure__c : '';
            temp_i_history.URCOD    = workOrder.CauseOfFailureValue__c != null ? workOrder.CauseOfFailureValue__c : '';
            temp_i_history.URGRP    = failureArea + failureGroup + (workOrder.FailurePhenomenonValue__c != null ? workOrder.FailurePhenomenonValue__c : '');
            temp_i_history.URTXT    = workOrder.CauseOfFailureDetail__c != null ? workOrder.CauseOfFailureDetail__c : '';

        /**
        * T_MOTION : list  
        */
        Integer indexNum = 0;
        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MOTION> temp_t_motion_list = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MOTION>();
        for (WorkOrderResult__c work : workHistory) {
            indexNum++;
            /**
            * T_MOTION
            */
            IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MOTION temp_t_motion = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MOTION();
            temp_t_motion.AUFNR         = workOrder.ServiceOrderNumber__c != null ? workOrder.ServiceOrderNumber__c : '';
            temp_t_motion.PERNR         = work.ServiceResource__r != null && work.ServiceResource__r.StaffNumber__c != null ? '0000' + work.ServiceResource__r.StaffNumber__c : '';
            temp_t_motion.SVCMAN_NAME   = work.ServiceResource__r != null && work.ServiceResource__r.Name != null ? (work.ServiceResource__r.AD_ID__c != null ? work.ServiceResource__r.AD_ID__c + ' ' + work.ServiceResource__r.Name : work.ServiceResource__r.Name) : '';
            temp_t_motion.ISDD          = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
            temp_t_motion.ISDZ          = work.WorkStartTime__c != null ? String.valueOf(work.WorkStartTime__c).subString(0,8) : '';
            temp_t_motion.AUSBS         = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
            temp_t_motion.AUZTB         = work.WorkEndTime__c != null ? String.valueOf(work.WorkEndTime__c).subString(0,8) : '';
            temp_t_motion.ISMNW         = work.WorkTime__c != null ? work.WorkTime__c : '';
            temp_t_motion.WORKCD        = work.WorkType__c != null ? String.valueOf(work.WorkType__c) : '';
            temp_t_motion.LTXA1         = work.Description__c != null ? String.valueOf(work.Description__c) : '';
            temp_t_motion.WORKNO        = String.valueOf(indexNum);

            temp_t_motion_list.add(temp_t_motion);
        }

        /**
        * T_MATERIAL : list  
        */
        Datetime nowDatetime = DateTime.now();

        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MATERIAL>  temp_t_material_list = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MATERIAL>();
            for (Integer i = 0; i< productRequestList.size(); i++) {
                ProductRequest product = productRequestList[i];
                    
                IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MATERIAL temp_t_material = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_MATERIAL();

                temp_t_material.AUFNR       = workOrder.ServiceOrderNumber__c != null ? workOrder.ServiceOrderNumber__c : '';
                temp_t_material.CAUSE_PRT   = product.IsCause__c == true ? 'X' : '';
                temp_t_material.SEQNO       = '0000';
                temp_t_material.MATNR       = product.Product__r.Name != null ? product.Product__r.Name : '';
                temp_t_material.MAKTX       = product.Product__r.FM_MaterialDetails__c != null ? product.Product__r.FM_MaterialDetails__c : '' ;
                temp_t_material.MEINS       = product.Product__r.Unit__c != null ? product.Product__r.Unit__c : '';
                temp_t_material.SUPPLY_TYPE = product.SupplyType__c != null ? product.SupplyType__c : '';
                temp_t_material.NETWR       = product.SAPPartsPrice__c != null ? String.valueOf(product.SAPPartsPrice__c) : ''; 
                temp_t_material.WAERS       = product.Product__r.CurrencyIsoCode != null ? product.Product__r.CurrencyIsoCode : '';
                temp_t_material.RETURN_YN   = product.ReturnStatus__c != null ? product.ReturnStatus__c : '';
                temp_t_material.ERDAT       = nowDatetime.format('yyyyMMdd');
                temp_t_material.ERZET       = nowDatetime.format('HH:mm:ss');
                temp_t_material.ITEM_CAT    = product.SAPItemCategory__c != null ? product.SAPItemCategory__c : ''; 
                temp_t_material.RETURN_TYPE = product.ReturnType__c != null ? product.ReturnType__c : '';
                temp_t_material.MENGE       = product.MENGE_GI__c != null ? String.valueOf(product.MENGE_GI__c) : ''; 
                temp_t_material.PGMNG       = product.Quantity__c != null ? String.valueOf(product.Quantity__c) : '';
                temp_t_material.ITEM_NUMBER = product.Seq__c;
                temp_t_material.GR          = product.ShippingCheck__c != null ? product.ShippingCheck__c : '';
                temp_t_material.REASON1     = product.Reason1__c != null ? product.Reason1__c : '';
                temp_t_material.REASON2     = product.Reason2__c != null ? product.Reason2__c : '';
                temp_t_material.RETURN_TEXT = product.ReturnNote__c != null ? product.ReturnNote__c : '';
                temp_t_material_list.add(temp_t_material);
            }    

        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP> temp_t_tmp_list = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP>();
        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR> temp_t_tmp_sr_list = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR>();

        List<Map<String, Object>> fileMapList = getConvertFile(convertVersionIdList, 'IF_SERVICE_046',  workOrder.ServiceOrderNumber__c);

        // 250417 확정인 경우에만 파일이 업로드 되도록 수정
        if (isConfirmed) {
            for (Map<String, Object> fileMap : fileMapList) {
                IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP t_Tmp = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP();
                IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR t_Tmp_Sr = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR();
                
                if((String) fileMap.get('FILETYPE') == 'report') {
                    t_Tmp_Sr.FILENAME = (String) fileMap.get('FILENAME');
                    t_Tmp_Sr.IF_DESC  = (String) fileMap.get('IF_DESC');
                    t_Tmp_Sr.EVISEQX  = (String) fileMap.get('EVISEQX');
                    t_Tmp_Sr.FILE_SIZE = (String) fileMap.get('FILESIZE');
                    t_Tmp_Sr.LINE     = (String) fileMap.get('FILE_DATA');
                    
                    temp_t_tmp_sr_list.add(t_Tmp_Sr);
                } else {
                    t_Tmp.FILENAME = (String) fileMap.get('FILENAME');
                    t_Tmp.IF_DESC  = (String) fileMap.get('IF_DESC');
                    t_Tmp.EVISEQX  = (String) fileMap.get('EVISEQX');
                    t_Tmp.FILE_SIZE = (String) fileMap.get('FILESIZE');
                    t_Tmp.LINE     = (String) fileMap.get('FILE_DATA');
                    
                    temp_t_tmp_list.add(t_Tmp);
                }
            }
        }
        
        /**
        * Service Report File List
        */
        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL_SR> t_DEL_SR_list = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL_SR>();
        if (!docMapList.isEmpty()) {
            for (Map<String, String> docMap : docMapList) {
                if (docMap.get('reportType') == 'report') {
                    IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL_SR t_DEL_SR = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL_SR();
                    t_DEL_SR.DOCNO = docMap.get('erpDocNo');
                    t_DEL_SR_list.add(t_DEL_SR);
                }
            }
        }
        
        /**
        * ETC File List
        */
        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL> t_DEL_list = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL>();
        if (!docMapList.isEmpty()) {
            for (Map<String, String> docMap : docMapList) {
                if (docMap.get('reportType') != 'report') {
                    IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL t_DEL = new IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_DEL();
                    t_DEL.DOCNO = docMap.get('erpDocNo');
                    t_DEL_list.add(t_DEL);
                }
            }
        }

        /**
        * @Scalar
        */   
        parameters.I_EXRSN      = completionResult.OverReason__c != null ? completionResult.OverReason__c : '';
        parameters.I_DESCRIPT   = workOrder.FailurePhenomenonDetail__c != null ? workOrder.FailurePhenomenonDetail__c : '';
        parameters.I_CR         = workOrder.PendingMattersCustomerRequirements__c != null ? workOrder.PendingMattersCustomerRequirements__c : '';
        parameters.I_CAUSE      = workOrder.CauseOfFailureDetail__c != null ? workOrder.CauseOfFailureDetail__c : '';
        parameters.I_ACTIVITY   = workOrder.PendingOrCustomerMatters__c != null ? workOrder.PendingOrCustomerMatters__c : '';

        parameters.I_USERINFO   = temp_i_userinfo;
        parameters.I_CODE       = temp_i_code;
        parameters.I_INFO       = temp_i_info;
        parameters.I_HISTORY    = temp_i_history;
        parameters.T_MOTION     = temp_t_motion_list;
        parameters.T_MATERIAL   = temp_t_material_list;
        parameters.T_TMP_SR     = temp_t_tmp_sr_list; // 서비스 리포트 파일 생성
        parameters.T_TMP        = temp_t_tmp_list; // 기타 첨부 파일 생성
        parameters.T_DEL        = t_DEL_list; // 기타 첨부 파일 삭제 리스트
        parameters.T_DEL_SR     = t_DEL_SR_list; // 서비스 리포트 파일 삭제 리스트

        /**
        * @ApiConnection
        */    
        IF_ERP_Service_ServRepInput method = new IF_ERP_Service_ServRepInput();
        method.interfaceUtil.isInsertLog = false; 
        
        IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res resParam_046 =  method.IF_SERVICE_046(parameters);

            if (isConfirmed) {
                IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res resParam_050 =  interfaceCall050(recordId, isConfirmed);
                resMap.put('res046' , resParam_046); 
                resMap.put('res050' , resParam_050); 
            } else {
                resMap.put('res046' , resParam_046); 
            }           

        return resMap;        
    }

    /**
         * Apex Class           : IF_ERP_Service_ServRepInput
         * Wrapper Class        : IF_ERP_Service_ServRepInput_Classes
         * Wrapper Name         : IF_SERVICE_050
         * SFDC interface Id    : IF-SERVICE-050
         * New I/F              : ZCRM_CS_WEB_JOB_RESULT_CONF
         * Description          : 서비스 리포트 확정 
     */ 
    public IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res interfaceCall050(Id recordId, Boolean isConfirmed) {
        WorkOrder workOrder = getWorkOrderData(recordId);
        Map<String, Object> workOrderResults = getWorkOrderResults(recordId);
        List<ProductRequest> productRequestList = getProductRequests(recordId);

        List<WorkOrderResult__c> workHistory = (List<WorkOrderResult__c>) workOrderResults.get('WH');
        WorkOrderResult__c completionResult = (WorkOrderResult__c) workOrderResults.get('COM'); 

        if (completionResult == null) {
            completionResult = new WorkOrderResult__c();
        }

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_USERINFO i_userInfo = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_USERINFO();
        i_userInfo.BNAME        = currentUser?.Id == null ? '' : currentUser.Id;
        i_userInfo.RNAME        = currentUser?.ERP_Key__c == null ? '' : String.valueOf(currentUser.ERP_Key__c);
        i_userInfo.KUNNR        = currentUser?.Account?.CustomerCode__c == null ? '' : currentUser.Account.CustomerCode__c;
        i_userInfo.VKORG        = currentUser?.SalesOrganization__c == null ? '' : currentUser.SalesOrganization__c;
        i_userInfo.VTWEG        = currentUser?.DistributionChannel__c == null ? '' : currentUser.DistributionChannel__c;
        i_userInfo.SPART        = currentUser?.Division__c == null ? '' : currentUser.Division__c;
        i_userInfo.WERKS        = workOrder?.ServiceTerritory?.PlanningPlant__c == null ? '' : workOrder.ServiceTerritory.PlanningPlant__c;
        i_userInfo.ARBPL        = workOrder?.ServiceTerritory?.WCCode__c == null ? '' : workOrder.ServiceTerritory.WCCode__c;

        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_INFO i_info = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_INFO();
        
            i_info.AUFNR = workOrder.ServiceOrderNumber__c !=null ? '000' + workOrder.ServiceOrderNumber__c : '';
            i_info.AUART = workOrder.PMActivityType__c !=null ? workOrder.PMActivityType__c : '';
            i_info.QMNUM = workOrder.Noti_Number__c !=null ? '000' + workOrder.Noti_Number__c : '';
            i_info.ILART = workOrder.OrderType__c !=null ? workOrder.OrderType__c : '';
            i_info.QMDAT = workOrder.Case.ApplicationDateTime__c != null ? String.valueOf(workOrder.Case.ApplicationDateTime__c).replace('-', '') : '';
            i_info.GSTRP = workOrder.CreatedDate != null ? String.valueOf(workOrder.CreatedDate.format('yyyyMMdd')) : '';
            i_info.LTRMN = workOrder.ActionCallDate__c != null ? String.valueOf(workOrder.ActionCallDate__c).replace('-', '') : '';
            i_info.QMTXT = workOrder.ReceptionDetail__c != null ? workOrder.ReceptionDetail__c  : '';
            i_info.TXTQM = workOrder.FailureStatus__c != null ? workOrder.FailureStatus__c : '';
            i_info.EQUNR = workOrder.Asset != null && workOrder.Asset.Name != null ? workOrder.Asset.Name : '';
            i_info.TYPBZ = workOrder.Asset != null && workOrder.Asset.MachineName__c != null ? workOrder.Asset.MachineName__c : '';
            
            if (workOrder.Asset.SerialNumber.contains('0000000000')) {
                i_info.SERNR = workOrder.Asset.SerialNumber == null ? '' : Integer.valueOf(workOrder.Asset.SerialNumber).toString();
            } else {
                i_info.SERNR = workOrder.Asset != null && workOrder.Asset.SerialNumber != null ? workOrder.Asset.SerialNumber : ''; 
            }

            i_info.INBDT = workOrder.Asset != null && workOrder.Asset.InstallationFinish__c != null ? String.valueOf(workOrder.Asset.InstallationFinish__c).replace('-', '') : '';
            i_info.NAME  = workOrder.Case.Account != null ? workOrder.Case.Account.Name : '';
            i_info.REP_NAME     = workOrder.Case.Account != null && workOrder.Case.Account.Representative__c != null ? workOrder.Case.Account.Representative__c : '';
            i_info.MOBILE       = workOrder.Case != null && workOrder.Case.FM_PhoneNumber__c != null ? String.valueOf(workOrder.Case.FM_PhoneNumber__c) : '';
            i_info.CONTACT_TEL  = workOrder.Case != null && workOrder.Case.FM_AccountPhone__c != null ? workOrder.Case.FM_AccountPhone__c : '';    
            i_info.WAERS  = 'KRW';
            i_info.WTY_TYPE    = workOrder.Case.FM_LaborWarranty__c == 'Y' ? 'IN' : 'OUT';
                
        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_HISTORY i_history = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_HISTORY();
            i_history.QMNUM = workOrder.Noti_Number__c !=null ? '000' + workOrder.Noti_Number__c : '';
            i_history.OTGRP = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c + '00000' : '';
            i_history.OTEIL = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c.right(2) : '';
            i_history.KURZTEXT = (workOrder.FailureArea__c != null ? workOrder.FailureArea__c : '') + ' - ' + (workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '');
            
            String failureArea = (workOrder.FailureAreaValue__c != null) ? workOrder.FailureAreaValue__c : '';
            String failureGroup = (workOrder.FailureAreaGroupValue__c != null) ? workOrder.FailureAreaGroupValue__c : '';
            
            // failureGroup이 2자리면 앞에 0을 붙여서 3자리로 맞춤
            if (failureGroup.length() == 2) {
                failureGroup = '0' + failureGroup;
            }
            i_history.FEGRP     = failureArea + failureGroup + '00';

            i_history.FECOD     = workOrder.FailurePhenomenonValue__c != null ? workOrder.FailurePhenomenonValue__c : '';
            i_history.TXTCDFE   = workOrder.FailurePhenomenon__c != null ? workOrder.FailurePhenomenon__c : '';
            i_history.FETXT     = workOrder.FailurePhenomenonDetail__c != null ? workOrder.FailurePhenomenonDetail__c : '';
            i_history.URGRP     = failureArea + failureGroup + (workOrder.FailurePhenomenonValue__c != null ? workOrder.FailurePhenomenonValue__c : '');
            i_history.URCOD     = workOrder.CauseOfFailureValue__c != null ? workOrder.CauseOfFailureValue__c : '';
            i_history.TXTCDUR   = workOrder.CauseOfFailure__c != null ? workOrder.CauseOfFailure__c : '';
            i_history.URTXT     = workOrder.CauseOfFailureDetail__c != null ? workOrder.CauseOfFailureDetail__c : '';
            i_history.MNGRP     = '90000001';
            i_history.MNCOD     = workOrder.RepairActionValue__c != null ? workOrder.RepairActionValue__c : '';
            i_history.TXTCDMA   = workOrder.RepairAction__c != null ? workOrder.RepairAction__c : '';
            i_history.MATXT     = workOrder.PendingOrCustomerMatters__c != null ? workOrder.PendingOrCustomerMatters__c : '';
            i_history.BLCOD     = workOrder.ResponsibleDepartment__c != null ? workOrder.ResponsibleDepartment__c : '';
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_CODE i_code = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_I_CODE();
            i_code.CODE_01 = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '';
            i_code.CODE_02 = '0';
            i_code.CODE_03 = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c.right(2) : '';
            i_code.TEXT    = (workOrder.FailureArea__c != null ? workOrder.FailureArea__c : '') + ' - ' + (workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '');
        
        List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MOTION> t_motion_list = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MOTION>();

            for (WorkOrderResult__c work : workHistory) {
                IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MOTION t_motion = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MOTION();
                t_motion.AUFNR = workOrder.ServiceOrderNumber__c !=null ? '000' + workOrder.ServiceOrderNumber__c : '';
                t_motion.PERNR = work.ServiceResource__r != null && work.ServiceResource__r.StaffNumber__c != null ? '0000' + work.ServiceResource__r.StaffNumber__c : '';
                t_motion.SVCMAN_NAME = work.ServiceResource__r != null && work.ServiceResource__r.Name != null ? (work.ServiceResource__r.AD_ID__c != null ? work.ServiceResource__r.AD_ID__c + ' ' + work.ServiceResource__r.Name : work.ServiceResource__r.Name) : '';
                t_motion.ISDD = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                t_motion.ISDZ = work.WorkStartTime__c != null ? String.valueOf(work.WorkStartTime__c).subString(0,8) : '';
                t_motion.AUSBS = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                t_motion.AUZTB = work.WorkEndTime__c != null ? String.valueOf(work.WorkEndTime__c).subString(0,8) : '';
                t_motion.ISMNW = work.WorkTime__c != null ? work.WorkTime__c : '';
                t_motion.LTXA1 = work.Description__c != null ? String.valueOf(work.Description__c) : '';
                t_motion.WORKCD = work.WorkType__c != null ? String.valueOf(work.WorkType__c) : '';
                
                t_motion_list.add(t_motion);
            }

        Datetime nowDatetime = DateTime.now();

        List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MATERIAL> t_material_list = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MATERIAL>();
        
            for (Integer i = 0; i< productRequestList.size(); i++) {
                ProductRequest product = productRequestList[i];

                IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MATERIAL t_material = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_MATERIAL();
                t_material.AUFNR = workOrder.ServiceOrderNumber__c !=null ? '000' + workOrder.ServiceOrderNumber__c : '';
                t_material.CAUSE_PRT = product.IsCause__c == true ? 'X' : '';
                t_material.MATNR = product.Product__r.Name != null ? product.Product__r.Name : '';
                t_material.MAKTX = product.Product__r.FM_MaterialDetails__c != null ? product.Product__r.FM_MaterialDetails__c : '' ;
                t_material.MEINS = product.Product__r.Unit__c != null ? product.Product__r.Unit__c : '';
                t_material.SUPPLY_TYPE = product.SupplyType__c != null ? product.SupplyType__c : '';
                t_material.NETWR = product.SAPPartsPrice__c != null ? String.valueOf(product.SAPPartsPrice__c) : ''; 
                t_material.WAERS = product.Product__r.CurrencyIsoCode != null ? product.Product__r.CurrencyIsoCode : '';
                t_material.RETURN_YN   = product.ReturnStatus__c != null ? product.ReturnStatus__c : '';
                t_material.RETURN_TEXT = product.ReturnNote__c != null ? product.ReturnNote__c : '';
                t_material.ERDAT = nowDatetime.format('yyyyMMdd');
                t_material.ERZET = nowDatetime.format('HH:mm:ss');
                t_material.ITEM_CAT = product.SAPItemCategory__c != null ? product.SAPItemCategory__c : ''; 
                t_material.RETURN_TYPE = product.ReturnType__c != null ? product.ReturnType__c : '';
                t_material.PGMNG = product.Quantity__c != null ? String.valueOf(product.Quantity__c) : '';
                t_material.MENGE = product.MENGE_GI__c != null ? String.valueOf(product.MENGE_GI__c) : ''; 
                t_material.REASON1 = product.Reason1__c != null ? product.Reason1__c : '';
                t_material.REASON2 = product.Reason2__c != null ? product.Reason2__c : '';
                t_material.ITEM_NUMBER = product.Seq__c !=null ? product.Seq__c : '';
                t_material.GR = product.ShippingCheck__c != null ? product.ShippingCheck__c : '';

                t_material_list.add(t_material);
            }
        
        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req parameters = new IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req();
        
        parameters.I_ACTIVITY = workOrder.PendingOrCustomerMatters__c != null ? workOrder.PendingOrCustomerMatters__c : '';
        parameters.I_DESCRIPT = workOrder.FailurePhenomenonDetail__c != null ? workOrder.FailurePhenomenonDetail__c : '';                                    
        parameters.I_CAUSE    = workOrder.CauseOfFailureDetail__c != null ? workOrder.CauseOfFailureDetail__c : '';
        parameters.I_CR       = workOrder.PendingMattersCustomerRequirements__c !=null ? workOrder.PendingMattersCustomerRequirements__c : '';
        parameters.I_INFO     = i_info;
        parameters.I_HISTORY  = i_history;
        parameters.I_CODE     = i_code;
        parameters.T_MOTION   = t_motion_list;
        parameters.T_MATERIAL = t_material_list;
        parameters.I_USERINFO = i_userInfo;
        
        IF_ERP_Service_Report method = new IF_ERP_Service_Report();
        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res resParam = method.IF_SERVICE_050(parameters);

        System.debug('recordId ::: ' + JSON.serialize(recordId));
        System.debug('request Param ::: ' + JSON.serialize(parameters));
        System.debug('response Param ::: ' + JSON.serialize(resParam));

        if (resParam.O_RETURN.TYPE == 'S') {
            if (isConfirmed) {
                WorkOrder wo = new WorkOrder();
                Datetime myDateTime = Datetime.now();
                wo.Id                = recordId;
                wo.ConfirmedDate__c  = myDateTime;
                wo.Status            = 'Confirm';
                update wo;
            }
        }
        return resParam;
    }

    /** 
     * SFDC interface Id    : IF-CSPLUS-044
     * RFC Name             : ZCRM_CS_A_CLAIM_RESULT_SVC_SAV
     * Description          : DNSA 서비스리포트 결과 저장
     */
    public IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res interfaceCall044(Id recordId, Boolean isConfirmed, List<Map<String, String>> docMapList, List<String> convertVersionIdList) {

        WorkOrder workOrder = getWorkOrderData(recordId);
        Map<String, Object> workOrderResults = getWorkOrderResults(recordId);

        List<WorkOrderResult__c> workHistory = (List<WorkOrderResult__c>) workOrderResults.get('WH');
        List<WorkOrderResult__c> partHistory = (List<WorkOrderResult__c>) workOrderResults.get('PT'); 

        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req request = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req();
        
        DateTime failureDate = workOrder.Case.BreakdownDateTime__c != null ? workOrder.Case.BreakdownDateTime__c : workOrder.Case.ApplicationDateTime__c;
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER header = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER();
            header.ILART            = '699'; // OrderType__c 고정 값
            header.FAIL_DT          = failureDate == null ? '' : failureDate.format('yyyyMMdd');
            header.FAIL_TM          = failureDate == null ? '' :failureDate.format('HH:mm:ss');
            header.AUFNR            = workOrder?.ServiceOrderNumber__c == null ? '' : workOrder.ServiceOrderNumber__c;
            header.QMNUM            = workOrder?.Noti_Number__c == null ? '' : '000' + workOrder.Noti_Number__c;
            header.QMDAT            = workOrder?.Case?.ApplicationDateTime__c == null ? '' : workOrder.Case.ApplicationDateTime__c.format('yyyyMMdd');     
            header.REQUIRE_DAT      = workOrder?.ScheduledDispatchTime__c  == null ? '' : workOrder.ScheduledDispatchTime__c .format('yyyyMMdd');
            header.ARRVAL_DT        = workOrder.RepairStartDate__c != null ? String.valueOf(workOrder.RepairStartDate__c).replace('-', '') : '';
            header.FAIL_END_DT      = workOrder.RepairEndDate__c != null ? String.valueOf(workOrder.RepairEndDate__c).replace('-', '') : '';
            header.REPORTEDBY       = currentUser?.EmployeeNumber == null ? '' : currentUser.EmployeeNumber;
            header.TYPBZ            = workOrder?.Asset?.MachineName__c == null ? '' : workOrder.Asset.MachineName__c;

            if (workOrder.Asset.SerialNumber.contains('0000000000')) {
                header.SERNR = workOrder.Asset.SerialNumber == null ? '' : Integer.valueOf(workOrder.Asset.SerialNumber).toString();
            } else {
                header.SERNR = workOrder.Asset != null && workOrder.Asset.SerialNumber != null ? workOrder.Asset.SerialNumber : ''; 
            }

            header.BREAKDOWN        = workOrder?.isMachineDown__c == true ? 'X' : '';
            header.CUSTOMER_NAME    = workOrder.CustomerName__c != null ? workOrder.CustomerName__c : '';
            header.CUSTOMER_TITLE   = workOrder.CustomerPosition__c != null ? workOrder.CustomerPosition__c : '';
            header.PHENOMENA        = workOrder.ReceptionDetail__c != null ? workOrder.ReceptionDetail__c : '';
            header.SIGNED_DATE      = workOrder.SignatureDate__c != null ? String.valueOf(workOrder.SignatureDate__c).replace('-', '') : '';
            
        
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO userInfo = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO();
            userInfo.BNAME  = currentUser?.Id == null ? '' : currentUser.Id;
            userInfo.RNAME  = currentUser?.ERP_Key__c == null ? '' : String.valueOf(currentUser.ERP_Key__c);
            userInfo.NAME1  = workOrder?.SoldTo__r?.Name == null ? '' : workOrder.SoldTo__r.Name; 
            userInfo.WERKS  = '414S';  // Plant__c 고정 값
            userInfo.WAERS  = 'USD';
            userInfo.ARBPL  = '1262215'; // WCCode__c 고정 값
            userInfo.KUNN2  = workOrder?.SoldTo__r?.CustomerCode__c == null ? '' : workOrder.SoldTo__r.CustomerCode__c;
            userInfo.LAND1  = 'US';
            userInfo.REGIO  = 'CA';
            userInfo.VERAN  = '440';
            userInfo.DF_CHK     = 'X';
            userInfo.FOREIGN    = 'X';
        
        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> t_claim_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> ();
        
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM claim = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM();
        
            claim.CLAIM_SEQ = '0001';
            claim.CODE_01   = workOrder?.FailureAreaValue__c == null ? '' : workOrder.FailureAreaValue__c;
            claim.CODE_02   = '0';
            claim.CODE_03   = workOrder?.FailureAreaGroupValue__c == null ? '' : workOrder.FailureAreaGroupValue__c.right(2);
            claim.OTGRP     = workOrder?.FailureAreaValue__c == null ? '' : workOrder.FailureAreaValue__c + '00000'; 
            claim.OTEIL     = workOrder?.FailureAreaGroupValue__c == null ? '' : workOrder.FailureAreaGroupValue__c.right(2);
            claim.KURZTEXT  = (workOrder.FailureArea__c != null ? workOrder.FailureArea__c : '') + ' - ' + (workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '');
            claim.FEGRP     = (workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '') + (workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c : '') + '00';
            claim.FECOD     = workOrder?.FailurePhenomenonValue__c == null ? '' : workOrder.FailurePhenomenonValue__c;
            claim.FETXT     = workOrder?.FailurePhenomenonDetail__c == null ? '' : workOrder.FailurePhenomenonDetail__c;    
            claim.URGRP     = (workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '') + (workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c : '') + (workOrder.FailurePhenomenonValue__c != null ? workOrder.FailurePhenomenonValue__c : '');
            claim.URCOD     = workOrder?.CauseOfFailureValue__c == null ? '' : workOrder.CauseOfFailureValue__c;
            claim.URTXT     = workOrder?.CauseOfFailureDetail__c == null ? '' : workOrder.CauseOfFailureDetail__c;
            claim.MNGRP     = '90000000';
            claim.MNCOD     = workOrder?.RepairActionValue__c == null ? '' : workOrder.RepairActionValue__c;
            claim.MATXT     = workOrder?.PendingOrCustomerMatters__c == null ? '' : workOrder.PendingOrCustomerMatters__c;
            claim.TXTCDUR   = workOrder.CauseOfFailure__c != null ? workOrder.CauseOfFailure__c : '';
            claim.TXTCDMA   = workOrder.RepairAction__c != null ? workOrder.RepairAction__c : '';
            claim.TXTCDFE   = workOrder.FailurePhenomenon__c != null ? workOrder.FailurePhenomenon__c : '';
            claim.BLCOD     = workOrder.ResponsibleDepartment__c != null ? workOrder.ResponsibleDepartment__c : '';
            t_claim_list.add(claim);

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_S> t_TextS_List = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_S>();        
            if(workOrder.FailurePhenomenonDetail__c != null) {
                List<String> textSList = workOrder.FailurePhenomenonDetail__c.split('\n');

                for (String text : textSList) {
                    IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_S t_TextS = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_S();
                    t_TextS.CLAIM_SEQ   = '0001';
                    t_TextS.TDLINE      = text;
                    t_TextS_List.add(t_TextS);
                }
            }

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_C> t_TextC_List = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_C>();
            if(workOrder.CauseOfFailureDetail__c != null) {
                List<String> textCList = workOrder.CauseOfFailureDetail__c.split('\n');

                for (String text : textCList) {
                    IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_C t_TextC = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_C();
                    t_TextC.CLAIM_SEQ   = '0001';
                    t_TextC.TDLINE      = text;
                    t_TextC_List.add(t_TextC);
                }
            }

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_A> t_TextA_List = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_A>();
            if(workOrder.PendingOrCustomerMatters__c != null) {
                List<String> textAList = workOrder.PendingOrCustomerMatters__c.split('\n');

                for (String text : textAList) {
                    IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_A t_TextA = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_A();
                    t_TextA.CLAIM_SEQ   = '0001';
                    t_TextA.TDLINE      = text;
                    t_TextA_List.add(t_TextA);
                }
            }

        System.debug('workOrder check ::: ' + JSON.serialize(workOrder));

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_P> t_TextP_List = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_P>();
            if(workOrder.ReceptionDetail__c != null) {
                List<String> textPList = workOrder.ReceptionDetail__c.split('\n');

                for (String text : textPList) {
                    IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_P t_TextP = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TEXT_P();
                    t_TextP.CLAIM_SEQ   = '0001';
                    t_TextP.TDLINE      = text;
                    t_TextP_List.add(t_TextP);
                }
            }

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE> t_date_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE> ();
            String orderNumber    = workOrder.ServiceOrderNumber__c != null ? workOrder.ServiceOrderNumber__c : '';    
            String notiNumber    = workOrder.Noti_Number__c != null ? workOrder.Noti_Number__c : '';

            for (WorkOrderResult__c work : workHistory) {
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE t_date = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE();
                // t_date.SEQNO = '0000';
                t_date.REP_FR_DT    = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                t_date.REP_FR_TM    = work.WorkStartTime__c != null ? String.valueOf(work.WorkStartTime__c).subString(0,8) : '';
                t_date.REP_TO_DT    = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                t_date.REP_TO_TM    = work.WorkEndTime__c != null ? String.valueOf(work.WorkEndTime__c).subString(0,8) : '';
                t_date.ISMNW        = work.WorkTime__c != null ? work.WorkTime__c : '';
                t_date.ISMNW_PDK    = work.TravelHour__c != null ? work.TravelHour__c : '';
                t_date.AIR_TRIP     = work.AirTrip__c != null && work.AirTrip__c == 'Yes' ? 'Y' : 'N';
                t_date.QMNUM        = notiNumber;
                t_date.AUFNR        = orderNumber;
                t_date_list.add(t_date);
            }
        
        
        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART> t_part_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART> ();

            for (WorkOrderResult__c work : partHistory) {            
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART t_part = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART();
                t_part.SEQNO        = '0001';
                t_part.MATNR        = work.ProductNumber__c != null ? work.ProductNumber__c : '';
                t_part.MAKTX        = work.ProductName__c != null ? work.ProductName__c : '';
                t_part.MENGE        = work.Quantity__c != null ? String.valueOf(work.Quantity__c) : '';
                t_part.CAUSE_PRT    = work.IsCause__c == true ? 'X' : '';
                t_part.RETURN_TEXT  = work.Note__c != null ? work.Note__c : '';
                t_part.AUFNR        = orderNumber;
                t_part_list.add(t_part);
            }

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP> t_Tmp_List = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP>();

        if (isConfirmed) {
            List<Map<String, Object>> fileMapList = getConvertFile(convertVersionIdList, 'IF_CSPLUS_044',  workOrder.ServiceOrderNumber__c);

            for (Map<String, Object> fileMap : fileMapList) {
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP t_Tmp = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP();
                
                t_Tmp.FILENAME = (String) fileMap.get('FILENAME');
                t_Tmp.IF_DESC  = (String) fileMap.get('IF_DESC');
                t_Tmp.EVISEQX  = (String) fileMap.get('EVISEQX');
                t_Tmp.FILE_SIZE = (String) fileMap.get('FILESIZE');
                t_Tmp.LINE     = (String) fileMap.get('FILE_DATA');
                
                t_Tmp_List.add(t_Tmp);
            }
            
        }

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DEL> t_Del_List = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DEL>();
        if (!docMapList.isEmpty()) {
            for (Map<String, String> docMap : docMapList) {
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DEL t_DEL = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DEL();
                t_DEL.DOCNO = docMap.get('erpDocNo');
                t_DEL_list.add(t_DEL);
            }
        }

        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE> t_File_List = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE>();
        
        request.I_UNAME     = 'CS_DMTA';
        request.I_LANGU     = 'E';
        request.I_USERINFO  = userInfo;
        request.I_HEADER    = header;
        request.T_DATE      = t_date_list;
        request.T_CLAIM     = t_claim_list;
        request.T_PART      = t_part_list;
        request.T_TEXT_S    = t_TextS_List;
        request.T_TEXT_C    = t_TextC_List;
        request.T_TEXT_A    = t_TextA_List;
        request.T_TEXT_P    = t_TextP_List;
        request.T_TMP       = t_Tmp_List;
        request.T_FILE      = t_File_List;
        request.T_DEL       = t_Del_List;
        
        IF_ERP_SalesOrder exectutor = new IF_ERP_SalesOrder();
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res resParam = exectutor.IF_CSPLUS_044(request);
                
        return resParam;
    }

    /**
    * @description 공통 WorkOrder 조회
    **/
    private static WorkOrder getWorkOrderData(Id recordId) {
        return [SELECT Id, ServiceOrderNumber__c, PMActivityType__c, OrderType__c, InstallTestFinish__c, CreatedDate, CurrencyIsoCode, Status, SoldTo__r.Name, SoldTo__r.CustomerCode__c,
                    FailureArea__c, FailureAreaValue__c, FailureAreaGroup__c, FailureAreaGroupValue__c, ServiceTerritory.PlanningPlant__c, ScheduledDispatchTime__c ,
                    FailurePhenomenon__c, FailurePhenomenonValue__c, FailurePhenomenonDetail__c, ServiceTerritory.WCCode__c, InspectionScore__c, PendingMattersCustomerRequirements__c,
                    CauseOfFailure__c, CauseOfFailureValue__c, FailureStatusCode__c, FailureStatus__c, RepairActionDetail__c, FM_WorkOrderResult_Template__c,
                    RepairAction__c, RepairActionValue__c, PendingOrCustomerMatters__c, CauseOfFailureDetail__c, Asset.FM_EquipmentWarrantyEquipmentParts__c,
                    Asset.Name, Asset.MachineName__c, Asset.SerialNumber, Asset.StartUpDate__c, Case.PendingDetail__c, ReceptionDetail__c, ResponsibleDepartment__c,
                    ServiceTerritory.Name, Asset.InstallationFinish__c, ActionCallDate__c, ReceiptDate__c, Case.ApplicationDateTime__c, 
                    Case.RepairRequestDateTime__c, RepairStartDate__c, RepairEndDate__c, Report_Type__c, Case.Account.CustomerCode__c, Case.BreakdownDateTime__c,
                    FieldManagerName__c, FieldManagerMobilePhone__c, WorkerName__c, WorkerMobilePhone__c, Noti_Number__c, FM_Requester__c, 
                    Case.Account.Name, Case.Account.Representative__c, Case.FM_AccountPhone__c, Case.FM_PhoneNumber__c, Case.Account.FM_Address__c, Case.Account.sggNm__c, HECare__c,
                    isMachineDown__c, ServiceEngineerName__c, SignatureDate__c, CustomerName__c, CustomerPosition__c, Case.AssetId, Case.FM_EquipmentWarranty__c, Case.FM_PartsWarranty__c, Case.FM_LaborWarranty__c,
                    (SELECT Id, ResultType__c, ServiceResource__r.Name, ServiceResource__r.StaffNumber__c, ServiceResource__r.AD_ID__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c, Description__c, ActionDetail__c FROM Work_Order_Content__r)
                FROM WorkOrder WHERE Id = :recordId LIMIT 1];
    }

    /**
    * @description 공통 WorkOrderResult 조회 
    **/
    private static Map<String, Object> getWorkOrderResults(Id recordId) {
        List<WorkOrderResult__c> results = [SELECT Id, Name, WorkOrder__c, WorkCenter__c, ResultType__c, CreatedDate, WorkOrder__r.WorkOrderNumber, 
                ServiceAppointment__c, SAKey__c, ServiceResource__c, ServiceResource__r.Name, WorkOrder__r.ServiceOrderNumber__c,
                ServiceResource__r.StaffNumber__c, ServiceResource__r.AD_ID__c, WorkDate__c, WorkEndDate__c, WorkStartTime__c, WorkOrder__r.Noti_Number__c,
                WorkEndTime__c, WorkTime__c, WorkType__c, Description__c, InitialDefectType__c, InitialDefectDetail__c, 
                ActionDetail__c, Note__c, StandardWorkFailureArea__c, StandardWorkItem__c, WorkOrder__r.RepairStartDate__c, WorkOrder__r.RepairEndDate__c,
                StandardWorkTime__c, StandardWorkForce__c, IsChangeStandardWork__c, ActualWorkTime__c, 
                ActualWorkForce__c, ChangeRequestReason__c, StandardHour__c, ProductNumber__c, 
                ProductName__c, IsCause__c, Quantity__c, OverReason__c, InspectionDetail__c,
                MainInstallationTime__c, TemporaryInstallationTime__c, FenseAPCCover__c, SemiSplashGuard__c, 
                OverTools__c, PMG__c, AAC__c, IsTemporaryInstallationTime__c, IsFenseAPCCover__c, 
                IsSemiSplashGuard__c, IsOverTools__c, IsPMG__c, IsAAC__c, EtcTime__c, ReasonOfETC__c, 
                IsHoliday__c, TotalInstallationTime__c, ReadinessStatus__c, AirTrip__c, TravelHour__c
            FROM WorkOrderResult__c
            WHERE WorkOrder__c = :recordId
            ORDER BY SaKey__c, WorkStartTime__c];
    
        List<WorkOrderResult__c> workHistoryResults = new List<WorkOrderResult__c>();
        List<WorkOrderResult__c> defectResults = new List<WorkOrderResult__c>();
        List<WorkOrderResult__c> partsUsedResults = new List<WorkOrderResult__c>();
        WorkOrderResult__c completionResult = null; 
    
        for (WorkOrderResult__c result : results) {
            if (result.ResultType__c == 'WH') {
                workHistoryResults.add(result);
            } else if (result.ResultType__c == 'ITD') {
                defectResults.add(result);
            } else if (result.ResultType__c == 'COM' && completionResult == null) { 
                completionResult = result; 
            } else if (result.ResultType__c == 'PT') {
                partsUsedResults.add(result);
            }
        }
    
        return new Map<String, Object>{
            'WH' => workHistoryResults,
            'ITD' => defectResults,
            'COM' => completionResult,
            'PT' => partsUsedResults
        };
    }

    /**
    * @description 공통 ProductRequest 조회
    **/
    private static List<ProductRequest> getProductRequests(Id recordId) {
        return [SELECT Id, Product__r.Name, Product__r.Name__c, Quantity__c, DeliveryCompleted__c, SAPPartsPrice__c, MENGE_GI__c,
                    Product__r.Unit__c, IsCause__c, ShippingCheck__c, ReturnStatus__c, ReturnType__c, SAPItemCategory__c, SupplyType__c,
                    Reason1__c, Reason2__c, ReturnNote__c, Seq__c, Product__r.CurrencyIsoCode, Product__r.FM_MaterialDetails__c, TransportsDivision__c 
                FROM ProductRequest
                WHERE Status = 'Approved' AND WorkOrderId = :recordId AND IsDealerPortalDelete__c = false 
                // AND IsDealerPortalPartition__c = false
                Order by Seq__c 
                ];
    }

    /**
    * @description 확정 시 Collaborator 조회
    **/
    private static List<Collaborator__c > getCollaborator (Id recordId) {
        return [SELECT
                Id, Name, ServiceResource__r.StaffNumber__c, WorkOrder__r.ServiceOrderNumber__c
                FROM Collaborator__c 
                WHERE WorkOrder__c = :recordId];
    }

    /**
    * @description Callout 전 ContentVersion 레코드 별 데이터 변환
    **/
    public static List<Map<String, Object>> getConvertFile (List<String> convertVersionIdList, String interfaceName, String orderNumber){
        try {
            system.debug('convertVersionIdList ::: '+convertVersionIdList);

            List<Map<String, Object>> fileTable = new List<Map<String, Object>>();
    
            Map<String, List<ContentVersion>> contentMap = new Map<String, List<ContentVersion>>();

            List<ContentVersion> cvList = [
                SELECT Id, ContentDocumentId, Title, VersionNumber, ContentSize, FileExtension, VersionData, DealerPotalFileType__c
                FROM ContentVersion
                WHERE DealerPotalFileType__c !='Signature' AND Id IN :convertVersionIdList
            ];

            for (ContentVersion cv : cvList) {
                if (!contentMap.containsKey(cv.Id)) {
                    contentMap.put(cv.Id, new List<ContentVersion>());
                }
                contentMap.get(cv.Id).add(cv);
            }

            for (String id : convertVersionIdList) {
                if (contentMap.containsKey(id)) {
                    for (ContentVersion cv : contentMap.get(id)) {
                        Blob fileData = cv.VersionData;
                        Integer startPos = 0;
                        Integer filePartIndex = 1;
    
                        String base64Data = EncodingUtil.base64Encode(fileData);
                        Integer fileLength = base64Data.length();

                        while (startPos < fileLength) {
                            Integer BUFFER_SIZE = 1024;

                            String buffer = base64Data.substring(
                                startPos,
                                Math.min(startPos + BUFFER_SIZE, base64Data.length())
                            );
                            
                            system.debug('buffer >> ' +buffer);

                            String convertTitle = orderNumber + '_' + cv.Title;

                            Map<String, Object> fileMap = new Map<String, Object>();
                            fileMap.put('INT_NO', String.valueOf(convertVersionIdList.indexOf(id) + 1));
                            fileMap.put('DOCU_ITEM', '0000' + String.valueOf(filePartIndex) + '0');
                            fileMap.put('FILE_ID', cv.Id);
                            
                            if (interfaceName.equals('IF_PARTS_025')) {
                                system.debug('File Test ::: ' + convertTitle);
                                fileMap.put('IF_DESC', EncodingUtil.urlEncode(convertTitle, 'UTF-8'));
                                fileMap.put('FILENAME', EncodingUtil.urlEncode(convertTitle, 'UTF-8'));
                            } else {
                                system.debug('File Test Common');
                                fileMap.put('IF_DESC', EncodingUtil.urlEncode(cv.Title, 'UTF-8'));
                                fileMap.put('FILENAME', EncodingUtil.urlEncode(cv.Title, 'UTF-8'));
                            }   
                            
                            fileMap.put('MIMETYPE', cv.FileExtension);
                            fileMap.put('DESCRIPTION', URL.getOrgDomainURL().toExternalForm()); 
                            fileMap.put('EVISEQX', String.valueOf(filePartIndex));
                            fileMap.put('FILETYPE', cv.DealerPotalFileType__c);
                            fileMap.put('FILE_SIZE', fileLength);
                
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

    private String encodeForSAP(String jsonString){
        jsonString = EncodingUtil.urlEncode(jsonString, 'UTF-8');
        jsonString = jsonString.replaceAll('%3D', '=');
        jsonString = jsonString.replaceAll('%7B', '{');
        jsonString = jsonString.replaceAll('%22', '"');
        jsonString = jsonString.replaceAll('%3A', ':');
        jsonString = jsonString.replaceAll('%7D', '}');  
        jsonString = jsonString.replaceAll('%5B', '[');  
        jsonString = jsonString.replaceAll('%5D', ']');  
        jsonString = jsonString.replaceAll('%2', ',');  
 
        return jsonString;
    }
}