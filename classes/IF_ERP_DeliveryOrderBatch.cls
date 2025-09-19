global with sharing class IF_ERP_DeliveryOrderBatch 
                    implements Database.Batchable<Object> , 
                               Database.AllowsCallouts, 
                               Database.Stateful  {

/** * field
 */
    public IF_ERP_DELIV_Classes.IF_DELIV_002_Req request{get;set;}
    public String  tableType {get;set;}
    public Integer upsertSize; 

    public class DoDto {
        public DoDto(){}
        public String VBELN, CAPITAL_NO, IF_FROM, TO, FROM_TXT, TO_TXT, AUBEL, VBELN_VA,
                      CreatedDate, LastModifiedDate, ObjectType, TDFORMAT, TDLINE,
                      ZTERM, TEXT1, T_EST_AMT, WAERK, ERDAT, BEZEI, NAME1, VDATU,
                      WADAT, WAUHR, LFDAT, LFUHR, WADAT_IST, ZZSTATUS, ZFETD, ZFETA, ZFCSHCP, ZFCARNM;
        public Boolean IsConverted;
    }
    public DoDto fromT_COND(IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_COND item) {
        DoDto dto = new DoDto(); 
        dto.VBELN      = item.VBELN;
        dto.CAPITAL_NO = item.CAPITAL_NO;
        dto.IF_FROM    = item.IF_FROM;
        dto.TO         = item.TO;
        dto.FROM_TXT   = item.FROM_TXT;
        dto.TO_TXT     = item.TO_TXT;
        dto.AUBEL      = item.AUBEL;
        dto.VBELN_VA   = item.VBELN_VA;
        dto.ObjectType = 'T_COND';
        return dto;
    }
    public DoDto fromT_HEADER(IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_HEADER item) {
        DoDto dto       = new DoDto(); 
        dto.VBELN      = item.VBELN;
        dto.ZTERM      = item.ZTERM;
        dto.TEXT1      = item.TEXT1;
        dto.T_EST_AMT  = item.T_EST_AMT;
        dto.WAERK      = item.WAERK;
        dto.ERDAT      = item.ERDAT;
        dto.BEZEI      = item.BEZEI;
        dto.NAME1      = item.NAME1;
        dto.VDATU      = item.VDATU;
        dto.ObjectType = 'T_HEADER';

        return dto;
    }
    public DoDto fromT_ZCRMS0062(IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_ZCRMS0062 item) {
        DoDto dto       = new DoDto(); 
        dto.VBELN      = item.VBELN;
        dto.WADAT      = item.WADAT;
        dto.WAUHR      = item.WAUHR;
        dto.LFDAT      = item.LFDAT;
        dto.LFUHR      = item.LFUHR;
        dto.WADAT_IST  = item.WADAT_IST;
        dto.ZZSTATUS   = item.ZZSTATUS;
        dto.ZFETD      = item.ZFETD;
        dto.ZFETA      = item.ZFETA;
        dto.ZFCSHCP    = item.ZFCSHCP;
        dto.ZFCARNM    = item.ZFCARNM;
        dto.ObjectType = 'T_ZCRMS0062';
        return dto;
    }
    public DoDto fromT_NOTE(IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_NOTE item) {
        DoDto dto       = new DoDto(); 
        dto.VBELN      = item.VBELN;
        dto.TDFORMAT   = item.TDFORMAT;
        dto.TDLINE     = item.TDLINE;
        dto.ObjectType = 'T_NOTE';
        return dto;
    }
    
    

/** * constructor
 */              
    public IF_ERP_DeliveryOrderBatch(IF_ERP_DELIV_Classes.IF_DELIV_002_Req request, String tableType){
        this.request   = request;
        this.tableType = tableType;
    } 


    public Iterable<Object> start(Database.BatchableContext BC){
        
        List<IF_ERP_DeliveryOrderBatch.DoDto> sapItemList = new List<IF_ERP_DeliveryOrderBatch.DoDto>();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Res response    = new IF_ERP_DELIV().IF_DELIV_002(request);

        for( IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_COND       item: response.T_COND       ) {
            sapItemList.add(fromT_COND(item));
        }
        for( IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_ZCRMS0062  item: response.T_ZCRMS0062  ) {
            sapItemList.add(fromT_ZCRMS0062(item));
        }
        for( IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_HEADER     item: response.T_HEADER     ) {
            sapItemList.add(fromT_HEADER(item));
        }
        for( IF_ERP_DELIV_Classes.IF_DELIV_002_Res_T_NOTE       item: response.T_NOTE       ) {
            sapItemList.add(fromT_NOTE(item));
        }                        
        return sapItemList;    
    }

    public void execute(Database.BatchableContext BC, List<Object> scope){
        List<IF_ERP_DeliveryOrderBatch.DoDto> itemList = (List<IF_ERP_DeliveryOrderBatch.DoDto>)scope;

        // RESULTS 
        Map<String,IF_DeliveryOrder__c> condsResults       = new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c> zcrms0062Results   = new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c> headersResults     = new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c> notesResults       = new Map<String,IF_DeliveryOrder__c>();


        // FIND FROM SFDC WITH KEY
        Map<String,IF_DeliveryOrder__c> condsfindMap       = findCondMap()              ;
        Map<String,IF_DeliveryOrder__c> zcrms0062findMap   = findDoMap('T_ZCRMS0062')   ;
        Map<String,IF_DeliveryOrder__c> headersfindMap     = findDoMap('T_HEADER')      ;
        Map<String,IF_DeliveryOrder__c> notesfindMap       = findDoMap('T_NOTE')        ;   

        // CONVERT IF_DeliveryOrder         
        for(IF_ERP_DeliveryOrderBatch.DoDto item : itemList){
            String              key     = ''      ;
            IF_DeliveryOrder__c ifObj             ;

            if( item.ObjectType.equals('T_COND') ){             // ## T_COND
                
                key = 'T_COND_'+item.VBELN+'_'+item.AUBEL;
                if( condsfindMap.containskey(key) ) { ifObj = condsfindMap.get(key); }
                
                ifObj = assignCOND(item,ifObj);
                if( !ifObj.IsConverted__c )         { condsResults.put(key,ifObj); }

            }
            else if( item.ObjectType.equals('T_ZCRMS0062') ){   // ## T_ZCRMS0062

                key = 'T_ZCRMS0062_'+item.VBELN;
                if( zcrms0062findMap.containskey(key) ) { ifObj = zcrms0062findMap.get(key); }

                ifObj = assignZCRMS0062(item,ifObj);
                if( !ifObj.IsConverted__c )             { zcrms0062Results.put(key,ifObj); }

            }
            else if( item.ObjectType.equals('T_HEADER') ){      // ## T_HEADER 
                key = 'T_HEADER_'+item.VBELN;
                if( headersfindMap.containskey(key) )   { ifObj = headersfindMap.get(key);  }      
                
                ifObj = assignHEADER(item,ifObj);
                if( !ifObj.IsConverted__c )             { headersResults.put(key,ifObj); }                

            }
            else{                                               // ##  T_NOTE
                key = 'T_NOTE_'+item.VBELN;
                if( notesfindMap.containskey(key) )     { ifObj = notesfindMap.get(key);    }

                ifObj = assignNOTE(item,ifObj);
                if( !ifObj.IsConverted__c )             { notesResults.put(key,ifObj); }                
                
            }                        
        }


        // UPSERT
        if( condsResults.size()      > 0){
            System.debug('COND upsert tlist : '+condsResults.size()); 

            List<Database.UpsertResult> upsertIfObj = Database.upsert(condsResults.values(),  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('DO Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
            }
        }
        if( zcrms0062Results.size()  > 0){
            System.debug('ZCRMS0062 upsert tlist : '+zcrms0062Results.size()); 

            List<Database.UpsertResult> upsertIfObj = Database.upsert(zcrms0062Results.values(),  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('DO Upsert ERROR  :::  ' + ur.getId() + ' / ' + ur.getErrors()); }
            }
        }
        if( headersResults.size()    > 0){
            System.debug('T_HEADER upsert tlist : '+headersResults.size()); 

            List<Database.UpsertResult> upsertIfObj = Database.upsert(headersResults.values(),  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('DO Upsert ERROR  :::  ' + ur.getId() + ' / ' + ur.getErrors()); }
            }
        }
        if( notesResults.size()      > 0){
            System.debug('T_NOTE upsert tlist : '+notesResults.size()); 

            List<Database.UpsertResult> upsertIfObj = Database.upsert(notesResults.values(),  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('DO Upsert ERROR  :::  ' + ur.getId() + ' / ' + ur.getErrors()); }
            }
        }                
    }

    public void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()) DataBase.executeBatch( new IF_ERP_DeliveryOrderConvertBatch(), 50 );
        System.debug(' ----- IMPORT FROM DELIVERY SUCCESS ----- ');
    }

    public IF_DeliveryOrder__c assignCOND(IF_ERP_DeliveryOrderBatch.DoDto item,IF_DeliveryOrder__c ifObj){
        if( ifObj != null ){
            if( ifObj.AUBEL__c != item.AUBEL  || ifObj.CAPITAL_NO__c  != item.CAPITAL_NO || ifObj.TO__c != item.TO ){
                ifObj.VBELN__c       = item.VBELN; ifObj.AUBEL__c       = item.AUBEL;
                ifObj.TO__c          = item.TO   ; ifObj.CAPITAL_NO__c  = item.CAPITAL_NO;
                ifObj.VBELN_VA__c    = item.VBELN_VA    ;
                ifObj.IsConverted__c = false;                
            }
        }
        else{
            ifObj = new IF_DeliveryOrder__c();
            ifObj.ObjectType__c  = 'T_COND'         ;   ifObj.VBELN__c       = item.VBELN       ;
            ifObj.CAPITAL_NO__c  = item.CAPITAL_NO  ;   ifObj.IF_FROM__c     = item.IF_FROM     ;
            ifObj.TO__c          = item.TO          ;   ifObj.FROM_TXT__c    = item.FROM_TXT    ;
            ifObj.TO_TXT__c      = item.TO_TXT      ;   ifObj.AUBEL__c       = item.AUBEL       ;
            ifObj.VBELN_VA__c    = item.VBELN_VA    ;   ifObj.IsConverted__c = false            ;
        }
        return ifObj;
    }

    public IF_DeliveryOrder__c assignZCRMS0062(IF_ERP_DeliveryOrderBatch.DoDto item,IF_DeliveryOrder__c ifObj){
        if( ifObj != null ){
            if( ifObj.WAUHR__c != item.WAUHR || ifObj.WADAT__c   != item.WADAT   || ifObj.LFUHR__c   != item.LFUHR   || ifObj.LFDAT__c    != item.LFDAT ||    ifObj.WADAT_IST__c   != item.WADAT_IST || ifObj.ZFETD__c != item.ZFETD 
             || ifObj.ZFETA__c != item.ZFETA || ifObj.ZFCARNM__c != item.ZFCARNM || ifObj.ZFCSHCP__c != item.ZFCSHCP || ifObj.ZZSTATUS__c != item.ZZSTATUS){
                ifObj.WAUHR__c  = item.WAUHR ;  ifObj.WADAT__c    = item.WADAT   ;  ifObj.LFUHR__c    = item.LFUHR    ; ifObj.LFDAT__c     = item.LFDAT;      ifObj.WADAT_IST__c    = item.WADAT_IST   ;ifObj.ZFETD__c  = item.ZFETD   ;
                ifObj.ZFETA__c  = item.ZFETA ;  ifObj.ZFCARNM__c  = item.ZFCARNM ;  ifObj.ZFCSHCP__c  = item.ZFCSHCP  ; ifObj.ZZSTATUS__c  = item.ZZSTATUS  ; ifObj.IsConverted__c  = false;      
            }      
        }
        else{
            ifObj = new IF_DeliveryOrder__c();                        
            ifObj.ObjectType__c  = 'T_ZCRMS0062'    ;ifObj.VBELN__c         = item.VBELN    ;
            ifObj.WADAT__c       = item.WADAT       ;ifObj.WAUHR__c         = item.WAUHR    ;
            ifObj.LFDAT__c       = item.LFDAT       ;ifObj.LFUHR__c         = item.LFUHR    ;
            ifObj.WADAT_IST__c   = item.WADAT_IST   ;ifObj.ZZSTATUS__c      = item.ZZSTATUS ;
            ifObj.ZFETD__c       = item.ZFETD       ;ifObj.ZFETA__c         = item.ZFETA    ;
            ifObj.ZFCSHCP__c     = item.ZFCSHCP     ;ifObj.ZFCARNM__c       = item.ZFCARNM  ;
            ifObj.IsConverted__c = false;
        }
        return ifObj;
    }

    public IF_DeliveryOrder__c assignHEADER(IF_ERP_DeliveryOrderBatch.DoDto item,IF_DeliveryOrder__c ifObj){
        if( ifObj != null ){
            if( ifObj.WAERK__c       != item.WAERK ){
                ifObj.WAERK__c        = item.WAERK     ;
                ifObj.IsConverted__c = false;    
            }
        }
        else{
            ifObj = new IF_DeliveryOrder__c();
            ifObj.ObjectType__c  = 'T_HEADER'   ;   
            ifObj.VBELN__c     = item.VBELN     ;
            ifObj.ZTERM__c     = item.ZTERM     ;
            ifObj.TEXT1__c     = item.TEXT1     ;
            ifObj.T_EST_AMT__c = item.T_EST_AMT ;
            ifObj.WAERK__c     = item.WAERK     ;
            ifObj.ERDAT__c     = item.ERDAT     ;
            ifObj.BEZEI__c     = item.BEZEI     ;
            ifObj.NAME1__c     = item.NAME1     ;
            ifObj.VDATU__c     = item.VDATU     ;
            ifObj.IsConverted__c = false;
        }
        return ifObj;        
    }

    public IF_DeliveryOrder__c assignNOTE(IF_ERP_DeliveryOrderBatch.DoDto item,IF_DeliveryOrder__c ifObj){
        if( ifObj != null ){
            if( ifObj.TDLINE__c     != item.TDLINE ){
                ifObj.TDLINE__c      = item.TDLINE ;
                ifObj.IsConverted__c = false       ;
            }
        }
        else{
            ifObj = new IF_DeliveryOrder__c();
            ifObj.ObjectType__c  = 'T_NOTE'         ;
            ifObj.VBELN__c       = item.VBELN       ;
            ifObj.TDFORMAT__c    = item.TDFORMAT    ;
            ifObj.TDLINE__c      = item.TDLINE      ;
            ifObj.IsConverted__c = false            ;
        }
        return ifObj;        
    }    

    public Map<String,IF_DeliveryOrder__c> findCondMap(){
        Map<String,IF_DeliveryOrder__c> ifDoMap = new  Map<String,IF_DeliveryOrder__c>();
        for(IF_DeliveryOrder__c item : [
            SELECT 
                VBELN__c, CAPITAL_NO__c, IF_FROM__c, TO__c,
                FROM_TXT__c, TO_TXT__c, AUBEL__c, VBELN_VA__c,
                CreatedDate, LastModifiedDate, IsConverted__c,  ObjectType__c
            FROM IF_DeliveryOrder__c
            WHERE ObjectType__c = 'T_COND'
            AND (CreatedDate = TODAY OR LastModifiedDate = TODAY)
        ]){
            ifDoMap.put(item.ObjectType__c+'_'+item.VBELN__c+'_'+item.AUBEL__c,item);
        }
        return ifDoMap;
    }
    public Map<String,IF_DeliveryOrder__c> findDoMap(String tableType){
        Map<String,IF_DeliveryOrder__c> ifDoMap = new  Map<String,IF_DeliveryOrder__c>();
        for(IF_DeliveryOrder__c item : [
            SELECT 
                VBELN__c, 
                TDFORMAT__c,TDLINE__c, // T_NOTE
                ZTERM__c,TEXT1__c,T_EST_AMT__c,WAERK__c,ERDAT__c,BEZEI__c,NAME1__c,VDATU__c, // toHeader
                WADAT__c,WAUHR__c,LFDAT__c,LFUHR__c,WADAT_IST__c,ZZSTATUS__c, // toZCRMS0062
                ZFETD__c,ZFETA__c,ZFCSHCP__c,ZFCARNM__c, // toZCRMS0062
                CreatedDate, LastModifiedDate, IsConverted__c, ObjectType__c
            FROM IF_DeliveryOrder__c
            WHERE ObjectType__c =:tableType
            AND (CreatedDate = TODAY OR LastModifiedDate = TODAY)
        ]){
            ifDoMap.put(tableType+'_'+item.VBELN__c,item);
        }
        return ifDoMap;
    }
}