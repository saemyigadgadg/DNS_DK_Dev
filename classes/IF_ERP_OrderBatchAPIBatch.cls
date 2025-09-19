public with sharing class IF_ERP_OrderBatchAPIBatch implements Database.Batchable<Object> ,
                    Database.AllowsCallouts, 
                    Database.Stateful {
    public Integer upsertSize = 0;
    /**
     * Constructor        
        */
        public IF_ERP_OrderBatchAPIBatch() {
        }         

        private String auart;
        
        public IF_ERP_Order_Classes.IF_ORDER_002_Res response;

        public class NotExistTableException  extends Exception{}    
    /**
     * Batch Start
        */
        public Iterable<Object> start(Database.BatchableContext BC){

            List<IF_ERP_OrderBatchAPIBatch.OrderDTO> itemList = new List<IF_ERP_OrderBatchAPIBatch.OrderDTO>();

            for(IF_ERP_Order_Classes.IF_ORDER_002_Res_T_LIST item : this.response.T_LIST){
                itemList.add(convertFromT_LIST(item));
            }

            for(IF_ERP_Order_Classes.IF_ORDER_002_Res_T_INCENTIVE item : this.response.T_INCENTIVE){
                itemList.add(convertFromT_INCENTIVE(item));
            }            
            return itemList;
        }

    /**
     * Batch execute
        */        
        public void execute(Database.BatchableContext BC, List<Object> scope){
            
            List<IF_ERP_OrderBatchAPIBatch.OrderDTO> itemList     = (List<IF_ERP_OrderBatchAPIBatch.OrderDTO>)scope;
            Set<String>                      tlists       = new Set<String>();
            Set<String>                      tincentive   = new Set<String>();

            for(IF_ERP_OrderBatchAPIBatch.OrderDTO item: itemList){
                if( item.TABLE_NAME == 'T_LIST' ){     tlists.add(item.VBELN); }
                else                             { tincentive.add(item.VBELN); }
            }
    
            Map<String,IF_Order__c> tlistResults      = new Map<String,IF_Order__c>();
            Map<String,IF_Order__c> tincentiveResults = new Map<String,IF_Order__c>();
            Map<String,IF_Order__c> tlistMap      = findIFOrder(tlists,'T_LIST');
            Map<String,IF_Order__c> tincentiveMap = findIFOrder(tlists,'T_INCENTIVE');


            for(IF_ERP_OrderBatchAPIBatch.OrderDTO item: itemList){

                
                String      key = item.auart +'_' + item.VBELN + '_' + item.POSNR;
                
                IF_Order__c ord = null;  
                System.debug('key : '+key);
                System.debug(' TABLE NAME : '+item.TABLE_NAME);
                if( item.TABLE_NAME == 'T_LIST'){
                    if( tlistMap.containsKey(key) ) {
                        // order 가 존재함  
                        System.debug('-- T_LIST 에 존재함 --');
                        ord = tlistMap.get(key);
                        System.debug('ord.VBELN__c : '+ord.VBELN__c);
                    }
                    ord = assignOrderList(item,ord); 
                    
                    if ( !ord.IsConverted__c){
                        System.debug('ord.TABLE_NAME__c : '+ord.TABLE_NAME__c);
                        tlistResults.put(key,ord);
                    }
                }   
                else if( item.TABLE_NAME == 'T_INCENTIVE'){
                    if( !tincentiveMap.containsKey(key) ) { 
                        // order 가 존재하지 않음 
                        ord = assignOrderIncentive(item,ord);
                        tincentiveResults.put(key,ord);
                    }
                }
            }

            if(tlistResults.size() > 0){
                this.upsertSize += tlistResults.size();
                System.debug('upsert tlist : '+tlistResults.size()); 
                List<Database.UpsertResult> upsertIfObj = Database.upsert(tlistResults.values(),  false);
                for(Database.UpsertResult ur : upsertIfObj) {
                    if(!ur.isSuccess()) { System.debug('IF ACCOUNT Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
                }
            }
            if(tincentiveMap.size() > 0){
                System.debug('upsert tlist : '+tincentiveMap.size());
                List<Database.UpsertResult> upsertIfObj = Database.upsert(tincentiveMap.values(),  false);
                for(Database.UpsertResult ur : upsertIfObj) {
                    if(!ur.isSuccess()) { System.debug('IF ACCOUNT Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
                }
            }            
        }

    /**
     * Batch finish
        */            
    public void finish(Database.BatchableContext BC){
        System.debug('IF_ERP_OrderBatchAPIBatch - finish ::: ' + this.upsertSize);
        // if(!Test.isRunningTest() && this.upsertSize>0) DataBase.executeBatch( new DN_OrderERPToCRMBatch(), 50 );
    }
    
    public Map<String,IF_Order__c>  findIFOrder(Set<String> vbelns,String tableName){
        System.debug('tableNm in findIFOrder : '+tableName);
        Map<String,IF_Order__c> sfdcIfOrderMap = new Map<String,IF_Order__c>(); 

        for(IF_Order__c sfdcIfOrder :[
            SELECT TABLE_NAME__c, VBELN__c, AUART__c, BSTDK__c, BSTKD__c, ERDAT__c, ERNAM__c, MODEL__c, 
                    MATNR__c, WAERK__c, TOTAL_AMT__c, NETWR_AMT__c, TAX_AMT__c, DISC_AMT__c, 
                    SURC_AMT__c, VSART__c, ZTERM__c, VDATU__c, KUNNR_AG__c, KUNNR_RE__c, KUNNR_RG__c,
                   KUNNR_WE__c, KUNNR_ZM__c, CONFIRM__c, CHANGE__c, ZZSTATUS__c, ZSDFUNC__c, WRBTR__c, KNUMV__c, 
                   ABGRU__c, VSBED__c, VKORG__c, VTWEG__c, SPART__c, MAKTX__c, SUBSEQUENCE__c, POSNR__c, SERNR__c, MTART__c,
                   FKDAT__c, MBDAT__c, DLVCR__c, APPDATE__c, BMENG__c, VRKME__c, ADEPDT__c, AUGRU__c, WADAT_IST__c, ZZSO_SORT__c, 
                   VBELN_D__c, ERDAT_D__c, OALIAS__c, G_OALIAS__c, IHREZ__c, VSTEL__c, EDATU__c, FKSTK__c, CARNO__c, VKBUR__c,
                   PERIOD__c, KBETR__c, WAERS__c, KUNNR__c, KUNNR_ZI__c, VBELN_I__c, VBELN_Q__c, ARKTX__c, ZDELFLAG__c, ZRETURNS__c, 
                   LIFSK__c, ZZAPPNO__c, ZZSOCHAN__c,
                   INCO1__c, INCO2__c, KVGR1__c, KVGR2__c, KVGR3__c, PLTYP__c, BZIRK__c, IsConverted__c 
            FROM IF_Order__c
            WHERE 
            TABLE_NAME__c =: tableName
            AND VBELN__c IN: vbelns
            AND (CreatedDate = Today OR LastModifiedDate = Today)
        ]){
            String key = sfdcIfOrder.AUART__c+'_'+sfdcIfOrder.VBELN__c+'_'+sfdcIfOrder.POSNR__c;
            sfdcIfOrderMap.put(key,sfdcIfOrder);
        }
        return sfdcIfOrderMap;
    }
    public class OrderDTO {
        public OrderDTO(){}
        public String TABLE_NAME, VBELN, AUART, BSTDK, BSTKD, ERDAT;
        public String ERNAM, MODEL, MATNR, WAERK, ZTERM, VDATU;
        public String KUNNR_AG, KUNNR_RE, KUNNR_RG, KUNNR_WE, KUNNR_ZM, CONFIRM;
        public String CHANGE, ZZSTATUS, ZSDFUNC, KNUMV, BUKRS_VF, ABGRU;
        public String VSBED, VKORG, VTWEG, SPART, MAKTX, SUBSEQUENCE;
        public String POSNR, SERNR, MTART, FKDAT, MBDAT, DLVCR;
        public String APPDATE, VRKME, ADEPDT, AUGRU, WADAT_IST, ZZSO_SORT;
        public String VBELN_D, ERDAT_D, OALIAS, G_OALIAS, IHREZ, VSTEL;
        public String EDATU, FKSTK, CARNO, VKBUR, KUNNR_ZI, VBELN_I,VSART;
        public String VBELN_Q, ARKTX, ZDELFLAG, ZRETURNS, INCO1, INCO2;
        public String KVGR1, KVGR2, KVGR3, PLTYP, BZIRK, PERIOD, WAERS;
    
        public String TOTAL_AMT, NETWR_AMT, TAX_AMT, DISC_AMT, SURC_AMT, WRBTR;
        public String BMENG, KBETR;
        public String LIFSK, ZZAPPNO,ZZSOCHAN;
    }
    public OrderDTO convertFromT_LIST(IF_ERP_Order_Classes.IF_ORDER_002_Res_T_LIST sapItem){
        OrderDTO item = new OrderDTO();
            item.TABLE_NAME     = 'T_LIST';                
            System.debug('sapItem.VBELN : '+sapItem.VBELN);
            item.AUART = this.auart == 'ZRE' ? 'ZRE' : sapItem.AUART;
            item.VBELN = sapItem.VBELN; item.AUART = sapItem.AUART; item.BSTDK = sapItem.BSTDK;
            item.BSTKD = sapItem.BSTKD; item.ERDAT = sapItem.ERDAT; item.ERNAM = sapItem.ERNAM; item.MODEL = sapItem.MODEL;
            item.MATNR = sapItem.MATNR; item.WAERK = sapItem.WAERK; item.ZTERM = sapItem.ZTERM; item.VDATU = sapItem.VDATU;
            item.KUNNR_AG = sapItem.KUNNR_AG; item.KUNNR_RE = sapItem.KUNNR_RE; item.KUNNR_RG = sapItem.KUNNR_RG; item.KUNNR_WE = sapItem.KUNNR_WE;
            item.KUNNR_ZM = sapItem.KUNNR_ZM; item.CONFIRM = sapItem.CONFIRM; item.CHANGE = sapItem.CHANGE; item.ZZSTATUS = sapItem.ZZSTATUS;
            item.ZSDFUNC = sapItem.ZSDFUNC; item.KNUMV = sapItem.KNUMV; item.BUKRS_VF = sapItem.BUKRS_VF; item.ABGRU = sapItem.ABGRU;
            item.VSBED = sapItem.VSBED; item.VKORG = sapItem.VKORG; item.VTWEG = sapItem.VTWEG; item.SPART = sapItem.SPART;
            item.MAKTX = sapItem.MAKTX; item.SUBSEQUENCE = sapItem.SUBSEQUENCE; item.POSNR = sapItem.POSNR; item.SERNR = sapItem.SERNR;
            item.MTART = sapItem.MTART; item.FKDAT = sapItem.FKDAT; item.MBDAT = sapItem.MBDAT; item.DLVCR = sapItem.DLVCR;
            item.APPDATE = sapItem.APPDATE; item.VRKME = sapItem.VRKME; item.ADEPDT = sapItem.ADEPDT; item.AUGRU = sapItem.AUGRU;
            item.WADAT_IST = sapItem.WADAT_IST; item.ZZSO_SORT = sapItem.ZZSO_SORT; item.VBELN_D = sapItem.VBELN_D; item.ERDAT_D = sapItem.ERDAT_D;
            item.OALIAS = sapItem.OALIAS; item.G_OALIAS = sapItem.G_OALIAS; item.IHREZ = sapItem.IHREZ; item.VSTEL = sapItem.VSTEL;
            item.EDATU = sapItem.EDATU; item.FKSTK = sapItem.FKSTK; item.CARNO = sapItem.CARNO; item.VKBUR = sapItem.VKBUR;
            item.KUNNR_ZI = sapItem.KUNNR_ZI; item.VBELN_I = sapItem.VBELN_I; item.VBELN_Q = sapItem.VBELN_Q; item.ARKTX = sapItem.ARKTX;
            item.ZDELFLAG = sapItem.ZDELFLAG; item.ZRETURNS = sapItem.ZRETURNS; item.INCO1 = sapItem.INCO1; item.INCO2 = sapItem.INCO2;
            item.KVGR1 = sapItem.KVGR1; item.KVGR2 = sapItem.KVGR2; item.KVGR3 = sapItem.KVGR3; item.PLTYP = sapItem.PLTYP;
            item.BZIRK = sapItem.BZIRK; item.TOTAL_AMT = sapItem.TOTAL_AMT; item.NETWR_AMT = sapItem.NETWR_AMT; item.TAX_AMT = sapItem.TAX_AMT;
            item.DISC_AMT = sapItem.DISC_AMT; item.SURC_AMT = sapItem.SURC_AMT; item.WRBTR = sapItem.WRBTR; item.BMENG = sapItem.BMENG;
            item.LIFSK    = sapItem.LIFSK;
            item.ZZAPPNO  = sapItem.ZZAPPNO;
            item.ZZSOCHAN = sapItem.ZZSOCHAN;
            return item;      
    }    
    public OrderDTO convertFromT_INCENTIVE(IF_ERP_Order_Classes.IF_ORDER_002_Res_T_INCENTIVE sapItem){
        OrderDTO item = new OrderDTO();
            item.TABLE_NAME     = 'T_INCENTIVE';
            item.VBELN          = sapItem.VBELN;
            item.PERIOD         = sapItem.PERIOD;
            item.KBETR          = sapItem.KBETR;
            item.WAERS          = sapItem.WAERS;
        return item;
    }
    public IF_Order__c              assignOrderList(IF_ERP_OrderBatchAPIBatch.OrderDTO  titem, IF_Order__c ifOrder){
        // Already Exist 
        if( ifOrder != null ){
            ifOrder.TABLE_NAME__c = 'T_LIST';
            System.debug(' ----- T_LIST EXIST -----');
            System.debug(' ----- assignOrderList - titem.VBELN ----- : '+titem.VBELN);
            System.debug(' ----- assignOrderList - ifOrder.VBELN__c ----- : '+ifOrder.VBELN__c);
            return changeOrder(titem,ifOrder);
        }else{
            ifOrder = new IF_Order__c();
            ifOrder.TABLE_NAME__c = 'T_LIST'; 
            ifOrder.VBELN__c = titem.VBELN;
            ifOrder.AUART__c = titem.AUART;
            ifOrder.BSTDK__c = titem.BSTDK;
            ifOrder.BSTKD__c = titem.BSTKD;
            ifOrder.ERDAT__c = titem.ERDAT;
            ifOrder.ERNAM__c = titem.ERNAM;
            ifOrder.MODEL__c = titem.MODEL;
            ifOrder.MATNR__c = titem.MATNR;
            ifOrder.WAERK__c = titem.WAERK;
            ifOrder.TOTAL_AMT__c = titem.TOTAL_AMT;
            ifOrder.NETWR_AMT__c = titem.NETWR_AMT;
            ifOrder.TAX_AMT__c = titem.TAX_AMT;
            ifOrder.DISC_AMT__c = titem.DISC_AMT;
            ifOrder.SURC_AMT__c = titem.SURC_AMT;
            ifOrder.VSART__c = titem.VSART;
            ifOrder.ZTERM__c = titem.ZTERM;
            ifOrder.VDATU__c = titem.VDATU;
            ifOrder.KUNNR_AG__c = titem.KUNNR_AG;
            ifOrder.KUNNR_RE__c = titem.KUNNR_RE;
            ifOrder.KUNNR_RG__c = titem.KUNNR_RG;
            ifOrder.KUNNR_WE__c = titem.KUNNR_WE;
            ifOrder.KUNNR_ZM__c = titem.KUNNR_ZM;
            ifOrder.CONFIRM__c = titem.CONFIRM;
            ifOrder.CHANGE__c = titem.CHANGE;
            ifOrder.ZZSTATUS__c = titem.ZZSTATUS;
            ifOrder.ZSDFUNC__c = titem.ZSDFUNC;
            ifOrder.WRBTR__c = titem.WRBTR;
            ifOrder.KNUMV__c = titem.KNUMV;
            ifOrder.BUKRS_VF__c = titem.BUKRS_VF;
            ifOrder.ABGRU__c = titem.ABGRU;
            ifOrder.VSBED__c = titem.VSBED;
            ifOrder.VKORG__c = titem.VKORG;
            ifOrder.VTWEG__c = titem.VTWEG;
            ifOrder.SPART__c = titem.SPART;
            ifOrder.MAKTX__c = titem.MAKTX;
            ifOrder.SUBSEQUENCE__c = titem.SUBSEQUENCE;
            ifOrder.POSNR__c = titem.POSNR;
            ifOrder.SERNR__c = titem.SERNR;
            ifOrder.MTART__c = titem.MTART;
            ifOrder.FKDAT__c = titem.FKDAT;
            ifOrder.MBDAT__c = titem.MBDAT;
            ifOrder.DLVCR__c = titem.DLVCR;
            ifOrder.APPDATE__c = titem.APPDATE;
            ifOrder.BMENG__c = titem.BMENG;
            ifOrder.VRKME__c = titem.VRKME;
            ifOrder.ADEPDT__c = titem.ADEPDT;
            ifOrder.AUGRU__c = titem.AUGRU;
            ifOrder.WADAT_IST__c = titem.WADAT_IST;
            ifOrder.ZZSO_SORT__c = titem.ZZSO_SORT;
            ifOrder.VBELN_D__c = titem.VBELN_D;
            ifOrder.ERDAT_D__c = titem.ERDAT_D;
            ifOrder.OALIAS__c = titem.OALIAS;
            ifOrder.G_OALIAS__c = titem.G_OALIAS;
            ifOrder.IHREZ__c     = titem.IHREZ;      // 귀사의 주문번호
            ifOrder.VSTEL__c     = titem.VSTEL;      // 출고지점
            ifOrder.EDATU__c     = titem.EDATU;      // 납품요청일
            ifOrder.FKSTK__c     = titem.FKSTK;      // 송장 상태
            ifOrder.CARNO__c     = titem.CARNO;      // 차량 번호
            ifOrder.VKBUR__c     = titem.VKBUR;      // 영업 사무소
            ifOrder.KUNNR_ZI__c  = titem.KUNNR_ZI;   // 납품처 고객 번호
            ifOrder.VBELN_I__c   = titem.VBELN_I;    // 참조 송장 번호
            ifOrder.VBELN_Q__c   = titem.VBELN_Q;    // 견적서 번호
            ifOrder.ARKTX__c     = titem.ARKTX;      // 품목 텍스트
            ifOrder.ZDELFLAG__c  = titem.ZDELFLAG;   // 삭제 플래그
            ifOrder.ZRETURNS__c  = titem.ZRETURNS;   // 반품 여부
            ifOrder.INCO1__c     = titem.INCO1;      // 인코텀스 조건 (주요조건)
            ifOrder.INCO2__c     = titem.INCO2;      // 인코텀스 상세조건
            ifOrder.KVGR1__c     = titem.KVGR1;      // 고객 그룹1
            ifOrder.KVGR2__c     = titem.KVGR2;      // 고객 그룹2
            ifOrder.KVGR3__c     = titem.KVGR3;      // 고객 그룹3
            ifOrder.PLTYP__c     = titem.PLTYP;      // 가격리스트 유형
            ifOrder.BZIRK__c     = titem.BZIRK;      // 영업구역  
            ifOrder.LIFSK__c     = titem.LIFSK;  
            ifOrder.ZZAPPNO__c   = titem.ZZAPPNO;
            ifOrder.LIFSK__c     = titem.LIFSK;
            ifOrder.ZZAPPNO__c   = titem.ZZAPPNO;
            ifOrder.ZZSOCHAN__c  = titem.ZZSOCHAN;
            return ifOrder;        
        }
    }
    public IF_Order__c              assignOrderIncentive(IF_ERP_OrderBatchAPIBatch.OrderDTO titem, IF_Order__c ifOrder){
        System.debug(' ----- T_INCENTIVE EXIST -----');
        ifOrder.TABLE_NAME__c = 'T_INCENTIVE';
        ifOrder.VBELN__c  = titem.VBELN;
        ifOrder.PERIOD__c = titem.PERIOD;
        ifOrder.KBETR__c  = titem.KBETR;
        ifOrder.WAERS__c  = titem.WAERS; 
        return ifOrder;
    }
    public IF_Order__c              changeOrder(IF_ERP_OrderBatchAPIBatch.OrderDTO t, IF_Order__c o) {
        Boolean c = false;
        System.debug('changeOrder VBELN t.VBELN'+t.VBELN);
        System.debug('changeOrder VBELN o.VBELN__c'+o.VBELN__c);
        if (notEqual(o.MATNR__c     , t.MATNR))           { o.MATNR__c     = t.MATNR;        c = true; }
        if (notEqual(o.LIFSK__c     , t.LIFSK))           { o.LIFSK__c     = t.LIFSK;        c = true; }
        if (notEqual(o.ZZAPPNO__c   , t.ZZAPPNO))         { o.ZZAPPNO__c   = t.ZZAPPNO;      c = true; }
        if (notEqual(o.ZZSOCHAN__c   , t.ZZSOCHAN))       { o.ZZSOCHAN__c  = t.ZZSOCHAN;     c = true; }
        if (notEqual(o.ZTERM__c     , t.ZTERM))           { o.ZTERM__c     = t.ZTERM;        c = true; }if (notEqual(o.VDATU__c     , t.VDATU))           { o.VDATU__c     = t.VDATU;        c = true; }if (notEqual(o.KUNNR_WE__c  , t.KUNNR_WE))        { o.KUNNR_WE__c  = t.KUNNR_WE;     c = true; }if (notEqual(o.ZZSTATUS__c  , t.ZZSTATUS))        { o.ZZSTATUS__c  = t.ZZSTATUS;     c = true; }if (notEqual(o.ABGRU__c     , t.ABGRU))           { o.ABGRU__c     = t.ABGRU;        c = true; }if (notEqual(o.SERNR__c     , t.SERNR))           { o.SERNR__c     = t.SERNR;        c = true; }if (notEqual(o.WADAT_IST__c , t.WADAT_IST))       { o.WADAT_IST__c = t.WADAT_IST;    c = true; }if (notEqual(o.VBELN_D__c   , t.VBELN_D))         { o.VBELN_D__c   = t.VBELN_D;      c = true; }if (notEqual(o.IHREZ__c     , t.IHREZ))           { o.IHREZ__c     = t.IHREZ;        c = true; }if (notEqual(o.KUNNR_ZI__c  , t.KUNNR_ZI))        { o.KUNNR_ZI__c  = t.KUNNR_ZI;     c = true; }if (notEqual(o.ARKTX__c     , t.ARKTX))           { o.ARKTX__c     = t.ARKTX;        c = true; }if (notEqual(o.ZDELFLAG__c  , t.ZDELFLAG))        { o.ZDELFLAG__c  = t.ZDELFLAG;     c = true; }if (notEqual(o.ZRETURNS__c  , t.ZRETURNS))        { o.ZRETURNS__c  = t.ZRETURNS;     c = true; }if (notEqual(o.INCO1__c     , t.INCO1))           { o.INCO1__c     = t.INCO1;        c = true; }
        if (c) o.IsConverted__c = false;
    
        return o;
    }
    private Boolean                 notEqual(Object a, Object b) {
        return (a == null && b != null) || (a != null && !a.equals(b));
    }
}