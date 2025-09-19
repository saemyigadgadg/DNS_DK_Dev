/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 02. 28. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-28 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_DealerPortalMigSettingController {
    private String OBJECTNAME {get;set;} // Object 명
    private DealerPortalMigSettings__mdt migSetting {get;set;}
    private Map<String,DealerPortalMigColumn__mdt>  migColumn {get;set;}
    
    public DN_DealerPortalMigSettingController() {
    }

    /**
     * @Description
     * 	- 생성자
    **/ 
    public DN_DealerPortalMigSettingController(String objectName) {
        this.OBJECTNAME = objectName;
        this.migSetting = DealerPortalMigSettings__mdt.getInstance(objectName);
        this.migColumn  = new Map<String,DealerPortalMigColumn__mdt>();
        List<DealerPortalMigColumn__mdt> migList = [
            SELECT 
            Id, DeveloperName, WhereField__c,
            MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName,
            DealerPortalMigSettings__c, TargetField__c, 
            CriteriaField__c, FromObject__c,ObjectByKeyField__c,AdditionalWhere__c, IsIncludeNullValue__c
            FROM DealerPortalMigColumn__mdt
            WHERE DealerPortalMigSettings__c = :this.migSetting.Id
            AND IsActive__c  = true
        ];
        System.debug(migList + ' :: migList');
        for(DealerPortalMigColumn__mdt col : migList) {
            this.migColumn.put(col.CriteriaField__c, col);
        }
    }   
    
    /**
     * @Description
     * 	- 마이그 설정에 따른 배치에서 호출하는 메소드
    **/ 
    public List<sObject> convertBatch2(List<sObject> recordList) {
        if(!migSetting.IsMig__c) {
            System.debug(' 마이그 설정 false');
            return null;
        }

        List<DealerPortalMigColumn__mdt> migList = [
            SELECT 
            Id, DeveloperName, WhereField__c,
            MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName,
            DealerPortalMigSettings__c, TargetField__c, 
            CriteriaField__c, FromObject__c,ObjectByKeyField__c,AdditionalWhere__c, IsIncludeNullValue__c
            FROM DealerPortalMigColumn__mdt
            WHERE DealerPortalMigSettings__c = :this.migSetting.Id
            AND IsActive__c  = true
        ];
        System.debug(migList + ' :: migList');
        Map<String, List<DealerPortalMigColumn__mdt>> metaListMap = new Map<String, List<DealerPortalMigColumn__mdt>>();
        for(DealerPortalMigColumn__mdt col : migList) {
            if(!metaListMap.containsKey(col.CriteriaField__c)) metaListMap.put(col.CriteriaField__c, new List<DealerPortalMigColumn__mdt>());
            metaListMap.get(col.CriteriaField__c).add(col);
        }
        List<String> criteriaField = new List<String>(metaListMap.keySet());
        Map<String,set<String>> criteriaFieldMap = new Map<String,set<String>>();
        for(String fie : criteriaField) {
            criteriaFieldMap.put(fie, new set<String>());
        }
        System.debug(criteriaFieldMap.keySet() + ' :: criteriaFieldMap.keySet()');
        System.debug(recordList+' ::: recordList');
        for(sObject obj : recordList) {
            for(String key : criteriaFieldMap.keySet()) {
                if((String) obj.get(key) !=null) {
                    String value = (String) obj.get(key);
                    System.debug(key  +' :: key');
                    System.debug( obj.get(key) + ' :: String) obj.get(key)');
                    criteriaFieldMap.get(key).add(value);
                }   
            }
        }
        System.debug(criteriaFieldMap + ' ::: criteriaFieldMap');
        Map<String,Map<String,String>> mappingMap = new Map<String,Map<String,String>>();
        for(String criterFie : criteriaFieldMap.keySet()) {
            for(DealerPortalMigColumn__mdt colMdt : metaListMap.get(criterFie)) {
                String query = 'SELECT '+colMdt.WhereField__c+','+colMdt.ObjectByKeyField__c+ ' FROM '+ colMdt.FromObject__c + ' WHERE '+colMdt.WhereField__c + ' IN(\'' +String.join(criteriaFieldMap.get(criterFie), '\',\'')+'\') AND '+colMdt.WhereField__c+ ' !=null'; 
                if(String.isNotBlank(colMdt.AdditionalWhere__c) ) query += ' '+colMdt.AdditionalWhere__c;
                System.debug(query + '::query');
                List<sObject> objList = Database.query(query);
                Map<String,String> keyValueMap = new Map<String,String>();
                for(sObject rec : objList) {
                    System.debug(objList + ' ::objList');
                    List<String> keyList =colMdt.WhereField__c.split('\\.');
                    System.debug(colMdt.WhereField__c + ' :: colMdt.WhereField__c');
                    System.debug(keyList +' :: keyList');
                    String key = '';
                    if(keyList.size() > 1) {
                        sObject objectByLookup = rec;
                        for(Integer i=0; i<keyList.size(); i++) {
                            if(i == keyList.size()-1) {
                                key = (String) objectByLookup.get(keyList[i]);
                            } else{
                                objectByLookup = objectByLookup.getSObject(keyList[i]);
                            }
                        }
                    } else {
                        System.debug(colMdt.WhereField__c + ' : colMdt.WhereField__c');
                        key = (String) rec.get(colMdt.WhereField__c);
                    }
                    String value = (String) rec.get(colMdt.ObjectByKeyField__c);
                    keyValueMap.put(key,value);
                }   
                mappingMap.put(criterFie, keyValueMap);
            }
        }
        System.debug(mappingMap + ' :: mappingMap');
        for(sObject recordSet :recordList) {
            for(String criterField : mappingMap.keySet()) {
                for(DealerPortalMigColumn__mdt colMdt : metaListMap.get(criterField)) {
                    Map<String,String> valueMap = mappingMap.get(criterField);
                    String key = (String) recordSet.get(criterField);
                    if(String.isNotBlank(key)) {
                        if(valueMap.get(key) != null) {
                            recordSet.put(colMdt.TargetField__c,valueMap.get(key));
                        }
    
                        if(colMdt.IsIncludeNullValue__c && valueMap.get(key) == null) {
                            recordSet.put(colMdt.TargetField__c,valueMap.get(key));
                        }
                    } 
                }
            }
            recordSet.put('IsConvert__c',true);
            
            System.debug(recordSet + ' :: recordSet');
        }
        return recordList;
    }

    /**
     * @Description
     * 	- 마이그 설정에 따른 배치에서 호출하는 메소드
    **/ 
    public List<sObject> convertBatch(List<sObject> recordList) {
        if(!migSetting.IsMig__c) {
            System.debug(' 마이그 설정 false');
            return null;
        }
        List<String> criteriaField = new List<String>(this.migColumn.keySet());
        Map<String,set<String>> criteriaFieldMap = new Map<String,set<String>>();
        for(String fie : criteriaField) {
            criteriaFieldMap.put(fie, new set<String>());
        }
        System.debug(criteriaFieldMap.keySet() + ' :: criteriaFieldMap.keySet()');
        System.debug(recordList+' ::: recordList');
        for(sObject obj : recordList) {
            for(String key : criteriaFieldMap.keySet()) {
                if((String) obj.get(key) !=null) {
                    String value = (String) obj.get(key);
                    System.debug(key  +' :: key');
                    System.debug( obj.get(key) + ' :: String) obj.get(key)');
                    criteriaFieldMap.get(key).add(value);
                }   
            }
        }
        System.debug(criteriaFieldMap + ' ::: criteriaFieldMap');
        Map<String,Map<String,String>> mappingMap = new Map<String,Map<String,String>>();
        for(String criterFie : criteriaFieldMap.keySet()) {// 필드 매핑은 최대 돌아가는게 많아도 5번정도
            DealerPortalMigColumn__mdt colMdt = migColumn.get(criterFie);
            String query = 'SELECT '+colMdt.WhereField__c+','+colMdt.ObjectByKeyField__c+ ' FROM '+ colMdt.FromObject__c + ' WHERE '+colMdt.WhereField__c + ' IN(\'' +String.join(criteriaFieldMap.get(criterFie), '\',\'')+'\') AND '+colMdt.WhereField__c+ ' !=null'; 
            if(String.isNotBlank(colMdt.AdditionalWhere__c) ) query += ' '+colMdt.AdditionalWhere__c;
            System.debug(query + '::query');
            List<sObject> objList = Database.query(query);
            Map<String,String> keyValueMap = new Map<String,String>();
            for(sObject rec : objList) {
                System.debug(objList + ' ::objList');
                List<String> keyList =colMdt.WhereField__c.split('\\.');
                System.debug(colMdt.WhereField__c + ' :: colMdt.WhereField__c');
                System.debug(keyList +' :: keyList');
                String key = '';
                if(keyList.size() > 1) {
                    sObject objectByLookup = rec;
                    for(Integer i=0; i<keyList.size(); i++) {
                        if(i == keyList.size()-1) {
                            key = (String) objectByLookup.get(keyList[i]);
                        } else{
                            objectByLookup = objectByLookup.getSObject(keyList[i]);
                        }
                    }
                } else {
                    System.debug(colMdt.WhereField__c + ' : colMdt.WhereField__c');
                    key = (String) rec.get(colMdt.WhereField__c);
                }
                String value = (String) rec.get(colMdt.ObjectByKeyField__c);
                keyValueMap.put(key,value);
            }   
            mappingMap.put(criterFie, keyValueMap);
        }
        System.debug(mappingMap + ' :: mappingMap');
        for(sObject recordSet :recordList) {
            for(String criterField : mappingMap.keySet()) {
                DealerPortalMigColumn__mdt colMdt = migColumn.get(criterField);
                Map<String,String> valueMap = mappingMap.get(criterField);
                String key = (String) recordSet.get(criterField);
                if(String.isNotBlank(key)) {
                    if(valueMap.get(key) != null) {
                        recordSet.put(migColumn.get(criterField).TargetField__c,valueMap.get(key));
                    }

                    if(colMdt.IsIncludeNullValue__c && valueMap.get(key) == null) {
                        recordSet.put(migColumn.get(criterField).TargetField__c,valueMap.get(key));
                    }
                } 
            }
            recordSet.put('IsConvert__c',true);
            
            System.debug(recordSet + ' :: recordSet');
        }
        return recordList;
    }

}