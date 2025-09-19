/**
 * @description       : 
 * @author            : Hayeong Min
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Hayeong Min
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   05-29-2024   Hayeong Min   Initial Version
**/
public with sharing class DN_SearchAccountController {
    /**
     * @Description
     * 	- ContactID로 장비 목록 조회
     * 
     * @author Hayeong Min | 07-30-2024
     * @Parameter
     *  - contactId      : Inbound의 ContactId
     *  - taskId         : Inbound TaskId
    **/ 
    @AuraEnabled
    public static ResultWrapper getAssetInfo(String contactId, String taskId){
        ResultWrapper rw = new ResultWrapper();
        try {
            Contact[] con= [SELECT Id, AccountId, MobilePhone FROM Contact WHERE Id = :contactId LIMIT 1];

            SearchWrapper sw = new SearchWrapper();
            sw.conTerm = contactId;
            sw.phoneTerm = con[0].MobilePhone;

            if (!con.isEmpty() && String.isNotEmpty(con[0].AccountId)){
                sw.accTerm = con[0].AccountId;
                String fields = 'Id, Name, AccountId, Account.Name, Account.Phone, Account.Mobile__c, MachineName__c, Order__r.ActualShippingDate__c, Account.ShippingCity, Account.ShippingStreet, FM_AccountName__c';
                String query = 'SELECT ' + fields + ', (SELECT Id, Name, StartServiceDate__c FROM Service_Package_Products__r) FROM Asset WHERE AccountId = \'' + con[0].AccountId + '\'';
                
                List<String> conditions = new List<String>();
                List<Asset> assets = Database.query(query);
                List<AssetWithPackages> resultList = new List<AssetWithPackages>();

                for (Asset a : assets) {
                    AssetWithPackages wrapper = new AssetWithPackages(a);
                    resultList.add(wrapper);
                }

                List<Object> jsonReadyList = new List<Object>();

                for (AssetWithPackages wrapper : resultList) {
                    Asset a = wrapper.asset;
                    List<ServicePackageProduct__c> packages = wrapper.servicePackages;

                    Map<String, Object> assetMap = new Map<String, Object>();
                    assetMap.put('Id', a.Id);
                    assetMap.put('Name', a.Name);
                    assetMap.put('AccountId', a.AccountId);
                    assetMap.put('MachineName__c', a.MachineName__c);
                    assetMap.put('FM_AccountName__c', a.FM_AccountName__c);

                    if (a.Account != null) {
                        Map<String, Object> accountMap = new Map<String, Object>();
                        accountMap.put('Phone', a.Account.Phone);
                        accountMap.put('Mobile__c', a.Account.Mobile__c);
                        accountMap.put('ShippingCity', a.Account.ShippingCity);
                        accountMap.put('ShippingStreet', a.Account.ShippingStreet);
                        assetMap.put('Account', accountMap);
                    }

                    if (a.Order__r != null) {
                        Map<String, Object> orderMap = new Map<String, Object>();
                        orderMap.put('ActualShippingDate__c', a.Order__r.ActualShippingDate__c);
                        assetMap.put('Order__r', orderMap);
                    }

                    List<Map<String, Object>> packageList = new List<Map<String, Object>>();
                    for (ServicePackageProduct__c spp : packages) {
                        Map<String, Object> pkg = new Map<String, Object>();
                        pkg.put('Id', spp.Id);
                        pkg.put('Name', spp.Name);
                        pkg.put('StartServiceDate', spp.StartServiceDate__c);
                        packageList.add(pkg);
                    }

                    assetMap.put('ServicePackages', packageList);
                    jsonReadyList.add(assetMap);
                }
                 rw.returnList = jsonReadyList;  
            }else{
                rw.msg = '등록된 고객사 정보가 없습니다.';
            }
            rw.searchWrap = sw;

              
            //Record Type 구분 Ticket/VOC
            Task callTask = [SELECT Id, Matrix_DNIS_Memo__c FROM Task WHERE Id = :taskId];
            String offeredCallType = callTask.Matrix_DNIS_Memo__c;

            if(offeredCallType == '고객의소리'){
                rw.recType = 'VOC';
            }else{
                rw.recType = 'Ticket';
            }
            
        } catch (Exception e) {
            rw.isSuccess = false;
            rw.msg = '조회된 연락처가 없습니다.';
            rw.errMessage = e.getMessage();
        }
        return rw;
    }

    public class AssetWrapper {
        public Asset asset;
        public List<ServicePackageProduct__c> services = new List<ServicePackageProduct__c>();
    } 

    /**
     * @Description
     *  - 조건에 맞는 검색 결과 반환
     * @Parameter
     *  - keyData      : 검색 조건
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static ResultWrapper getSearchResult(String keyData){
        ResultWrapper rw = new ResultWrapper();
        Map<String, Object> keyDataJSON = (Map<String, Object>) JSON.deserializeUntyped(keyData);
        String accountKey = (String) keyDataJSON.get('accountKey');
        String assetTerm = (String) keyDataJSON.get('assetTerm');
        List<Asset> assetList = new List<Asset>();
        String query = '';
        try {

            String fields = 'Id, Name, AccountId, Account.Name, Account.Phone, Account.Mobile__c, MachineName__c, Order__r.ActualShippingDate__c, Account.ShippingCity, Account.ShippingStreet, FM_AccountName__c';
            query = 'SELECT ' + fields + ', (SELECT Id, Name, StartServiceDate__c FROM Service_Package_Products__r) FROM Asset';
            
            List<String> conditions = new List<String>();
            
            if (String.isNotEmpty(accountKey)) {
                conditions.add('AccountId = \'' + String.escapeSingleQuotes(accountKey) + '\'');
            }
            
            if (String.isNotEmpty(assetTerm)) {
                conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(assetTerm) + '%\'');
            }
            
            if (!conditions.isEmpty()) {
                query += ' WHERE ' + String.join(conditions, ' AND ');
            }

            List<Asset> assets = Database.query(query);
            List<AssetWithPackages> resultList = new List<AssetWithPackages>();

            for (Asset a : assets) {
                AssetWithPackages wrapper = new AssetWithPackages(a);
                resultList.add(wrapper);
            }

            List<Object> jsonReadyList = new List<Object>();

            for (AssetWithPackages wrapper : resultList) {
                Asset a = wrapper.asset;
                List<ServicePackageProduct__c> packages = wrapper.servicePackages;

                Map<String, Object> assetMap = new Map<String, Object>();
                assetMap.put('Id', a.Id);
                assetMap.put('Name', a.Name);
                assetMap.put('AccountId', a.AccountId);
                assetMap.put('MachineName__c', a.MachineName__c);
                assetMap.put('FM_AccountName__c', a.FM_AccountName__c);

                if (a.Account != null) {
                    Map<String, Object> accountMap = new Map<String, Object>();
                    accountMap.put('Phone', a.Account.Phone);
                    accountMap.put('Mobile__c', a.Account.Mobile__c);
                    accountMap.put('ShippingCity', a.Account.ShippingCity);
                    accountMap.put('ShippingStreet', a.Account.ShippingStreet);
                    assetMap.put('Account', accountMap);
                }

                if (a.Order__r != null) {
                    Map<String, Object> orderMap = new Map<String, Object>();
                    orderMap.put('ActualShippingDate__c', a.Order__r.ActualShippingDate__c);
                    assetMap.put('Order__r', orderMap);
                }

                List<Map<String, Object>> packageList = new List<Map<String, Object>>();
                for (ServicePackageProduct__c spp : packages) {
                    Map<String, Object> pkg = new Map<String, Object>();
                    pkg.put('Id', spp.Id);
                    pkg.put('Name', spp.Name);
                    pkg.put('StartServiceDate', spp.StartServiceDate__c);
                    packageList.add(pkg);
                }

                assetMap.put('ServicePackages', packageList);
                jsonReadyList.add(assetMap);
            }

            if (!jsonReadyList.isEmpty()) {
                rw.returnList =  jsonReadyList;
            } else {
                rw.msg = System.Label.DNS_M_NoData;
            }
            
        } catch (Exception e) {
            rw.isSuccess = false;
            rw.msg = System.Label.DNS_M_GeneralError;
            rw.errMessage = e.getMessage();
        }
        System.debug('rw : ' + rw);
        return rw;
    }

    /**
     * @Description
     * 	- Ticket 목록 조회
     * 
     * @author Hayeong Min | 07-29-2024
     * @Parameter
     *  - keyData      : 필요한 DATA 
    **/ 
    @AuraEnabled
    public static ResultWrapper getTicketList(String keyData){
        ResultWrapper rw = new ResultWrapper();
        try {

            Map<String, Object> keyDataJSON = (Map<String, Object>) JSON.deserializeUntyped(keyData);
            String assetId = (String) keyDataJSON.get('assetId');
            String taskId = (String) keyDataJSON.get('taskId');
            String caller = (String) keyDataJSON.get('caller');
            String recType = (String) keyDataJSON.get('recType');
            String uId = (String) keyDataJSON.get('uId');

            String accountId = [SELECT AccountId FROM Asset WHERE Id = :assetId].AccountId;
            List<Case> ticketList = new List<Case>();
            
            String fields = 'Id, RecordType.Name, FM_TicketName__c, toLabel(Status), ReceptionDetails__c, ApplicationDateTime__c, AccountId, Account.Name, ';
                   fields += 'AssetId, Asset.Name, Asset.MachineName__c, Requester__c, Requester__r.Name, Requester__r.Phone, Requester__r.MobilePhone';
            String query = 'SELECT ' + fields +  ' FROM Case WHERE AssetId = \'' + assetId + '\'';
            if(String.isNotEmpty(accountId)){
                query += ' AND AccountId = \'' + accountId + '\'';
            }


            //Ticket으로 유입된 경우에는 콜백 & 부재를 제외한 Ticket/VOC 모두 출력
            //VOC로 유입된 경우에는 VOC 모두 출력
            query += ' AND InternalTicketType__c != \'Request callback\'';
            if(recType == 'Ticket'){
                query += ' AND  RecordType.Name IN (\'Ticket\', \'VOC\')';
            }else{
                query += ' AND RecordType.Name IN (\'VOC\')';
            }
            
            query += ' ORDER BY ApplicationDateTime__c DESC';
            
            System.debug('query ::'+ query);
            ticketList = Database.query(query);

            String recId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = :recType].Id;

            if(ticketList.size() == 0){
                Case ticket = new Case();
                ticket.RecordTypeId = recId;
                ticket.AccountId = String.isNotEmpty(accountId) ? accountId : null;
                System.debug('ticket.AccountId :::'+ticket.AccountId);
                ticket.AssetId = assetId;
                System.debug('ticket.AssetId :::'+ticket.AssetId);
                ticket.Requester__c = String.isNotEmpty(caller) ? caller : null;
                System.debug('ticket.Requester__c :::'+ticket.Requester__c);
                ticket.Matrix_Call_ID__c = uId;
                DateTime dt =  System.now();
                ticket.ApplicationDateTime__c = dt;
                ticket.RepairRequestDateTime__c = dt.addHours(2);
                ticket.ReceptionPath__c = 'Call Center(Representative)';
                ticket.isSelf__c = TRUE;
                System.debug('ticket :::'+ticket);
                insert ticket;
                ticketList.add(ticket);

                //cONTACT 비활성화 추가 
                Contact con = [SELECT Id, MobilePhone FROM Contact WHERE ID = :caller];
                String phoneNum = con.MobilePhone;
                if(phoneNum.contains('-')){
                    phoneNum = phoneNum.replaceAll('-', '');
                }
                List<Contact> conList = [SELECT Id, Name, MobilePhone, Inactive__c 
                                        FROM Contact 
                                        WHERE Inactive__c = FALSE AND ID != :caller 
                                        AND FM_Phone__c= :phoneNum];

                if(String.isNotEmpty(taskId) || taskId != ''){
                    Task task = [SELECT Id, WhatId, WhoId FROM Task WHERE Id = :taskId];
                    task.WhatId = ticket.Id;
                    task.WhoId = caller;
                    update task;
                }
                
                rw.msg = System.Label.DNS_M_TicketCreated;
                rw.isNew = true;
            }
            rw.returnList = ticketList;
        } catch (Exception e) {
            rw.isSuccess = false;
            rw.msg = 'Ticket 정보를 가져오는데 문제가 발생했습니다.';
            rw.errMessage = e.getMessage();
        }
        return rw;
    }

    /**
     * @Description
     * 	- 선택한 Ticket에 Task 연결하기
     * 
     * @author Hayeong Min | 11-25-2024
     * @Parameter
     *  - ticketId      : 선택한 ticketId
     *  - taskId        : InboundCall Task ID
     *  - uId           : InboundCall UID
     *  - contactKey    : InboundCall ContactId
    **/ 
    @AuraEnabled
    public static ResultWrapper viewSelectedTicket(String ticketId, String taskId, String uId, String contactKey){

        System.debug('ticketId : '+ticketId);
        System.debug('taskId : '+taskId);
        System.debug('uId : '+uId);
        System.debug('contactKey : '+contactKey);
        ResultWrapper rw = new ResultWrapper();
        try{
            Case ticket = [SELECT Id, Matrix_Call_ID__c FROM Case WHERE Id = : ticketId];
            if(String.isNotEmpty(taskId) || taskId != ''){
                Task task = [SELECT Id, WhatId, WhoId FROM Task WHERE Id = :taskId];
                task.WhatId = ticket.Id;
                task.WhoId = contactKey;
                update task;

                ticket.Matrix_Call_ID__c = uId;
                update ticket;
            }

            //Inbound Contact을 제외한 동일한 번호의 Contact 비활성화
            Contact con = [SELECT Id, MobilePhone FROM Contact WHERE ID = :contactKey];
            String phoneNum = con.MobilePhone;
            if(phoneNum.contains('-')){
                phoneNum = phoneNum.replaceAll('-', '');
            }
            System.debug('con : '+ con);
            System.debug('phoneNum : '+ phoneNum);
            List<Contact> conList = [SELECT Id, Name, MobilePhone, Inactive__c 
                                    FROM Contact 
                                    WHERE Inactive__c = FALSE AND ID != :contactKey 
                                    AND FM_Phone__c= :phoneNum];
            System.debug('conList :: '+conList);

            rw.returnValue = ticket.Id;
        }catch(Exception e){
            rw.isSuccess = false;
            rw.errMessage = e.getMessage();
        }
        return rw;
    }

    /**
     * @Description
     * 	- 새로운 Ticket 생성 & Task 연결하기
     * 
     * @author Hayeong Min | 11-25-2024
     * @Parameter
     *  - keyData        : Inbound Call Key DATA
    **/ 
    @AuraEnabled
    public static ResultWrapper getNewTicket(String keyData){
        ResultWrapper rw = new ResultWrapper();
        try{
            System.debug('createNewTicket ::'+keyData);
            Map<String, Object> keyDataJSON = (Map<String, Object>) JSON.deserializeUntyped(keyData);
            String accountKey = (String) keyDataJSON.get('accountKey');
            String assetKey = (String) keyDataJSON.get('assetKey');
            String contactKey = (String) keyDataJSON.get('contactKey');
            String taskId = (String) keyDataJSON.get('taskId');
            String caller = (String) keyDataJSON.get('caller');
            String recType = (String) keyDataJSON.get('recType');
            String uId = (String) keyDataJSON.get('uId');

            //기존 다른 Contact 비활성화
            Contact con = [SELECT Id, MobilePhone FROM Contact WHERE ID = :contactKey];
            String phoneNum = con.MobilePhone;
            if(phoneNum.contains('-')){
                phoneNum = phoneNum.replaceAll('-', '');
            }
            List<Contact> conList = [SELECT Id, Name, MobilePhone, Inactive__c 
                                    FROM Contact 
                                    WHERE Inactive__c = FALSE AND ID != :contactKey 
                                    AND FM_Phone__c= :phoneNum];

            Case ticket = new Case();
            if(String.isNotEmpty(accountKey) && String.isNotBlank(accountKey)){
                ticket.AccountId = accountKey;
            }
            if(String.isNotEmpty(assetKey) && String.isNotBlank(assetKey)){
                ticket.AssetId = assetKey;
            }
            if(String.isNotEmpty(caller) && String.isNotBlank(caller)){
                ticket.Requester__c = caller;
            }
            ticket.Matrix_Call_ID__c = uId;
            String recId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = :recType].Id;

            DateTime dt =  System.now();
            ticket.ApplicationDateTime__c = dt;
            ticket.RepairRequestDateTime__c = dt.addHours(2);
            ticket.ReceptionPath__c = 'Call Center(Representative)';
            ticket.isSelf__c = TRUE;
            ticket.RecordTypeId = recId;
            insert ticket;
            // ticket.
            if(String.isNotEmpty(taskId) || taskId != ''){
                Task task = [SELECT Id, WhatId, WhoId FROM Task WHERE Id = :taskId];
                task.WhatId = ticket.Id;
                task.WhoId = contactKey;
                update task;
            }
            rw.returnValue = ticket.Id;
        }catch(Exception e){
            rw.isSuccess = false;
            rw.errMessage = e.getMessage();
        }
        return rw;
    }


    /**
     * @Description
     * 	- ContactId를 기반으로 동일한 번호의 Contact 이력조회
     * 
     * @author Hayeong Min | 02-14-2025
     * @Parameter
     *  - contactId        : InboundCall ContactId
    **/ 
    @AuraEnabled
    public static ResultWrapper getContactInfo(String contactId){
        ResultWrapper rw = new ResultWrapper();
        try {
            Contact con = [SELECT Id, MobilePhone FROM Contact WHERE ID = :contactId];
            String phoneNum = con.MobilePhone;
            if(phoneNum.contains('-')){
                phoneNum = phoneNum.replaceAll('-', '');
            }
            List<Contact> conList = [SELECT Id, Name, MobilePhone, AccountId, Account.Name FROM Contact WHERE Inactive__c = FALSE AND FM_Phone__c= :phoneNum];
            rw.returnList = conList;
        } catch (Exception e) {
            rw.isSuccess = false;
            rw.errMessage = e.getMessage();
        }
        return rw;
    }

    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     *  - resultStr 	: method 결과메세지
     *  - returnValue 	: 반환 string 값
     *  - returnList 	: 반환 List값
     *  - isNew 	    : 객체 생성 유무
     */ 
    public class ResultWrapper{
        @AuraEnabled public Boolean isSuccess  { get; set;}
        @AuraEnabled public String  errMessage { get; set;}
        @AuraEnabled public String  returnValue { get; set;}
        @AuraEnabled public Boolean isNew { get; set;}
        @AuraEnabled public List<Object> returnList { get; set;}
        @AuraEnabled public SearchWrapper searchWrap { get; set;}
        @AuraEnabled public String recType { get; set;}
        @AuraEnabled public String msg { get; set;}

        public ResultWrapper(){
            this.isSuccess = true;
            this.errMessage = '';
            this.returnValue = '';
            this.isNew = false;
            this.returnList = new List<Object>();
            this.searchWrap = new SearchWrapper();
            this.recType = '';
            this.msg = '';
        }
    }

    /*
     * @Description 
     *  - 검색 조건 Wrapper
     * 
     * @Variable 
     *  - accTerm 	    : Account SearchKey
     *  - equipTerm 	: Asset SearchKey
     *  - phoneTerm 	: Phone SearchKey
     *  - conTerm 	    : Contact SearchKey
     */ 
    public class SearchWrapper{
        @AuraEnabled public String  accTerm { get; set;}
        @AuraEnabled public String  equipTerm { get; set;}
        @AuraEnabled public String  phoneTerm { get; set;}
        @AuraEnabled public String  conTerm { get; set;}

        public SearchWrapper(){
            this.accTerm = '';
            this.equipTerm = '';
            this.phoneTerm = '';
            this.conTerm = '';
        }
    }

    public class AssetWithPackages {
        public Asset asset { get; set; }
        public List<ServicePackageProduct__c> servicePackages { get; set; }

        // 생성자
        public AssetWithPackages(Asset asset) {
            this.asset = asset;
            this.servicePackages = new List<ServicePackageProduct__c>();
            if (asset.Service_Package_Products__r != null) {
                this.servicePackages.addAll(asset.Service_Package_Products__r);
            }
        }
    }
    
}