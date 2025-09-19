const labels = {
    // [MSG]
    DNS_M_GeneralError : DNS_M_GeneralError // Error Occurred, 오류가 발생했습니다
    , DNS_M_Success : DNS_M_Success // Success, 성공
    , DNS_M_PreparationCheckSaved : DNS_M_PreparationCheckSaved // The preparation checklist has been saved., 사전설치 점검표가 저장되었습니다.
    , DNS_M_PreparationCreationError : DNS_M_PreparationCreationError // Preparation Checklist creation is only allowed when the order status is 'Order Mapped'.
    , DNS_M_PreparationEditError : DNS_M_PreparationEditError // The Preparation Checklist can only be edited when the ticket status is 'New' or 'Reject'.
    , DNS_M_PreparationTicketCreation : DNS_M_PreparationTicketCreation // The ticket has been successfully created., 티켓이 성공적으로 생성되었습니다.
    , DNS_M_QuoteLineItemEdited : DNS_M_QuoteLineItemEdited // The Quote line item(s) has been edited., 견적 제품이 수정되었습니다.
    , DNS_M_QuoteCreate : DNS_M_QuoteCreate // Quotes can only be generated in Qualified steps., Qualified 단계에서만 견적을 생성할 수 있습니다.
    , DNS_M_QuoteAutoName : DNS_M_QuoteAutoName // The quotation name is generated automatically. / 견적명은 자동 생성 됩니다.


    // [TITLE]
    , DNS_T_SearchAccount : DNS_T_SearchAccount // Search Account, 고객조회
    , DNS_T_ProductRequest : DNS_T_ProductRequest // Product Request, 부품청구
    , DNS_H_SendCS : DNS_H_SendCS // Send CS, CS 전송

    // [SECTION]  
    , DNS_S_ProductRequest : DNS_S_ProductRequest // Product Request, 부품청구
    , DNS_S_ServiceHistory : DNS_S_ServiceHistory // Service History, 서비스접수이력
    , DNS_S_PendingServiceHistory : DNS_S_PendingServiceHistory // Pending Service History, 미결접수이력
    , DNS_S_ActivityHistory : DNS_S_ActivityHistory // All Activities History, 전체상담이력
    , DNS_S_AllActivitiesHistory : DNS_S_AllActivitiesHistory // Activity History, 상담이력
    , DNS_S_AccountEquipmentList : DNS_S_AccountEquipmentList // Account Equipment List, 고객장비정보
    , DNS_S_SameDefectHistory : DNS_S_SameDefectHistory // Same Failiure History, 동일하자이력
    , DNS_S_TicketList : DNS_S_TicketList // Ticket List, 티켓이력
    , DNS_S_WorkOrderList : DNS_S_WorkOrderList // WorkOrder List, 오더이력
    , DNS_S_PrepararionChecklistInformation : DNS_S_PrepararionChecklistInformation // Prepararion Checklist Information, 사전설치 점검표 정보
    , DNS_S_Description : DNS_S_Description // Description, 비고
    , DNS_S_NewPrepararionChecklist : DNS_S_NewPrepararionChecklist // New Prepararion Checklist, 새 사전설치 점검표
    , DNS_S_EditPreparationChecklist : DNS_S_EditPreparationChecklist // Edit Preparation Checklist, 사전설치 점검표 편집
    
    // [FIELD]
    , DNS_F_Status : DNS_F_Status // Status, 티켓 상태
    , DNS_F_ContactPerson : DNS_F_ContactPerson // Contact Person, 고객사 담당자
    , DNS_F_SalesRep : DNS_F_SalesRep // Sales Rep., 판매자
    , DNS_F_PreparationInspector : DNS_F_PreparationInspector // Preparation Inspector, 준비사항 확인자

    , DNS_F_ClosedReason : DNS_F_ClosedReason // Closed Reason, 
    , DNS_F_Resultofmeasure : DNS_F_Resultofmeasure // Result of measure
    , DNS_F_ClosedReasonDetails: DNS_F_ClosedReasonDetails // Closed Reason Details
    , DNS_F_AssignHoldingReason : DNS_F_AssignHoldingReason // Assign Holding Reason, 
    , DNS_F_AccountName : DNS_F_AccountName // Account Name, 
    , DNS_F_Requester : DNS_F_Requester // Requester, 
    , DNS_F_Internalrequester : DNS_F_Internalrequester // Internal requester, 
    , DNS_F_Phone : DNS_F_Phone // Phone, 
    , DNS_F_NotificationToCustomer : DNS_F_NotificationToCustomer // Notification (To. Customer), 
    , DNS_F_Urgent : DNS_F_Urgent // Urgent,
    , DNS_F_Urgency : DNS_F_Urgency // Urgency,
    , DNS_F_Recurrence : DNS_F_Recurrence // Recurrence,
    , DNS_F_ReceptionDetails : DNS_F_ReceptionDetails // Reception Details,
    , DNS_F_ProgressDetail : DNS_F_ProgressDetail // Progress Detail,
    , DNS_F_Equipment : DNS_F_Equipment // Equipment,
    , DNS_F_ConsultationChannel : DNS_F_ConsultationChannel // Consultation Channel,
    , DNS_F_TicketTypeMajor : DNS_F_TicketTypeMajor // Ticket Type (Major),
    , DNS_F_TicketTypeMiddle : DNS_F_TicketTypeMiddle // Ticket Type (Middle),
    , DNS_F_ReceptionPath : DNS_F_ReceptionPath // Reception Path,
    , DNS_F_DateTimeOpened : DNS_F_DateTimeOpened //Date/Time Opened,
    , DNS_F_DateTimeFailure : DNS_F_DateTimeFailure //Date/Time Failure,
    , DNS_F_OriginTicket : DNS_F_OriginTicket // Origin Ticket,
    , DNS_F_FailureStatus : DNS_F_FailureStatus // Failure Status,
    , DNS_F_SalesOrder : DNS_F_SalesOrder // Sales Order,
    , DNS_F_FailureArea : DNS_F_FailureArea // Failure Area,
    , DNS_F_FailureAreaDetail : DNS_F_FailureAreaDetail // Failure Area(Detail),
    , DNS_F_Failurephenomenon : DNS_F_Failurephenomenon // Failure phenomenon,
    , DNS_F_RequestedVisitDateTime : DNS_F_RequestedVisitDateTime // Requested Visit DateTime,
    , DNS_F_ProgressDelay : DNS_F_ProgressDelay // Progress Delay,
    , DNS_F_ClosedPendingReason : DNS_F_ClosedPendingReason // Closed/Pending Reason,
    , DNS_F_TechnicalReview : DNS_F_TechnicalReview // Technical Review,
    , DNS_F_InstallationDefect : DNS_F_InstallationDefect // Installation Defect,
    , DNS_F_AfterResponsePlan : DNS_F_AfterResponsePlan // After Response Plan,
    , DNS_F_ModelCode : DNS_F_ModelCode // Model Code,
    , DNS_F_InstallationWorkCenter : DNS_F_InstallationWorkCenter // Installation WorkCenter,
    , DNS_F_ProductionSite : DNS_F_ProductionSite // Production Site,
    , DNS_F_NotiNO : DNS_F_NotiNO // Noti NO,
    , DNS_F_OccurrenceClassification : DNS_F_OccurrenceClassification // Occurrence Classification,
    , DNS_F_SVOrdNo : DNS_F_SVOrdNo // SV Ord.No,
    , DNS_F_ReturnItemDelivery : DNS_F_ReturnItemDelivery // Return Item Delivery,
    , DNS_F_LastModifiedBy : DNS_F_LastModifiedBy // Last Modified By,
    , DNS_F_CreatedBy : DNS_F_CreatedBy // Created By,
    , DNS_F_ContactPosition : DNS_F_ContactPosition // Contact Position, 직책
    , DNS_F_SalesDealer : DNS_F_SalesDealer // Sales Dealer, 판매대리점
    , DNS_F_SalesDealerContactPhone : DNS_F_SalesDealerContactPhone // Sales Dealer Contact Phone, 판매담당자 전화
    , DNS_F_TrainingCount : DNS_F_TrainingCount // Training Count, 교육횟수
    , DNS_F_TrainingType : DNS_F_TrainingType // Training Type, 교육종류
    , DNS_F_TraineeLevel : DNS_F_TraineeLevel // Trainee Level, 피교육자 수준
    , DNS_F_TrainingDateTime1 : DNS_F_TrainingDateTime1 // Training Date/Time 1, 교육 일시 1
    , DNS_F_TrainingDateTime2 : DNS_F_TrainingDateTime2 // Training Date/Time 2, 교육 일시 2
    , DNS_F_TrainingDateTime3 : DNS_F_TrainingDateTime3 // Training Date/Time 3, 교육 일시 3
    , DNS_F_ServiceResource : DNS_F_ServiceResource // Service Resource, 작업자

    // [COLUMN]  
    , DNS_C_InspectionDate : DNS_C_InspectionDate // Inspection Date, 점검일자
    , DNS_C_OrderType : DNS_C_OrderType // Order Type, 오더유형
    , DNS_C_OrderStatus : DNS_C_OrderStatus // Order Status, 오더상태
    , DNS_C_OrderNumber : DNS_C_OrderNumber // Order Number, 오더번호
    , DNS_C_Manager : DNS_C_Manager // Manager, 담당자
    , DNS_C_ServiceResource : DNS_C_ServiceResource // Service Resource, 작업자
    , DNS_C_ReceptionDetails : DNS_C_ReceptionDetails // Reception Details, 접수내용
    , DNS_C_ConsultationDetails : DNS_C_ConsultationDetails // Consultation Details, 상담내용
    , DNS_C_InspectionDetails : DNS_C_InspectionDetails // Inspection Details, 점검내용
    , DNS_C_Status : DNS_C_Status // Status, 진행상태
    , DNS_C_DateOfReceipt : DNS_C_DateOfReceipt // Date of Receipt, 접수일자
    , DNS_C_Ticket : DNS_C_Ticket // Ticket, 티켓번호
    , DNS_C_Account : DNS_C_Account // Account, 업체명
    , DNS_C_WorkCenter : DNS_C_WorkCenter // Service W/C, 서비스 W/C
    , DNS_C_Model : DNS_C_Model // Model, 기종
    , DNS_C_SerialNumber : DNS_C_SerialNumber // Serial Number, 호기
    , DNS_C_Phone : DNS_C_Phone // Phone, 전화번호
    , DNS_C_InstallDate : DNS_C_InstallDate // Install Date, 설치일자
    , DNS_C_ActionDetails : DNS_C_ActionDetails // Action Details, 조치수리내용
    , DNS_C_ConsultationDate : DNS_C_ConsultationDate // Consultation Date, 상담일자
    , DNS_C_Consultant : DNS_C_Consultant // Consultant, 상담원
    , DNS_C_Reviser : DNS_C_Reviser // Reviser, 수정자
    , DNS_C_Contact : DNS_C_Contact // Contact, 연락처
    , DNS_C_ContactName : DNS_C_ContactName // Contact, 고객명
    , DNS_C_Equipment : DNS_C_Equipment // Equipment, 장비번호
    , DNS_C_ConsultStartTime : DNS_C_ConsultStartTime // Consultation Start Time, 상담시작시간
    , DNS_C_ConsultEndTime : DNS_C_ConsultEndTime // Consultation Start Time, 상담종료시간
    , DNS_C_ConsultTypeLevel1 : DNS_C_ConsultTypeLevel1 // Consultation Type(Major), 상담유형(대)
    , DNS_C_ConsultTypeLevel2 : DNS_C_ConsultTypeLevel2 // Consultation Type(Middle), 상담유형(중)
    , DNS_C_ConsultationChannel : DNS_C_ConsultationChannel // Consultation Channel, 상담채널
    , DNS_C_PartsName : DNS_C_PartsName // PartsName, 부품명
    , DNS_C_PartsProcessStatus : DNS_C_PartsProcessStatus // PartsProcessStatus, 부품 진행 상태
    , DNS_C_PartsCode : DNS_C_PartsCode // PartsCode, 부품코드
    , DNS_C_Stock : DNS_C_Stock // Stock, 재고
    , DNS_C_Quantity : DNS_C_Quantity // Quantity, 수량
    , DNS_C_EndDateOfVisit : DNS_C_EndDateOfVisit // End Date of Visit, 방문 종료일
    , DNS_C_StartDateOfVisit : DNS_C_StartDateOfVisit // Start Date of Visit, 방문 시작일
    , DNS_C_RecordType : DNS_C_RecordType // Record Type, 레코드 유형
    , DNS_C_InspectionName : DNS_C_InspectionName // Inspection Name, 입회검사명 
    , DNS_C_Item : DNS_C_Item // Item, 항목
    , DNS_C_PreparationBeforeInstallation : DNS_C_PreparationBeforeInstallation // Customer Preparation Before Installation, 설치시운전 고객사 준비사항
    , DNS_C_PlannedDate : DNS_C_PlannedDate // Planned Date, 예정일
    , DNS_C_CompletionDate : DNS_C_CompletionDate // Completion Date, 완료일
    , DNS_C_QuoteExpirationDate : DNS_C_QuoteExpirationDate // ExpirationDate, 만료일
    , DNS_C_QuoteName : DNS_C_QuoteName // QuoteName, 견적서 이름
    , DNS_M_VersionCnt : DNS_M_VersionCnt // Quote Version
    , DNS_C_QuoteNumber : DNS_C_QuoteNumber // QuoteNumber, 견적서 번호
    , DNS_C_PreparationChecklist : DNS_C_PreparationChecklist // Preparation Checklist, 사전설치 점검표
    , DNS_C_ProductRequestProductCode : DNS_C_ProductRequestProductCode // 부품청구 Product, 품번
    , DNS_C_ProductRequestStatus : DNS_C_ProductRequestStatus // 부품청구 Status, 부품청구상태
    , DNS_C_ProductRequestSequence : DNS_C_ProductRequestSequence // 부품청구 Sequence, 순번
    , DNS_C_ProductRequestProduct : DNS_C_ProductRequestProduct // 부품청구 Product, 품명
    , DNS_C_ProductRequestQuantity : DNS_C_ProductRequestQuantity // 부품청구 Quantity, 수량
    , DNS_C_ProductRequestInventory : DNS_C_ProductRequestInventory // 부품청구 Inventory, 재고
    , DNS_C_ProductRequestReturnStatus : DNS_C_ProductRequestReturnStatus // 부품청구 ReturnStatus, 반납여부
    , DNS_C_ProductRequestTransportsDivision : DNS_C_ProductRequestTransportsDivision // 부품청구 TransportsDivision, 탁송구분
    , DNS_C_ProductRequestShipTo : DNS_C_ProductRequestShipTo // 부품청구 ShipTo, 배송처
    , DNS_C_ProductRequestWorkCenter : DNS_C_ProductRequestWorkCenter // 부품청구 WorkCenter, 대리점명
    , DNS_C_LocationMap : DNS_C_LocationMap // Location Map, 약도
    , DNS_C_Weight : DNS_C_Weight // Weight, 무게
    , DNS_C_OnSiteDate : DNS_C_OnSiteDate // Onsite Date, 출동일자
    , DNS_C_ProgressDetail : DNS_C_ProgressDetail // Progress Detail, 진행사항
    , DNS_C_Inspection : DNS_C_Inspection // Inspection, 입회검사
    
    // [BUTTON]
    , DNS_B_Approval : DNS_B_Approval // Approval, 승인
    , DNS_B_Save : DNS_B_Save // Save, 저장
    , DNS_B_New : DNS_B_New // New, 새로 만들기
    , DNS_B_Edit : DNS_B_Edit // Edit, 편집
    , DNS_B_Cancel : DNS_B_Cancel // Cancel, 취소
    , DNS_B_ViewAll : DNS_B_ViewAll // View All, 모두 보기
    , DNS_B_Search : DNS_B_Search // Search, 조회
    , DNS_B_ProductRequestEdit : DNS_B_ProductRequestEdit // 부품청구 Edit, 수정
    , DNS_B_ProductRequestSave : DNS_B_ProductRequestSave // 부품청구 Save, 저장
    , DNS_B_Next : DNS_B_Next // 다음

    //[MOBILE] 밑에 import 곡 하세요
    , DNS_FSL_IndirectApplication : DNS_FSL_IndirectApplication // Indirect Application, 간접접수
    , DNS_FSL_Account : DNS_FSL_Account // Account, 업체명
    , DNS_FSL_Equipment : DNS_FSL_Equipment // Equipment, 장비
    , DNS_FSL_Contact : DNS_FSL_Contact // Contact, 담당자
    , DNS_FSL_Dispatched : DNS_FSL_Dispatched // Dispatched, 출동여부
    , DNS_FSL_Completed : DNS_FSL_Completed // Completed, 완료여부
    , DNS_FSL_CompleteInput : DNS_FSL_CompleteInput // Complete Input, 입력 완료
    , DNS_FSL_PleaseEnterInformation : DNS_FSL_PleaseEnterInformation // Please Enter Information, 정보를 입력해 주세요.
    , DNS_FSL_Dispatch : DNS_FSL_Dispatch // Dispatch, 출동
    , DNS_FSL_NotDispatched : DNS_FSL_NotDispatched // Not Dispatched, 미출동
    , DNS_FSL_Complete : DNS_FSL_Complete // Complete, 완료
    , DNS_FSL_Incomplete : DNS_FSL_Incomplete // Incomplete, 미완료
    , DNS_FSL_NoAnnouncement : DNS_FSL_NoAnnouncement // There are currently no announcements., 현재 공지사항이 없습니다.
    , DNS_FSL_Back : DNS_FSL_Back // Back, 뒤로가기
    , DNS_FSL_Attachment : DNS_FSL_Attachment // Attachment, 첨부파일
    , DNS_FSL_NoFilesAttached : DNS_FSL_NoFilesAttached // No files are attached., 첨부된 파일이 없습니다.
    , DNS_FSL_SetDepartureTime : DNS_FSL_SetDepartureTime // Set Departure Time, 출발 시간 설정
    , DNS_FSL_DoWantDepartureTime : DNS_FSL_DoWantDepartureTime // Do you want to register your departure time in the current time?, 현재 시간으로 출발 시간을 등록하시겠습니까?
    , DNS_FSL_Cancel : DNS_FSL_Cancel // Cancel, 취소
    , DNS_FSL_Check : DNS_FSL_Check // Check, 확인
    , DNS_FSL_DepartureReportCompleted : DNS_FSL_DepartureReportCompleted // Departure report completed, 출발 보고 완료
    , DNS_FSL_DepartureReportingComplete : DNS_FSL_DepartureReportingComplete // Departure reporting is complete., 출발 보고가 완료되었습니다.
    , DNS_FSL_SetArrivalTime : DNS_FSL_SetArrivalTime // Set Arrival Time, 도착 시간 설정
    , DNS_FSL_DoWantArrivalTime : DNS_FSL_DoWantArrivalTime // Do you want to register the arrival time in the current time?, 현재 시간으로 도착 시간을 등록하시겠습니까?
    , DNS_FSL_ArrivalReportCompleted : DNS_FSL_ArrivalReportCompleted // Arrival report completed, 도착 보고 완료
    , DNS_FSL_ArrivalReportingComplete : DNS_FSL_ArrivalReportingComplete // Arrival report has been completed, 출발 보고가 완료되었습니다.
    , DNS_FSL_PleaseSelectStatus : DNS_FSL_PleaseSelectStatus // Please select a status., 상태를 선택해주세요.
    , DNS_FSL_Save : DNS_FSL_Save // Save, 저장
    , DNS_FSL_Close : DNS_FSL_Close // Close, Close
    , DNS_FSL_StatusChangeComplete : DNS_FSL_StatusChangeComplete // The status change is complete., 상태변경이 완료되었습니다.
    , DNS_FSL_PendingProcessing : DNS_FSL_PendingProcessing // Pending processing, 미결처리
    , DNS_FSL_PendingReasonChoice : DNS_FSL_PendingReasonChoice // Pending Reason Choice, 미결사유를 선택해주세요.
    , DNS_FSL_PendingMSG : DNS_FSL_PendingMSG // If none of the reasons apply, please select "Other" and enter the reason for the delay., 해당하는 사유가 없을 경우, [기타] 선택 후 미결사유를 입력해 주세요.
    , DNS_FSL_Alarm : DNS_FSL_Alarm // Alarm, 알림
    , DNS_FSL_PendingProcessingCompleted : DNS_FSL_PendingProcessingCompleted // Pending Processing is Completed., 미결처리가 완료되었습니다.
    , DNS_FSL_AssignmentRejectionReason : DNS_FSL_AssignmentRejectionReason //	Select Assignment Rejection Reason., 미결처리가 완료되었습니다.
    , DNS_FSL_AssignmentRejectionSave : DNS_FSL_AssignmentRejectionSave //	Assignment Rejection Save, 배정거절 저장
    , DNS_FSL_AssignmentRejectionReasonSave : DNS_FSL_AssignmentRejectionReasonSave //	The reason for assignment rejection has been successfully saved., 배정거절사유가 성공적으로 저장되었습니다.
    , DNS_FSL_Parts : DNS_FSL_Parts //	Parts, 부품
    , DNS_FSL_Closing : DNS_FSL_Closing //	Closing, 종결
    , DNS_FSL_Customer : DNS_FSL_Customer //	Customer, 고객
    , DNS_FSL_NeedMorePerson : DNS_FSL_NeedMorePerson //	Need More Person, 인원
    , DNS_FSL_Installation : DNS_FSL_Installation //	Installation, 설치
    , DNS_FSL_TechnicalReview : DNS_FSL_TechnicalReview //	Technical Review, 기술검토
    , DNS_FSL_TechnicalDesign : DNS_FSL_TechnicalDesign //	Technical Design, 기술설계
    , DNS_FSL_TechnicalCustomer : DNS_FSL_TechnicalCustomer //	Technical Customer, 기술고객
    , DNS_FSL_TechnicalPersonnel : DNS_FSL_TechnicalPersonnel //	Technical Personnel, 기술인원
    , DNS_FSL_TechnicalParts : DNS_FSL_TechnicalParts //	Technical Parts, 기술부품
    , DNS_FSL_ResultNotEntered : DNS_FSL_ResultNotEntered //	Result not entered, 결과미입력
    , DNS_FSL_etc : DNS_FSL_etc // ETC, 기타
    , DNS_FSL_DispatchImpossible : DNS_FSL_DispatchImpossible // Dispatch Impossible, 출동불가
    , DNS_FSL_DispatchDelay : DNS_FSL_DispatchDelay // Dispatch Delay, 출동지연
    , DNS_FSL_TechnicalShortage : DNS_FSL_TechnicalShortage // Technical Shortage, 기술부족
    , DNS_FSL_PartsNeeded : DNS_FSL_PartsNeeded // Parts Needed, 부품필요
    , DNS_FSL_Wait : DNS_FSL_Wait // Wait, 대기
    , DNS_FSL_Education : DNS_FSL_Education // Education, 교육
    , DNS_FSL_Meeting : DNS_FSL_Meeting // Meeting, 회의
    , DNS_FSL_Work : DNS_FSL_Work // Work, 작업
    , DNS_FSL_SelfWork : DNS_FSL_SelfWork // Self-Work, 자체작업
    , DNS_FSL_AssignmentRejectionReasonFail : DNS_FSL_AssignmentRejectionReasonFail // Only the main worker for the dispatch can reject the assignment., 해당 출동의 메인작업자만 배정거절을 진행할 수 있습니다.
    , DNS_FSL_Replacement : DNS_FSL_Replacement // Replacement, 대체품
    , DNS_FSL_Material : DNS_FSL_Material // Material, 재질
    , DNS_FSL_ProductNumber : DNS_FSL_ProductNumber // Product Number, 품번
    , DNS_FSL_State : DNS_FSL_State // State, 상태
    , DNS_FSL_Stock : DNS_FSL_Stock // Stock, 재고
    , DNS_FSL_Quantity : DNS_FSL_Quantity // Quantity, 수량
    , DNS_FSL_Standard : DNS_FSL_Standard // Standard, 규격
    , DNS_FSL_Unit : DNS_FSL_Unit // Unit, 단위
    , DNS_FSL_Weight : DNS_FSL_Weight // Weight, 중량
    , DNS_FSL_WeightUnit : DNS_FSL_WeightUnit // Weight Unit, 중량단위
    , DNS_FSL_DeliveryPackaging : DNS_FSL_DeliveryPackaging // Delivery Packaging, 납품포장
    , DNS_FSL_Add : DNS_FSL_Add // Add, 추가
    , DNS_FSL_ThePartRequestHasBeenCompleted : DNS_FSL_ThePartRequestHasBeenCompleted // The part request has been completed., 부품 요청이 완료되었습니다.
    , DNS_FSL_ConfirmationOfPartAddition : DNS_FSL_ConfirmationOfPartAddition // Confirmation of Part Addition, 부품 추가 확인
    , DNS_FSL_PleaseCheckQuantity : DNS_FSL_PleaseCheckQuantity // Please check if the quantity you entered is correct., 입력한 수량이 맞는지 확인해 주세요.
    , DNS_FSL_Dot : DNS_FSL_Dot // ., 개
    , DNS_FSL_AddParts : DNS_FSL_AddParts // + Add Parts, + 부품추가
    , DNS_FSL_ProductName : DNS_FSL_ProductName // Product Name, 품명
    , DNS_FSL_BillingPartsList : DNS_FSL_BillingPartsList // Billing Parts List, 청구부품 목록
    , DNS_FSL_CancellationOfRequest : DNS_FSL_CancellationOfRequest // Cancellation of Request, 요청 취소
    , DNS_FSL_CancellationOfRequestIsOnlyPossibleBeforeApproval : DNS_FSL_CancellationOfRequestIsOnlyPossibleBeforeApproval // Cancellation of request is only possible before approval., 요청 취소는 승인 전까지만 가능합니다.
    , DNS_FSL_PleaseEnterTheQuantity : DNS_FSL_PleaseEnterTheQuantity // Please enter the quantity., 수량을 입력해 주세요.
    , DNS_FSL_ThereAreNoLookupResults : DNS_FSL_ThereAreNoLookupResults // There are no lookup results., 조회 결과가 없습니다.
    , DNS_FSL_ThereAreCurrentlyNoRequestedParts : DNS_FSL_ThereAreCurrentlyNoRequestedParts // There are currently no requested parts., 현재 청구된 부품이 없습니다.
    , DNS_FSL_InventoryCheck : DNS_FSL_InventoryCheck // Inventory Check, 재고조회
    , DNS_FSL_DepartureSuccessSave : DNS_FSL_DepartureSuccessSave // The departure time was successfully saved., 출발 시간이 성공적으로 저장되었습니다.
    , DNS_FSL_DepartureCannotSave : DNS_FSL_DepartureCannotSave // The departure time has already been saved and cannot be modified., 출발 시간이 이미 저장되어 수정 불가능합니다.
    , DNS_FSL_ArrivalSuccessSave : DNS_FSL_ArrivalSuccessSave // The Arrival time was successfully saved., 도착 시간이 성공적으로 저장되었습니다.
    , DNS_FSL_ArrivalCannotSave : DNS_FSL_ArrivalCannotSave // The Arrival time has already been saved and cannot be modified., 도착 시간이 이미 저장되어 수정 불가능합니다.
    , DNS_FSL_InputSuccessSaved : DNS_FSL_InputSuccessSaved // Ticket submission is complete., Ticket 접수가 완료되었습니다.
    , DNS_FSL_ErrorOccurred : DNS_FSL_ErrorOccurred // An error occurred:, 오류가 발생했습니다:
    , DNS_FSL_Error : DNS_FSL_Error // Error, 오류
    , DNS_FSL_PendingProcessingNotPossible : DNS_FSL_PendingProcessingNotPossible // Pending processing is not possible. There is already a pending reason., 미결처리를 할 수 없습니다. 이미 미결 사유가 있습니다.
    , DNS_FSL_CancelRequest : DNS_FSL_CancelRequest // Want to cancel the parts request?, 부품요청을 취소하시겠습니까?
    , DNS_FSL_ConfirmRequestCancellation : DNS_FSL_ConfirmRequestCancellation // Confirm request cancellation, 요청취소 확인
    , DNS_FSL_AssignmentRejectionCompleted : DNS_FSL_AssignmentRejectionCompleted // Assignment rejection has been completed., 배정거절이 완료되었습니다.
    , DNS_FSL_PossibleAssignedStatus : DNS_FSL_PossibleAssignedStatus // Refusal of assignment is possible only when the Service Order is in assigned status., 배정거절은 WorkOrder가 배정 상태일 때만 가능합니다.
    , DNS_FSL_SalesPriceBeforeReplacement : DNS_FSL_SalesPriceBeforeReplacement // Sales Price Before Replacement, 대체전 판매가
    , DNS_FSL_SalesPriceReplacement : DNS_FSL_SalesPriceReplacement // Sales Price Replacement, 대체품 판매가
    , DNS_FSL_StockQuantity : DNS_FSL_StockQuantity // Stock Quantity, 재고 수량
    , DNS_FSL_DealerStock : DNS_FSL_DealerStock // Dealer Stock, 대리점 재고
    , DNS_FSL_OutStock : DNS_FSL_OutStock // Out of Stock., 재고가 없습니다.
    , DNS_FSL_CurrentStock : DNS_FSL_CurrentStock // Current Stock, 현재고
    , DNS_FSL_AvailableStock : DNS_FSL_AvailableStock // Available Stock, 가용재고
    , DNS_FSL_OrderReservationStock : DNS_FSL_OrderReservationStock // Order Reservation Stock, 주문예약재고
    , DNS_FSL_NoProductName : DNS_FSL_NoProductName // No Product Name, 품명이 없습니다.
    , DNS_FSL_NoProductNumber : DNS_FSL_NoProductNumber // No Product Number, 품번이 없습니다.
    , DNS_FSL_NoState : DNS_FSL_NoState // No State, 상태가 없습니다.
    , DNS_FSL_NoQuantity : DNS_FSL_NoQuantity // No Quantity, 수량이 없습니다.
    , DNS_FSL_New : DNS_FSL_New // New, 신규
    , DNS_FSL_EnterLeastThreeCharacters : DNS_FSL_EnterLeastThreeCharacters // You must enter at least three characters in your search keyword., 검색 키워드를 최소 세 글자 이상 입력해야 됩니다.
    , DNS_FSL_PartRequested : DNS_FSL_PartRequested // The part was Requested., 부품이 청구되었습니다.
    , DNS_FSL_PleaseEnterQuantity : DNS_FSL_PleaseEnterQuantity // Please enter a Quantity., 수량을 입력해주세요.
    , DNS_FSL_PartrequestCanceled : DNS_FSL_PartrequestCanceled // The part request was canceled., 부품 요청이 취소되었습니다.
    , DNS_FSL_AlreadyDeleted : DNS_FSL_AlreadyDeleted // It has already been deleted., 이미 삭제된 상태입니다.
    , DNS_FSL_PerformanceDueDate : DNS_FSL_PerformanceDueDate // Average Performance Due Date, 평균실적납기일
    , DNS_FSL_ChangedSupplyDate : DNS_FSL_ChangedSupplyDate // Changed Supply Date, 변경공급예정일
    , DNS_FSL_SubmitDate : DNS_FSL_SubmitDate // Submit Date, 불츌일
    , DNS_FSL_ServiceType : DNS_FSL_ServiceType // Service Type, 서비스유형
    , DNS_FSL_RequestDate : DNS_FSL_RequestDate // Request Date, 요청일자
    , DNS_FSL_ReceptionDetail : DNS_FSL_ReceptionDetail // Reception Detail, 접수내역
    , DNS_FSL_RepairDetail : DNS_FSL_RepairDetail // Repair Detail, 조치내역
    , DNS_FSL_ViewDetail : DNS_FSL_ViewDetail // View Detail, 상세보기
    , DNS_FSL_CustomerAppointmentTimeSetting : DNS_FSL_CustomerAppointmentTimeSetting // Customer Appointment Time Setting, 고객약속시간 설정
    , DNS_FSL_CustomerAppointmentTimeSettingComplete : DNS_FSL_CustomerAppointmentTimeSettingComplete // Customer Appointment Time Setting Complete, 고객약속시간 설정 완료
    , DNS_FSL_RegisterCustomerTimeSetTime : DNS_FSL_RegisterCustomerTimeSetTime // Do you want to register a customer appointment time with a set time?, 설정한 시간으로 고객약속시간을 등록하시겠습니까?
    , DNS_FSL_CustomerTimeregisteredSetTime : DNS_FSL_CustomerTimeregisteredSetTime // The Customer Appointment time has been registered at the set time., 설정한 시간으로 고객약속시간이 등록되었습니다.
    , DNS_FSL_CustomerAppointmentSuccessfullySave : DNS_FSL_CustomerAppointmentSuccessfullySave // The Customer appointment was successfully save., 고객약속시간이 성공적으로 저장되었습니다.
    , DNS_FSL_EnteredAfterCurrentTime : DNS_FSL_EnteredAfterCurrentTime // Customer appointment time can only be entered after the current time., 고객약속시간은 현재 시간 이후 시간만 입력 가능합니다.
    , DNS_FSL_PendingDetail : DNS_FSL_PendingDetail // Pending Detail, 미결내용
    , DNS_FSL_DispatchCompleted : DNS_FSL_DispatchCompleted // This is a dispatch reservation that has been completed., 완료처리가 진행된 출동예약입니다.
    , DNS_FSL_DispatchCanceled : DNS_FSL_DispatchCanceled // This is a dispatch reservation that has been Canceled., 삭제된 오더입니다.
    , DNS_FSL_DispatchConfirm : DNS_FSL_DispatchConfirm // This is a dispatch reservation that has been Confirmed., 이미 확정된 오더입니다.
    , DNS_FSL_SavingValue : DNS_FSL_SavingValue // An error occurred while saving the value., 값 저장 중 오류가 발생했습니다.
    , DNS_FSL_EnterPendingDetail : DNS_FSL_EnterPendingDetail // Please enter pending detail., 미결내용을 입력해주세요.
    , DNS_FSL_SetComplete : DNS_FSL_SetComplete // Set Complete, 완료 설정
    , DNS_FSL_PleaseEnterValuesComplete : DNS_FSL_PleaseEnterValuesComplete // Please enter values ​​to complete., 완료 보고를 위해 값을 입력해주세요.
    , DNS_FSL_FailureAreaMajor : DNS_FSL_FailureAreaMajor // Failure Area (Major), 고장부위(대)
    , DNS_FSL_SelectFailureAreaMajor : DNS_FSL_SelectFailureAreaMajor // Select the Failure Area (Major)., 고장부위(대)를 선택하세요.
    , DNS_FSL_FailureAreaMiddle : DNS_FSL_FailureAreaMiddle // Failure Area (Middle), 고장부위(중)
    , DNS_FSL_SelectFailureAreaMiddle : DNS_FSL_SelectFailureAreaMiddle // Select the Failure Area (Middle), 고장부위(중)을 선택하세요.
    , DNS_FSL_FailurePhenomenon : DNS_FSL_FailurePhenomenon // Failure Phenomenon, 고장현상
    , DNS_FSL_SelectFailurePhenomenon : DNS_FSL_SelectFailurePhenomenon // Select the Failure Phenomenon, 고장현상을 선택하세요.
    , DNS_FSL_FailurePhenomenonDetail : DNS_FSL_FailurePhenomenonDetail // Failure Phenomenon Detail, 고장부위/현상 상세
    , DNS_FSL_FailureCause : DNS_FSL_FailureCause // Failure Cause, 고장원인
    , DNS_FSL_SelectFailureCause : DNS_FSL_SelectFailureCause // Select the Failure Cause, 고장원인을 선택하세요.
    , DNS_FSL_FailureCauseDetail : DNS_FSL_FailureCauseDetail // Failure Cause Detail, 고장원인 상세
    , DNS_FSL_RepairAction : DNS_FSL_RepairAction // Repair Action, 조치내역
    , DNS_FSL_SelectRepairAction : DNS_FSL_SelectRepairAction // Select the Repair Action, 조치내역을 선택하세요.
    , DNS_FSL_SuccessfulComplete : DNS_FSL_SuccessfulComplete // Successful Complete, 완료 보고 완료
    , DNS_FSL_CompleteSuccessful : DNS_FSL_CompleteSuccessful // The Complete was Successful., 완료 보고가 완료되었습니다.
    , DNS_FSL_OrderTypeNotSupport : DNS_FSL_OrderTypeNotSupport // This is an order type that does not support completion input. Completed processing has been completed., 완료 입력을 지원하지 않는 오더유형입니다. 완료처리가 완료되었습니다.
    , DNS_FSL_DispatchPendingProcessed : DNS_FSL_DispatchPendingProcessed // This is a dispatch reservation that has been pending processed., 미결처리가 진행된 출동예약입니다.
    , DNS_FSL_UploadFile : DNS_FSL_UploadFile // Upload File, 파일 업로드
    , DNS_FSL_SelectedFile : DNS_FSL_SelectedFile // Selected File, 선택된 파일
    , DNS_FSL_CaseFileUploadComplete : DNS_FSL_CaseFileUploadComplete // The case and file upload is complete., Case와 파일 업로드가 완료되었습니다.
    , DNS_FSL_InputWorkResult : DNS_FSL_InputWorkResult // Input Work Result, 작업결과 입력
    , DNS_FSL_SelectInputWorkResult : DNS_FSL_SelectInputWorkResult // Select the Input Work Result, 작업결과 값을 입력해주세요.
    , DNS_FSL_SuccessfulInputWorkResult : DNS_FSL_SuccessfulInputWorkResult // Successful Input Work Result, 작업결과 입력 완료
    , DNS_FSL_InputWorkResultSuccessful : DNS_FSL_InputWorkResultSuccessful // The Input Work Result was Successful., 작업결과 입력 완료되었습니다.
    , DNS_FSL_OrderTypeNotSupportInputWorkResult : DNS_FSL_OrderTypeNotSupportInputWorkResult // This is an order type that does not support input work result. , 작업결과 입력을 지원하지 않는 오더유형입니다.
    , DNS_FSL_AlreadyConfirmed : DNS_FSL_AlreadyConfirmed // This is a dispatch reservation that has already been confirmed. It is not possible to input work results., 이미 Confirm 처리된 출동 예약입니다. 작업결과입력이 불가능합니다.
    , DNS_FSL_InputWorkResultsCompleted : DNS_FSL_InputWorkResultsCompleted // Input work results has been completed., 작업결과 입력이 완료되었습니다.
    
    , DNS_FSL_Announcement : DNS_FSL_Announcement // Announcement, 공지사항
    , DNS_FSL_ByName : DNS_FSL_ByName // By Name, 이름순
    , DNS_FSL_ByDate : DNS_FSL_ByDate // By Date, 최신순
    , DNS_FSL_Writer : DNS_FSL_Writer // Writer, 작성자
    , DNS_FSL_CreateQnA : DNS_FSL_CreateQnA // Create Q&A, Q & A 생성
    , DNS_FSL_QnATitle : DNS_FSL_QnATitle // Q&A Title, Q&A 제목
    , DNS_FSL_PostingDate : DNS_FSL_PostingDate // Posting Date, 등록일
    , DNS_FSL_QuestionContent : DNS_FSL_QuestionContent // Question content, 질문
    , DNS_FSL_Create : DNS_FSL_Create // Create, 생성
    , DNS_FSL_IntegratedBulletinBoard : DNS_FSL_IntegratedBulletinBoard // Integrated Bulletin Board, 통합 게시판
    , DNS_FSL_Content : DNS_FSL_Content // Content, 내용
    , DNS_FSL_QnACreated : DNS_FSL_QnACreated // Q&A has been created., Q&A가 생성되었습니다.
    , DNS_FSL_QnACreateFailed : DNS_FSL_QnACreateFailed // Q&A creation failed., Q&A 생성에 실패했습니다.
    , DNS_FSL_NoFilesDownload : DNS_FSL_NoFilesDownload // There are no files to download., 다운로드할 파일이 없습니다.
    , DNS_FSL_Respondent : DNS_FSL_Respondent // Respondent, 답변자
    , DNS_FSL_AnswerContent : DNS_FSL_AnswerContent // Answer content, 답변
    , DNS_FSL_NoDepartureTime : DNS_FSL_NoDepartureTime // There is no departure time. Please complete the departure, 출발시간이 없습니다. 출발보고를 완료해 주세요.
    , DNS_FSL_ExistingAppointmentTime : DNS_FSL_ExistingAppointmentTime // An existing registered time exists. Do you want to edit your appointment time?, 기존에 등록한 시간이 존재합니다. 고객약속시간을 수정하시겠습니까?
    , DNS_FSL_TicketCanceled : DNS_FSL_TicketCanceled // Tickets that have already been canceled., 이미 취소된 Ticket입니다.
    , DNS_FSL_PreDayMissingPending : DNS_FSL_PreDayMissingPending // 전날 미결을 누르지 않았습니다.
    , DNS_FSL_PreDayMissingArrAndPending : DNS_FSL_PreDayMissingArrAndPending // 전날 도착 및 미결을 누르지 않았습니다.
    , DNS_FSL_Okay : DNS_FSL_Okay // OK, 확인
    , DNS_FSL_Holiday : DNS_FSL_Holiday // Holiday, 휴가

    // 필드하자관리
    , DNS_FDM_ReceptionDetail_Section : DNS_FDM_ReceptionDetail_Section // Reception Detail, 접수내용
    , DNS_FDM_OrderStatus_Section : DNS_FDM_OrderStatus_Section // Order Status, 오더현황
    , DNS_FDM_PendingManagement_Section : DNS_FDM_PendingManagement_Section // Pending Management, 미결관리
    , DNS_FDM_Cooperation_Section : DNS_FDM_Cooperation_Section // Cooperation, 협조부서
    , DNS_FDM_DispatchPlan_Section : DNS_FDM_DispatchPlan_Section // Dispatch Plan, 출동계획
    , DNS_FDM_Consultant : DNS_FDM_Consultant // Consultant, 상담원
    , DNS_FDM_Requester : DNS_FDM_Requester // Requester, 신청자
    , DNS_FDM_Urgency : DNS_FDM_Urgency // Urgency, 긴급/독촉
    , DNS_FDM_Severity : DNS_FDM_Severity // Severity, 심각도
    , DNS_FDM_Branch : DNS_FDM_Branch // Branch, 지사
    , DNS_FDM_Dispatcher : DNS_FDM_Dispatcher // Dispatcher, 출동자
    , DNS_FDM_RequesterPhone : DNS_FDM_RequesterPhone // Requester Phone, 연락처
    , DNS_FDM_WorkerPhone : DNS_FDM_WorkerPhone // Worker Phone, 연락처
    , DNS_FDM_DefectType : DNS_FDM_DefectType // Defect Type, 하자유형
    , DNS_FDM_Installer : DNS_FDM_Installer // Installer, 설치자
    , DNS_FDM_InstallFinishDate : DNS_FDM_InstallFinishDate // Install Finish Date, 설치완료일
    , DNS_FDM_PendingProcessing : DNS_FDM_PendingProcessing // Pending Processing, 종결미결원인
    , DNS_FDM_Reservation : DNS_FDM_Reservation // Reservation, 예약상태
    , DNS_FDM_LastArrivalDate : DNS_FDM_LastArrivalDate // Last Arrival Date, 최종도착일시
    , DNS_FDM_Dealer : DNS_FDM_Dealer // Dealer, 판매대리점
    , DNS_FDM_ReceptionDate : DNS_FDM_ReceptionDate // Reception Date, 접수일시
    , DNS_FDM_ActionRepairDetails : DNS_FDM_ActionRepairDetails // Action/Repair Details, 조치/수리내용
    , DNS_FDM_ReGenerate : DNS_FDM_ReGenerate // ReGenerate, 재발생
    , DNS_FDM_UrgencyLevel : DNS_FDM_UrgencyLevel // Urgency Level, 긴급도
    , DNS_FDM_OrderNumber : DNS_FDM_OrderNumber // Order Number, 오더번호
    , DNS_FDM_WorkCenter : DNS_FDM_WorkCenter // Work Center, 업체명
    , DNS_FDM_Address : DNS_FDM_Address // Address, 위치
    , DNS_FDM_InstallationDefect : DNS_FDM_InstallationDefect // Installation Defect, 설치하자
    , DNS_FDM_InstallerWC : DNS_FDM_InstallerWC // Installer Work Center, 설치자소속
    , DNS_FDM_TechnicalReview : DNS_FDM_TechnicalReview // Technical Review, 기술검토
    , DNS_FDM_PendingProcessingDetail : DNS_FDM_PendingProcessingDetail // Pending Processing Detail, 미결내용
    , DNS_FDM_LastDispatchDate : DNS_FDM_LastDispatchDate // Last Dispatch Date, 최종출동일시
    , DNS_FDM_LastCompletionDate : DNS_FDM_LastCompletionDate // Last Completion Date, 최종완료일시
    , DNS_FDM_ProductCategory : DNS_FDM_ProductCategory // Product Category, 기종군
    , DNS_FDM_ReceptionDetail : DNS_FDM_ReceptionDetail // Reception Detail, 고장내용(상담)
    , DNS_FDM_CountermeasureDetail : DNS_FDM_CountermeasureDetail // Countermeasure Detail, 향후대응방안
    , DNS_FDM_PartState : DNS_FDM_PartState // Part State, 부품상태
    , DNS_FDM_ServiceResource : DNS_FDM_ServiceResource // Service Resource, 수리담당자
    , DNS_FDM_DispatchedDate : DNS_FDM_DispatchedDate // Dispatched Date, 출발예정일
    , DNS_FDM_AllOrderCount : DNS_FDM_AllOrderCount // All Order Count, 전체오더건수
    , DNS_FDM_OrderAverage : DNS_FDM_OrderAverage // Order Average, 오더평균
    , DNS_FDM_SupplyDate : DNS_FDM_SupplyDate // Supply Date, 공급예정일
    , DNS_FDM_RepairDate : DNS_FDM_RepairDate // Repair Date, 수리예정일
    , DNS_FDM_DispatchedTime : DNS_FDM_DispatchedTime // Dispatched Time, 출발예정시간
    , DNS_FDM_OrderCount : DNS_FDM_OrderCount // Order Count (30Days), 오더건수(30일)
    , DNS_FDM_UrgencyEquip : DNS_FDM_UrgencyEquip // Urgency Equipment, 긴급대응장비
    , DNS_FDM_DispatchedCount : DNS_FDM_DispatchedCount // Dispatched Count, 출동횟수
    , DNS_FDM_Complaint : DNS_FDM_Complaint // Complaint, 고객불만/요구사항
    , DNS_FDM_ElapsedDate : DNS_FDM_ElapsedDate // Elapsed Date, 경과일
    , DNS_FDM_CSMemberName : DNS_FDM_CSMemberName // CS Member Name, 담당자
    , DNS_FDM_CSDueDate : DNS_FDM_CSDueDate // CS DueDate, 처리기한
    , DNS_FDM_CooperationTeam : DNS_FDM_CooperationTeam // Cooperation Team, 팀
    , DNS_FDM_CooperationDate : DNS_FDM_CooperationDate // Cooperation Date, 처리기한
    , DNS_FDM_CooperationPerson : DNS_FDM_CooperationPerson // Cooperation Person, 담당자
    , DNS_FDM_RepairRequestDate : DNS_FDM_RepairRequestDate // Repair Request Date, 수리요청일시
    , DNS_FDM_Save : DNS_FDM_Save // Save, 저장
    , DNS_FDM_Cancel : DNS_FDM_Cancel // Cancel, 취소
    , DNS_FDM_MATNR : DNS_FDM_MATNR // PartsNumber, 품번
    , DNS_FDM_MAKTX : DNS_FDM_MAKTX // PartsName, 품명
    , DNS_FDM_MENGE : DNS_FDM_MENGE // Quantity, 수량
    , DNS_FDM_REQDAT : DNS_FDM_REQDAT // Request Date, 신청일
    , DNS_FDM_MATNR_TXT : DNS_FDM_MATNR_TXT // Consignment progress, 탁송진행
    , DNS_FDM_APPROVAL : DNS_FDM_APPROVAL // Approval Status, 결재진행상태
    , DNS_FDM_DAREG : DNS_FDM_DAREG // Parts Packing Completed Date, 부품포장완료일
    , DNS_FDM_DAYYN : DNS_FDM_DAYYN // 24 Hours Passed, 24시간경과
    , DNS_FDM_SDATE : DNS_FDM_SDATE // Departure Date, 출발일
    , DNS_FDM_ODATE : DNS_FDM_ODATE // Expected Date, 예정일
    , DNS_FDM_SecuringParts : DNS_FDM_SecuringParts // Securing Parts, 부품확보
    , DNS_FDM_ProgressParts : DNS_FDM_ProgressParts // Progress Parts, 부품진행
    , DNS_FDM_PRETD : DNS_FDM_PRETD // Scheduled Supply Date, 공급예정일
    , DNS_FDM_QDATU : DNS_FDM_QDATU // Disbursement Date, 불출일자
    , DNS_FDM_Status : DNS_FDM_Status // Status, 상태
    , DNS_FDM_DeliveryLocation : DNS_FDM_DeliveryLocation // Delivery Location, 배송처
    , DNS_FDM_CSMemberNameMig : DNS_FDM_CSMemberNameMig // CS Member Name (Migration) , CS 담당자 (Migration)
    
}

