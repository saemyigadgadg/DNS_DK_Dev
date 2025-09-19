public with sharing class IF_ERP_Parts_Return_Classes {
    public IF_ERP_Parts_Return_Classes() {}

    // SFDC interface Id    : IF-PARTS-017
    // AS-IS RFC            : Z_EP_INVOICELIST
    // New I/F              : ZCRM_EP_INVOICELIST
    // Description          : 반품대상 조회
    public class IF_PARTS_017_Req{
        @AuraEnabled public IF_PARTS_017_Req_LS_SEARCH  LS_SEARCH   {get;set;}
        @AuraEnabled public String                      I_VKORG     {get;set;}
        @AuraEnabled public String                      I_FKART     {get;set;}
        @AuraEnabled public IF_PARTS_017_Req_I_USERINFO I_USERINFO  {get;set;}

        public IF_PARTS_017_Req(){}
    }
    public class IF_PARTS_017_Req_LS_SEARCH{
        @AuraEnabled public String AUART        {get;set;}
        @AuraEnabled public String BSTKD        {get;set;}
        @AuraEnabled public String VGBEL        {get;set;}
        @AuraEnabled public String VBELN        {get;set;}
        
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String FRDATE       {get;set;}
        @AuraEnabled public String TODATE       {get;set;}
        @AuraEnabled public String USERID       {get;set;}
        
        @AuraEnabled public String KUNNR        {get;set;}
        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VBTYP        {get;set;}
        @AuraEnabled public String WAERK        {get;set;}
        
        @AuraEnabled public String T_NETWR      {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String COUNT        {get;set;}
        @AuraEnabled public String RFGSK        {get;set;}
        
        @AuraEnabled public String FKSTK        {get;set;}
        @AuraEnabled public String KVGR5        {get;set;}
        @AuraEnabled public String IHREZ        {get;set;}
        @AuraEnabled public String SUBMI        {get;set;}
        
        @AuraEnabled public String KONDA        {get;set;}
        @AuraEnabled public String XBLNR        {get;set;}
        @AuraEnabled public String ZZACCPTCD    {get;set;}
        @AuraEnabled public String ZZCFSTA      {get;set;}
        
        @AuraEnabled public String ITEMLEVEL    {get;set;}
        @AuraEnabled public String ZLINE_STAT   {get;set;}
        @AuraEnabled public String DVBELN       {get;set;}
        @AuraEnabled public String EFCIVNO      {get;set;}

        public IF_PARTS_017_Req_LS_SEARCH(){}
    }
    public class IF_PARTS_017_Req_I_USERINFO{
        @AuraEnabled public String BNAME    {get;set;}
        @AuraEnabled public String RNAME    {get;set;}
        @AuraEnabled public String HIER     {get;set;}
        @AuraEnabled public String KUNNR    {get;set;}
        @AuraEnabled public String LIFNR    {get;set;}

        @AuraEnabled public String VKORG    {get;set;}
        @AuraEnabled public String VTWEG    {get;set;}
        @AuraEnabled public String SPART    {get;set;}
        @AuraEnabled public String WERKS    {get;set;}
        @AuraEnabled public String ARBPL    {get;set;}
        
        @AuraEnabled public String PARNR    {get;set;}
        @AuraEnabled public String ENAME    {get;set;}
        @AuraEnabled public String KUNN2    {get;set;}
        @AuraEnabled public String LAND1    {get;set;}
        @AuraEnabled public String LGORT    {get;set;}
        
        @AuraEnabled public String DF_CHK   {get;set;}
        @AuraEnabled public String CO_CHK   {get;set;}

        public IF_PARTS_017_Req_I_USERINFO(){}
    }
    public class IF_PARTS_017_Res{
        @AuraEnabled public String                              LV_MSG      {get;set;}
        @AuraEnabled public List<IF_PARTS_017_Res_LT_SEARCH2>   LT_SEARCH2  {get;set;}

        public IF_PARTS_017_Res(){}
    }
    public class IF_PARTS_017_Res_LT_SEARCH2{
        @AuraEnabled public String VBELN        {get;set;}
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String BSTKD        {get;set;}
        @AuraEnabled public String VBELN2       {get;set;}

        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String AUBEL        {get;set;}
        
        @AuraEnabled public String AUPOS        {get;set;}
        @AuraEnabled public String ERDAT        {get;set;}
        @AuraEnabled public String COUNT        {get;set;}
        @AuraEnabled public String NETWR        {get;set;}
        
        @AuraEnabled public String WAERK        {get;set;}
        @AuraEnabled public String VBTYP_VF     {get;set;}
        @AuraEnabled public String VBTYP        {get;set;}
        @AuraEnabled public String RFGSK        {get;set;}
        
        @AuraEnabled public String NETPR        {get;set;}
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String KWMENG       {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        
        @AuraEnabled public String VRKME        {get;set;}
        @AuraEnabled public String MATWA        {get;set;}
        @AuraEnabled public String BUDAT        {get;set;}
        @AuraEnabled public String FKIMG        {get;set;}
        
        @AuraEnabled public String WAERS        {get;set;}
        @AuraEnabled public String VSBED        {get;set;}
        @AuraEnabled public String MWSBP        {get;set;}
        @AuraEnabled public String KZWI2        {get;set;}
        
        @AuraEnabled public String KZWI2_N      {get;set;}
        @AuraEnabled public String CL_QTY       {get;set;}
        @AuraEnabled public String KONDA        {get;set;}
        @AuraEnabled public String XBLNR        {get;set;}
        
        public IF_PARTS_017_Res_LT_SEARCH2(){}
    }

    /** SFDC interface Id    : IF-PARTS-018
     *  AS-IS RFC            : Z_SD_CREATE_SALES_ORDER_DIA
     *  New I/F              : ZCRM_SD_CREATE_SALES_ORDER_USA
     *  Description          : 반품생성 저장
        */
        public class IF_PARTS_018_Req{
            @AuraEnabled public IF_PARTS_018_Req_I_HEAD         I_HEAD          {get;set;}
            @AuraEnabled public IF_PARTS_018_Req_I_COLLECTION   I_COLLECTION    {get;set;}
            @AuraEnabled public String I_REF_ORDER                              {get;set;}
            @AuraEnabled public String I_COMPLAIN                               {get;set;}
            @AuraEnabled public String I_GUBUN                                  {get;set;}
            
            @AuraEnabled public String I_TESTRUN                                {get;set;}
            @AuraEnabled public String I_INQUIRY                                {get;set;}
            @AuraEnabled public String I_MDOWN                                  {get;set;}
            @AuraEnabled public String I_EMAIL                                  {get;set;}
            @AuraEnabled public IF_PARTS_018_Req_I_USERINFO   I_USERINFO        {get;set;}

            @AuraEnabled public List<IF_PARTS_018_Req_T_ITEM>       T_ITEM          {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_PARTNER>    T_PARTNER       {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_CONFIG>     T_CONFIG        {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_SEL_CONFIG> T_SEL_CONFIG    {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_PRICING>    T_PRICING       {get;set;}
            
            @AuraEnabled public List<IF_PARTS_018_Req_T_PRICING_ADD>    T_PRICING_ADD   {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_PRICING_RATE>   T_PRICING_RATE  {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_NOTES>          T_NOTES         {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_FILE>           T_FILE          {get;set;}
            @AuraEnabled public List<IF_PARTS_018_Req_T_RETURN>         T_RETURN        {get;set;}
            
            @AuraEnabled public List<IF_PARTS_018_Req_T_CONDTEXT>       T_CONDTEXT      {get;set;}

            public IF_PARTS_018_Req(){}
        }
        public class IF_PARTS_018_Req_I_HEAD{
            @AuraEnabled public String AUART            {get;set;}
            @AuraEnabled public String VKORG            {get;set;}
            @AuraEnabled public String VTWEG            {get;set;}
            @AuraEnabled public String SPART            {get;set;}

            @AuraEnabled public String VKBUR            {get;set;}
            @AuraEnabled public String VDATU            {get;set;}
            @AuraEnabled public String BSTKD            {get;set;}
            @AuraEnabled public String BZIRK            {get;set;}
            
            @AuraEnabled public String INCO1            {get;set;}
            @AuraEnabled public String INCO2            {get;set;}
            @AuraEnabled public String ZTERM            {get;set;}
            @AuraEnabled public String LIFSK            {get;set;}
            
            @AuraEnabled public String FAKSK            {get;set;}
            @AuraEnabled public String AUGRU            {get;set;}
            @AuraEnabled public String KVGR1            {get;set;}
            @AuraEnabled public String KVGR2            {get;set;}
            
            @AuraEnabled public String KVGR3            {get;set;}
            @AuraEnabled public String KVGR4            {get;set;}
            @AuraEnabled public String KVGR5            {get;set;}
            @AuraEnabled public String WAERK            {get;set;}
            
            @AuraEnabled public String WERKS            {get;set;}
            @AuraEnabled public String SUBMI            {get;set;}
            @AuraEnabled public String AUTLF            {get;set;}
            
            @AuraEnabled public String KNUMV            {get;set;}
            @AuraEnabled public String ERNAM            {get;set;}
            @AuraEnabled public String ZZINCOM_VER      {get;set;}
            @AuraEnabled public String BASE_DATE        {get;set;}
            
            @AuraEnabled public String GI_DATE          {get;set;}
            @AuraEnabled public String T_NETWR          {get;set;}
            @AuraEnabled public String T_EST_AMT        {get;set;}
            @AuraEnabled public String ERDAT            {get;set;}
            
            @AuraEnabled public String ERZET            {get;set;}
            @AuraEnabled public String BUKRS_VF         {get;set;}
            @AuraEnabled public String NETWR            {get;set;}
            @AuraEnabled public String ABRVW            {get;set;}
            
            @AuraEnabled public String REFDOCTYPE       {get;set;}
            @AuraEnabled public String REF_DOC          {get;set;}
            @AuraEnabled public String REFDOC_CAT       {get;set;}
            @AuraEnabled public String REF_PROC         {get;set;}
            
            @AuraEnabled public String KZAZU            {get;set;}
            @AuraEnabled public String BSTDK            {get;set;}
            @AuraEnabled public String FKDAT            {get;set;}
            @AuraEnabled public String VBTYP            {get;set;}
            
            @AuraEnabled public String PLTYP            {get;set;}
            @AuraEnabled public String VSBED            {get;set;}
            @AuraEnabled public String KONDA            {get;set;}
            @AuraEnabled public String SDABW            {get;set;}
            
            @AuraEnabled public String EQUNR            {get;set;}
            @AuraEnabled public String VSNMR_V          {get;set;}
            @AuraEnabled public String BNAME            {get;set;}
            @AuraEnabled public String TELF1            {get;set;}
            
            @AuraEnabled public String IHREZ            {get;set;}
            @AuraEnabled public String VSART            {get;set;}
            @AuraEnabled public String BSTKD_E          {get;set;}
            @AuraEnabled public String IHREZ_E          {get;set;}
            
            @AuraEnabled public String AUART_T          {get;set;}
            @AuraEnabled public String ZTERM_T          {get;set;}
            @AuraEnabled public String VSBED_T          {get;set;}
            @AuraEnabled public String ABRVW_T          {get;set;}
            
            @AuraEnabled public String ANGDT            {get;set;}
            @AuraEnabled public String BNDDT            {get;set;}
            @AuraEnabled public String SERGE            {get;set;}
            @AuraEnabled public String ZSDFUNC          {get;set;}
            
            @AuraEnabled public String ZZSTATUS         {get;set;}
            @AuraEnabled public String ZZUSEDCAR_NO     {get;set;}
            @AuraEnabled public String ZZINCOM_NO       {get;set;}
            @AuraEnabled public String ZZPERM_NO        {get;set;}
            
            @AuraEnabled public String ZZCAPITAL_NO     {get;set;}
            @AuraEnabled public String ZZPERIOD         {get;set;}
            @AuraEnabled public String ZZRAT_REDUCE     {get;set;}
            @AuraEnabled public String ZZWARRPER        {get;set;}
            
            @AuraEnabled public String ZZPERUNIT        {get;set;}
            @AuraEnabled public String ZZWARHRS         {get;set;}
            @AuraEnabled public String ZZWARRPER_B      {get;set;}
            @AuraEnabled public String ZZPERUNIT_B      {get;set;}
            
            @AuraEnabled public String ZZWARHRS_B       {get;set;}
            @AuraEnabled public String ZZWARRDAT        {get;set;}
            @AuraEnabled public String ZZPR_WAR         {get;set;}
            @AuraEnabled public String ZZPR_WAR_B       {get;set;}
            
            @AuraEnabled public String ZZCOVERAGE       {get;set;}
            @AuraEnabled public String ZZCOVERAGE_B     {get;set;}
            @AuraEnabled public String ZZSQNO           {get;set;}
            @AuraEnabled public String ZZTECHARG        {get;set;}
            
            @AuraEnabled public String ZZDRAFTNO        {get;set;}
            @AuraEnabled public String ZZAPPNO          {get;set;}
            @AuraEnabled public String ZZAPPNO_T        {get;set;}
            @AuraEnabled public String ZZCAPITAL_NO_T   {get;set;}
            
            @AuraEnabled public String ZZMACNO          {get;set;}
            @AuraEnabled public String ZZQUINO          {get;set;}
            @AuraEnabled public String ZZISDAT          {get;set;}
            @AuraEnabled public String ZZCFSTA          {get;set;}
            
            @AuraEnabled public String ZZCFUSR          {get;set;}
            @AuraEnabled public String CUSTOMS_BRO      {get;set;}
            @AuraEnabled public String ZZURGEN          {get;set;}

            public IF_PARTS_018_Req_I_HEAD(){}
        }
        public class IF_PARTS_018_Req_I_COLLECTION{
            @AuraEnabled public String ZZUSEDCAR_NO    {get;set;}
            @AuraEnabled public String ZZPERM_NO       {get;set;}
            @AuraEnabled public String ZZCAPITAL_NO    {get;set;}
            @AuraEnabled public String MORT_CODE1      {get;set;}
            
            @AuraEnabled public String MORT_DATE1      {get;set;}
            @AuraEnabled public String MORT_CODE2      {get;set;}
            @AuraEnabled public String MORT_DATE2      {get;set;}
            @AuraEnabled public String MORT_CODE3      {get;set;}
            
            @AuraEnabled public String MORT_DATE3      {get;set;}
            @AuraEnabled public String MORT_CODE4      {get;set;}
            @AuraEnabled public String MORT_DATE4      {get;set;}
            @AuraEnabled public String MORT_CODE5      {get;set;}
            
            @AuraEnabled public String MORT_DATE5      {get;set;}
            @AuraEnabled public String MORT_CODE6      {get;set;}
            @AuraEnabled public String MORT_DATE6      {get;set;}
            @AuraEnabled public String ZZWARRPER       {get;set;}
            
            @AuraEnabled public String ZZPERUNIT       {get;set;}
            @AuraEnabled public String ZZWARHRS        {get;set;}
            @AuraEnabled public String ZZWARRDAT       {get;set;}
            @AuraEnabled public String BASE_DATE       {get;set;}
            
            @AuraEnabled public String WADAT_IST       {get;set;}
            @AuraEnabled public String ZZINCOM_NO      {get;set;}
            @AuraEnabled public String NETWR           {get;set;}
            @AuraEnabled public String NETWR1          {get;set;}
            
            @AuraEnabled public String WAERK           {get;set;}
            @AuraEnabled public String INCOM_CODE      {get;set;}
            @AuraEnabled public String ZTERM           {get;set;}
            @AuraEnabled public String EST_DAT         {get;set;}
            
            @AuraEnabled public String EST_AMT         {get;set;}
            @AuraEnabled public String FA_CODE         {get;set;}
            @AuraEnabled public String DOWN_REQ_NO     {get;set;}
            @AuraEnabled public String MODIFY_NETWR    {get;set;}
            
            @AuraEnabled public String ZZPERIOD        {get;set;}
            @AuraEnabled public String ZZRAT_REDUCE    {get;set;}
            @AuraEnabled public String RESIDUAL        {get;set;}
            @AuraEnabled public String ZZDRAFTNO       {get;set;}

            public IF_PARTS_018_Req_I_COLLECTION(){}
        }
        public class IF_PARTS_018_Req_I_USERINFO{
            @AuraEnabled public String BNAME    {get;set;}
            @AuraEnabled public String RNAME    {get;set;}
            @AuraEnabled public String HIER     {get;set;}
            @AuraEnabled public String KUNNR    {get;set;}
            @AuraEnabled public String LIFNR    {get;set;}

            @AuraEnabled public String VKORG    {get;set;}
            @AuraEnabled public String VTWEG    {get;set;}
            @AuraEnabled public String SPART    {get;set;}
            @AuraEnabled public String WERKS    {get;set;}
            @AuraEnabled public String ARBPL    {get;set;}
            
            @AuraEnabled public String PARNR    {get;set;}
            @AuraEnabled public String ENAME    {get;set;}
            @AuraEnabled public String KUNN2    {get;set;}
            @AuraEnabled public String LAND1    {get;set;}
            @AuraEnabled public String LGORT    {get;set;}
            
            @AuraEnabled public String DF_CHK   {get;set;}
            @AuraEnabled public String CO_CHK   {get;set;}

            public IF_PARTS_018_Req_I_USERINFO(){}
        }
        public class IF_PARTS_018_Req_T_ITEM{
            @AuraEnabled public String POSNR        {get;set;}
            @AuraEnabled public String UEPOS        {get;set;}
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String ARKTX        {get;set;}

            @AuraEnabled public String ABGRU        {get;set;}
            @AuraEnabled public String VKAUS        {get;set;}
            @AuraEnabled public String NETWR        {get;set;}
            @AuraEnabled public String NETPR        {get;set;}
            
            @AuraEnabled public String MWST         {get;set;}
            @AuraEnabled public String WAERK        {get;set;}
            @AuraEnabled public String MWSBP        {get;set;}
            @AuraEnabled public String KWMENG       {get;set;}
            
            @AuraEnabled public String KBMENG       {get;set;}
            @AuraEnabled public String KLMENG       {get;set;}
            @AuraEnabled public String VRKME        {get;set;}
            @AuraEnabled public String MEINS        {get;set;}
            
            @AuraEnabled public String WERKS        {get;set;}
            @AuraEnabled public String ROUTE        {get;set;}
            @AuraEnabled public String ANZSN        {get;set;}
            @AuraEnabled public String UPDATEFLAG   {get;set;}
            
            @AuraEnabled public String KZWI1        {get;set;}
            @AuraEnabled public String LIST_PRICE   {get;set;}
            @AuraEnabled public String SUB_TOTAL    {get;set;}
            @AuraEnabled public String PSTYV        {get;set;}
            
            @AuraEnabled public String REF_DOC      {get;set;}
            @AuraEnabled public String REF_DOC_IT   {get;set;}
            @AuraEnabled public String REF_DOC_CA   {get;set;}
            @AuraEnabled public String POSEX        {get;set;}
            
            @AuraEnabled public String MAKTX        {get;set;}
            @AuraEnabled public String PRSDT        {get;set;}
            @AuraEnabled public String KONDA        {get;set;}
            @AuraEnabled public String LGORT        {get;set;}
            
            @AuraEnabled public String LGOBE        {get;set;}
            @AuraEnabled public String VSART        {get;set;}
            @AuraEnabled public String PARENT       {get;set;}
            @AuraEnabled public String EDATU        {get;set;}
            
            @AuraEnabled public String POSNRX       {get;set;}
            @AuraEnabled public String TNDR_TRKID   {get;set;}
            @AuraEnabled public String IHREZ_E      {get;set;}
            @AuraEnabled public String ST_7020      {get;set;}
            
            @AuraEnabled public String ZZACCPTCD    {get;set;}
            @AuraEnabled public String ZZDEALDT     {get;set;}
            @AuraEnabled public String ZZAPPMACHINE {get;set;}
            @AuraEnabled public String ZZEQMASTER   {get;set;}
            
            @AuraEnabled public String ZZWORKHRS    {get;set;}
            @AuraEnabled public String ZZCMPCD      {get;set;}
            @AuraEnabled public String ZZREASON     {get;set;}
            @AuraEnabled public String ZZKMAT       {get;set;}
            
            @AuraEnabled public String EQUIP_CHECK  {get;set;}
            @AuraEnabled public String AVAIL_DATE   {get;set;}
            @AuraEnabled public String VENDOR       {get;set;}
            @AuraEnabled public String CARRIER      {get;set;}
            
            @AuraEnabled public String TRACKING_NO  {get;set;}
            @AuraEnabled public String VDATU        {get;set;}
            @AuraEnabled public String REMARK       {get;set;}

            public IF_PARTS_018_Req_T_ITEM(){}
        }
        public class IF_PARTS_018_Req_T_PARTNER{
            @AuraEnabled public String VBELN            {get;set;}
            @AuraEnabled public String POSNR            {get;set;}
            @AuraEnabled public String PARVW            {get;set;}
            @AuraEnabled public String KUNNR            {get;set;}

            @AuraEnabled public String NAME1            {get;set;}
            @AuraEnabled public String NAME2            {get;set;}
            @AuraEnabled public String NAME3            {get;set;}
            @AuraEnabled public String NAME4            {get;set;}
            
            @AuraEnabled public String STREET1          {get;set;}
            @AuraEnabled public String STREET2          {get;set;}
            @AuraEnabled public String CITY1            {get;set;}
            @AuraEnabled public String CITY2            {get;set;}
            
            @AuraEnabled public String STATE            {get;set;}
            @AuraEnabled public String ZIP              {get;set;}
            @AuraEnabled public String HOUSE_NUM1       {get;set;}
            @AuraEnabled public String TEL_NUMBER       {get;set;}
            
            @AuraEnabled public String FAX_NUMBER       {get;set;}
            @AuraEnabled public String EMAIL            {get;set;}
            @AuraEnabled public String SIC_CODE         {get;set;}
            @AuraEnabled public String MAIL_OK          {get;set;}
            
            @AuraEnabled public String COUNTRY          {get;set;}
            @AuraEnabled public String TZONE            {get;set;}
            @AuraEnabled public String CONTACT          {get;set;}
            @AuraEnabled public String SORT2            {get;set;}
            
            @AuraEnabled public String PO_BOX_LOC       {get;set;}

            public IF_PARTS_018_Req_T_PARTNER(){}
        }
        public class IF_PARTS_018_Req_T_CONFIG{
            @AuraEnabled public String POSNR        {get;set;}
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATBEZ        {get;set;}
            @AuraEnabled public String ZSEQNO       {get;set;}

            @AuraEnabled public String SHOW         {get;set;}
            @AuraEnabled public String READONLY     {get;set;}

            public IF_PARTS_018_Req_T_CONFIG(){}
        }
        public class IF_PARTS_018_Req_T_SEL_CONFIG{
            @AuraEnabled public String POSNR        {get;set;}
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATWRT        {get;set;}

            public IF_PARTS_018_Req_T_SEL_CONFIG(){}
        }
        public class IF_PARTS_018_Req_T_PRICING{
            @AuraEnabled public String POSNR        {get;set;}
            @AuraEnabled public String KSCHL        {get;set;}
            @AuraEnabled public String VTEXT        {get;set;}
            @AuraEnabled public String KWERT        {get;set;}

            @AuraEnabled public String WAERK        {get;set;}
            @AuraEnabled public String VISIBLE      {get;set;}

            public IF_PARTS_018_Req_T_PRICING(){}
        }
        public class IF_PARTS_018_Req_T_PRICING_ADD{
            @AuraEnabled public String POSNR        {get;set;}
            @AuraEnabled public String KSCHL        {get;set;}
            @AuraEnabled public String VTEXT        {get;set;}
            @AuraEnabled public String KWERT        {get;set;}

            @AuraEnabled public String WAERK        {get;set;}
            @AuraEnabled public String ZISI_DISPLAY {get;set;}
            @AuraEnabled public String STUNR        {get;set;}
            @AuraEnabled public String ZAEHK        {get;set;}
            
            @AuraEnabled public String VISIBLE      {get;set;}
            @AuraEnabled public String VISIBLE_01   {get;set;}
            @AuraEnabled public String UPDATEFLAG   {get;set;}

            public IF_PARTS_018_Req_T_PRICING_ADD(){}
        }
        public class IF_PARTS_018_Req_T_PRICING_RATE{
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

            public IF_PARTS_018_Req_T_PRICING_RATE(){}
        }
        public class IF_PARTS_018_Req_T_NOTES{
            @AuraEnabled public String POSNR        {get;set;}
            @AuraEnabled public String SEQNO        {get;set;}
            @AuraEnabled public String TDID         {get;set;}
            @AuraEnabled public String LINE         {get;set;}

            public IF_PARTS_018_Req_T_NOTES(){}
        }
        public class IF_PARTS_018_Req_T_FILE{
            @AuraEnabled public String INT_NO       {get;set;}
            @AuraEnabled public String CHECK        {get;set;}
            @AuraEnabled public String DOCU_ITEM    {get;set;}
            @AuraEnabled public String VISIBLE      {get;set;}

            @AuraEnabled public String FILE_NAME    {get;set;}
            @AuraEnabled public String DESCRIPTION  {get;set;}
            @AuraEnabled public String FILE_DATA    {get;set;}
            @AuraEnabled public String FILE_NO      {get;set;}
            
            @AuraEnabled public String FILESIZE     {get;set;}

            public IF_PARTS_018_Req_T_FILE(){}
        }
        public class IF_PARTS_018_Req_T_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String ID           {get;set;}
            @AuraEnabled public String IF_NUMBER       {get;set;}
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

            public IF_PARTS_018_Req_T_RETURN(){}
        }
        public class IF_PARTS_018_Req_T_CONDTEXT{
            @AuraEnabled public String MANDT        {get;set;}
            @AuraEnabled public String VBELN        {get;set;}
            @AuraEnabled public String ZSEQ         {get;set;}
            @AuraEnabled public String KSCHL        {get;set;}

            @AuraEnabled public String ZZTEXT       {get;set;}
            @AuraEnabled public String ZEMAIL       {get;set;}
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATWRT        {get;set;}
            
            @AuraEnabled public String KWERT        {get;set;}
            @AuraEnabled public String WAERS        {get;set;}
            @AuraEnabled public String ERDAT        {get;set;}
            @AuraEnabled public String ERNAM        {get;set;}
            
            @AuraEnabled public String ERZET        {get;set;}
            @AuraEnabled public String AEDAT        {get;set;}
            @AuraEnabled public String AENAM        {get;set;}
            @AuraEnabled public String AEZET        {get;set;}

            public IF_PARTS_018_Req_T_CONDTEXT(){}
        }
        public class IF_PARTS_018_Res{
            @AuraEnabled public String                    O_VBELN   {get;set;}
            @AuraEnabled public IF_PARTS_018_Res_O_RETURN O_RETURN  {get;set;}

            public IF_PARTS_018_Res(){}
        }
        public class IF_PARTS_018_Res_O_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}

            public IF_PARTS_018_Res_O_RETURN(){}
        }

    /**  SFDC interface Id  : IF-PARTS-019
     * AS-IS RFC            : Z_EP_ORDERLIST
     * New I/F              : ZCRM_EP_ORDERLIST
     * Description          : 반품 목록 조회
        */
        public class IF_PARTS_019_Req{
            @AuraEnabled public IF_PARTS_019_Req_LS_SEARCH  LS_SEARCH       {get;set;}
            @AuraEnabled public String                      COMPLAINT       {get;set;}
            @AuraEnabled public String                      I_LANGU         {get;set;}
            @AuraEnabled public String                      I_BGTYP         {get;set;}
            @AuraEnabled public String                      I_DIBK_FLAG     {get;set;}
            
            @AuraEnabled public IF_PARTS_019_Req_I_USERINFO I_USERINFO      {get;set;}

            public IF_PARTS_019_Req(){}
        }
        public class IF_PARTS_019_Req_LS_SEARCH{
            @AuraEnabled public String AUART        {get;set;}
            @AuraEnabled public String BSTKD        {get;set;}
            @AuraEnabled public String VGBEL        {get;set;}
            @AuraEnabled public String VBELN        {get;set;}
            @AuraEnabled public String MATNR        {get;set;}

            @AuraEnabled public String FRDATE       {get;set;}
            @AuraEnabled public String TODATE       {get;set;}
            @AuraEnabled public String USERID       {get;set;}
            @AuraEnabled public String KUNNR        {get;set;}
            
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VBTYP        {get;set;}
            @AuraEnabled public String WAERK        {get;set;}
            @AuraEnabled public String T_NETWR      {get;set;}
            
            @AuraEnabled public String SPART        {get;set;}
            @AuraEnabled public String COUNT        {get;set;}
            @AuraEnabled public String RFGSK        {get;set;}
            @AuraEnabled public String FKSTK        {get;set;}
            
            @AuraEnabled public String KVGR5        {get;set;}
            @AuraEnabled public String IHREZ        {get;set;}
            @AuraEnabled public String SUBMI        {get;set;}
            @AuraEnabled public String KONDA        {get;set;}
            
            @AuraEnabled public String XBLNR        {get;set;}
            @AuraEnabled public String ZZACCPTCD    {get;set;}
            @AuraEnabled public String ZZCFSTA      {get;set;}
            @AuraEnabled public String ITEMLEVEL    {get;set;}
            
            @AuraEnabled public String ZLINE_STAT   {get;set;}
            @AuraEnabled public String DVBELN       {get;set;}
            @AuraEnabled public String EFCIVNO      {get;set;}

            public IF_PARTS_019_Req_LS_SEARCH(){}
        }
        public class IF_PARTS_019_Req_I_USERINFO{
            @AuraEnabled public String BNAME    {get;set;}
            @AuraEnabled public String RNAME    {get;set;}
            @AuraEnabled public String HIER     {get;set;}
            @AuraEnabled public String KUNNR    {get;set;}
            @AuraEnabled public String LIFNR    {get;set;}

            @AuraEnabled public String VKORG    {get;set;}
            @AuraEnabled public String VTWEG    {get;set;}
            @AuraEnabled public String SPART    {get;set;}
            @AuraEnabled public String WERKS    {get;set;}
            @AuraEnabled public String ARBPL    {get;set;}
            
            @AuraEnabled public String PARNR    {get;set;}
            @AuraEnabled public String ENAME    {get;set;}
            @AuraEnabled public String KUNN2    {get;set;}
            @AuraEnabled public String LAND1    {get;set;}
            @AuraEnabled public String LGORT    {get;set;}
            
            @AuraEnabled public String DF_CHK   {get;set;}
            @AuraEnabled public String CO_CHK   {get;set;}

            public IF_PARTS_019_Req_I_USERINFO(){}
        }
        public class IF_PARTS_019_Res{
            @AuraEnabled public List<IF_PARTS_019_Res_LT_SEARCH>    LT_SEARCH   {get;set;}
            @AuraEnabled public List<IF_PARTS_019_Res_LT_SEARCH2>   LT_SEARCH2  {get;set;}
            @AuraEnabled public String                              LV_MSG      {get;set;}
            @AuraEnabled public IF_PARTS_019_Res_O_RETURN           O_RETURN    {get;set;}
            public IF_PARTS_019_Res(){}
        }
        public class IF_PARTS_019_Res_LT_SEARCH{
            @AuraEnabled public String AUART        {get;set;}
            @AuraEnabled public String VBELN        {get;set;}
            @AuraEnabled public String BSTKD        {get;set;}
            @AuraEnabled public String VBELN2       {get;set;}

            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}
            @AuraEnabled public String SPART        {get;set;}
            @AuraEnabled public String ERDAT        {get;set;}
            
            @AuraEnabled public String ERZET        {get;set;}
            @AuraEnabled public String COUNT        {get;set;}
            @AuraEnabled public String T_NETWR      {get;set;}
            @AuraEnabled public String WAERK        {get;set;}
            
            @AuraEnabled public String VBTYP        {get;set;}
            @AuraEnabled public String RFGSK        {get;set;}
            @AuraEnabled public String FKSTK        {get;set;}
            @AuraEnabled public String NETPR        {get;set;}
            
            @AuraEnabled public String VGBEL        {get;set;}
            @AuraEnabled public String ZZACCPTCD    {get;set;}
            @AuraEnabled public String VTEXT        {get;set;}
            @AuraEnabled public String VBELN3       {get;set;}
            
            @AuraEnabled public String VSBED        {get;set;}
            @AuraEnabled public String ZZAUKON      {get;set;}
            @AuraEnabled public String VTEXT2       {get;set;}
            @AuraEnabled public String KONDA        {get;set;}
            
            @AuraEnabled public String KVGR5        {get;set;}
            @AuraEnabled public String KUNNR        {get;set;}
            @AuraEnabled public String NAME_KUNNR   {get;set;}
            @AuraEnabled public String KUNWE        {get;set;}
            
            @AuraEnabled public String NAME1        {get;set;}
            @AuraEnabled public String TOTALQTY     {get;set;}
            @AuraEnabled public String SUBMI        {get;set;}
            @AuraEnabled public String CARR_DEC     {get;set;}
            
            @AuraEnabled public String ZZAPPNO      {get;set;}
            @AuraEnabled public String NAME2        {get;set;}
            @AuraEnabled public String AUGRU        {get;set;}

            public IF_PARTS_019_Res_LT_SEARCH(){}
        }
        public class IF_PARTS_019_Res_LT_SEARCH2{
            @AuraEnabled public String AUART        {get;set;}
            @AuraEnabled public String VBELN        {get;set;}
            @AuraEnabled public String POSNR        {get;set;}
            @AuraEnabled public String BSTKD        {get;set;}
            
            @AuraEnabled public String VBELN2       {get;set;}
            @AuraEnabled public String POSNR2       {get;set;}
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}

            @AuraEnabled public String SPART        {get;set;}
            @AuraEnabled public String ERDAT        {get;set;}
            @AuraEnabled public String ERZET        {get;set;}
            @AuraEnabled public String COUNT        {get;set;}
            
            @AuraEnabled public String T_NETWR      {get;set;}
            @AuraEnabled public String WAERK        {get;set;}
            @AuraEnabled public String VBTYP        {get;set;}
            @AuraEnabled public String RFGSK        {get;set;}
            
            @AuraEnabled public String NETPR        {get;set;}
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String KWMENG       {get;set;}
            @AuraEnabled public String MAKTX        {get;set;}
            
            @AuraEnabled public String VRKME        {get;set;}
            @AuraEnabled public String MATWA        {get;set;}
            @AuraEnabled public String RFGSK_TX     {get;set;}
            @AuraEnabled public String RFGSK_TX_T   {get;set;}
            
            @AuraEnabled public String ZZACCPTCD    {get;set;}
            @AuraEnabled public String VTEXT        {get;set;}
            @AuraEnabled public String VGBEL        {get;set;}
            @AuraEnabled public String ZZCMPCD      {get;set;}
            
            @AuraEnabled public String VBELN3       {get;set;}
            @AuraEnabled public String VBELN4       {get;set;}
            @AuraEnabled public String KBETR        {get;set;}
            @AuraEnabled public String STATUS       {get;set;}
            
            @AuraEnabled public String TEXT002      {get;set;}
            @AuraEnabled public String TEXT004      {get;set;}
            @AuraEnabled public String EMP_NAME     {get;set;}
            @AuraEnabled public String RDATE        {get;set;}
            
            @AuraEnabled public String IN_FREIGHT   {get;set;}
            @AuraEnabled public String OUT_FREIGHT  {get;set;}
            @AuraEnabled public String ZZAPPNO      {get;set;}
            @AuraEnabled public String NAME2        {get;set;}
            
            @AuraEnabled public String RFGSK_TX_T1  {get;set;}
            @AuraEnabled public String XBLNR        {get;set;}
            @AuraEnabled public String FKIMG        {get;set;}
            @AuraEnabled public String IFKIMG       {get;set;}
            
            @AuraEnabled public String NFKIMG       {get;set;}
            @AuraEnabled public String FKDAT        {get;set;}
            @AuraEnabled public String ZFCIVNO      {get;set;}
            @AuraEnabled public String ZFSEQ        {get;set;}
            
            @AuraEnabled public String ZFMBLNO      {get;set;}
            @AuraEnabled public String ZFHBLNO      {get;set;}
            @AuraEnabled public String ZZANSWER     {get;set;}

            public IF_PARTS_019_Res_LT_SEARCH2(){}
        }
        public class IF_PARTS_019_Res_O_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
            @AuraEnabled public String LOG_NO       {get;set;}
            @AuraEnabled public String LOG_MSG_NO   {get;set;}
            
            @AuraEnabled public String MESSAGE_V1   {get;set;}
            @AuraEnabled public String MESSAGE_V2   {get;set;}
            @AuraEnabled public String MESSAGE_V3   {get;set;}
            @AuraEnabled public String MESSAGE_V4   {get;set;}

            public IF_PARTS_019_Res_O_RETURN(){}
        }

    /** IF-PARTS-028 (전달필요)
     *  RFC Name             : ZCRM_EP_ORDER_DELETE_ME
     *  Description          : 반품 대상 삭제
        */
        public class IF_PARTS_028_Req{
            @AuraEnabled public String I_VKORG      {get;set;}
            @AuraEnabled public List<IF_PARTS_028_Req_T_LIST> T_LIST {get;set;}   

            public IF_PARTS_028_Req(){}
        }
        public class IF_PARTS_028_Req_T_LIST{
            @AuraEnabled public String VBELN        {get;set;}
            @AuraEnabled public String MSGTYP       {get;set;}
            @AuraEnabled public String MSG          {get;set;}

            public IF_PARTS_028_Req_T_LIST(){}
        }
        public class IF_PARTS_028_Res{
            @AuraEnabled public List<IF_PARTS_028_Res_T_LIST> T_LIST {get;set;}  

            public IF_PARTS_028_Res(){}
        }
        public class IF_PARTS_028_Res_T_LIST{
            @AuraEnabled public String VBELN        {get;set;}
            @AuraEnabled public String MSGTYP       {get;set;}
            @AuraEnabled public String MSG          {get;set;}

            public IF_PARTS_028_Res_T_LIST(){}
        }
}