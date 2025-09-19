//**
//* @date: 2025-03-21 
//* @description:
//   VKORG : 1800 ->  DNS  = ZZWARHRS 값 상관 없이 저장 
//   VKORG : 4140 ->  DNSA = ZZWARHRS 값 이 1 인 것만 저장  
//*/
global with sharing class IF_ERP_WarrantyBatch 
                                            implements Database.Batchable<Object> , 
                                            Database.AllowsCallouts, 
                                            Database.Stateful  {
    public IF_ERP_WarrantyBatch(IF_ERP_Order_Classes.IF_ORDER_017_Req request, String tableNm){
        this.request = request;
        this.tableNm = tableNm;
    } 

    private IF_ERP_Order_Classes.IF_ORDER_017_Req request;
    private String tableNm;

    private String  message; 
    private Integer successCnt;
    private Integer failCnt;


    public Iterable<Object> start(Database.BatchableContext BC){
        // 1. CALL OUT SAP
        IF_ERP_Order_Classes.IF_ORDER_017_Res response = new IF_ERP_Order().IF_ORDER_017(request);

        if( tableNm.equals('T_DATA') ){
            System.debug('START _ T_DATA');
            return response.T_DATA;
        }
        else{
            throw new NotExistTableException();
        }
    }

    public void execute(Database.BatchableContext BC, List<Object> scope){
        System.debug('execute : ');
        Map<String,Warranty__c>                                             upsertMap   = new Map<String,Warranty__c>();

        try {
            if( tableNm.equals('T_DATA') ){

                // IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA - DATA 
                List<IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA>          itemList    = (List<IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA>)scope;
        
                // Map<String,IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA> 
                Map<String,IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA>    sapMap      = new Map<String,IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA>(); 
                
                // GET Warranty Key FROM SAP 
                Set<String>                                                 keys        = new Set<String>();
        
                System.debug('itemList size : '+itemList.size());

                Date todayDate = Date.today();

                
                for(IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA data : itemList){
                    String KSCHL    = (data.KSCHL    != null) ? data.KSCHL    : '';
                    String VKORG    = (data.VKORG    != null) ? data.VKORG    : '';
                    String SPART    = (data.SPART    != null) ? data.SPART    : '';
                    String VTWEG    = (data.VTWEG    != null) ? data.VTWEG    : '';
                    String ZZPR_WAR = (data.ZZPR_WAR != null) ? data.ZZPR_WAR : '';
                    String BZIRK    = (data.BZIRK    != null) ? data.BZIRK    : '';
                    String ZZWARHRS = (data.ZZWARHRS != null) ? data.ZZWARHRS : '';
                    if(data.DATBI == null || convertToDate(data.DATBI) < todayDate){
                        System.debug('ExpireDate : '+data.DATBI);
                        continue;
                    }
                    /**
                     * @date: 2025-03-21 
                     * @description:
                        VKORG : 1800 ->  DNS  = ZZWARHRS 값 상관 없이 저장 
                        VKORG : 4140 ->  DNSA = ZZWARHRS 값 이 1 인 것만 저장  
                     */
                    if( VKORG.equals('1800') || ( VKORG.equals('4140') && ZZWARHRS.equals('1') ) ){
                        String key = 'KSCHL_'+KSCHL+'__VKORG_'+VKORG+'__SPART_'+SPART+'__VTWEG_'+VTWEG+'__ZZPR_WAR_'+ZZPR_WAR+'__BZIRK_'+BZIRK;
                        System.debug(key);
                        sapMap.put(key, data);
                    }
                }

                keys = sapMap.keySet();
        
                Map<String,Warranty__c> warrantyMap = getAllWarrantyInOrgs();
                System.debug('key.size() : '+keys.size());
                System.debug('itemList.size() : '+itemList.size());
        
                for(String key : keys){
                
                    if( !warrantyMap.containsKey(key) ){
                        warrantyMap.put(key,new Warranty__c());
                    }
        
                    Warranty__c warranty = warrantyMap.get(key);
                    IF_ERP_Order_Classes.IF_ORDER_017_Res_T_DATA item = sapMap.get(key); 
                    warranty.warrantyKey__c     = key;
                    warranty.KSCHL__c           = item.KSCHL;
                    warranty.VKORG__c           = item.VKORG;
                    warranty.SPART__c           = item.SPART;
                    warranty.VTWEG__c           = item.VTWEG;
                    warranty.ZZPR_WAR__c        = item.ZZPR_WAR;
                    warranty.ZZWARRPER__c       = item.ZZWARRPER;
                    warranty.ZZPERUNIT__c       = item.ZZPERUNIT;
                    warranty.ZZWARHRS__c        = item.ZZWARHRS;
                    warranty.ZZCOVERAGE__c      = item.ZZCOVERAGE;
                    warranty.ZZCOVERAGE_B__c    = item.ZZCOVERAGE_B;
                    warranty.BZIRK__c           = item.BZIRK;
                    warranty.DATBI__c           = convertToDate(item.DATBI);
                    warranty.DATAB__c           = convertToDate(item.DATAB);
                    warranty.Percent__c         = Decimal.valueof(item.PERCENT);
                    upsertMap.put(key,warranty);
                    warrantyMap.remove(key);

                    System.debug('item.DATBI : '+item.DATBI);
                    System.debug('item.DATAB : '+item.DATAB);
                    System.debug('warranty.DATBI__c : '+warranty.DATBI__c);
                    System.debug('warranty.DATAB__c : '+warranty.DATAB__c);
                    System.debug('Warranty Map Size : '+warrantyMap.size());
                    System.debug('=========================================');
                    System.debug('');
                }
                
                for(Warranty__c  warranty : warrantyMap.values()){
                    System.debug('ZERO UPDATE WARRANTY  : '+warranty.warrantyKey__c);
                    warranty.Percent__c = Decimal.valueOf(0);
                    upsertMap.put(warranty.warrantyKey__c,warranty);
                }
            }

            // remove percent 0

            System.debug('warrantyList.size : '+upsertMap.size());
            for (Warranty__c warranty : upsertMap.values()) {
                System.debug('warranty id : '+warranty.Id);
            }

            List<Warranty__c> resultList = upsertMap.values();

            upsert  resultList;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC){
    }

    private Date convertToDate(String dateString){
        try {
            if(dateString == null && dateString == '') {
                return null;
            }
            System.debug('dateString : '+dateString);

            String[] dateArray = dateString.split('-');
            Integer year  = Integer.valueOf(dateArray[0]);
            Integer month = Integer.valueOf(dateArray[1]);
            Integer day   = Integer.valueOf(dateArray[2]); 
            if(year > 2999 ){
                year = 2999;
            }

            return Date.newInstance(year, month, day);
        } catch (Exception e) {
            System.debug('CONVERT DATE ERROR : '+e.getMessage());
            return null;
        }
    }

    public Map<String,Warranty__c> getWarrantyMapFromSFDC(Set<String> keys ){
        Map<String,Warranty__c> warrantyMap = new Map<String,Warranty__c>();
        for(Warranty__c warranty : [SELECT 
                                    KSCHL__c,
                                    VKORG__c,
                                    SPART__c,
                                    VTWEG__c,
                                    ZZPR_WAR__c,
                                    ZZWARRPER__c,
                                    ZZPERUNIT__c,
                                    ZZWARHRS__c,
                                    ZZCOVERAGE__c,
                                    ZZCOVERAGE_B__c,
                                    BZIRK__c,
                                    Percent__c,
                                    DATAB__c,
                                    DATBI__c,
                                    warrantyKey__c
                                    FROM Warranty__c
                                    WHERE warrantyKey__c IN: keys]){
            warrantyMap.put(warranty.warrantyKey__c, warranty);
        }
        return warrantyMap;
    }

    public Map<String,Warranty__c> getAllWarrantyInOrgs(){
        Map<String,Warranty__c> warrantyMap = new Map<String,Warranty__c>();
        for(Warranty__c warranty : [SELECT 
                                    KSCHL__c,
                                    VKORG__c,
                                    SPART__c,
                                    VTWEG__c,
                                    ZZPR_WAR__c,
                                    ZZWARRPER__c,
                                    ZZPERUNIT__c,
                                    ZZWARHRS__c,
                                    ZZCOVERAGE__c,
                                    ZZCOVERAGE_B__c,
                                    BZIRK__c,
                                    Percent__c,
                                    DATAB__c,
                                    DATBI__c,
                                    warrantyKey__c
                                    FROM Warranty__c]){
            if(warranty.warrantyKey__c == null || warranty.warrantyKey__c == '' ){
                String KSCHL    = (warranty.KSCHL__c    != null) ? warranty.KSCHL__c    : '';
                String VKORG    = (warranty.VKORG__c    != null) ? warranty.VKORG__c    : '';
                String SPART    = (warranty.SPART__c    != null) ? warranty.SPART__c    : '';
                String VTWEG    = (warranty.VTWEG__c    != null) ? warranty.VTWEG__c    : '';
                String ZZPR_WAR = (warranty.ZZPR_WAR__c != null) ? warranty.ZZPR_WAR__c : '';
                String BZIRK    = (warranty.BZIRK__c    != null) ? warranty.BZIRK__c    : '';
                String ZZWARHRS = (warranty.ZZWARHRS__c != null) ? warranty.ZZWARHRS__c : '';

                if( VKORG.equals('1800') || ( VKORG.equals('4140') && ZZWARHRS.equals('1') ) ){
                    warranty.warrantyKey__c = 'KSCHL_'+KSCHL+'__VKORG_'+VKORG+'__SPART_'+SPART+'__VTWEG_'+VTWEG+'__ZZPR_WAR_'+ZZPR_WAR+'__BZIRK_'+BZIRK;
                }
                else{
                    continue;
                }
            }
            warrantyMap.put(warranty.warrantyKey__c, warranty);
        }

        System.debug('warranty size : '+warrantyMap.size());

        return warrantyMap;
    }


// Custom Exception 
    public class NotExistTableException  extends Exception{}    

}