export default labels;

// [MSG]
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_Success from '@salesforce/label/c.DNS_M_Success'; 
import DNS_M_PreparationCheckSaved from '@salesforce/label/c.DNS_M_PreparationCheckSaved'; 
import DNS_M_PreparationCreationError from '@salesforce/label/c.DNS_M_PreparationCreationError'; 
import DNS_M_PreparationEditError from '@salesforce/label/c.DNS_M_PreparationEditError'; 
import DNS_M_PreparationTicketCreation from '@salesforce/label/c.DNS_M_PreparationTicketCreation'; 
import DNS_M_QuoteLineItemEdited from '@salesforce/label/c.DNS_M_QuoteLineItemEdited'; 
import DNS_M_QuoteCreate from '@salesforce/label/c.DNS_M_QuoteCreate'; 
import DNS_M_QuoteAutoName from '@salesforce/label/c.DNS_M_QuoteAutoName'; 

// [TITLE]  
import DNS_T_SearchAccount from '@salesforce/label/c.DNS_T_SearchAccount'; 
import DNS_T_ProductRequest from '@salesforce/label/c.DNS_T_ProductRequest';  // 섹션이있긴한데 타이틀로도 하나
import DNS_H_SendCS from '@salesforce/label/c.DNS_H_SendCS';  
import DNS_S_ProductRequest from '@salesforce/label/c.DNS_S_ProductRequest'; 

