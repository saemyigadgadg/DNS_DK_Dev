/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-05-07
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
public without sharing class DN_NewWorkOrderController {

    /**
     * @Description
     * 	- New Work Order 화면의 URL에서 TicketID DECODING
     * @Parameter
     *  - base64String : URL의 Parameter
    **/ 
    @AuraEnabled
    public static CommonWrapper decodeTicketId(String base64String){
        CommonWrapper cw = new CommonWrapper();
        try {
            if(base64String.contains('.')){
                String[] parts = base64String.split('\\.');
                base64String = parts[1];
            }

            Blob decodedBlob = EncodingUtil.base64Decode(base64String);
            String decodedString = decodedBlob.toString();
            
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(decodedString);

            if (jsonData.containsKey('attributes')) {
                Map<String, Object> attributes = (Map<String, Object>) jsonData.get('attributes');
                String recordId = (String) attributes.get('recordId');
                System.debug('Extracted Record ID: ' + recordId); // ticketID
                cw.returnValue = recordId;
            }
        }catch (Exception e) {
            System.debug(e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = 'getTIcketID Error : '+e.getMessage();
        }
        return cw;
    }


    /**
     * @Description
     * 	- 상위 Ticket 정보 추출
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getTicketInfo(String ticketId){
        CommonWrapper cw = new CommonWrapper();
        try{
            Case ticket = [
                SELECT 
                FM_Country__c, Status, TicketType__c, InternalTicketType__c, Requester__c,
                FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c,
                SalesOrder__c, SalesOrder__r.ShipTo_PSO__c, 
                FM_EquipmentWarranty__c, FM_LaborWarranty__c, FM_PartsWarranty__c,
                RepairRequestDateTime__c, BreakdownDateTime__c, ApplicationDateTime__c,
                AssetId, Asset.SoldTo__c, Asset.MachineName__c, Asset.SoldTo__r.RecordType.Name, Asset.Order__c,
                AccountId, Account.AccountGroup__c, RecordType.DeveloperName
                FROM CASE
                WHERE ID = :ticketId
            ];
            System.debug('ticket :: '+ticket );

            //Validation 확인해서 False면 ERROR 
            cw = checkValidation(ticket);
            if(!cw.isSuccess) return cw;


            //DNSA 오더 생성
            if(ticket.FM_Country__c == 'DNSA'){
                cw.isDNSA = true;
                cw.recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder' AND DeveloperName = 'WorkOrder_DNSA'].Id;
                cw.assetId      = ticket.AssetId;
                cw.model        = ticket.Asset.MachineName__c;
                cw.dispatchTime = ticket.RepairRequestDateTime__c;
                cw.shipTo       = ticket.AccountId;
                cw.soldTo       = ticket.Asset.SoldTo__c; //미국은 일단 장비의 Sold To 정보 가져오기
                cw.ticketType   = ticket.InternalTicketType__c;
                cw.warranty     = ticket.FM_EquipmentWarranty__c;
                cw.orderType    = '601';
                System.debug('cw :: '+cw );
            }

            //국내 오더 생성
            if(ticket.FM_Country__c == 'DNS'){
                cw.recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder' AND DeveloperName = 'WorkOrder_Domestic'].Id;
                cw.assetId      = ticket.AssetId;
                cw.model        = ticket.Asset.MachineName__c;
                cw.warranty     = ticket.FM_EquipmentWarranty__c;
                cw.dispatchTime = ticket.RepairRequestDateTime__c;
                cw.shipTo       = ticket.AccountId;
                cw.salesOrder   = ticket.Asset.Order__c;
                cw.ticketType = ticket.InternalTicketType__c;
                
                //Ticket Type에 따른 PM Activity Type Default Setting
                cw.orderType = checkPMType(ticket.FM_LaborWarranty__c, ticket.InternalTicketType__c);
                System.debug('cw.orderType ::: '+ cw.orderType);

                //Sold To 정보 Mapping
                if(cw.orderType == '104'){ 
                    //설치시운전은 Sales Order의 Ship To을 Sold To에 Mapping & Sales Order 정보 보여주기
                    if(String.isNotEmpty(ticket.SalesOrder__c)){
                        //Ticket의 Sales Order의 Ship to 
                        String soId = ticket.SalesOrder__c;
                        Order so = [SELECT Id, OrderNumber, ERPOrderNo__c,
                                ShipTo_PSO__c, ShipTo_PSO__r.RecordType.Name, 
                                ShipTo_PSO__r.Name, ShipTo_PSO__r.CustomerCode__c,
                                SoldTo__c, SoldTo__r.Name, SoldTo__r.CustomerCode__c,
                                SoldTo__r.RecordType.Name
                        FROM Order WHERE Id = :soId];
                        
                        cw.soldTo = so.ShipTo_PSO__c;
                        cw.soldToRecordType = so.ShipTo_PSO__r.RecordType.Name; 
                        
                        cw.salesOrder = so.Id;
                        cw.soNumber = so.ERPOrderNo__c;
                        cw.soShipToId = so.ShipTo_PSO__c;
                        cw.soShipTo = so.ShipTo_PSO__r.Name;
                        cw.soShipToCode = so.ShipTo_PSO__r.CustomerCode__c;
                        cw.soSoldTo = so.SoldTo__r.Name;
                        cw.soSoldToCode = so.SoldTo__r.CustomerCode__c;

                        if(so.SoldTo__r.RecordType.Name == 'Dealer'){
                            cw.soSoldToRecordType = '대리점입니다.';
                        }
                        if(so.ShipTo_PSO__r.RecordType.Name == 'Trade Customer'){
                            cw.soShipToRecordType = '실고객';
                        }else if(so.ShipTo_PSO__r.RecordType.Name == 'Ship to Party'){
                            cw.soShipToRecordType = '배송처';
                        }

                    }
                }else if(cw.orderType == '809' || cw.orderType == '801'){
                    //설치검수와 납품후교육 무상은 장비의 Sold To를 우선으로 Mapping & Sales Order 정보 보여주기
                    //장비에 Sold To 정보 없으면 Sales Order의 Ship To를 Sold To에 Mapping 
                    if(String.isNotEmpty(ticket.SalesOrder__c)){
                        Order so = [SELECT Id, OrderNumber, ERPOrderNo__c,
                                    ShipTo_PSO__c, ShipTo_PSO__r.RecordType.Name, 
                                    ShipTo_PSO__r.Name, ShipTo_PSO__r.CustomerCode__c,
                                    SoldTo__c, SoldTo__r.Name, SoldTo__r.CustomerCode__c,
                                    SoldTo__r.RecordType.Name
                            FROM Order WHERE Id = :ticket.SalesOrder__c];

                        cw.salesOrder = so.Id;
                        cw.soNumber = so.ERPOrderNo__c;
                        cw.soShipToId = so.ShipTo_PSO__c;
                        cw.soShipTo = so.ShipTo_PSO__r.Name;
                        cw.soShipToCode = so.ShipTo_PSO__r.CustomerCode__c;
                        cw.soSoldTo = so.SoldTo__r.Name;
                        cw.soSoldToCode = so.SoldTo__r.CustomerCode__c;

                        if(so.SoldTo__r.RecordType.Name == 'Dealer'){
                            cw.soSoldToRecordType = '대리점입니다.';
                        }
                        if(so.ShipTo_PSO__r.RecordType.Name == 'Trade Customer'){
                            cw.soShipToRecordType = '실고객';
                        }else if(so.ShipTo_PSO__r.RecordType.Name == 'Ship to Party'){
                            cw.soShipToRecordType = '배송처';
                        }

                        cw.soldTo = so.ShipTo_PSO__c;
                        cw.soldToRecordType = so.ShipTo_PSO__r.RecordType.Name; 
                    }

                    if(String.isNotEmpty(ticket.Asset.SoldTo__c)){
                        cw.soldTo = ticket.Asset.SoldTo__c;
                        cw.soldToRecordType = ticket.Asset.SoldTo__r.RecordType.Name;
                    }
                }else{
                    //그 외에는 장비의 Sold To를 Mapping & Record Type 고려할 필요 없음
                    cw.soldTo = ticket.Asset.SoldTo__c;
                }

                List<Map<String, String>> results = new List<Map<String, String>>();

                // WorkOrder 오브젝트의 OrderType__c 필드 Describe
                Schema.DescribeFieldResult fieldResult = WorkOrder.OrderType__c.getDescribe();
                List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();

                // Controlling 필드 TicketType__c Describe
                Schema.DescribeFieldResult ctrlField = WorkOrder.TicketType__c.getDescribe();
                List<Schema.PicklistEntry> ctrlValues = ctrlField.getPicklistValues();

                // Controlling 값(ticketTypeValue)의 인덱스 찾기
                Integer ctrlIndex = -1;
                for (Integer i = 0; i < ctrlValues.size(); i++) {
                    if (ctrlValues[i].getValue() == cw.ticketType) {
                        ctrlIndex = i;
                        break;
                    }
                }

                // Dependent Picklist 필터링
                for (Schema.PicklistEntry entry : values) {
                    if (entry.isActive()) {
                        Map<String, String> option = new Map<String, String>();
                        option.put('label', entry.getLabel());
                        option.put('value', entry.getValue());
                        results.add(option);
                    }
                }
                cw.orderTypeList = results;
            }

        } catch(Exception e){
           System.debug(e.getMessage());
           cw.isSuccess = false;
           cw.errMessage = e.getLineNumber() +'__'+ e.getMessage();
        }
        return cw;
    }


    /*
     * @Description
     *  - Sold To 또는 Sales Order 정보 가져오기
     * 
     * @Parameter
     *  - soldTo	    : soldTo(Account) Id
     */ 
    @AuraEnabled
    public static CommonWrapper getSoldToInfo(String ticketId, String orderType){
        CommonWrapper cw = new CommonWrapper();
        try {
            Case ticket = [SELECT Id, SalesOrder__c, AssetId, Asset.SoldTo__c, Asset.SoldTo__r.RecordType.Name FROM Case WHERE Id = : ticketId];

            if(orderType == '801' || orderType == '809' || orderType == '104'){
                if(String.isNotEmpty(ticket.SalesOrder__c)){
                    Order so = [SELECT Id, ERPOrderNo__c, 
                                ShipTo_PSO__c, ShipTo_PSO__r.Name, ShipTo_PSO__r.CustomerCode__c, ShipTo_PSO__r.RecordType.Name, 
                                soldTo__c, SoldTo__r.Name, SoldTo__r.CustomerCode__c, SoldTo__r.RecordType.Name
                                FROM Order WHERE ID = :ticket.SalesOrder__c];
                    cw.salesOrder = so.Id;
                    cw.soNumber = so.ERPOrderNo__c;
                    cw.soShipToId = so.ShipTo_PSO__c;
                    cw.soShipTo = so.ShipTo_PSO__r.Name;
                    cw.soShipToCode = so.ShipTo_PSO__r.CustomerCode__c;
                    cw.soSoldTo = so.SoldTo__r.Name;
                    cw.soSoldToCode = so.SoldTo__r.CustomerCode__c;

                    if(so.SoldTo__r.RecordType.Name == 'Dealer'){
                        cw.soSoldToRecordType = '대리점입니다.';
                    }
                    if(so.ShipTo_PSO__r.RecordType.Name == 'Trade Customer'){
                        cw.soShipToRecordType = '실고객';
                    }else if(so.ShipTo_PSO__r.RecordType.Name == 'Ship to Party'){
                        cw.soShipToRecordType = '배송처';
                    }

                    cw.soldTo = so.ShipTo_PSO__c;
                    cw.soldToRecordType = so.ShipTo_PSO__r.RecordType.Name;
                }

                if(String.isNotEmpty(ticket.Asset.SoldTo__c) && (orderType == '801' || orderType == '809')){
                    cw.soldTo = ticket.Asset.SoldTo__c;
                    cw.soldToRecordType = ticket.Asset.SoldTo__r.RecordType.Name;
                }
                
            }else{
                cw.soldTo = ticket.Asset.SoldTo__c;
            }

        } catch (Exception e) {
            System.debug(e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber() +'__'+ e.getMessage();
        }
        return cw;
    }

    /*
     * @Description
     *  - 선택한 SoldTo의 RecordType 정보 반환
     * 
     * @Parameter
     *  - soldTo	    : soldTo(Account) Id
     */ 
    @AuraEnabled
    public static CommonWrapper getSoldToRecordType(String soldTo){
        CommonWrapper cw = new CommonWrapper();
        try {
            Account soldToAcc = [SELECT Id, RecordType.Name FROM Account WHERE Id = :soldTo];
            cw.soldTo = soldToAcc.Id;
            cw.soldToRecordType = soldToAcc.RecordType.Name;
        } catch (Exception e) {
            System.debug(e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        System.debug('cw'+cw);
        return cw;
    }


    /*
     * @Description
     * 	- Work Order 생성
     * 
     * @Parameter
     *  - workOrderData	    : Work Order 정보
     */
    @AuraEnabled
    public static CommonWrapper saveWorkOrder(String isDNSAParam, String workOrderData){
        CommonWrapper cw = new CommonWrapper();
        try {
           

            Boolean isDNSA = Boolean.valueOf(isDNSAParam);
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(workOrderData);

            System.debug('isDNSA'+isDNSA);
            if(isDNSA){
                WorkOrder newRecord = new WorkOrder();
                newRecord.PMActivityType__c = 'HS01';   
                newRecord.Country__c = 'DNSA';   
                for (String fieldName : fieldMap.keySet()) {
                    String fieldType = getFieldType(fieldName);
                    if(fieldType != 'formula' && fieldMap.get(fieldName) != null) {
                        switch on fieldType {
                            when 'LONG', 'INTEGER'{
                                String IntegerValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Integer.valueOf(IntegerValue));
                            }
                            when 'DOUBLE', 'CURRENCY', 'PERCENT'{
                                String decimalValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Double.valueOf(decimalValue));
                            }
                            when 'DATE' {
                                String dateValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Date.valueOf(dateValue));
                            }
                            when 'DATETIME'  {
                                String datetimeValue = (String) fieldMap.get(fieldName);
                                DateTime localDatetime = changeDatetime(datetimeValue);
                                newRecord.put(fieldName, localDatetime);
                            }
                            when 'BOOLEAN' {
                                newRecord.put(fieldName, fieldMap.get(fieldName));
                            }
                            when else {
                                newRecord.put(fieldName, fieldMap.get(fieldName));
                            }
                        }
                        
                    }
                }

                String ticketId = (String) fieldMap.get('CaseId');
                String soldTo = (String) fieldMap.get('SoldTo__c');
                String dispatchTimeStr = (String) fieldMap.get('ScheduledDispatchTime__c');
                System.debug('dispatchTimeStr :: '+dispatchTimeStr);
                System.debug('soldTo :: '+soldTo);
                DateTime dispatchTime = changeDatetime(dispatchTimeStr);

                //DNSA Service Order 생성 I/F
                IFWrapper ifw = IF_CSPLUS_044(ticketId, dispatchTime, soldTo);
                System.debug('ifw.ifResult : '+ifw.ifResult);
                cw.returnAll = ifw.ifResult;
                Case ticket = [SELECT Id, Status FROM Case WHERE Id = :ticketId];
                if(ifw.isSuccess){
                    newRecord.ServiceOrderNumber__c = ifw.returnValue;
                    newRecord.Noti_Number__c = ifw.notiNum;
                    insert newRecord;
                    System.debug('newRecord : '+newRecord);

                    ticket.Status = 'Assignment completed';
                    update ticket;
                    cw.returnValue = newRecord.Id;
                }else{
                    cw.isSuccess = false;
                    cw.errMessage = ifw.errMessage;
                }
            }else{

                String orderType = (String) fieldMap.get('OrderType__c');
                String assetId = (String) fieldMap.get('AssetId');
                String accountId = (String) fieldMap.get('AccountId');
                String serviceResourceId = (String) fieldMap.get('Worker__c');
                String ticketId = (String) fieldMap.get('CaseId');
                String soldTo = (String) fieldMap.get('SoldTo__c');
                String dispatchTimeStr = (String) fieldMap.get('ScheduledDispatchTime__c');
                String spTask = (String) fieldMap.get('SPTask__c');
                Boolean isDirect = (Boolean) fieldMap.get('IsDirectPaidService__c');
                
                //Case ticketInfo = [ SELECT ID, InternalTicketType__c,  DeliveryOrder__r.DeliveryDate__c FROM Case WHERE ID =: ticketId ];

                //장비의 고객과 Ticket의 고객정보가 다르면 에러 메시지 표현 
                //하지만 장비에 고객정보가 없을 때는 비교 안함
                Asset equip = [SELECT Id, AccountId FROM Asset WHERE ID = :assetId];
                System.debug('order Type :: '+orderType);
                if((orderType != '104') && (orderType != '801') && (orderType != '809') && (orderType != '810')){
                    if((!String.isEmpty(equip.AccountId)) && (accountId != equip.AccountId)){
                        cw.isSuccess = false;
                        cw.errMessage = System.Label.DNS_E_CheckAccountEquipmentInfo;
                        return cw;
                    }
                }

                Case upperTicket = [SELECT Id, FM_LaborWarranty__c, FM_PartsWarranty__c, FM_EquipmentWarranty__c FROM Case WHERE ID = :ticketId];
                //입고수리는 장비의 부품 보증정보 기반으로 접수
                if(orderType == '214' && upperTicket.FM_PartsWarranty__c == 'N'){
                    cw.isSuccess = false;
                    cw.errMessage = System.Label.DNS_E_CheckPartsWarranty;
                    return cw;
                }

                //입고수리를 제외하고는 장비의 공임정보를 기반으로 접수 => 유상의 경우, 무상오더를 생성시 에러 발생
                if((orderType == '201' || orderType == '801') && upperTicket.FM_LaborWarranty__c == 'N'){
                    cw.isSuccess = false;
                    cw.errMessage = System.Label.DNS_E_CheckLaborWarranty;
                    return cw;
                }

                //직영유상일 때 서비스요원이 직영소속인지 확인하는 Validation 추가
                ServiceResource resource = [SELECT ID, Service_Territory__r.isDirect__c FROM ServiceResource WHERE ID = :serviceResourceId];
                if(!resource.Service_Territory__r.isDirect__c && orderType == '215' ){
                    cw.isSuccess = false;
                    cw.errMessage = System.Label.DNS_E_NoDirectResource;
                    return cw;
                }

                System.debug('dispatchTimeStr :: '+dispatchTimeStr);
                DateTime dispatchTime = changeDatetime(dispatchTimeStr);
                System.debug('dispatchTime :: '+dispatchTime);
                Boolean hasSkill = false;
                
                // 출동 요청일시가 현재 시간보다 작을 경우 Validation - 2025.02.28 Sangil, Park
                // 초 단위 까지 고려하여 -1 Minutes 한것이니 수정하지 말것
                if(DateTime.Now().addMinutes(-1) > dispatchTime){
                    cw.isSuccess 	= false;
                    cw.errMessage 	= System.Label.DNS_E_CheckDispatchTime;
                    return cw;
                }

                if(orderType == '104'){//설치시운전일 때 Skill 정보 확인
                    hasSkill = getResourceSkillInfo(assetId, serviceResourceId);
                }else if(orderType == '217'){
                    //부품만 청구일 때 부품보증이 Y가 아니면 에러 발생
                    Case ticket = [SELECT Id, FM_LaborWarranty__c, FM_PartsWarranty__c, FM_EquipmentWarranty__c FROM Case WHERE ID = :ticketId];
                    String partsWarranty = ticket.FM_PartsWarranty__c;
                    if(partsWarranty == 'N'){
                        cw.isSuccess = false;
                        cw.errMessage = System.Label.DNS_E_ChargeOnlyParts;
                        return cw;
                    }else if(partsWarranty == ''){
                        cw.isSuccess = false;
                        cw.errMessage = System.Label.DNS_E_CheckWarranty;
                        return cw;
                    }
                }else if(orderType == '204' || orderType == '218' || orderType == '219' || orderType == '220' || orderType == '803' || orderType == '203'){
                    //P-Claim과 납품후교육정책은 특정 사용자만 사용 가능
                    String pclaimRule = [SELECT Id FROM AssignmentRule__c WHERE Name = 'P-Claim 사용자' LIMIT 1].Id;
                    if(String.isNotEmpty(pclaimRule)){
                        List<AssignmentMember__c> pclaimUser = [SELECT Id, User__c FROM AssignmentMember__c WHERE AssignmentRule__c = :pclaimRule];
                        Set<Id> userIds = new Set<Id>();
                        for (AssignmentMember__c u : pclaimUser) {
                            userIds.add(u.User__c);
                        }
                        Boolean isCurrentUserInList = userIds.contains(UserInfo.getUserId());

                        if(!isCurrentUserInList){
                            cw.isSuccess = false;
                            cw.errMessage = System.Label.DNS_E_NoRightPClaim;
                            return cw;
                        }

                    }
                }
                
                if(hasSkill || orderType != '104'){
                    WorkOrder newRecord = new WorkOrder();
                    for (String fieldName : fieldMap.keySet()) {
                        String fieldType = getFieldType(fieldName);
                        newRecord.Country__c = 'DNS';   
                        if(fieldType != 'formula' && fieldMap.get(fieldName) != null) {
                            switch on fieldType {
                                when 'LONG', 'INTEGER'{
                                    String IntegerValue = (String) fieldMap.get(fieldName);
                                    newRecord.put(fieldName, Integer.valueOf(IntegerValue));
                                }
                                when 'DOUBLE', 'CURRENCY', 'PERCENT'{
                                    String decimalValue = (String) fieldMap.get(fieldName);
                                    newRecord.put(fieldName, Double.valueOf(decimalValue));
                                }
                                when 'DATE' {
                                    String dateValue = (String) fieldMap.get(fieldName);
                                    newRecord.put(fieldName, Date.valueOf(dateValue));
                                }
                                when 'DATETIME'  {
                                    String datetimeValue = (String) fieldMap.get(fieldName);
                                    DateTime localDatetime = changeDatetime(datetimeValue);
                                    newRecord.put(fieldName, localDatetime);
                                }
                                when 'BOOLEAN' {
                                    newRecord.put(fieldName, fieldMap.get(fieldName));
                                }
                                when else {
                                    newRecord.put(fieldName, fieldMap.get(fieldName));
                                }
                            }
                            
                        }
                    }

                    String frontNum = newRecord.OrderType__c.left(1);
                    switch on frontNum{
                        when '1'{
                            newRecord.PMActivityType__c = 'CS01';
                        }
                        when '2'{
                            newRecord.PMActivityType__c = 'CS02';
                        }
                        when '8'{
                            newRecord.PMActivityType__c = 'CS08';
                        }
                        when else{
                            newRecord.PMActivityType__c = 'HS01';
                        }
                    }
                    newRecord.Status = 'Assigned';  

                    Case ticket = [SELECT Id, Status FROM Case WHERE Id = :ticketId];
                    //납품 후 교육
                    if(orderType == '801' || orderType == '802' || orderType == '803'){//납품 후 교육
                        IFWrapper ifw = IF_CSPLUS_005(ticketId, orderType, serviceResourceId, soldTo, dispatchTime);
                        cw.returnAll = ifw.ifResult;
                        if(ifw.isSuccess){
                            newRecord.ServiceOrderNumber__c = ifw.returnValue;
                            insert newRecord;
                            System.debug('newRecord : '+newRecord);
    
                            ticket.Status = 'Assignment completed';
                            update ticket;
                            cw.returnValue = newRecord.Id;
                        }else{
                            cw.isSuccess = false;
                            cw.errMessage = ifw.errMessage;
                        }
                    }

                    //설치검수, 순회서비스, 정기점검, (HE Care => 정기점검으로 변경)
                    if(orderType == '809' || orderType == '106' || orderType == '103' || orderType == '810'){
                        IFWrapper ifw = IF_CSPLUS_042(ticketId, orderType, serviceResourceId, dispatchTime, soldTo);
                        if(ifw.isSuccess){
                            newRecord.ServiceOrderNumber__c = ifw.returnValue;
                            newRecord.Noti_Number__c = ifw.notiNum;
                            insert newRecord;
                            System.debug('newRecord : '+newRecord);
    
                            ticket.Status = 'Assignment completed';
                            update ticket;
                            cw.returnValue = newRecord.Id;
                        }else{
                            cw.isSuccess = false;
                            cw.errMessage = ifw.errMessage;
                        }
                    }

                    //CS02번 
                    if(orderType == '201' || orderType == '202' || orderType == '203' || orderType == '204'
                    || orderType == '214' || orderType == '215' || orderType == '217' || orderType == '216' || orderType == '218'
                    || orderType == '219' || orderType == '220'){
                        IFWrapper ifw = IF_CSPLUS_010(ticketId, orderType, serviceResourceId, dispatchTime, soldTo, spTask, isDirect);
                        if(ifw.isSuccess){
                            newRecord.ServiceOrderNumber__c = ifw.returnValue;
                            newRecord.Noti_Number__c = ifw.notiNum;
                            insert newRecord;
                            System.debug('newRecord : '+newRecord);
    
                            ticket.Status = 'Assignment completed';
                            update ticket;
                            cw.returnValue = newRecord.Id;
                        }else{
                            cw.isSuccess = false;
                            cw.errMessage = ifw.errMessage;
                        }
                    }

                    if(orderType == '104'){
                        IFWrapper ifw = IF_CSPLUS_036(ticketId, serviceResourceId, dispatchTime, soldTo);
                        if(ifw.isSuccess){
                            newRecord.ServiceOrderNumber__c = ifw.returnValue;
                            insert newRecord;
                            System.debug('newRecord : '+newRecord);
    
                            ticket.Status = 'Assignment completed';
                            update ticket;
                            cw.returnValue = newRecord.Id;
                        }else{
                            cw.isSuccess = false;
                            cw.errMessage = ifw.errMessage;
                        }
                    }

                }else{
                    cw.isSuccess = false;
                    cw.errMessage = System.Label.DNS_E_InstallerNoSkill;
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber()+'_'+e.getMessage();
        }
        System.debug('cw'+cw);
        return cw;
    }

    //======== INTERFACE ============================================================================= 
    /**
     * @Description
     * 	- CS08 중 납품 후 교육 Work Order 생성 I/F
     * @author Hayeong Min 
    **/
    private static IFWrapper IF_CSPLUS_005 (String ticketId, String orderType, String serviceResourceId, String soldTo, DateTime dispatchTime){
        IFWrapper iw = new IFWrapper();
        ServiceResource resouce = [SELECT Id, StaffNumber__c, Service_Territory__c, Service_Territory__r.WCCode__c, Service_Territory__r.PlanningPlant__c FROM ServiceResource WHERE Id = :serviceResourceId];
        Case ticket = [SELECT Id, Status, Requester__c, ReceptionDetails__c,
                            Requester__r.Name, FM_PhoneNumber__c, 
                            AssetId, Asset.Name, TrainingDateTime1__c, AccountId FROM Case WHERE Id = :ticketId];
        Account acc = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode,ShippingCity, ShippingStreet FROM Account WHERE ID = :soldTo];
        Account shipTo = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode,ShippingCity, ShippingStreet FROM Account WHERE ID = :ticket.AccountId];

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req wrapper = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req();
        wrapper.I_EQUNR     = ticket.Asset.Name; //장비번호
        wrapper.I_SOLDTO    = acc.CustomerCode__c; //Sold To 고객코드
        wrapper.I_KTEXT     = ticket.ReceptionDetails__c; //설명
        wrapper.I_PERNR     = resouce.StaffNumber__c; //서비스요원 코드
        wrapper.I_ILART     = orderType; //오더 activity type
        wrapper.I_VAPLZ     = resouce.Service_Territory__r.WCCode__c; //워크센터 코드
        wrapper.I_MANAGER   = ticket.Requester__r.Name; //요청자명
        wrapper.I_TELF1     = ticket.FM_PhoneNumber__c; //업체담당전화
        wrapper.I_PSTLZ     = shipTo.ShippingPostalCode; //우편번호
        wrapper.I_ADDR1     = shipTo.ShippingCity; //주소
        wrapper.I_ADDR2     = shipTo.ShippingStreet; //상세주소
        wrapper.I_SWERKS    = resouce.Service_Territory__r.PlanningPlant__c; //Service Plant 


        wrapper.I_GSTRP     = dispatchTime.format('yyyyMMdd');//시작일시
        wrapper.I_GLTRP     = dispatchTime.format('yyyyMMdd');//시작일시

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res res = instance.IF_CSPLUS_005(wrapper);  
        System.debug('res :: '+res);

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res_O_RETURN o_return = res.O_RETURN;
        String o_aufnr = res.O_AUFNR;

        iw.ifResult = JSON.serialize(o_return);
        if(o_return.TYPE != 'S'){
            iw.isSuccess = false;
            iw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
        }else{
            iw.returnValue = o_aufnr;
        }
        
        return iw;
    }

    /**
     * @Description
     * 	- 설치검수, 순회서비스, 정기점검 Work Order 생성 I/F
     * @author Hayeong Min 
    **/
    private static IFWrapper IF_CSPLUS_042 (String ticketId, String orderType, String serviceResourceId, DateTime dispatchTime, String soldTo){
        IFWrapper iw = new IFWrapper();
        
        Case ticket = [SELECT Id, AssetId, Asset.Name, ReceptionDetails__c FROM Case WHERE Id = :ticketId];
        ServiceResource serviceResource = [SELECT Id, StaffNumber__c, Service_Territory__r.WCCode__c, Service_Territory__r.PlanningPlant__c FROM ServiceResource WHERE Id = :serviceResourceId];
        Account acc = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode,ShippingCity, ShippingStreet FROM Account WHERE ID = :soldTo];
        
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req();
        req.I_EQUNR     = ticket.Asset.Name;
        req.I_KTEXT     = ticket.ReceptionDetails__c;
        req.I_PERNR     = serviceResource.StaffNumber__c;
        req.I_ILART     = orderType;
        req.I_VAPLZ     = serviceResource.Service_Territory__r.WCCode__c;
        req.I_GSTRP     = dispatchTime.format('yyyyMMdd');
        req.I_KUNUM     = acc.CustomerCode__c; //soldTo
        req.I_SWERKS     = serviceResource.Service_Territory__r.PlanningPlant__c;

        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res res = instance.IF_CSPLUS_042(req);

        System.debug('res :: '+res);

        
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res_O_RETURN o_return = res.O_RETURN;
        String o_aufnr = res.O_AUFNR;
        System.debug('o_aufnr : ' + o_aufnr);
        System.debug('o_aufnr : ' + o_return.TYPE);
        if(o_return.TYPE != 'S'){
            System.debug('o_aufnr1 : ' + o_return.TYPE);
            iw.isSuccess = false;
            iw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
        }else{
            System.debug('o_aufnr2 : ' + o_return.TYPE);
            iw.returnValue = o_aufnr;
        }

        iw.ifResult = JSON.serialize(o_return);
        return iw;
    }

    /**
     * @Description
     * 	- CS02 Work Order 생성 I/F
     * @author Hayeong Min 
    **/
    private static IFWrapper IF_CSPLUS_010(String ticketId, String orderType, String serviceResourceId, DateTime dispatchTime, String soldTo, String spTask, Boolean isDirect){
        IFWrapper iw = new IFWrapper();
        Case ticket = [SELECT Id, Status, ReceptionDetails__c, AssetId, 
                                FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c, 
                                BreakdownDateTime__c, RepairRequestDateTime__c, ApplicationDateTime__c,
                                AccountId, FM_LaborWarranty__c, FM_PartsWarranty__c
                        FROM Case WHERE Id = :ticketId]; 

        Asset equip = [SELECT Id, Name, MachineName__c, SerialNumber FROM Asset WHERE Id = :ticket.AssetId];
        
        String warranty = '';
        if(ordertype == '202' || orderType == '214' || ordertype == '215' || orderType == '218'){
            warranty = ticket.FM_PartsWarranty__c;
        }else{
            warranty = ticket.FM_LaborWarranty__c;
        }
        System.debug('warranty ::: '+warranty);
        if(String.isEmpty(warranty)){
            iw.isSuccess = false;
            iw.errMessage = System.Label.DNS_E_CheckWarranty;
            return iw;
        }

        ServiceResource resouce = [SELECT Id, StaffNumber__c, Service_Territory__c, Service_Territory__r.WCCode__c, Service_Territory__r.classify__c FROM ServiceResource WHERE Id = :serviceResourceId];
        
        Account acc = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode,ShippingCity, ShippingStreet FROM Account WHERE ID = :soldTo];
        Account shipTo = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode,ShippingCity, ShippingStreet FROM Account WHERE ID = :ticket.AccountId];

        User u = [SELECT Id, Name, EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()];
        
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER i_header = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER();
        i_header.QMCOD = getFailureType(orderType); // 하자유형 코드
        i_header.WHR_YN = (orderType == '218' || orderType == '219') ? 'Y':'N'; // P-Claim 입고처리 : Y / P - Claim : N, Value Fund : 219 : Y / 220 : N
        i_header.OTGRP = ticket.FailureAreaValue__c + '00000';//고장부위(대) ERPCodeGroup__c => 00000
        i_header.OTEIL = ticket.FailureAreaDetailValue__c.right(2); //고장부위 (중) Value
        i_header.FEGRP = ticket.FailureAreaValue__c + ticket.FailureAreaDetailValue__c + '00'; // 대 + 중 + '00'
        i_header.FECOD = ticket.FailurePhenomenonValue__c; //고장현상 Value

        DateTime failureDate = ticket.BreakdownDateTime__c != null ? ticket.BreakdownDateTime__c : ticket.ApplicationDateTime__c;
        i_header.TRBL_DT = failureDate.format('yyyyMMdd'); //'20241101'; //고장일자
        i_header.TRBL_TM = failureDate.format('HH:mm:ss'); //'110000'; //고장시간
        i_header.RECV_DT = ticket.ApplicationDateTime__c.format('yyyyMMdd'); //'20241101'; //접수일자
        i_header.RECV_TM = ticket.ApplicationDateTime__c.format('HH:mm:ss'); //'120000'; //접수시간
        i_header.LTRMN = ticket.RepairRequestDateTime__c.format('yyyyMMdd');//'20241101'; //수리요청일자
        i_header.LTRUR = ticket.RepairRequestDateTime__c.format('HH:mm:ss');//'120000'; //수리요청일시

        i_header.QMNAM = UserInfo.getName(); //상담자명(기술상담사)
        i_header.ARBPL = resouce.Service_Territory__r.WCCode__c; //워크센터 코드
        i_header.DAUNO ='1'; //작업요구시간(고정값)
        i_header.S_DATE = dispatchTime.format('yyyyMMdd');//작업시작일자 = 출동예정일시
        i_header.INPUT_NO ='1';
        i_header.PERNR = resouce.StaffNumber__c; //서비스요원 코드
        i_header.TYPBZ = equip.MachineName__c; //장비 기종
        i_header.SERNR = equip.SerialNumber; // 장비 호기정보
        System.debug('orderTypeCS02 i_header ::: '+i_header);
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2 i_header_2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2();
        i_header_2.KUNNR = acc.CustomerCode__c; // 고객사 코드
        i_header_2.NAME1 = acc.Name;//고객명
        i_header_2.POST_CODE1 = shipTo.ShippingPostalCode; //우편번호                                       
        i_header_2.CITY1 = shipTo.ShippingCity;                                    
        i_header_2.STREET = shipTo.ShippingStreet;                                    
        i_header_2.ERNAM = u.EmployeeNumber; //접수자 --> USER의 User Code로 변경
        i_header_2.AENAM = u.EmployeeNumber; //변경자 ID --> USER의 User Code로 변경
        System.debug('orderTypeCS02 i_header_2 ::: '+i_header_2);

        List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2> t_i_list2 = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2>();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2 tiItem2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2();
        tiItem2.TEXT = ticket.ReceptionDetails__c;
        t_i_list2.add(tiItem2);

        String docType = '';
       
        if(orderType == '201'){
            docType = 'YDCO';
        } else if (orderType == '202') {
            if (warranty == 'N') {
                docType = 'YDOW';
            }else {
                docType = isDirect ? 'YDOW' : 'YDCO'; 
            }
        }  else if (orderType == '215') {
            docType = 'YDOW'; 
        } else if (orderType == '203' || orderType == '204' || orderType == '214' || orderType == '217' || orderType == '218') {
            docType = 'YDCO';
        } else if (orderType == '219') {
            docType='YDVF';
        } else {
            docType = 'YDCO';
        }

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req();
        req.I_EQUNR     = equip.Name; //장비번호 
        req.I_DOC_TYPE  = docType; 
        req.I_WARR_YN   = warranty; // 보증여부 ('Y': Under warranty, 'N': Out of warranty) 
        req.I_NEW_CLICK = 'I'; //생성 Flag('I':New create, 'C': Change)
        req.I_SAFETY = getSpindleRepairInfo(orderType); //스핀들수리여부   
        WarrantyWrapper ww = getWarrantyInfo(orderType, serviceResourceId);
        req.I_OUT_WARR  = ww.isWarranty; //'X' : Out warranty                         
        req.I_DIRECT    = ww.isDirect; // 직영유상여부       
        req.I_PART_OUT_WARR = ticket.FM_PartsWarranty__c; //부품보증 / 'X' : Out warranty                                 

        req.I_HEADER = i_header;
        req.I_HEADER2 = i_header_2;
        req.T_I_LIST2 = t_i_list2;

        if(orderType == '214' || orderType == '215' || orderType == '218'){
            req.I_TASKLIST = spTask;
        }

        System.debug('orderTypeCS02 req ::: '+ Json.Serialize(req));
        IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res res = instance.IF_CSPLUS_010(req);

        System.debug('orderTypeCS02 res ::: '+ Json.Serialize(res));

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res_O_RETURN o_return = res.O_RETURN;
        String o_aufnr = res.O_AUFNR; //orderNum
        String o_qmnum = res.O_QMNUM; //notiNum

        iw.ifResult = JSON.serialize(o_return);
        // if(o_return.TYPE != 'S' || ){
        if(String.isEmpty(res.O_AUFNR)){
            iw.isSuccess = false;
            iw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
        }else{
            iw.returnValue = o_aufnr;
            iw.notiNum = o_qmnum;
        }
        
        return iw;
    }


    /**
     * @Description
     * 	- 설치시운전 Work Order 생성 I/F
     * @author Hayeong Min 
    **/
    private static IFWrapper IF_CSPLUS_036(String ticketId, String serviceResourceId, DateTime dispatchTime, String soldTo){
        IFWrapper iw = new IFWrapper();
        Case ticket = [SELECT Id, Status, Requester__c, ReceptionDetails__c, AccountId, 
                            Requester__r.Name, FM_PhoneNumber__c, SalesOrder__c, SalesOrder__r.ERPPSONo__c,
                            AssetId, Asset.Name  FROM Case WHERE Id = :ticketId];

        ServiceResource resource = [SELECT Id, StaffNumber__c, Service_Territory__c, Service_Territory__r.WCCode__c, 
                                    Service_Territory__r.ControlWorkcenter__c, Service_Territory__r.ControlWorkcenter__r.Name, 
                                    Service_Territory__r.ControlWorkcenter__r.WCCode__c, Service_Territory__r.classify__c 
                                    FROM ServiceResource WHERE Id = :serviceResourceId];
        String wcCode = '';
        String brachCode = '';

        //설치시운전은 다 주소기반
        wcCode = resource.Service_Territory__r.WCCode__c;
        Account shipTo = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode, ShippingCity, ShippingStreet FROM Account WHERE ID = :ticket.AccountId];
        
        if(String.isNotEmpty(shipTo.ShippingPostalCode)){
            String postal = shipTo.ShippingPostalCode.left(3);
            List<JurisdictionalInformation__mdt> zipList = [SELECT Id, CityCounty2__c FROM JurisdictionalInformation__mdt WHERE ZipCode__c = :postal LIMIT 1];
            if(zipList.size()>0){
                String zipCity = zipList[0].CityCounty2__c;
                System.debug('zipList[0].CityCounty2__c : '+zipList[0].CityCounty2__c);
                JurisdictionalInfo__c zipBranch = [SELECT Id, CityCounty__c, City__c, WorkCenter__c, WorkCenter__r.Name, WorkCenter__r.WCCode__c FROM JurisdictionalInfo__c WHERE CityCounty__c = :zipCity LIMIT 1];
                System.debug('zipBranch : '+zipBranch);
                brachCode = zipBranch.WorkCenter__r.WCCode__c;
            }else{
                brachCode = resource.Service_Territory__r.ControlWorkcenter__r.WCCode__c;
            }
        }else{
            brachCode = resource.Service_Territory__r.ControlWorkcenter__r.WCCode__c;
        }
        
        
        Account acc = [SELECT Id, Name, CustomerCode__c, ShippingPostalCode,ShippingCity, ShippingStreet FROM Account WHERE ID = :soldTo];

        if(String.isEmpty(ticket.SalesOrder__r.ERPPSONo__c)){
            iw.isSuccess = false;
            iw.errMessage = System.Label.DNS_E_NoSalesOrderNumber;
            return iw;
        }

        IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Req req = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Req();
        req.I_EQUNR     = ticket.Asset.Name;
        req.I_SWERKS    = '184S'; //고정
        req.I_ARBPL     = wcCode; // 직영 WorkCenter 코드
        req.I_GSTRP     = dispatchTime.format('yyyy-MM-dd'); // 출동요청일시
        req.I_PARNR     = resource.StaffNumber__c; //서비스요원 코드
        req.I_VKBUR     = brachCode; 
        req.I_WADAT     = dispatchTime.format('yyyy-MM-dd');
        req.I_LFDAT     = dispatchTime.format('yyyy-MM-dd');
        req.I_SOLDTO    = acc.CustomerCode__c;
        req.I_VBELN     = ticket.SalesOrder__r.ERPPSONo__c; //Sales Order Number
        
        IF_ERP_InstAndComm instance = new IF_ERP_InstAndComm();
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res res = instance.IF_CSPLUS_036(req);
        System.debug('req :: ' + Json.serialize(req));
        System.debug('res :: '+Json.serialize(res));

        List<IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res_OT_RETURN> ot_returnList = res.OT_RETURN;
        String o_aufnr = res.O_AUFNR;
        IF_ERP_InstAndComm_Classes.IF_CSPLUS_036_Res_OT_RETURN o_return = ot_returnList[0];
        
        if(String.isEmpty(res.O_AUFNR)){
            iw.isSuccess = false;
            iw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
        }else{
            iw.returnValue = o_aufnr;
        }

        iw.ifResult = JSON.serialize(o_return);
        return iw;
    }

    /**
     * @Description
     * 	- DNSA Work Order 생성 I/F
     * @author Hayeong Min 
    **/ 
    private static IFWrapper IF_CSPLUS_044 (String ticketId, DateTime dispatchTime, String soldTo){
        IFWrapper iw = new IFWrapper();
        
        Case ticket = [SELECT Id, BreakdownDateTime__c, ApplicationDateTime__c, 
                        AccountId, AssetId, Asset.Name, Asset.MachineName__c, Asset.SerialNumber,
                        ReceptionDetails__c, RepairRequestDateTime__c ,
                        FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c, InternalTicketType__c
                        FROM Case WHERE Id = :ticketId];
        User u = [SELECT Id, Name, EmployeeNumber, ERP_Key__c, Portal_EmployeeNumber__c  FROM User WHERE ID = :UserInfo.getUserId()];
        Account acc = [SELECT Id, Name, CustomerCode__c, Country__c FROM Account WHERE Id = :soldTo];

        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER header = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER();
        header.ILART        = '699'; //PM Activity Type 고정

        DateTime failureDate = ticket.BreakdownDateTime__c != null ? ticket.BreakdownDateTime__c : ticket.ApplicationDateTime__c;
        header.FAIL_DT      = failureDate.format('yyyyMMdd'); //고장일자 
        header.FAIL_TM      = failureDate.format('HH:mm:ss'); //고장시간 
        header.QMDAT        = ticket.ApplicationDateTime__c.format('yyyyMMdd'); //접수일자     
        header.REG_TIME     = ticket.ApplicationDateTime__c.format('HH:mm:ss'); //접수시간
        header.REQUIRE_DAT  = dispatchTime.format('yyyyMMdd'); //출동일자(수리요청일자)
        header.REQUIRE_TIM  = dispatchTime.format('HH:mm:ss'); //출동일시(수리요청일시)
        header.REPORTEDBY   = u.EmployeeNumber;
        header.TYPBZ        = ticket.Asset.MachineName__c; //장비기종
        header.SERNR        = ticket.Asset.SerialNumber; //장비번호
        System.debug('header :: '+ header);
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO userInfo = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO();
        userInfo.BNAME      = u.Portal_EmployeeNumber__c;//'CS_DMTA'; // User Name in User Master Record -> LOG 저장용
        userInfo.RNAME      = String.valueOf(u.ERP_Key__c); //User Name in User Master Record -> LOG 저장용
        userInfo.NAME1      = acc.Name; //고객사 이름
        userInfo.WAERS      = 'USD'; // Currency Key
        userInfo.ARBPL      = '1262215'; //Work Center 코드 고정
        userInfo.KUNN2      = acc.CustomerCode__c; //고객번호 
        userInfo.LAND1      = 'US'; // Country Key
        userInfo.REGIO      = 'CA'; // Region (State, Province, County)
        userInfo.WERKS      = '414S'; //Plant 정보 고정
        userInfo.VERAN      = '440'; // Person responsible for the work center
        userInfo.DF_CHK     = 'X'; // Default Check
        userInfo.FOREIGN    = 'X'; // Land Gubun Code
        userInfo.ERDAT      = System.now().format('yyyyMMdd'); //Date on Which Record Was Created ???
        userInfo.ERNAM      = u.EmployeeNumber; // 접수자
        System.debug('userInfo :: '+ userInfo);
        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> t_claim_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> ();
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM claim = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM();
        claim.CLAIM_SEQ = '0001'; //Claim Seq
        claim.CODE_01 = ticket.FailureAreaValue__c; //고장부위(대)
        claim.CODE_03 = ticket.FailureAreaDetailValue__c.right(2); //고장부위 (중) Value
        claim.OTGRP = ticket.FailureAreaValue__c + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
        claim.OTEIL = ticket.FailureAreaDetailValue__c.right(2); //고장부위 (중) Value
        claim.FEGRP = ticket.FailureAreaValue__c + ticket.FailureAreaDetailValue__c + '00'; // 대 + 중 + '00'
        claim.FECOD = ticket.FailurePhenomenonValue__c; //고장현상 Value
        claim.FETXT = ticket.ReceptionDetails__c; //Notification Item Short Text --> 접수내용?
        t_claim_list.add(claim);    
        System.debug('t_claim_list :: '+ claim);
        
        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP> t_tmp_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP> ();
        List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE> t_file_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE> ();

        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req req = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req();
        req.I_UNAME = 'CS_DMTA';
        req.I_LANGU = 'E';
        req.I_USERINFO = userInfo;
        req.I_HEADER   = header;
        req.T_CLAIM = t_claim_list;
        req.T_TMP = t_tmp_list;
        req.T_FILE = t_file_list;

        System.debug('req :: '+ req);
        IF_ERP_SalesOrder execute = new IF_ERP_SalesOrder();
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res res = execute.IF_CSPLUS_044(req);

        System.debug('res :: '+res);
        
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_O_RETURN o_return = res.O_RETURN;
        String o_order = res.O_ORDER;
        System.debug('IF_CSPLUS_044_Res o_order :'+o_order);
        String o_notification = res.O_NOTIFICATION;

        if(o_return.TYPE != 'S'){
            iw.isSuccess = false;
            iw.errMessage = 'ERP ERROR : '+o_return.MESSAGE;
        }else{
            Integer integerNum = Integer.valueOf(o_order);
            iw.returnValue = String.valueOf(integerNum);
            Integer integerNotiNum = Integer.valueOf(o_notification);
            iw.notiNum = String.valueOf(integerNotiNum);
        }
        
        iw.ifResult = JSON.serialize(res);
        return iw;
    }

    //================================================================================================

    /**
     * @Description
     * 	- 오더 생성시, Ticket 정보와 관련된 Validation Check
     * 
     * @Parameter
     *  - ticket       : 상위 Ticket 정보
    **/ 
    private static CommonWrapper checkValidation(Case ticket){
        CommonWrapper cw = new CommonWrapper();
        
        //장비정보 필수
        if(String.isEmpty(ticket.AssetId)){
            cw.isSuccess = false;
            cw.errMessage = System.Label.DNS_M_CheckEquipment;
        }

        //수리요청일시 필수
        if(ticket.RepairRequestDateTime__c == null){
            cw.isSuccess = false;
            cw.errMessage = System.Label.DNS_M_CheckVisitDate;
        }

        //고장접수시 고장일시 필수
        if(ticket.InternalTicketType__c == 'Failure receipt' && ticket.BreakdownDateTime__c == null){
            cw.isSuccess = false;
            cw.errMessage = System.Label.DNS_M_EnterFailureDatetime;
        }

        //접수일시 필수
        if(ticket.ApplicationDateTime__c == null){
            cw.isSuccess = false;
            cw.errMessage = System.Label.DNS_M_EnterApplicationDatetime;
        }

        //오더 생성하는 Ticket 유형이 아닌 경우 Validation 걸기
        if(!(ticket.InternalTicketType__c == 'Failure receipt' || 
            ticket.InternalTicketType__c =='Installation request' || 
            ticket.InternalTicketType__c =='Post-delivery training' || 
            ticket.InternalTicketType__c =='Regular Inspections' || 
            ticket.InternalTicketType__c =='Service Campaign' || 
            ticket.InternalTicketType__c =='Pre-Call' || 
            ticket.InternalTicketType__c =='Missing Part, Wrong Part' ||
            ticket.InternalTicketType__c == 'Service Package Claim' ||
            ticket.InternalTicketType__c == 'Customer Support' ||
            ticket.InternalTicketType__c == 'Sales support')
        ){
            cw.isSuccess = false;
            cw.errMessage = System.Label.DNS_E_NotOrderType;
        }

        //Service Package Claim은 한국에서는 선택 가능하지만 오더 생성X, 미국에서는 오더 생성 O
        if(ticket.RecordType.DeveloperName == 'Ticket_Domestic' && ticket.InternalTicketType__c == 'Service Package Claim'){
            cw.isSuccess = false;
            cw.errMessage = System.Label.DNS_E_NotOrderType;
        }


        //미오후납, Pre-Call, 고장접수시, 고장정보 필수
        if(ticket.InternalTicketType__c == 'Missing Part, Wrong Part' || ticket.InternalTicketType__c == 'Failure receipt' || ticket.InternalTicketType__c == 'Pre-Call'){
            if(String.isEmpty(ticket.FailureAreaValue__c) || String.isEmpty(ticket.FailureAreaDetailValue__c) || String.isEmpty(ticket.FailurePhenomenonValue__c) || ticket.BreakdownDateTime__c == null){
                cw.isSuccess = false;
                cw.errMessage = System.Label.DNS_E_EnterFailureInfo;
            }
        }

        //Ticket 상태 종결이면 Service Order 생성 불가
        if(ticket.Status == 'Closed'){
            cw.isSuccess = false;
            cw.errMessage = System.Label.DNS_E_TicketClosed;
        }

        return cw;
    }
    
    /**
     * @Description
     * 	- PM Activity Type Default Setting
     *  - 수리요청일시가 장비에 등록된 보증기간 내에 있으면 무상Claim(201), 보증기간을 지났으면 유상Claim(202)
     *  - Ticket Type(중)이 납품 후 교육이면 납품 후 교육 무상(201), 납품 후 교육 유상(802)
     *  - Ticket Type(중)이 설치요청이면 설치시운전(104)
     *  - Ticket Type(중)이 Pre-Call이면 Pre-Call(203)
     *  - Ticket Type(중)이 Missing Part, Wrong Part이면 무상Claim(201)
     *  - Ticket Type(중)이 Sales support이면 영업기술지원(810)
     * 
     * @Parameter
     *  - warranty     : Ticket 공임 Warranty
     *  - ticketType   : Ticket 유형(중)
    **/ 
    private static String checkPMType(String warranty, String ticketType){
        String pmType = '';

        if(ticketType == 'Failure receipt'){
            if(warranty =='Y'){
                pmType = '201'; //무상
            }else{
                pmType = '202'; //유상
            }
        }

        if(ticketType == 'Post-delivery training'){
            pmType = '801'; //납품후교육 무상
        }

        if(ticketType == 'Installation request'){//설치시운전인 경우
            pmType = '104';
        } 

        if(ticketType == 'Pre-Call'){//Pre-Call인 경우
            pmType = '203';
        }
        
        if(ticketType == 'Missing Part, Wrong Part'){//미오후납인 경우
            pmType = '201';
        }

        if(ticketType == 'Service Campaign'){//순회서비스
            pmType = '106';
        }

        if(ticketType == 'Regular Inspections'){//정기점검
            pmType = '103';
        }

        if(ticketType == 'Sales support'){//영업지원원
            pmType = '810';
        }

        if(ticketType == 'Customer Support'){//고객지원
            pmType = '219';
        }

        return pmType;
    }

    /**
     * @Description
     * 	- 설치시운전 Work Order일 경우, 서비스요원 기술 조회회
     * @Parameter
     *  - assetId : 맵핑된 장비 Id
     *  - serviceResourceId : 맵핑된 서비스요원 Id
    **/ 
    private static Boolean getResourceSkillInfo(String assetId, String serviceResourceId){
        Boolean hasSkill = false;
        String equipName = [SELECT Id, Name FROM Asset WHERE Id = :assetId].Name;
        String equipCode = equipName.split('-')[0];
        List<ModelManager__c> modelManagerList = [SELECT Id, Name, ModelCode__c, ModelGroup__c FROM ModelManager__c WHERE ModelCode__c = :equipCode ORDER BY LastModifiedDate DESC LIMIT 1];
        if(!modelManagerList.isEmpty()){
            String modelGroup = modelManagerList.get(0).ModelGroup__c;
            List<ServiceResourceSkill> skillList = [SELECT Id, ServiceResourceId, SkillId, FM_ModelCategory__c FROM ServiceResourceSkill WHERE ServiceResourceId = :serviceResourceId];
            
            // 직영 인원 일 경우 기술 조회 X - Sagil,Park
            List<ServiceResource> srList = [SELECT ID FROM ServiceResource 
                                            WHERE ID =: serviceResourceId 
                                            AND (Service_Territory__r.classify__c = '지사'  OR Service_Territory__r.classify__c = 'POST')
                                            AND IsActive = true];
            if(srList.size() > 0){
                hasSkill = true;
                return hasSkill;
            }else{
                if((!skillList.isEmpty()) && (String.isNotEmpty(modelGroup))){
                    //모델군
                    for(ServiceResourceSkill sk : skillList){
                        if(sk.FM_ModelCategory__c == modelGroup) {
                            hasSkill = true;
                            break;
                        }
                    }
                }else if(String.isEmpty(modelGroup)){
                    hasSkill = true;
                }
            }
        }else{
            hasSkill = true;
        }
        return hasSkill;
    }

    /**
     * @Description
     * 	- 하자유형 코드 Get
     * @Parameter
     *  - pmType     : PM Activity Type
    **/ 
    private static String getFailureType(String pmType){
        String QMCOD = '';
        switch on pmType {
            when '201', '202'{
                QMCOD = '01';
            }
            when '204', '218'{
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
        return QMCOD;
    }

    /**
     * @Description
     * 	- 스핀들 수리 여부
     * @Parameter
     *  - pmType     : PM Activity Type
    **/ 
    private static String getSpindleRepairInfo(String pmType){
        String result = '';
        if(pmType == '214' || pmType == '215' || pmType == '218'){
            result = 'X';
        }
        return result;
    }

    /**
     * @Description
     * 	- 유상/직영유상 여부
     * @Parameter
     *  - pmType     : PM Activity Type
    **/ 
    private static WarrantyWrapper getWarrantyInfo(String pmType, String serviceResourceId){
        WarrantyWrapper ww = new WarrantyWrapper();
        if(pmType == '202' || pmType == '215'){
            ww.isWarranty = 'X';
        }

        if(ww.isWarranty == 'X'){//유상일 때
            ServiceResource sr = [SELECT Id, FM_isDirect__c FROM ServiceResource WHERE ID = :serviceResourceId];
            if(sr.FM_isDirect__c) {
                ww.isDirect = 'X';
            }
        }
        return ww;
    }

    /**
     * @Description
     * 	- Case의 Field Type
     * @Parameter
     *  - fieldName     : 타입을 조회할 Field Name
    **/ 
    private static String getFieldType(String fieldName){
        Schema.DescribeFieldResult  fieldDescribe   = Schema.SObjectType.WorkOrder.fields.getMap().get(fieldName).getDescribe();
        Schema.DisplayType          fieldType       = fieldDescribe.getType();   
        if (fieldDescribe.isCalculated()) {
            return 'formula';
        } else {
            return fieldType.name();
        }
    }

    /**
     * @Description
     *  - String인 DateTime 값 DateTime 형태로 변경해서 
     * @author Hayeong Min 
    **/
    private static DateTime changeDatetime(String datetimeValue){
        datetimeValue = datetimeValue.replace('T', ' ').substring(0, 19);
        Datetime utcDatetime = Datetime.valueOf(datetimeValue);
        TimeZone tz = UserInfo.getTimeZone();
        Datetime localDatetime = utcDatetime.addSeconds(tz.getOffset(utcDatetime) / 1000);
        return localDatetime;
    }



    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		               {get; set;}
        @AuraEnabled
        public String errMessage		               {get; set;} 
        @AuraEnabled
        public Boolean isDNSA		                   {get; set;}
        @AuraEnabled    
        public String recordTypeId		               {get; set;}
        @AuraEnabled    
        public String returnValue		               {get; set;}
        @AuraEnabled
        public String assetId		    	           {get; set;}
        @AuraEnabled
        public String model		    	               {get; set;}
        @AuraEnabled
        public String orderType		                   {get; set;}
        @AuraEnabled
        public List<Map<String, String>> orderTypeList {get; set;}
        @AuraEnabled
        public String soldTo		                   {get; set;}
        @AuraEnabled
        public String soldToRecordType		           {get; set;}
        @AuraEnabled
        public String shipTo		                   {get; set;}
        @AuraEnabled
        public String shipToAccountGroup	           {get; set;}
        @AuraEnabled
        public String salesOrder	                   {get; set;}
        @AuraEnabled
        public String soNumber	                       {get; set;}
        @AuraEnabled
        public String warranty	                       {get; set;}
        @AuraEnabled
        public String soSoldTo	                       {get; set;}
        @AuraEnabled
        public String soSoldToCode	                   {get; set;}
        @AuraEnabled
        public String soSoldToRecordType	           {get; set;}
        @AuraEnabled
        public String soShipToId	                   {get; set;}
        @AuraEnabled
        public String soShipTo	                       {get; set;}
        @AuraEnabled
        public String soShipToCode	                   {get; set;}
        @AuraEnabled
        public String soShipToRecordType	           {get; set;}
        @AuraEnabled
        public String ticketType	                   {get; set;}
        @AuraEnabled
        public DateTime dispatchTime	               {get; set;}
        @AuraEnabled
        public String returnAll		                   {get; set;}
        @AuraEnabled
        public IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res_O_RETURN TRAINING_O_RETURN	        {get; set;}

        
        public CommonWrapper(){
            this.isSuccess 		            = true;
            this.errMessage 	            = '';
            this.isDNSA 	                = false;
            this.recordTypeId 	            = '';
            this.returnValue 	            = '';
            this.assetId 	                = '';
            this.model 	                    = '';
            this.orderType 	                = '';
            this.soldTo 	                = '';
            this.soldToRecordType 	        = '';
            this.shipTo 	                = '';
            this.shipToAccountGroup         = '';
            this.salesOrder                 = '';
            this.soNumber                   = '';
            this.warranty                   = '';
            this.soSoldTo                   = '';
            this.soSoldToCode               = '';
            this.soSoldToRecordType         = '';
            this.soShipToId                 = '';
            this.soShipTo                   = '';
            this.soShipToRecordType         = '';
            this.ticketType                 = '';
            this.dispatchTime               = System.now();
            this.TRAINING_O_RETURN         = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res_O_RETURN();
            this.returnAll 	        = '';
        }
    }


    /*
     * @Description
     * 		- I/F 결과 반환 Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     *  	- returnValue 			: 성공 시 반환값
     *  	- notiNum 			    : 오더 Noti Number
     *  	- ifResult 			    : 오더 I/F o_return 값 String 으로 변환한 값
     */
    public class IFWrapper {
        @AuraEnabled
        public Boolean isSuccess 		    {get; set;}
        @AuraEnabled
        public String errMessage		    {get; set;} 
        @AuraEnabled
        public String returnValue		    {get; set;}
        @AuraEnabled
        public String notiNum		        {get; set;}
        @AuraEnabled
        public String ifResult		        {get; set;}
        
        public IFWrapper(){
            this.isSuccess 		            = true;
            this.errMessage 	            = '';
            this.returnValue 	            = '';
            this.notiNum 	                = '';
            this.ifResult 	                = '';
        }
    }


    /*
     * @Description
     * 		- Warranty 및 직영 여부 Wrapper
     * 
     * @Variable
     *  	- isWarranty 		: Warranty 여부
     *  	- isDirect 			: 직영 여부
     */
    public class WarrantyWrapper {
        @AuraEnabled
        public String isWarranty		{get; set;}
        @AuraEnabled
        public String isDirect		    {get; set;}
        
        public WarrantyWrapper(){
            this.isWarranty 	            = '';
            this.isDirect 	                = '';
        }
    }
}