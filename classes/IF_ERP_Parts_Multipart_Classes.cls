public with sharing class IF_ERP_Parts_Multipart_Classes {
    public IF_ERP_Parts_Multipart_Classes() {}

    /** SFDC interface Id    : IF-PARTS-022
     * RFC Name              : ZCRM_EP_PARTS_STANDARD_ME_SR
     * Description           : Parts > 부품정보 > 멀티부품정보조회
        */
        public class IF_PARTS_022_Req{
            @AuraEnabled public String                          I_LANGU     {get;set;}
            @AuraEnabled public String                          I_KVGR5     {get;set;}
            @AuraEnabled public List<IF_PARTS_022_Req_D_DETAIL> D_DETAIL    {get;set;}
            @AuraEnabled public IF_PARTS_022_Req_I_USERINFO     I_USERINFO  {get;set;}

            public IF_PARTS_022_Req(){
                this.I_LANGU        = '';
                this.I_KVGR5        = '';
                this.D_DETAIL       = new List<IF_PARTS_022_Req_D_DETAIL>();
                this.I_USERINFO     = new IF_PARTS_022_Req_I_USERINFO();
            }
        }
        public class IF_PARTS_022_Req_D_DETAIL{
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String MAKTX        {get;set;}
            @AuraEnabled public String SVC_FLAG     {get;set;}
            @AuraEnabled public String AVA_FLAG     {get;set;}

            @AuraEnabled public String NOTCD        {get;set;}
            @AuraEnabled public String COND_VALUE   {get;set;}
            @AuraEnabled public String NETPR        {get;set;}
            @AuraEnabled public String IF_CURRENCY  {get;set;}
            
            @AuraEnabled public String NETPR_ETC    {get;set;}
            @AuraEnabled public String CURRENCY2    {get;set;}
            @AuraEnabled public String KWMENG       {get;set;}
            @AuraEnabled public String AUMNG        {get;set;}
            
            @AuraEnabled public String LFMNG        {get;set;}
            @AuraEnabled public String MEINS        {get;set;}
            @AuraEnabled public String BRGEW        {get;set;}
            @AuraEnabled public String NTGEW        {get;set;}
            
            @AuraEnabled public String GEWEI        {get;set;}
            @AuraEnabled public String GROES        {get;set;}
            @AuraEnabled public String PRODH        {get;set;}
            @AuraEnabled public String PRODH_T      {get;set;}
            
            @AuraEnabled public String BULET        {get;set;}
            @AuraEnabled public String ZPRAT        {get;set;}
            @AuraEnabled public String HERKL        {get;set;}
            @AuraEnabled public String PLIFZ        {get;set;}
            
            @AuraEnabled public String M_MATNR      {get;set;}
            @AuraEnabled public String C_MTPOS      {get;set;}
            @AuraEnabled public String DATAB        {get;set;}
            @AuraEnabled public String KONDM        {get;set;}
            
            @AuraEnabled public String VTEXT        {get;set;}
            @AuraEnabled public String NOTCD_TEXT   {get;set;}
            @AuraEnabled public String SVRCD        {get;set;}
            @AuraEnabled public String AVAIL_QTY    {get;set;}
            @AuraEnabled public String AVAIL_QTY2    {get;set;}
            
            @AuraEnabled public String THREAD       {get;set;}
            @AuraEnabled public String D_MATERIAL   {get;set;}
            @AuraEnabled public String MANUFACT     {get;set;}
            @AuraEnabled public String REPLACE      {get;set;}
            @AuraEnabled public String SUB_MATERIAL {get;set;}
            @AuraEnabled public String SVCLT        {get;set;}


            public IF_PARTS_022_Req_D_DETAIL(){
                this.MATNR       = '';
                this.MAKTX       = '';
                this.SVC_FLAG    = '';
                this.AVA_FLAG    = '';
                this.NOTCD       = '';
                this.COND_VALUE  = '';
                this.NETPR       = '';
                this.IF_CURRENCY = '';
                this.NETPR_ETC   = '';
                this.CURRENCY2   = '';
                this.KWMENG      = '';
                this.AUMNG       = '';
                this.LFMNG       = '';
                this.MEINS       = '';
                this.BRGEW       = '';
                this.NTGEW       = '';
                this.GEWEI       = '';
                this.GROES       = '';
                this.PRODH       = '';
                this.PRODH_T     = '';
                this.BULET       = '';
                this.ZPRAT       = '';
                this.HERKL       = '';
                this.PLIFZ       = '';
                this.M_MATNR     = '';
                this.C_MTPOS     = '';
                this.DATAB       = '';
                this.KONDM       = '';
                this.VTEXT       = '';
                this.NOTCD_TEXT  = '';
                this.SVRCD       = '';
                this.AVAIL_QTY   = '';
                this.AVAIL_QTY2   = '';
                this.THREAD      = '';
                this.D_MATERIAL  = '';
                this.MANUFACT    = '';
                this.REPLACE     = '';
                this.SUB_MATERIAL= '';
                this.SVCLT       = '';
            }
        }
        public class IF_PARTS_022_Req_I_USERINFO{
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

            public IF_PARTS_022_Req_I_USERINFO(){
                this.BNAME      = '';
                this.RNAME      = '';
                this.HIER       = '';
                this.KUNNR      = '';
                this.LIFNR      = '';
                this.VKORG      = '';
                this.VTWEG      = '';
                this.SPART      = '';
                this.WERKS      = '';
                this.ARBPL      = '';
                this.PARNR      = '';
                this.ENAME      = '';
                this.KUNN2      = '';
                this.LAND1      = '';
                this.LGORT      = '';
                this.DF_CHK     = '';
                this.CO_CHK     = '';
            }
        }
        public class IF_PARTS_022_Res{
            @AuraEnabled public List<IF_PARTS_022_Res_D_DETAIL> D_DETAIL {get;set;}
            @AuraEnabled public IF_PARTS_022_Res_O_RETURN       O_RETURN {get;set;}
            @AuraEnabled public List<IF_PARTS_022_Res_T_RETURN> T_RETURN {get;set;}

            public IF_PARTS_022_Res(){}
        }
        public class IF_PARTS_022_Res_D_DETAIL{
            @AuraEnabled public String MATNR            {get;set;}
            @AuraEnabled public String MAKTX            {get;set;}
            @AuraEnabled public String SVC_FLAG         {get;set;}
            @AuraEnabled public String AVA_FLAG         {get;set;}

            @AuraEnabled public String NOTCD            {get;set;}
            @AuraEnabled public String COND_VALUE       {get;set;}
            @AuraEnabled public String NETPR            {get;set;}
            @AuraEnabled public String IF_CURRENCY      {get;set;}
            
            @AuraEnabled public String NETPR_ETC        {get;set;}
            @AuraEnabled public String CURRENCY2        {get;set;}
            @AuraEnabled public String KWMENG           {get;set;}
            @AuraEnabled public String AUMNG            {get;set;}
            
            @AuraEnabled public String LFMNG            {get;set;}
            @AuraEnabled public String MEINS            {get;set;}
            @AuraEnabled public String BRGEW            {get;set;}
            @AuraEnabled public String NTGEW            {get;set;}
            
            @AuraEnabled public String GEWEI            {get;set;}
            @AuraEnabled public String GROES            {get;set;}
            @AuraEnabled public String PRODH            {get;set;}
            @AuraEnabled public String PRODH_T          {get;set;}
            
            @AuraEnabled public String BULET            {get;set;}
            @AuraEnabled public String ZPRAT            {get;set;}
            @AuraEnabled public String HERKL            {get;set;}
            @AuraEnabled public String PLIFZ            {get;set;}
            
            @AuraEnabled public String M_MATNR          {get;set;}
            @AuraEnabled public String C_MTPOS          {get;set;}
            @AuraEnabled public String DATAB            {get;set;}
            @AuraEnabled public String KONDM            {get;set;}
            
            @AuraEnabled public String VTEXT            {get;set;}
            @AuraEnabled public String NOTCD_TEXT       {get;set;}
            @AuraEnabled public String SVRCD            {get;set;}
            @AuraEnabled public String AVAIL_QTY        {get;set;}
            
            @AuraEnabled public String THREAD           {get;set;}
            @AuraEnabled public String D_MATERIAL       {get;set;}
            @AuraEnabled public String MANUFACT         {get;set;}
            @AuraEnabled public String REPLACE          {get;set;}
            
            @AuraEnabled public String SUB_MATERIAL     {get;set;}
            @AuraEnabled public String SVCLT            {get;set;}
            @AuraEnabled public String MIN_QTY          {get;set;}
            @AuraEnabled public String AVAIL_QTY2       {get;set;}


            public IF_PARTS_022_Res_D_DETAIL(){}
        }
        public class IF_PARTS_022_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}
            
            public IF_PARTS_022_Res_O_RETURN(){}
        }
        public class IF_PARTS_022_Res_T_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_PARTS_022_Res_T_RETURN(){}
        }
        
}