// [SECTION]  
import DNS_S_ServiceHistory from '@salesforce/label/c.DNS_S_ServiceHistory'; 
import DNS_S_PendingServiceHistory from '@salesforce/label/c.DNS_S_PendingServiceHistory'; 
import DNS_S_ActivityHistory from '@salesforce/label/c.DNS_S_ActivityHistory'; 
import DNS_S_AllActivitiesHistory from '@salesforce/label/c.DNS_S_AllActivitiesHistory'; 
import DNS_S_AccountEquipmentList from '@salesforce/label/c.DNS_S_AccountEquipmentList'; 
import DNS_S_SameDefectHistory from '@salesforce/label/c.DNS_S_SameDefectHistory'; 
import DNS_S_TicketList from '@salesforce/label/c.DNS_S_TicketList'; 
import DNS_S_WorkOrderList from '@salesforce/label/c.DNS_S_WorkOrderList'; 
import DNS_S_PrepararionChecklistInformation from '@salesforce/label/c.DNS_S_PrepararionChecklistInformation'; 
import DNS_S_Description from '@salesforce/label/c.DNS_S_Description'; 
import DNS_S_NewPrepararionChecklist from '@salesforce/label/c.DNS_S_NewPrepararionChecklist'; 
import DNS_S_EditPreparationChecklist from '@salesforce/label/c.DNS_S_EditPreparationChecklist'; 

