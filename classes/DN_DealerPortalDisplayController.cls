/**
 * @author            : iltae.seo
 * @last modified on  : 2024-12-02
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-02   iltae.seo     Initial Version
**/
public with sharing class DN_DealerPortalDisplayController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    
    /**
    * @description 화면별 메타데이터 조회 
    * @author iltae.seo | 2024-12-02 
    * @param String displayKey  
    **/
    @AuraEnabled
    public static DisplaySetting getDisplayMdt(String displayKey){
        try {
            List<String> filterSettingIds = new List<String>();
            
            
            // display Setting
            DealerPortalSetting__mdt  display = DealerPortalSetting__mdt.getInstance(displayKey);
            DisplaySetting displaySetting = new DisplaySetting(display);
            displaySetting.buttonList = new List<ButtonSetting>();
            displaySetting.filterList = new List<FilterSetting>();
            //현재 유저 정보
            displaySetting.userInfo = getCurrentUserInfo();        
            
            //운영 확인용 - Admin 사용자인 경우 Medata 에 설정 된 정보로 재할당
            if(currentUser.getIsAdmin()) {
                displaySetting.userInfo.accountId = currentUser.getAgencyId();
                displaySetting.userInfo.accountName = currentUser.getAgencyName();
            }
            
            // display Button
            List<DealerPortalButtonSetting__mdt> button = [select Id, DeveloperName, MasterLabel,ButtonLabelEn__c,ButtonLabelKo__c,
                                                                DealerPortalSetting__c, ButtonType__c,DealerPortalFilterSetting__c, DealerPortalFilterSetting__r.ParentFieldApiName__c,
                                                                ModalComponent__c, ButtonIcon__c, ButtonIndex__c,ModalParams__c
                                                                from DealerPortalButtonSetting__mdt where DealerPortalSetting__c=:display.Id 
                                                                AND DealerPortalFilterSetting__c = null 
                                                                order by ButtonIndex__c asc];
            for(DealerPortalButtonSetting__mdt buttonMdt : button) {
                displaySetting.buttonList.add(new ButtonSetting(buttonMdt));
            } 
            // display FilterSetting
            List<DealerPortalFilterSetting__mdt> filterList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix,IsRequired__c,IsVisible__c,AdditionalField__c,
                                                                    Label, QualifiedApiName, SystemModstamp, DealerPortalSetting__c,WhereCondition__c,DependenceField__c,
                                                                    FieldLabelKo__c, FieldApiName__c, FieldType__c, PickListValue__c,DefaultValue__c, DefaultValueLabel__c,
                                                                    ParentFieldValue__c, ParentFieldApiName__c, ObjectName__c, FieldLabelEn__c,FilterIndex__c,IsSearch__c,
                                                                    DependenceValue__c, MaxLength__c,PickListValueEN__c,DependenceValueEN__c
                                                                    from DealerPortalFilterSetting__mdt 
                                                                    where DealerPortalSetting__c=:display.Id order by FilterIndex__c asc];
            
            
            // 필터의 디폴트값이 유동적인 경우 switch문 사용
            Map<String, FilterSetting> filterMap = new Map<String, FilterSetting>();
            for(DealerPortalFilterSetting__mdt filter : filterList) {
                Boolean isRequeryNeeded = false;
                switch on filter.DefaultValue__c {
                    when 'User.Account.Name' {
                        filter.DefaultValue__c = displaySetting.userInfo.accountId; //
                        filter.DefaultValueLabel__c = displaySetting.userInfo.accountName;
                    }
                    when 'User.Account.Dealer.ShipTo' {
                        isRequeryNeeded = true;
                    }
                    when 'Area__r.Name' {
                        // for문안에 쿼리사용을 할 수 밖에 없어서 사용
                        // DealerPortalFilterSetting__mdt의 수가 10개미만 
                        List<DealerAreaByMPPS__c> apreaList = [select Id, Name, Dealer__c, Dealer__r.Name,Area__r.Name  from DealerAreaByMPPS__c where Dealer__c=:displaySetting.userInfo.accountId];
                        if(apreaList.size() > 0) {
                            filter.DefaultValue__c = apreaList[0].Area__c;
                            filter.DefaultValueLabel__c = apreaList[0].Area__r.Name;
                        }
                        
                    }

                }
                FilterSetting filterWrapper = new FilterSetting(filter);
                filterSettingIds.add(filter.Id);
                displaySetting.filterList.add(filterWrapper);
                if(isRequeryNeeded) filterMap.put(filterWrapper.defaultValue, filterWrapper);
            }                                                             
            // 필터에 Default Value 설정(쿼리조회 필요시)

            if(filterMap.containsKey('User.Account.Dealer.ShipTo')) {
                FilterSetting filterWrapper = filterMap.get('User.Account.Dealer.ShipTo');
                for(DealerCustomerShipTo__c shipTo : [ 
                 SELECT Id, FM_Address__c, Customer__c,  DetailInfo__c, RoadAddr__c 
                 FROM DealerCustomerShipTo__c 
                 WHERE Customer__r.SourceAccount__c = :displaySetting.userInfo.accountId AND FM_Address__c != null
                 ORDER BY CreatedDate asc LIMIT 2
               ]) {
                    filterWrapper.defaultValue = shipTo.Id;
                    filterWrapper.defaultValueLabel = displaySetting.userInfo.accountName + ' | '+  shipTo.FM_Address__c;
                    break;
               }
            }



            // display Filter Button
            List<DealerPortalButtonSetting__mdt> filterButton = [select Id, DeveloperName, MasterLabel,ButtonLabelEn__c,ButtonLabelKo__c,
                                                                DealerPortalSetting__c, ButtonType__c,DealerPortalFilterSetting__c, DealerPortalFilterSetting__r.ParentFieldApiName__c,
                                                                ModalComponent__c, ButtonIcon__c, ButtonIndex__c,ModalParams__c
                                                                from DealerPortalButtonSetting__mdt where DealerPortalSetting__c=null
                                                                AND DealerPortalFilterSetting__c IN : filterSettingIds
                                                                order by ButtonIndex__c asc];
            for(DealerPortalButtonSetting__mdt filterBtn : filterButton) {
                for(FilterSetting filterSet : displaySetting.filterList) {
                    if(filterSet.id == filterBtn.DealerPortalFilterSetting__c) {
                        if(filterSet.filterButtonList ==null) {
                            filterSet.filterButtonList = new List<ButtonSetting>();
                        }
                        filterSet.filterButtonList.add(new ButtonSetting(filterBtn));
                    }
                }
            }
            return displaySetting;
        } catch (Exception e) {
            System.debug(e.getMessage() + '< ===e.getMessage()');
            System.debug(e.getLinenumber() + '< ===e.getLinenumber()');
            throw new DN_DealerPortalDisplayControllerException(e.getMessage() + e.getLinenumber());
        }
    }

    /**
    * @description CurrentUserInfo -현재 유저의 정보를 조회
    * @author iltae.seo | 2024-12-02   
    **/
    public static CurrentUser getCurrentUserInfo() {
        User user = [select Id, Name, Account.Name,Account.Id, DistributionChannel__c,Division__c,SalesOrganization__c,SalesDistrict__c,SalesOffice__c,Plant__c from User where Id=:UserInfo.getUserId()];
        CurrentUser currentUser = new CurrentUser();
        return currentUser;
    }

    /**
    * @description 데이터 테이블의 데이터 조회 오브젝트 하나일떄
    * @author iltae.seo | 2024-12-02   
    **/
    @AuraEnabled
    public static List<sObject> getDataList(String query){
        try {
            
            System.debug(query + ' < ===query');
            List<sObject> returnList = Database.query(query);
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description 고객사명 가져오기
    * @author iltae.seo | 2024-12-02   
    **/
    @AuraEnabled
    public static List<DealerCustomer__c> getCustomerList(List<String> customIds){
        try {
            List<DealerCustomer__c> dealerCustomerList = [select Id, Name from DealerCustomer__c where Id IN:customIds];
            
            System.debug(dealerCustomerList + ' ::: dealerCustomerList');
            return dealerCustomerList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 현재 사용자가 딜러포탈인지 내부사이트 접속했는지 구분 
    * @author iltae.seo | 2025-03-05   
    **/
    @AuraEnabled 
    public static Boolean isCommunity() {
        return Network.getNetworkId() ==null? false : true;
    }
    


    /**
    * @description 페이징 처리후 화면에 전달 - 페이징 처리 사용시, 
    * pageMoving 클릭한 페이지
    * @author iltae.seo | 2024-12-02   
    **/
    @AuraEnabled 
    public static PageReturn getDataListQuery(PageReturn page, Integer nextPage, Boolean isExcelDataLoad, String customerId){
        try {
            System.debug(Network.getNetworkId());
            System.debug(page +' <= ==page');
            System.debug(nextPage + ' < ==nextPage');
            // limit 2000건
            User user = [select Id, Name, AccountId from User where Id =: UserInfo.getUserId()];
            PageReturn returnPages = page;
            returnPages.recordList = new List<sObject>();
            
            //returnPages.strQuery += ' AND Dealer__c=\''+user.AccountId+'\' '; 
            if(String.isNotBlank(user.AccountId)) {
                returnPages.strQuery += ' AND SourceAccount__c !=\''+currentUser.getAgencyId()+'\' '; 
            }
            System.debug(customerId + ' :: customerId');
            if(String.isNotBlank(customerId)) {
                List<DealerCustomer__c> delaerCUstomer =[
                    SELECT Id, Name, CustomerCode__c FROM DealerCustomer__c where Id =:customerId
                ];
                if(delaerCUstomer.size() >0) {
                    returnPages.strQuery += ' AND (Dealer__r.CustomerCode__c =\''+delaerCUstomer[0].CustomerCode__c+'\' OR (SourceAccount__c !=null AND SourceAccount__r.CustomerCode__c !=\''+delaerCUstomer[0].CustomerCode__c+'\'))';
                }
            }
            String countWhere = returnPages.strQuery.substring(returnPages.strQuery.indexOfIgnoreCase('where'), returnPages.strQuery.length());
            System.debug(returnPages.strQuery + ' returnPages.strQuery');
            System.debug(countWhere + ' ::: countW here');
            System.debug(returnPages.strQuery +' '+returnPages.orderByField+' '+returnPages.orderBy +' limit 5000' + ' aaaasss');
            returnPages.recordList = Database.query(returnPages.strQuery +' '+returnPages.orderByField+' '+returnPages.orderBy +' limit 5000');
            returnPages.totalRecordSize = Database.countQuery('select COUNT() from DealerCustomer__c ' +countWhere +' limit 5000');
            List<sObject> recordListSet = new List<sObject>();
            // Stage Idx, Last Idx
            Integer startIdx = 0;
            Integer endIdx = 0;
            // 같은 경우 뒤로가기 또는 현재 페이지 클릭
            if(returnPages.currentPage == nextPage) {
                startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
                startIdx = (startIdx - returnPages.itemsPerPage) + 1;
                endIdx = (nextPage*returnPages.itemsPerPage);    
            } else {
                startIdx = (nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage) +1;//(returnPages.currentPage * returnPages.itemsPerPage)+1;
                endIdx = (nextPage*returnPages.itemsPerPage);    
                
            }
            for(Integer i=startIdx-1; i<returnPages.recordList.size(); i++) {
                // 시작 데이터 Indx 부터 End Indx까지
                if(i < endIdx) {
                    recordListSet.add(returnPages.recordList[i]);
                } else {
                    break;
                }
            }
            //리스트 정리 후 재할당
            if(!isExcelDataLoad) {
                returnPages.startIdx = startIdx;
                returnPages.endIdx = endIdx;
                returnPages.currentPage = nextPage;
            }
            returnPages.recordList = recordListSet;
            return returnPages;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: Message');
            System.debug(e.getStackTraceString() + ' ::: getStackTraceString');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 필터 타입이 SearchPickList인 경우 검색하는 기능 제공, additionalField필드는 최소 한개이상은 필수값임, 검색필터
    * @author iltae.seo | 2025-01-31   
    **/
    @AuraEnabled
    public static List<sObject> getSearchPicList(String objectName, String additionalField,String whereCondition){
        try {
            if(whereCondition.contains('currentAccount')) {
                User use = [select Id, Name, Account.Id from User where Id=:UserInfo.getUserId()];
                whereCondition = whereCondition.replace('currentAccount', '\''+use.Account.Id+'\'');
            }
            List<String> additionalFieldList = additionalField.split(',');
            String query = 'select Id, ' + String.join(additionalFieldList, ',');
            String fromQ = ' FROM ' + objectName;
            String whereQ = ' WHERE Id !=null ' + whereCondition;
            System.debug(query + fromQ + whereQ+' limit 100' + ' ;;;111');
            List<sObject> objectList = Database.query(query + fromQ + whereQ+' limit 100');
            // objectList.addAll(Database.query(query + fromQ + whereQ' limit 100'));
            
            return objectList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: Message');
            System.debug(e.getStackTraceString() + ' ::: getStackTraceString');
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    /**
    * @description 필터 타입이 SearchPickList인 경우 검색하는 기능 제공, additionalField필드는 최소 한개이상은 필수값임
    * @author iltae.seo | 2025-01-31   
    **/
    @AuraEnabled
    public static List<sObject> getSearchList(String objectName, List<String> additionalField , String searchValue, String whereCondition,String defaultValue){
        try {
            System.debug(objectName + ' ====objectName');
            System.debug(additionalField + ' ====additionalField');
            System.debug(searchValue + ' ====searchValue');
            if(whereCondition.contains('currentAccount')) {
                User use = [select Id, Name, Account.Id from User where Id=:UserInfo.getUserId()];
                whereCondition = whereCondition.replace('currentAccount', '\''+use.Account.Id+'\'');
            }
            String query = 'select Id';
            String fromQ = ' FROM ' + objectName;
            String whereQ = ' WHERE Id !=null AND(';
            String notSearchWhere = ' WHERE Id !=null AND(';
            for(Integer i=0; i<additionalField.size(); i++) {
                query += ', '+additionalField[i];
                whereQ += ' '+additionalField[i]+ ' LIKE '+ '\'%' +searchValue+'%\''+' OR';
                notSearchWhere += ' '+additionalField[i]+ ' LIKE '+ '\'%'+''+'%\''+' OR';
            }
            // 마지막에 OR를 지우고 )괄호 추가
            whereQ = whereQ.subString(0,whereQ.length() - 2) + ')';
            notSearchWhere = notSearchWhere.subString(0,notSearchWhere.length() - 2) + ')';
            System.debug(query + fromQ + whereQ +' ' +whereCondition+' limit 100'+ ' < querye1111');
            List<sObject> objectList = new List<sObject>();
            // 디폴트값 있는 경우 디폴트값 추가
            if(String.isNotBlank(defaultValue)) {
                sObject obj;
                Type t = Type.forName(objectName);
                obj = (sObject) t.newInstance();
                obj.put(additionalField[0],defaultValue);
                objectList.add(obj);
                
            }
            objectList.addAll(Database.query(query + fromQ + whereQ +' ' +whereCondition+' limit 100'));
            
            //해당필드가 공백값이면 값을 ''로 지정
            for(sObject obj : objectList) {
                for(String field : additionalField) {
                    String fieldSet = field.trim();
                    if(obj.get(fieldSet)==null) {
                        obj.put(fieldSet, '');
                    }
                }
            }
            System.debug(objectList + ' ::: objectList');
            return objectList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: Message');
            System.debug(e.getStackTraceString() + ' ::: getStackTraceString');
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /**
    * @description 픽리스트인 경우 픽리스트값 재설정
    * @author iltae.seo | 2024-12-31   
    **/
    public static List<Map<String, String>> setPickList(String pickListValue) {
        List<Map<String, String>> returnList = new List<Map<String, String>>();
        if (String.isNotBlank(pickListValue)) {
            String[] items = pickListValue.split(';');
            for (String item : items) {
                String[] keyValuePairs = item.split(',');
                Map<String, String> option = new Map<String, String>();
                for (String keyValuePair : keyValuePairs) {
                    String[] pair = keyValuePair.split(':');
                    if (pair.size() == 2) {
                        String key = pair[0].trim();
                        String value = pair[1].trim();
                        option.put(key, value);
                    }
                }
                returnList.add(option);
            }
        }
        return returnList;
    }
    
    // 데이터 리턴 페이징 처리까지
    public class PageReturn {
        @AuraEnabled public String strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<sObject> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        @AuraEnabled public Boolean isNetwork {get;set;} // 커뮤니티 사이트 유무,
        @AuraEnabled public String dateKeyField {get; set;} // 레코드 조회시 시작 시점을 찾을 Date관련 필드 정보
        
        public PageReturn() {}
      
    }

    // CurrentUserInfo 
    public class CurrentUser{
        @AuraEnabled public String id { get; set; } // userId
        @AuraEnabled public String name { get; set; } // User명
        @AuraEnabled public String accountName { get; set; } // 대리점명
        @AuraEnabled public String accountId { get; set; } // 대리점명
        @AuraEnabled public String distributionChannel { get; set; } 
        @AuraEnabled public String division { get; set; } 
        @AuraEnabled public String salesOrganization { get; set; } 
        @AuraEnabled public String salesDistrict { get; set; } 
        @AuraEnabled public String salesOffice { get; set; } 
        @AuraEnabled public String plant  { get; set; } 
        @AuraEnabled public String customerCode  { get; set; } 
        public CurrentUser() {
            this.id = UserInfo.getUserId();
            this.name = currentUser.getAgencyName();
            this.accountName = currentUser.getAgencyName();
            this.accountId = currentUser.getAgencyId();
            this.distributionChannel = currentUser.getDistributionChannel();
            this.division = currentUser.getDivision();
            this.salesOrganization = currentUser.getSalesOranization();
            this.plant = '1846';
            this.customerCode = currentUser.getAgencyCustomerCode();
        }
        public CurrentUser(User user) {
            this.id = user.Id;
            this.name = user.Name;
            this.accountName = String.isBlank(user.Account.Name) ? '' : user.Account.Name;
            this.accountId = String.isBlank(user.Account.Id) ? '' : user.Account.Id;
            this.distributionChannel = String.isBlank(user.DistributionChannel__c) ? '' : user.DistributionChannel__c;
            this.salesOrganization = String.isBlank(user.SalesOrganization__c) ? '' : user.SalesOrganization__c;
            this.division = String.isBlank(user.Division__c) ? '' : user.Division__c;
            this.salesDistrict = String.isBlank(user.SalesDistrict__c) ? '' : user.SalesDistrict__c;
            this.salesOffice = String.isBlank(user.SalesOffice__c) ? '' : user.SalesOffice__c;
            this.plant = '1846';
        }
    }


    // DisplaySetting class
    public class DisplaySetting {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String iconName {get;set;}
        @AuraEnabled public String displayName {get;set;}
        @AuraEnabled public Decimal filterSection {get;set;}
        @AuraEnabled public List<ButtonSetting> buttonList {get;set;}
        @AuraEnabled public List<FilterSetting> filterList {get;set;}
        @AuraEnabled public CurrentUser userInfo {get;set;}
        public DisplaySetting() {}
        public DisplaySetting(DealerPortalSetting__mdt display) {
            this.id = display.Id;
            this.iconName = display.IconName__c;
            this.displayName = currentUser.getLanguageLocaleKey() == 'ko'?  display.DisplayNameKo__c : display.DisplayNameEN__c;
            this.filterSection = display.FilterSection__c;

        }
    }
    // button setting
    public class ButtonSetting {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String parentKey {get;set;}
        @AuraEnabled public String buttonIcon {get;set;}
        @AuraEnabled public Decimal buttonIndex {get;set;}
        @AuraEnabled public String buttonLabel {get;set;}
        @AuraEnabled public String buttonType {get;set;}
        @AuraEnabled public String modalComponent {get;set;}
        @AuraEnabled public String modalParams {get;set;}
        @AuraEnabled public Boolean isPickList {get;set;}
        @AuraEnabled public List<Map<String, String>> pickListValue {get;set;}
        public ButtonSetting(DealerPortalButtonSetting__mdt button) {
            this.id = button.Id;
            this.buttonIcon = button.ButtonIcon__c;
            this.buttonIndex = button.ButtonIndex__c;
            this.buttonLabel = button.ButtonLabelKo__c;
            this.buttonType = button.ButtonType__c;
            this.modalComponent = button.ModalComponent__c;
            this.modalParams = button.ModalParams__c;
            this.parentKey = button.DealerPortalFilterSetting__r.ParentFieldApiName__c; // 필터
            if(this.buttonType =='PickList') {
                this.pickListValue = setPickList(button.ModalParams__c);
                this.isPickList = true;
            } else {
                this.isPickList = false;
            }
        }
    }
    // filter Button setting
    public class FilterSetting {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String dealerPortalSetting {get;set;}
        @AuraEnabled public String fieldLabel {get;set;}
        @AuraEnabled public String fieldApiName {get;set;}
        @AuraEnabled public String fieldType {get;set;}
        @AuraEnabled public List<Map<String, String>> pickListValue {get;set;}
        @AuraEnabled public String parentFieldValue {get;set;}
        @AuraEnabled public String parentFieldApiName {get;set;}
        @AuraEnabled public String objectName {get;set;}
        @AuraEnabled public Boolean isInput {get;set;}
        @AuraEnabled public String defaultValue {get;set;}
        @AuraEnabled public String defaultValueLabel {get;set;}
        @AuraEnabled public List<ButtonSetting> filterButtonList {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public Boolean isVisible {get;set;}
        @AuraEnabled public String whereCondition {get;set;}
        @AuraEnabled public Boolean isSearch {get;set;}
        @AuraEnabled public String dependenceField {get;set;}
        @AuraEnabled public String dependenceValue {get;set;} 
        @AuraEnabled public String additionalField {get;set;} 
        @AuraEnabled public String maxLength {get; set;}
        //IsRequired__c,IsVisible__c

        public FilterSetting() {}
        public FilterSetting(DealerPortalFilterSetting__mdt filter) {
            this.id = filter.Id;
            this.dealerPortalSetting = filter.DealerPortalSetting__c;
            this.fieldLabel = currentUser.getLanguageLocaleKey() == 'ko'? filter.FieldLabelKo__c : filter.FieldLabelEn__c;
            this.fieldApiName = filter.FieldApiName__c;
            this.fieldType = filter.FieldType__c;
            this.isRequired = filter.IsRequired__c;
            this.isVisible = filter.IsVisible__c;
            this.isSearch = filter.IsSearch__c;
            this.whereCondition = filter.WhereCondition__c;
            this.dependenceField = filter.DependenceField__c;

            switch on this.fieldType {
                when 'Text' {
                    this.isInput = true;
                }
                when else {
                    this.isInput = false;
                }
            }
            this.defaultValue = String.isBlank(filter.DefaultValue__c) ? '' : filter.DefaultValue__c;
            this.defaultValueLabel = String.isBlank(filter.DefaultValueLabel__c) ? '' : filter.DefaultValueLabel__c;
            this.parentFieldApiName = filter.ParentFieldApiName__c;
            this.parentFieldValue = filter.ParentFieldValue__c;
            this.maxLength = filter.MaxLength__c != null ? String.valueOf(filter.MaxLength__c) : '';

            if(this.fieldType =='PickList') {
                this.pickListValue = currentUser.getLanguageLocaleKey() == 'ko'? setPickList(filter.PickListValue__c) : setPickList(filter.PickListValueEN__c);   
                this.dependenceValue = currentUser.getLanguageLocaleKey() == 'ko'? filter.DependenceValue__c :filter.DependenceValueEN__c;
            }
            if(this.fieldType =='RadioButton') {
                this.pickListValue = currentUser.getLanguageLocaleKey() == 'ko'? setPickList(filter.PickListValue__c) : setPickList(filter.PickListValueEN__c);   
            }
            // SearchPickList 목록 뜨는지 확인용
            if(this.fieldType=='SearchPickList') {
                this.additionalField =  filter.AdditionalField__c;    
                this.dependenceValue = currentUser.getLanguageLocaleKey() == 'ko'? filter.DependenceValue__c :filter.DependenceValueEN__c;
                
                this.pickListValue = currentUser.getLanguageLocaleKey() == 'ko'? setPickList(filter.PickListValue__c) : setPickList(filter.PickListValueEN__c);   
            }
            if(this.fieldType =='YearMonth') {
                this.dependenceValue = currentUser.getLanguageLocaleKey() == 'ko'? filter.DependenceValue__c :filter.DependenceValueEN__c;
            }

            this.objectName = filter.ObjectName__c;
        }
    }
    public class DN_DealerPortalDisplayControllerException extends Exception {}
 
   
}