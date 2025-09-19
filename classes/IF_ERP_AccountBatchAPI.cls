public with sharing class IF_ERP_AccountBatchAPI 
                                                implements Database.Batchable<Object> , 
                                                        Database.AllowsCallouts, 
                                                        Database.Stateful  {
    public IF_ERP_AccountBatchAPI(IF_ERP_Account_Classes.IF_ACCOUNT_005_Res response) {
        this.response = response;
    }

    private final IF_ERP_Account_Classes.IF_ACCOUNT_005_Res response;

    public Iterable<Object> start(Database.BatchableContext BC){

        List<IF_ERP_AccountBatchAPI.AccountData> dataList = new List<IF_ERP_AccountBatchAPI.AccountData>();

        for(IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNA1 item : this.response.T_KNA1){
            dataList.add(convertFromKNA1(item));
        }
        for(IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV item : this.response.T_KNVV){
            dataList.add(convertFromKNVV(item));
        }
        for(IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP item : this.response.T_KNVP){
            dataList.add(convertFromKNVP(item));
        }

        return dataList;
  }

/** BATCH | EXECUTE
 */        
 public void execute(Database.BatchableContext BC, List<Object> scope){
    
    List<IF_ERP_AccountBatchAPI.AccountData> dataList = (List<IF_ERP_AccountBatchAPI.AccountData>)scope; 
    
    Set<String> kna1s = new Set<String>(); 
    Set<String> knvvs = new Set<String>();
    Set<String> knvps = new Set<String>();

    for(IF_ERP_AccountBatchAPI.AccountData item : dataList){
             if(item.TABLE_NAME == 'KNA1')  { kna1s.add(item.KUNNR); }
        else if(item.TABLE_NAME == 'KNVV')  { knvvs.add(item.KUNNR); }
        else                                { knvps.add(item.KUNNR); }
    }
    Map<String,IF_Account__c> kna1Result = new Map<String,IF_Account__c>();    
    Map<String,IF_Account__c> knvvResult = new Map<String,IF_Account__c>();    
    Map<String,IF_Account__c> knvpResult = new Map<String,IF_Account__c>();    
    
    Map<String,IF_Account__c> kna1Map = findMap_KNA1(kna1s);
    Map<String,IF_Account__c> knvvMap = findMap_KNVV(knvvs); 
    Map<String,IF_Account__c> knvpMap = findMap_KNVP(knvps); 


    for(IF_ERP_AccountBatchAPI.AccountData item : dataList){
        IF_Account__c acc;
        String        key = '';
         if( item.TABLE_NAME == 'KNA1' ){
            key = item.TABLE_NAME+'_'+item.KUNNR;
            if ( kna1Map.containsKey(key) ) { acc = kna1Map.get(key);}
            acc = convertToIfAccount(item,acc);
            kna1Result.put(key,acc);
        }
        else if ( item.TABLE_NAME == 'KNVV'  ){
            key = item.TABLE_NAME+'_'+item.KUNNR+'_'+item.VKORG+'_'+item.SPART;
            if ( knvvMap.containsKey(key) ) { acc = knvvMap.get(key);}
            acc = convertToIfAccount(item,acc);
            knvvResult.put(key,acc);

        }
        else {
            key = item.TABLE_NAME+'_'+item.KUNNR+'_'+item.PARVW+'_'+item.VKORG+'_'+item.SPART+'_'+item.KUNN2;
            if      ( knvpMap.containsKey(key) ) { acc = knvpMap.get(key);}
            acc = convertToIfAccount(item,acc);
            knvpResult.put(key,acc);
        }
    }         

    if(kna1Result.size() > 0){
        List<Database.UpsertResult> upsertIfObj = Database.upsert(kna1Result.values(),  false);
        for(Database.UpsertResult ur : upsertIfObj) {
            if(!ur.isSuccess()) { System.debug('IF ACCOUNT Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
        }
    }
    if(knvvResult.size() > 0){
        List<Database.UpsertResult> upsertIfObj = Database.upsert(knvvResult.values(),  false);
        for(Database.UpsertResult ur : upsertIfObj) {
            if(!ur.isSuccess()) { System.debug('IF ACCOUNT Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
        }
    }
    if(knvpResult.size() > 0){
        List<Database.UpsertResult> upsertIfObj = Database.upsert(knvpResult.values(),  false);
        for(Database.UpsertResult ur : upsertIfObj) {
            if(!ur.isSuccess()) { System.debug('IF ACCOUNT Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
        }
    }        
}

/** BATCH | FINSH 
 */            
 public void finish(Database.BatchableContext BC){
    if (!Test.isRunningTest() ){
        DN_UpdateAccountFromERPBatch batch = new DN_UpdateAccountFromERPBatch();
        Database.executeBatch(batch, 50);        
    }
 }



 public class AccountData {
    public AccountData(){}
     public String TABLE_NAME { get; set; } public Boolean IsComplete { get; set; } public String KUNNR { get; set; } 
     public String VKORG      { get; set; } public String VTWEG { get; set; } public String SPART { get; set; } 
     public String BZIRK      { get; set; } public String VKBUR { get; set; } public String VKGRP { get; set; } 
     public String KDGRP      { get; set; } public String WAERS { get; set; } public String INCO1 { get; set; } 
     public String ZTERM      { get; set; } public String KTGRD { get; set; } public String VSBED { get; set; } 
     public String AUFSD      { get; set; } public String ORT01 { get; set; } public String NAME1 { get; set; } 
     public String STRAS      { get; set; } public String LAND1 { get; set; } public String LANDX { get; set; } 
     public String ERNAM      { get; set; } public String ERDAT { get; set; } public String KTOKD { get; set; } 
     public String KTEXT      { get; set; } public String ANRED { get; set; } public String LOCATION { get; set; }
     public String REGIO      { get; set; } public String SORTL { get; set; } public String NAME3 { get; set; } 
     public String PSTLZ      { get; set; } public String TELF1 { get; set; } public String TELF2 { get; set; } 
     public String TELFX      { get; set; } public String KNURL { get; set; } public String KATR1 { get; set; } 
     public String VTEXT1 { get; set; } public String KATR2 { get; set; } public String VTEXT2 { get; set; } 
     public String KATR3 { get; set; } public String VTEXT3 { get; set; } public String STCD1 { get; set; } 
     public String STCD2 { get; set; } public String J_1KFTBUS { get; set; } public String J_1KFTIND { get; set; } 
     public String JMZAH { get; set; } public String JMJAH { get; set; } public String BZTXT { get; set; } 
     public String BEZEI { get; set; } public String KTONR { get; set; } public String NAME2 { get; set; } 
     public String VTEXT4 { get; set; } public String VTEXT5 { get; set; } public String VTEXT6 { get; set; } 
     public String VTEXT7 { get; set; } public String MDLNM { get; set; } public String MATNR { get; set; } 
     public String MAKTX { get; set; } public String MEINS { get; set; } public String ADRNR { get; set; } 
     public String FLAG { get; set; } public String STCD4 { get; set; } public String SATNR { get; set; } 
     public String J_1KFREPRE { get; set; } public String VBELN { get; set; } public String WADAT_IST { get; set; } 
     public String VRKME { get; set; } public String LFIMG { get; set; } public String TOTAL_LFIMG { get; set; } 
     public String ZSEXTEN { get; set; } public String ZMESSAGE { get; set; } public String STCD3 { get; set; } 
     public String KONZS { get; set; } public String NAME_GR { get; set; } public String KATR10 { get; set; } 
     public String VTEXT10 { get; set; } public String KATR20 { get; set; } public String VTEXT20 { get; set; } 
     public String KATR30 { get; set; } public String VTEXT30 { get; set; } public String GKAM_M { get; set; } 
     public String ZTURNOVER { get; set; } public String ZEMPL { get; set; } public String ZPRESI { get; set; } 
     public String ZYEAR { get; set; } public String ZHEADQ { get; set; } public String ZVOL { get; set; } 
     public String ZPROD { get; set; } public String ZBUYER { get; set; } public String ZWEBPAGE { get; set; } 
     public String REGIO_T { get; set; } public String SMTP_ADDR { get; set; } public String SORT1 { get; set; } 
     public String SORT2 { get; set; } public String LZONE { get; set; } public String SPRAS { get; set; } 
     public String STR_SUPPL1 { get; set; } public String STR_SUPPL2 { get; set; } public String STR_SUPPL3 { get; set; } 
     public String PARVW { get; set; } public String VTEXT { get; set; } public String KUNN2 { get; set; } 
     public String KNREF { get; set; } public String DEFPA { get; set; }
}

public IF_ERP_AccountBatchAPI.AccountData convertFromKNA1(IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNA1 item){
    IF_ERP_AccountBatchAPI.AccountData result = new IF_ERP_AccountBatchAPI.AccountData(); 
    result.TABLE_NAME = 'KNA1';  // 테이블 이름 예시
    result.IsComplete = false;  // 처리 완료 여부 예시
    result.KUNNR = validKUNNR(item.KUNNR);  
    result.STR_SUPPL3   = item.STR_SUPPL3;    result.STR_SUPPL2   = item.STR_SUPPL2;    result.STR_SUPPL1   = item.STR_SUPPL1;
    result.SPRAS        = item.SPRAS;          result.LZONE        = item.LZONE;          result.SORT2        = item.SORT2;
    result.SORT1        = item.SORT1;          result.SMTP_ADDR    = item.SMTP_ADDR;      result.REGIO_T      = item.REGIO_T;
    result.ZWEBPAGE     = item.ZWEBPAGE;       result.ZBUYER       = item.ZBUYER;         result.ZPROD        = item.ZPROD;
    result.ZVOL         = item.ZVOL;           result.ZHEADQ       = item.ZHEADQ;         result.ZYEAR        = item.ZYEAR;
    result.ZPRESI       = item.ZPRESI;         result.ZEMPL        = item.ZEMPL;          result.ZTURNOVER    = item.ZTURNOVER;
    result.GKAM_M       = item.GKAM_M;         result.VTEXT30      = item.VTEXT30;        result.KATR30       = item.KATR30;
    result.VTEXT20      = item.VTEXT20;        result.KATR20       = item.KATR20;         result.VTEXT10      = item.VTEXT10;
    result.KATR10       = item.KATR10;         result.NAME_GR      = item.NAME_GR;        result.KONZS        = item.KONZS;
    result.STCD3        = item.STCD3;          result.ZMESSAGE     = item.ZMESSAGE;       result.ZSEXTEN      = item.ZSEXTEN;
    result.TOTAL_LFIMG  = item.TOTAL_LFIMG;    result.LFIMG        = item.LFIMG;          result.VRKME        = item.VRKME;
    result.WADAT_IST    = item.WADAT_IST;      result.VBELN        = item.VBELN;          result.J_1KFREPRE    = item.J_1KFREPRE;
    result.AUFSD        = item.AUFSD;          result.SATNR        = item.SATNR;          result.STCD4        = item.STCD4;
    result.FLAG         = item.FLAG;           result.ADRNR        = item.ADRNR;          result.MEINS        = item.MEINS;
    result.MAKTX        = item.MAKTX;          result.MATNR        = item.MATNR;          result.MDLNM        = item.MDLNM;
    result.VTEXT7       = item.VTEXT7;         result.SPART        = item.SPART;          result.VTEXT6       = item.VTEXT6;
    result.VTWEG        = item.VTWEG;          result.VTEXT5       = item.VTEXT5;         result.VKORG        = item.VKORG;
    result.VTEXT4       = item.VTEXT4;         result.VSBED        = item.VSBED;          result.NAME2        = item.NAME2;
    result.KTONR        = item.KTONR;          result.BEZEI        = item.BEZEI;          result.BZTXT        = item.BZTXT;
    result.JMJAH        = item.JMJAH;          result.JMZAH        = item.JMZAH;          result.J_1KFTIND    = item.J_1KFTIND;
    result.J_1KFTBUS    = item.J_1KFTBUS;       result.STCD2        = item.STCD2;          result.STCD1        = item.STCD1;
    result.VTEXT3       = item.VTEXT3;         result.KATR3        = item.KATR3;          result.VTEXT2       = item.VTEXT2;
    result.KATR2        = item.KATR2;          result.VTEXT1       = item.VTEXT1;         result.KATR1        = item.KATR1;
    result.KNURL        = item.KNURL;          result.TELFX        = item.TELFX;          result.TELF2        = item.TELF2;
    result.TELF1        = item.TELF1;          result.PSTLZ        = item.PSTLZ;          result.NAME3        = item.NAME3;
    result.SORTL        = item.SORTL;          result.REGIO        = item.REGIO;          result.LOCATION     = item.LOCATION;
    result.ANRED        = item.ANRED;          result.KTEXT        = item.KTEXT;          result.KTOKD        = item.KTOKD;
    result.ERDAT        = item.ERDAT;          result.ERNAM        = item.ERNAM;          result.LANDX        = item.LANDX;
    result.LAND1        = item.LAND1;          result.STRAS        = item.STRAS;          result.NAME1        = item.NAME1;
    result.ORT01        = item.ORT01;          result.KDGRP        = item.KDGRP;          result.VKBUR        = item.VKBUR;
    result.BZIRK        = item.BZIRK;       
    return result;
}


public IF_ERP_AccountBatchAPI.AccountData convertFromKNVV(IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVV item){
    IF_ERP_AccountBatchAPI.AccountData result = new IF_ERP_AccountBatchAPI.AccountData(); 
    result.TABLE_NAME = 'KNVV';  // 테이블 이름 예시
    result.IsComplete = false;  // 처리 완료 여부 예시
    result.KUNNR = validKUNNR(item.KUNNR);
    result.VKORG = item.VKORG;  result.VTWEG = item.VTWEG;
    result.SPART = item.SPART;  result.BZIRK = item.BZIRK;  result.VKBUR = item.VKBUR;
    result.VKGRP = item.VKGRP;  result.KDGRP = item.KDGRP;  result.WAERS = item.WAERS;
    result.INCO1 = item.INCO1;  result.ZTERM = item.ZTERM;  result.KTGRD = item.KTGRD;
    result.VSBED = item.VSBED;  result.AUFSD = item.AUFSD;  
    System.debug('KNVV - KUNNR :'+result.KUNNR);
    return result;
}  

public IF_ERP_AccountBatchAPI.AccountData convertFromKNVP(IF_ERP_Account_Classes.IF_ACCOUNT_005_Res_T_KNVP item){
    IF_ERP_AccountBatchAPI.AccountData result = new IF_ERP_AccountBatchAPI.AccountData(); 
    result.TABLE_NAME = 'KNVP';  // 테이블 이름 예시
    result.IsComplete = false;  // 처리 완료 여부 예시
    result.KUNNR = validKUNNR(item.KUNNR);  
    result.KUNN2 = validKUNNR(item.KUNN2);
    result.VKORG = item.VKORG;  result.VTWEG = item.VTWEG;
    result.SPART = item.SPART;  result.PARVW = item.PARVW;  result.VTEXT = item.VTEXT;
    result.KNREF = item.KNREF;  result.DEFPA = item.DEFPA;
    System.debug('KNVP - KUNNR :'+result.KUNNR);
    System.debug('KNVP - KUNN2 :'+result.KUNN2);
    return result;
}     

    public String validKUNNR(String kunnr){
        try{
            return String.valueOf(Integer.valueOf(kunnr));
        }
        catch(Exception e){
            return kunnr;
        }
    }

    public Map<String,IF_Account__c> findMap_KNA1(Set<String> keys){
        
        Map<String,IF_Account__c> ifTableMap = new Map<String,IF_Account__c>();

        for(IF_Account__c ifObj : [ SELECT Id,KUNNR__c, ORT01__c, NAME1__c, STRAS__c, LAND1__c, LANDX__c, ERNAM__c, ERDAT__c, KTOKD__c, KDGRP__c, KTEXT__c, ANRED__c, LOCATION__c, REGIO__c, SORTL__c, NAME3__c, PSTLZ__c, TELF1__c, TELF2__c, TELFX__c,
            KNURL__c, KATR1__c, VTEXT1__c, KATR2__c, VTEXT2__c, KATR3__c, VTEXT3__c, STCD1__c, STCD2__c, J_1KFTBUS__c, J_1KFTIND__c, JMZAH__c, JMJAH__c, BZIRK__c, BZTXT__c, VKBUR__c, BEZEI__c, KTONR__c, NAME2__c, VSBED__c,
            VTEXT4__c, VKORG__c, VTEXT5__c, VTWEG__c, VTEXT6__c, SPART__c, VTEXT7__c, MDLNM__c, MATNR__c, MAKTX__c, MEINS__c, ADRNR__c, FLAG__c, STCD4__c, SATNR__c, AUFSD__c, J_1KFREPRE__c, VBELN__c, WADAT_IST__c, VRKME__c,
            LFIMG__c, TOTAL_LFIMG__c, ZSEXTEN__c, ZMESSAGE__c, STCD3__c, KONZS__c, NAME_GR__c, KATR10__c, VTEXT10__c, KATR20__c, VTEXT20__c, KATR30__c, VTEXT30__c, GKAM_M__c, ZTURNOVER__c, ZEMPL__c, ZPRESI__c, ZYEAR__c,
            ZHEADQ__c, ZVOL__c, ZPROD__c, ZBUYER__c, ZWEBPAGE__c, REGIO_T__c, SMTP_ADDR__c, SORT1__c, SORT2__c, LZONE__c, SPRAS__c, STR_SUPPL1__c, STR_SUPPL2__c, STR_SUPPL3__c,
            CreatedDate,LastModifiedDate, IsComplete__c, TABLE_NAME__c
            FROM IF_Account__c
            WHERE KUNNR__c IN: keys
            AND (CreatedDate = TODAY OR LastModifiedDate = TODAY)
        ]){
            ifTableMap.put(ifObj.TABLE_NAME__c+'_'+ifObj.KUNNR__c,ifObj);
        }
        return ifTableMap;
    }

    public Map<String,IF_Account__c> findMap_KNVV(Set<String> keys){
        
        Map<String,IF_Account__c> ifTableMap = new Map<String,IF_Account__c>();

        for(IF_Account__c ifObj : [ 
            SELECT Id,KUNNR__c, VKORG__c, VTWEG__c, SPART__c, BZIRK__c, VKBUR__c, 
            VKGRP__c, KDGRP__c, WAERS__c, INCO1__c, ZTERM__c, KTGRD__c, VSBED__c, AUFSD__c,
            CreatedDate,LastModifiedDate, IsComplete__c, TABLE_NAME__c
            FROM IF_Account__c
            WHERE KUNNR__c IN: keys
            AND (CreatedDate = TODAY OR LastModifiedDate = TODAY)
        ]){
            ifTableMap.put(ifObj.TABLE_NAME__c+'_'+ifObj.KUNNR__c+'_'+ifObj.VKORG__c+'_'+ifObj.SPART__c,ifObj);
        }
        return ifTableMap;
    }
      
    public Map<String,IF_Account__c> findMap_KNVP(Set<String> keys){
        
        Map<String,IF_Account__c> ifTableMap = new Map<String,IF_Account__c>();

        for(IF_Account__c ifObj : [ 
            SELECT Id,KUNNR__c, VKORG__c, VTWEG__c, SPART__c,
            PARVW__c, VTEXT__c, KUNN2__c, KNREF__c, DEFPA__c,
            CreatedDate,LastModifiedDate, IsComplete__c, TABLE_NAME__c
            FROM IF_Account__c
            WHERE KUNNR__c IN: keys
            AND (CreatedDate = TODAY OR LastModifiedDate = TODAY)
        ]){
            ifTableMap.put(ifObj.TABLE_NAME__c+'_'+ifObj.KUNNR__c+'_'+ifObj.PARVW__c+'_'+ifObj.VKORG__c+'_'+ifObj.SPART__c+'_'+ifObj.KUNN2__c,ifObj);
        }
        return ifTableMap;
    }

    public IF_Account__c convertToIfAccount(IF_ERP_AccountBatchAPI.AccountData item, IF_Account__c ifAcc){
        if(ifAcc == null){
            ifAcc = new IF_Account__c();
        }
        ifAcc.TABLE_NAME__c = item.TABLE_NAME; 
        ifAcc.IsComplete__c = false; 
        ifAcc.KUNNR__c = item.KUNNR;
        ifAcc.VKORG__c = item.VKORG; ifAcc.VTWEG__c = item.VTWEG; ifAcc.SPART__c = item.SPART;
        ifAcc.BZIRK__c = item.BZIRK; ifAcc.VKBUR__c = item.VKBUR; ifAcc.VKGRP__c = item.VKGRP;
        ifAcc.KDGRP__c = item.KDGRP; ifAcc.WAERS__c = item.WAERS; ifAcc.INCO1__c = item.INCO1;
        ifAcc.ZTERM__c = item.ZTERM; ifAcc.KTGRD__c = item.KTGRD; ifAcc.VSBED__c = item.VSBED;
        ifAcc.AUFSD__c = item.AUFSD; ifAcc.ORT01__c = item.ORT01; ifAcc.NAME1__c = item.NAME1;
        ifAcc.STRAS__c = item.STRAS; ifAcc.LAND1__c = item.LAND1; ifAcc.LANDX__c = item.LANDX;
        ifAcc.ERNAM__c = item.ERNAM; ifAcc.ERDAT__c = item.ERDAT; ifAcc.KTOKD__c = item.KTOKD;
        ifAcc.KTEXT__c = item.KTEXT; ifAcc.ANRED__c = item.ANRED; ifAcc.LOCATION__c = item.LOCATION;
        ifAcc.REGIO__c = item.REGIO; ifAcc.SORTL__c = item.SORTL; ifAcc.NAME3__c = item.NAME3;
        ifAcc.PSTLZ__c = item.PSTLZ; ifAcc.TELF1__c = item.TELF1; ifAcc.TELF2__c = item.TELF2;
        ifAcc.TELFX__c = item.TELFX; ifAcc.KNURL__c = item.KNURL; ifAcc.KATR1__c = item.KATR1;
        ifAcc.VTEXT1__c = item.VTEXT1; ifAcc.KATR2__c = item.KATR2; ifAcc.VTEXT2__c = item.VTEXT2;
        ifAcc.KATR3__c = item.KATR3; ifAcc.VTEXT3__c = item.VTEXT3; ifAcc.STCD1__c = item.STCD1;
        ifAcc.STCD2__c = item.STCD2; ifAcc.J_1KFTBUS__c = item.J_1KFTBUS; ifAcc.J_1KFTIND__c = item.J_1KFTIND;
        ifAcc.JMZAH__c = item.JMZAH; ifAcc.JMJAH__c = item.JMJAH; ifAcc.BZTXT__c = item.BZTXT;
        ifAcc.BEZEI__c = item.BEZEI; ifAcc.KTONR__c = item.KTONR; ifAcc.NAME2__c = item.NAME2;
        ifAcc.VTEXT4__c = item.VTEXT4; ifAcc.VTEXT5__c = item.VTEXT5; ifAcc.VTEXT6__c = item.VTEXT6;
        ifAcc.VTEXT7__c = item.VTEXT7; ifAcc.MDLNM__c = item.MDLNM; ifAcc.MATNR__c = item.MATNR;
        ifAcc.MAKTX__c = item.MAKTX; ifAcc.MEINS__c = item.MEINS; ifAcc.ADRNR__c = item.ADRNR;
        ifAcc.FLAG__c = item.FLAG; ifAcc.STCD4__c = item.STCD4; ifAcc.SATNR__c = item.SATNR;
        ifAcc.J_1KFREPRE__c = item.J_1KFREPRE; ifAcc.VBELN__c = item.VBELN; ifAcc.WADAT_IST__c = item.WADAT_IST;
        ifAcc.VRKME__c = item.VRKME; ifAcc.LFIMG__c = item.LFIMG; ifAcc.TOTAL_LFIMG__c = item.TOTAL_LFIMG;
        ifAcc.ZSEXTEN__c = item.ZSEXTEN; ifAcc.ZMESSAGE__c = item.ZMESSAGE; ifAcc.STCD3__c = item.STCD3;
        ifAcc.KONZS__c = item.KONZS; ifAcc.NAME_GR__c = item.NAME_GR; ifAcc.KATR10__c = item.KATR10;
        ifAcc.VTEXT10__c = item.VTEXT10; ifAcc.KATR20__c = item.KATR20; ifAcc.VTEXT20__c = item.VTEXT20;
        ifAcc.KATR30__c = item.KATR30; ifAcc.VTEXT30__c = item.VTEXT30; ifAcc.GKAM_M__c = item.GKAM_M;
        ifAcc.ZTURNOVER__c = item.ZTURNOVER; ifAcc.ZEMPL__c = item.ZEMPL; ifAcc.ZPRESI__c = item.ZPRESI;
        ifAcc.ZYEAR__c = item.ZYEAR; ifAcc.ZHEADQ__c = item.ZHEADQ; ifAcc.ZVOL__c = item.ZVOL;
        ifAcc.ZPROD__c = item.ZPROD; ifAcc.ZBUYER__c = item.ZBUYER; ifAcc.ZWEBPAGE__c = item.ZWEBPAGE;

        ifAcc.REGIO_T__c = item.REGIO_T; ifAcc.SMTP_ADDR__c = item.SMTP_ADDR; ifAcc.SORT1__c = item.SORT1;
        ifAcc.SORT2__c = item.SORT2; ifAcc.LZONE__c = item.LZONE; ifAcc.SPRAS__c = item.SPRAS;
        ifAcc.STR_SUPPL1__c = item.STR_SUPPL1; ifAcc.STR_SUPPL2__c = item.STR_SUPPL2; ifAcc.STR_SUPPL3__c = item.STR_SUPPL3;
        ifAcc.PARVW__c = item.PARVW; ifAcc.VTEXT__c = item.VTEXT; ifAcc.KUNN2__c = item.KUNN2;
        ifAcc.KNREF__c = item.KNREF; ifAcc.DEFPA__c = item.DEFPA;

        return ifAcc;        
    }
}