// [FIELD]
import DNS_F_Status from '@salesforce/label/c.DNS_F_Status'; 
import DNS_F_ContactPerson from '@salesforce/label/c.DNS_F_ContactPerson'; 
import DNS_F_SalesRep from '@salesforce/label/c.DNS_F_SalesRep'; 
import DNS_F_PreparationInspector from '@salesforce/label/c.DNS_F_PreparationInspector'; 

import DNS_F_ClosedReason from '@salesforce/label/c.DNS_F_ClosedReason'; 
import DNS_F_Resultofmeasure from '@salesforce/label/c.DNS_F_Resultofmeasure'; 
import DNS_F_ClosedReasonDetails from '@salesforce/label/c.DNS_F_ClosedReasonDetails'; 
import DNS_F_AssignHoldingReason from '@salesforce/label/c.DNS_F_AssignHoldingReason'; 
import DNS_F_AccountName from '@salesforce/label/c.DNS_F_AccountName'; 
import DNS_F_Requester from '@salesforce/label/c.DNS_F_Requester'; 
import DNS_F_Internalrequester from '@salesforce/label/c.DNS_F_Internalrequester'; 
import DNS_F_Phone from '@salesforce/label/c.DNS_F_Phone'; 
import DNS_F_NotificationToCustomer from '@salesforce/label/c.DNS_F_NotificationToCustomer'; 
import DNS_F_Urgent from '@salesforce/label/c.DNS_F_Urgent'; 
import DNS_F_Urgency from '@salesforce/label/c.DNS_F_Urgency'; 
import DNS_F_Recurrence from '@salesforce/label/c.DNS_F_Recurrence'; 
import DNS_F_ReceptionDetails from '@salesforce/label/c.DNS_F_ReceptionDetails'; 
import DNS_F_ProgressDetail from '@salesforce/label/c.DNS_F_ProgressDetail'; 
import DNS_F_Equipment from '@salesforce/label/c.DNS_F_Equipment'; 
import DNS_F_ConsultationChannel from '@salesforce/label/c.DNS_F_ConsultationChannel'; 
import DNS_F_TicketTypeMajor from '@salesforce/label/c.DNS_F_TicketTypeMajor'; 
import DNS_F_TicketTypeMiddle from '@salesforce/label/c.DNS_F_TicketTypeMiddle'; 
import DNS_F_ReceptionPath from '@salesforce/label/c.DNS_F_ReceptionPath'; 
import DNS_F_DateTimeOpened from '@salesforce/label/c.DNS_F_DateTimeOpened'; 
import DNS_F_DateTimeFailure from '@salesforce/label/c.DNS_F_DateTimeFailure'; 
import DNS_F_OriginTicket from '@salesforce/label/c.DNS_F_OriginTicket'; 
import DNS_F_FailureStatus from '@salesforce/label/c.DNS_F_FailureStatus'; 
import DNS_F_SalesOrder from '@salesforce/label/c.DNS_F_SalesOrder'; 
import DNS_F_FailureArea from '@salesforce/label/c.DNS_F_FailureArea'; 
import DNS_F_FailureAreaDetail from '@salesforce/label/c.DNS_F_FailureAreaDetail'; 
import DNS_F_Failurephenomenon from '@salesforce/label/c.DNS_F_Failurephenomenon'; 
import DNS_F_RequestedVisitDateTime from '@salesforce/label/c.DNS_F_RequestedVisitDateTime'; 
import DNS_F_ProgressDelay from '@salesforce/label/c.DNS_F_ProgressDelay'; 
import DNS_F_ClosedPendingReason from '@salesforce/label/c.DNS_F_ClosedPendingReason'; 
import DNS_F_TechnicalReview from '@salesforce/label/c.DNS_F_TechnicalReview'; 
import DNS_F_InstallationDefect from '@salesforce/label/c.DNS_F_InstallationDefect'; 
import DNS_F_AfterResponsePlan from '@salesforce/label/c.DNS_F_AfterResponsePlan'; 
import DNS_F_ModelCode from '@salesforce/label/c.DNS_F_ModelCode'; 
import DNS_F_InstallationWorkCenter from '@salesforce/label/c.DNS_F_InstallationWorkCenter'; 
import DNS_F_ProductionSite from '@salesforce/label/c.DNS_F_ProductionSite'; 
import DNS_F_NotiNO from '@salesforce/label/c.DNS_F_NotiNO'; 
import DNS_F_OccurrenceClassification from '@salesforce/label/c.DNS_F_OccurrenceClassification'; 
import DNS_F_SVOrdNo from '@salesforce/label/c.DNS_F_SVOrdNo'; 
import DNS_F_ReturnItemDelivery from '@salesforce/label/c.DNS_F_ReturnItemDelivery'; 
import DNS_F_LastModifiedBy from '@salesforce/label/c.DNS_F_LastModifiedBy'; 
import DNS_F_CreatedBy from '@salesforce/label/c.DNS_F_CreatedBy'; 
import DNS_F_ContactPosition from '@salesforce/label/c.DNS_F_ContactPosition';
import DNS_F_SalesDealer from '@salesforce/label/c.DNS_F_SalesDealer';
import DNS_F_SalesDealerContactPhone from '@salesforce/label/c.DNS_F_SalesDealerContactPhone';
import DNS_F_TrainingCount from '@salesforce/label/c.DNS_F_TrainingCount';
import DNS_F_TrainingType from '@salesforce/label/c.DNS_F_TrainingType';
import DNS_F_TraineeLevel from '@salesforce/label/c.DNS_F_TraineeLevel';
import DNS_F_TrainingDateTime1 from '@salesforce/label/c.DNS_F_TrainingDateTime1';
import DNS_F_TrainingDateTime2 from '@salesforce/label/c.DNS_F_TrainingDateTime2';
import DNS_F_TrainingDateTime3 from '@salesforce/label/c.DNS_F_TrainingDateTime3';
import DNS_F_ServiceResource from '@salesforce/label/c.DNS_F_ServiceResource';

