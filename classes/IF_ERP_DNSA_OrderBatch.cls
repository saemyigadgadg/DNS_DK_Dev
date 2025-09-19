global with sharing class IF_ERP_DNSA_OrderBatch 
                                                implements 
                                                Database.Batchable<Object>, 
                                                Database.AllowsCallouts, 
                                                Database.Stateful  {
    
    private IF_ERP_Order_Classes.IF_ORDER_012_Req request;
    private String tableNm;

    private String  batchClassMessage;
    private Integer successCnt;
    private Integer failCnt;
    
    public IF_ERP_DNSA_OrderBatch(IF_ERP_Order_Classes.IF_ORDER_012_Req request) { this.request = request; }
    
    public Iterable<Object> start(Database.BatchableContext BC){
        IF_ERP_Order_Classes.IF_ORDER_012_Res response = new IF_ERP_Order().IF_ORDER_012(request);
    
        List<IF_ERP_DNSA_OrderBatch.DnsaOrderDto> itemList = new List<IF_ERP_DNSA_OrderBatch.DnsaOrderDto>();
    
        if(response == null){
            return itemList; 
        }

        if(response.T_ORDER != null || response.T_ORDER.size() != 0 ){
            for(IF_ERP_Order_Classes.IF_ORDER_012_Res_T_ORDER     item: response.T_ORDER ){
                itemList.add(fromT_ORDER(item));
            }
        }

        if(response.T_ZCRMS0094 != null || response.T_ZCRMS0094.size() != 0 ){
            for(IF_ERP_Order_Classes.IF_ORDER_012_Res_T_ZCRMS0094 item: response.T_ZCRMS0094 ){
                itemList.add(fromT_ZCRMS0094(item));
            }
        }
        
        
    
        return itemList;
    }
    public void execute(Database.BatchableContext BC, List<Object> scope){
        
        List<IF_ERP_DNSA_OrderBatch.DnsaOrderDto> itemList       = (List<IF_ERP_DNSA_OrderBatch.DnsaOrderDto>) scope;
        Map<String,Map<String,IF_Order__c>>       findIfOrderMap = findSfdcMap();
        Map<String,IF_Order__c>                   findT_Order    = findIfOrderMap.get('T_ORDER');
        Map<String,IF_Order__c>                   findT_ZCRM     = findIfOrderMap.get('T_ZCRM');
        Map<String,IF_Order__c>                   upsertMap      = new Map<String,IF_Order__c>();

        for(IF_ERP_DNSA_OrderBatch.DnsaOrderDto item : itemList){

            
            String      key     = '';
            IF_Order__c ifObj       ;

            // ## T_ORDER
            if( item.TABLE_NAME == 'T_ORDER' ){
                key = item.AUART+'_'+item.POSNR+'_'+item.VBELN+'_'+item.TABLE_NAME;
                if( findT_Order.containsKey(key) ) ifObj = findT_Order.get(key);
            }
            // ## T_ZCRMS0094
            else{
                key = item.PSO_NUM+'_'+item.VBELN_SO+'_'+item.TABLE_NAME;
                if( findT_ZCRM.containsKey(key) ) ifObj = findT_ZCRM.get(key);                
            }

            // ## isConverted == false ? insert to upsertMap
            ifObj = assign(item,ifObj);

            if(!ifObj.IsConverted__c) upsertMap.put(key,ifObj);
        }

        if(upsertMap.size() > 0){
            System.debug(' ----------> TOTAL UPSERT SIZE : '+upsertMap.size() );
            List<Database.UpsertResult> upsertIfObj = Database.upsert(upsertMap.values(),  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('IF ACCOUNT Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
            }
        }  
    }
    public void finish(Database.BatchableContext BC){
    }    

    private IF_Order__c assign(IF_ERP_DNSA_OrderBatch.DnsaOrderDto item, IF_Order__c ifObj){
        Map<String, String> fieldMappings = new Map<String, String>{
            'TABLE_NAME' => item.TABLE_NAME,   'AUART' => item.AUART,     'BSTDK' => item.BSTDK,     'AUART_TX' => item.AUART_TX,   'BSTKD' => item.BSTKD,
            'ERDAT' => item.ERDAT,   'VBELN' => item.VBELN,   'ERDAT_D' => item.ERDAT_D,   'GUBUN' => item.GUBUN,   'MODEL' => item.MODEL,
            'MODEL_TX' => item.MODEL_TX,   'TOTAL_AMT' => item.TOTAL_AMT,   'DISC_AMT' => item.DISC_AMT,   'SURC_AMT' => item.SURC_AMT,   'NETWR_AMT' => item.NETWR_AMT,
            'WAERK' => item.WAERK,   'VSART' => item.VSART,   'VSART_TX' => item.VSART_TX,   'ZTERM' => item.ZTERM,   'ZTERM_TX' => item.ZTERM_TX,
            'VDATU' => item.VDATU,   'KUNNR_AG' => item.KUNNR_AG,   'KUNNR_AG_TX' => item.KUNNR_AG_TX,   'KUNNR_WE' => item.KUNNR_WE,   'KUNNR_WE_TX' => item.KUNNR_WE_TX,
            'KUNNR_RE' => item.KUNNR_RE,   'KUNNR_RE_TX' => item.KUNNR_RE_TX,   'KUNNR_RG' => item.KUNNR_RG,   'KUNNR_RG_TX' => item.KUNNR_RG_TX,   'KUNNR_ZM' => item.KUNNR_ZM,
            'KUNNR_ZM_TX' => item.KUNNR_ZM_TX,   'ERNAM' => item.ERNAM,   'NAME' => item.NAME,   'APPROVAL' => item.APPROVAL,   'REJECT' => item.REJECT,
            'BUTTTON_ENABLE' => item.BUTTTON_ENABLE,   'ZZSTATUS' => item.ZZSTATUS,   'ZZSTATUS_TX' => item.ZZSTATUS_TX,   'ZSDFUNC' => item.ZSDFUNC,   'ZSDFUNC_TX' => item.ZSDFUNC_TX,
            'ABGRU' => item.ABGRU,   'ABGRU_TX' => item.ABGRU_TX,   'TAX_AMT' => item.TAX_AMT,   'SERNR' => item.SERNR,   'MAKTX' => item.MAKTX,
            'TOTAL_DC_RATE' => item.TOTAL_DC_RATE,   'FKDAT' => item.FKDAT,   'VSBED' => item.VSBED,   'VSBED_TX' => item.VSBED_TX,   'MBDAT' => item.MBDAT,
            'KUNNR_ZV' => item.KUNNR_ZV,   'KUNNR_ZV_TX' => item.KUNNR_ZV_TX,   'ICON_V' => item.ICON_V,   'BMENG' => item.BMENG,   'ADEPDT' => item.ADEPDT,
            'VRKME' => item.VRKME,   'OALIAS' => item.OALIAS,   'IHREZ' => item.IHREZ,   'VBELN_ST' => item.VBELN_ST,   'KWERT' => item.KWERT,
            'WAERS' => item.WAERS,   'KBETR' => item.KBETR,   'WAERS_DC' => item.WAERS_DC,   'KWERT_DC' => item.KWERT_DC,   'ATTACH' => item.ATTACH,
            'ZZAPPNO' => item.ZZAPPNO,   'ZZAPPNO_T' => item.ZZAPPNO_T,   'LOCATION' => item.LOCATION,   'KUNNR_Z2' => item.KUNNR_Z2,   'Z2_NAME' => item.Z2_NAME,
            'VSNMR_V' => item.VSNMR_V,   'EQUNR' => item.EQUNR,   'MDLNM' => item.MDLNM,   'EDATE' => item.EDATE,   'RDATE' => item.RDATE,
            'RTDAT' => item.RTDAT,   'STAGE' => item.STAGE,   'NOTE_ZH03' => item.NOTE_ZH03,   'EDATU' => item.EDATU,   'FKSTK' => item.FKSTK,
            'AUGRU' => item.AUGRU,   'AUGRU_T' => item.AUGRU_T,   'SERGE' => item.SERGE,   'ZSTOCKTEX' => item.ZSTOCKTEX,   'VBELN_STO' => item.VBELN_STO,
            'UPTDATE' => item.UPTDATE,   'ZPPDATE' => item.ZPPDATE,   'OPT1' => item.OPT1,   'OPT2' => item.OPT2,   'OPT3' => item.OPT3,
            'OPT4' => item.OPT4,   'OPT5' => item.OPT5,   'OPT6' => item.OPT6,   'ACDAT' => item.ACDAT,   'J_1KFREPRE' => item.J_1KFREPRE,
            'CARNO' => item.CARNO,   'AMOUNT' => item.AMOUNT,   'BAS_RATE' => item.BAS_RATE,   'ALL_RATE' => item.ALL_RATE,   'PRO_RATE' => item.PRO_RATE,
            'TOTAL_DC_AMT' => item.TOTAL_DC_AMT,   'TOTAL_DC' => item.TOTAL_DC,   'DC_AMT' => item.DC_AMT,   'ATWRT' => item.ATWRT,   'VBELN_V' => item.VBELN_V,
            'ZTRAC' => item.ZTRAC,   'POSNR' => item.POSNR,   'LIFNR' => item.LIFNR,   'NAME1' => item.NAME1,   'MATNR' => item.MATNR,
            'ETDAT' => item.ETDAT,   'PRODAT' => item.PRODAT,   'ZETADAT' => item.ZETADAT,   'VKBUR' => item.VKBUR,   'EBELN' => item.EBELN,
            'ZPORT' => item.ZPORT,   'SHP_DT' => item.SHP_DT,   'DLV_DT' => item.DLV_DT,   'MANUFACTURER' => item.MANUFACTURER,   'AEDAT' => item.AEDAT,
            'WADAT_IST' => item.WADAT_IST,   'PSO_NUM' => item.PSO_NUM,   'ZDELFLAG' => item.ZDELFLAG,   'ZRETURNS' => item.ZRETURNS,   'INCO1' => item.INCO1,
            'INCO2' => item.INCO2,   'VBELN_SO' => item.VBELN_SO,   'WAUHR' => item.WAUHR,   'LFDAT' => item.LFDAT,   'LFUHR' => item.LFUHR,
            'ZFETD' => item.ZFETD,   'ZFETA' => item.ZFETA,   'ZFCSHCP' => item.ZFCSHCP,   'ZFCARNM' => item.ZFCARNM,   'ZFPLDVLD' => item.ZFPLDVLD,
            'ZFPLDVCD' => item.ZFPLDVCD,   'ZFPLDV' => item.ZFPLDV, 
            'VKORG' => item.VKORG, 'VTWEG' => item.VTWEG, 'SPART' => item.SPART
        };
        
        if( ifObj != null){
            ifObj.IsDNSA__c = true;
            System.debug(' ----------> ALREADY EXIST');
            for(String key : fieldMappings.keySet()){
                String ifObjKey = key+'__c';
                if ( ifObj.get(ifObjKey) != fieldMappings.get(key) ){
                    ifObj.put(ifObjKey,fieldMappings.get(key));
                    ifObj.put('IsConverted__c',false);
                }  
            }
        }
        else{
            System.debug(' ----------> NEW ONE');
            ifObj = new IF_Order__c();
            ifObj.put('IsConverted__c',false);
            for(String key : fieldMappings.keySet()){
                String ifObjKey = key+'__c';
                ifObj.IsDNSA__c = true;
                ifObj.put(ifObjKey,fieldMappings.get(key));
                ifObj.put('IsConverted__c',false);
            }   
        }
        return ifObj;
    }
    private Map<String,Map<String,IF_Order__c>> findSfdcMap(){
        Map<String,IF_Order__c> findT_Order = new Map<String,IF_Order__c>();
        Map<String,IF_Order__c> findT_ZCRM  = new Map<String,IF_Order__c>();
        Map<String,Map<String,IF_Order__c>> findIFOrder = new  Map<String,Map<String,IF_Order__c>>();


        for(IF_Order__c obj :[
            SELECT 
            TABLE_NAME__c,     AUART__c,         BSTDK__c,         AUART_TX__c,
            BSTKD__c,          ERDAT__c,         VBELN__c,         ERDAT_D__c,
            GUBUN__c,          MODEL__c,         MODEL_TX__c,      TOTAL_AMT__c,
            DISC_AMT__c,       SURC_AMT__c,      NETWR_AMT__c,     WAERK__c,
            VSART__c,          VSART_TX__c,      ZTERM__c,         ZTERM_TX__c,
            VDATU__c,          KUNNR_AG__c,      KUNNR_AG_TX__c,   KUNNR_WE__c,
            KUNNR_WE_TX__c,    KUNNR_RE__c,      KUNNR_RE_TX__c,   KUNNR_RG__c,
            KUNNR_RG_TX__c,    KUNNR_ZM__c,      KUNNR_ZM_TX__c,   ERNAM__c,
            NAME__c,           APPROVAL__c,      REJECT__c,        BUTTTON_ENABLE__c,
            ZZSTATUS__c,       ZZSTATUS_TX__c,   ZSDFUNC__c,       ZSDFUNC_TX__c,
            ABGRU__c,          ABGRU_TX__c,      TAX_AMT__c,       SERNR__c,
            MAKTX__c,          TOTAL_DC_RATE__c, FKDAT__c,         VSBED__c,
            VSBED_TX__c,       MBDAT__c,         KUNNR_ZV__c,      KUNNR_ZV_TX__c,
            ICON_V__c,         BMENG__c,         ADEPDT__c,        VRKME__c,
            OALIAS__c,         IHREZ__c,         VBELN_ST__c,      KWERT__c,
            WAERS__c,          KBETR__c,         WAERS_DC__c,      KWERT_DC__c,
            ATTACH__c,         ZZAPPNO__c,       ZZAPPNO_T__c,     LOCATION__c,
            KUNNR_Z2__c,       Z2_NAME__c,       VSNMR_V__c,       EQUNR__c,
            MDLNM__c,          EDATE__c,         RDATE__c,         RTDAT__c,
            STAGE__c,          NOTE_ZH03__c,     EDATU__c,         FKSTK__c,
            AUGRU__c,          AUGRU_T__c,       SERGE__c,         ZSTOCKTEX__c,
            VBELN_STO__c,      UPTDATE__c,       ZPPDATE__c,       OPT1__c,
            OPT2__c,           OPT3__c,          OPT4__c,          OPT5__c,
            OPT6__c,           ACDAT__c,         J_1KFREPRE__c,    CARNO__c,
            AMOUNT__c,         BAS_RATE__c,      ALL_RATE__c,      PRO_RATE__c,
            TOTAL_DC_AMT__c,   TOTAL_DC__c,      DC_AMT__c,        ATWRT__c,
            VBELN_V__c,        ZTRAC__c,         POSNR__c,         LIFNR__c,
            NAME1__c,          MATNR__c,         ETDAT__c,         PRODAT__c,
            ZETADAT__c,        VKBUR__c,         EBELN__c,         ZPORT__c,
            SHP_DT__c,         DLV_DT__c,        MANUFACTURER__c,  AEDAT__c,
            WADAT_IST__c,      PSO_NUM__c,       ZDELFLAG__c,      ZRETURNS__c,
            INCO1__c,          INCO2__c,         VBELN_SO__c,      WADAT__c,
            WAUHR__c,          LFDAT__c,         LFUHR__c,         ZFETD__c,
            ZFETA__c,          ZFCSHCP__c,       ZFCARNM__c,       ZFPLDVLD__c,
            SPART__c,          VKORG__c,         VTWEG__c,
            ZFPLDVCD__c,       ZFPLDV__c,        LastModifiedDate, Id,
            IsDNSA__c,         IsConverted__c   

        FROM IF_Order__c
        WHERE LastModifiedDate = TODAY
        AND IsDNSA__c = true
        ]){
            // -> KEY AUART	POSNR	VBELN	TABLE_NAME
            if(obj.TABLE_NAME__c == 'T_Order'){
                String key = obj.AUART__c+'_'+obj.POSNR__c+'_'+obj.VBELN__c+'_'+obj.TABLE_NAME__c;
                findT_Order.put(key ,obj);
            }
            else{
                String key = obj.PSO_NUM__c+'_'+obj.VBELN_SO__c+'_'+obj.TABLE_NAME__c;
                findT_ZCRM.put(key ,obj);
            }
        }
        findIFOrder.put('T_ORDER',findT_Order);
        findIFOrder.put('T_ZCRM',findT_ZCRM);
        
        return findIFOrder;
    }
    private IF_ERP_DNSA_OrderBatch.DnsaOrderDto fromT_ZCRMS0094(IF_ERP_Order_Classes.IF_ORDER_012_Res_T_ZCRMS0094 item){
        IF_ERP_DNSA_OrderBatch.DnsaOrderDto dto    = new IF_ERP_DNSA_OrderBatch.DnsaOrderDto();
        dto.TABLE_NAME      = 'T_ZCRMS0094';                  
        dto.VBELN_SO        = item.VBELN_SO;       dto.PSO_NUM        = item.PSO_NUM;        dto.VBELN           = item.VBELN;          dto.WADAT          = item.WADAT;
        dto.WAUHR           = item.WAUHR;          dto.LFDAT          = item.LFDAT;          dto.LFUHR           = item.LFUHR;          dto.WADAT_IST      = item.WADAT_IST;
        dto.ZZSTATUS        = item.ZZSTATUS;       dto.ZFETD          = item.ZFETD;          dto.ZFETA           = item.ZFETA;          dto.ZFCSHCP        = item.ZFCSHCP;
        dto.ZFCARNM         = item.ZFCARNM;        dto.ZFPLDVLD       = item.ZFPLDVLD;       dto.ZFPLDVCD        = item.ZFPLDVCD;       dto.ZFPLDV         = item.ZFPLDV;
        dto.NAME1           = item.NAME1;
        return dto;
    }
    private IF_ERP_DNSA_OrderBatch.DnsaOrderDto fromT_ORDER(IF_ERP_Order_Classes.IF_ORDER_012_Res_T_ORDER item){
        IF_ERP_DNSA_OrderBatch.DnsaOrderDto dto = new IF_ERP_DNSA_OrderBatch.DnsaOrderDto();
        dto.TABLE_NAME = 'T_ORDER';      
        dto.AUART             = item.AUART;
        dto.BSTDK             = item.BSTDK;             dto.AUART_TX          = item.AUART_TX;          dto.BSTKD             = item.BSTKD;             dto.ERDAT             = item.ERDAT;
        dto.VBELN             = item.VBELN;             dto.ERDAT_D           = item.ERDAT_D;           dto.GUBUN             = item.GUBUN;             dto.MODEL             = item.MODEL;
        dto.MODEL_TX          = item.MODEL_TX;          dto.TOTAL_AMT         = item.TOTAL_AMT;         dto.DISC_AMT          = item.DISC_AMT;          dto.SURC_AMT          = item.SURC_AMT;
        dto.NETWR_AMT         = item.NETWR_AMT;         dto.WAERK             = item.WAERK;             dto.VSART             = item.VSART;             dto.VSART_TX          = item.VSART_TX;
        dto.ZTERM             = item.ZTERM;             dto.ZTERM_TX          = item.ZTERM_TX;          dto.VDATU             = item.VDATU;             dto.KUNNR_AG          = item.KUNNR_AG;
        dto.KUNNR_AG_TX       = item.KUNNR_AG_TX;       dto.KUNNR_WE          = item.KUNNR_WE;          dto.KUNNR_WE_TX       = item.KUNNR_WE_TX;       dto.KUNNR_RE          = item.KUNNR_RE;
        dto.KUNNR_RE_TX       = item.KUNNR_RE_TX;       dto.KUNNR_RG          = item.KUNNR_RG;          dto.KUNNR_RG_TX       = item.KUNNR_RG_TX;       dto.KUNNR_ZM          = item.KUNNR_ZM;
        dto.KUNNR_ZM_TX       = item.KUNNR_ZM_TX;       dto.ERNAM             = item.ERNAM;             dto.NAME              = item.NAME;              dto.APPROVAL          = item.APPROVAL;
        dto.REJECT            = item.REJECT;            dto.BUTTTON_ENABLE    = item.BUTTTON_ENABLE;    dto.ZZSTATUS          = item.ZZSTATUS;          dto.ZZSTATUS_TX       = item.ZZSTATUS_TX;
        dto.ZSDFUNC           = item.ZSDFUNC;           dto.ZSDFUNC_TX        = item.ZSDFUNC_TX;        dto.ABGRU             = item.ABGRU;             dto.ABGRU_TX          = item.ABGRU_TX;
        dto.TAX_AMT           = item.TAX_AMT;           dto.SERNR             = item.SERNR;             dto.MAKTX             = item.MAKTX;             dto.TOTAL_DC_RATE     = item.TOTAL_DC_RATE;
        dto.FKDAT             = item.FKDAT;             dto.VSBED             = item.VSBED;             dto.VSBED_TX          = item.VSBED_TX;          dto.MBDAT             = item.MBDAT;
        dto.KUNNR_ZV          = item.KUNNR_ZV;          dto.KUNNR_ZV_TX       = item.KUNNR_ZV_TX;       dto.ICON_V            = item.ICON_V;            dto.BMENG             = item.BMENG;
        dto.ADEPDT            = item.ADEPDT;            dto.VRKME             = item.VRKME;             dto.OALIAS            = item.OALIAS;            dto.IHREZ             = item.IHREZ;
        dto.VBELN_ST          = item.VBELN_ST;          dto.KWERT             = item.KWERT;             dto.WAERS             = item.WAERS;             dto.KBETR             = item.KBETR;
        dto.WAERS_DC          = item.WAERS_DC;          dto.KWERT_DC          = item.KWERT_DC;          dto.ATTACH            = item.ATTACH;            dto.ZZAPPNO           = item.ZZAPPNO;
        dto.ZZAPPNO_T         = item.ZZAPPNO_T;         dto.LOCATION          = item.LOCATION;          dto.KUNNR_Z2          = item.KUNNR_Z2;          dto.Z2_NAME           = item.Z2_NAME;
        dto.VSNMR_V           = item.VSNMR_V;           dto.EQUNR             = item.EQUNR;             dto.MDLNM             = item.MDLNM;             dto.EDATE             = item.EDATE;
        dto.RDATE             = item.RDATE;             dto.RTDAT             = item.RTDAT;             dto.STAGE             = item.STAGE;             dto.NOTE_ZH03         = item.NOTE_ZH03;
        dto.EDATU             = item.EDATU;             dto.FKSTK             = item.FKSTK;             dto.AUGRU             = item.AUGRU;             dto.AUGRU_T           = item.AUGRU_T;
        dto.SERGE             = item.SERGE;             dto.ZSTOCKTEX         = item.ZSTOCKTEX;         dto.VBELN_STO         = item.VBELN_STO;         dto.UPTDATE           = item.UPTDATE;
        dto.ZPPDATE           = item.ZPPDATE;           dto.OPT1              = item.OPT1;              dto.OPT2              = item.OPT2;              dto.OPT3              = item.OPT3;
        dto.OPT4              = item.OPT4;              dto.OPT5              = item.OPT5;              dto.OPT6              = item.OPT6;              dto.ACDAT             = item.ACDAT;
        dto.J_1KFREPRE        = item.J_1KFREPRE;        dto.CARNO             = item.CARNO;             dto.AMOUNT            = item.AMOUNT;            dto.BAS_RATE          = item.BAS_RATE;
        dto.ALL_RATE          = item.ALL_RATE;          dto.PRO_RATE          = item.PRO_RATE;          dto.TOTAL_DC_AMT      = item.TOTAL_DC_AMT;      dto.TOTAL_DC          = item.TOTAL_DC;
        dto.DC_AMT            = item.DC_AMT;            dto.ATWRT             = item.ATWRT;             dto.VBELN_V           = item.VBELN_V;           dto.ZTRAC             = item.ZTRAC;
        dto.POSNR             = item.POSNR;             dto.LIFNR             = item.LIFNR;             dto.NAME1             = item.NAME1;             dto.MATNR             = item.MATNR;
        dto.ETDAT             = item.ETDAT;             dto.PRODAT            = item.PRODAT;            dto.ZETADAT           = item.ZETADAT;           dto.VKBUR             = item.VKBUR;
        dto.EBELN             = item.EBELN;             dto.ZPORT             = item.ZPORT;             dto.SHP_DT            = item.SHP_DT;            dto.DLV_DT            = item.DLV_DT;
        dto.MANUFACTURER      = item.MANUFACTURER;      dto.AEDAT             = item.AEDAT;             dto.WADAT_IST         = item.WADAT_IST;         dto.PSO_NUM           = item.PSO_NUM;
        dto.ZDELFLAG          = item.ZDELFLAG;          dto.ZRETURNS          = item.ZRETURNS;          dto.INCO1             = item.INCO1;             dto.INCO2             = item.INCO2;
        dto.VKORG             = item.VKORG;             dto.VTWEG             = item.VTWEG;             dto.SPART             = item.SPART;
        return dto;            
    }    
    private class DnsaOrderDto {
        public DnsaOrderDto(){}

        public String TABLE_NAME, AUART, BSTDK;
        public String AUART_TX, BSTKD, ERDAT, VBELN;
        public String ERDAT_D, GUBUN, MODEL, MODEL_TX;
        public String TOTAL_AMT, DISC_AMT, SURC_AMT, NETWR_AMT;
        public String WAERK, VSART, VSART_TX, ZTERM;
        public String ZTERM_TX, VDATU, KUNNR_AG, KUNNR_AG_TX;
        public String KUNNR_WE, KUNNR_WE_TX, KUNNR_RE, KUNNR_RE_TX;
        public String KUNNR_RG, KUNNR_RG_TX, KUNNR_ZM, KUNNR_ZM_TX;
        public String ERNAM, NAME, APPROVAL, REJECT;
        public String BUTTTON_ENABLE, ZZSTATUS, ZZSTATUS_TX, ZSDFUNC;
        public String ZSDFUNC_TX, ABGRU, ABGRU_TX, TAX_AMT;
        public String SERNR, MAKTX, TOTAL_DC_RATE, FKDAT;
        public String VSBED, VSBED_TX, MBDAT, KUNNR_ZV;
        public String KUNNR_ZV_TX, ICON_V, BMENG, ADEPDT;
        public String VRKME, OALIAS, IHREZ, VBELN_ST;
        public String KWERT, WAERS, KBETR, WAERS_DC;
        public String KWERT_DC, ATTACH, ZZAPPNO, ZZAPPNO_T;
        public String LOCATION, KUNNR_Z2, Z2_NAME, VSNMR_V;
        public String EQUNR, MDLNM, EDATE, RDATE;
        public String RTDAT, STAGE, NOTE_ZH03, EDATU;
        public String FKSTK, AUGRU, AUGRU_T, SERGE;
        public String ZSTOCKTEX, VBELN_STO, UPTDATE, ZPPDATE;
        public String OPT1, OPT2, OPT3, OPT4;
        public String OPT5, OPT6, ACDAT, J_1KFREPRE;
        public String CARNO, AMOUNT, BAS_RATE, ALL_RATE;
        public String PRO_RATE, TOTAL_DC_AMT, TOTAL_DC, DC_AMT;
        public String ATWRT, VBELN_V, ZTRAC, POSNR;
        public String LIFNR, NAME1, MATNR, ETDAT;
        public String PRODAT, ZETADAT, VKBUR, EBELN;
        public String ZPORT, SHP_DT, DLV_DT, MANUFACTURER;
        public String AEDAT, WADAT_IST, PSO_NUM, ZDELFLAG;
        public String ZRETURNS, INCO1, INCO2, VBELN_SO;
        public String WADAT, WAUHR, LFDAT, LFUHR;
        public String ZFETD, ZFETA, ZFCSHCP, ZFCARNM;
        public String ZFPLDVLD, ZFPLDVCD, ZFPLDV;
        public String VKORG, VTWEG, SPART;
    }
}