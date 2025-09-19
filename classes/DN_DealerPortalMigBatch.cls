/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 03. 14. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-14 | Iltae seo      | 최초작성 
 */
public with sharing class DN_DealerPortalMigBatch implements Database.Batchable<SObject>,Database.Stateful{
    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) logger = new DN_AsyncApexErrorLogger();
            return logger;
        }
        set;
    }
    public String migSettingName {get; set;} //DealerId
    public String ojbectName {get; set;}
    public Boolean isTest {get; set;}
    private set<String> selectQ {get;set;}
    private Boolean isMutiple = false;

    public DN_DealerPortalMigBatch() {

    }
    /**
     * @Description
     * 	- 마이그 대상이 되는 세팅명, 옵젝명에 따라 설정
    **/
    public DN_DealerPortalMigBatch(String migSettingName,String ojbectName) {
        this.migSettingName = migSettingName;
        this.ojbectName = ojbectName;
        this.selectQ = new set<String>();
        DealerPortalMigSettings__mdt migSetting = DealerPortalMigSettings__mdt.getInstance(migSettingName);
        List<DealerPortalMigColumn__mdt> migList = [
            SELECT 
            Id, DeveloperName, WhereField__c,
            MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName,
            DealerPortalMigSettings__c, TargetField__c, 
            CriteriaField__c, FromObject__c,ObjectByKeyField__c,AdditionalWhere__c
            FROM DealerPortalMigColumn__mdt
            WHERE DealerPortalMigSettings__c = :migSetting.Id
        ];
        for(DealerPortalMigColumn__mdt mdtField : migList) {
            this.selectQ.add(mdtField.TargetField__c);
            this.selectQ.add(mdtField.CriteriaField__c);
        }
        this.isTest = false;
    }

    /**
     * @Description
     * 	- 마이그 대상이 되는 세팅명, 옵젝명에 따라 설정, 멀티여부
    **/
    public DN_DealerPortalMigBatch(String migSettingName,String ojbectName,Boolean isMutiple) {
        this(migSettingName, ojbectName);
        this.isMutiple = isMutiple;
    }

    /**
     * @Description
     * 	- 배치 시작
    **/
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'SELECT Id,IsConvert__c,';
        query += String.join(selectQ, ', ');
        query += ' FROM '+ this.ojbectName + ' WHERE IsConvert__c = false';
        return Database.getQueryLocator(query);
    }

    /**
     * @Description
     * 	- 배치 실행
    **/
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_DealerPortalMigBatch Batch Execute ================');
        System.debug(this.isTest + ' ::this.isTest');
        try {
            DN_DealerPortalMigSettingController settings = new DN_DealerPortalMigSettingController(this.migSettingName);
            List<sObject> ojbectList;
            if(isMutiple) {
                ojbectList = settings.convertBatch2(scope);
            }else {
                ojbectList = settings.convertBatch(scope);
            }
            if(this.isTest) { // 테코에서 Exception 발생시키기 위해 Id를 null로 변경
                for(sObject obj : ojbectList) {
                   obj.put('Id', null);
                }
            }
            update ojbectList;
            
        } catch (Exception e) {
            String log = ''
                       + ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_DealerPortalMigBatch', 'execute', 'BatchApex', log);
        }
    }

    /**
     * @Description
     * 	- 배치 종료
    **/
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_DealerPortalMigBatch Batch finish ================');
        System.debug('배치 실행 완료');
        try {
            
        } catch (Exception e) {
            String log = ''
                       + ' Exception : ' + e.getStackTraceString()
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_DealerPortalMigBatch', 'finish.DN_DealerPortalMigBatch', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }
    }
}