// [COLUMN]  
import DNS_C_InspectionDate from '@salesforce/label/c.DNS_C_InspectionDate'; 
import DNS_C_OrderType from '@salesforce/label/c.DNS_C_OrderType'; 
import DNS_C_OrderStatus from '@salesforce/label/c.DNS_C_OrderStatus'; 
import DNS_C_OrderNumber from '@salesforce/label/c.DNS_C_OrderNumber'; 
import DNS_C_Manager from '@salesforce/label/c.DNS_C_Manager'; 
import DNS_C_ServiceResource from '@salesforce/label/c.DNS_C_ServiceResource'; 
import DNS_C_ReceptionDetails from '@salesforce/label/c.DNS_C_ReceptionDetails';
import DNS_C_ConsultationDetails from '@salesforce/label/c.DNS_C_ConsultationDetails';
import DNS_C_InspectionDetails from '@salesforce/label/c.DNS_C_InspectionDetails';
import DNS_C_Status from '@salesforce/label/c.DNS_C_Status';
import DNS_C_DateOfReceipt from '@salesforce/label/c.DNS_C_DateOfReceipt';
import DNS_C_Ticket from '@salesforce/label/c.DNS_C_Ticket';
import DNS_C_Account from '@salesforce/label/c.DNS_C_Account';
import DNS_C_WorkCenter from '@salesforce/label/c.DNS_C_WorkCenter';
import DNS_C_Model from '@salesforce/label/c.DNS_C_Model';
import DNS_C_SerialNumber from '@salesforce/label/c.DNS_C_SerialNumber';
import DNS_C_Phone from '@salesforce/label/c.DNS_C_Phone';
import DNS_C_InstallDate from '@salesforce/label/c.DNS_C_InstallDate';
import DNS_C_ActionDetails from '@salesforce/label/c.DNS_C_ActionDetails';
import DNS_C_ConsultationDate from '@salesforce/label/c.DNS_C_ConsultationDate';
import DNS_C_Consultant from '@salesforce/label/c.DNS_C_Consultant';
import DNS_C_Reviser from '@salesforce/label/c.DNS_C_Reviser';
import DNS_C_Contact from '@salesforce/label/c.DNS_C_Contact';
import DNS_C_ContactName from '@salesforce/label/c.DNS_C_ContactName';
import DNS_C_Equipment from '@salesforce/label/c.DNS_C_Equipment';
import DNS_C_ConsultStartTime from '@salesforce/label/c.DNS_C_ConsultStartTime';
import DNS_C_ConsultEndTime from '@salesforce/label/c.DNS_C_ConsultEndTime';
import DNS_C_ConsultTypeLevel1 from '@salesforce/label/c.DNS_C_ConsultTypeLevel1';
import DNS_C_ConsultTypeLevel2 from '@salesforce/label/c.DNS_C_ConsultTypeLevel2';
import DNS_C_ConsultationChannel from '@salesforce/label/c.DNS_C_ConsultationChannel';
import DNS_C_PartsName from '@salesforce/label/c.DNS_C_PartsName';
import DNS_C_PartsProcessStatus from '@salesforce/label/c.DNS_C_PartsProcessStatus';
import DNS_C_PartsCode from '@salesforce/label/c.DNS_C_PartsCode';
import DNS_C_Stock from '@salesforce/label/c.DNS_C_Stock';
import DNS_C_Quantity from '@salesforce/label/c.DNS_C_Quantity';
import DNS_C_EndDateOfVisit from '@salesforce/label/c.DNS_C_EndDateOfVisit';
import DNS_C_StartDateOfVisit from '@salesforce/label/c.DNS_C_StartDateOfVisit';
import DNS_C_RecordType from '@salesforce/label/c.DNS_C_RecordType';
import DNS_C_InspectionName from '@salesforce/label/c.DNS_C_InspectionName';
import DNS_C_PreparationChecklist from '@salesforce/label/c.DNS_C_PreparationChecklist';
import DNS_C_ProductRequestProductCode from '@salesforce/label/c.DNS_C_ProductRequestProductCode';
import DNS_C_ProductRequestStatus from '@salesforce/label/c.DNS_C_ProductRequestStatus';
import DNS_C_ProductRequestSequence from '@salesforce/label/c.DNS_C_ProductRequestSequence';
import DNS_C_ProductRequestProduct from '@salesforce/label/c.DNS_C_ProductRequestProduct';
import DNS_C_ProductRequestQuantity from '@salesforce/label/c.DNS_C_ProductRequestQuantity';
import DNS_C_ProductRequestInventory from '@salesforce/label/c.DNS_C_ProductRequestInventory';
import DNS_C_ProductRequestReturnStatus from '@salesforce/label/c.DNS_C_ProductRequestReturnStatus';
import DNS_C_ProductRequestTransportsDivision from '@salesforce/label/c.DNS_C_ProductRequestTransportsDivision';
import DNS_C_ProductRequestShipTo from '@salesforce/label/c.DNS_C_ProductRequestShipTo';
import DNS_C_ProductRequestWorkCenter from '@salesforce/label/c.DNS_C_ProductRequestWorkCenter';
import DNS_C_Item from '@salesforce/label/c.DNS_C_Item';
import DNS_C_PreparationBeforeInstallation from '@salesforce/label/c.DNS_C_PreparationBeforeInstallation';
import DNS_C_PlannedDate from '@salesforce/label/c.DNS_C_PlannedDate';
import DNS_C_CompletionDate from '@salesforce/label/c.DNS_C_CompletionDate';
import DNS_C_QuoteExpirationDate from '@salesforce/label/c.DNS_C_QuoteExpirationDate';
import DNS_C_QuoteName from '@salesforce/label/c.DNS_C_QuoteName';
import DNS_M_VersionCnt from '@salesforce/label/c.DNS_M_VersionCnt';
import DNS_C_QuoteNumber from '@salesforce/label/c.DNS_C_QuoteNumber';
import DNS_C_LocationMap from '@salesforce/label/c.DNS_C_LocationMap';
import DNS_C_Weight from '@salesforce/label/c.DNS_C_Weight';
import DNS_C_OnSiteDate from '@salesforce/label/c.DNS_C_OnSiteDate';
import DNS_C_ProgressDetail from '@salesforce/label/c.DNS_C_ProgressDetail';
import DNS_C_Inspection from '@salesforce/label/c.DNS_C_Inspection';

