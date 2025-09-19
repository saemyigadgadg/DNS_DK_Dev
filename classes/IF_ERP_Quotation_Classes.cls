public with sharing class IF_ERP_Quotation_Classes {
    public IF_ERP_Quotation_Classes() {}


    
/** IF-OPTY-019  
    */  
    /**
         * Apex Class           : IF_ERP_Quotation
         * Wrapper Class        : IF_ERP_Quotation_Classes
         * Wrapper Name         : IF-OPTY-019  
         * SFDC interface Id    : IF_OPTY_019
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_MS_QT_CRE
         * Description          : Quotation 생성 CRM에서 Quotation 생성 후 ERP에 전송 
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
        */    
        public class IF_OPTY_019_Req {
          public IF_OPTY_019_Req(){
            this.T_VARIANT        = new List<IF_OPTY_019_Req_T_VARIANT>();
            this.T_ITEM           = new List<IF_OPTY_019_Req_T_ITEM>();
            this.T_PRICING_ADD    = new List<IF_OPTY_019_Req_T_PRICING_ADD>();
            this.T_PRICING_RATE   = new List<IF_OPTY_019_Req_T_PRICING_RATE>();
            this.T_PRICING        = new List<IF_OPTY_019_Req_T_PRICING>();
          } 
            @AuraEnabled public String I_AUART      {get;set;}
            @AuraEnabled public String I_VKORG      {get;set;}
            @AuraEnabled public String I_VTWEG      {get;set;}
            @AuraEnabled public String I_SPART      {get;set;}
            @AuraEnabled public String I_VKBUR      {get;set;}

            @AuraEnabled public String I_GSBER      {get;set;}
            @AuraEnabled public String I_KUNNR      {get;set;}
            @AuraEnabled public String I_KUNWE      {get;set;}
            @AuraEnabled public String I_KONDA      {get;set;}
            @AuraEnabled public String I_BNDDT      {get;set;}
            
            @AuraEnabled public String I_KWMENG     {get;set;}
            @AuraEnabled public String I_WAERS      {get;set;}
            @AuraEnabled public String I_SDATE      {get;set;}
            @AuraEnabled public String I_CUST_GRP1  {get;set;}
            @AuraEnabled public String I_CUST_GRP2  {get;set;}
            
            @AuraEnabled public String I_CUST_GRP3  {get;set;}
            @AuraEnabled public String I_VBELN      {get;set;}
            @AuraEnabled public String I_VDATU      {get;set;}
            @AuraEnabled public String I_KUNNR2     {get;set;}
            @AuraEnabled public String TESTRUN      {get;set;}

            @AuraEnabled public String I_ZZAPPNO    {get;set;}
            @AuraEnabled public String I_IQ_CHK     {get;set;}
            @AuraEnabled public String I_ZTERM      {get;set;}
            @AuraEnabled public String I_INCO1      {get;set;}
            @AuraEnabled public String I_INCO2      {get;set;}

            @AuraEnabled public String I_ZZWARRPER      {get;set;}
            @AuraEnabled public String I_ZZPERUNIT      {get;set;}
            @AuraEnabled public String I_ZZWARHRS       {get;set;}
            @AuraEnabled public String I_ZZWARRDAT      {get;set;}
            @AuraEnabled public String I_ZZPR_WAR       {get;set;}
            
            @AuraEnabled public String I_ZZCOVERAGE     {get;set;}
            @AuraEnabled public String I_ZZCOVERAGE_B   {get;set;}

            @AuraEnabled public String I_ZZKVGR4        {get;set;}

            @AuraEnabled public List<IF_OPTY_019_Req_T_VARIANT>       T_VARIANT       {get;set;} 
            @AuraEnabled public List<IF_OPTY_019_Req_T_ITEM>          T_ITEM          {get;set;} 
            @AuraEnabled public List<IF_OPTY_019_Req_T_PRICING_ADD>   T_PRICING_ADD   {get;set;} 

            @AuraEnabled public List<IF_OPTY_019_Req_T_PRICING_RATE>  T_PRICING_RATE  {get;set;} 
            @AuraEnabled public List<IF_OPTY_019_Req_T_PRICING>       T_PRICING       {get;set;} 
        }
        public class IF_OPTY_019_Req_T_VARIANT { 
          public IF_OPTY_019_Req_T_VARIANT(){}
          @AuraEnabled public String POSNR {get;set;} 
          @AuraEnabled public String ATINN {get;set;} 
          @AuraEnabled public String ATNAM {get;set;} 
          @AuraEnabled public String ATBEZ {get;set;} 
          @AuraEnabled public String ATWRT {get;set;} 
    
          @AuraEnabled public String ATWTB {get;set;} 
        }
        public class IF_OPTY_019_Req_T_ITEM { 
          public IF_OPTY_019_Req_T_ITEM(){}
          @AuraEnabled public String POSNR {get;set;} 
          @AuraEnabled public String PARENT {get;set;} 
          @AuraEnabled public String MAKTX {get;set;} 
          @AuraEnabled public String MATNR {get;set;} 
          @AuraEnabled public String ARKTX {get;set;} 
    
          @AuraEnabled public String KWMENG {get;set;} 
          @AuraEnabled public String REQ_DATE {get;set;} 
          @AuraEnabled public String VRKME {get;set;} 
          @AuraEnabled public String NETPR {get;set;} 
          @AuraEnabled public String WAERK {get;set;} 
    
          @AuraEnabled public String WERKS {get;set;} 
          @AuraEnabled public String CHECK {get;set;} 
          @AuraEnabled public String EQUIP_CHECK {get;set;} 
          @AuraEnabled public String MWST  {get;set;} 
          @AuraEnabled public String PSTYV {get;set;} 
    
          @AuraEnabled public String NOTE  {get;set;} 
          @AuraEnabled public String NETWR {get;set;} 
          @AuraEnabled public String VTEXT {get;set;} 
          @AuraEnabled public String MWSBP {get;set;} 
          @AuraEnabled public String ZZSQCOD {get;set;} 
    
          @AuraEnabled public String ZZSQTITLE {get;set;} 
          @AuraEnabled public String ZZDEALDT {get;set;} 
          @AuraEnabled public String INPUT_P {get;set;} 
          @AuraEnabled public String INPUT_A {get;set;} 
          @AuraEnabled public String BUILT_P {get;set;} 
    
          @AuraEnabled public String BUILT_A {get;set;} 
          @AuraEnabled public String TEST_P {get;set;} 
          @AuraEnabled public String TEST_A {get;set;} 
          @AuraEnabled public String PAINT_P {get;set;} 
          @AuraEnabled public String PAINT_A {get;set;} 
    
          @AuraEnabled public String RTS_P {get;set;} 
          @AuraEnabled public String RTS_A {get;set;} 
          @AuraEnabled public String DECK_P {get;set;} 
          @AuraEnabled public String DECK_A {get;set;} 
          @AuraEnabled public String EDATU {get;set;} 
        }
        public class IF_OPTY_019_Req_T_PRICING_ADD {
            @AuraEnabled public String POSNR            {get;set;}
            @AuraEnabled public String KSCHL            {get;set;}
            @AuraEnabled public String VTEXT            {get;set;}
            @AuraEnabled public String KWERT            {get;set;}
            @AuraEnabled public String WAERK            {get;set;}

            @AuraEnabled public String ZISI_DISPLAY     {get;set;}
            @AuraEnabled public String STUNR            {get;set;}
            @AuraEnabled public String ZAEHK            {get;set;}
            @AuraEnabled public String VISIBLE          {get;set;}
            @AuraEnabled public String VISIBLE_01       {get;set;}
            
            @AuraEnabled public String UPDATEFLAG       {get;set;}
            
            public IF_OPTY_019_Req_T_PRICING_ADD(){}
        }
        public class IF_OPTY_019_Req_T_PRICING_RATE{
            @AuraEnabled public String POSNR            {get;set;}
            @AuraEnabled public String KSCHL            {get;set;}
            @AuraEnabled public String VTEXT            {get;set;}
            @AuraEnabled public String RATE             {get;set;}
            @AuraEnabled public String WAERK            {get;set;}
            
            @AuraEnabled public String STUNR            {get;set;}
            @AuraEnabled public String ZAEHK            {get;set;}
            @AuraEnabled public String KWERT            {get;set;}
            @AuraEnabled public String NWAERK           {get;set;}
            @AuraEnabled public String UPDATEFLAG       {get;set;}

            public IF_OPTY_019_Req_T_PRICING_RATE(){}
        }
        public class IF_OPTY_019_Req_T_PRICING {
            @AuraEnabled public String POSNR   {get;set;} 
            @AuraEnabled public String KSCHL   {get;set;} 
            @AuraEnabled public String VTEXT   {get;set;} 
            @AuraEnabled public String KWERT   {get;set;} 
            @AuraEnabled public String WAERK   {get;set;} 
            @AuraEnabled public String VISIBLE {get;set;} 
        }


    /** RESPONSE 
      */          
        public class IF_OPTY_019_Res { 
          public IF_OPTY_019_Res(){}
          @AuraEnabled public String I_VBELN  {get;set;} // mapping 용 key

          @AuraEnabled public String O_RECODE {get;set;} 
          @AuraEnabled public String O_REMSG  {get;set;} 
          @AuraEnabled public String O_VBELN  {get;set;} 
          @AuraEnabled public String O_EDATU  {get;set;} 
          @AuraEnabled public String O_TOTAMT {get;set;} 

          @AuraEnabled public IF_OPTY_019_Res_O_NET_VALUE           O_NET_VALUE     {get;set;}
          @AuraEnabled public List<IF_OPTY_019_Res_T_PRICING>       T_PRICING       {get;set;}
          @AuraEnabled public List<IF_OPTY_019_Res_T_PRICING_ADD>   T_PRICING_ADD   {get;set;}
          @AuraEnabled public List<IF_OPTY_019_Res_T_PRICING_RATE>  T_PRICING_RATE  {get;set;}
          @AuraEnabled public List<IF_OPTY_019_Res_T_OPTION>        T_OPTION        {get;set;}

          @AuraEnabled public List<IF_OPTY_019_Res_T_PRICING_EX>    T_PRICING_EX    {get;set;}
          @AuraEnabled public List<IF_OPTY_019_Res_T_COND_EX>       T_COND_EX       {get;set;}
          @AuraEnabled public List<IF_OPTY_019_Res_T_COND_ELMT>     T_COND_ELMT     {get;set;}
        }
        public class IF_OPTY_019_Res_O_NET_VALUE {
          public IF_OPTY_019_Res_O_NET_VALUE(){}

          @AuraEnabled public String POSNR    {get;set;}
          @AuraEnabled public String KSCHL    {get;set;}
          @AuraEnabled public String VTEXT    {get;set;}
          @AuraEnabled public String KWERT    {get;set;}
          @AuraEnabled public String WAERK    {get;set;}

          @AuraEnabled public String VISIBLE  {get;set;}
        }
        public class IF_OPTY_019_Res_T_PRICING{
          public IF_OPTY_019_Res_T_PRICING(){}

          @AuraEnabled public String POSNR    {get;set;}
          @AuraEnabled public String KSCHL    {get;set;}
          @AuraEnabled public String VTEXT    {get;set;}
          @AuraEnabled public String KWERT    {get;set;}
          @AuraEnabled public String WAERK    {get;set;}

          @AuraEnabled public String VISIBLE  {get;set;}
        }
        public class IF_OPTY_019_Res_T_PRICING_ADD{
          public IF_OPTY_019_Res_T_PRICING_ADD(){}

          @AuraEnabled public String POSNR          {get;set;}
          @AuraEnabled public String KSCHL          {get;set;}
          @AuraEnabled public String VTEXT          {get;set;}
          @AuraEnabled public String KWERT          {get;set;}
          @AuraEnabled public String WAERK          {get;set;}

          @AuraEnabled public String ZISI_DISPLAY   {get;set;}
          @AuraEnabled public String STUNR          {get;set;}
          @AuraEnabled public String ZAEHK          {get;set;}
          @AuraEnabled public String VISIBLE        {get;set;}
          @AuraEnabled public String VISIBLE_01     {get;set;}
          
          @AuraEnabled public String UPDATEFLAG     {get;set;}
        }
        public class IF_OPTY_019_Res_T_PRICING_RATE{
          public IF_OPTY_019_Res_T_PRICING_RATE(){}

          @AuraEnabled public String POSNR          {get;set;}
          @AuraEnabled public String KSCHL          {get;set;}
          @AuraEnabled public String VTEXT          {get;set;}
          @AuraEnabled public String RATE           {get;set;}
          @AuraEnabled public String WAERK          {get;set;}
          
          @AuraEnabled public String STUNR          {get;set;}
          @AuraEnabled public String ZAEHK          {get;set;}
          @AuraEnabled public String KWERT          {get;set;}
          @AuraEnabled public String NWAERK         {get;set;}
          @AuraEnabled public String UPDATEFLAG     {get;set;}
        }
        public class IF_OPTY_019_Res_T_OPTION{
          public IF_OPTY_019_Res_T_OPTION(){}

          @AuraEnabled public String POSNR          {get;set;}
          @AuraEnabled public String KSCHL          {get;set;}
          @AuraEnabled public String VTEXT          {get;set;}
          @AuraEnabled public String KWERT          {get;set;}
          @AuraEnabled public String WAERK          {get;set;}

          @AuraEnabled public String VISIBLE        {get;set;}
        }
        public class IF_OPTY_019_Res_T_PRICING_EX{
          public IF_OPTY_019_Res_T_PRICING_EX(){}

          @AuraEnabled public String POSNR    {get;set;}
          @AuraEnabled public String KSCHL    {get;set;}
          @AuraEnabled public String VTEXT    {get;set;}
          @AuraEnabled public String KBETR    {get;set;}
          @AuraEnabled public String KWERT    {get;set;}

          @AuraEnabled public String WAERK    {get;set;}
          @AuraEnabled public String VISIBLE  {get;set;}
          @AuraEnabled public String GUBUN    {get;set;}
        }
        public class IF_OPTY_019_Res_T_COND_EX{
          public IF_OPTY_019_Res_T_COND_EX(){}

          @AuraEnabled public String ITM_NUMBER    {get;set;}
          @AuraEnabled public String COND_ST_NO    {get;set;}
          @AuraEnabled public String COND_COUNT    {get;set;}
          @AuraEnabled public String COND_TYPE     {get;set;}
          @AuraEnabled public String COND_VALUE    {get;set;}

          @AuraEnabled public String IF_CURRENCY   {get;set;}
          @AuraEnabled public String COND_UNIT     {get;set;}
          @AuraEnabled public String COND_P_UNT    {get;set;}
          @AuraEnabled public String CURR_ISO      {get;set;}
          @AuraEnabled public String CD_UNT_ISO    {get;set;}

          @AuraEnabled public String REFOBJTYPE    {get;set;}
          @AuraEnabled public String REFOBJKEY     {get;set;}
          @AuraEnabled public String REFLOGSYS     {get;set;}
          @AuraEnabled public String APPLICATIO    {get;set;}
          @AuraEnabled public String CONPRICDAT    {get;set;}

          @AuraEnabled public String CALCTYPCON    {get;set;}
          @AuraEnabled public String CONBASEVAL    {get;set;}
          @AuraEnabled public String CONEXCHRAT    {get;set;}
          @AuraEnabled public String NUMCONVERT    {get;set;}
          @AuraEnabled public String DENOMINATO    {get;set;}

          @AuraEnabled public String CONDTYPE      {get;set;}
          @AuraEnabled public String STAT_CON      {get;set;}
          @AuraEnabled public String SCALETYPE     {get;set;}
          @AuraEnabled public String ACCRUALS      {get;set;}
          @AuraEnabled public String CONINVOLST    {get;set;}

          @AuraEnabled public String CONDORIGIN    {get;set;}
          @AuraEnabled public String GROUPCOND     {get;set;}
          @AuraEnabled public String COND_UPDAT    {get;set;}
          @AuraEnabled public String ACCESS_SEQ    {get;set;}
          @AuraEnabled public String CONDCOUNT     {get;set;}

          @AuraEnabled public String ROUNDOFFDI    {get;set;}
          @AuraEnabled public String CONDVALUE     {get;set;}
          @AuraEnabled public String CURRENCY_2    {get;set;}
          @AuraEnabled public String CURR_ISO_2    {get;set;}
          @AuraEnabled public String CONDCNTRL     {get;set;}

          @AuraEnabled public String CONDISACTI    {get;set;}
          @AuraEnabled public String CONDCLASS     {get;set;}
          @AuraEnabled public String FACTBASVAL    {get;set;}
          @AuraEnabled public String SCALEBASIN    {get;set;}
          @AuraEnabled public String SCALBASVAL    {get;set;}

          @AuraEnabled public String UNITMEASUR    {get;set;}
          @AuraEnabled public String ISO_UNIT      {get;set;}
          @AuraEnabled public String CURRENCKEY    {get;set;}
          @AuraEnabled public String CURRENISO     {get;set;}
          @AuraEnabled public String CONDINCOMP    {get;set;}

          @AuraEnabled public String CONDCONFIG    {get;set;}
          @AuraEnabled public String CONDCHAMAN    {get;set;}
          @AuraEnabled public String COND_NO       {get;set;}
          @AuraEnabled public String TAX_CODE      {get;set;}
          @AuraEnabled public String VARCOND       {get;set;}

          @AuraEnabled public String ACCOUNTKEY    {get;set;}
          @AuraEnabled public String ACCOUNT_KE    {get;set;}
          @AuraEnabled public String WT_WITHCD     {get;set;}
          @AuraEnabled public String STRUCTCOND    {get;set;}
          @AuraEnabled public String FACTCONBAS    {get;set;}

          @AuraEnabled public String CONDCOINHD    {get;set;}
          @AuraEnabled public String VCTEXT        {get;set;}
          @AuraEnabled public String MATNR_AC      {get;set;}
          @AuraEnabled public String ZZSQCOD       {get;set;}
        }
        public class IF_OPTY_019_Res_T_COND_ELMT{
            public IF_OPTY_019_Res_T_COND_ELMT(){}

            @AuraEnabled public String KAPPL        {get;set;}
            @AuraEnabled public String KSCHL        {get;set;}
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}
            @AuraEnabled public String WAERK        {get;set;}

            @AuraEnabled public String ZZKVGR4      {get;set;}
            @AuraEnabled public String ZTERM        {get;set;}
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String KBETR        {get;set;}
        }
      
