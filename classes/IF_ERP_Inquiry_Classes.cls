public with sharing class IF_ERP_Inquiry_Classes {
    public IF_ERP_Inquiry_Classes() {}


    // SFDC interface Id    : IF-OPTY-006
    // AS-IS RFC            : Z_SD_MS_IQ_CRE
    // New I/F              : ZCRM_SD_MS_IQ_CRE       
    // Description          : CRM에서 일반 Inquiry 생성 후 ERP에 전송
    public class IF_OPTY_006_Req{
        @AuraEnabled public String I_AUART                  {get;set;}
        @AuraEnabled public String I_VKORG                  {get;set;}
        @AuraEnabled public String I_VTWEG                  {get;set;}
        @AuraEnabled public String I_SPART                  {get;set;}
        @AuraEnabled public String I_VKBUR                  {get;set;}

        @AuraEnabled public String I_GSBER                  {get;set;}
        @AuraEnabled public String I_KUNNR                  {get;set;}
        @AuraEnabled public String I_KONDA                  {get;set;}
        @AuraEnabled public String I_MATNR                  {get;set;}
        @AuraEnabled public String I_KWMENG                 {get;set;}
    
        @AuraEnabled public String I_CUST_GRP1              {get;set;}
        @AuraEnabled public String I_CUST_GRP2              {get;set;}
        @AuraEnabled public String I_CUST_GRP3              {get;set;}
        @AuraEnabled public String I_VDATU                  {get;set;}
        @AuraEnabled public String I_KUNNR2                 {get;set;}

        @AuraEnabled public String I_ZZAPPNO                {get;set;}
        @AuraEnabled public String I_AUGRU                  {get;set;}
        @AuraEnabled public String I_REP_VKBUR              {get;set;}
        @AuraEnabled public String I_WORKPIECE              {get;set;}
        @AuraEnabled public String I_ZINDUS                 {get;set;}
        
        @AuraEnabled public String I_ZINDUS2                {get;set;}
        @AuraEnabled public String I_LAND1                  {get;set;}
        @AuraEnabled public String I_EXPORT                 {get;set;}
        @AuraEnabled public List<IF_OPTY_006_Req_T_ITEM> T_ITEM              {get;set;}
        @AuraEnabled public List<IF_OPTY_006_Req_T_TEXT> T_TEXT              {get;set;}
        
        @AuraEnabled public List<IF_OPTY_006_Req_T_TEXT_ZH27> T_TEXT_ZH27    {get;set;}
        @AuraEnabled public List<IF_OPTY_006_Req_T_TEXT_ZH09> T_TEXT_ZH09    {get;set;}

        public IF_OPTY_006_Req(){}
    }
    public class IF_OPTY_006_Req_T_ITEM{
        @AuraEnabled public String POSNR            {get;set;}
        @AuraEnabled public String PARENT           {get;set;}
        @AuraEnabled public String MAKTX            {get;set;}
        @AuraEnabled public String MATNR            {get;set;}
        @AuraEnabled public String ARKTX            {get;set;}

        @AuraEnabled public String KWMENG           {get;set;}
        @AuraEnabled public String REQ_DATE         {get;set;}
        @AuraEnabled public String VRKME            {get;set;}
        @AuraEnabled public String NETPR            {get;set;}
        @AuraEnabled public String WAERK            {get;set;}

        @AuraEnabled public String WERKS            {get;set;}
        @AuraEnabled public String CHECK            {get;set;}
        @AuraEnabled public String MWST             {get;set;}
        @AuraEnabled public String EQUIP_CHECK      {get;set;}
        @AuraEnabled public String PSTYV            {get;set;}

        @AuraEnabled public String NOTE             {get;set;}
        @AuraEnabled public String NETWR            {get;set;}
        @AuraEnabled public String VTEXT            {get;set;}
        @AuraEnabled public String MWSBP            {get;set;}
        @AuraEnabled public String ZZSQCOD          {get;set;}
        
        @AuraEnabled public String ZZSQTITLE        {get;set;}
        @AuraEnabled public String ZZDEALDT         {get;set;}
        @AuraEnabled public String INPUT_P          {get;set;}
        @AuraEnabled public String INPUT_A          {get;set;}
        @AuraEnabled public String BUILT_P          {get;set;}

        @AuraEnabled public String BUILT_A          {get;set;}
        @AuraEnabled public String TEST_P           {get;set;}
        @AuraEnabled public String TEST_A           {get;set;}
        @AuraEnabled public String PAINT_P          {get;set;}
        @AuraEnabled public String PAINT_A          {get;set;}

        @AuraEnabled public String RTS_P            {get;set;}
        @AuraEnabled public String RTS_A            {get;set;}
        @AuraEnabled public String DECK_P           {get;set;}
        @AuraEnabled public String DECK_A           {get;set;}
        @AuraEnabled public String EDATU            {get;set;}

        public IF_OPTY_006_Req_T_ITEM(){}
    }
    public class IF_OPTY_006_Req_T_TEXT{
        @AuraEnabled public String DOC_NUMBER       {get;set;}
        @AuraEnabled public String ITM_NUMBER       {get;set;}
        @AuraEnabled public String TEXT_ID          {get;set;}
        @AuraEnabled public String LANGU            {get;set;}
        @AuraEnabled public String LANGU_ISO        {get;set;}

        @AuraEnabled public String FORMAT_COL       {get;set;}
        @AuraEnabled public String TEXT_LINE        {get;set;}
        @AuraEnabled public String FUNCTION         {get;set;}
        
        public IF_OPTY_006_Req_T_TEXT(){}
    }
    public class IF_OPTY_006_Req_T_TEXT_ZH27{
        @AuraEnabled public String DOC_NUMBER       {get;set;}
        @AuraEnabled public String ITM_NUMBER       {get;set;}
        @AuraEnabled public String TEXT_ID          {get;set;}
        @AuraEnabled public String LANGU            {get;set;}
        @AuraEnabled public String LANGU_ISO        {get;set;}

        @AuraEnabled public String FORMAT_COL       {get;set;}
        @AuraEnabled public String TEXT_LINE        {get;set;}
        @AuraEnabled public String FUNCTION         {get;set;}

        public IF_OPTY_006_Req_T_TEXT_ZH27(){}
    }
    public class IF_OPTY_006_Req_T_TEXT_ZH09{
        @AuraEnabled public String DOC_NUMBER       {get;set;}
        @AuraEnabled public String ITM_NUMBER       {get;set;}
        @AuraEnabled public String TEXT_ID          {get;set;}
        @AuraEnabled public String LANGU            {get;set;}
        @AuraEnabled public String LANGU_ISO        {get;set;}

        @AuraEnabled public String FORMAT_COL       {get;set;}
        @AuraEnabled public String TEXT_LINE        {get;set;}
        @AuraEnabled public String FUNCTION         {get;set;}

        public IF_OPTY_006_Req_T_TEXT_ZH09(){}
    }
    public class IF_OPTY_006_Res{
        @AuraEnabled public String O_RECODE         {get;set;}
        @AuraEnabled public String O_REMSG          {get;set;}
        @AuraEnabled public String O_VBELN          {get;set;}
        @AuraEnabled public String O_EDATU          {get;set;}
        @AuraEnabled public String O_TOTAMT         {get;set;}

        public IF_OPTY_006_Res(){}
    }


    // SFDC interface Id    : IF-OPTY-007
    // AS-IS RFC            : Z_SD_MS_IQ_CHG       
    // New I/F              : ZCRM_SD_MS_IQ_CHG       
    // Description          : CRM에서 일반 Inquiry 수정 후 ERP에 전송 
    public class IF_OPTY_007_Req{
        @AuraEnabled public String I_VBELN      {get;set;}
        @AuraEnabled public String I_VDATU      {get;set;}
        @AuraEnabled public String I_KWMENG     {get;set;}
        @AuraEnabled public String I_REP_VKBUR  {get;set;}
        @AuraEnabled public String I_ZINDUS     {get;set;}

        @AuraEnabled public String I_ZINDUS2    {get;set;}
        @AuraEnabled public String I_LAND1      {get;set;}
        @AuraEnabled public String I_EXPORT     {get;set;}
        @AuraEnabled public String I_CANCEL     {get;set;}

        public IF_OPTY_007_Req(){}
    }
    public class IF_OPTY_007_Res{
        @AuraEnabled public String O_RECODE                     {get;set;}
        @AuraEnabled public String O_REMSG                      {get;set;}
        @AuraEnabled public List<IF_OPTY_007_Res_T_ITEM> T_ITEM     {get;set;}

        public IF_OPTY_007_Res(){}
    }
    public class IF_OPTY_007_Res_T_ITEM{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String KWMENG       {get;set;}
        @AuraEnabled public String VRKME        {get;set;}

        @AuraEnabled public String NETPR        {get;set;}
        @AuraEnabled public String WAERK        {get;set;}
        @AuraEnabled public String NETWR        {get;set;}
        @AuraEnabled public String WAERS        {get;set;}
        @AuraEnabled public String PSTYV        {get;set;}

        @AuraEnabled public String MWSBP        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}
        @AuraEnabled public String ZZKMAT       {get;set;}
        @AuraEnabled public String MDLNM        {get;set;}
        @AuraEnabled public String SATNR        {get;set;}

        public IF_OPTY_007_Res_T_ITEM(){}
    }    

    /** SFDC interface Id   : IF-OPTY-008
     * New I/F              : ZCRM_SD_MS_IQ_LST
     * Description          : 일반/시스템 Inquiry 정보 반환하여 ERP & CRM 데이터 동기화 (생성, 수정)
        */
        public class IF_OPTY_008_Req{
            @AuraEnabled public String I_SDATE      {get;set;}
            @AuraEnabled public String I_EDATE      {get;set;}

            public IF_OPTY_008_Req(){}
        }
        public class IF_OPTY_008_Res{
            @AuraEnabled public IF_OPTY_008_Res_O_RETURN        O_RETURN    {get;set;}
            @AuraEnabled public List<IF_OPTY_008_Res_T_HEADER>  T_HEADER    {get;set;}
            @AuraEnabled public List<IF_OPTY_008_Res_T_ITEM>    T_ITEM      {get;set;}
            @AuraEnabled public List<IF_OPTY_008_Res_T_PARTNER> T_PARTNER   {get;set;}

            public IF_OPTY_008_Res(){}
        }
        public class IF_OPTY_008_Res_O_RETURN{
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

            public IF_OPTY_008_Res_O_RETURN(){}
        }
        public class IF_OPTY_008_Res_T_HEADER{
            @AuraEnabled public String VBELN            {get;set;}
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
            @AuraEnabled public String WAERK            {get;set;}
            @AuraEnabled public String ZZUSEDCAR_NO     {get;set;}
            
            @AuraEnabled public String ZZINCOM_NO       {get;set;}
            @AuraEnabled public String ZZPERM_NO        {get;set;}
            @AuraEnabled public String ZZCAPITAL_NO     {get;set;}
            @AuraEnabled public String ZZPERIOD         {get;set;}
            
            @AuraEnabled public String ZZRAT_REDUCE     {get;set;}
            @AuraEnabled public String ZZWARRPER        {get;set;}
            @AuraEnabled public String ZZPERUNIT        {get;set;}
            @AuraEnabled public String ZZWARHRS         {get;set;}
            
            @AuraEnabled public String ZZWARRDAT        {get;set;}
            @AuraEnabled public String ZZCOVERAGE       {get;set;}
            @AuraEnabled public String ZZCOVERAGE_B     {get;set;}
            @AuraEnabled public String KNUMV            {get;set;}
            
            @AuraEnabled public String ERNAM            {get;set;}
            @AuraEnabled public String ZZINCOM_VER      {get;set;}
            @AuraEnabled public String BASE_DATE        {get;set;}
            @AuraEnabled public String GI_DATE          {get;set;}
            
            @AuraEnabled public String T_NETWR          {get;set;}
            @AuraEnabled public String T_EST_AMT        {get;set;}
            @AuraEnabled public String ERDAT            {get;set;}
            @AuraEnabled public String BUKRS_VF         {get;set;}
            
            @AuraEnabled public String NETWR            {get;set;}
            @AuraEnabled public String ABRVW            {get;set;}
            @AuraEnabled public String ZSDFUNC          {get;set;}
            @AuraEnabled public String ZZSTATUS         {get;set;}
            
            @AuraEnabled public String REFDOCTYPE       {get;set;}
            @AuraEnabled public String REF_DOC          {get;set;}
            @AuraEnabled public String REFDOC_CAT       {get;set;}
            @AuraEnabled public String REF_PROC         {get;set;}
            
            @AuraEnabled public String KZAZU            {get;set;}
            @AuraEnabled public String BSTDK            {get;set;}
            @AuraEnabled public String FKDAT            {get;set;}
            @AuraEnabled public String VBTYP            {get;set;}
            
            @AuraEnabled public String PLTYP            {get;set;}
            @AuraEnabled public String ZZSQNO           {get;set;}
            @AuraEnabled public String ZZTECHARG        {get;set;}
            @AuraEnabled public String ZZDRAFTNO        {get;set;}
            
            @AuraEnabled public String VSBED            {get;set;}
            @AuraEnabled public String IHREZ            {get;set;}
            @AuraEnabled public String BSTKD_E          {get;set;}
            @AuraEnabled public String PRSDT            {get;set;}
            
            @AuraEnabled public String ZZREP_VKBUR      {get;set;}
            @AuraEnabled public String ZZSQITEM         {get;set;}
            @AuraEnabled public String AUDAT            {get;set;}
            @AuraEnabled public String ZZPR_WAR         {get;set;}
            
            @AuraEnabled public String KONDA            {get;set;}

            public IF_OPTY_008_Res_T_HEADER(){}
        }
        public class IF_OPTY_008_Res_T_ITEM{
            @AuraEnabled public String VBELN            {get;set;}
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
            @AuraEnabled public String WAERK            {get;set;}
            @AuraEnabled public String ZZUSEDCAR_NO     {get;set;}
            
            @AuraEnabled public String ZZINCOM_NO       {get;set;}
            @AuraEnabled public String ZZPERM_NO        {get;set;}
            @AuraEnabled public String ZZCAPITAL_NO     {get;set;}
            @AuraEnabled public String ZZPERIOD         {get;set;}
            
            @AuraEnabled public String ZZRAT_REDUCE     {get;set;}
            @AuraEnabled public String ZZWARRPER        {get;set;}
            @AuraEnabled public String ZZPERUNIT        {get;set;}
            @AuraEnabled public String ZZWARHRS         {get;set;}
            
            @AuraEnabled public String ZZWARRDAT        {get;set;}
            @AuraEnabled public String ZZCOVERAGE       {get;set;}
            @AuraEnabled public String ZZCOVERAGE_B     {get;set;}
            @AuraEnabled public String KNUMV            {get;set;}
            
            @AuraEnabled public String ERNAM            {get;set;}
            @AuraEnabled public String ZZINCOM_VER      {get;set;}
            @AuraEnabled public String BASE_DATE        {get;set;}
            @AuraEnabled public String GI_DATE          {get;set;}
            
            @AuraEnabled public String T_NETWR          {get;set;}
            @AuraEnabled public String T_EST_AMT        {get;set;}
            @AuraEnabled public String ERDAT            {get;set;}
            @AuraEnabled public String BUKRS_VF         {get;set;}
            
            @AuraEnabled public String NETWR            {get;set;}
            @AuraEnabled public String ABRVW            {get;set;}
            @AuraEnabled public String ZSDFUNC          {get;set;}
            @AuraEnabled public String ZZSTATUS         {get;set;}
            
            @AuraEnabled public String REFDOCTYPE       {get;set;}
            @AuraEnabled public String REF_DOC          {get;set;}
            @AuraEnabled public String REFDOC_CAT       {get;set;}
            @AuraEnabled public String REF_PROC         {get;set;}
            
            @AuraEnabled public String KZAZU            {get;set;}
            @AuraEnabled public String BSTDK            {get;set;}
            @AuraEnabled public String FKDAT            {get;set;}
            @AuraEnabled public String VBTYP            {get;set;}
            
            @AuraEnabled public String PLTYP            {get;set;}
            @AuraEnabled public String ZZSQNO           {get;set;}
            @AuraEnabled public String ZZTECHARG        {get;set;}
            @AuraEnabled public String ZZDRAFTNO        {get;set;}
            
            @AuraEnabled public String VSBED            {get;set;}
            @AuraEnabled public String IHREZ            {get;set;}
            @AuraEnabled public String BSTKD_E          {get;set;}
            @AuraEnabled public String PRSDT            {get;set;}
            
            @AuraEnabled public String ZZREP_VKBUR      {get;set;}
            @AuraEnabled public String ZZSQITEM         {get;set;}
            @AuraEnabled public String AUDAT            {get;set;}
            @AuraEnabled public String ZZPR_WAR         {get;set;}
            
            @AuraEnabled public String KONDA            {get;set;}

            public IF_OPTY_008_Res_T_ITEM(){}
        }
        public class IF_OPTY_008_Res_T_PARTNER{
            @AuraEnabled public String VBELN            {get;set;}
            @AuraEnabled public String PARVW            {get;set;}
            @AuraEnabled public String KUNNR            {get;set;}
            @AuraEnabled public String NAME1            {get;set;}

            @AuraEnabled public String CITY1            {get;set;}
            @AuraEnabled public String STREET           {get;set;}
            @AuraEnabled public String POST_CODE1       {get;set;}
            @AuraEnabled public String COUNTRY          {get;set;}
            
            @AuraEnabled public String VTEXT            {get;set;}
            @AuraEnabled public String READ             {get;set;}
            @AuraEnabled public String M_NAME1          {get;set;}
            @AuraEnabled public String M_CITY1          {get;set;}
            
            @AuraEnabled public String M_STREET         {get;set;}
            @AuraEnabled public String M_POST_CODE1     {get;set;}
            @AuraEnabled public String E_MAIL           {get;set;}

            public IF_OPTY_008_Res_T_PARTNER(){}
        }

    /** SFDC interface Id   : IF-OPTY-022
     * New I/F              : ZCRM_SD_SET_SQ_MASTER
     * Description          : SQ 연동
        */
        public class IF_OPTY_022_Req{
            @AuraEnabled public List<IF_OPTY_022_Req_IT_DATA>       IT_DATA     {get;set;}
            @AuraEnabled public List<IF_OPTY_022_Req_IT_RTEXT1>     IT_RTEXT1   {get;set;}
            @AuraEnabled public List<IF_OPTY_022_Req_IT_RTEXT2>     IT_RTEXT2   {get;set;}

            public IF_OPTY_022_Req(){}
        }
        public class IF_OPTY_022_Req_IT_DATA{
            @AuraEnabled public String VBELN_QU     {get;set;}
            @AuraEnabled public String POSNR_QU     {get;set;}
            @AuraEnabled public String EMP_NO       {get;set;}
            @AuraEnabled public String SQNUM        {get;set;}
            @AuraEnabled public String FINAL_DT     {get;set;}

            @AuraEnabled public String DEPT_TEXT    {get;set;}
            @AuraEnabled public String FIRST_PO     {get;set;}
            @AuraEnabled public String CHKFL        {get;set;}
            @AuraEnabled public String DECHK        {get;set;}
            @AuraEnabled public String VLMON        {get;set;}
            
            @AuraEnabled public String NETPR        {get;set;}
            @AuraEnabled public String WAERS        {get;set;}
            @AuraEnabled public String REMARK       {get;set;}

            public IF_OPTY_022_Req_IT_DATA(){}
        }
        public class IF_OPTY_022_Req_IT_RTEXT1{
            @AuraEnabled public String VBELN_QU     {get;set;}
            @AuraEnabled public String POSNR_QU     {get;set;}
            @AuraEnabled public String EMP_NO       {get;set;}
            @AuraEnabled public String TDLINE       {get;set;}

            public IF_OPTY_022_Req_IT_RTEXT1(){}
        }
        public class IF_OPTY_022_Req_IT_RTEXT2{
            @AuraEnabled public String VBELN_QU     {get;set;}
            @AuraEnabled public String POSNR_QU     {get;set;}
            @AuraEnabled public String EMP_NO       {get;set;}
            @AuraEnabled public String TDLINE       {get;set;}

            public IF_OPTY_022_Req_IT_RTEXT2(){}
        }
        public class IF_OPTY_022_Res{
            @AuraEnabled public IF_OPTY_022_Res_O_RETURN O_RETURN {get;set;}

            public IF_OPTY_022_Res(){}
        }
        public class IF_OPTY_022_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_OPTY_022_Res_O_RETURN(){}
        }
}