// [BUTTON]
import DNS_B_Approval from '@salesforce/label/c.DNS_B_Approval';
import DNS_B_Edit from '@salesforce/label/c.DNS_B_Edit';
import DNS_B_Save from '@salesforce/label/c.DNS_B_Save';
import DNS_B_New from '@salesforce/label/c.DNS_B_New';
import DNS_B_Cancel from '@salesforce/label/c.DNS_B_Cancel';
import DNS_B_ViewAll from '@salesforce/label/c.DNS_B_ViewAll';
import DNS_B_Search from '@salesforce/label/c.DNS_B_Search';
import DNS_B_ProductRequestEdit from '@salesforce/label/c.DNS_B_ProductRequestEdit';
import DNS_B_ProductRequestSave from '@salesforce/label/c.DNS_B_ProductRequestSave';
import DNS_B_Next from '@salesforce/label/c.DNS_B_Next';


//[MOBILE]
import DNS_FSL_IndirectApplication from '@salesforce/label/c.DNS_FSL_IndirectApplication';
import DNS_FSL_Account from '@salesforce/label/c.DNS_FSL_Account';
import DNS_FSL_Equipment from '@salesforce/label/c.DNS_FSL_Equipment';
import DNS_FSL_Contact from '@salesforce/label/c.DNS_FSL_Contact';
import DNS_FSL_Dispatched from '@salesforce/label/c.DNS_FSL_Dispatched';
import DNS_FSL_Completed from '@salesforce/label/c.DNS_FSL_Completed';
import DNS_FSL_CompleteInput from '@salesforce/label/c.DNS_FSL_CompleteInput';
import DNS_FSL_PleaseEnterInformation from '@salesforce/label/c.DNS_FSL_PleaseEnterInformation';
import DNS_FSL_Dispatch from '@salesforce/label/c.DNS_FSL_Dispatch';
import DNS_FSL_NotDispatched from '@salesforce/label/c.DNS_FSL_NotDispatched';
import DNS_FSL_Complete from '@salesforce/label/c.DNS_FSL_Complete';
import DNS_FSL_Incomplete from '@salesforce/label/c.DNS_FSL_Incomplete';
import DNS_FSL_NoAnnouncement from '@salesforce/label/c.DNS_FSL_NoAnnouncement';
import DNS_FSL_Back from '@salesforce/label/c.DNS_FSL_Back';
import DNS_FSL_Attachment from '@salesforce/label/c.DNS_FSL_Attachment';
import DNS_FSL_NoFilesAttached from '@salesforce/label/c.DNS_FSL_NoFilesAttached';
import DNS_FSL_SetDepartureTime from '@salesforce/label/c.DNS_FSL_SetDepartureTime';
import DNS_FSL_DoWantDepartureTime from '@salesforce/label/c.DNS_FSL_DoWantDepartureTime';
import DNS_FSL_Cancel from '@salesforce/label/c.DNS_FSL_Cancel';
import DNS_FSL_Check from '@salesforce/label/c.DNS_FSL_Check';
import DNS_FSL_DepartureReportCompleted from '@salesforce/label/c.DNS_FSL_DepartureReportCompleted';
import DNS_FSL_DepartureReportingComplete from '@salesforce/label/c.DNS_FSL_DepartureReportingComplete';
import DNS_FSL_SetArrivalTime from '@salesforce/label/c.DNS_FSL_SetArrivalTime';
import DNS_FSL_DoWantArrivalTime from '@salesforce/label/c.DNS_FSL_DoWantArrivalTime';
import DNS_FSL_ArrivalReportingComplete from '@salesforce/label/c.DNS_FSL_ArrivalReportingComplete';
import DNS_FSL_PleaseSelectStatus from '@salesforce/label/c.DNS_FSL_PleaseSelectStatus';
import DNS_FSL_Save from '@salesforce/label/c.DNS_FSL_Save';
import DNS_FSL_Close from '@salesforce/label/c.DNS_FSL_Close';
import DNS_FSL_StatusChangeComplete from '@salesforce/label/c.DNS_FSL_StatusChangeComplete'; 
import DNS_FSL_PendingReasonChoice from '@salesforce/label/c.DNS_FSL_PendingReasonChoice'; 
import DNS_FSL_PendingMSG from '@salesforce/label/c.DNS_FSL_PendingMSG'; 
import DNS_FSL_Alarm from '@salesforce/label/c.DNS_FSL_Alarm'; 
import DNS_FSL_PendingProcessingCompleted from '@salesforce/label/c.DNS_FSL_PendingProcessingCompleted'; 
import DNS_FSL_PendingProcessing from '@salesforce/label/c.DNS_FSL_PendingProcessing'; 
import DNS_FSL_AssignmentRejectionReason from '@salesforce/label/c.DNS_FSL_AssignmentRejectionReason'; 
import DNS_FSL_AssignmentRejectionSave from '@salesforce/label/c.DNS_FSL_AssignmentRejectionSave'; 
import DNS_FSL_AssignmentRejectionReasonSave from '@salesforce/label/c.DNS_FSL_AssignmentRejectionReasonSave'; 
import DNS_FSL_Parts from '@salesforce/label/c.DNS_FSL_Parts'; 
import DNS_FSL_Closing from '@salesforce/label/c.DNS_FSL_Closing'; 
import DNS_FSL_Customer from '@salesforce/label/c.DNS_FSL_Customer'; 
import DNS_FSL_Installation from '@salesforce/label/c.DNS_FSL_Installation'; 
import DNS_FSL_TechnicalReview from '@salesforce/label/c.DNS_FSL_TechnicalReview'; 
import DNS_FSL_TechnicalCustomer from '@salesforce/label/c.DNS_FSL_TechnicalCustomer'; 
import DNS_FSL_TechnicalDesign from '@salesforce/label/c.DNS_FSL_TechnicalDesign'; 
import DNS_FSL_TechnicalParts from '@salesforce/label/c.DNS_FSL_TechnicalParts'; 
import DNS_FSL_TechnicalPersonnel from '@salesforce/label/c.DNS_FSL_TechnicalPersonnel'; 
import DNS_FSL_ResultNotEntered from '@salesforce/label/c.DNS_FSL_ResultNotEntered'; 
import DNS_FSL_NeedMorePerson from '@salesforce/label/c.DNS_FSL_NeedMorePerson'; 
import DNS_FSL_ArrivalReportCompleted from '@salesforce/label/c.DNS_FSL_ArrivalReportCompleted'; 
import DNS_FSL_etc from '@salesforce/label/c.DNS_FSL_ETC';
import DNS_FSL_DispatchImpossible  from '@salesforce/label/c.DNS_FSL_DispatchImpossible';
import DNS_FSL_DispatchDelay  from '@salesforce/label/c.DNS_FSL_DispatchDelay';
import DNS_FSL_TechnicalShortage  from '@salesforce/label/c.DNS_FSL_TechnicalShortage';
import DNS_FSL_PartsNeeded  from '@salesforce/label/c.DNS_FSL_PartsNeeded';
import DNS_FSL_Wait  from '@salesforce/label/c.DNS_FSL_Wait';
import DNS_FSL_Education  from '@salesforce/label/c.DNS_FSL_Education';
import DNS_FSL_Meeting  from '@salesforce/label/c.DNS_FSL_Meeting';
import DNS_FSL_Work  from '@salesforce/label/c.DNS_FSL_Work';
import DNS_FSL_SelfWork  from '@salesforce/label/c.DNS_FSL_SelfWork';
import DNS_FSL_AssignmentRejectionReasonFail  from '@salesforce/label/c.DNS_FSL_AssignmentRejectionReasonFail';
import DNS_FSL_Replacement  from '@salesforce/label/c.DNS_FSL_Replacement';
import DNS_FSL_Material  from '@salesforce/label/c.DNS_FSL_Material';
import DNS_FSL_ProductNumber  from '@salesforce/label/c.DNS_FSL_ProductNumber';
import DNS_FSL_State  from '@salesforce/label/c.DNS_FSL_State';
import DNS_FSL_Stock  from '@salesforce/label/c.DNS_FSL_Stock';
import DNS_FSL_Quantity  from '@salesforce/label/c.DNS_FSL_Quantity';
import DNS_FSL_Standard  from '@salesforce/label/c.DNS_FSL_Standard';
import DNS_FSL_Unit  from '@salesforce/label/c.DNS_FSL_Unit';
import DNS_FSL_Weight  from '@salesforce/label/c.DNS_FSL_Weight';
import DNS_FSL_WeightUnit  from '@salesforce/label/c.DNS_FSL_WeightUnit';
import DNS_FSL_DeliveryPackaging  from '@salesforce/label/c.DNS_FSL_DeliveryPackaging';
import DNS_FSL_Add  from '@salesforce/label/c.DNS_FSL_Add';
import DNS_FSL_ThePartRequestHasBeenCompleted  from '@salesforce/label/c.DNS_FSL_ThePartRequestHasBeenCompleted';
import DNS_FSL_ConfirmationOfPartAddition  from '@salesforce/label/c.DNS_FSL_ConfirmationOfPartAddition';
import DNS_FSL_PleaseCheckQuantity  from '@salesforce/label/c.DNS_FSL_PleaseCheckQuantity';
import DNS_FSL_Dot  from '@salesforce/label/c.DNS_FSL_Dot';
import DNS_FSL_AddParts  from '@salesforce/label/c.DNS_FSL_AddParts';
import DNS_FSL_ProductName  from '@salesforce/label/c.DNS_FSL_ProductName';
import DNS_FSL_BillingPartsList  from '@salesforce/label/c.DNS_FSL_BillingPartsList';
import DNS_FSL_CancellationOfRequest  from '@salesforce/label/c.DNS_FSL_CancellationOfRequest';
import DNS_FSL_CancellationOfRequestIsOnlyPossibleBeforeApproval  from '@salesforce/label/c.DNS_FSL_CancellationOfRequestIsOnlyPossibleBeforeApproval';
import DNS_FSL_PleaseEnterTheQuantity  from '@salesforce/label/c.DNS_FSL_PleaseEnterTheQuantity';
import DNS_FSL_ThereAreNoLookupResults  from '@salesforce/label/c.DNS_FSL_ThereAreNoLookupResults';
import DNS_FSL_ThereAreCurrentlyNoRequestedParts  from '@salesforce/label/c.DNS_FSL_ThereAreCurrentlyNoRequestedParts';
import DNS_FSL_InventoryCheck  from '@salesforce/label/c.DNS_FSL_InventoryCheck';
import DNS_FSL_DepartureSuccessSave  from '@salesforce/label/c.DNS_FSL_DepartureSuccessSave';
import DNS_FSL_DepartureCannotSave  from '@salesforce/label/c.DNS_FSL_DepartureCannotSave';
import DNS_FSL_ArrivalSuccessSave  from '@salesforce/label/c.DNS_FSL_ArrivalSuccessSave';
import DNS_FSL_ArrivalCannotSave  from '@salesforce/label/c.DNS_FSL_ArrivalCannotSave';
import DNS_FSL_InputSuccessSaved  from '@salesforce/label/c.DNS_FSL_InputSuccessSaved';
import DNS_FSL_ErrorOccurred  from '@salesforce/label/c.DNS_FSL_ErrorOccurred';
import DNS_FSL_Error  from '@salesforce/label/c.DNS_FSL_Error';
import DNS_FSL_PendingProcessingNotPossible  from '@salesforce/label/c.DNS_FSL_PendingProcessingNotPossible';
import DNS_FSL_CancelRequest  from '@salesforce/label/c.DNS_FSL_CancelRequest';
import DNS_FSL_ConfirmRequestCancellation  from '@salesforce/label/c.DNS_FSL_ConfirmRequestCancellation';
import DNS_FSL_AssignmentRejectionCompleted  from '@salesforce/label/c.DNS_FSL_AssignmentRejectionCompleted';
import DNS_FSL_PossibleAssignedStatus  from '@salesforce/label/c.DNS_FSL_PossibleAssignedStatus';
import DNS_FSL_SalesPriceBeforeReplacement  from '@salesforce/label/c.DNS_FSL_SalesPriceBeforeReplacement';
import DNS_FSL_SalesPriceReplacement  from '@salesforce/label/c.DNS_FSL_SalesPriceReplacement';
import DNS_FSL_StockQuantity  from '@salesforce/label/c.DNS_FSL_StockQuantity';
import DNS_FSL_DealerStock  from '@salesforce/label/c.DNS_FSL_DealerStock';
import DNS_FSL_OutStock  from '@salesforce/label/c.DNS_FSL_OutStock';
import DNS_FSL_CurrentStock  from '@salesforce/label/c.DNS_FSL_CurrentStock';
import DNS_FSL_AvailableStock  from '@salesforce/label/c.DNS_FSL_AvailableStock';
import DNS_FSL_OrderReservationStock  from '@salesforce/label/c.DNS_FSL_OrderReservationStock';
import DNS_FSL_NoProductName  from '@salesforce/label/c.DNS_FSL_NoProductName';
import DNS_FSL_NoProductNumber  from '@salesforce/label/c.DNS_FSL_NoProductNumber';
import DNS_FSL_NoState  from '@salesforce/label/c.DNS_FSL_NoState';
import DNS_FSL_NoQuantity  from '@salesforce/label/c.DNS_FSL_NoQuantity';
import DNS_FSL_New  from '@salesforce/label/c.DNS_FSL_New';
import DNS_FSL_EnterLeastThreeCharacters  from '@salesforce/label/c.DNS_FSL_EnterLeastThreeCharacters';
import DNS_FSL_PartRequested  from '@salesforce/label/c.DNS_FSL_PartRequested';
import DNS_FSL_PleaseEnterQuantity  from '@salesforce/label/c.DNS_FSL_PleaseEnterQuantity';
import DNS_FSL_PartrequestCanceled  from '@salesforce/label/c.DNS_FSL_PartrequestCanceled';
import DNS_FSL_AlreadyDeleted  from '@salesforce/label/c.DNS_FSL_AlreadyDeleted';
import DNS_FSL_PerformanceDueDate  from '@salesforce/label/c.DNS_FSL_PerformanceDueDate';
import DNS_FSL_ChangedSupplyDate  from '@salesforce/label/c.DNS_FSL_ChangedSupplyDate';
import DNS_FSL_SubmitDate  from '@salesforce/label/c.DNS_FSL_SubmitDate';
import DNS_FSL_ServiceType  from '@salesforce/label/c.DNS_FSL_ServiceType';
import DNS_FSL_RequestDate  from '@salesforce/label/c.DNS_FSL_RequestDate';
import DNS_FSL_ReceptionDetail  from '@salesforce/label/c.DNS_FSL_ReceptionDetail';
import DNS_FSL_RepairDetail  from '@salesforce/label/c.DNS_FSL_RepairDetail';
import DNS_FSL_ViewDetail  from '@salesforce/label/c.DNS_FSL_ViewDetail';
import DNS_FSL_CustomerAppointmentTimeSetting  from '@salesforce/label/c.DNS_FSL_CustomerAppointmentTimeSetting';
import DNS_FSL_CustomerAppointmentTimeSettingComplete  from '@salesforce/label/c.DNS_FSL_CustomerAppointmentTimeSettingComplete';
import DNS_FSL_RegisterCustomerTimeSetTime  from '@salesforce/label/c.DNS_FSL_RegisterCustomerTimeSetTime';
import DNS_FSL_CustomerTimeregisteredSetTime  from '@salesforce/label/c.DNS_FSL_CustomerTimeregisteredSetTime';
import DNS_FSL_CustomerAppointmentSuccessfullySave  from '@salesforce/label/c.DNS_FSL_CustomerAppointmentSuccessfullySave';
import DNS_FSL_EnteredAfterCurrentTime  from '@salesforce/label/c.DNS_FSL_EnteredAfterCurrentTime';
import DNS_FSL_PendingDetail  from '@salesforce/label/c.DNS_FSL_PendingDetail';
import DNS_FSL_DispatchCompleted  from '@salesforce/label/c.DNS_FSL_DispatchCompleted';
import DNS_FSL_DispatchCanceled  from '@salesforce/label/c.DNS_FSL_DispatchCanceled';
import DNS_FSL_DispatchConfirm  from '@salesforce/label/c.DNS_FSL_DispatchConfirm';
import DNS_FSL_SavingValue  from '@salesforce/label/c.DNS_FSL_SavingValue';
import DNS_FSL_EnterPendingDetail  from '@salesforce/label/c.DNS_FSL_EnterPendingDetail';
import DNS_FSL_SetComplete  from '@salesforce/label/c.DNS_FSL_SetComplete';
import DNS_FSL_PleaseEnterValuesComplete  from '@salesforce/label/c.DNS_FSL_PleaseEnterValuesComplete';
import DNS_FSL_FailureAreaMajor  from '@salesforce/label/c.DNS_FSL_FailureAreaMajor';
import DNS_FSL_SelectFailureAreaMajor  from '@salesforce/label/c.DNS_FSL_SelectFailureAreaMajor';
import DNS_FSL_FailureAreaMiddle  from '@salesforce/label/c.DNS_FSL_FailureAreaMiddle';
import DNS_FSL_SelectFailureAreaMiddle  from '@salesforce/label/c.DNS_FSL_SelectFailureAreaMiddle';
import DNS_FSL_FailurePhenomenon  from '@salesforce/label/c.DNS_FSL_FailurePhenomenon';
import DNS_FSL_SelectFailurePhenomenon  from '@salesforce/label/c.DNS_FSL_SelectFailurePhenomenon';
import DNS_FSL_FailurePhenomenonDetail  from '@salesforce/label/c.DNS_FSL_FailurePhenomenonDetail';
import DNS_FSL_FailureCause  from '@salesforce/label/c.DNS_FSL_FailureCause';
import DNS_FSL_SelectFailureCause  from '@salesforce/label/c.DNS_FSL_SelectFailureCause';
import DNS_FSL_FailureCauseDetail  from '@salesforce/label/c.DNS_FSL_FailureCauseDetail';
import DNS_FSL_RepairAction  from '@salesforce/label/c.DNS_FSL_RepairAction';
import DNS_FSL_SelectRepairAction  from '@salesforce/label/c.DNS_FSL_SelectRepairAction';
import DNS_FSL_SuccessfulComplete  from '@salesforce/label/c.DNS_FSL_SuccessfulComplete';
import DNS_FSL_CompleteSuccessful  from '@salesforce/label/c.DNS_FSL_CompleteSuccessful';
import DNS_FSL_OrderTypeNotSupport  from '@salesforce/label/c.DNS_FSL_OrderTypeNotSupport';
import DNS_FSL_DispatchPendingProcessed  from '@salesforce/label/c.DNS_FSL_DispatchPendingProcessed';
import DNS_FSL_UploadFile  from '@salesforce/label/c.DNS_FSL_UploadFile';
import DNS_FSL_SelectedFile  from '@salesforce/label/c.DNS_FSL_SelectedFile';
import DNS_FSL_CaseFileUploadComplete  from '@salesforce/label/c.DNS_FSL_CaseFileUploadComplete';
import DNS_FSL_InputWorkResult  from '@salesforce/label/c.DNS_FSL_InputWorkResult';
import DNS_FSL_SelectInputWorkResult  from '@salesforce/label/c.DNS_FSL_SelectInputWorkResult';
import DNS_FSL_SuccessfulInputWorkResult  from '@salesforce/label/c.DNS_FSL_SuccessfulInputWorkResult';
import DNS_FSL_InputWorkResultSuccessful  from '@salesforce/label/c.DNS_FSL_InputWorkResultSuccessful';
import DNS_FSL_OrderTypeNotSupportInputWorkResult  from '@salesforce/label/c.DNS_FSL_OrderTypeNotSupportInputWorkResult';
import DNS_FSL_AlreadyConfirmed  from '@salesforce/label/c.DNS_FSL_AlreadyConfirmed';
import DNS_FSL_InputWorkResultsCompleted  from '@salesforce/label/c.DNS_FSL_InputWorkResultsCompleted';
import DNS_FSL_ExistingAppointmentTime  from '@salesforce/label/c.DNS_FSL_ExistingAppointmentTime';

