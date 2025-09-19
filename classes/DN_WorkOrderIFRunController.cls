public with sharing class DN_WorkOrderIFRunController {

    /**
     * @Description
     * 	- Service Order 정보 Update I/F 실행
     * @author Hayeong Min
    **/ 
    @AuraEnabled
    public static CommonWrapper callWorkOrderIF(String recordId){
        System.debug('recordId : '+recordId);
        CommonWrapper cw = new CommonWrapper();
        try {
            WorkOrder wo = [SELECT Id, ScheduledDispatchTime__c, PMActivityType__c, OrderType__c, ReceptionDetail__c, CreatedDate,
            SPTask__c, ServiceOrderNumber__c, FM_Contact__c, Case.FM_PhoneNumber__c, 
            Worker__c, Worker__r.Name, Worker__r.StaffNumber__c, Worker__r.FM_isDirect__c,
            Worker__r.Service_Territory__r.PlanningPlant__c,
            Asset.Name, Asset.MachineName__c, Asset.SerialNumber, 
            Case.FM_EquipmentWarranty__c, Case.FM_LaborWarranty__c, Case.FM_PartsWarranty__c,
            SoldTo__r.CustomerCode__c, SoldTo__r.Name, SoldTo__r.ShippingPostalCode,
            SoldTo__r.ShippingCity, SoldTo__r.ShippingStreet, 
            Account.Name,  Account.CustomerCode__c, Account.ShippingPostalCode,
            Account.ShippingCity, Account.ShippingStreet, 
            Case.BreakdownDateTime__c, Case.ApplicationDateTime__c, FM_RepairRequestDateTime__c,
            ServiceTerritoryId, ServiceTerritory.Name, ServiceTerritory.WCCode__c, ServiceTerritory.PlanningPlant__c,
            ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__r.WCCode__c, ServiceTerritory.WCID__c,
            Case.SalesOrder__r.ERPPSONo__c, isMachineDown__c,
            OwnerId, Owner.Name, isIFSuccess__c, 
            Noti_Number__c , RepairStartDate__c, RepairEndDate__c, RepairActionValue__c, CauseOfFailureValue__c, CauseOfFailureDetail__c, PendingOrCustomerMatters__c,
            FailureArea__c, FailureAreaValue__c, FailureAreaGroup__c, FailureAreaGroupValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c, FailurePhenomenonDetail__c,
            Case.FailureAreaValue__c, Case.FailureAreaDetailValue__c, Case.FailurePhenomenonValue__c, FM_isDirect__c, IsDirectPaidService__c
            FROM WorkOrder WHERE Id = :recordId];
            System.debug('wo :: '+ JSON.serialize(wo) );
            //IF_CSPLUS_010
            if(wo.OrderType__c == '201' || wo.OrderType__c == '202' || wo.OrderType__c == '203' || wo.OrderType__c == '204'
            || wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '217' || wo.OrderType__c == '216'
            || wo.OrderType__c == '218' || wo.OrderType__c == '219' || wo.OrderType__c == '220'){
                User u = [SELECT Id, Name, EmployeeNumber, ERP_Key__c FROM User WHERE ID = :UserInfo.getUserId()];
                //하자 유형 코드
                String QMCOD = '';
                switch on wo.OrderType__c {
                    when '201', '202'{
                        QMCOD = '01';
                    }
                    when '204', '218' {
                        QMCOD = '06';
                    }
                    when '214', '215' {
                        QMCOD = '10';
                    }
                    when '203'  {
                        QMCOD = '11';
                    }
                    when '216' {
                        QMCOD = '12';
                    }
                    when '217' {
                        QMCOD = '14';
                    }
                    when '219', '220' {
                        QMCOD = '20';
                    }
                    when else {
                        QMCOD = '19';
                    }
                }

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER i_header = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER();
                
                Boolean isWoInfo = true;
                if(String.isEmpty(wo.FailureAreaValue__c) 
                || String.isEmpty(wo.FailureAreaGroupValue__c) 
                || String.isEmpty(wo.FailurePhenomenonValue__c)){
                    if(String.isEmpty(wo.Case.FailureAreaValue__c) ||
                        String.isEmpty(wo.Case.FailureAreaDetailValue__c) ||  
                        String.isEmpty(wo.Case.FailurePhenomenonValue__c)){
                        system.debug('Ticket에 고장정보 없는 2번 오더');

                        cw.isSuccess = false;
                        cw.errMessage = System.Label.DNS_E_EnterTicketFailureInfo;
                        return cw;
                    }else{
                        system.debug('Ticket에 고장정보 있는 2번 오더');
                        isWoInfo = false;
                    }
                }

                if(isWoInfo){
                    i_header.QMCOD = QMCOD;// 하자유형 코드
                    i_header.WHR_YN= (wo.OrderType__c == '218' || wo.OrderType__c == '219') ? 'Y':'N'; // P-Claim 입고처리 : Y / P - Claim : N
                    i_header.OTGRP = wo.FailureAreaValue__c + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
                    i_header.OTEIL = wo.FailureAreaGroupValue__c.right(2); //고장부위 (중) Value
                    i_header.FEGRP = wo.FailureAreaValue__c + wo.FailureAreaGroupValue__c + '00'; // 대 + 중 + '00'
                    i_header.FECOD = wo.FailurePhenomenonValue__c; //고장현상 Value
                }else{
                    i_header.QMCOD = QMCOD;// 하자유형 코드
                    i_header.WHR_YN= (wo.OrderType__c == '218' || wo.OrderType__c == '219') ? 'Y':'N'; // P-Claim 입고처리 : Y / P - Claim : N
                    i_header.OTGRP = wo.Case.FailureAreaValue__c + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
                    i_header.OTEIL = wo.Case.FailureAreaDetailValue__c.right(2); //고장부위 (중) Value
                    i_header.FEGRP = wo.Case.FailureAreaValue__c + wo.Case.FailureAreaDetailValue__c + '00'; // 대 + 중 + '00'
                    i_header.FECOD = wo.Case.FailurePhenomenonValue__c; //고장현상 Value
                }

                DateTime failureDate = wo.Case.BreakdownDateTime__c != null ? wo.Case.BreakdownDateTime__c : wo.Case.ApplicationDateTime__c;
                i_header.TRBL_DT = failureDate.format('yyyyMMdd'); //'20241101'; //고장일자
                i_header.TRBL_TM = failureDate.format('HH:mm:ss'); //'110000'; //고장시간
                i_header.RECV_DT = wo.Case.ApplicationDateTime__c.format('yyyyMMdd'); //'20241101'; //접수일자
                i_header.RECV_TM = wo.Case.ApplicationDateTime__c.format('HH:mm:ss'); //'120000'; //접수시간
                i_header.LTRMN = wo.FM_RepairRequestDateTime__c.format('yyyyMMdd');//'20241101'; //수리요청일자
                i_header.LTRUR = wo.FM_RepairRequestDateTime__c.format('HH:mm:ss');//'120000'; //수리요청일시

                i_header.QMNAM = wo.Owner.Name; //상담자명(기술상담사)
                i_header.ARBPL = wo.ServiceTerritory.WCCode__c; //워크센터 코드
                i_header.DAUNO ='1'; //작업요구시간(고정값)
                i_header.S_DATE = wo.ScheduledDispatchTime__c.format('yyyyMMdd');//작업시작일자 = 출동예정일시  
                
                i_header.PERNR = wo.Worker__r.StaffNumber__c; //서비스요원 코드
                i_header.TYPBZ = wo.Asset.MachineName__c; //장비 기종
                i_header.SERNR = wo.Asset.SerialNumber; // 장비 호기정보

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2 i_header_2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2();
                i_header_2.KUNNR = wo.SoldTo__r.CustomerCode__c; // 고객사 코드
                i_header_2.NAME1 = wo.SoldTo__r.Name;//고객명
                i_header_2.POST_CODE1 = wo.Account.ShippingPostalCode; //우편번호                                       
                i_header_2.CITY1 = wo.Account.ShippingCity;                                    
                i_header_2.STREET = wo.Account.ShippingStreet;                                    
                i_header_2.ERNAM = u.EmployeeNumber; //접수자
                i_header_2.AENAM = u.EmployeeNumber; //변경자
                
                List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2> t_i_list2 = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2>();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2 tiItem2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2();
                tiItem2.TEXT = wo.ReceptionDetail__c;
                t_i_list2.add(tiItem2);


                //부품청구 내역 T_I_LIST
                List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST> t_i_list = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST>();
                List<ProductRequest> proReq = [SELECT Id, Quantity__c, Seq__c, 
                                                TransportsDivision__c, ReturnStatus__c,
                                                ProductType__c, Product__r.ProductCode, 
                                                WorkCenterId__c, WorkCenterId__r.Name
                                                FROM ProductRequest
                                                WHERE WorkOrderId =: wo.Id AND Status='Approved' 
                                                AND IsDealerPortalDelete__c = false 
                                                ORDER BY Seq__c];
                Boolean isSpin = false;
                if(proReq.size()>0){
                    // 청구된 ProductRequest의 대리점 Map
                    Set<Id> dealerIds = new Set<Id>(); 
                    for(ProductRequest pr : proReq){
                        if(String.isNotEmpty(pr.WorkCenterId__c)){
                            dealerIds.add(pr.WorkCenterId__c);
                        }
                    }

                    Map<Id, String> dealerMap = new Map<Id,String>();
                    if(!dealerIds.isEmpty()){
                        List<ServiceTerritory> dealerList = [SELECT Id, ServiceWorkCenter__c, WCCode__c FROM ServiceTerritory WHERE ServiceWorkCenter__c IN : dealerIds];
                        for(ServiceTerritory dealer : dealerList){
                            dealerMap.put(dealer.ServiceWorkCenter__c, dealer.WCCode__c);
                        }
                    }
                    
                    // 대리점점
                    List<String> transportDivisions = new List<String>{'1', '2', '3', '4'};
                    for(ProductRequest pr : proReq){
                        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST tiItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST();

                        tiItem.SPIND = String.isNotEmpty(pr.ProductType__c) ? pr.ProductType__c : ''; //스핀들구분 
                        tiItem.RSPOS = '0';// 부품예약순번
                        tiItem.MENGE = String.valueOf(pr.Quantity__c); //수량  
                        tiItem.RSNUM = '0';// 부품예약번호
                        tiItem.POSNR = pr.Seq__c; //순번 
                        tiItem.VSBED = pr.TransportsDivision__c;// 탁송구분
                        tiItem.MATNR = pr.Product__r.ProductCode; //부품번호(품번)
                        tiItem.RETURN_YN = pr.ReturnStatus__c; //폐품반납

                        String tranDiv = ''; //공급구분
                        tiItem.SUPPLY_TP = transportDivisions.contains(pr.TransportsDivision__c) ?  'N' : 'L'; // L:부품부청구(본사) , N:대리점구입(대리점)

                        if(String.isNotEmpty(pr.WorkCenterId__c) && dealerMap.containsKey(pr.WorkCenterId__c)){
                            tiItem.VENDOR = dealerMap.get(pr.WorkCenterId__c);
                        }else{
                            tiItem.VENDOR = '';
                        }

                        if(String.isNotEmpty(pr.ProductType__c)){
                            isSpin = true;
                        }
                        
                        t_i_list.add(tiItem);
                    }
                    
                }

                String warranty = '';
                if(wo.OrderType__c == '202' || wo.OrderType__c == '215' || wo.OrderType__c == '214' || wo.OrderType__c == '218'){
                    warranty = wo.Case.FM_PartsWarranty__c;
                }else{
                    warranty = wo.Case.FM_LaborWarranty__c;
                }
                
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req();
                req.I_AUFNR = wo.ServiceOrderNumber__c;
                req.I_EQUNR     = wo.Asset.Name; //장비번호 
                req.I_WARR_YN   = warranty; // 보증여부 ('Y': Under warranty, 'N': Out of warranty) 
                req.I_NEW_CLICK = 'C'; //생성 Flag('I':New create, 'C': Change)
                req.I_SOLDTO = wo.SoldTo__r.CustomerCode__c; // 고객사 코드

                req.I_SAFETY = (wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '218') ? 'X' : '';  //스핀들수리여부   
                req.I_OUT_WARR = (wo.OrderType__c == '202' || wo.OrderType__c == '215') ? 'X' : '';  //'X' : Out warranty    
                req.I_DIRECT = ((wo.OrderType__c == '202' || wo.OrderType__c == '215') && (wo.Worker__r.FM_isDirect__c)) ? 'X' : ''; // 직영유상여부               

                req.I_SKIP_SBOM = 'X'; //S-BOM
                req.I_MAT_CLICK = 'Y'; //부품청구 Falg
                if(wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '218'){ req.I_TASKLIST = wo.SPTask__c; }

                String docType = '';
                if(isSpin) {
                    docType = 'YDOR';
                } else {
                    if(wo.OrderType__c == '201'){
                        docType = 'YDCO';
                    } else if (wo.OrderType__c == '202') {
                        if (warranty == 'N') {
                            docType = 'YDOW';
                        }else {
                            docType = wo.IsDirectPaidService__c ? 'YDOW' : 'YDCO'; 
                        }
                    } else if (wo.OrderType__c == '215') {
                        docType = 'YDOW'; 
                    }  else if (wo.OrderType__c == '203' || wo.OrderType__c == '204' || wo.OrderType__c == '214' || wo.OrderType__c == '217' || wo.OrderType__c == '218') {
                        docType = 'YDCO';
                    } else if (wo.OrderType__c == '219') {
                        docType='YDVF';
                    } else {
                        docType = 'YDCO';
                    }
                }
                // if(isSpin) { //(유)스핀들 
                //     docType='YDOR';
                // } else if(wo.OrderType__c == '215'){ // 유상SP입고수리
                //     docType='YDOW';
                // } else if(wo.OrderType__c == '219'){
                //     docType='YDVF';
                // }  else if(wo.OrderType__c == '220'){
                //     docType='YDCO';
                // }  else if(req.I_DIRECT == 'X'){ //직영유상
                //     if(warranty == 'Y'){ //보증내
                //         docType='YDCO';
                //     } else { //보증외
                //         docType='YDOW';
                //     }
                // }else {
                //     docType='YDCO';
                // }
                req.I_DOC_TYPE = docType;// 영업오더유형

                req.I_HEADER = i_header;
                req.I_HEADER2 = i_header_2;
                req.T_I_LIST = t_i_list;
                req.T_I_LIST2 = t_i_list2;

                System.debug('orderTypeCS02 req ::: '+req);
                IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res res = instance.IF_CSPLUS_010(req);
                System.debug('orderTypeCS02 res ::: '+res);

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res_O_RETURN o_return = res.O_RETURN;
                String o_aufnr = res.O_AUFNR; //orderNum
                String o_qmnum = res.O_QMNUM; //notiNum

                // if(o_return.TYPE != 'S' || ){
                if(String.isEmpty(res.O_AUFNR)){
                    cw.isSuccess = false;
                    cw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
                }else{
                    cw.orderNumber = o_aufnr;
                }

            }else if(wo.OrderType__c == '801' || wo.OrderType__c == '802' || wo.OrderType__c == '803'){//IF_CSPLUS_005 : 납품 후 교육

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req wrapper = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req();
                wrapper.I_EQUNR     = wo.Asset.Name; //장비번호
                wrapper.I_SOLDTO    = wo.SoldTo__r.CustomerCode__c; //Sold To 고객코드
                wrapper.I_KTEXT     = wo.ReceptionDetail__c; //설명
                wrapper.I_PERNR     = wo.Worker__r.StaffNumber__c; //서비스요원 코드
                wrapper.I_ILART     = wo.OrderType__c; //오더 activity type
                wrapper.I_VAPLZ     = wo.ServiceTerritory.WCCode__c; //워크센터 코드
                wrapper.I_MANAGER   = wo.FM_Contact__c; //요청자명
                wrapper.I_TELF1     = wo.Case.FM_PhoneNumber__c; //업체담당전화
                wrapper.I_GSTRP     = wo.ScheduledDispatchTime__c.format('yyyyMMdd');//시작일시
                wrapper.I_GLTRP     = wo.ScheduledDispatchTime__c.format('yyyyMMdd');//시작일시
                wrapper.I_AUFNR     = wo.ServiceOrderNumber__c;//오더번호
                wrapper.I_PSTLZ     = wo.Account.ShippingPostalCode; //우편번호
                wrapper.I_ADDR1     = wo.Account.ShippingCity; //주소
                wrapper.I_ADDR2     = wo.Account.ShippingStreet; //상세주소
                wrapper.I_SWERKS    = wo.Worker__r.Service_Territory__r.PlanningPlant__c; //Service Plant 

                IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res res = instance.IF_CSPLUS_005(wrapper);  
                System.debug('res :: '+res);

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res_O_RETURN o_return = res.O_RETURN;
                String o_aufnr = res.O_AUFNR;

                if(o_return.TYPE != 'S'){
                    cw.isSuccess = false;
                    cw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
                }else{
                    cw.orderNumber = o_aufnr;
                    SendSMS__e smsEvent = new SendSMS__e(
                        WorkOrderId__c = wo.Id
                    );
                    Database.SaveResult sr = EventBus.publish(smsEvent);
                    System.debug('sr ::: '+ sr);
                }                
                
            }else if(wo.OrderType__c == '104'){//설치시운전

                String wcCode = '';
                String brachCode = '';
                if(wo.ServiceTerritory.classify__c == 'W/C'){
                    wcCode = wo.ServiceTerritory.WCCode__c;
                    brachCode = wo.ServiceTerritory.ControlWorkcenter__r.WCCode__c;
                }else{
                    wcCode = wo.ServiceTerritory.WCCode__c;
                    brachCode = wcCode;
                }                                                                                       

                IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Req req = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Req();
                req.I_EQUNR          = wo.Asset.Name; // Equipment Number
                req.I_SWERKS         = '184S';        // serviceTerritory Planning Plant
                req.I_ARBPL          = wcCode; // 직영 WorkCenter 코드
                req.I_GSTRP          = wo.ScheduledDispatchTime__c.format('yyyy-MM-dd'); // 출동요청일시
                req.I_PARNR          = wo.Worker__r.StaffNumber__c; //서비스요원 코드
                
                req.I_VBELN     = wo.Case.SalesOrder__r.ERPPSONo__c; //Sales Order Number
                req.I_WADAT     = wo.ScheduledDispatchTime__c.format('yyyy-MM-dd');
                req.I_LFDAT     = wo.ScheduledDispatchTime__c.format('yyyy-MM-dd');
                req.I_VKBUR     = brachCode; 

                req.I_SOLDTO    = wo.SoldTo__r.CustomerCode__c; // Sold To 고객코드
                req.I_AUFNR     = wo.ServiceOrderNumber__c; // Order Number
                
                IF_ERP_InstAndComm instance = new IF_ERP_InstAndComm();
                IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res res = instance.IF_CSPLUS_043(req);
                System.debug('res :: '+res);

                List<IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res_OT_RETURN> ot_return = res.OT_RETURN;
                IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res_OT_RETURN o_return = ot_return[0];
                String o_aufnr = res.O_AUFNR;

                if(o_return.TYPE != 'S'){
                    cw.isSuccess = false;
                    cw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
                }else{
                    cw.orderNumber = o_aufnr;
                }

            }else if(wo.OrderType__c == '809' || wo.OrderType__c == '106' || wo.OrderType__c == '103'){//설치검수, 순회서비스, 정기점검
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req();
                req.I_EQUNR     = wo.Asset.Name;
                req.I_KTEXT     = wo.ReceptionDetail__c;
                req.I_PERNR     = wo.Worker__r.StaffNumber__c;
                req.I_ILART     = wo.OrderType__c;
                req.I_VAPLZ     = wo.ServiceTerritory.WCCode__c;
                req.I_GSTRP     = wo.ScheduledDispatchTime__c.format('yyyyMMdd');
                req.I_KUNUM     = wo.Account.CustomerCode__c;//soldTo
                req.I_AUFNR     = wo.ServiceOrderNumber__c;
                req.I_SWERKS    = wo.Worker__r.Service_Territory__r.PlanningPlant__c;

                IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res res = instance.IF_CSPLUS_042(req);

                System.debug('res :: '+res);

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res_O_RETURN o_return = res.O_RETURN;
                String o_aufnr = res.O_AUFNR;

                if(o_return.TYPE != 'S'){
                    cw.isSuccess = false;
                    cw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
                }else{
                    cw.orderNumber = o_aufnr;
                }
                
            }
            
            //DNSA
            if(wo.PMActivityType__c == 'HS01'){
                Id userID = UserInfo.getUserId();
                User u = [SELECT Id, Name, EmployeeNumber, ERP_Key__c FROM User WHERE ID = :userID];

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER header = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER();
                header.AUFNR        = wo.ServiceOrderNumber__c;
                header.QMNUM        = '000'+ wo.Noti_Number__c;
                header.ILART        = '699';
                DateTime failureDate = wo.Case.BreakdownDateTime__c != null ? wo.Case.BreakdownDateTime__c : wo.Case.ApplicationDateTime__c;
                header.FAIL_DT      = failureDate.format('yyyyMMdd'); //고장일자 
                header.FAIL_TM      = failureDate.format('HH:mm:ss'); //고장시간 
                header.QMDAT        = wo.Case.ApplicationDateTime__c.format('yyyyMMdd'); //접수일자     
                header.REG_TIME     = wo.Case.ApplicationDateTime__c.format('HH:mm:ss'); //접수시간
                header.REQUIRE_DAT  = wo.ScheduledDispatchTime__c.format('yyyyMMdd'); //출동일자(수리요청일자)
                header.REQUIRE_TIM  = wo.ScheduledDispatchTime__c.format('HH:mm:ss'); //출동일시(수리요청일시)
                header.ARRVAL_DT    = wo.RepairStartDate__c != null ? String.valueOf(wo.RepairStartDate__c).replace('-', '') : ''; //작업시작일시(도착시간)
                header.FAIL_END_DT  = wo.RepairEndDate__c != null ? String.valueOf(wo.RepairEndDate__c).replace('-', '') : ''; //작업완료시간
                header.REPORTEDBY   = u.EmployeeNumber;
                header.TYPBZ        = wo.Asset.MachineName__c; //장비기종
                header.SERNR        = wo.Asset.SerialNumber; //장비번호
                header.BREAKDOWN    = wo?.isMachineDown__c == true ? 'X' : '';

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO userInfo = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO();
                userInfo.BNAME      = u.Id;//'CS_DMTA'; // User Name in User Master Record -> LOG 저장용
                userInfo.RNAME      = String.valueOf(u.ERP_Key__c); //User Name in User Master Record -> LOG 저장용
                userInfo.NAME1      = wo.SoldTo__r.Name; //고객사 이름
                userInfo.WAERS      = 'USD'; // Currency Key
                userInfo.ARBPL      = '1262215'; //Work Center 코드 고정
                userInfo.KUNN2      = wo.SoldTo__r.CustomerCode__c; //고객번호 
                userInfo.LAND1      = 'US'; // Country Key
                userInfo.REGIO      = 'CA'; // Region (State, Province, County)
                userInfo.WERKS      = '414S'; //Plant 정보 고정
                userInfo.VERAN      = '440'; // Person responsible for the work center
                userInfo.DF_CHK     = 'X'; // Default Check
                userInfo.FOREIGN    = 'X'; // Land Gubun Code
                userInfo.ERDAT      = wo.CreatedDate.format('yyyyMMdd'); //Date on Which Record Was Created ???
                userInfo.ERNAM      = u.EmployeeNumber; // 접수자

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> t_claim_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> ();
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM claim = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM();
                claim.CLAIM_SEQ = '0001'; //Claim Seq
                claim.CODE_01 = wo.FailureAreaValue__c; //고장부위(대)
                claim.CODE_03 = wo.FailureAreaGroupValue__c.right(2); //고장부위 (중) Value
                claim.OTGRP = wo.FailureAreaValue__c + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
                claim.OTEIL = wo.FailureAreaGroupValue__c.right(2); //고장부위 (중) Value
                claim.KURZTEXT  = wo.FailureArea__c + ' - ' + wo.FailureAreaGroup__c;
                claim.FEGRP = wo.FailureAreaValue__c + wo.FailureAreaGroupValue__c + '00'; // 대 + 중 + '00'
                claim.FECOD = wo.FailurePhenomenonValue__c; //고장현상 Value
                claim.FETXT = wo.FailurePhenomenonDetail__c; //Notification Item Short Text
                claim.URGRP     = wo.FailureAreaValue__c + wo.FailureAreaGroupValue__c + wo.FailurePhenomenonValue__c; // Code Group - Causes
                claim.URCOD     = wo.CauseOfFailureValue__c; //Cause Code
                claim.URTXT     = wo.CauseOfFailureDetail__c; //Short Text for Cause Code
                claim.MNGRP     = '90000000'; //Code Group - Activities
                claim.MNCOD     = wo.RepairActionValue__c; //Activity Code
                claim.MATXT     = wo.PendingOrCustomerMatters__c;
                t_claim_list.add(claim);

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE> t_date_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE> ();
                List<WorkOrderResult__c> whList =  [SELECT Id, Name, WorkOrder__c, WorkCenter__c, ResultType__c, CreatedDate, WorkOrder__r.WorkOrderNumber, 
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
                                    WHERE ResultType__c = 'WH' AND WorkOrder__c = :recordId
                                    ORDER BY SaKey__c, WorkStartTime__c];
                if(whList.size()>0){
                    for(WorkOrderResult__c work : whList){
                        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE t_date = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE();
                        t_date.AUFNR = wo.ServiceOrderNumber__c;
                        t_date.QMNUM = wo.Noti_Number__c;
                        t_date.REP_FR_DT    = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                        t_date.REP_FR_TM    = work.WorkStartTime__c != null ? String.valueOf(work.WorkStartTime__c).replace('-', '') : '';
                        t_date.REP_TO_DT    = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                        t_date.REP_TO_TM    = work.WorkEndTime__c != null ? String.valueOf(work.WorkEndTime__c).replace('-', '') : '';
                        t_date.ISMNW        = work.WorkTime__c != null ? work.WorkTime__c : '';
                        t_date.ISMNW_PDK    = work.TravelHour__c != null ? work.TravelHour__c : '';
                        t_date.AIR_TRIP     = work.AirTrip__c != null && work.AirTrip__c == 'Yes' ? 'Y' : 'N';
                        t_date_list.add(t_date);
                    }
                }

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART> t_part_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART> ();
                List<WorkOrderResult__c> ptList =  [SELECT Id, Name, WorkOrder__c, WorkCenter__c, ResultType__c, CreatedDate, WorkOrder__r.WorkOrderNumber, 
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
                                    WHERE ResultType__c = 'PT' AND WorkOrder__c = :recordId
                                    ORDER BY SaKey__c, WorkStartTime__c];

                if(ptList.size()>0){
                    for(WorkOrderResult__c work : ptList){
                        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART t_part = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART();
                        t_part.SEQNO        = '0001';
                        t_part.MATNR        = work.ProductName__c != null ? work.ProductName__c : '';
                        t_part.MENGE        = work.Quantity__c != null ? String.valueOf(work.Quantity__c) : '';
                        t_part.CAUSE_PRT    = work.IsCause__c == true ? 'X' : '';
                        t_part.RETURN_TEXT  = work.Note__c != null ? work.Note__c : '';
                        t_part.AUFNR        = wo.ServiceOrderNumber__c;
                        t_part_list.add(t_part);
                    }
                }

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP> t_tmp_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP> ();
                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE> t_file_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE> ();

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req req = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req();
                req.I_UNAME = 'CS_DMTA';
                req.I_LANGU = 'E';
                req.I_USERINFO = userInfo;
                req.I_HEADER   = header;
                req.T_CLAIM = t_claim_list;
                req.T_DATE  = t_date_list;
                req.T_PART  = t_part_list;
                req.T_TMP = t_tmp_list;
                req.T_FILE = t_file_list;

                IF_ERP_SalesOrder execute = new IF_ERP_SalesOrder();
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res res = execute.IF_CSPLUS_044(req);
                System.debug('res :: '+res);

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_O_RETURN o_return = res.O_RETURN;
                if(o_return.TYPE != 'S'){
                    System.debug('IF_CSPLUS_044 INTERFACE ERROR : '+o_return.MESSAGE);
                    cw.isSuccess = false;
                    cw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
                }else{
                    cw.orderNumber = wo.ServiceOrderNumber__c;
                }
            }

            wo.isIFSuccess__c = cw.isSuccess;
            System.debug('WorkORder isIFSuccess__c : '+wo.isIFSuccess__c);
            update wo;

        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber() +'_'+ e.getMessage();
        }

        return cw;
    }

     /*
     * @Description 
     *  - 공용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 		: 성공여부
     *  - errMessage 	    : 에러메시지
     *  - orderNumber 	    : Service Order ERP Number
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		    {get; set;}
        @AuraEnabled
        public String errMessage		    {get; set;} 
        @AuraEnabled    
        public String orderNumber		    {get; set;}
        

        
        public CommonWrapper(){
            this.isSuccess 		            = true;
            this.errMessage 	            = '';
            this.orderNumber 	            = '';
        }
    }

}