/** SFDC interface Id   : IF-OPTY-020
 * New I/F              : ZCRM_SD_MS_QT_CHG
 * Description          : Quotation 수정 (CRM -> ERP)
    */
    public class IF_OPTY_020_Req{
        @AuraEnabled public String I_VBELN      {get;set;}
        @AuraEnabled public String I_AUART      {get;set;}
        @AuraEnabled public String I_VKORG      {get;set;}
        @AuraEnabled public String I_VTWEG      {get;set;}
        @AuraEnabled public String I_SPART      {get;set;}

        @AuraEnabled public String I_VKBUR      {get;set;}
        @AuraEnabled public String I_GSBER      {get;set;}
        @AuraEnabled public String I_KUNNR      {get;set;}
        @AuraEnabled public String I_KUNWE      {get;set;}
        @AuraEnabled public String I_KONDA      {get;set;}
        
        @AuraEnabled public String I_BNDDT      {get;set;}
        @AuraEnabled public String I_KWMENG     {get;set;}
        @AuraEnabled public String I_WAERS      {get;set;}
        @AuraEnabled public String I_SDATE      {get;set;}
        @AuraEnabled public String I_CUST_GRP1  {get;set;}

        @AuraEnabled public String I_CUST_GRP2  {get;set;}
        @AuraEnabled public String I_CUST_GRP3  {get;set;}
        @AuraEnabled public String I_VDATU      {get;set;}
        @AuraEnabled public String I_KUNNR2     {get;set;}
        @AuraEnabled public String TESTRUN      {get;set;}

        @AuraEnabled public String I_ZZAPPNO    {get;set;}
        @AuraEnabled public String I_IQ_CHK     {get;set;}
        @AuraEnabled public String I_ZTERM      {get;set;}
        @AuraEnabled public String I_INCO1      {get;set;}
        @AuraEnabled public String I_INCO2      {get;set;}
        
        @AuraEnabled public List<IF_OPTY_020_Req_T_VARIANT> T_VARIANT   {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Req_T_ITEM>    T_ITEM      {get;set;}

        // 2025.01.07 필드 추가
        @AuraEnabled public String I_ZZWARRPER      {get;set;}
        @AuraEnabled public String I_ZZPERUNIT      {get;set;}
        @AuraEnabled public String I_ZZWARHRS       {get;set;}
        @AuraEnabled public String I_ZZWARRDAT      {get;set;}
        @AuraEnabled public String I_ZZPR_WAR       {get;set;}

        @AuraEnabled public String I_ZZCOVERAGE     {get;set;}
        @AuraEnabled public String I_ZZCOVERAGE_B   {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Req_T_PRICING_ADD>   T_PRICING_ADD   {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Req_T_PRICING_RATE>  T_PRICING_RATE  {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Req_T_PRICING>       T_PRICING       {get;set;} 
        // 2025.01.07 필드 추가
      
        public IF_OPTY_020_Req(){
          this.T_VARIANT        = new List<IF_OPTY_020_Req_T_VARIANT>();
          this.T_ITEM           = new List<IF_OPTY_020_Req_T_ITEM>();
          this.T_PRICING_ADD    = new List<IF_OPTY_020_Req_T_PRICING_ADD>();
          this.T_PRICING_RATE   = new List<IF_OPTY_020_Req_T_PRICING_RATE>();
          this.T_PRICING        = new List<IF_OPTY_020_Req_T_PRICING>();
        }
    }
    public class IF_OPTY_020_Req_T_VARIANT{
        @AuraEnabled public String POSNR    {get;set;}    
        @AuraEnabled public String ATINN    {get;set;}    
        @AuraEnabled public String ATNAM    {get;set;}    
        @AuraEnabled public String ATBEZ    {get;set;}    
        @AuraEnabled public String ATWRT    {get;set;}

        @AuraEnabled public String ATWTB    {get;set;}

        public IF_OPTY_020_Req_T_VARIANT(){}
    }
    public class IF_OPTY_020_Req_T_ITEM{
        @AuraEnabled public String POSNR        {get;set;}        
        @AuraEnabled public String PARENT       {get;set;}        
        @AuraEnabled public String MAKTX        {get;set;}        
        @AuraEnabled public String MATNR        {get;set;}        
        @AuraEnabled public String ARKTX        {get;set;}

        @AuraEnabled public String KWMENG       {get;set;}        
        @AuraEnabled public String REQ_DATE     {get;set;}        
        @AuraEnabled public String VRKME        {get;set;}        
        @AuraEnabled public String NETPR        {get;set;}        
        @AuraEnabled public String WAERK        {get;set;}        
        
        @AuraEnabled public String WERKS        {get;set;}        
        @AuraEnabled public String CHECK        {get;set;}        
        @AuraEnabled public String EQUIP_CHECK  {get;set;}            
        @AuraEnabled public String MWST         {get;set;}    
        @AuraEnabled public String PSTYV        {get;set;}        
        
        @AuraEnabled public String NOTE         {get;set;}    
        @AuraEnabled public String NETWR        {get;set;}        
        @AuraEnabled public String VTEXT        {get;set;}        
        @AuraEnabled public String MWSBP        {get;set;}        
        @AuraEnabled public String ZZSQCOD      {get;set;}        
        
        @AuraEnabled public String ZZSQTITLE    {get;set;}            
        @AuraEnabled public String ZZDEALDT     {get;set;}        
        @AuraEnabled public String INPUT_P      {get;set;}        
        @AuraEnabled public String INPUT_A      {get;set;}        
        @AuraEnabled public String BUILT_P      {get;set;}        
        
        @AuraEnabled public String BUILT_A      {get;set;}        
        @AuraEnabled public String TEST_P       {get;set;}        
        @AuraEnabled public String TEST_A       {get;set;}        
        @AuraEnabled public String PAINT_P      {get;set;}        
        @AuraEnabled public String PAINT_A      {get;set;}        
        
        @AuraEnabled public String RTS_P        {get;set;}        
        @AuraEnabled public String RTS_A        {get;set;}        
        @AuraEnabled public String DECK_P       {get;set;}        
        @AuraEnabled public String DECK_A       {get;set;}        
        @AuraEnabled public String EDATU        {get;set;}        
        
        @AuraEnabled public String UPDATEFLAG   {get;set;}            

        public IF_OPTY_020_Req_T_ITEM(){}
    }
    public class IF_OPTY_020_Req_T_PRICING_ADD{
        @AuraEnabled public String POSNR            {get;set;}
        @AuraEnabled public String KSCHL            {get;set;}
        @AuraEnabled public String VTEXT            {get;set;}
        @AuraEnabled public String KWERT            {get;set;}
        @AuraEnabled public String WAERK            {get;set;}

        @AuraEnabled public String ZISI_DISPLAY     {get;set;}
        @AuraEnabled public String STUNR            {get;set;}
        @AuraEnabled public String ZAEHK            {get;set;}
        @AuraEnabled public String VISIBLE          {get;set;}
        @AuraEnabled public String VISIBLE_01       {get;set;}
        
        @AuraEnabled public String UPDATEFLAG       {get;set;}

        public IF_OPTY_020_Req_T_PRICING_ADD(){}
    }
    public class IF_OPTY_020_Req_T_PRICING_RATE{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String KSCHL        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String RATE         {get;set;}
        @AuraEnabled public String WAERK        {get;set;}

        @AuraEnabled public String STUNR        {get;set;}
        @AuraEnabled public String ZAEHK        {get;set;}
        @AuraEnabled public String KWERT        {get;set;}
        @AuraEnabled public String NWAERK       {get;set;}
        @AuraEnabled public String UPDATEFLAG   {get;set;}

        public IF_OPTY_020_Req_T_PRICING_RATE(){}
    }
    public class IF_OPTY_020_Req_T_PRICING {
      @AuraEnabled public String POSNR   {get;set;} 
      @AuraEnabled public String KSCHL   {get;set;} 
      @AuraEnabled public String VTEXT   {get;set;} 
      @AuraEnabled public String KWERT   {get;set;} 
      @AuraEnabled public String WAERK   {get;set;} 
      @AuraEnabled public String VISIBLE {get;set;} 
    }
    
    public class IF_OPTY_020_Res{
        @AuraEnabled public String O_RECODE   {get;set;}             
        @AuraEnabled public String O_REMSG    {get;set;}         
        @AuraEnabled public String O_VBELN    {get;set;}         
        @AuraEnabled public String O_EDATU    {get;set;}         
        @AuraEnabled public String O_TOTAMT   {get;set;}                     

        @AuraEnabled public IF_OPTY_020_Res_O_NET_VALUE             O_NET_VALUE     {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Res_T_PRICING>         T_PRICING       {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Res_T_PRICING_ADD>     T_PRICING_ADD   {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Res_T_PRICING_RATE>    T_PRICING_RATE  {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Res_T_OPTION>          T_OPTION        {get;set;}
        
        @AuraEnabled public List<IF_OPTY_020_Res_T_PRICING_EX>      T_PRICING_EX    {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Res_T_COND_EX>         T_COND_EX       {get;set;}
        @AuraEnabled public List<IF_OPTY_020_Res_T_COND_ELMT>       T_COND_ELMT     {get;set;}

        public IF_OPTY_020_Res(){}
    }
    public class IF_OPTY_020_Res_O_NET_VALUE{
        @AuraEnabled public String NETPR          {get;set;}              
        @AuraEnabled public String NETWR          {get;set;}              
        @AuraEnabled public String MWST           {get;set;}          
        @AuraEnabled public String WAERK          {get;set;}              
        @AuraEnabled public String NETWR_CH       {get;set;}     

        @AuraEnabled public String NETWR_CC06     {get;set;}                  
        @AuraEnabled public String CB01_INFO1     {get;set;}                  
        @AuraEnabled public String CB01_TAXINFO   {get;set;}                  
        @AuraEnabled public String CI06_INFO1     {get;set;}                  
        @AuraEnabled public String CI06_TAXINFO   {get;set;}                  
        
        @AuraEnabled public String CC06_INFO1     {get;set;}                  
        @AuraEnabled public String CC06_TAXINFO   {get;set;}                  
        @AuraEnabled public String LP_BM          {get;set;}              
        @AuraEnabled public String LP_OP          {get;set;}              
        @AuraEnabled public String LP_SUM         {get;set;}              
        
        @AuraEnabled public String PROMO_PRC      {get;set;}                  

        public IF_OPTY_020_Res_O_NET_VALUE(){}
    }
    public class IF_OPTY_020_Res_T_PRICING{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String KSCHL        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String KWERT        {get;set;}
        @AuraEnabled public String WAERK        {get;set;}

        @AuraEnabled public String VISIBLE      {get;set;}

        public IF_OPTY_020_Res_T_PRICING(){}
    }
    public class IF_OPTY_020_Res_T_PRICING_ADD{
        @AuraEnabled public String POSNR            {get;set;}
        @AuraEnabled public String KSCHL            {get;set;}
        @AuraEnabled public String VTEXT            {get;set;}
        @AuraEnabled public String KWERT            {get;set;}
        @AuraEnabled public String WAERK            {get;set;}

        @AuraEnabled public String ZISI_DISPLAY     {get;set;}
        @AuraEnabled public String STUNR            {get;set;}
        @AuraEnabled public String ZAEHK            {get;set;}
        @AuraEnabled public String VISIBLE          {get;set;}
        @AuraEnabled public String VISIBLE_01       {get;set;}
        
        @AuraEnabled public String UPDATEFLAG       {get;set;}

        public IF_OPTY_020_Res_T_PRICING_ADD(){}
    }
    public class IF_OPTY_020_Res_T_PRICING_RATE{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String KSCHL        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String RATE         {get;set;}
        @AuraEnabled public String WAERK        {get;set;}

        @AuraEnabled public String STUNR        {get;set;}
        @AuraEnabled public String ZAEHK        {get;set;}
        @AuraEnabled public String KWERT        {get;set;}
        @AuraEnabled public String NWAERK       {get;set;}
        @AuraEnabled public String UPDATEFLAG   {get;set;}

        public IF_OPTY_020_Res_T_PRICING_RATE(){}
    }
    public class IF_OPTY_020_Res_T_OPTION{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String KSCHL        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String KWERT        {get;set;}
        @AuraEnabled public String WAERK        {get;set;}

        @AuraEnabled public String VISIBLE      {get;set;}

        public IF_OPTY_020_Res_T_OPTION(){}
    }
    public class IF_OPTY_020_Res_T_PRICING_EX{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String KSCHL        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String KBETR        {get;set;}
        @AuraEnabled public String KWERT        {get;set;}

        @AuraEnabled public String WAERK        {get;set;}
        @AuraEnabled public String VISIBLE      {get;set;}
        @AuraEnabled public String GUBUN        {get;set;}

        public IF_OPTY_020_Res_T_PRICING_EX(){}
    }
    public class IF_OPTY_020_Res_T_COND_EX{
        @AuraEnabled public String ITM_NUMBER    {get;set;}          
        @AuraEnabled public String COND_ST_NO    {get;set;}          
        @AuraEnabled public String COND_COUNT    {get;set;}          
        @AuraEnabled public String COND_TYPE     {get;set;}          
        @AuraEnabled public String COND_VALUE    {get;set;}      

        @AuraEnabled public String IF_CURRENCY   {get;set;}      
        @AuraEnabled public String COND_UNIT     {get;set;}          
        @AuraEnabled public String COND_P_UNT    {get;set;}          
        @AuraEnabled public String CURR_ISO      {get;set;}      
        @AuraEnabled public String CD_UNT_ISO    {get;set;}          
        
        @AuraEnabled public String REFOBJTYPE    {get;set;}          
        @AuraEnabled public String REFOBJKEY     {get;set;}          
        @AuraEnabled public String REFLOGSYS     {get;set;}          
        @AuraEnabled public String APPLICATIO    {get;set;}          
        @AuraEnabled public String CONPRICDAT    {get;set;}          
        
        @AuraEnabled public String CALCTYPCON    {get;set;}          
        @AuraEnabled public String CONBASEVAL    {get;set;}          
        @AuraEnabled public String CONEXCHRAT    {get;set;}          
        @AuraEnabled public String NUMCONVERT    {get;set;}          
        @AuraEnabled public String DENOMINATO    {get;set;}          
        
        @AuraEnabled public String CONDTYPE      {get;set;}      
        @AuraEnabled public String STAT_CON      {get;set;}      
        @AuraEnabled public String SCALETYPE     {get;set;}          
        @AuraEnabled public String ACCRUALS      {get;set;}      
        @AuraEnabled public String CONINVOLST    {get;set;}          
        
        @AuraEnabled public String CONDORIGIN    {get;set;}          
        @AuraEnabled public String GROUPCOND     {get;set;}          
        @AuraEnabled public String COND_UPDAT    {get;set;}          
        @AuraEnabled public String ACCESS_SEQ    {get;set;}          
        @AuraEnabled public String CONDCOUNT     {get;set;}          
        
        @AuraEnabled public String ROUNDOFFDI    {get;set;}          
        @AuraEnabled public String CONDVALUE     {get;set;}          
        @AuraEnabled public String CURRENCY_2    {get;set;}          
        @AuraEnabled public String CURR_ISO_2    {get;set;}          
        @AuraEnabled public String CONDCNTRL     {get;set;}          
        
        @AuraEnabled public String CONDISACTI    {get;set;}          
        @AuraEnabled public String CONDCLASS     {get;set;}          
        @AuraEnabled public String FACTBASVAL    {get;set;}          
        @AuraEnabled public String SCALEBASIN    {get;set;}          
        @AuraEnabled public String SCALBASVAL    {get;set;}          
        
        @AuraEnabled public String UNITMEASUR    {get;set;}          
        @AuraEnabled public String ISO_UNIT      {get;set;}      
        @AuraEnabled public String CURRENCKEY    {get;set;}          
        @AuraEnabled public String CURRENISO     {get;set;}          
        @AuraEnabled public String CONDINCOMP    {get;set;}          
        
        @AuraEnabled public String CONDCONFIG    {get;set;}          
        @AuraEnabled public String CONDCHAMAN    {get;set;}          
        @AuraEnabled public String COND_NO       {get;set;}      
        @AuraEnabled public String TAX_CODE      {get;set;}      
        @AuraEnabled public String VARCOND       {get;set;}      
        
        @AuraEnabled public String ACCOUNTKEY    {get;set;}          
        @AuraEnabled public String ACCOUNT_KE    {get;set;}          
        @AuraEnabled public String WT_WITHCD     {get;set;}          
        @AuraEnabled public String STRUCTCOND    {get;set;}          
        @AuraEnabled public String FACTCONBAS    {get;set;}          
        
        @AuraEnabled public String CONDCOINHD    {get;set;}          
        @AuraEnabled public String VCTEXT        {get;set;}      
        @AuraEnabled public String MATNR_AC      {get;set;}      
        @AuraEnabled public String ZZSQCOD       {get;set;}      

        public IF_OPTY_020_Res_T_COND_EX(){}
    }
    public class IF_OPTY_020_Res_T_COND_ELMT{
        @AuraEnabled public String KAPPL         {get;set;}
        @AuraEnabled public String KSCHL         {get;set;}
        @AuraEnabled public String VKORG         {get;set;}
        @AuraEnabled public String VTWEG         {get;set;}
        @AuraEnabled public String WAERK         {get;set;}
        
        @AuraEnabled public String ZZKVGR4       {get;set;}
        @AuraEnabled public String ZTERM         {get;set;}
        @AuraEnabled public String MATNR         {get;set;}
        @AuraEnabled public String KBETR         {get;set;}

        public IF_OPTY_020_Res_T_COND_ELMT(){}
    }

    // public class IF_ORDER_021_Req{
    //     @AuraEnabled public IF_ORDER_021_Req_I_REF_QUOT I_REF_QUOT {get;set;}

    //     public IF_ORDER_021_Req(){}
    // }
    // public class IF_ORDER_021_Req_I_REF_QUOT{
    //     @AuraEnabled public String VBELN_QU     {get;set;}
    //     @AuraEnabled public String AUART        {get;set;}

    //     public IF_ORDER_021_Req_I_REF_QUOT(){}
    // }
    // public class IF_ORDER_021_Res{
    //     @AuraEnabled public String                          O_VBELN     {get;set;}
    //     @AuraEnabled public IF_ORDER_021_Res_O_RETURN       O_RETURN    {get;set;}
    //     @AuraEnabled public List<IF_ORDER_021_Res_T_LIST>   T_LIST      {get;set;}

    //     public IF_ORDER_021_Res(){}
    // }
    // public class IF_ORDER_021_Res_O_RETURN{
    //     @AuraEnabled public String TYPE        {get;set;}
    //     @AuraEnabled public String CODE        {get;set;}
    //     @AuraEnabled public String MESSAGE     {get;set;}

    //     public IF_ORDER_021_Res_O_RETURN(){}
    // }
    // public class IF_ORDER_021_Res_T_LIST{
    //     @AuraEnabled public String VBELN        {get;set;}
    //     @AuraEnabled public String AUART        {get;set;}
    //     @AuraEnabled public String BSTDK        {get;set;}
    //     @AuraEnabled public String BSTKD        {get;set;}
    //     @AuraEnabled public String ERDAT        {get;set;}

    //     @AuraEnabled public String ERNAM        {get;set;}
    //     @AuraEnabled public String MODEL        {get;set;}
    //     @AuraEnabled public String MATNR        {get;set;}
    //     @AuraEnabled public String WAERK        {get;set;}
    //     @AuraEnabled public String TOTAL_AMT    {get;set;}
        
    //     @AuraEnabled public String NETWR_AMT    {get;set;}
    //     @AuraEnabled public String TAX_AMT      {get;set;}
    //     @AuraEnabled public String DISC_AMT     {get;set;}
    //     @AuraEnabled public String SURC_AMT     {get;set;}
    //     @AuraEnabled public String VSART        {get;set;}
        
    //     @AuraEnabled public String ZTERM        {get;set;}
    //     @AuraEnabled public String VDATU        {get;set;}
    //     @AuraEnabled public String KUNNR_AG     {get;set;}
    //     @AuraEnabled public String KUNNR_RE     {get;set;}
    //     @AuraEnabled public String KUNNR_RG     {get;set;}
        
    //     @AuraEnabled public String KUNNR_WE     {get;set;}
    //     @AuraEnabled public String KUNNR_ZM     {get;set;}
    //     @AuraEnabled public String CONFIRM      {get;set;}
    //     @AuraEnabled public String CHANGE       {get;set;}
    //     @AuraEnabled public String ZZSTATUS     {get;set;}
        
    //     @AuraEnabled public String ZSDFUNC      {get;set;}
    //     @AuraEnabled public String WRBTR        {get;set;}
    //     @AuraEnabled public String KNUMV        {get;set;}
    //     @AuraEnabled public String BUKRS_VF     {get;set;}
    //     @AuraEnabled public String ABGRU        {get;set;}
        
    //     @AuraEnabled public String VSBED        {get;set;}
    //     @AuraEnabled public String VKORG        {get;set;}
    //     @AuraEnabled public String VTWEG        {get;set;}
    //     @AuraEnabled public String SPART        {get;set;}
    //     @AuraEnabled public String MAKTX        {get;set;}
        
    //     @AuraEnabled public String SUBSEQUENCE  {get;set;}
    //     @AuraEnabled public String POSNR        {get;set;}
    //     @AuraEnabled public String SERNR        {get;set;}
    //     @AuraEnabled public String MTART        {get;set;}
    //     @AuraEnabled public String FKDAT        {get;set;}
        
    //     @AuraEnabled public String MBDAT        {get;set;}
    //     @AuraEnabled public String DLVCR        {get;set;}
    //     @AuraEnabled public String APPDATE      {get;set;}
    //     @AuraEnabled public String BMENG        {get;set;}
    //     @AuraEnabled public String VRKME        {get;set;}
        
    //     @AuraEnabled public String ADEPDT       {get;set;}
    //     @AuraEnabled public String AUGRU        {get;set;}
    //     @AuraEnabled public String WADAT_IST    {get;set;}
    //     @AuraEnabled public String ZZSO_SORT    {get;set;}
    //     @AuraEnabled public String VBELN_D      {get;set;}
        
    //     @AuraEnabled public String ERDAT_D      {get;set;}
    //     @AuraEnabled public String OALIAS       {get;set;}
    //     @AuraEnabled public String G_OALIAS     {get;set;}
    //     @AuraEnabled public String IHREZ        {get;set;}
    //     @AuraEnabled public String VSTEL        {get;set;}
        
    //     @AuraEnabled public String EDATU        {get;set;}
    //     @AuraEnabled public String FKSTK        {get;set;}
    //     @AuraEnabled public String CARNO        {get;set;}
    //     @AuraEnabled public String VKBUR        {get;set;}
    //     @AuraEnabled public String AEDAT        {get;set;}
        
    //     @AuraEnabled public String KUNNR_ZI     {get;set;}
    //     @AuraEnabled public String VBELN_I      {get;set;}
    //     @AuraEnabled public String VBELN_Q      {get;set;}
    //     @AuraEnabled public String ARKTX        {get;set;}
    //     @AuraEnabled public String ZDELFLAG     {get;set;}
        
    //     @AuraEnabled public String ZRETURNS     {get;set;}

    //     public IF_ORDER_021_Res_T_LIST(){}
    // }
}