import DNS_FSL_Announcement  from '@salesforce/label/c.DNS_FSL_Announcement';
import DNS_FSL_ByName  from '@salesforce/label/c.DNS_FSL_ByName';
import DNS_FSL_ByDate  from '@salesforce/label/c.DNS_FSL_ByDate';
import DNS_FSL_Writer  from '@salesforce/label/c.DNS_FSL_Writer';
import DNS_FSL_CreateQnA  from '@salesforce/label/c.DNS_FSL_CreateQnA';
import DNS_FSL_QnATitle  from '@salesforce/label/c.DNS_FSL_QnATitle';
import DNS_FSL_PostingDate  from '@salesforce/label/c.DNS_FSL_PostingDate';
import DNS_FSL_QuestionContent  from '@salesforce/label/c.DNS_FSL_QuestionContent';
import DNS_FSL_Create  from '@salesforce/label/c.DNS_FSL_Create';
import DNS_FSL_IntegratedBulletinBoard  from '@salesforce/label/c.DNS_FSL_IntegratedBulletinBoard';
import DNS_FSL_Content  from '@salesforce/label/c.DNS_FSL_Content';
import DNS_FSL_QnACreated  from '@salesforce/label/c.DNS_FSL_QnACreated';
import DNS_FSL_QnACreateFailed  from '@salesforce/label/c.DNS_FSL_QnACreateFailed';
import DNS_FSL_NoFilesDownload  from '@salesforce/label/c.DNS_FSL_NoFilesDownload';
import DNS_FSL_Respondent  from '@salesforce/label/c.DNS_FSL_Respondent';
import DNS_FSL_AnswerContent  from '@salesforce/label/c.DNS_FSL_AnswerContent';
import DNS_FSL_NoDepartureTime  from '@salesforce/label/c.DNS_FSL_NoDepartureTime';
import DNS_FSL_TicketCanceled  from '@salesforce/label/c.DNS_FSL_TicketCanceled';
import DNS_FSL_PreDayMissingArrAndPending  from '@salesforce/label/c.DNS_FSL_PreDayMissingArrAndPending';
import DNS_FSL_PreDayMissingPending  from '@salesforce/label/c.DNS_FSL_PreDayMissingPending';
import DNS_FSL_Okay  from '@salesforce/label/c.DNS_FSL_Okay';
import DNS_FSL_Holiday  from '@salesforce/label/c.DNS_FSL_Holiday';

