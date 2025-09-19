/**
 * @description       : 
 * @author            : sunwoong.han@dkbmc.com
 * @group             : 
 * @last modified on  : 2025-09-11
 * @last modified by  : sunwoong.han@dkbmc.com
**/
public with sharing class DN_C_Utils {
    /**
     * Custom Exception class
     */
    public class CommException extends Exception {}

    /**
     * 상태값 정의 enum
     */
    public enum StatusCode {
        SUCCESS, ERROR, FAIL, WARNING, INFO, NONE
    }

    /**
     * Select options wrap class
     */
    public virtual class SelectOption {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public SelectOption() {}
        public SelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
     * @description Lightning Component Controller Result
     */
    public virtual class ControllerResult {
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String message {get;set;}

        public void setSuccess(String message) {
            this.state = DN_C_Utils.StatusCode.SUCCESS.name();
            this.message = message;
        }

        public void setError(String message) {
            this.state = DN_C_Utils.StatusCode.ERROR.name();
            this.message = message;
        }
    }

    /**
     * SObject Schema 정보 class
     */
    public class SchemaInfo {
        private Schema.SObjectType type;
        private Schema.DescribeSObjectResult result;

        public SchemaInfo() {}

        public SchemaInfo(String sObjectType) {
            this.setSchema(sObjectType);
        }

        public void setSchema(String sObjectType) {
            this.type = Schema.getGlobalDescribe().get(sObjectType);
            this.result = this.type.getDescribe();
        }

        public Schema.SObjectType getType() {
            return this.type;
        }

        public String getTypeToString() {
            return String.valueOf(this.type);
        }

        public String getLabel() {
            return this.result.getLabel();
        }

        public Schema.DescribeSObjectResult getResult() {
            return this.result;
        }

        public Map<Id, Schema.RecordTypeInfo> getRecordTypeMapByIds() {
            return this.result.getRecordTypeInfosById();
        }

        public Map<String, Schema.RecordTypeInfo> getRecordTypeMapByDeveloperNames() {
            return this.result.getRecordTypeInfosByDeveloperName();
        }

        public Map<String, Schema.RecordTypeInfo> getRecordTypeMapByNames() {
            return this.result.getRecordTypeInfosByName();
        }

        public Schema.RecordTypeInfo getRecordTypeByDeveloperName(String name) {
            return this.result.getRecordTypeInfosByDeveloperName().get(name);
        }

        public Schema.RecordTypeInfo getRecordTypeById(String typeId) {
            return this.result.getRecordTypeInfosById().get(typeId);
        }

        public Map<String, Schema.SObjectField> getFieldMap() {
            return this.result.fields?.getMap();
        }

        public List<Schema.SObjectField> getFieldList() {
            return this.getFieldMap().values();
        }

        public Map<String, Schema.FieldSet> getFieldSetMap() {
            return this.result.fieldsets?.getMap();
        }

        public List<Schema.FieldSet> getFieldSetList() {
            return this.getFieldSetMap().values();
        }

        public Schema.DescribeFieldResult getFieldInfo(String fieldName) {
            return this.getFieldMap().get(fieldName.toLowerCase())?.getDescribe();
        }

        public List<Schema.PicklistEntry> getPicklistEntrys(String picklistFieldName) {
            return this.getFieldInfo(picklistFieldName)?.getPicklistValues();
        }

        public List<SelectOption> getPicklistSelectOptions(String picklistFieldName) {
            List<SelectOption> options = new List<SelectOption>();
            List<Schema.PicklistEntry> entrys = this.getPicklistEntrys(picklistFieldName);
            if(entrys == null) return options;
            for(Schema.PicklistEntry entry : entrys){
                options.add(
                    new SelectOption(
                        entry.getLabel(),
                        entry.getValue()
                    )
                );
            }
            return options;
        }

        public Map<String, Boolean> getObjectPermission() {
            return new Map<String, Boolean>{
                'isCreateable'      => this.result.isCreateable()
                , 'isUpdateable'    => this.result.isUpdateable()
                , 'isDeletable'     => this.result.isDeletable()
                , 'isAccessible'    => this.result.isAccessible()
            };
        }
    }

    /** 
     * @description Get Lightning Experience Origin Url
     * @author DKBMC | 2021-07-28 
     * @return String 
    **/
    @AuraEnabled
    public static String getLexOrigin(){
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
    }

    /**
     * @description Get Visualforce Origin Url
     * @author DKBMC | 2021-07-28 
     * @return String 
    **/
    @AuraEnabled
    public static String getVFOrigin(){
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0] + '--c.visualforce.com';
    }
    
    /**
     * Dependent Picklist label value 가져오기
     * 
     * @param dependToken - sObject__c.Field__c
     * @return  `Map<String, List<Map<String, String>>>`
     */
    public static Map<String, List<Map<String, String>>> getDependentPicklistLV(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<Map<String, String>>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if (control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty( String.valueOf( ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor') ) )) {
                List<String> base64chars = String.valueOf( ( (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(entry)) ).get('validFor') ).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue = (controlEntries == null ? (Object)(index == 1) : (Object)(controlEntries[index].isActive() ? controlEntries[index].getValue() : null));
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)
                        continue;
                    if (!result.containsKey((String)controlValue)) {
                        result.put((String)controlValue, new List<Map<String, String>>());
                    }
                    Map<String, String> stdMap = new Map<String, String>();
                    stdMap.put('label', entry.getLabel());
                    stdMap.put('value', entry.getValue());
                    result.get((String)controlValue).add(stdMap);
                }
            }
        }
        return result;
    }

    /**
     * sObject Tab Icon 정보 조회 
     * 
     * @param sObjectName 조회 대상 sObject API Name
     * @return  `String`  
     */
    public static String getIconName(String sObjectName) {
        String iconInfo = 'custom:custom20';
        if(sObjectName == '') {
            iconInfo += ',' + 'Object';
            return iconInfo;
        }
        try{
            List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
            List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
            String objLabel = new SchemaInfo(sObjectName).getLabel();

            for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
                for(Schema.DescribeTabResult tr : tsr.getTabs()) {
                    if(sObjectName == tr.getSobjectName()) {
                        if( tr.isCustom() == true ) {
                            iconDesc.addAll(tr.getIcons());
                        } else {
                            iconInfo = 'standard:' + sObjectName.toLowerCase();
                        }
                    }
                }
            }
            for (Schema.DescribeIconResult ir : iconDesc) {
                if (ir.getContentType() == 'image/svg+xml'){
                    iconInfo = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                    break;
                }
            }
            
            iconInfo += ',' + objLabel;
        } catch(Exception e) {
            iconInfo = e.getMessage();
        }
        return iconInfo;
    }

    /**
     * get orgarniztion type: PRODUCTION/FULL/PARTIAL
     * @return  `String`
     */
    public static String getOrganizationType() {
        String organiztionType = '';
        Boolean isSandbox;
        try{
            isSandbox = [SELECT IsSandbox FROM Organization WHERE Id = :System.UserInfo.getOrganizationId()]?.IsSandbox;
            if(isSandbox) {
                Integer storageLimit = OrgLimits.getMap().get('DataStorageMB').getLimit();
                switch on storageLimit{
                    when 200 {
                        organiztionType = 'DEVELOPER';
                    }
                    when 1024 {
                        organiztionType = 'DEVELOPER_PRO';
                    }
                    when 5120 {
                        organiztionType = 'PARTIAL';
                    }
                    when else {
                        organiztionType = 'FULL';
                    }
                }
            } else {
                organiztionType = 'PRODUCTION';
            }

        } catch(Exception e) {

        }  
    
        return organiztionType;
    }

    /**
    * @description Iso Code에 따른 화폐 기호 반환
    * @author DKBMC | 2021-09-06 
    * @param Iso 
    * @return String 
    **/
    public static String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('KRW' == Iso ? '₩' : 
           ('CNY' == Iso ? '元' : 
           Iso)))))));
           return currencySymbol;
    }

    /**
    * @description ISO Code 반환
    * @author DKBMC | 2021-09-06 
    * @param someObject 
    * @return String 
    **/
    public static String getCurrencyIsoCode(SObject someObject){
        String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        return currencyIso;
    }

    /**
    * @description 화폐 기호 반환
    * @author DKBMC | 2021-09-06 
    * @param someObject 
    * @return String 
    **/
    public static String getCurrencySymbol(SObject someObject) {
        return getCurrencySymbolFromIso(getCurrencyIsoCode(someObject));
    }

    /**
     * 암호화 타입 열거형 클래스
     */
    public enum Encryption {MD5, SHA1, SHA3_256, SHA3_384, SHA3_512, SHA_256, SHA_512}

    /**
     * 문자 암호화
     * @param text 암호화 대상 문자
     * @param type 암호화 타입
     * @return  `Blob`
     */
    public static Blob doEncryption(String text, Encryption type) {
        if(String.isBlank(text)) return null;
        if(type == null) return null;

        Blob hash = Crypto.generateDigest(type.name().replace('_', '-'), Blob.valueOf(text));
        return hash;
    }
    
    /**
     * AES128 방식 암호화
     * @param targetData 암호화할 데이터
     * @return  `Map<String, String>`
     */
    public static Map<String, String> processEncryption(string targetData){
        Blob cryptoKey = Crypto.generateAesKey(128); 
        String strkey = EncodingUtil.base64Encode(cryptoKey);
        Blob data = Blob.valueOf(targetData); 
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data ); 
        string b64Data = EncodingUtil.base64Encode(encryptedData);  
        return new Map<String, String>{
            'key' => strkey,
            'encrypteValue' => b64Data
        };
    }

    /**
     * AES128 방식 복호화
     * @param encrypteValue 복호화할 데이터
     * @param key 복호화 Key
     * @return  `DecryptionResult`
     */
    public static DecryptionResult processDecryption(string encrypteValue, String key){
        DecryptionResult result = new DecryptionResult();
        Blob data = EncodingUtil.base64Decode(encrypteValue);
        Blob privateKey = EncodingUtil.base64Decode(key);
        try{ 
            Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES128', privateKey, data);
            result.decryptedData = dataToDecrypt.toString();
            result.setSuccess('decryption success!');
        } catch(Exception e){
            result.setError('error: ' + e.getMessage() + '|| stacktrace:: ' + e.getStackTraceString());
        }
        return result;
    }
    public class DecryptionResult extends DN_C_Utils.ControllerResult {
        public String decryptedData {get;set;}
    }

    /**
     * Dynamic Query result DTO
     */
    public class SearchResult extends DN_C_Utils.ControllerResult {
        @AuraEnabled public List<SObject> datas {get;set;}
        @AuraEnabled public Integer totalCount {get;set;}
    }

    /**
     * Search Filter (WHERE clause)
     */
    public class Filter {
        @AuraEnabled public List<Criteria> criteria {get;set;}
        @AuraEnabled public String filterLogic {get;set;}   // {0} AND ({1} OR {2})
        @AuraEnabled public String objectName {get;set;}    // sObject name
    }

    /**
     * Search Criteria (field, operator, value)
     */
    public class Criteria {
        @AuraEnabled public String fieldPath {get;set;}     // field api name
        @AuraEnabled public String operator {get;set;}      // =, !=, <, <=, >, >=, IN, NOT IN, LIKE ...
        @AuraEnabled public Object value {get;set;}         // field value
    }

    /**
     * Dynamic Query with Filter
     * @param fields `String` field api name
     * @param filter `Filter` filter
     * @param limitSize `Integer` limit size
     * @param offset `Integer` offset
     * @return `SearchResult`
     */
    @AuraEnabled
    public static SearchResult searchData(String fields, Filter filter, Integer limitSize, Integer offset) {
        SearchResult result = new SearchResult();
        try {
            if(String.isBlank(filter.objectName)) throw new CommException('ObjectName is required');
            
            Map<String, Object> cMap = new Map<String, Object>();
            String query = 'SELECT ' + fields + ' FROM ' + filter.objectName;
            String condition;

            if(filter.criteria != null && !filter.criteria.isEmpty()) {
                List<String> whereClause = new List<String>();

                for(Integer i=0 ; i < filter.criteria.size() ; i++) {
                    Criteria criteria = filter.criteria[i];
                    String key = 'value_' + i;

                    if(String.isNotBlank(criteria.operator)) {
                        Object value = criteria.value;
                        
                        whereClause.add(criteria.fieldPath + ' ' + criteria.operator + ' :' + key);

                        cMap.put(key, value);
                    }
                }
                condition = ' WHERE '
                          + (
                                String.isNotBlank(filter.filterLogic) ?
                                String.format(filter.filterLogic, whereClause) :
                                String.join(whereClause, ' AND ')
                            );
            }

            if(condition != null) query += condition;
            if(limitSize != null) query += ' LIMIT ' + limitSize;

            Integer totalCount = Database.queryWithBinds(query, cMap, AccessLevel.SYSTEM_MODE).size();

            if(limitSize != null && offset != null) query += ' OFFSET ' + offset;

            List<SObject> dataList = Database.queryWithBinds(query, cMap, AccessLevel.SYSTEM_MODE);

            result.datas = dataList;
            result.totalCount = totalCount;
            result.setSuccess('');

        } catch (Exception e) {
            result.setError(e.getMessage() + ' line:['+e.getLineNumber()+']');
        }

        return result;
    }
}