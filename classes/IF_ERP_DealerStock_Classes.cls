public with sharing class IF_ERP_DealerStock_Classes {
    public IF_ERP_DealerStock_Classes() {}

/** IF_DEALERSTOCK_001
    */  
    /**
         * Apex Class           : IF_ERP_DealerStock
         * Wrapper Class        : IF_ERP_DealerStock_Classes
         * Wrapper Name         : IF-DEALERSTOCK-001
         * SFDC interface Id    : IF_DEALERSTOCK_001
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SS_SEND_REPLACE_PART_HIST
         * Description          : 대체품 해제 이력 조회 
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */     
        public class IF_DEALERSTOCK_001_Req {
        public IF_DEALERSTOCK_001_Req(){
            this.I_USERINFO = new IF_DEALERSTOCK_001_Req_I_USERINFO();
            this.IT_MATNR   = new List<IF_DEALERSTOCK_001_Req_IT_MATNR>();  
        }
        @AuraEnabled public String I_DATE_FROM {get;set;} 
        @AuraEnabled public String I_DATE_TO {get;set;} 

        @AuraEnabled public IF_DEALERSTOCK_001_Req_I_USERINFO I_USERINFO {get;set;} 
        @AuraEnabled public List<IF_DEALERSTOCK_001_Req_IT_MATNR> IT_MATNR {get;set;} 
        }

        public class IF_DEALERSTOCK_001_Req_I_USERINFO { 
        public IF_DEALERSTOCK_001_Req_I_USERINFO(){} 
        @AuraEnabled public String BNAME  {get;set;} 
        @AuraEnabled public String RNAME  {get;set;} 
        @AuraEnabled public String HIER   {get;set;} 
        @AuraEnabled public String KUNNR  {get;set;} 
        @AuraEnabled public String LIFNR  {get;set;} 

        @AuraEnabled public String VKORG  {get;set;} 
        @AuraEnabled public String VTWEG  {get;set;} 
        @AuraEnabled public String SPART  {get;set;} 
        @AuraEnabled public String WERKS  {get;set;} 
        @AuraEnabled public String ARBPL  {get;set;} 

        @AuraEnabled public String PARNR  {get;set;} 
        @AuraEnabled public String ENAME  {get;set;} 
        @AuraEnabled public String KUNN2  {get;set;} 
        @AuraEnabled public String LAND1  {get;set;} 
        @AuraEnabled public String LGORT  {get;set;} 

        @AuraEnabled public String DF_CHK {get;set;} 
        @AuraEnabled public String CO_CHK {get;set;} 
        }

        public class IF_DEALERSTOCK_001_Req_IT_MATNR {
        public IF_DEALERSTOCK_001_Req_IT_MATNR(){} 
        @AuraEnabled public String MATNR {get;set;} 
        }

    /** RESPONSE 
        SYSTEM : IF_SYSTEM
        NUMBER : IF_NUMBER
      */     
        public class IF_DEALERSTOCK_001_Res { 
            public IF_DEALERSTOCK_001_Res(){
                this.ES_RETURN = new IF_DEALERSTOCK_001_Res_ES_RETURN();
                this.ET_HIST   = new List<IF_DEALERSTOCK_001_Res_ET_HIST>();  
            }
        @AuraEnabled public IF_DEALERSTOCK_001_Res_ES_RETURN ES_RETURN {get;set;} 
        @AuraEnabled public List<IF_DEALERSTOCK_001_Res_ET_HIST> ET_HIST {get;set;} 
        }

        public class IF_DEALERSTOCK_001_Res_ES_RETURN {
            public IF_DEALERSTOCK_001_Res_ES_RETURN(){} 
        @AuraEnabled public String TYPE   {get;set;} 
        @AuraEnabled public String ID     {get;set;} 
        @AuraEnabled public String IF_NUMBER {get;set;} 
        @AuraEnabled public String MESSAGE {get;set;} 
        @AuraEnabled public String LOG_NO {get;set;} 

        @AuraEnabled public String LOG_MSG_NO {get;set;} 
        @AuraEnabled public String MESSAGE_V1 {get;set;} 
        @AuraEnabled public String MESSAGE_V2 {get;set;} 
        @AuraEnabled public String MESSAGE_V3 {get;set;} 
        @AuraEnabled public String MESSAGE_V4 {get;set;} 

        @AuraEnabled public String PARAMETER {get;set;} 
        @AuraEnabled public String ROW    {get;set;} 
        @AuraEnabled public String FIELD  {get;set;} 
        @AuraEnabled public String IF_SYSTEM {get;set;} 

        }

        public class IF_DEALERSTOCK_001_Res_ET_HIST { 
            public IF_DEALERSTOCK_001_Res_ET_HIST(){}
        @AuraEnabled public String MATNR {get;set;} 
        @AuraEnabled public String MAKTX {get;set;} 
        @AuraEnabled public String LSTNR {get;set;} 
        @AuraEnabled public String DMD18 {get;set;} 
        @AuraEnabled public String DMD17 {get;set;} 

        @AuraEnabled public String DMD16 {get;set;} 
        @AuraEnabled public String DMD15 {get;set;} 
        @AuraEnabled public String DMD14 {get;set;} 
        @AuraEnabled public String DMD13 {get;set;} 
        @AuraEnabled public String DMD12 {get;set;} 

        @AuraEnabled public String DMD11 {get;set;} 
        @AuraEnabled public String DMD10 {get;set;} 
        @AuraEnabled public String DMD09 {get;set;} 
        @AuraEnabled public String DMD08 {get;set;} 
        @AuraEnabled public String DMD07 {get;set;} 

        @AuraEnabled public String DMD06 {get;set;} 
        @AuraEnabled public String DMD05 {get;set;} 
        @AuraEnabled public String DMD04 {get;set;} 
        @AuraEnabled public String DMD03 {get;set;} 
        @AuraEnabled public String DMD02 {get;set;} 

        @AuraEnabled public String DMD01 {get;set;} 
        @AuraEnabled public String MEINS {get;set;} 
        @AuraEnabled public String FRQ06 {get;set;} 
        @AuraEnabled public String FRQ12 {get;set;} 
        @AuraEnabled public String FRQ18 {get;set;} 

        @AuraEnabled public String VERPR {get;set;} 
        @AuraEnabled public String WAERS {get;set;} 
        @AuraEnabled public String MAABC {get;set;} 
        @AuraEnabled public String MINBE {get;set;} 
        @AuraEnabled public String MABST {get;set;} 

        @AuraEnabled public String CHGDT {get;set;} 
        @AuraEnabled public String SVRCD {get;set;} 
        @AuraEnabled public String MMSTA {get;set;} 

        }

/** IF_DEALERSTOCK_002
    */  
    /**
         * Apex Class           : IF_ERP_DealerStock
         * Wrapper Class        : IF_ERP_DealerStock_Classes
         * Wrapper Name         : IF-DEALERSTOCK-002
         * SFDC interface Id    : IF_DEALERSTOCK_002
         * AS-IS RFC            : 
         * New I/F              : ZSS_SEND_MATERIAL_EXTENTION
         * Description          : 대체품 해제 이력 조회-부품마스터에 LAST 품번이 존재하므로 I/F에 항목 추가-신규부품 생성 시 대리점 별로 부품정보 확장
         * KeyValue             : X
         * NOT NULL             : X
         -> 신규 생성된 품번을 대리점의 Material Master 로 생성해주는 기능 
         대리점 자재 종합조회 - 확장
     */            
    /** REQUEST 
      */
        public class IF_DEALERSTOCK_002_Req {
        public IF_DEALERSTOCK_002_Req(){ this.I_USERINFO = new IF_DEALERSTOCK_002_Req_I_USERINFO();} 
        @AuraEnabled public String I_MATNR {get;set;} 

        @AuraEnabled public IF_DEALERSTOCK_002_Req_I_USERINFO I_USERINFO {get;set;} 

        }

        public class IF_DEALERSTOCK_002_Req_I_USERINFO { 
        @AuraEnabled public String BNAME {get;set;} 
        @AuraEnabled public String VKORG {get;set;} 
        @AuraEnabled public String VTWEG {get;set;} 
        @AuraEnabled public String SPART {get;set;} 
        @AuraEnabled public String WERKS {get;set;} 

        }

      
     /** RESPONSE 
      */
        public class IF_DEALERSTOCK_002_Res {
        public IF_DEALERSTOCK_002_Res(){
            this.ES_RETURN = new IF_DEALERSTOCK_002_Res_ES_RETURN();
        }
        @AuraEnabled public IF_DEALERSTOCK_002_Res_ES_RETURN ES_RETURN {get;set;} 

        }

        public class IF_DEALERSTOCK_002_Res_ES_RETURN { 
        @AuraEnabled public String TYPE   {get;set;} 
        @AuraEnabled public String ID     {get;set;} 
        @AuraEnabled public String IF_NUMBER {get;set;} 
        @AuraEnabled public String MESSAGE {get;set;} 
        @AuraEnabled public String LOG_NO {get;set;} 

        @AuraEnabled public String LOG_MSG_NO {get;set;} 
        @AuraEnabled public String MESSAGE_V1 {get;set;} 
        @AuraEnabled public String MESSAGE_V2 {get;set;} 
        @AuraEnabled public String MESSAGE_V3 {get;set;} 
        @AuraEnabled public String MESSAGE_V4 {get;set;} 

        @AuraEnabled public String PARAMETER {get;set;} 
        @AuraEnabled public String ROW    {get;set;} 
        @AuraEnabled public String FIELD  {get;set;} 
        @AuraEnabled public String IF_SYSTEM {get;set;} 

        }

/** IF-DEALERSTOCK-003
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_REQ
 * Description          : 대리점 무상 오더 불출 요청 정보 조회
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_DEALERSTOCK_GI_REQ_M
    */
    public class IF_DEALERSTOCK_003_Req{
        @AuraEnabled public String                                  I_HISTORY       {get;set;}
        @AuraEnabled public IF_DEALERSTOCK_003_Req_I_DETAIL_INFO    I_DETAIL_INFO   {get;set;}

        public IF_DEALERSTOCK_003_Req(){}
    }
    public class IF_DEALERSTOCK_003_Req_I_DETAIL_INFO{
        @AuraEnabled public String AUFNR        {get;set;}
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String BDMNG        {get;set;}
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String MEINS        {get;set;}
        
        @AuraEnabled public String DEALER_CD    {get;set;}
        @AuraEnabled public String DEDAT        {get;set;}
        @AuraEnabled public String DEZIT        {get;set;}
        @AuraEnabled public String DENAM        {get;set;}

        public IF_DEALERSTOCK_003_Req_I_DETAIL_INFO(){}
    }
    public class IF_DEALERSTOCK_003_Res{
        @AuraEnabled public IF_DEALERSTOCK_003_Res_O_RETURN             O_RETURN       {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_003_Res_T_O_RESB>       T_O_RESB       {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093>  T_O_ZCRMS0093  {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_003_Res_T_O_ZCST0040>   T_O_ZCST0040   {get;set;}

        public IF_DEALERSTOCK_003_Res(){}
    }
    public class IF_DEALERSTOCK_003_Res_O_RETURN {
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_DEALERSTOCK_003_Res_O_RETURN(){}
    }
    public class IF_DEALERSTOCK_003_Res_T_O_RESB {
        @AuraEnabled public String AUFNR    {get;set;}
        @AuraEnabled public String POSNR    {get;set;}
        @AuraEnabled public String RSNUM    {get;set;}
        @AuraEnabled public String RSPOS    {get;set;}
        @AuraEnabled public String MATNR    {get;set;}

        @AuraEnabled public String MAKTX    {get;set;}
        @AuraEnabled public String WERKS    {get;set;}
        @AuraEnabled public String LGORT    {get;set;}
        @AuraEnabled public String POSTP    {get;set;}
        @AuraEnabled public String BDMNG    {get;set;}
        
        @AuraEnabled public String MEINS    {get;set;}
        @AuraEnabled public String VORNR    {get;set;}
        @AuraEnabled public String RSART    {get;set;}
        @AuraEnabled public String CHK      {get;set;}

        public IF_DEALERSTOCK_003_Res_T_O_RESB(){}
    }
    public class IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093{
        @AuraEnabled public String MANDT         {get;set;}           
        @AuraEnabled public String QMNUM         {get;set;}           
        @AuraEnabled public String QMSEQ         {get;set;}           
        @AuraEnabled public String EQUNR         {get;set;}           
        @AuraEnabled public String MATNR         {get;set;}    

        @AuraEnabled public String CAUSE         {get;set;}           
        @AuraEnabled public String LIFNR         {get;set;}           
        @AuraEnabled public String ZSUPPLY       {get;set;}           
        @AuraEnabled public String MENGE         {get;set;}           
        @AuraEnabled public String MEINS         {get;set;}           
        
        @AuraEnabled public String VBELN         {get;set;}           
        @AuraEnabled public String VSBED         {get;set;}           
        @AuraEnabled public String KUNNR         {get;set;}           
        @AuraEnabled public String ERROR         {get;set;}           
        @AuraEnabled public String EBELN         {get;set;}           
        
        @AuraEnabled public String DELIV         {get;set;}           
        @AuraEnabled public String CLAIM_NO      {get;set;}           
        @AuraEnabled public String POWERTRAIN    {get;set;}               
        @AuraEnabled public String STATUS        {get;set;}           
        @AuraEnabled public String RETURN_YN     {get;set;}               
        
        @AuraEnabled public String ARBPL         {get;set;}           
        @AuraEnabled public String AUFNR         {get;set;}           
        @AuraEnabled public String AUART         {get;set;}           
        @AuraEnabled public String KUNUM         {get;set;}           
        @AuraEnabled public String TNAME         {get;set;}           
        
        @AuraEnabled public String WERKS         {get;set;}           
        @AuraEnabled public String APPRO_ID      {get;set;}           
        @AuraEnabled public String APPRO_ST      {get;set;}           
        @AuraEnabled public String REQ_USER      {get;set;}           
        @AuraEnabled public String REQ_DATE      {get;set;}           
        
        @AuraEnabled public String CNF_DATE      {get;set;}           
        @AuraEnabled public String AUTLF         {get;set;}           
        @AuraEnabled public String COUNTRY       {get;set;}           
        @AuraEnabled public String CARRIER       {get;set;}           
        @AuraEnabled public String CARRIER_T     {get;set;}               
        
        @AuraEnabled public String ACCT_NO       {get;set;}           
        @AuraEnabled public String ONE_TIME_CHK  {get;set;}               
        @AuraEnabled public String ORDER_TYPE    {get;set;}               
        @AuraEnabled public String RSNUM         {get;set;}           
        @AuraEnabled public String HOLD          {get;set;}       
        
        @AuraEnabled public String VSTEL         {get;set;}           
        @AuraEnabled public String ZRMA          {get;set;}       
        @AuraEnabled public String SPIND         {get;set;}           
        @AuraEnabled public String MAKTX         {get;set;}           
        @AuraEnabled public String NAME1         {get;set;}           
        
        @AuraEnabled public String CHK           {get;set;}       

        public IF_DEALERSTOCK_003_Res_T_O_ZCRMS0093(){}
    }
    public class IF_DEALERSTOCK_003_Res_T_O_ZCST0040{
        @AuraEnabled public String MANDT          {get;set;}        
        @AuraEnabled public String AUFNR          {get;set;}        
        @AuraEnabled public String WORKNO         {get;set;}        
        @AuraEnabled public String SEQNO          {get;set;}        
        @AuraEnabled public String MATNR          {get;set;}        

        @AuraEnabled public String ITEM_NUMBER    {get;set;}            
        @AuraEnabled public String MAKTX          {get;set;}        
        @AuraEnabled public String MEINS          {get;set;}        
        @AuraEnabled public String PGMNG          {get;set;}        
        @AuraEnabled public String MENGE          {get;set;}        

        @AuraEnabled public String SUPPLY_TYPE    {get;set;}            
        @AuraEnabled public String ITEM_CAT       {get;set;}        
        @AuraEnabled public String CHANGE_DT      {get;set;}            
        @AuraEnabled public String EBELN          {get;set;}        
        @AuraEnabled public String EBELP          {get;set;}        

        @AuraEnabled public String MBLNR          {get;set;}        
        @AuraEnabled public String GI_MBLNR       {get;set;}        
        @AuraEnabled public String LIFNR          {get;set;}        
        @AuraEnabled public String NAME1          {get;set;}        
        @AuraEnabled public String LPRICE         {get;set;}       

        @AuraEnabled public String NETWR          {get;set;}        
        @AuraEnabled public String BRTWR          {get;set;}        
        @AuraEnabled public String FREIGHT        {get;set;}        
        @AuraEnabled public String WAERS          {get;set;}        
        @AuraEnabled public String BELNR          {get;set;}        
        
        @AuraEnabled public String CAUSE_PRT      {get;set;}          
        @AuraEnabled public String RETURN_YN      {get;set;}            
        @AuraEnabled public String RETURN_TYPE    {get;set;}            
        @AuraEnabled public String RETURN_TEXT    {get;set;}            
        @AuraEnabled public String RETURN_WAY     {get;set;}      

        @AuraEnabled public String RETURN_END_YN  {get;set;}                
        @AuraEnabled public String RETURN_QTY     {get;set;}            
        @AuraEnabled public String RETURN_DT      {get;set;}            
        @AuraEnabled public String BANFN          {get;set;}        
        @AuraEnabled public String BNFPO          {get;set;}        
        
        @AuraEnabled public String BELNR_IV       {get;set;}        
        @AuraEnabled public String VBELN          {get;set;}        
        @AuraEnabled public String POSNR          {get;set;}        
        @AuraEnabled public String SO_CHK         {get;set;}        
        @AuraEnabled public String CNF_QTY        {get;set;}        

        @AuraEnabled public String CLOSE_DT       {get;set;}        
        @AuraEnabled public String PRT_DATE       {get;set;}        
        @AuraEnabled public String PRT_TIME       {get;set;}        
        @AuraEnabled public String REASON1        {get;set;}        
        @AuraEnabled public String REASON2        {get;set;}       

        @AuraEnabled public String MAT_WARR_YN    {get;set;}            
        @AuraEnabled public String ZSVP           {get;set;}    
        @AuraEnabled public String VBELN_VF       {get;set;}        
        @AuraEnabled public String POSNR_VF       {get;set;}        
        @AuraEnabled public String NRTN_TEXT      {get;set;}       

        @AuraEnabled public String INCLUDE        {get;set;}        
        @AuraEnabled public String ERDAT          {get;set;}        
        @AuraEnabled public String ERNAM          {get;set;}        
        @AuraEnabled public String ERZET          {get;set;}        
        @AuraEnabled public String AEDAT          {get;set;}       

        @AuraEnabled public String AENAM          {get;set;}        
        @AuraEnabled public String AEZET          {get;set;}        

        public IF_DEALERSTOCK_003_Res_T_O_ZCST0040(){}
    }

/** IF-DEALERSTOCK-004
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_REQ_DIV
 * Description          : 대리점 무상 오더 불출 요청 정보 분할
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_DEALERSTOCK_GI_REQ_DIV_M
    */
    public class IF_DEALERSTOCK_004_Req{
        @AuraEnabled public String I_AUFNR  {get;set;}
        @AuraEnabled public String I_POSNR  {get;set;}
        @AuraEnabled public String I_QTY1   {get;set;}
        @AuraEnabled public String I_QTY2   {get;set;}

        public IF_DEALERSTOCK_004_Req(){}
    }
    public class IF_DEALERSTOCK_004_Res{
        @AuraEnabled public List<IF_DEALERSTOCK_004_Res_T_RETURN>    T_RETURN    {get;set;}
        @AuraEnabled public IF_DEALERSTOCK_004_Res_O_RETURN          O_RETURN    {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_004_Res_T_MAIN>      T_MAIN      {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_004_Res_T_RESB>      T_RESB      {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_004_Res_T_NOTI>      T_NOTI      {get;set;}

        @AuraEnabled public List<IF_DEALERSTOCK_004_Res_T_DOMESTIC>  T_DOMESTIC  {get;set;}

        public IF_DEALERSTOCK_004_Res(){}
    }
    public class IF_DEALERSTOCK_004_Res_T_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_DEALERSTOCK_004_Res_T_RETURN(){}
    }
    public class IF_DEALERSTOCK_004_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_DEALERSTOCK_004_Res_O_RETURN(){}
    }
    public class IF_DEALERSTOCK_004_Res_T_MAIN{
        @AuraEnabled public String AUFNR      {get;set;}          
        @AuraEnabled public String POSNR      {get;set;}          
        @AuraEnabled public String QMDAT      {get;set;}          
        @AuraEnabled public String MATNR      {get;set;}          
        @AuraEnabled public String BDMNG      {get;set;}          

        @AuraEnabled public String BMENG      {get;set;}          
        @AuraEnabled public String MEINS      {get;set;}          
        @AuraEnabled public String WRAMT      {get;set;}          
        @AuraEnabled public String WAERS      {get;set;}          
        @AuraEnabled public String VSART      {get;set;}          

        @AuraEnabled public String PDATE      {get;set;}          
        @AuraEnabled public String PTIME      {get;set;}          
        @AuraEnabled public String ERSDA      {get;set;}          
        @AuraEnabled public String DEALER_CD  {get;set;}              
        @AuraEnabled public String STAT       {get;set;}      
        
        @AuraEnabled public String INVOICE    {get;set;}          
        @AuraEnabled public String ERDAT      {get;set;}          
        @AuraEnabled public String ERZET      {get;set;}          
        @AuraEnabled public String ERNAM      {get;set;}          
        @AuraEnabled public String AEDAT      {get;set;}          

        @AuraEnabled public String AEZET      {get;set;}          
        @AuraEnabled public String AENAM      {get;set;}          
        @AuraEnabled public String MAKTX      {get;set;}          
        @AuraEnabled public String VSARTT     {get;set;}          
        @AuraEnabled public String STATT      {get;set;}          

        @AuraEnabled public String DEALER_NM  {get;set;}              
        @AuraEnabled public String DEDAT      {get;set;}          
        @AuraEnabled public String DEZIT      {get;set;}          
        @AuraEnabled public String DENAM      {get;set;}          
        @AuraEnabled public String RCOL       {get;set;}      

        @AuraEnabled public String CHK        {get;set;}      

        public IF_DEALERSTOCK_004_Res_T_MAIN(){}
    }
    public class IF_DEALERSTOCK_004_Res_T_RESB{
        @AuraEnabled public String AUFNR    {get;set;}
        @AuraEnabled public String POSNR    {get;set;}
        @AuraEnabled public String RSNUM    {get;set;}
        @AuraEnabled public String RSPOS    {get;set;}
        @AuraEnabled public String MATNR    {get;set;}

        @AuraEnabled public String MAKTX    {get;set;}
        @AuraEnabled public String WERKS    {get;set;}
        @AuraEnabled public String LGORT    {get;set;}
        @AuraEnabled public String POSTP    {get;set;}
        @AuraEnabled public String BDMNG    {get;set;}

        @AuraEnabled public String MEINS    {get;set;}
        @AuraEnabled public String VORNR    {get;set;}
        @AuraEnabled public String RSART    {get;set;}
        @AuraEnabled public String CHK      {get;set;}

        public IF_DEALERSTOCK_004_Res_T_RESB(){}
    }
    public class IF_DEALERSTOCK_004_Res_T_NOTI{
        @AuraEnabled public String MANDT          {get;set;}         
        @AuraEnabled public String QMNUM          {get;set;}         
        @AuraEnabled public String QMSEQ          {get;set;}         
        @AuraEnabled public String EQUNR          {get;set;}         
        @AuraEnabled public String MATNR          {get;set;}         

        @AuraEnabled public String CAUSE          {get;set;}         
        @AuraEnabled public String LIFNR          {get;set;}         
        @AuraEnabled public String ZSUPPLY        {get;set;}         
        @AuraEnabled public String MENGE          {get;set;}         
        @AuraEnabled public String MEINS          {get;set;}         

        @AuraEnabled public String VBELN          {get;set;}         
        @AuraEnabled public String VSBED          {get;set;}         
        @AuraEnabled public String KUNNR          {get;set;}         
        @AuraEnabled public String ERROR          {get;set;}         
        @AuraEnabled public String EBELN          {get;set;}         

        @AuraEnabled public String DELIV          {get;set;}         
        @AuraEnabled public String CLAIM_NO       {get;set;}         
        @AuraEnabled public String POWERTRAIN     {get;set;}             
        @AuraEnabled public String STATUS         {get;set;}         
        @AuraEnabled public String RETURN_YN      {get;set;}        

        @AuraEnabled public String ARBPL          {get;set;}         
        @AuraEnabled public String AUFNR          {get;set;}         
        @AuraEnabled public String AUART          {get;set;}         
        @AuraEnabled public String KUNUM          {get;set;}         
        @AuraEnabled public String TNAME          {get;set;}         

        @AuraEnabled public String WERKS          {get;set;}         
        @AuraEnabled public String APPRO_ID       {get;set;}         
        @AuraEnabled public String APPRO_ST       {get;set;}         
        @AuraEnabled public String REQ_USER       {get;set;}         
        @AuraEnabled public String REQ_DATE       {get;set;}         

        @AuraEnabled public String CNF_DATE       {get;set;}         
        @AuraEnabled public String AUTLF          {get;set;}         
        @AuraEnabled public String COUNTRY        {get;set;}         
        @AuraEnabled public String CARRIER        {get;set;}         
        @AuraEnabled public String CARRIER_T      {get;set;}             

        @AuraEnabled public String ACCT_NO        {get;set;}         
        @AuraEnabled public String ONE_TIME_CHK   {get;set;}             
        @AuraEnabled public String ORDER_TYPE     {get;set;}             
        @AuraEnabled public String RSNUM          {get;set;}         
        @AuraEnabled public String HOLD           {get;set;}     

        @AuraEnabled public String VSTEL          {get;set;}         
        @AuraEnabled public String ZRMA           {get;set;}     
        @AuraEnabled public String SPIND          {get;set;}         

        public IF_DEALERSTOCK_004_Res_T_NOTI(){}
    }
    public class IF_DEALERSTOCK_004_Res_T_DOMESTIC{
        @AuraEnabled public String MANDT          {get;set;}        
        @AuraEnabled public String AUFNR          {get;set;}        
        @AuraEnabled public String WORKNO         {get;set;}        
        @AuraEnabled public String SEQNO          {get;set;}        
        @AuraEnabled public String MATNR          {get;set;}        
        
        @AuraEnabled public String ITEM_NUMBER    {get;set;}    
        @AuraEnabled public String MAKTX          {get;set;}        
        @AuraEnabled public String MEINS          {get;set;}        
        @AuraEnabled public String PGMNG          {get;set;}        
        @AuraEnabled public String MENGE          {get;set;}    

        @AuraEnabled public String SUPPLY_TYPE    {get;set;}            
        @AuraEnabled public String ITEM_CAT       {get;set;}        
        @AuraEnabled public String CHANGE_DT      {get;set;}            
        @AuraEnabled public String EBELN          {get;set;}        
        @AuraEnabled public String EBELP          {get;set;}     

        @AuraEnabled public String MBLNR          {get;set;}        
        @AuraEnabled public String GI_MBLNR       {get;set;}        
        @AuraEnabled public String LIFNR          {get;set;}        
        @AuraEnabled public String NAME1          {get;set;}        
        @AuraEnabled public String LPRICE         {get;set;}     

        @AuraEnabled public String NETWR          {get;set;}        
        @AuraEnabled public String BRTWR          {get;set;}        
        @AuraEnabled public String FREIGHT        {get;set;}        
        @AuraEnabled public String WAERS          {get;set;}        
        @AuraEnabled public String BELNR          {get;set;}    

        @AuraEnabled public String CAUSE_PRT      {get;set;}            
        @AuraEnabled public String RETURN_YN      {get;set;}            
        @AuraEnabled public String RETURN_TYPE    {get;set;}            
        @AuraEnabled public String RETURN_TEXT    {get;set;}            
        @AuraEnabled public String RETURN_WAY     {get;set;}     

        @AuraEnabled public String RETURN_END_YN  {get;set;}                
        @AuraEnabled public String RETURN_QTY     {get;set;}            
        @AuraEnabled public String RETURN_DT      {get;set;}            
        @AuraEnabled public String BANFN          {get;set;}        
        @AuraEnabled public String BNFPO          {get;set;}      

        @AuraEnabled public String BELNR_IV       {get;set;}        
        @AuraEnabled public String VBELN          {get;set;}        
        @AuraEnabled public String POSNR          {get;set;}        
        @AuraEnabled public String SO_CHK         {get;set;}        
        @AuraEnabled public String CNF_QTY        {get;set;}        
        
        @AuraEnabled public String CLOSE_DT       {get;set;}        
        @AuraEnabled public String PRT_DATE       {get;set;}        
        @AuraEnabled public String PRT_TIME       {get;set;}        
        @AuraEnabled public String REASON1        {get;set;}        
        @AuraEnabled public String REASON2        {get;set;}        

        @AuraEnabled public String MAT_WARR_YN    {get;set;}            
        @AuraEnabled public String ZSVP           {get;set;}    
        @AuraEnabled public String VBELN_VF       {get;set;}        
        @AuraEnabled public String POSNR_VF       {get;set;}        
        @AuraEnabled public String NRTN_TEXT      {get;set;}      

        @AuraEnabled public String ERDAT          {get;set;}        
        @AuraEnabled public String ERNAM          {get;set;}        
        @AuraEnabled public String ERZET          {get;set;}        
        @AuraEnabled public String AEDAT          {get;set;}        
        @AuraEnabled public String AENAM          {get;set;}       
         
        @AuraEnabled public String AEZET          {get;set;}        

        public IF_DEALERSTOCK_004_Res_T_DOMESTIC(){}
    }

/** IF-DEALERSTOCK-005
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_REQ_DIV
 * Description          : 대리점 무상 오더 불출 관련 SAP 삭제
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_DEALERSTOCK_GI_REQ_DEL_M
    */
    public class IF_DEALERSTOCK_005_Req {
        @AuraEnabled public String I_AUFNR          {get;set;}
        @AuraEnabled public String I_POSNR          {get;set;}
        @AuraEnabled public String I_DOMESTIC       {get;set;}

        // 2025.03.31 추가
        @AuraEnabled public String I_QMSEQ          {get;set;}
        @AuraEnabled public String I_ITEM_NUMBER    {get;set;}

        public IF_DEALERSTOCK_005_Req(){}
    }
    public class IF_DEALERSTOCK_005_Res {
        @AuraEnabled public String E_USER                                       {get;set;}
        @AuraEnabled public String E_DATUM                                      {get;set;}
        @AuraEnabled public String E_UZEIT                                      {get;set;}
        @AuraEnabled public IF_DEALERSTOCK_005_Res_O_RETURN         O_RETURN    {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_005_Res_T_RETURN>   T_RETURN    {get;set;}

        public IF_DEALERSTOCK_005_Res(){}
    }
    public class IF_DEALERSTOCK_005_Res_O_RETURN {
        @AuraEnabled public String TYPE         {get;set;}    
        @AuraEnabled public String CODE         {get;set;}    
        @AuraEnabled public String MESSAGE      {get;set;}                

        public IF_DEALERSTOCK_005_Res_O_RETURN(){}
    }
    public class IF_DEALERSTOCK_005_Res_T_RETURN {
        @AuraEnabled public String TYPE         {get;set;}    
        @AuraEnabled public String CODE         {get;set;}    
        @AuraEnabled public String MESSAGE      {get;set;}                

        public IF_DEALERSTOCK_005_Res_T_RETURN(){}
    }

/** IF-DEALERSTOCK-006
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_INF_DSP
 * Description          : 출하정보 조회
    */
    public class IF_DEALERSTOCK_006_Req {
        @AuraEnabled public IF_DEALERSTOCK_006_Req_IS_USERINFO      IS_USERINFO {get;set;}
        @AuraEnabled public IF_DEALERSTOCK_006_Req_IS_INPUT         IS_INPUT    {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_006_Req_IT_MATNR>   IT_MATNR    {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_006_Req_IT_IVNO>    IT_IVNO     {get;set;}
        
        public IF_DEALERSTOCK_006_Req(){}
    }
    public class IF_DEALERSTOCK_006_Req_IS_USERINFO {
        @AuraEnabled public String BNAME        {get;set;}
        @AuraEnabled public String RNAME        {get;set;}
        @AuraEnabled public String HIER         {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}
        @AuraEnabled public String LIFNR        {get;set;}

        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}
        @AuraEnabled public String ARBPL        {get;set;}
        
        @AuraEnabled public String PARNR        {get;set;}
        @AuraEnabled public String ENAME        {get;set;}
        @AuraEnabled public String KUNN2        {get;set;}
        @AuraEnabled public String LAND1        {get;set;}
        @AuraEnabled public String LGORT        {get;set;}
        
        @AuraEnabled public String DF_CHK       {get;set;}
        @AuraEnabled public String CO_CHK       {get;set;}

        public IF_DEALERSTOCK_006_Req_IS_USERINFO(){}
    }
    public class IF_DEALERSTOCK_006_Req_IS_INPUT {
        @AuraEnabled public String DOCNO        {get;set;}
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String ERDAT_F      {get;set;}
        @AuraEnabled public String ERDAT_T      {get;set;}
        @AuraEnabled public String TYPE         {get;set;}

        public IF_DEALERSTOCK_006_Req_IS_INPUT(){}
    }
    public class IF_DEALERSTOCK_006_Req_IT_MATNR {
        @AuraEnabled public String MATNR        {get;set;}

        public IF_DEALERSTOCK_006_Req_IT_MATNR(){}
    }
    public class IF_DEALERSTOCK_006_Req_IT_IVNO {
        @AuraEnabled public String TEXT1        {get;set;}

        public IF_DEALERSTOCK_006_Req_IT_IVNO(){}
    }
    public class IF_DEALERSTOCK_006_Res {
        @AuraEnabled public IF_DEALERSTOCK_006_Res_O_RETURN         O_RETURN    {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_006_Res_ET_LIST>    ET_LIST     {get;set;}
        
        public IF_DEALERSTOCK_006_Res(){}
    }
    public class IF_DEALERSTOCK_006_Res_O_RETURN {
        @AuraEnabled public String TYPE         {get;set;}
        @AuraEnabled public String CODE         {get;set;}
        @AuraEnabled public String MESSAGE      {get;set;}

        public IF_DEALERSTOCK_006_Res_O_RETURN(){}
    }
    public class IF_DEALERSTOCK_006_Res_ET_LIST {
        @AuraEnabled public String DOCNO        {get;set;}
        @AuraEnabled public String DOCIT        {get;set;}
        @AuraEnabled public String CUST_NO      {get;set;}
        @AuraEnabled public String NAME1        {get;set;}
        @AuraEnabled public String MATNR        {get;set;}

        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String CUQTY        {get;set;}
        @AuraEnabled public String KWMENG       {get;set;}
        @AuraEnabled public String RMQTY        {get;set;}
        @AuraEnabled public String GRQTY        {get;set;}
        
        @AuraEnabled public String RTQTY        {get;set;}
        @AuraEnabled public String MEINS        {get;set;}
        @AuraEnabled public String LOC          {get;set;}
        @AuraEnabled public String NETPR        {get;set;}
        @AuraEnabled public String DISPR        {get;set;}
        
        @AuraEnabled public String DMBTR        {get;set;}
        @AuraEnabled public String WAERS        {get;set;}
        @AuraEnabled public String AUDAT        {get;set;}
        @AuraEnabled public String GIDAT        {get;set;}
        @AuraEnabled public String TYPE         {get;set;}
        
        @AuraEnabled public String BSTKD        {get;set;}
        @AuraEnabled public String TEXT1        {get;set;}

        public IF_DEALERSTOCK_006_Res_ET_LIST(){}
    }

/** IF_DEALERSTOCK_007
    */  
    /**
         * Apex Class           : IF_ERP_DealerStock
         * Wrapper Class        : IF_ERP_DealerStock_Classes
         * Wrapper Name         : IF-DEALERSTOCK-007
         * SFDC interface Id    : IF_DEALERSTOCK_007
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SS_SEND_TSL_LIST				
         * Description          : : Service factor by target service level 조회
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** RESPONSSE 
      */
    public class IF_DEALERSTOCK_007_Res { 
      @AuraEnabled public IF_DEALERSTOCK_007_Res_O_RETURN O_RETURN {get;set;} 
      @AuraEnabled public List<IF_DEALERSTOCK_007_Res_ET_SFT> ET_SFT {get;set;} 
    }

    public class IF_DEALERSTOCK_007_Res_O_RETURN { 
      @AuraEnabled public String TYPE    {get;set;} 
      @AuraEnabled public String CODE    {get;set;} 
      @AuraEnabled public String MESSAGE {get;set;} 
    }

    public class IF_DEALERSTOCK_007_Res_ET_SFT { 
      @AuraEnabled public String TSL {get;set;} 
      @AuraEnabled public String SFT {get;set;} 
    }

/** IF-DEALERSTOCK-009
 * New I/F              : ZCRM_SS_DEALER_GRADE
 * Description          : 대리점 등급별 할인율 조회
    */
    public class IF_DEALERSTOCK_009_Req{
        @AuraEnabled public String I_CON_TYPE   {get;set;}
        @AuraEnabled public String I_VKORG      {get;set;}
        @AuraEnabled public String I_PLTYP      {get;set;}
        @AuraEnabled public String I_GRADE      {get;set;}
        @AuraEnabled public String I_DATE       {get;set;}

        public IF_DEALERSTOCK_009_Req(){}
    }
    public class IF_DEALERSTOCK_009_Res{
        @AuraEnabled public List<IF_DEALERSTOCK_009_Res_T_RETURN> T_RETURN {get;set;}
        @AuraEnabled public IF_DEALERSTOCK_009_Res_O_RETURN       O_RETURN {get;set;}

        public IF_DEALERSTOCK_009_Res(){
            this.T_RETURN = new List<IF_DEALERSTOCK_009_Res_T_RETURN>();
            this.O_RETURN = new IF_DEALERSTOCK_009_Res_O_RETURN();
        }
    }
    public class IF_DEALERSTOCK_009_Res_T_RETURN{
        @AuraEnabled public String ZZKVGR4      {get;set;}
        @AuraEnabled public String KFRST        {get;set;}
        @AuraEnabled public String KBSTAT       {get;set;}
        @AuraEnabled public String KBETR        {get;set;}
        @AuraEnabled public String KONWA        {get;set;}

        @AuraEnabled public String KRECH        {get;set;}
        @AuraEnabled public String KZBZG        {get;set;}
        @AuraEnabled public String DATAB        {get;set;}
        @AuraEnabled public String DATBI        {get;set;}
        @AuraEnabled public String KZNEP        {get;set;}
        
        @AuraEnabled public String ZTERM        {get;set;}
        @AuraEnabled public String VALDT        {get;set;}
        @AuraEnabled public String VALTG        {get;set;}
        
        public IF_DEALERSTOCK_009_Res_T_RETURN(){}
    }
    public class IF_DEALERSTOCK_009_Res_O_RETURN{
        @AuraEnabled public String TYPE         {get;set;}
        @AuraEnabled public String CODE         {get;set;}
        @AuraEnabled public String MESSAGE      {get;set;}

        public IF_DEALERSTOCK_009_Res_O_RETURN(){}
    }

/** IF-DEALERSTOCK-010
 * New I/F              : ZCRM_SS_RECV_EP_SIMULATION
 * Description          : 대리점 재고 관리 시뮬레이션 
    */
    public class IF_DEALERSTOCK_010_Req {
        @AuraEnabled public IF_DEALERSTOCK_010_Req_I_USERINFO       I_USERINFO  {get;set;}    
        @AuraEnabled public String                                  I_CUST_NO   {get;set;}                                           
        @AuraEnabled public String                                  I_OTHERS    {get;set;}                                       
        @AuraEnabled public List<IF_DEALERSTOCK_010_Req_IT_ITEM>    IT_ITEM     {get;set;}                                           

        public IF_DEALERSTOCK_010_Req(){
            this.I_USERINFO      = new IF_DEALERSTOCK_010_Req_I_USERINFO();
            this.IT_ITEM         = new List<IF_DEALERSTOCK_010_Req_IT_ITEM>();
        }
    }
    public class IF_DEALERSTOCK_010_Req_I_USERINFO {
        @AuraEnabled public String BNAME        {get;set;}
        @AuraEnabled public String RNAME        {get;set;}
        @AuraEnabled public String HIER         {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}
        @AuraEnabled public String LIFNR        {get;set;}

        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}
        @AuraEnabled public String ARBPL        {get;set;}
        
        @AuraEnabled public String PARNR        {get;set;}
        @AuraEnabled public String ENAME        {get;set;}
        @AuraEnabled public String KUNN2        {get;set;}
        @AuraEnabled public String LAND1        {get;set;}
        @AuraEnabled public String LGORT        {get;set;}
        
        @AuraEnabled public String DF_CHK       {get;set;}
        @AuraEnabled public String CO_CHK       {get;set;}

        public IF_DEALERSTOCK_010_Req_I_USERINFO(){}
    }
    public class IF_DEALERSTOCK_010_Req_IT_ITEM {
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}

        public IF_DEALERSTOCK_010_Req_IT_ITEM(){}
    }
    public class IF_DEALERSTOCK_010_Res {
        @AuraEnabled public List<IF_DEALERSTOCK_010_Res_ET_MAT> ET_MAT      {get;set;}
        @AuraEnabled public IF_DEALERSTOCK_010_Res_ES_RETURN    ES_RETURN   {get;set;}    

        public IF_DEALERSTOCK_010_Res(){
            this.ET_MAT     = new List<IF_DEALERSTOCK_010_Res_ET_MAT>();
            this.ES_RETURN  = new IF_DEALERSTOCK_010_Res_ES_RETURN();
        }
    }
    public class IF_DEALERSTOCK_010_Res_ET_MAT {
        @AuraEnabled public String MATNR     {get;set;}      
        @AuraEnabled public String REPNR     {get;set;}      
        @AuraEnabled public String MAKTX     {get;set;}      
        @AuraEnabled public String KPEIN     {get;set;}      
        @AuraEnabled public String KMEIN     {get;set;}      

        @AuraEnabled public String KBETR     {get;set;}      
        @AuraEnabled public String KONWA     {get;set;}      
        @AuraEnabled public String CUQTY     {get;set;}      
        @AuraEnabled public String AVQTY     {get;set;}      
        @AuraEnabled public String NOTCD     {get;set;}      
        
        @AuraEnabled public String NONMV     {get;set;}      
        @AuraEnabled public String KUNNR     {get;set;}      
        @AuraEnabled public String RATE      {get;set;}  
        @AuraEnabled public String HSCODE    {get;set;}      
        @AuraEnabled public String IGST      {get;set;}  
        
        @AuraEnabled public String CGST      {get;set;}  
        @AuraEnabled public String SGST      {get;set;}  
        @AuraEnabled public String OTHER     {get;set;}      
        @AuraEnabled public String NETPR     {get;set;}      

        public IF_DEALERSTOCK_010_Res_ET_MAT(){}
    }
    public class IF_DEALERSTOCK_010_Res_ES_RETURN {
        @AuraEnabled public String TYPE         {get;set;}   
        @AuraEnabled public String ID           {get;set;}   
        @AuraEnabled public String IF_NUMBER    {get;set;}           
        @AuraEnabled public String MESSAGE      {get;set;}       
        @AuraEnabled public String LOG_NO       {get;set;}       

        @AuraEnabled public String LOG_MSG_NO   {get;set;}           
        @AuraEnabled public String MESSAGE_V1   {get;set;}           
        @AuraEnabled public String MESSAGE_V2   {get;set;}           
        @AuraEnabled public String MESSAGE_V3   {get;set;}           
        @AuraEnabled public String MESSAGE_V4   {get;set;}           
        
        @AuraEnabled public String PARAMETER    {get;set;}           
        @AuraEnabled public String ROW          {get;set;}   
        @AuraEnabled public String FIELD        {get;set;}       
        @AuraEnabled public String IF_SYSTEM    {get;set;}           

        public IF_DEALERSTOCK_010_Res_ES_RETURN(){}
    }

/** IF-DEALERSTOCK-011
 * New I/F              : ZCRM_EP_SAFETY_STOCK_ADD
 * Description          : 기타입고
    */
    public class IF_DEALERSTOCK_011_Req {
        @AuraEnabled public IF_DEALERSTOCK_011_Req_I_USERINFO   I_USERINFO  {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_011_Req_IT_MAT> IT_MAT      {get;set;}

        public IF_DEALERSTOCK_011_Req(){
            this.I_USERINFO     = new IF_DEALERSTOCK_011_Req_I_USERINFO();
            this.IT_MAT         = new List<IF_DEALERSTOCK_011_Req_IT_MAT>();
        }
    }
    public class IF_DEALERSTOCK_011_Req_I_USERINFO{
        @AuraEnabled public String BNAME        {get;set;}
        @AuraEnabled public String RNAME        {get;set;}
        @AuraEnabled public String HIER         {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}
        @AuraEnabled public String LIFNR        {get;set;}

        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}
        @AuraEnabled public String ARBPL        {get;set;}
        
        @AuraEnabled public String PARNR        {get;set;}
        @AuraEnabled public String ENAME        {get;set;}
        @AuraEnabled public String KUNN2        {get;set;}
        @AuraEnabled public String LAND1        {get;set;}
        @AuraEnabled public String LGORT        {get;set;}
        
        @AuraEnabled public String DF_CHK       {get;set;}
        @AuraEnabled public String CO_CHK       {get;set;}
        
        public IF_DEALERSTOCK_011_Req_I_USERINFO(){}
    }
    public class IF_DEALERSTOCK_011_Req_IT_MAT{
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String STQTY        {get;set;}

        public IF_DEALERSTOCK_011_Req_IT_MAT(){}
    }
    public class IF_DEALERSTOCK_011_Res {
        @AuraEnabled public List<IF_DEALERSTOCK_011_Res_ET_LIST> ET_LIST {get;set;}

        public IF_DEALERSTOCK_011_Res(){}
    }
    public class IF_DEALERSTOCK_011_Res_ET_LIST {
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String STQTY        {get;set;}
        @AuraEnabled public String CUQTY        {get;set;}
        @AuraEnabled public String REQTY        {get;set;}

        @AuraEnabled public String MEINS        {get;set;}
        @AuraEnabled public String THREAD       {get;set;}
        @AuraEnabled public String NETPR        {get;set;}
        @AuraEnabled public String DISPR        {get;set;}
        @AuraEnabled public String WAERS        {get;set;}
        
        @AuraEnabled public String LOC          {get;set;}

        public IF_DEALERSTOCK_011_Res_ET_LIST(){}
    }

/** IF-DEALERSTOCK-012
 * New I/F              : ZCRM_EP_SAFETY_STOCK_ADD2
 * Description          : 기타출고
    */
    public class IF_DEALERSTOCK_012_Req {
        @AuraEnabled public IF_DEALERSTOCK_012_Req_I_USERINFO   I_USERINFO  {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_012_Req_IT_MAT> IT_MAT      {get;set;}

        public IF_DEALERSTOCK_012_Req(){
            this.I_USERINFO     = new IF_DEALERSTOCK_012_Req_I_USERINFO();
            this.IT_MAT         = new List<IF_DEALERSTOCK_012_Req_IT_MAT>();
        }
    }
    public class IF_DEALERSTOCK_012_Req_I_USERINFO{
        @AuraEnabled public String BNAME        {get;set;}
        @AuraEnabled public String RNAME        {get;set;}
        @AuraEnabled public String HIER         {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}
        @AuraEnabled public String LIFNR        {get;set;}

        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}
        @AuraEnabled public String ARBPL        {get;set;}
        
        @AuraEnabled public String PARNR        {get;set;}
        @AuraEnabled public String ENAME        {get;set;}
        @AuraEnabled public String KUNN2        {get;set;}
        @AuraEnabled public String LAND1        {get;set;}
        @AuraEnabled public String LGORT        {get;set;}
        
        @AuraEnabled public String DF_CHK       {get;set;}
        @AuraEnabled public String CO_CHK       {get;set;}
        
        public IF_DEALERSTOCK_012_Req_I_USERINFO(){}
    }
    public class IF_DEALERSTOCK_012_Req_IT_MAT{
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String STQTY        {get;set;}

        public IF_DEALERSTOCK_012_Req_IT_MAT(){}
    }
    public class IF_DEALERSTOCK_012_Res {
        @AuraEnabled public List<IF_DEALERSTOCK_012_Res_ET_LIST> ET_LIST {get;set;}

        public IF_DEALERSTOCK_012_Res(){}
    }
    public class IF_DEALERSTOCK_012_Res_ET_LIST {
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String STQTY        {get;set;}
        @AuraEnabled public String CUQTY        {get;set;}
        @AuraEnabled public String REQTY        {get;set;}

        @AuraEnabled public String MEINS        {get;set;}
        @AuraEnabled public String THREAD       {get;set;}
        @AuraEnabled public String NETPR        {get;set;}
        @AuraEnabled public String DISPR        {get;set;}
        @AuraEnabled public String WAERS        {get;set;}
        
        @AuraEnabled public String LOC          {get;set;}

        public IF_DEALERSTOCK_012_Res_ET_LIST(){}
    }

/** IF-DEALERSTOCK-014
 * New I/F              : ZCRM_SL_RECV_EP_GR_LIST_TO_CAN
 * Description          : 입고취소
    */
    public class IF_DEALERSTOCK_014_Req {
        @AuraEnabled public IF_DEALERSTOCK_014_Req_IS_INPUT     IS_INPUT    {get;set;}
        @AuraEnabled public IF_DEALERSTOCK_014_Req_I_USERINFO   I_USERINFO  {get;set;}
        
        public IF_DEALERSTOCK_014_Req(){
            this.IS_INPUT       = new IF_DEALERSTOCK_014_Req_IS_INPUT();
            this.I_USERINFO     = new IF_DEALERSTOCK_014_Req_I_USERINFO();
        }
    }
    public class IF_DEALERSTOCK_014_Req_IS_INPUT{
        @AuraEnabled public String TYPE         {get;set;}
        @AuraEnabled public String DOCNO        {get;set;}
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String DATE_F       {get;set;}
        @AuraEnabled public String DATE_T       {get;set;}

        public IF_DEALERSTOCK_014_Req_IS_INPUT(){}
    }
    public class IF_DEALERSTOCK_014_Req_I_USERINFO{
        @AuraEnabled public String BNAME        {get;set;}
        @AuraEnabled public String RNAME        {get;set;}
        @AuraEnabled public String HIER         {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}
        @AuraEnabled public String LIFNR        {get;set;}

        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}
        @AuraEnabled public String ARBPL        {get;set;}
        
        @AuraEnabled public String PARNR        {get;set;}
        @AuraEnabled public String ENAME        {get;set;}
        @AuraEnabled public String KUNN2        {get;set;}
        @AuraEnabled public String LAND1        {get;set;}
        @AuraEnabled public String LGORT        {get;set;}
        
        @AuraEnabled public String DF_CHK       {get;set;}
        @AuraEnabled public String CO_CHK       {get;set;}

        public IF_DEALERSTOCK_014_Req_I_USERINFO(){}
    }
    public class IF_DEALERSTOCK_014_Res{
        @AuraEnabled public IF_DEALERSTOCK_014_Res_ES_RETURN        ES_RETURN   {get;set;}
        @AuraEnabled public List<IF_DEALERSTOCK_014_Res_ET_LIST>    ET_LIST     {get;set;}

        public IF_DEALERSTOCK_014_Res(){}
    }
    public class IF_DEALERSTOCK_014_Res_ES_RETURN{
        @AuraEnabled public String TYPE         {get;set;}
        @AuraEnabled public String CODE         {get;set;}
        @AuraEnabled public String MESSAGE      {get;set;}

        public IF_DEALERSTOCK_014_Res_ES_RETURN(){}
    }
    public class IF_DEALERSTOCK_014_Res_ET_LIST{
        @AuraEnabled public String DOCNO        {get;set;}
        @AuraEnabled public String DOCIT        {get;set;}
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String THREAD       {get;set;}

        @AuraEnabled public String LOC          {get;set;}
        @AuraEnabled public String CUQTY        {get;set;}
        @AuraEnabled public String MENGE        {get;set;}
        @AuraEnabled public String CAQTY        {get;set;}
        @AuraEnabled public String RMQTY        {get;set;}
        
        @AuraEnabled public String MEINS        {get;set;}
        @AuraEnabled public String ERDAT        {get;set;}
        @AuraEnabled public String NETPR        {get;set;}
        @AuraEnabled public String DISPR        {get;set;}
        @AuraEnabled public String DMBTR        {get;set;}
        
        @AuraEnabled public String WAERS        {get;set;}
        @AuraEnabled public String RETNO        {get;set;}

        public IF_DEALERSTOCK_014_Res_ET_LIST(){}
    }

/** IF-DEALERSTOCK-015
 * New I/F              : ZCRM_CS_DEALERSTOCK_GI_INF_DSP
 * Description          : 정산완료 STATUS를 업데이트
    */
    public class IF_DEALERSTOCK_015_Req {
        @AuraEnabled public String I_USERID ;
        @AuraEnabled public String I_STAT   ;
        @AuraEnabled public IF_DEALERSTOCK_015_Req_I_ORG            I_ORG   ;
        @AuraEnabled public List<IF_DEALERSTOCK_015_Req_IT_LIST>    IT_LIST ;
        
        public IF_DEALERSTOCK_015_Req(){
            this.I_ORG          = new IF_DEALERSTOCK_015_Req_I_ORG();
            this.IT_LIST        = new List<IF_DEALERSTOCK_015_Req_IT_LIST>();
        }
    }


    public class IF_DEALERSTOCK_015_Req_I_ORG{
        public IF_DEALERSTOCK_015_Req_I_ORG(){}
        @AuraEnabled public String VKORG;
        @AuraEnabled public String VTWEG;
        @AuraEnabled public String SPART;
        @AuraEnabled public String WERKS;
        @AuraEnabled public String ARBPL;
        @AuraEnabled public String AMSCCTL;
    }

    public class IF_DEALERSTOCK_015_Req_IT_LIST{
        public IF_DEALERSTOCK_015_Req_IT_LIST(){}
        @AuraEnabled public String AUFNR;
        @AuraEnabled public String POSNR;
        @AuraEnabled public String BMENG;
        @AuraEnabled public String PDATE;
        @AuraEnabled public String PTIME;
        @AuraEnabled public String WRAMT;
        @AuraEnabled public String WAERS;
        @AuraEnabled public String ERSDA;
    }

    public class IF_DEALERSTOCK_015_Res{
        public IF_DEALERSTOCK_015_Res(){
            this.ES_RETURN = new IF_DEALERSTOCK_015_Res_ES_RETURN();
        }
        
        @AuraEnabled public IF_DEALERSTOCK_015_Res_ES_RETURN ES_RETURN ;  
    }

    public class IF_DEALERSTOCK_015_Res_ES_RETURN{
        public IF_DEALERSTOCK_015_Res_ES_RETURN(){}
        @AuraEnabled public String TYPE ;
        @AuraEnabled public String ID ;
        @AuraEnabled public String IF_NUMBER ;
        @AuraEnabled public String MESSAGE ;
        @AuraEnabled public String LOG_NO ;
        @AuraEnabled public String LOG_MSG_NO ;
        @AuraEnabled public String MESSAGE_V1 ;
        @AuraEnabled public String MESSAGE_V2 ;
        @AuraEnabled public String MESSAGE_V3 ;
        @AuraEnabled public String MESSAGE_V4 ;
        @AuraEnabled public String PARAMETER ;
        @AuraEnabled public String ROW ;
        @AuraEnabled public String FIELD ;
        @AuraEnabled public String IF_SYSTEM ;
    }


}