// 필드하자관리 Section
import DNS_FDM_ReceptionDetail_Section  from '@salesforce/label/c.DNS_FDM_ReceptionDetail_Section';
import DNS_FDM_OrderStatus_Section  from '@salesforce/label/c.DNS_FDM_OrderStatus_Section';
import DNS_FDM_PendingManagement_Section  from '@salesforce/label/c.DNS_FDM_PendingManagement_Section';
import DNS_FDM_Cooperation_Section  from '@salesforce/label/c.DNS_FDM_Cooperation_Section';
import DNS_FDM_DispatchPlan_Section  from '@salesforce/label/c.DNS_FDM_DispatchPlan_Section';

// 필드하자관리 CustomLabel
import DNS_FDM_Consultant  from '@salesforce/label/c.DNS_FDM_Consultant';
import DNS_FDM_Requester  from '@salesforce/label/c.DNS_FDM_Requester';
import DNS_FDM_Urgency  from '@salesforce/label/c.DNS_FDM_Urgency';
import DNS_FDM_Severity  from '@salesforce/label/c.DNS_FDM_Severity';
import DNS_FDM_Branch  from '@salesforce/label/c.DNS_FDM_Branch';
import DNS_FDM_Dispatcher  from '@salesforce/label/c.DNS_FDM_Dispatcher';
import DNS_FDM_RequesterPhone  from '@salesforce/label/c.DNS_FDM_RequesterPhone';
import DNS_FDM_WorkerPhone  from '@salesforce/label/c.DNS_FDM_WorkerPhone';
import DNS_FDM_DefectType  from '@salesforce/label/c.DNS_FDM_DefectType';
import DNS_FDM_Installer  from '@salesforce/label/c.DNS_FDM_Installer';
import DNS_FDM_InstallFinishDate  from '@salesforce/label/c.DNS_FDM_InstallFinishDate';
import DNS_FDM_PendingProcessing  from '@salesforce/label/c.DNS_FDM_PendingProcessing';
import DNS_FDM_Reservation  from '@salesforce/label/c.DNS_FDM_Reservation';
import DNS_FDM_LastArrivalDate  from '@salesforce/label/c.DNS_FDM_LastArrivalDate';
import DNS_FDM_Dealer  from '@salesforce/label/c.DNS_FDM_Dealer';
import DNS_FDM_ReceptionDate  from '@salesforce/label/c.DNS_FDM_ReceptionDate';
import DNS_FDM_ActionRepairDetails  from '@salesforce/label/c.DNS_FDM_ActionRepairDetails';
import DNS_FDM_ReGenerate  from '@salesforce/label/c.DNS_FDM_ReGenerate';
import DNS_FDM_UrgencyLevel  from '@salesforce/label/c.DNS_FDM_UrgencyLevel';
import DNS_FDM_OrderNumber  from '@salesforce/label/c.DNS_FDM_OrderNumber';
import DNS_FDM_WorkCenter  from '@salesforce/label/c.DNS_FDM_WorkCenter';
import DNS_FDM_Address  from '@salesforce/label/c.DNS_FDM_Address';
import DNS_FDM_InstallationDefect  from '@salesforce/label/c.DNS_FDM_InstallationDefect';
import DNS_FDM_InstallerWC  from '@salesforce/label/c.DNS_FDM_InstallerWC';
import DNS_FDM_TechnicalReview  from '@salesforce/label/c.DNS_FDM_TechnicalReview';
import DNS_FDM_PendingProcessingDetail  from '@salesforce/label/c.DNS_FDM_PendingProcessingDetail';
import DNS_FDM_LastDispatchDate  from '@salesforce/label/c.DNS_FDM_LastDispatchDate';
import DNS_FDM_LastCompletionDate  from '@salesforce/label/c.DNS_FDM_LastCompletionDate';
import DNS_FDM_ProductCategory  from '@salesforce/label/c.DNS_FDM_ProductCategory';
import DNS_FDM_ReceptionDetail  from '@salesforce/label/c.DNS_FDM_ReceptionDetail';
import DNS_FDM_CountermeasureDetail  from '@salesforce/label/c.DNS_FDM_CountermeasureDetail';
import DNS_FDM_PartState  from '@salesforce/label/c.DNS_FDM_PartState';
import DNS_FDM_ServiceResource  from '@salesforce/label/c.DNS_FDM_ServiceResource';
import DNS_FDM_DispatchedDate  from '@salesforce/label/c.DNS_FDM_DispatchedDate';
import DNS_FDM_AllOrderCount  from '@salesforce/label/c.DNS_FDM_AllOrderCount';
import DNS_FDM_OrderAverage  from '@salesforce/label/c.DNS_FDM_OrderAverage';
import DNS_FDM_SupplyDate  from '@salesforce/label/c.DNS_FDM_SupplyDate';
import DNS_FDM_RepairDate  from '@salesforce/label/c.DNS_FDM_RepairDate';
import DNS_FDM_DispatchedTime  from '@salesforce/label/c.DNS_FDM_DispatchedTime';
import DNS_FDM_OrderCount  from '@salesforce/label/c.DNS_FDM_OrderCount';
import DNS_FDM_UrgencyEquip  from '@salesforce/label/c.DNS_FDM_UrgencyEquip';
import DNS_FDM_DispatchedCount  from '@salesforce/label/c.DNS_FDM_DispatchedCount';
import DNS_FDM_Complaint  from '@salesforce/label/c.DNS_FDM_Complaint';
import DNS_FDM_ElapsedDate  from '@salesforce/label/c.DNS_FDM_ElapsedDate';
import DNS_FDM_CSMemberName  from '@salesforce/label/c.DNS_FDM_CSMemberName';
import DNS_FDM_CSDueDate  from '@salesforce/label/c.DNS_FDM_CSDueDate';
import DNS_FDM_CooperationTeam  from '@salesforce/label/c.DNS_FDM_CooperationTeam';
import DNS_FDM_CooperationDate  from '@salesforce/label/c.DNS_FDM_CooperationDate';
import DNS_FDM_CooperationPerson  from '@salesforce/label/c.DNS_FDM_CooperationPerson';
import DNS_FDM_RepairRequestDate  from '@salesforce/label/c.DNS_FDM_RepairRequestDate';
import DNS_FDM_Save  from '@salesforce/label/c.DNS_FDM_Save';
import DNS_FDM_Cancel  from '@salesforce/label/c.DNS_FDM_Cancel';
import DNS_FDM_MATNR  from '@salesforce/label/c.DNS_FDM_MATNR';
import DNS_FDM_MAKTX  from '@salesforce/label/c.DNS_FDM_MAKTX';
import DNS_FDM_MENGE  from '@salesforce/label/c.DNS_FDM_MENGE';
import DNS_FDM_REQDAT  from '@salesforce/label/c.DNS_FDM_REQDAT';
import DNS_FDM_MATNR_TXT  from '@salesforce/label/c.DNS_FDM_MATNR_TXT';
import DNS_FDM_APPROVAL  from '@salesforce/label/c.DNS_FDM_APPROVAL';
import DNS_FDM_DAREG  from '@salesforce/label/c.DNS_FDM_DAREG';
import DNS_FDM_DAYYN  from '@salesforce/label/c.DNS_FDM_DAYYN';
import DNS_FDM_SDATE  from '@salesforce/label/c.DNS_FDM_SDATE';
import DNS_FDM_ODATE  from '@salesforce/label/c.DNS_FDM_ODATE';
import DNS_FDM_SecuringParts  from '@salesforce/label/c.DNS_FDM_SecuringParts';
import DNS_FDM_ProgressParts  from '@salesforce/label/c.DNS_FDM_ProgressParts';
import DNS_FDM_PRETD  from '@salesforce/label/c.DNS_FDM_PRETD';
import DNS_FDM_QDATU  from '@salesforce/label/c.DNS_FDM_QDATU';
import DNS_FDM_Status  from '@salesforce/label/c.DNS_FDM_Status';
import DNS_FDM_DeliveryLocation  from '@salesforce/label/c.DNS_FDM_DeliveryLocation';
import DNS_FDM_CSMemberNameMig  from '@salesforce/label/c.DNS_FDM_CSMemberNameMig';