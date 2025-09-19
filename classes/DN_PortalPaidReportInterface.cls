/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 05-12-2025
 * @last modified by  : Chungwoo Lee
**/
public without sharing class DN_PortalPaidReportInterface {

    /**
     * @description 현재 User getter/setter 
     */
    public static User currentUser {
        get {
            if (currentUser == null) {
                currentUser = [SELECT 
                                Id, UserCode__c, Division__c, SalesOrganization__c, DistributionChannel__c, ERP_Key__c,
                                Account.CustomerCode__c, Country__c
                                FROM User WHERE Id = :userInfo.getUserID() LIMIT 1];
            }
            return currentUser;
        }
        set;
    }

    /**
     * Wrapper Name         : IF_SERVICE_049
     * SFDC interface Id    : IF-SERVICE-049
     * New I/F              : ZCRM_CS_WEB_REQ_RES_SAVE_MT
     * Description          : 유상 리포트 정보 조회
    */
    public IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res interfaceCall049 (String recordId, Boolean isConfirmed, List<String> convertVersionIdList) {
        
        WorkOrder workOrder = [ SELECT Id, 
                    WorkOrderNumber, OrderType__c, FM_WorkOrderResult_Template__c, InspectionDetails__c, CreatedDate, ConfirmedDate__c, Asset.InstallationFinish__c, InstallTestFinish__c,
                    HasWarrantyDirectManagement__c, PMActivityType__c, ServiceTerritoryId, ServiceTerritory.Name, TargetCompletionDate__c,
                    Asset.MachineName__c, Asset.SerialNumber, Asset.Name, Asset.ObjectType__c, Asset.FM_EquipmentWarrantyEquipmentParts__c, Asset.InstallDate,
                    FM_PhoneNumber__c, Account.Name, Account.Representative__c, Account.Mobile__c, Account.FM_Address__c, Account.Phone, Account.sggNm__c,
                    Asset.FieldManagerName__c, Asset.FieldManagerMobilePhone__c, Asset.WorkerName__c, Asset.WorkerMobilePhone__c, ServiceOrderNumber__c,
                    FailureArea__c, FailureAreaValue__c, FailureAreaGroup__c, FailureAreaGroupValue__c, CurrencyIsoCode, Noti_Number__c,
                    FailurePhenomenon__c, FailurePhenomenonValue__c, FailurePhenomenonDetail__c, 
                    CauseOfFailure__c, CauseOfFailureValue__c, FailureStatusCode__c, FailureStatus__c, RepairActionDetail__c,ResponsibleDepartment__c,
                    RepairAction__c, RepairActionValue__c, PendingOrCustomerMatters__c, CauseOfFailureDetail__c, ServiceTerritory.PlanningPlant__c,
                    ActionCallDate__c, DefectDate__c, ReceiptDate__c, Worker__r.Name, Worker__r.StaffNumber__c, Worker__r.AD_ID__c , ServiceTerritory.WCCode__c
                FROM WorkOrder
                WHERE Id = :recordId LIMIT 1 ];
        
        List<WorkOrderResult__c> workOrderResults = [
            SELECT
            Id, Name, WorkOrder__c, WorkCenter__c, ResultType__c, ActionDetail__c, WorkOrder__r.WorkOrderNumber, OverReason__c,
            MainInstallationTime__c, IsTemporaryInstallationTime__c, TemporaryInstallationTime__c, IsHoliday__c, 
            SpecificationInstallationTime__c, IsFenseAPCCover__c, IsSemiSplashGuard__c, IsOverTools__c, IsPMG__c, IsAAC__c, IsEtc__c, EtcTime__c, ReasonOfETC__c,
            TotalInstallationTime__c, TotalInputTime__c, ReadinessStatus__c, InspectionDetail__c,
            WorkOrder__r.Asset.FieldManagerName__c, WorkOrder__r.Asset.FieldManagerMobilePhone__c, WorkOrder__r.Asset.WorkerName__c, WorkOrder__r.Asset.WorkerMobilePhone__c,
            WorkOrder__r.Asset.InstallationFinish__c, WorkOrder__r.Asset.HECare__c, WorkOrder__r.Asset.Name, Worker__c, Worker__r.Name
            FROM WorkOrderResult__c
            WHERE WorkOrder__c = :recordId AND ResultType__c =:'COM' LIMIT 1
        ];
        WorkOrderResult__c workOrderResult = new WorkOrderResult__c();
        if(!workOrderResults.isEmpty()) {
            workOrderResult = workOrderResults[0];
        }

        List<WorkOrderResult__c> workOrderResultList = [SELECT Id, 
                Name, WorkOrder__c, WorkCenter__c, ResultType__c, CreatedDate, WorkOrder__r.WorkOrderNumber, ServiceAppointment__c, SAKey__c,
                ServiceResource__c, ServiceResource__r.Name, ServiceResource__r.StaffNumber__c, ServiceResource__r.AD_ID__c, Worker__r.Name,
                WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkTime__c, WorkType__c, Description__c,
                InitialDefectType__c, InitialDefectDetail__c, ActionDetail__c, Note__c,
                StandardWorkFailureArea__c, StandardWorkItem__c, StandardWorkTime__c, StandardWorkForce__c,
                IsChangeStandardWork__c, ActualWorkTime__c, ActualWorkForce__c, ChangeRequestReason__c, StandardHour__c,
                ProductNumber__c, ProductName__c, IsCause__c, Quantity__c
            FROM WorkOrderResult__c
            WHERE WorkOrder__c = :recordId AND ResultType__c !='COM'
            Order By SaKey__c , WorkStartTime__c 
        ];

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req req = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req();

            /**
             * Scalar
             */
            req.I_DESCRIPT          = workOrder.FailurePhenomenonDetail__c != null ? workOrder.FailurePhenomenonDetail__c : '';
            req.I_CAUSE             = workOrder.CauseOfFailureDetail__c != null ? workOrder.CauseOfFailureDetail__c : '';
            req.I_ACTIVITY          = workOrder.PendingOrCustomerMatters__c != null ? workOrder.PendingOrCustomerMatters__c : '';
            req.I_TYPBZ             = workOrder.Asset != null && workOrder.Asset.MachineName__c != null ? workOrder.Asset.MachineName__c : '';

            if (workOrder.Asset.SerialNumber.contains('0000000000')) {
                req.I_SERNR = workOrder.Asset.SerialNumber == null ? '' : Integer.valueOf(workOrder.Asset.SerialNumber).toString();
            } else {
                req.I_SERNR             = workOrder.Asset != null && workOrder.Asset.SerialNumber != null ? workOrder.Asset.SerialNumber : ''; 
            }

            req.I_EQUNR             = workOrder.Asset != null && workOrder.Asset.Name != null ? workOrder.Asset.Name : '';

        /**
         * I_USERINFO
         */
        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_USERINFO I_USERINFO = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_USERINFO();
            I_USERINFO.BNAME        = currentUser?.Id == null ? '' : currentUser.Id;
            I_USERINFO.RNAME        = currentUser?.ERP_Key__c == null ? '' : String.valueOf(currentUser.ERP_Key__c);
            I_USERINFO.KUNNR        = currentUser?.Account?.CustomerCode__c == null ? '' : currentUser.Account.CustomerCode__c;
            I_USERINFO.VKORG        = currentUser?.SalesOrganization__c == null ? '' : currentUser.SalesOrganization__c;
            I_USERINFO.VTWEG        = currentUser?.DistributionChannel__c == null ? '' : currentUser.DistributionChannel__c;
            I_USERINFO.SPART        = currentUser?.Division__c == null ? '' : currentUser.Division__c;
            I_USERINFO.WERKS        = workOrder?.ServiceTerritory?.PlanningPlant__c == null ? '' : workOrder.ServiceTerritory.PlanningPlant__c;
            I_USERINFO.ARBPL        = workOrder?.ServiceTerritory?.WCCode__c == null ? '' : workOrder.ServiceTerritory.WCCode__c;

        req.I_USERINFO = I_USERINFO;

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INPUT I_INPUT = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_INPUT();
            I_INPUT.DESENDDATE     = workOrder.ActionCallDate__c != null ? String.valueOf(workOrder.ActionCallDate__c) : '';
            I_INPUT.DESSTTIME      = '00:00:00';
            I_INPUT.D_CODE         = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c.right(2) : '';
            I_INPUT.D_CODEGRP      = (workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '') + (workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c : '') + '00';
            I_INPUT.EQUNR          = workOrder.Asset != null && workOrder.Asset.Name != null ? workOrder.Asset.Name : '';
            I_INPUT.NOTIF_DATE     = workOrder.DefectDate__c != null ? String.valueOf(workOrder.DefectDate__c) : '';
            I_INPUT.NOTIFTIME      = '00:00:00';
            I_INPUT.REPORTEDBY     = workOrderResult.Worker__r.Name != null ? workOrderResult.Worker__r.Name : '';
            I_INPUT.REQUIRE_DAT    = workOrder.ReceiptDate__c != null ? String.valueOf(workOrder.ReceiptDate__c) : '';
            I_INPUT.STRMLFNDATE    = workOrder.ActionCallDate__c != null ? String.valueOf(workOrder.ActionCallDate__c) : '';
            I_INPUT.STRMLFNTIME    = '00:00:00';        
            I_INPUT.TXTQM          = workOrder.FailureStatus__c != null ? workOrder.FailureStatus__c : '';
            I_INPUT.WTY_TYPE       = workOrder.Asset.FM_EquipmentWarrantyEquipmentParts__c.contains('Y /') == true ? 'IN' : 'OUT';
     
            if (!isConfirmed) {
                I_INPUT.QMNUM   = workOrder.Noti_Number__c != null ? workOrder.Noti_Number__c: '';
            }

            req.I_INPUT = I_INPUT;

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_HISTORY I_HISTORY = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_HISTORY();
            I_HISTORY.FECOD    = workOrder.FailurePhenomenonValue__c !=null ? workOrder.FailurePhenomenonValue__c : '';
            I_HISTORY.FEGRP    = (workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '') + '0' + (workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c : '').right(2) + '00'; 
            I_HISTORY.FETXT    = workOrder.FailurePhenomenonDetail__c != null ? workOrder.FailurePhenomenonDetail__c : '';
            I_HISTORY.KURZTEXT = (workOrder.FailureArea__c != null ? workOrder.FailureArea__c : '') + ' - ' + (workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '');
            I_HISTORY.MATXT    = workOrder.PendingOrCustomerMatters__c != null ? workOrder.PendingOrCustomerMatters__c : '';
            I_HISTORY.MNCOD    = workOrder.RepairActionValue__c != null ? workOrder.RepairActionValue__c : '';
            I_HISTORY.OTEIL    = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c.right(2) : '';
            I_HISTORY.OTGRP    = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c + '00000' : '';
            I_HISTORY.TXTCDFE  = workOrder.FailurePhenomenon__c != null ? workOrder.FailurePhenomenon__c : '';
            I_HISTORY.TXTCDMA  = workOrder.RepairAction__c != null ? workOrder.RepairAction__c : '';
            I_HISTORY.MNGRP    = '90000001'; // AS-IS인 SAP에 하드 코딩되어있는 필드
            I_HISTORY.TXTCDUR  = workOrder.CauseOfFailure__c != null ? workOrder.CauseOfFailure__c : '';
            I_HISTORY.URCOD    = workOrder.CauseOfFailureValue__c != null ? workOrder.CauseOfFailureValue__c : '';
            I_HISTORY.URGRP    = (workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '') +  (workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c : '') + (workOrder.FailurePhenomenonValue__c != null ? workOrder.FailurePhenomenonValue__c : '');
            I_HISTORY.URTXT    = workOrder.CauseOfFailureDetail__c != null ? workOrder.CauseOfFailureDetail__c : '';

            I_HISTORY.QMNUM    = workOrder.Noti_Number__c != null ? workOrder.Noti_Number__c : '';

            req.I_HISTORY = I_HISTORY;

        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_CODE I_CODE = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_I_CODE();
            I_CODE.CODE_01 = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c + '00000' : '';
            I_CODE.CODE_02 = '0';
            I_CODE.CODE_03 = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c.right(2) : '';
            I_CODE.TEXT    = (workOrder.FailureArea__c != null ? workOrder.FailureArea__c : '') + ' - ' + (workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '');

            req.I_CODE = I_CODE;

        List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_MOTION> T_MOTION_List = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_MOTION>();
        for (WorkOrderResult__c work : workOrderResultList) {
            if (work.resultType__c == 'WH') {
                /**
                * T_MOTION
                */
                IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_MOTION temp_t_motion = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_MOTION();

                temp_t_motion.PERNR         = work.ServiceResource__r != null && work.ServiceResource__r.StaffNumber__c != null ? '0000' + work.ServiceResource__r.StaffNumber__c : '';
                temp_t_motion.SVCMAN_NAME   = work.ServiceResource__r != null && work.ServiceResource__r.AD_ID__c != null && work.ServiceResource__r.Name != null ? work.ServiceResource__r.AD_ID__c + ' ' + work.ServiceResource__r.Name : '';
                temp_t_motion.ISDD          = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c) : '';
                temp_t_motion.ISDZ          = work.WorkStartTime__c != null ? String.valueOf(work.WorkStartTime__c).subString(0,8) : '';
                temp_t_motion.AUSBS         = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c) : '';
                temp_t_motion.AUZTB         = work.WorkEndTime__c != null ? String.valueOf(work.WorkEndTime__c).subString(0,8) : '';
                temp_t_motion.LTXA1         = work.Description__c != null ? String.valueOf(work.Description__c) : '';

                temp_t_motion.WORKNO        = '0000';
                temp_t_motion.SEQNO         = '0000';
                temp_t_motion.RUECK         = '0000000000';
                temp_t_motion.ISMNW_PDK     = '0.0';
                temp_t_motion.ISMNW         = '0.0';
                temp_t_motion.ERZET         = '00:00:00';
                temp_t_motion.AEZET         = '00:00:00';

                if (!isConfirmed) {
                    temp_t_motion.AUFNR     = workOrder.ServiceOrderNumber__c != null ? '000' + workOrder.ServiceOrderNumber__c : '';
                }
                T_MOTION_List.add(temp_t_motion);
            }
        }
        req.T_MOTION = T_MOTION_List;

        List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_ITEM> T_ITEM_List = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_ITEM>();
        for (WorkOrderResult__c work : workOrderResultList) {
            if (work.resultType__c == 'PT') {
                /**
                * T_ITEM
                */
                IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_ITEM T_ITEM = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_ITEM();

                T_ITEM.MATNR    = work.ProductNumber__c != null ? work.ProductNumber__c :'';
                T_ITEM.CAUSE    = work.IsCause__c == true ? '4' : '';
                T_ITEM.MENGE    = work.Quantity__c != null ? String.valueOf(work.Quantity__c) : '';
                T_ITEM.ZSUPPLY  = '01';

                T_ITEM.KUNNR    = '1';
                T_ITEM.LIFNR    = '1';
                T_ITEM.MEINS    = '1';
                T_ITEM.VSBED    = '1';
                
                T_ITEM_List.add(T_ITEM);
            }
        }
        req.T_ITEM = T_ITEM_List;

        List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP> t_TMP_List = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP>();
        List<Map<String, Object>> testReturn = getConvertFile(convertVersionIdList);

        System.debug('test file convert ::: ' + JSON.serialize(testReturn));

        for (Map<String, Object> fileMap : testReturn) {
            IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP tmpRecord = new IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP();
            
            tmpRecord.FILENAME = (String) fileMap.get('FILENAME') != null ? (String) fileMap.get('FILENAME')  : '';
            tmpRecord.IF_DESC  = (String) fileMap.get('IF_DESC') != null ? (String) fileMap.get('IF_DESC')  : '';
            tmpRecord.EVISEQX  = (String) fileMap.get('EVISEQX') != null ? (String) fileMap.get('EVISEQX')  : '';
            tmpRecord.FILE_SIZE = (String) fileMap.get('FILESIZE') != null ? (String) fileMap.get('FILESIZE')  : '';
            tmpRecord.LINE     = (String) fileMap.get('FILE_DATA') != null ? (String) fileMap.get('FILE_DATA')  : '';
            
            t_TMP_List.add(tmpRecord);
        }

        req.T_TMP = t_TMP_List;

        IF_ERP_Service_Report instance = new IF_ERP_Service_Report();
        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res resParam = instance.IF_SERVICE_049(req);
        
        System.debug('Response 049 ::: '+JSON.serialize(resParam));

            if (isConfirmed) {
                WorkOrder wo = new WorkOrder();
                datetime myDateTime = datetime.now();
                wo.Id                = recordId;
                wo.ConfirmedDate__c  = myDateTime;
                wo.Status            = 'Confirm';
                if (resParam.O_RETURN.TYPE == 'S') {
                    wo.ServiceOrderNumber__c    = resParam.O_AUFNR_F != null ? resParam.O_AUFNR_F.substring(3) : '';
                    wo.Noti_Number__c           = resParam.O_QMNUM_F != null ? resParam.O_QMNUM_F.substring(3) : '';
                }
                update wo;
            }
            
        return resParam;
    }

    /**
    * @description Callout 전 ContentVersion 레코드 별 데이터 변환
    **/
    public static List<Map<String, Object>> getConvertFile (List<String> convertVersionIdList){
        try {
            system.debug('convertVersionIdList ::: '+convertVersionIdList);

            List<Map<String, Object>> fileTable = new List<Map<String, Object>>();
    
            Map<String, List<ContentVersion>> contentMap = new Map<String, List<ContentVersion>>();

            List<ContentVersion> cvList = [
                SELECT Id, ContentDocumentId, Title, VersionNumber, ContentSize, FileExtension, VersionData, DealerPotalFileType__c
                FROM ContentVersion
                WHERE Id IN :convertVersionIdList
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


                            Map<String, Object> fileMap = new Map<String, Object>();
                            fileMap.put('INT_NO', String.valueOf(convertVersionIdList.indexOf(id) + 1));
                            fileMap.put('DOCU_ITEM', '0000' + String.valueOf(filePartIndex) + '0');
                            fileMap.put('FILE_ID', cv.Id);            
                            fileMap.put('IF_DESC', EncodingUtil.urlEncode(cv.Title, 'UTF-8'));
                            fileMap.put('FILENAME', EncodingUtil.urlEncode(cv.Title, 'UTF-8'));
                            fileMap.put('DESCRIPTION', URL.getOrgDomainURL().toExternalForm()); 
                            fileMap.put('EVISEQX', String.valueOf(filePartIndex));
                            fileMap.put('FILETYPE', cv.DealerPotalFileType__c);
                
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
}