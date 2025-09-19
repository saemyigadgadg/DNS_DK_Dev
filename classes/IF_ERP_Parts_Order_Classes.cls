public with sharing class IF_ERP_Parts_Order_Classes {
    public IF_ERP_Parts_Order_Classes() {}

    // SFDC interface Id    : IF-PARTS-001
    // AS-IS RFC            : Z_EP_GET_ORDERTYPE2
    // New I/F              : ZCRM_EP_GET_ORDERTYPE2
    // Description          : 주문유형 Code 값 조회 및 저장
    public class IF_PARTS_001_Req{
        @AuraEnabled public String I_VKORG      {get;set;}
        @AuraEnabled public String I_VTWEG      {get;set;}
        @AuraEnabled public String I_KUNNR      {get;set;}
        @AuraEnabled public String I_SPART      {get;set;}

        @AuraEnabled public String I_AUART      {get;set;}
        @AuraEnabled public String I_LANG       {get;set;}
        @AuraEnabled public String I_VBTYP      {get;set;}
        @AuraEnabled public String I_STATUS     {get;set;}
        
        @AuraEnabled public String I_VBELN      {get;set;}
        
        public IF_PARTS_001_Req(){}
    }
    public class IF_PARTS_001_Res{
        @AuraEnabled public String E_KDGRP                          {get;set;}
        @AuraEnabled public List<IF_PARTS_001_Res_T_ZSSV0002> T_ZSSV0002  {get;set;}

        public IF_PARTS_001_Res(){}
    }
    public class IF_PARTS_001_Res_T_ZSSV0002{
        @AuraEnabled public String KONDA        {get;set;}
        @AuraEnabled public String ZZAUKON      {get;set;}
        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}

        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String KDGRP        {get;set;}
        @AuraEnabled public String AUART        {get;set;}
        @AuraEnabled public String VBTYP        {get;set;}
        
        @AuraEnabled public String STATUS       {get;set;}
        @AuraEnabled public String RDDAT        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String DEFFLG       {get;set;}

        public IF_PARTS_001_Res_T_ZSSV0002(){}
    }

    /**  SFDC interface Id    : IF-PARTS-003
     *   AS-IS RFC            : Z_EP_ORDER_SIMULATION
     *   New I/F              : ZCRM_EP_ORDER_SIMULATION
     *   Description          : 부품 오더 조회
    */
    public class IF_PARTS_003_Req{
        @AuraEnabled public IF_PARTS_003_Req_I_USERINFO                 I_USERINFO          {get;set;}
        @AuraEnabled public IF_PARTS_003_Req_LS_MAIN_HEAD               LS_MAIN_HEAD        {get;set;}
        @AuraEnabled public IF_PARTS_003_Req_LS_ERROR_IGNORE            LS_ERROR_IGNORE     {get;set;}
        @AuraEnabled public String                                      LS_APPLY            {get;set;}
        @AuraEnabled public IF_PARTS_003_Req_LS_IMPORT_PORTAL           LS_IMPORT_PORTAL    {get;set;}

        @AuraEnabled public String                                      LV_AUART            {get;set;}
        @AuraEnabled public String                                      I_USERID            {get;set;}
        @AuraEnabled public IF_PARTS_003_Req_I_ORG                      I_ORG               {get;set;}
        @AuraEnabled public String                                      I_LANGU             {get;set;}
        
        @AuraEnabled public String                                      I_SHIPTO            {get;set;}
        @AuraEnabled public String                                      I_DATE              {get;set;}
        @AuraEnabled public String                                      I_CS                {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Req_LT_GERNERAL_ZTERM>    LT_GERNERAL_ZTERM   {get;set;}
        
        @AuraEnabled public List<IF_PARTS_003_Req_LT_PARTNER>           LT_PARTNER          {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Req_LT_ITEM>              LT_ITEM             {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Req_LT_STATUS>            LT_STATUS           {get;set;}

        public IF_PARTS_003_Req(){
            this.I_USERINFO         = new IF_PARTS_003_Req_I_USERINFO();
            this.LS_MAIN_HEAD       = new IF_PARTS_003_Req_LS_MAIN_HEAD();
            this.LS_ERROR_IGNORE    = new IF_PARTS_003_Req_LS_ERROR_IGNORE();
            this.LS_IMPORT_PORTAL   = new IF_PARTS_003_Req_LS_IMPORT_PORTAL();
            this.LT_GERNERAL_ZTERM  = new List<IF_PARTS_003_Req_LT_GERNERAL_ZTERM>();
            this.LT_PARTNER         = new List<IF_PARTS_003_Req_LT_PARTNER>();
            this.LT_ITEM            = new List<IF_PARTS_003_Req_LT_ITEM>();
            this.LT_STATUS          = new List<IF_PARTS_003_Req_LT_STATUS>();
        }
    }
    public class IF_PARTS_003_Req_I_USERINFO{
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

        public IF_PARTS_003_Req_I_USERINFO(){}
    }
    public class IF_PARTS_003_Req_LS_MAIN_HEAD{
        @AuraEnabled public String KONDA            {get;set;}
        @AuraEnabled public String KUNNR            {get;set;}
        @AuraEnabled public String KUNNR_NAME       {get;set;}
        @AuraEnabled public String KUNNR_STREET     {get;set;}
        @AuraEnabled public String KUNAG            {get;set;}

        @AuraEnabled public String KUNAG_NAME       {get;set;}
        @AuraEnabled public String KUNAG_STREET     {get;set;}
        @AuraEnabled public String KUNNR_CR         {get;set;}
        @AuraEnabled public String NETWR            {get;set;}
        @AuraEnabled public String WAERK            {get;set;}
        
        @AuraEnabled public String CREDIT           {get;set;}
        @AuraEnabled public String CREDIT_WAERK     {get;set;}
        @AuraEnabled public String TOTAL_WEIGHT     {get;set;}
        @AuraEnabled public String GEWEI            {get;set;}
        @AuraEnabled public String VOLUM            {get;set;}
        
        @AuraEnabled public String VOLEH            {get;set;}
        @AuraEnabled public String KONDA_TEXT       {get;set;}
        @AuraEnabled public String KVGR5            {get;set;}
        @AuraEnabled public String NAME             {get;set;}
        @AuraEnabled public String CITY             {get;set;}
        
        @AuraEnabled public String STREET           {get;set;}
        @AuraEnabled public String COUNTRY          {get;set;}
        @AuraEnabled public String POSTL_CODE       {get;set;}
        @AuraEnabled public String TRANSPZONE       {get;set;}
        @AuraEnabled public String ORDER_DATE       {get;set;}
        
        @AuraEnabled public String PRICE_LIST       {get;set;}
        @AuraEnabled public String COLLECT_NO       {get;set;}
        @AuraEnabled public String ZTERM            {get;set;}
        @AuraEnabled public String ORD_REASON       {get;set;}
        @AuraEnabled public String BZIRK            {get;set;}
        
        @AuraEnabled public String DOCUFEE          {get;set;}

        public IF_PARTS_003_Req_LS_MAIN_HEAD(){}
    }
    public class IF_PARTS_003_Req_LS_ERROR_IGNORE{
        @AuraEnabled public String IGNORE           {get;set;}
        @AuraEnabled public String IGNORE_QTY       {get;set;}
        @AuraEnabled public String IGNORE_PRICE     {get;set;}
        @AuraEnabled public String IGNORE_DIVISION  {get;set;}
        @AuraEnabled public String IGNORE_PURCHASE  {get;set;}

        @AuraEnabled public String IGNORE_HAZARD    {get;set;}

        public IF_PARTS_003_Req_LS_ERROR_IGNORE(){}
    }
    public class IF_PARTS_003_Req_LS_IMPORT_PORTAL{
        @AuraEnabled public String DOC_CATEGORY {get;set;}
        @AuraEnabled public String DOC_MODE     {get;set;}
        @AuraEnabled public String COMPLAINT    {get;set;}

        public IF_PARTS_003_Req_LS_IMPORT_PORTAL(){}
    }
    public class IF_PARTS_003_Req_I_ORG{
        @AuraEnabled public String VKORG    {get;set;}
        @AuraEnabled public String VTWEG    {get;set;}
        @AuraEnabled public String SPART    {get;set;}
        @AuraEnabled public String WERKS    {get;set;}
        @AuraEnabled public String ARBPL    {get;set;}

        @AuraEnabled public String AMSCCTL  {get;set;}

        public IF_PARTS_003_Req_I_ORG(){}
    }
    public class IF_PARTS_003_Req_LT_GERNERAL_ZTERM{
        @AuraEnabled public String ZTERM  {get;set;}
        @AuraEnabled public String TEXT   {get;set;}

        public IF_PARTS_003_Req_LT_GERNERAL_ZTERM(){}
    }
    public class IF_PARTS_003_Req_LT_PARTNER{
        @AuraEnabled public String PARTN_ROLE   {get;set;}
        @AuraEnabled public String PARTN_NUMB   {get;set;}
        @AuraEnabled public String ITM_NUMBER   {get;set;}
        @AuraEnabled public String TITLE        {get;set;}
        @AuraEnabled public String NAME         {get;set;}

        @AuraEnabled public String NAME_2       {get;set;}
        @AuraEnabled public String NAME_3       {get;set;}
        @AuraEnabled public String NAME_4       {get;set;}
        @AuraEnabled public String STREET       {get;set;}
        @AuraEnabled public String COUNTRY      {get;set;}
        
        @AuraEnabled public String COUNTR_ISO   {get;set;}
        @AuraEnabled public String POSTL_CODE   {get;set;}
        @AuraEnabled public String POBX_PCD     {get;set;}
        @AuraEnabled public String POBX_CTY     {get;set;}
        @AuraEnabled public String CITY         {get;set;}
        
        @AuraEnabled public String DISTRICT     {get;set;}
        @AuraEnabled public String REGION       {get;set;}
        @AuraEnabled public String PO_BOX       {get;set;}
        @AuraEnabled public String TELEPHONE    {get;set;}
        @AuraEnabled public String TELEPHONE2   {get;set;}
        
        @AuraEnabled public String TELEBOX      {get;set;}
        @AuraEnabled public String FAX_NUMBER   {get;set;}
        @AuraEnabled public String TELETEX_NO   {get;set;}
        @AuraEnabled public String TELEX_NO     {get;set;}
        @AuraEnabled public String LANGU        {get;set;}
        
        @AuraEnabled public String LANGU_ISO    {get;set;}
        @AuraEnabled public String UNLOAD_PT    {get;set;}
        @AuraEnabled public String TRANSPZONE   {get;set;}
        @AuraEnabled public String TAXJURCODE   {get;set;}
        @AuraEnabled public String ADDRESS      {get;set;}
        
        @AuraEnabled public String PRIV_ADDR    {get;set;}
        @AuraEnabled public String ADDR_TYPE    {get;set;}
        @AuraEnabled public String ADDR_ORIG    {get;set;}
        @AuraEnabled public String ADDR_LINK    {get;set;}
        @AuraEnabled public String REFOBJTYPE   {get;set;}
        
        @AuraEnabled public String REFOBJKEY    {get;set;}
        @AuraEnabled public String REFLOGSYS    {get;set;}

        public IF_PARTS_003_Req_LT_PARTNER(){}
    }
    public class IF_PARTS_003_Req_LT_ITEM{
        @AuraEnabled public String CCHECK           {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String MATERIAL         {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}

        @AuraEnabled public String QTY              {get;set;}
        @AuraEnabled public String UOM              {get;set;}
        @AuraEnabled public String NET_PRICE        {get;set;}
        @AuraEnabled public String NET_ITEM_PRICE   {get;set;}
        @AuraEnabled public String NET_VALUE        {get;set;}
        
        @AuraEnabled public String LIST_PRICE       {get;set;}
        @AuraEnabled public String IF_CURRENCY      {get;set;}
        @AuraEnabled public String AVAILABILITY     {get;set;}
        @AuraEnabled public String REF_ORD          {get;set;}
        @AuraEnabled public String REF_ITEM         {get;set;}
        
        @AuraEnabled public String COMPLAINT        {get;set;}
        @AuraEnabled public String COMPLAINT_DESC   {get;set;}
        @AuraEnabled public String PLANT            {get;set;}
        @AuraEnabled public String O                {get;set;}
        @AuraEnabled public String C                {get;set;}
        
        @AuraEnabled public String D                {get;set;}
        @AuraEnabled public String BD               {get;set;}
        @AuraEnabled public String BO               {get;set;}
        @AuraEnabled public String DB               {get;set;}
        @AuraEnabled public String R                {get;set;}
        
        @AuraEnabled public String PLANT_TX         {get;set;}
        @AuraEnabled public String USAGE_HILV       {get;set;}
        @AuraEnabled public String CHEKCABLE        {get;set;}
        @AuraEnabled public String MATNR_CHECK      {get;set;}
        @AuraEnabled public String A                {get;set;}
        
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String MATNR_DESIGN     {get;set;}
        @AuraEnabled public String REQ_QTY_DESIGN   {get;set;}
        
        @AuraEnabled public String ZZDEALDT         {get;set;}
        @AuraEnabled public String WAERS            {get;set;}
        @AuraEnabled public String REASON           {get;set;}
        @AuraEnabled public String INPUT_QTY        {get;set;}
        @AuraEnabled public String EXCEL            {get;set;}
        
        @AuraEnabled public String MVGR5            {get;set;}
        @AuraEnabled public String MATERIAL_ENT     {get;set;}
        @AuraEnabled public String ERRORCHECK       {get;set;}
        @AuraEnabled public String ERRORMSG         {get;set;}
        @AuraEnabled public String SUGRD            {get;set;}
        
        @AuraEnabled public String COMPLAINT_REASON {get;set;}
        @AuraEnabled public String ACCEPT           {get;set;}
        @AuraEnabled public String MATERIAL_N       {get;set;}
        @AuraEnabled public String NETPR            {get;set;}
        @AuraEnabled public String DIEUCE           {get;set;}
        
        @AuraEnabled public String DIEUFL           {get;set;}
        @AuraEnabled public String DIUK             {get;set;}
        @AuraEnabled public String DIID             {get;set;}
        @AuraEnabled public String DI               {get;set;}
        @AuraEnabled public String DIUKL            {get;set;}
        
        @AuraEnabled public String MEINS            {get;set;}
        @AuraEnabled public String HERKL            {get;set;}
        @AuraEnabled public String KONDM            {get;set;}
        @AuraEnabled public String NTGEW            {get;set;}
        @AuraEnabled public String GEWEI            {get;set;}
        
        @AuraEnabled public String POUND            {get;set;}
        @AuraEnabled public String KUNNR            {get;set;}
        @AuraEnabled public String TDLNR            {get;set;}
        @AuraEnabled public String TDLNR_NAME       {get;set;}
        @AuraEnabled public String BSTKD_E          {get;set;}
        
        @AuraEnabled public String BSTDK_E          {get;set;}
        @AuraEnabled public String AVAIL_QTY1       {get;set;}
        @AuraEnabled public String AVAIL_QTY2       {get;set;}
        @AuraEnabled public String ZZAPPMACHINE     {get;set;}
        @AuraEnabled public String ZZEQMASTER       {get;set;}
        @AuraEnabled public String ZZWORKHRS        {get;set;}
        
        @AuraEnabled public String TNDR_TRKID       {get;set;}
        @AuraEnabled public String STATUS           {get;set;}
        @AuraEnabled public String MITEM            {get;set;}
        @AuraEnabled public String TO_PART          {get;set;}
        @AuraEnabled public String BULLETIN         {get;set;}
        
        @AuraEnabled public String BULL_MATNR       {get;set;}
        @AuraEnabled public String MEMO             {get;set;}
        @AuraEnabled public String MEMO_MATNR       {get;set;}
        @AuraEnabled public String EMERC            {get;set;}

        public IF_PARTS_003_Req_LT_ITEM(){}
    }
    public class IF_PARTS_003_Req_LT_STATUS{
        @AuraEnabled public String CODE             {get;set;}
        @AuraEnabled public String TEXT             {get;set;}
        @AuraEnabled public String NAME             {get;set;}

        public IF_PARTS_003_Req_LT_STATUS(){}
    }
    public class IF_PARTS_003_Res{
        @AuraEnabled public IF_PARTS_003_Res_LS_MAIN_HEAD_RESULT          LS_MAIN_HEAD_RESULT  {get;set;}
        @AuraEnabled public String                                        E_MEG                {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_ITEM>                LT_ITEM              {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_PRICING_01>          LT_PRICING_01        {get;set;}
        
        @AuraEnabled public List<IF_PARTS_003_Res_LT_PRICING_02>          LT_PRICING_02        {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_STATUS>              LT_STATUS            {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_IF_RETURN>              IF_RETURN            {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_ERRORMSG>               ERRORMSG             {get;set;}
        
        @AuraEnabled public List<IF_PARTS_003_Res_LT_NON_EXIST>           LT_NON_EXIST         {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_NON_QTY>             LT_NON_QTY           {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_WRONG_DIVISION>      LT_WRONG_DIVISION    {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_NON_PRICE>           LT_NON_PRICE         {get;set;}
        
        @AuraEnabled public List<IF_PARTS_003_Res_LT_NON_PURCHASE>        LT_NON_PURCHASE      {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_BAPIRET2>            LT_BAPIRET2          {get;set;}
        @AuraEnabled public List<IF_PARTS_003_Res_LT_WRONG_ITEM>          LT_WRONG_ITEM        {get;set;}
        @AuraEnabled public IF_PARTS_003_Res_LS_GENERAL                   LS_GENERAL           {get;set;}

        @AuraEnabled public IF_PARTS_003_Res_O_RETURN                     O_RETURN             {get;set;}

        public IF_PARTS_003_Res(){}
    }
    public class IF_PARTS_003_Res_LS_MAIN_HEAD_RESULT{
        @AuraEnabled public String KONDA                {get;set;}
        @AuraEnabled public String KUNNR                {get;set;}
        @AuraEnabled public String KUNNR_NAME           {get;set;}
        @AuraEnabled public String KUNNR_STREET         {get;set;}
        @AuraEnabled public String KUNAG                {get;set;}
        
        @AuraEnabled public String KUNAG_NAME           {get;set;}
        @AuraEnabled public String KUNAG_STREET         {get;set;}
        @AuraEnabled public String KUNNR_CR             {get;set;}
        @AuraEnabled public String NETWR                {get;set;}
        @AuraEnabled public String WAERK                {get;set;}
        
        @AuraEnabled public String CREDIT               {get;set;}
        @AuraEnabled public String CREDIT_WAERK         {get;set;}
        @AuraEnabled public String TOTAL_WEIGHT         {get;set;}
        @AuraEnabled public String GEWEI                {get;set;}
        @AuraEnabled public String VOLUM                {get;set;}
        
        @AuraEnabled public String VOLEH                {get;set;}
        @AuraEnabled public String KONDA_TEXT           {get;set;}
        @AuraEnabled public String KVGR5                {get;set;}
        @AuraEnabled public String NAME                 {get;set;}
        @AuraEnabled public String CITY                 {get;set;}
        
        @AuraEnabled public String STREET               {get;set;}
        @AuraEnabled public String COUNTRY              {get;set;}
        @AuraEnabled public String POSTL_CODE           {get;set;}
        @AuraEnabled public String TRANSPZONE           {get;set;}
        @AuraEnabled public String ORDER_DATE           {get;set;}
        
        @AuraEnabled public String PRICE_LIST           {get;set;}
        @AuraEnabled public String COLLECT_NO           {get;set;}
        @AuraEnabled public String ZTERM                {get;set;}
        @AuraEnabled public String ORD_REASON           {get;set;}
        @AuraEnabled public String BZIRK                {get;set;}
        
        @AuraEnabled public String DOCUFEE              {get;set;}

        public IF_PARTS_003_Res_LS_MAIN_HEAD_RESULT(){}
    }
    public class IF_PARTS_003_Res_LT_ITEM{
        @AuraEnabled public String CCHECK               {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String MATERIAL             {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}

        @AuraEnabled public String QTY                  {get;set;}
        @AuraEnabled public String UOM                  {get;set;}
        @AuraEnabled public String NET_PRICE            {get;set;}
        @AuraEnabled public String NET_ITEM_PRICE       {get;set;}
        @AuraEnabled public String NET_VALUE            {get;set;}
        
        @AuraEnabled public String LIST_PRICE           {get;set;}
        @AuraEnabled public String IF_CURRENCY          {get;set;}
        @AuraEnabled public String AVAILABILITY         {get;set;}
        @AuraEnabled public String REF_ORD              {get;set;}
        @AuraEnabled public String REF_ITEM             {get;set;}
        
        @AuraEnabled public String COMPLAINT            {get;set;}
        @AuraEnabled public String COMPLAINT_DESC       {get;set;}
        @AuraEnabled public String PLANT                {get;set;}
        @AuraEnabled public String O                    {get;set;}
        @AuraEnabled public String C                    {get;set;}
        
        @AuraEnabled public String D                    {get;set;}
        @AuraEnabled public String BD                   {get;set;}
        @AuraEnabled public String BO                   {get;set;}
        @AuraEnabled public String DB                   {get;set;}
        @AuraEnabled public String R                    {get;set;}
        
        @AuraEnabled public String PLANT_TX             {get;set;}
        @AuraEnabled public String USAGE_HILV           {get;set;}
        @AuraEnabled public String CHEKCABLE            {get;set;}
        @AuraEnabled public String MATNR_CHECK          {get;set;}
        @AuraEnabled public String A                    {get;set;}
        
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String MATNR_DESIGN         {get;set;}
        @AuraEnabled public String REQ_QTY_DESIGN       {get;set;}
        
        @AuraEnabled public String ZZDEALDT             {get;set;}
        @AuraEnabled public String WAERS                {get;set;}
        @AuraEnabled public String REASON               {get;set;}
        @AuraEnabled public String INPUT_QTY            {get;set;}
        @AuraEnabled public String EXCEL                {get;set;}
        
        @AuraEnabled public String MVGR5                {get;set;}
        @AuraEnabled public String MATERIAL_ENT         {get;set;}
        @AuraEnabled public String ERRORCHECK           {get;set;}
        @AuraEnabled public String ERRORMSG             {get;set;}
        @AuraEnabled public String SUGRD                {get;set;}
        
        @AuraEnabled public String COMPLAINT_REASON     {get;set;}
        @AuraEnabled public String ACCEPT               {get;set;}
        @AuraEnabled public String MATERIAL_N           {get;set;}
        @AuraEnabled public String NETPR                {get;set;}
        @AuraEnabled public String DIEUCE               {get;set;}

        @AuraEnabled public String DIEUFL               {get;set;}
        @AuraEnabled public String DIUK                 {get;set;}
        @AuraEnabled public String DIID                 {get;set;}
        @AuraEnabled public String DI                   {get;set;}
        @AuraEnabled public String DIUKL                {get;set;}
        
        @AuraEnabled public String MEINS                {get;set;}
        @AuraEnabled public String HERKL                {get;set;}
        @AuraEnabled public String KONDM                {get;set;}
        @AuraEnabled public String NTGEW                {get;set;}
        @AuraEnabled public String GEWEI                {get;set;}
        
        @AuraEnabled public String POUND                {get;set;}        
        @AuraEnabled public String KUNNR                {get;set;}
        @AuraEnabled public String TDLNR                {get;set;}
        @AuraEnabled public String TDLNR_NAME           {get;set;}
        @AuraEnabled public String BSTKD_E              {get;set;}
        
        @AuraEnabled public String BSTDK_E              {get;set;}
        @AuraEnabled public String AVAIL_QTY1           {get;set;}
        @AuraEnabled public String AVAIL_QTY2           {get;set;}
        @AuraEnabled public String ZZAPPMACHINE         {get;set;}
        @AuraEnabled public String ZZEQMASTER           {get;set;}
        @AuraEnabled public String ZZWORKHRS            {get;set;}
        
        @AuraEnabled public String TNDR_TRKID           {get;set;}
        @AuraEnabled public String STATUS               {get;set;}
        @AuraEnabled public String MITEM                {get;set;}
        @AuraEnabled public String TO_PART              {get;set;}
        @AuraEnabled public String BULLETIN             {get;set;}
        
        @AuraEnabled public String BULL_MATNR           {get;set;}
        @AuraEnabled public String MEMO                 {get;set;}
        @AuraEnabled public String MEMO_MATNR           {get;set;}
        @AuraEnabled public String EMERC                {get;set;}
        
        public IF_PARTS_003_Res_LT_ITEM(){}
    }
    public class IF_PARTS_003_Res_LT_PRICING_01{
        @AuraEnabled public String NAME     {get;set;}
        @AuraEnabled public String NEWR     {get;set;}
        @AuraEnabled public String WAERK    {get;set;}
        @AuraEnabled public String NETWR    {get;set;}

        public IF_PARTS_003_Res_LT_PRICING_01(){}
    }
    public class IF_PARTS_003_Res_LT_PRICING_02{
        @AuraEnabled public String NAME     {get;set;}
        @AuraEnabled public String NEWR     {get;set;}
        @AuraEnabled public String WAERK    {get;set;}
        @AuraEnabled public String NETWR    {get;set;}

        public IF_PARTS_003_Res_LT_PRICING_02(){}
    }
    public class IF_PARTS_003_Res_LT_STATUS{
        @AuraEnabled public String CODE {get;set;}
        @AuraEnabled public String TEXT {get;set;}
        @AuraEnabled public String NAME {get;set;}

        public IF_PARTS_003_Res_LT_STATUS(){}
    }
    public class IF_PARTS_003_Res_IF_RETURN{
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
        
        public IF_PARTS_003_Res_IF_RETURN(){}
    }
    public class IF_PARTS_003_Res_ERRORMSG{
        @AuraEnabled public String NAME {get;set;}
        @AuraEnabled public String TEXT {get;set;}

        public IF_PARTS_003_Res_ERRORMSG(){}
    }
    public class IF_PARTS_003_Res_LT_NON_EXIST{
        @AuraEnabled public String ERROR_MATNR          {get;set;}
        @AuraEnabled public String APPLY                {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String ID                   {get;set;}

        @AuraEnabled public String IF_NUMBER            {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String NOTCD                {get;set;}
        @AuraEnabled public String NOTCD_TEXT           {get;set;}
        @AuraEnabled public String PO_ITM_NO            {get;set;}

        public IF_PARTS_003_Res_LT_NON_EXIST(){}
    }
    public class IF_PARTS_003_Res_LT_NON_QTY{
        @AuraEnabled public String ERROR_MATNR      {get;set;}
        @AuraEnabled public String APPLY            {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String ID               {get;set;}

        @AuraEnabled public String IF_NUMBER        {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String NOTCD            {get;set;}
        @AuraEnabled public String NOTCD_TEXT       {get;set;}
        @AuraEnabled public String PO_ITM_NO        {get;set;}

        public IF_PARTS_003_Res_LT_NON_QTY(){}
    }
    public class IF_PARTS_003_Res_LT_WRONG_DIVISION{
        @AuraEnabled public String ERROR_MATNR          {get;set;}
        @AuraEnabled public String APPLY                {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String ID                   {get;set;}

        @AuraEnabled public String IF_NUMBER            {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String NOTCD                {get;set;}
        @AuraEnabled public String NOTCD_TEXT           {get;set;}
        @AuraEnabled public String PO_ITM_NO            {get;set;}
        
        public IF_PARTS_003_Res_LT_WRONG_DIVISION(){}
    }
    public class IF_PARTS_003_Res_LT_NON_PRICE{
        @AuraEnabled public String ERROR_MATNR      {get;set;}
        @AuraEnabled public String APPLY            {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String ID               {get;set;}

        @AuraEnabled public String IF_NUMBER        {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String NOTCD            {get;set;}
        @AuraEnabled public String NOTCD_TEXT       {get;set;}
        @AuraEnabled public String PO_ITM_NO        {get;set;}

        public IF_PARTS_003_Res_LT_NON_PRICE(){}
    }
    public class IF_PARTS_003_Res_LT_NON_PURCHASE{
        @AuraEnabled public String ERROR_MATNR      {get;set;}
        @AuraEnabled public String APPLY            {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String ID               {get;set;}

        @AuraEnabled public String IF_NUMBER        {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String NOTCD            {get;set;}
        @AuraEnabled public String NOTCD_TEXT       {get;set;}
        @AuraEnabled public String PO_ITM_NO        {get;set;}

        public IF_PARTS_003_Res_LT_NON_PURCHASE(){}
    }
    public class IF_PARTS_003_Res_LT_BAPIRET2{
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
        
        public IF_PARTS_003_Res_LT_BAPIRET2(){}
    }
    public class IF_PARTS_003_Res_LT_WRONG_ITEM{
        @AuraEnabled public String ERROR_MATNR          {get;set;}
        @AuraEnabled public String APPLY                {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String ID                   {get;set;}

        @AuraEnabled public String IF_NUMBER            {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String NOTCD                {get;set;}
        @AuraEnabled public String NOTCD_TEXT           {get;set;}
        @AuraEnabled public String PO_ITM_NO            {get;set;}
        
        public IF_PARTS_003_Res_LT_WRONG_ITEM(){}
    }
    public class IF_PARTS_003_Res_LS_GENERAL{
        @AuraEnabled public String BSTNK                {get;set;}
        @AuraEnabled public String VDATU                {get;set;}
        @AuraEnabled public String INCO1                {get;set;}
        @AuraEnabled public String INCO2                {get;set;}
        @AuraEnabled public String VSBED                {get;set;}

        @AuraEnabled public String COMPLETE_DELIVERY    {get;set;}
        @AuraEnabled public String ROUTE                {get;set;}
        @AuraEnabled public String VSBED_TX             {get;set;}
        @AuraEnabled public String ROUTE_TX             {get;set;}
        @AuraEnabled public String SPECPROCID           {get;set;}
        
        @AuraEnabled public String POSSIBLE_DATE        {get;set;}
        @AuraEnabled public String IF_FROM              {get;set;}
        @AuraEnabled public String TO                   {get;set;}
        @AuraEnabled public String AUDAT                {get;set;}
        @AuraEnabled public String ERZET                {get;set;}
        
        @AuraEnabled public String BSTKD_E              {get;set;}
        @AuraEnabled public String ZZCFDAT              {get;set;}

        public IF_PARTS_003_Res_LS_GENERAL(){}
    }
    public class IF_PARTS_003_Res_O_RETURN{
        @AuraEnabled public String TYPE                 {get;set;}
        @AuraEnabled public String CODE                 {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}

        public IF_PARTS_003_Res_O_RETURN(){}
    }

    /** SFDC interface Id   : IF-PARTS-005
     *  AS-IS RFC            : Z_EP_PARTS_ORDER_CREATE
     *  New I/F              : ZCRM_EP_PARTS_ORDER_CREATE
     *  Description          : (대리점=> DNS) 오더 생성을 위한 I/F 호출
    */
    public class IF_PARTS_005_Req{
        @AuraEnabled public String                              LV_AUART            {get;set;}
        @AuraEnabled public IF_PARTS_005_Req_LS_MAIN_HEAD       LS_MAIN_HEAD        {get;set;}
        @AuraEnabled public IF_PARTS_005_Req_LS_GENERAL         LS_GENERAL          {get;set;}
        @AuraEnabled public String                              LV_MATERIAL         {get;set;}
        @AuraEnabled public IF_PARTS_005_Req_LS_IMPORT_PORTAL   LS_IMPORT_PORTAL    {get;set;}
        
        @AuraEnabled public String                              LV_ADDRESS          {get;set;}
        @AuraEnabled public String                              LV_REMARK           {get;set;}
        @AuraEnabled public IF_PARTS_005_Req_LS_SELECTED_ITEM   LS_SELECTED_ITEM    {get;set;}
        @AuraEnabled public IF_PARTS_005_Req_LS_EP_ONETIME      LS_EP_ONETIME       {get;set;}
        @AuraEnabled public String                              I_USERID            {get;set;}

        @AuraEnabled public IF_PARTS_005_Req_I_ORG              I_ORG               {get;set;}
        @AuraEnabled public String                              I_LANGU             {get;set;}
        @AuraEnabled public String                              I_SHIPTO            {get;set;}
        @AuraEnabled public String                              I_FORWARDER         {get;set;}
        @AuraEnabled public String                              I_VKORG             {get;set;}

        @AuraEnabled public String                              I_VTWEG             {get;set;}
        @AuraEnabled public String                              I_SPART             {get;set;}
        @AuraEnabled public String                              I_KUNNR             {get;set;}
        @AuraEnabled public List<IF_PARTS_005_Req_LT_GERNERAL_ZTERM>  LT_GERNERAL_ZTERM   {get;set;}
        @AuraEnabled public List<IF_PARTS_005_Req_LT_ITEM>            LT_ITEM             {get;set;}

        
        @AuraEnabled public List<IF_PARTS_005_Req_LT_FILE>            LT_FILE             {get;set;}
        @AuraEnabled public List<IF_PARTS_005_Req_LT_PARTNER>         LT_PARTNER          {get;set;}

        public IF_PARTS_005_Req(){
            this.LV_AUART       = '';
            this.LV_MATERIAL    = '';
            this.LV_ADDRESS     = '';
            this.LV_REMARK      = '';
            this.I_USERID       = '';
            this.I_LANGU        = '';
            this.I_SHIPTO       = '';
            this.I_FORWARDER    = '';
            this.I_VKORG        = '';
            this.I_VTWEG        = '';
            this.I_SPART        = '';
            this.I_KUNNR        = '';

            this.LS_MAIN_HEAD           = new IF_PARTS_005_Req_LS_MAIN_HEAD();
            this.LS_GENERAL             = new IF_PARTS_005_Req_LS_GENERAL();
            this.LS_IMPORT_PORTAL       = new IF_PARTS_005_Req_LS_IMPORT_PORTAL();
            this.LS_SELECTED_ITEM       = new IF_PARTS_005_Req_LS_SELECTED_ITEM();
            this.LS_EP_ONETIME          = new IF_PARTS_005_Req_LS_EP_ONETIME();
            this.I_ORG                  = new IF_PARTS_005_Req_I_ORG();

            this.LT_GERNERAL_ZTERM      = new List<IF_PARTS_005_Req_LT_GERNERAL_ZTERM>();
            this.LT_ITEM                = new List<IF_PARTS_005_Req_LT_ITEM>();
            this.LT_FILE                = new List<IF_PARTS_005_Req_LT_FILE>();
            this.LT_PARTNER             = new List<IF_PARTS_005_Req_LT_PARTNER>();
        }
    }
    public class IF_PARTS_005_Req_LS_MAIN_HEAD{
        @AuraEnabled public String KONDA                    {get;set;}
        @AuraEnabled public String KUNNR                    {get;set;}
        @AuraEnabled public String KUNNR_NAME               {get;set;}
        @AuraEnabled public String KUNNR_STREET             {get;set;}

        @AuraEnabled public String KUNAG                    {get;set;}
        @AuraEnabled public String KUNAG_NAME               {get;set;}
        @AuraEnabled public String KUNAG_STREET             {get;set;}
        @AuraEnabled public String KUNNR_CR                 {get;set;}
        
        @AuraEnabled public String NETWR                    {get;set;}
        @AuraEnabled public String WAERK                    {get;set;}
        @AuraEnabled public String CREDIT                   {get;set;}
        @AuraEnabled public String CREDIT_WAERK             {get;set;}

        @AuraEnabled public String TOTAL_WEIGHT             {get;set;}
        @AuraEnabled public String GEWEI                    {get;set;}
        @AuraEnabled public String VOLUM                    {get;set;}
        @AuraEnabled public String VOLEH                    {get;set;}
        
        @AuraEnabled public String KONDA_TEXT               {get;set;}
        @AuraEnabled public String KVGR5                    {get;set;}
        @AuraEnabled public String NAME                     {get;set;}
        @AuraEnabled public String CITY                     {get;set;}
        
        @AuraEnabled public String STREET                   {get;set;}
        @AuraEnabled public String COUNTRY                  {get;set;}
        @AuraEnabled public String POSTL_CODE               {get;set;}
        @AuraEnabled public String TRANSPZONE               {get;set;}
        
        @AuraEnabled public String ORDER_DATE               {get;set;}
        @AuraEnabled public String PRICE_LIST               {get;set;}
        @AuraEnabled public String COLLECT_NO               {get;set;}
        @AuraEnabled public String ZTERM                    {get;set;}
        
        @AuraEnabled public String ORD_REASON               {get;set;}
        @AuraEnabled public String BZIRK                    {get;set;}
        @AuraEnabled public String DOCUFEE                  {get;set;}

        public IF_PARTS_005_Req_LS_MAIN_HEAD(){
            this.KONDA          = '';
            this.KUNNR          = '';
            this.KUNNR_NAME     = '';
            this.KUNNR_STREET   = '';
            this.KUNAG          = '';
            this.KUNAG_NAME     = '';
            this.KUNAG_STREET   = '';
            this.KUNNR_CR       = '';
            this.NETWR          = '';
            this.WAERK          = '';
            this.CREDIT         = '';
            this.CREDIT_WAERK   = '';
            this.TOTAL_WEIGHT   = '';
            this.GEWEI          = '';
            this.VOLUM          = '';
            this.VOLEH          = '';
            this.KONDA_TEXT     = '';
            this.KVGR5          = '';
            this.NAME           = '';
            this.CITY           = '';
            this.STREET         = '';
            this.COUNTRY        = '';
            this.POSTL_CODE     = '';
            this.TRANSPZONE     = '';
            this.ORDER_DATE     = '';
            this.PRICE_LIST     = '';
            this.COLLECT_NO     = '';
            this.ZTERM          = '';
            this.ORD_REASON     = '';
            this.BZIRK          = '';
            this.DOCUFEE        = '';
        }
    }
    public class IF_PARTS_005_Req_LS_GENERAL{
        @AuraEnabled public String BSTNK                {get;set;}
        @AuraEnabled public String VDATU                {get;set;}
        @AuraEnabled public String INCO1                {get;set;}
        @AuraEnabled public String INCO2                {get;set;}

        @AuraEnabled public String VSBED                {get;set;}
        @AuraEnabled public String COMPLETE_DELIVERY    {get;set;}
        @AuraEnabled public String ROUTE                {get;set;}
        @AuraEnabled public String VSBED_TX             {get;set;}
        
        @AuraEnabled public String ROUTE_TX             {get;set;}
        @AuraEnabled public String SPECPROCID           {get;set;}
        @AuraEnabled public String POSSIBLE_DATE        {get;set;}
        @AuraEnabled public String IF_FROM              {get;set;}
        
        @AuraEnabled public String TO                   {get;set;}
        @AuraEnabled public String AUDAT                {get;set;}
        @AuraEnabled public String ERZET                {get;set;}
        @AuraEnabled public String BSTKD_E              {get;set;}
        
        @AuraEnabled public String ZZCFDAT              {get;set;}

        public IF_PARTS_005_Req_LS_GENERAL(){
            this.BSTNK                  = '';
            this.VDATU                  = '';
            this.INCO1                  = '';
            this.INCO2                  = '';
            this.VSBED                  = '';
            this.COMPLETE_DELIVERY      = '';
            this.ROUTE                  = '';
            this.VSBED_TX               = '';
            this.ROUTE_TX               = '';
            this.SPECPROCID             = '';
            this.POSSIBLE_DATE          = '';
            this.IF_FROM                = '';
            this.TO                     = '';
            this.AUDAT                  = '';
            this.ERZET                  = '';
            this.BSTKD_E                = '';
            this.ZZCFDAT                = '';
        }
    }
    public class IF_PARTS_005_Req_LS_IMPORT_PORTAL{
        @AuraEnabled public String DOC_CATEGORY   {get;set;}
        @AuraEnabled public String DOC_MODE       {get;set;}
        @AuraEnabled public String COMPLAINT      {get;set;}

        public IF_PARTS_005_Req_LS_IMPORT_PORTAL(){
            this.DOC_CATEGORY       = '';
            this.DOC_MODE           = '';
            this.COMPLAINT          = '';
        }
    }
    public class IF_PARTS_005_Req_LS_SELECTED_ITEM{
        @AuraEnabled public String REF_ORD          {get;set;}
        @AuraEnabled public String REF_ITEM         {get;set;}
        @AuraEnabled public String COMPLAINT        {get;set;}
        @AuraEnabled public String COMPLAINT_DESC   {get;set;}

        @AuraEnabled public String CODE_TEXT        {get;set;}
        @AuraEnabled public String ZZDEALDT         {get;set;}
        @AuraEnabled public String REASON           {get;set;}
        @AuraEnabled public String DESCRIPT         {get;set;}

        public IF_PARTS_005_Req_LS_SELECTED_ITEM(){
            this.REF_ORD            = '';
            this.REF_ITEM           = '';
            this.COMPLAINT          = '';
            this.COMPLAINT_DESC     = '';
            this.CODE_TEXT          = '';
            this.ZZDEALDT           = '';
            this.REASON             = '';
            this.DESCRIPT           = '';
        }
    }
    public class IF_PARTS_005_Req_LS_EP_ONETIME{
        @AuraEnabled public String NAME         {get;set;}
        @AuraEnabled public String CITY         {get;set;}
        @AuraEnabled public String STREET       {get;set;}
        @AuraEnabled public String COUNTRY      {get;set;}

        @AuraEnabled public String POSTL_CODE   {get;set;}
        @AuraEnabled public String TRANSPZONE   {get;set;}
        @AuraEnabled public String TELEPHONE    {get;set;}
        @AuraEnabled public String NAME_2       {get;set;}
        
        @AuraEnabled public String REGION       {get;set;}

        public IF_PARTS_005_Req_LS_EP_ONETIME(){
            this.NAME           = '';
            this.CITY           = '';
            this.STREET         = '';
            this.COUNTRY        = '';
            this.POSTL_CODE     = '';
            this.TRANSPZONE     = '';
            this.TELEPHONE      = '';
            this.NAME_2         = '';
            this.REGION         = '';
        }
    }
    public class IF_PARTS_005_Req_I_ORG{
        @AuraEnabled public String VKORG    {get;set;}
        @AuraEnabled public String VTWEG    {get;set;}
        @AuraEnabled public String SPART    {get;set;}
        @AuraEnabled public String WERKS    {get;set;}

        @AuraEnabled public String ARBPL    {get;set;}
        @AuraEnabled public String AMSCCTL  {get;set;}

        public IF_PARTS_005_Req_I_ORG(){
            this.VKORG          = '';
            this.VTWEG          = '';
            this.SPART          = '';
            this.WERKS          = '';
            this.ARBPL          = '';
            this.AMSCCTL        = '';
        }
    }
    public class IF_PARTS_005_Req_LT_GERNERAL_ZTERM{
        @AuraEnabled public String ZTERM    {get;set;}
        @AuraEnabled public String TEXT     {get;set;}

        public IF_PARTS_005_Req_LT_GERNERAL_ZTERM(){
            this.ZTERM      = '';
            this.TEXT       = '';
        }
    }
    public class IF_PARTS_005_Req_LT_ITEM{
        @AuraEnabled public String CCHECK               {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String MATERIAL             {get;set;}

        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String QTY                  {get;set;}
        @AuraEnabled public String UOM                  {get;set;}
        @AuraEnabled public String NET_PRICE            {get;set;}
        
        @AuraEnabled public String NET_ITEM_PRICE       {get;set;}
        @AuraEnabled public String NET_VALUE            {get;set;}
        @AuraEnabled public String LIST_PRICE           {get;set;}
        @AuraEnabled public String IF_CURRENCY          {get;set;}
        
        @AuraEnabled public String AVAILABILITY         {get;set;}
        @AuraEnabled public String REF_ORD              {get;set;}
        @AuraEnabled public String REF_ITEM             {get;set;}
        @AuraEnabled public String COMPLAINT            {get;set;}
        
        @AuraEnabled public String COMPLAINT_DESC       {get;set;}
        @AuraEnabled public String PLANT                {get;set;}
        @AuraEnabled public String O                    {get;set;}
        @AuraEnabled public String C                    {get;set;}
        
        @AuraEnabled public String D                    {get;set;}
        @AuraEnabled public String BD                   {get;set;}
        @AuraEnabled public String BO                   {get;set;}
        @AuraEnabled public String DB                   {get;set;}
        
        @AuraEnabled public String R                    {get;set;}
        @AuraEnabled public String PLANT_TX             {get;set;}
        @AuraEnabled public String USAGE_HILV           {get;set;}
        @AuraEnabled public String CHEKCABLE            {get;set;}
        
        @AuraEnabled public String MATNR_CHECK          {get;set;}
        @AuraEnabled public String A                    {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String MATNR_DESIGN         {get;set;}
        @AuraEnabled public String REQ_QTY_DESIGN       {get;set;}
        @AuraEnabled public String ZZDEALDT             {get;set;}
        
        @AuraEnabled public String WAERS                {get;set;}
        @AuraEnabled public String REASON               {get;set;}
        @AuraEnabled public String INPUT_QTY            {get;set;}
        @AuraEnabled public String EXCEL                {get;set;}
        
        @AuraEnabled public String MVGR5                {get;set;}
        @AuraEnabled public String MATERIAL_ENT         {get;set;}
        @AuraEnabled public String ERRORCHECK           {get;set;}
        @AuraEnabled public String ERRORMSG             {get;set;}
        
        @AuraEnabled public String SUGRD                {get;set;}
        @AuraEnabled public String COMPLAINT_REASON     {get;set;}
        @AuraEnabled public String ACCEPT               {get;set;}
        @AuraEnabled public String MATERIAL_N           {get;set;}
        
        @AuraEnabled public String NETPR                {get;set;}
        @AuraEnabled public String DIEUCE               {get;set;}
        @AuraEnabled public String DIEUFL               {get;set;}
        @AuraEnabled public String DIUK                 {get;set;}
        
        @AuraEnabled public String DIID                 {get;set;}
        @AuraEnabled public String DI                   {get;set;}
        @AuraEnabled public String DIUKL                {get;set;}
        @AuraEnabled public String MEINS                {get;set;}
        
        @AuraEnabled public String HERKL                {get;set;}
        @AuraEnabled public String KONDM                {get;set;}
        @AuraEnabled public String NTGEW                {get;set;}
        @AuraEnabled public String GEWEI                {get;set;}
        
        @AuraEnabled public String POUND                {get;set;}
        @AuraEnabled public String KUNNR                {get;set;}
        @AuraEnabled public String TDLNR                {get;set;}
        @AuraEnabled public String TDLNR_NAME           {get;set;}
        
        @AuraEnabled public String BSTKD_E              {get;set;}
        @AuraEnabled public String BSTDK_E              {get;set;}
        @AuraEnabled public String AVAIL_QTY1           {get;set;}
        @AuraEnabled public String AVAIL_QTY2           {get;set;}
        @AuraEnabled public String ZZAPPMACHINE         {get;set;}
        
        @AuraEnabled public String ZZEQMASTER           {get;set;}
        @AuraEnabled public String ZZWORKHRS            {get;set;}
        @AuraEnabled public String TNDR_TRKID           {get;set;}
        @AuraEnabled public String STATUS               {get;set;}
        
        @AuraEnabled public String MITEM                {get;set;}
        @AuraEnabled public String TO_PART              {get;set;}
        @AuraEnabled public String BULLETIN             {get;set;}
        @AuraEnabled public String BULL_MATNR           {get;set;}
        
        @AuraEnabled public String MEMO                 {get;set;}
        @AuraEnabled public String MEMO_MATNR           {get;set;}
        @AuraEnabled public String EMERC                {get;set;}

        public IF_PARTS_005_Req_LT_ITEM(){
            this.CCHECK                 = '';
            this.ITEM                   = '';
            this.HILV                   = '';
            this.MATERIAL               = '';
            this.MATERIAL_TEXT          = '';
            this.QTY                    = '';
            this.UOM                    = '';
            this.NET_PRICE              = '';
            this.NET_ITEM_PRICE         = '';
            this.NET_VALUE              = '';
            this.LIST_PRICE             = '';
            this.IF_CURRENCY            = '';
            this.AVAILABILITY           = '';
            this.REF_ORD                = '';
            this.REF_ITEM               = '';
            this.COMPLAINT              = '';
            this.COMPLAINT_DESC         = '';
            this.PLANT                  = '';
            this.O                      = '';
            this.C                      = '';
            this.D                      = '';
            this.BD                     = '';
            this.BO                     = '';
            this.DB                     = '';
            this.R                      = '';
            this.PLANT_TX               = '';
            this.USAGE_HILV             = '';
            this.CHEKCABLE              = '';
            this.MATNR_CHECK            = '';
            this.A                      = '';
            this.REQ_QTY                = '';
            this.LOT_QTY                = '';
            this.MIN_QTY                = '';
            this.MATNR_DESIGN           = '';
            this.REQ_QTY_DESIGN         = '';
            this.ZZDEALDT               = '';
            this.WAERS                  = '';
            this.REASON                 = '';
            this.INPUT_QTY              = '';
            this.EXCEL                  = '';
            this.MVGR5                  = '';
            this.MATERIAL_ENT           = '';
            this.ERRORCHECK             = '';
            this.ERRORMSG               = '';
            this.SUGRD                  = '';
            this.COMPLAINT_REASON       = '';
            this.ACCEPT                 = '';
            this.MATERIAL_N             = '';
            this.NETPR                  = '';
            this.DIEUCE                 = '';
            this.DIEUFL                 = '';
            this.DIUK                   = '';
            this.DIID                   = '';
            this.DI                     = '';
            this.DIUKL                  = '';
            this.MEINS                  = '';
            this.HERKL                  = '';
            this.KONDM                  = '';
            this.NTGEW                  = '';
            this.GEWEI                  = '';
            this.POUND                  = '';
            this.KUNNR                  = '';
            this.TDLNR                  = '';
            this.TDLNR_NAME             = '';
            this.BSTKD_E                = '';
            this.BSTDK_E                = '';
            this.AVAIL_QTY1             = '';
            this.AVAIL_QTY2             = '';
            this.ZZAPPMACHINE           = '';
            this.ZZEQMASTER             = '';
            this.ZZWORKHRS              = '';
            this.TNDR_TRKID             = '';
            this.STATUS                 = '';
            this.MITEM                  = '';
            this.TO_PART                = '';
            this.BULLETIN               = '';
            this.BULL_MATNR             = '';
            this.MEMO                   = '';
            this.MEMO_MATNR             = '';
            this.EMERC                  = '';
        }
    }
    public class IF_PARTS_005_Req_LT_FILE{
        @AuraEnabled public String INT_NO       {get;set;}
        @AuraEnabled public String CHECK        {get;set;}
        @AuraEnabled public String DOCU_ITEM    {get;set;}
        @AuraEnabled public String VISIBLE      {get;set;}

        @AuraEnabled public String FILE_NAME    {get;set;}
        @AuraEnabled public String DESCRIPTION  {get;set;}
        @AuraEnabled public String FILE_DATA    {get;set;}
        @AuraEnabled public String FILE_NO      {get;set;}
        
        @AuraEnabled public String FILESIZE     {get;set;}

        public IF_PARTS_005_Req_LT_FILE(){
            this.INT_NO             = '';
            this.CHECK              = '';
            this.DOCU_ITEM          = '';
            this.VISIBLE            = '';
            this.FILE_NAME          = '';
            this.DESCRIPTION        = '';
            this.FILE_DATA          = '';
            this.FILE_NO            = '';
            this.FILESIZE           = '';
        }
    }
    public class IF_PARTS_005_Req_LT_PARTNER{
        @AuraEnabled public String PARTN_ROLE       {get;set;}
        @AuraEnabled public String PARTN_NUMB       {get;set;}
        @AuraEnabled public String ITM_NUMBER       {get;set;}
        @AuraEnabled public String TITLE            {get;set;}

        @AuraEnabled public String NAME             {get;set;}
        @AuraEnabled public String NAME_2           {get;set;}
        @AuraEnabled public String NAME_3           {get;set;}
        @AuraEnabled public String NAME_4           {get;set;}
        
        @AuraEnabled public String STREET           {get;set;}
        @AuraEnabled public String COUNTRY          {get;set;}
        @AuraEnabled public String COUNTR_ISO       {get;set;}
        @AuraEnabled public String POSTL_CODE       {get;set;}
        
        @AuraEnabled public String POBX_PCD         {get;set;}
        @AuraEnabled public String POBX_CTY         {get;set;}
        @AuraEnabled public String CITY             {get;set;}
        @AuraEnabled public String DISTRICT         {get;set;}
        
        @AuraEnabled public String REGION           {get;set;}
        @AuraEnabled public String PO_BOX           {get;set;}
        @AuraEnabled public String TELEPHONE        {get;set;}
        @AuraEnabled public String TELEPHONE2       {get;set;}
        
        @AuraEnabled public String TELEBOX          {get;set;}
        @AuraEnabled public String FAX_NUMBER       {get;set;}
        @AuraEnabled public String TELETEX_NO       {get;set;}
        @AuraEnabled public String TELEX_NO         {get;set;}
        
        @AuraEnabled public String LANGU            {get;set;}
        @AuraEnabled public String LANGU_ISO        {get;set;}
        @AuraEnabled public String UNLOAD_PT        {get;set;}
        @AuraEnabled public String TRANSPZONE       {get;set;}
        
        @AuraEnabled public String TAXJURCODE       {get;set;}
        @AuraEnabled public String ADDRESS          {get;set;}
        @AuraEnabled public String PRIV_ADDR        {get;set;}
        @AuraEnabled public String ADDR_TYPE        {get;set;}
        
        @AuraEnabled public String ADDR_ORIG        {get;set;}
        @AuraEnabled public String ADDR_LINK        {get;set;}
        @AuraEnabled public String REFOBJTYPE       {get;set;}
        @AuraEnabled public String REFOBJKEY        {get;set;}
        
        @AuraEnabled public String REFLOGSYS        {get;set;}

        public IF_PARTS_005_Req_LT_PARTNER(){
            this.PARTN_ROLE         = '';
            this.PARTN_NUMB         = '';
            this.ITM_NUMBER         = '';
            this.TITLE              = '';
            this.NAME               = '';
            this.NAME_2             = '';
            this.NAME_3             = '';
            this.NAME_4             = '';
            this.STREET             = '';
            this.COUNTRY            = '';
            this.COUNTR_ISO         = '';
            this.POSTL_CODE         = '';
            this.POBX_PCD           = '';
            this.POBX_CTY           = '';
            this.CITY               = '';
            this.DISTRICT           = '';
            this.REGION             = '';
            this.PO_BOX             = '';
            this.TELEPHONE          = '';
            this.TELEPHONE2         = '';
            this.TELEBOX            = '';
            this.FAX_NUMBER         = '';
            this.TELETEX_NO         = '';
            this.TELEX_NO           = '';
            this.LANGU              = '';
            this.LANGU_ISO          = '';
            this.UNLOAD_PT          = '';
            this.TRANSPZONE         = '';
            this.TAXJURCODE         = '';
            this.ADDRESS            = '';
            this.PRIV_ADDR          = '';
            this.ADDR_TYPE          = '';
            this.ADDR_ORIG          = '';
            this.ADDR_LINK          = '';
            this.REFOBJTYPE         = '';
            this.REFOBJKEY          = '';
            this.REFLOGSYS          = '';
        }
    }
    public class IF_PARTS_005_Res{
        @AuraEnabled public IF_PARTS_005_Res_LS_MAIN_HEAD_RESULT    LS_MAIN_HEAD_RESULT     {get;set;}
        @AuraEnabled public String                                  E_MEG                   {get;set;}
        @AuraEnabled public String                                  LV_VENLR                {get;set;}
        @AuraEnabled public List<IF_PARTS_005_Res_LT_BAPIRET2>      LT_BAPIRET2             {get;set;}

        public IF_PARTS_005_Res(){}
    }
    public class IF_PARTS_005_Res_LS_MAIN_HEAD_RESULT{
        @AuraEnabled public String KONDA            {get;set;}
        @AuraEnabled public String KUNNR            {get;set;}
        @AuraEnabled public String KUNNR_NAME       {get;set;}
        @AuraEnabled public String KUNNR_STREET     {get;set;}

        @AuraEnabled public String KUNAG            {get;set;}
        @AuraEnabled public String KUNAG_NAME       {get;set;}
        @AuraEnabled public String KUNAG_STREET     {get;set;}
        @AuraEnabled public String KUNNR_CR         {get;set;}
        
        @AuraEnabled public String NETWR            {get;set;}
        @AuraEnabled public String WAERK            {get;set;}
        @AuraEnabled public String CREDIT           {get;set;}
        @AuraEnabled public String CREDIT_WAERK     {get;set;}
        
        @AuraEnabled public String TOTAL_WEIGHT     {get;set;}
        @AuraEnabled public String GEWEI            {get;set;}
        @AuraEnabled public String VOLUM            {get;set;}
        @AuraEnabled public String VOLEH            {get;set;}
        
        @AuraEnabled public String KONDA_TEXT       {get;set;}
        @AuraEnabled public String KVGR5            {get;set;}
        @AuraEnabled public String NAME             {get;set;}
        @AuraEnabled public String CITY             {get;set;}
        
        @AuraEnabled public String STREET           {get;set;}
        @AuraEnabled public String COUNTRY          {get;set;}
        @AuraEnabled public String POSTL_CODE       {get;set;}
        @AuraEnabled public String TRANSPZONE       {get;set;}
        
        @AuraEnabled public String ORDER_DATE       {get;set;}
        @AuraEnabled public String PRICE_LIST       {get;set;}
        @AuraEnabled public String COLLECT_NO       {get;set;}
        @AuraEnabled public String ZTERM            {get;set;}
        
        @AuraEnabled public String ORD_REASON       {get;set;}
        @AuraEnabled public String BZIRK            {get;set;}
        @AuraEnabled public String DOCUFEE          {get;set;}

        public IF_PARTS_005_Res_LS_MAIN_HEAD_RESULT(){}
    }
    public class IF_PARTS_005_Res_LT_BAPIRET2{
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

        public IF_PARTS_005_Res_LT_BAPIRET2(){}
    }

    /** SFDC interface Id   : IF-PARTS-007
     * AS-IS RFC            : Z_EP_ORDERLIST_ME
     * New I/F              : ZCRM_EP_ORDERLIST_ME
     * Description          : 오더 조회
    */
    public class IF_PARTS_007_Req{
        @AuraEnabled public IF_PARTS_007_Req_LS_SEARCH  LS_SEARCH   {get;set;}
        @AuraEnabled public String COMPLAINT    {get;set;}
        @AuraEnabled public String I_LANGU      {get;set;}
        @AuraEnabled public String I_YESF       {get;set;}

        @AuraEnabled public String I_VKORG      {get;set;}
        @AuraEnabled public String I_VTWEG      {get;set;}
        @AuraEnabled public String I_SPART      {get;set;}
        @AuraEnabled public String I_KUNNR      {get;set;}

        public IF_PARTS_007_Req(){
            this.LS_SEARCH      = new IF_PARTS_007_Req_LS_SEARCH();
            this.COMPLAINT      = '';
            this.I_LANGU        = '';
            this.I_YESF         = '';
            this.I_VKORG        = '';
            this.I_VTWEG        = '';
            this.I_SPART        = '';
            this.I_KUNNR        = '';
        }
    }
    public class IF_PARTS_007_Req_LS_SEARCH{
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

        public IF_PARTS_007_Req_LS_SEARCH(){
            this.AUART          = '';
            this.BSTKD          = '';
            this.VGBEL          = '';
            this.VBELN          = '';
            this.MATNR          = '';
            this.FRDATE         = '';
            this.TODATE         = '';
            this.USERID         = '';
            this.KUNNR          = '';
            this.VKORG          = '';
            this.VBTYP          = '';
            this.WAERK          = '';
            this.T_NETWR        = '';
            this.SPART          = '';
            this.COUNT          = '';
            this.RFGSK          = '';
            this.FKSTK          = '';
            this.KVGR5          = '';
            this.IHREZ          = '';
            this.SUBMI          = '';
            this.KONDA          = '';
            this.XBLNR          = '';
            this.ZZACCPTCD      = '';
            this.ZZCFSTA        = '';
            this.ITEMLEVEL      = '';
            this.ZLINE_STAT     = '';
            this.DVBELN         = '';
            this.EFCIVNO        = '';
        }
    }
    public class IF_PARTS_007_Res{
        @AuraEnabled public String                              LV_MSG      {get;set;}
        @AuraEnabled public List<IF_PARTS_007_Res_LT_SEARCH>    LT_SEARCH   {get;set;}
        @AuraEnabled public List<IF_PARTS_007_Res_LT_SEARCH2>   LT_SEARCH2  {get;set;}

        public IF_PARTS_007_Res(){}
    }
    public class IF_PARTS_007_Res_LT_SEARCH{
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

        public IF_PARTS_007_Res_LT_SEARCH(){}
    }
    public class IF_PARTS_007_Res_LT_SEARCH2{
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

        public IF_PARTS_007_Res_LT_SEARCH2(){}
    }

    /** SFDC interface Id   : IF-PARTS-008
     * AS-IS RFC            : Z_EP_ORDER_LOAD2
     * New I/F              : ZCRM_EP_ORDER_LOAD2
     * Description          : 오더 상세 조회
    */
    public class IF_PARTS_008_Req{
        @AuraEnabled public String                              I_VKORG             {get;set;}
        @AuraEnabled public String                              I_VTWEG             {get;set;}
        @AuraEnabled public String                              I_SPART             {get;set;}
        @AuraEnabled public String                              I_KUNNR             {get;set;}

        @AuraEnabled public IF_PARTS_008_Req_LS_MAIN_HEAD       LS_MAIN_HEAD        {get;set;}
        @AuraEnabled public String                              LV_MATERIAL         {get;set;}
        @AuraEnabled public IF_PARTS_008_Req_LS_IMPORT_PORTAL   LS_IMPORT_PORTAL    {get;set;}
        @AuraEnabled public String                              LV_REF_ORD          {get;set;}
        
        @AuraEnabled public String                              I_LANGU             {get;set;}
        @AuraEnabled public String                              I_KSCHL             {get;set;}

        public IF_PARTS_008_Req(){
            this.I_VKORG            = '';
            this.I_VTWEG            = '';
            this.I_SPART            = '';
            this.I_KUNNR            = '';
            this.LS_MAIN_HEAD       = new IF_PARTS_008_Req_LS_MAIN_HEAD();
            this.LV_MATERIAL        = '';
            this.LS_IMPORT_PORTAL   = new IF_PARTS_008_Req_LS_IMPORT_PORTAL();
            this.LV_REF_ORD         = '';
            this.I_LANGU            = '';
            this.I_KSCHL            = '';
        }
    }
    public class IF_PARTS_008_Req_LS_MAIN_HEAD{
        @AuraEnabled public String KONDA            {get;set;}
        @AuraEnabled public String KUNNR            {get;set;}
        @AuraEnabled public String KUNNR_NAME       {get;set;}
        @AuraEnabled public String KUNNR_STREET     {get;set;}

        @AuraEnabled public String KUNAG            {get;set;}
        @AuraEnabled public String KUNAG_NAME       {get;set;}
        @AuraEnabled public String KUNAG_STREET     {get;set;}
        @AuraEnabled public String NETWR            {get;set;}
        
        @AuraEnabled public String NETWR1           {get;set;}
        @AuraEnabled public String WAERK            {get;set;}
        @AuraEnabled public String CREDIT           {get;set;}
        @AuraEnabled public String CREDIT_WAERK     {get;set;}
        
        @AuraEnabled public String TOTAL_WEIGHT     {get;set;}
        @AuraEnabled public String POUND            {get;set;}
        @AuraEnabled public String GEWEI            {get;set;}
        @AuraEnabled public String VOLUM            {get;set;}
        
        @AuraEnabled public String VOLEH            {get;set;}
        @AuraEnabled public String KONDA_TEXT       {get;set;}
        @AuraEnabled public String KVGR5            {get;set;}
        @AuraEnabled public String NAME             {get;set;}
        
        @AuraEnabled public String CITY             {get;set;}
        @AuraEnabled public String STREET           {get;set;}
        @AuraEnabled public String COUNTRY          {get;set;}
        @AuraEnabled public String POSTL_CODE       {get;set;}
        
        @AuraEnabled public String TRANSPZONE       {get;set;}
        @AuraEnabled public String TELEPHONE        {get;set;}
        @AuraEnabled public String ZZAPPNO          {get;set;}
        @AuraEnabled public String NAME2            {get;set;}
        
        @AuraEnabled public String SUBMI            {get;set;}
        @AuraEnabled public String CARR_DEC         {get;set;}
        @AuraEnabled public String VSNMR_V          {get;set;}
        @AuraEnabled public String BNAME            {get;set;}
        
        @AuraEnabled public String TELF1            {get;set;}
        @AuraEnabled public String IHREZ            {get;set;}
        @AuraEnabled public String BSTDK_E          {get;set;}
        @AuraEnabled public String BSTDK            {get;set;}
        
        @AuraEnabled public String AUGRU            {get;set;}
        @AuraEnabled public String AUGRU_T          {get;set;}
        @AuraEnabled public String ABRVW            {get;set;}
        @AuraEnabled public String PLTYP            {get;set;}
        
        @AuraEnabled public String FREIGHT          {get;set;}
        @AuraEnabled public String BNDDT            {get;set;}
        @AuraEnabled public String AUART_T          {get;set;}
        @AuraEnabled public String XBLNR            {get;set;}
        
        @AuraEnabled public String ZZMACNO          {get;set;}
        @AuraEnabled public String ZZQUINO          {get;set;}
        @AuraEnabled public String ZZISDAT          {get;set;}
        @AuraEnabled public String ZZCFSTA          {get;set;}
        
        @AuraEnabled public String ZZCFSTA_T        {get;set;}
        @AuraEnabled public String ZZCFUSR          {get;set;}
        @AuraEnabled public String ZZCFUSR_T        {get;set;}
        @AuraEnabled public String STATUS           {get;set;}
        
        @AuraEnabled public String ZZURGEN          {get;set;}
        @AuraEnabled public String ZZURGEN_TEXT     {get;set;}

        public IF_PARTS_008_Req_LS_MAIN_HEAD(){
            this.KONDA         = '';
            this.KUNNR         = '';
            this.KUNNR_NAME    = '';
            this.KUNNR_STREET  = '';
            this.KUNAG         = '';
            this.KUNAG_NAME    = '';
            this.KUNAG_STREET  = '';
            this.NETWR         = '';
            this.NETWR1        = '';
            this.WAERK         = '';
            this.CREDIT        = '';
            this.CREDIT_WAERK  = '';
            this.TOTAL_WEIGHT  = '';
            this.POUND         = '';
            this.GEWEI         = '';
            this.VOLUM         = '';
            this.VOLEH         = '';
            this.KONDA_TEXT    = '';
            this.KVGR5         = '';
            this.NAME          = '';
            this.CITY          = '';
            this.STREET        = '';
            this.COUNTRY       = '';
            this.POSTL_CODE    = '';
            this.TRANSPZONE    = '';
            this.TELEPHONE     = '';
            this.ZZAPPNO       = '';
            this.NAME2         = '';
            this.SUBMI         = '';
            this.CARR_DEC      = '';
            this.VSNMR_V       = '';
            this.BNAME         = '';
            this.TELF1         = '';
            this.IHREZ         = '';
            this.BSTDK_E       = '';
            this.BSTDK         = '';
            this.AUGRU         = '';
            this.AUGRU_T       = '';
            this.ABRVW         = '';
            this.PLTYP         = '';
            this.FREIGHT       = '';
            this.BNDDT         = '';
            this.AUART_T       = '';
            this.XBLNR         = '';
            this.ZZMACNO       = '';
            this.ZZQUINO       = '';
            this.ZZISDAT       = '';
            this.ZZCFSTA       = '';
            this.ZZCFSTA_T     = '';
            this.ZZCFUSR       = '';
            this.ZZCFUSR_T     = '';
            this.STATUS        = '';
            this.ZZURGEN       = '';
            this.ZZURGEN_TEXT  = '';
        }
    }
    public class IF_PARTS_008_Req_LS_IMPORT_PORTAL{
        @AuraEnabled public String DOC_CATEGORY {get;set;}
        @AuraEnabled public String DOC_MODE     {get;set;}
        @AuraEnabled public String COMPLAINT    {get;set;}

        public IF_PARTS_008_Req_LS_IMPORT_PORTAL(){
            this.DOC_CATEGORY       = '';
            this.DOC_MODE           = '';
            this.COMPLAINT          = '';
        }
    }
    public class IF_PARTS_008_Res{
        @AuraEnabled public IF_PARTS_008_Res_LS_MAIN_HEAD_RESULT        LS_MAIN_HEAD_RESULT    {get;set;}
        @AuraEnabled public String                                      E_MEG                  {get;set;}
        @AuraEnabled public String                                      LV_VENLR               {get;set;}
        @AuraEnabled public IF_PARTS_008_Res_LS_FIRST                   LS_FIRST               {get;set;}

        @AuraEnabled public IF_PARTS_008_Res_LS_GENERAL                 LS_GENERAL             {get;set;}
        @AuraEnabled public String                                      LV_ADDRESS             {get;set;}
        @AuraEnabled public String                                      LV_REMARK              {get;set;}
        @AuraEnabled public String                                      LV_ONETIME             {get;set;}

        @AuraEnabled public String                                      O_TOTAL                {get;set;}
        @AuraEnabled public String                                      O_FORWARDER            {get;set;}
        @AuraEnabled public String                                      O_NAME1                {get;set;}
        @AuraEnabled public String                                      LV_SCAT                {get;set;}
        
        @AuraEnabled public String                                      I_INQUIRY              {get;set;}
        @AuraEnabled public String                                      E_MDOWN                {get;set;}
        @AuraEnabled public String                                      E_VSART_TX             {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_GERNERAL_ZTERM>    LT_GERNERAL_ZTERM      {get;set;}
        
        @AuraEnabled public List<IF_PARTS_008_Res_LT_ITEM>              LT_ITEM                {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_FILE>              LT_FILE                {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_PRICING_01>        LT_PRICING_01          {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_PRICING_02>        LT_PRICING_02          {get;set;}
        
        @AuraEnabled public List<IF_PARTS_008_Res_LT_STATUS>            LT_STATUS              {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_RETURN>               IF_RETURN              {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_ERRORMSG>             ERRORMSG               {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_VALUESET>          LT_VALUESET            {get;set;}
        
        @AuraEnabled public List<IF_PARTS_008_Res_LT_FILE2>             LT_FILE2               {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_TEXT>              LT_TEXT                {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_PARTNER>           LT_PARTNER             {get;set;}
        @AuraEnabled public List<IF_PARTS_008_Res_LT_CONDITION>         LT_CONDITION           {get;set;}

        public IF_PARTS_008_Res(){}
    }
    public class IF_PARTS_008_Res_LS_MAIN_HEAD_RESULT{
        @AuraEnabled public String KONDA           {get;set;}
        @AuraEnabled public String KUNNR           {get;set;}
        @AuraEnabled public String KUNNR_NAME      {get;set;}
        @AuraEnabled public String KUNNR_STREET    {get;set;}

        @AuraEnabled public String KUNAG           {get;set;}
        @AuraEnabled public String KUNAG_NAME      {get;set;}
        @AuraEnabled public String KUNAG_STREET    {get;set;}
        @AuraEnabled public String KUNNR_CR        {get;set;}
        
        @AuraEnabled public String NETWR           {get;set;}
        @AuraEnabled public String WAERK           {get;set;}
        @AuraEnabled public String CREDIT          {get;set;}
        @AuraEnabled public String CREDIT_WAERK    {get;set;}
        
        @AuraEnabled public String TOTAL_WEIGHT    {get;set;}
        @AuraEnabled public String GEWEI           {get;set;}
        @AuraEnabled public String VOLUM           {get;set;}
        @AuraEnabled public String VOLEH           {get;set;}
        
        @AuraEnabled public String KONDA_TEXT      {get;set;}
        @AuraEnabled public String KVGR5           {get;set;}
        @AuraEnabled public String NAME            {get;set;}
        @AuraEnabled public String CITY            {get;set;}
        
        @AuraEnabled public String STREET          {get;set;}
        @AuraEnabled public String COUNTRY         {get;set;}
        @AuraEnabled public String POSTL_CODE      {get;set;}
        @AuraEnabled public String TRANSPZONE      {get;set;}
        
        @AuraEnabled public String ORDER_DATE      {get;set;}
        @AuraEnabled public String PRICE_LIST      {get;set;}
        @AuraEnabled public String COLLECT_NO      {get;set;}
        @AuraEnabled public String ZTERM           {get;set;}
        
        @AuraEnabled public String ORD_REASON      {get;set;}
        @AuraEnabled public String BZIRK           {get;set;}
        @AuraEnabled public String DOCUFEE         {get;set;}
        @AuraEnabled public String TELEPHONE       {get;set;}

        public IF_PARTS_008_Res_LS_MAIN_HEAD_RESULT(){}
    }
    public class IF_PARTS_008_Res_LS_FIRST{
        @AuraEnabled public String AUART        {get;set;}
        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}

        @AuraEnabled public String BEZEI        {get;set;}
        @AuraEnabled public String VKORG_T      {get;set;}
        @AuraEnabled public String VTWEG_T      {get;set;}
        @AuraEnabled public String SPART_T      {get;set;}

        public IF_PARTS_008_Res_LS_FIRST(){}
    }
    public class IF_PARTS_008_Res_LS_GENERAL{
        @AuraEnabled public String BSTNK                    {get;set;}
        @AuraEnabled public String VDATU                    {get;set;}
        @AuraEnabled public String INCO1                    {get;set;}
        @AuraEnabled public String INCO2                    {get;set;}

        @AuraEnabled public String VSBED                    {get;set;}
        @AuraEnabled public String COMPLETE_DELIVERY        {get;set;}
        @AuraEnabled public String ROUTE                    {get;set;}
        @AuraEnabled public String VSBED_TX                 {get;set;}
        
        @AuraEnabled public String ROUTE_TX                 {get;set;}
        @AuraEnabled public String SPECPROCID               {get;set;}
        @AuraEnabled public String POSSIBLE_DATE            {get;set;}
        @AuraEnabled public String IF_FROM                  {get;set;}
        
        @AuraEnabled public String TO                       {get;set;}
        @AuraEnabled public String AUDAT                    {get;set;}
        @AuraEnabled public String ERZET                    {get;set;}
        @AuraEnabled public String BSTKD_E                  {get;set;}
        
        @AuraEnabled public String ZZCFDAT                  {get;set;}

        public IF_PARTS_008_Res_LS_GENERAL(){}
    }
    public class IF_PARTS_008_Res_LT_GERNERAL_ZTERM{
        @AuraEnabled public String ZTERM    {get;set;}
        @AuraEnabled public String TEXT     {get;set;}
        
        public IF_PARTS_008_Res_LT_GERNERAL_ZTERM(){}
    }
    public class IF_PARTS_008_Res_LT_ITEM{
        @AuraEnabled public String CCHECK               {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String MATERIAL             {get;set;}

        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String QTY                  {get;set;}
        @AuraEnabled public String UOM                  {get;set;}
        @AuraEnabled public String NET_PRICE            {get;set;}
        
        @AuraEnabled public String NET_ITEM_PRICE       {get;set;}
        @AuraEnabled public String NET_VALUE            {get;set;}
        @AuraEnabled public String LIST_PRICE           {get;set;}
        @AuraEnabled public String IF_CURRENCY          {get;set;}
        
        @AuraEnabled public String AVAILABILITY         {get;set;}
        @AuraEnabled public String REF_ORD              {get;set;}
        @AuraEnabled public String REF_ITEM             {get;set;}
        @AuraEnabled public String COMPLAINT            {get;set;}
        
        @AuraEnabled public String COMPLAINT_DESC       {get;set;}
        @AuraEnabled public String PLANT                {get;set;}
        @AuraEnabled public String O                    {get;set;}
        @AuraEnabled public String C                    {get;set;}
        
        @AuraEnabled public String D                    {get;set;}
        @AuraEnabled public String BD                   {get;set;}
        @AuraEnabled public String BO                   {get;set;}
        @AuraEnabled public String DB                   {get;set;}
        
        @AuraEnabled public String R                    {get;set;}
        @AuraEnabled public String PLANT_TX             {get;set;}
        @AuraEnabled public String USAGE_HILV           {get;set;}
        @AuraEnabled public String CHEKCABLE            {get;set;}
        
        @AuraEnabled public String MATNR_CHECK          {get;set;}
        @AuraEnabled public String A                    {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String MATNR_DESIGN         {get;set;}
        @AuraEnabled public String REQ_QTY_DESIGN       {get;set;}
        @AuraEnabled public String ZZDEALDT             {get;set;}
        
        @AuraEnabled public String WAERS                {get;set;}
        @AuraEnabled public String REASON               {get;set;}
        @AuraEnabled public String INPUT_QTY            {get;set;}
        @AuraEnabled public String EXCEL                {get;set;}
        
        @AuraEnabled public String MVGR5                {get;set;}
        @AuraEnabled public String MATERIAL_ENT         {get;set;}
        @AuraEnabled public String ERRORCHECK           {get;set;}
        @AuraEnabled public String ERRORMSG             {get;set;}
        
        @AuraEnabled public String SUGRD                {get;set;}
        @AuraEnabled public String COMPLAINT_REASON     {get;set;}
        @AuraEnabled public String ACCEPT               {get;set;}
        @AuraEnabled public String MATERIAL_N           {get;set;}
        
        @AuraEnabled public String NETPR                {get;set;}
        @AuraEnabled public String DIEUCE               {get;set;}
        @AuraEnabled public String DIEUFL               {get;set;}
        @AuraEnabled public String DIUK                 {get;set;}
        
        @AuraEnabled public String DIID                 {get;set;}
        @AuraEnabled public String DI                   {get;set;}
        @AuraEnabled public String DIUKL                {get;set;}
        @AuraEnabled public String ZZAPPMACHINE         {get;set;}
        
        @AuraEnabled public String ZZEQMASTER           {get;set;}

        public IF_PARTS_008_Res_LT_ITEM(){}
    }
    public class IF_PARTS_008_Res_LT_FILE{
        @AuraEnabled public String INT_NO       {get;set;}
        @AuraEnabled public String CHECK        {get;set;}
        @AuraEnabled public String DOCU_ITEM    {get;set;}
        @AuraEnabled public String VISIBLE      {get;set;}

        @AuraEnabled public String FILE_NAME    {get;set;}
        @AuraEnabled public String DESCRIPTION  {get;set;}
        @AuraEnabled public String FILE_DATA    {get;set;}
        @AuraEnabled public String FILE_NO      {get;set;}
        
        @AuraEnabled public String FILESIZE     {get;set;}

        public IF_PARTS_008_Res_LT_FILE(){}
    }
    public class IF_PARTS_008_Res_LT_PRICING_01{
        @AuraEnabled public String NAME     {get;set;}
        @AuraEnabled public String NEWR     {get;set;}
        @AuraEnabled public String WAERK    {get;set;}
        @AuraEnabled public String NETWR    {get;set;}

        public IF_PARTS_008_Res_LT_PRICING_01(){}
    }
    public class IF_PARTS_008_Res_LT_PRICING_02{
        @AuraEnabled public String NAME     {get;set;}
        @AuraEnabled public String NEWR     {get;set;}
        @AuraEnabled public String WAERK    {get;set;}
        @AuraEnabled public String NETWR    {get;set;}

        public IF_PARTS_008_Res_LT_PRICING_02(){}
    }
    public class IF_PARTS_008_Res_LT_STATUS{
        @AuraEnabled public String CODE {get;set;}
        @AuraEnabled public String TEXT {get;set;}
        @AuraEnabled public String NAME {get;set;}

        public IF_PARTS_008_Res_LT_STATUS(){}
    }
    public class IF_PARTS_008_Res_RETURN{
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

        public IF_PARTS_008_Res_RETURN(){}
    }
    public class IF_PARTS_008_Res_ERRORMSG{
        @AuraEnabled public String NAME {get;set;}
        @AuraEnabled public String TEXT {get;set;}

        public IF_PARTS_008_Res_ERRORMSG(){}
    }
    public class IF_PARTS_008_Res_LT_VALUESET{
        @AuraEnabled public String VALUE    {get;set;}
        @AuraEnabled public String TEXT     {get;set;}

        public IF_PARTS_008_Res_LT_VALUESET(){}
    }
    public class IF_PARTS_008_Res_LT_FILE2{
        @AuraEnabled public String INT_NO       {get;set;}
        @AuraEnabled public String CHECK        {get;set;}
        @AuraEnabled public String DOCU_ITEM    {get;set;}
        @AuraEnabled public String VISIBLE      {get;set;}

        @AuraEnabled public String FILE_NAME    {get;set;}
        @AuraEnabled public String DESCRIPTION  {get;set;}
        @AuraEnabled public String FILE_DATA    {get;set;}
        @AuraEnabled public String FILE_NO      {get;set;}
        
        @AuraEnabled public String FILESIZE     {get;set;}

        public IF_PARTS_008_Res_LT_FILE2(){}
    }
    public class IF_PARTS_008_Res_LT_TEXT{
        @AuraEnabled public String POSNR    {get;set;}
        @AuraEnabled public String SEQNO    {get;set;}
        @AuraEnabled public String TDID     {get;set;}
        @AuraEnabled public String LINE     {get;set;}

        public IF_PARTS_008_Res_LT_TEXT(){}
    }
    public class IF_PARTS_008_Res_LT_PARTNER{
        @AuraEnabled public String VBELN        {get;set;}
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String PARVW        {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}

        @AuraEnabled public String NAME1        {get;set;}
        @AuraEnabled public String NAME2        {get;set;}
        @AuraEnabled public String NAME3        {get;set;}
        @AuraEnabled public String NAME4        {get;set;}
        
        @AuraEnabled public String STREET1      {get;set;}
        @AuraEnabled public String STREET2      {get;set;}
        @AuraEnabled public String CITY1        {get;set;}
        @AuraEnabled public String CITY2        {get;set;}
        
        @AuraEnabled public String STATE        {get;set;}
        @AuraEnabled public String ZIP          {get;set;}
        @AuraEnabled public String HOUSE_NUM1   {get;set;}
        @AuraEnabled public String TEL_NUMBER   {get;set;}
        
        @AuraEnabled public String FAX_NUMBER   {get;set;}
        @AuraEnabled public String EMAIL        {get;set;}
        @AuraEnabled public String SIC_CODE     {get;set;}
        @AuraEnabled public String MAIL_OK      {get;set;}
        
        @AuraEnabled public String COUNTRY      {get;set;}
        @AuraEnabled public String TZONE        {get;set;}
        @AuraEnabled public String CONTACT      {get;set;}
        @AuraEnabled public String SORT2        {get;set;}
        
        @AuraEnabled public String PO_BOX_LOC   {get;set;}

        public IF_PARTS_008_Res_LT_PARTNER(){}
    }
    public class IF_PARTS_008_Res_LT_CONDITION{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String KPOSN        {get;set;}
        @AuraEnabled public String STUNR        {get;set;}
        @AuraEnabled public String ZAEHK        {get;set;}

        @AuraEnabled public String KSCHL        {get;set;}
        @AuraEnabled public String KRECH        {get;set;}
        @AuraEnabled public String KBETR        {get;set;}
        @AuraEnabled public String WAERS        {get;set;}
        
        @AuraEnabled public String ZWAERS       {get;set;}
        @AuraEnabled public String KPEIN        {get;set;}
        @AuraEnabled public String KMEIN        {get;set;}
        @AuraEnabled public String KWERT        {get;set;}
        
        @AuraEnabled public String WAERK        {get;set;}
        @AuraEnabled public String VARCOND      {get;set;}
        @AuraEnabled public String KAWRT        {get;set;}
        @AuraEnabled public String KINAK        {get;set;}
        
        @AuraEnabled public String KAPPL        {get;set;}
        @AuraEnabled public String UPDATEFLAG   {get;set;}

        public IF_PARTS_008_Res_LT_CONDITION(){}
    }

    /**  SFDC interface Id    : IF-PARTS-009
     *   AS-IS RFC            : Z_EP_ORDER_SIMULATION_MASS
     *   New I/F              : ZCRM_EP_ORDER_SIMULATION_MASS
     *   Description          : 부품 주문 -> 오더생성 -> Simulation 버튼을 통해 부품 정보 조회
    */
    public class IF_PARTS_009_Req{
        @AuraEnabled public String                                      LS_APPLY            {get;set;}
        @AuraEnabled public String                                      LV_AUART            {get;set;}
        @AuraEnabled public String                                      I_USERID            {get;set;}
        @AuraEnabled public String                                      I_LANGU             {get;set;}
        @AuraEnabled public String                                      I_SHIPTO            {get;set;}
        @AuraEnabled public String                                      I_DATE              {get;set;}
        @AuraEnabled public String                                      I_CS                {get;set;}
        @AuraEnabled public String                                      ODKEY               {get;set;}

        @AuraEnabled public IF_PARTS_009_Req_I_USERINFO                 I_USERINFO          {get;set;}
        @AuraEnabled public IF_PARTS_009_Req_LS_MAIN_HEAD               LS_MAIN_HEAD        {get;set;}
        @AuraEnabled public IF_PARTS_009_Req_LS_ERROR_IGNORE            LS_ERROR_IGNORE     {get;set;}
        @AuraEnabled public IF_PARTS_009_Req_LS_IMPORT_PORTAL           LS_IMPORT_PORTAL    {get;set;}
        @AuraEnabled public IF_PARTS_009_Req_I_ORG                      I_ORG               {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Req_LT_GERNERAL_ZTERM>    LT_GERNERAL_ZTERM   {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Req_LT_PARTNER>           LT_PARTNER          {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Req_LT_ITEM>              LT_ITEM             {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Req_LT_STATUS>            LT_STATUS           {get;set;}

        public IF_PARTS_009_Req(){
            this.I_USERINFO         = new IF_PARTS_009_Req_I_USERINFO();
            this.LS_MAIN_HEAD       = new IF_PARTS_009_Req_LS_MAIN_HEAD();
            this.LS_ERROR_IGNORE    = new IF_PARTS_009_Req_LS_ERROR_IGNORE();
            this.LS_IMPORT_PORTAL   = new IF_PARTS_009_Req_LS_IMPORT_PORTAL();
            this.LT_GERNERAL_ZTERM  = new List<IF_PARTS_009_Req_LT_GERNERAL_ZTERM>();
            this.LT_PARTNER         = new List<IF_PARTS_009_Req_LT_PARTNER>();
            this.LT_ITEM            = new List<IF_PARTS_009_Req_LT_ITEM>();
            this.LT_STATUS          = new List<IF_PARTS_009_Req_LT_STATUS>();
        }
    }
    public class IF_PARTS_009_Req_I_USERINFO{
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

        public IF_PARTS_009_Req_I_USERINFO(){}
    }
    public class IF_PARTS_009_Req_LS_MAIN_HEAD{
        @AuraEnabled public String KONDA            {get;set;}
        @AuraEnabled public String KUNNR            {get;set;}
        @AuraEnabled public String KUNNR_NAME       {get;set;}
        @AuraEnabled public String KUNNR_STREET     {get;set;}
        @AuraEnabled public String KUNAG            {get;set;}

        @AuraEnabled public String KUNAG_NAME       {get;set;}
        @AuraEnabled public String KUNAG_STREET     {get;set;}
        @AuraEnabled public String KUNNR_CR         {get;set;}
        @AuraEnabled public String NETWR            {get;set;}
        @AuraEnabled public String WAERK            {get;set;}
        
        @AuraEnabled public String CREDIT           {get;set;}
        @AuraEnabled public String CREDIT_WAERK     {get;set;}
        @AuraEnabled public String TOTAL_WEIGHT     {get;set;}
        @AuraEnabled public String GEWEI            {get;set;}
        @AuraEnabled public String VOLUM            {get;set;}
        
        @AuraEnabled public String VOLEH            {get;set;}
        @AuraEnabled public String KONDA_TEXT       {get;set;}
        @AuraEnabled public String KVGR5            {get;set;}
        @AuraEnabled public String NAME             {get;set;}
        @AuraEnabled public String CITY             {get;set;}
        
        @AuraEnabled public String STREET           {get;set;}
        @AuraEnabled public String COUNTRY          {get;set;}
        @AuraEnabled public String POSTL_CODE       {get;set;}
        @AuraEnabled public String TRANSPZONE       {get;set;}
        @AuraEnabled public String ORDER_DATE       {get;set;}
        
        @AuraEnabled public String PRICE_LIST       {get;set;}
        @AuraEnabled public String COLLECT_NO       {get;set;}
        @AuraEnabled public String ZTERM            {get;set;}
        @AuraEnabled public String ORD_REASON       {get;set;}
        @AuraEnabled public String BZIRK            {get;set;}
        
        @AuraEnabled public String DOCUFEE          {get;set;}

        public IF_PARTS_009_Req_LS_MAIN_HEAD(){}
    }
    public class IF_PARTS_009_Req_LS_ERROR_IGNORE{
        @AuraEnabled public String IGNORE           {get;set;}
        @AuraEnabled public String IGNORE_QTY       {get;set;}
        @AuraEnabled public String IGNORE_PRICE     {get;set;}
        @AuraEnabled public String IGNORE_DIVISION  {get;set;}
        @AuraEnabled public String IGNORE_PURCHASE  {get;set;}

        @AuraEnabled public String IGNORE_HAZARD    {get;set;}

        public IF_PARTS_009_Req_LS_ERROR_IGNORE(){}
    }
    public class IF_PARTS_009_Req_LS_IMPORT_PORTAL{
        @AuraEnabled public String DOC_CATEGORY {get;set;}
        @AuraEnabled public String DOC_MODE     {get;set;}
        @AuraEnabled public String COMPLAINT    {get;set;}

        public IF_PARTS_009_Req_LS_IMPORT_PORTAL(){}
    }
    public class IF_PARTS_009_Req_I_ORG{
        @AuraEnabled public String VKORG    {get;set;}
        @AuraEnabled public String VTWEG    {get;set;}
        @AuraEnabled public String SPART    {get;set;}
        @AuraEnabled public String WERKS    {get;set;}
        @AuraEnabled public String ARBPL    {get;set;}

        @AuraEnabled public String AMSCCTL  {get;set;}

        public IF_PARTS_009_Req_I_ORG(){}
    }
    public class IF_PARTS_009_Req_LT_GERNERAL_ZTERM{
        @AuraEnabled public String ZTERM  {get;set;}
        @AuraEnabled public String TEXT   {get;set;}

        public IF_PARTS_009_Req_LT_GERNERAL_ZTERM(){}
    }
    public class IF_PARTS_009_Req_LT_PARTNER{
        @AuraEnabled public String PARTN_ROLE   {get;set;}
        @AuraEnabled public String PARTN_NUMB   {get;set;}
        @AuraEnabled public String ITM_NUMBER   {get;set;}
        @AuraEnabled public String TITLE        {get;set;}
        @AuraEnabled public String NAME         {get;set;}

        @AuraEnabled public String NAME_2       {get;set;}
        @AuraEnabled public String NAME_3       {get;set;}
        @AuraEnabled public String NAME_4       {get;set;}
        @AuraEnabled public String STREET       {get;set;}
        @AuraEnabled public String COUNTRY      {get;set;}
        
        @AuraEnabled public String COUNTR_ISO   {get;set;}
        @AuraEnabled public String POSTL_CODE   {get;set;}
        @AuraEnabled public String POBX_PCD     {get;set;}
        @AuraEnabled public String POBX_CTY     {get;set;}
        @AuraEnabled public String CITY         {get;set;}
        
        @AuraEnabled public String DISTRICT     {get;set;}
        @AuraEnabled public String REGION       {get;set;}
        @AuraEnabled public String PO_BOX       {get;set;}
        @AuraEnabled public String TELEPHONE    {get;set;}
        @AuraEnabled public String TELEPHONE2   {get;set;}
        
        @AuraEnabled public String TELEBOX      {get;set;}
        @AuraEnabled public String FAX_NUMBER   {get;set;}
        @AuraEnabled public String TELETEX_NO   {get;set;}
        @AuraEnabled public String TELEX_NO     {get;set;}
        @AuraEnabled public String LANGU        {get;set;}
        
        @AuraEnabled public String LANGU_ISO    {get;set;}
        @AuraEnabled public String UNLOAD_PT    {get;set;}
        @AuraEnabled public String TRANSPZONE   {get;set;}
        @AuraEnabled public String TAXJURCODE   {get;set;}
        @AuraEnabled public String ADDRESS      {get;set;}
        
        @AuraEnabled public String PRIV_ADDR    {get;set;}
        @AuraEnabled public String ADDR_TYPE    {get;set;}
        @AuraEnabled public String ADDR_ORIG    {get;set;}
        @AuraEnabled public String ADDR_LINK    {get;set;}
        @AuraEnabled public String REFOBJTYPE   {get;set;}
        
        @AuraEnabled public String REFOBJKEY    {get;set;}
        @AuraEnabled public String REFLOGSYS    {get;set;}

        public IF_PARTS_009_Req_LT_PARTNER(){}
    }
    public class IF_PARTS_009_Req_LT_ITEM{
        @AuraEnabled public String CCHECK           {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String MATERIAL         {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}

        @AuraEnabled public String QTY              {get;set;}
        @AuraEnabled public String UOM              {get;set;}
        @AuraEnabled public String NET_PRICE        {get;set;}
        @AuraEnabled public String NET_ITEM_PRICE   {get;set;}
        @AuraEnabled public String NET_VALUE        {get;set;}
        
        @AuraEnabled public String LIST_PRICE       {get;set;}
        @AuraEnabled public String IF_CURRENCY      {get;set;}
        @AuraEnabled public String AVAILABILITY     {get;set;}
        @AuraEnabled public String REF_ORD          {get;set;}
        @AuraEnabled public String REF_ITEM         {get;set;}
        
        @AuraEnabled public String COMPLAINT        {get;set;}
        @AuraEnabled public String COMPLAINT_DESC   {get;set;}
        @AuraEnabled public String PLANT            {get;set;}
        @AuraEnabled public String O                {get;set;}
        @AuraEnabled public String C                {get;set;}
        
        @AuraEnabled public String D                {get;set;}
        @AuraEnabled public String BD               {get;set;}
        @AuraEnabled public String BO               {get;set;}
        @AuraEnabled public String DB               {get;set;}
        @AuraEnabled public String R                {get;set;}
        
        @AuraEnabled public String PLANT_TX         {get;set;}
        @AuraEnabled public String USAGE_HILV       {get;set;}
        @AuraEnabled public String CHEKCABLE        {get;set;}
        @AuraEnabled public String MATNR_CHECK      {get;set;}
        @AuraEnabled public String A                {get;set;}
        
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String MATNR_DESIGN     {get;set;}
        @AuraEnabled public String REQ_QTY_DESIGN   {get;set;}
        
        @AuraEnabled public String ZZDEALDT         {get;set;}
        @AuraEnabled public String WAERS            {get;set;}
        @AuraEnabled public String REASON           {get;set;}
        @AuraEnabled public String INPUT_QTY        {get;set;}
        @AuraEnabled public String EXCEL            {get;set;}
        
        @AuraEnabled public String MVGR5            {get;set;}
        @AuraEnabled public String MATERIAL_ENT     {get;set;}
        @AuraEnabled public String ERRORCHECK       {get;set;}
        @AuraEnabled public String ERRORMSG         {get;set;}
        @AuraEnabled public String SUGRD            {get;set;}
        
        @AuraEnabled public String COMPLAINT_REASON {get;set;}
        @AuraEnabled public String ACCEPT           {get;set;}
        @AuraEnabled public String MATERIAL_N       {get;set;}
        @AuraEnabled public String NETPR            {get;set;}
        @AuraEnabled public String DIEUCE           {get;set;}
        
        @AuraEnabled public String DIEUFL           {get;set;}
        @AuraEnabled public String DIUK             {get;set;}
        @AuraEnabled public String DIID             {get;set;}
        @AuraEnabled public String DI               {get;set;}
        @AuraEnabled public String DIUKL            {get;set;}
        
        @AuraEnabled public String MEINS            {get;set;}
        @AuraEnabled public String HERKL            {get;set;}
        @AuraEnabled public String KONDM            {get;set;}
        @AuraEnabled public String NTGEW            {get;set;}
        @AuraEnabled public String GEWEI            {get;set;}
        
        @AuraEnabled public String POUND            {get;set;}
        @AuraEnabled public String KUNNR            {get;set;}
        @AuraEnabled public String TDLNR            {get;set;}
        @AuraEnabled public String TDLNR_NAME       {get;set;}
        @AuraEnabled public String BSTKD_E          {get;set;}
        
        @AuraEnabled public String BSTDK_E          {get;set;}
        @AuraEnabled public String AVAIL_QTY1       {get;set;}
        @AuraEnabled public String AVAIL_QTY2       {get;set;}
        @AuraEnabled public String ZZAPPMACHINE     {get;set;}
        @AuraEnabled public String ZZEQMASTER       {get;set;}
        @AuraEnabled public String ZZWORKHRS        {get;set;}
        
        @AuraEnabled public String TNDR_TRKID       {get;set;}
        @AuraEnabled public String STATUS           {get;set;}
        @AuraEnabled public String MITEM            {get;set;}
        @AuraEnabled public String TO_PART          {get;set;}
        @AuraEnabled public String BULLETIN         {get;set;}
        
        @AuraEnabled public String BULL_MATNR       {get;set;}
        @AuraEnabled public String MEMO             {get;set;}
        @AuraEnabled public String MEMO_MATNR       {get;set;}
        @AuraEnabled public String EMERC            {get;set;}

        public IF_PARTS_009_Req_LT_ITEM(){}
    }
    public class IF_PARTS_009_Req_LT_STATUS{
        @AuraEnabled public String CODE             {get;set;}
        @AuraEnabled public String TEXT             {get;set;}
        @AuraEnabled public String NAME             {get;set;}

        public IF_PARTS_009_Req_LT_STATUS(){}
    }
    public class IF_PARTS_009_Res{
        @AuraEnabled public IF_PARTS_009_Res_LS_MAIN_HEAD_RESULT          LS_MAIN_HEAD_RESULT  {get;set;}
        @AuraEnabled public String                                        E_MEG                {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_ITEM>                LT_ITEM              {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_PRICING_01>          LT_PRICING_01        {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_PRICING_02>          LT_PRICING_02        {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_STATUS>              LT_STATUS            {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_ERRORMSG>               ERRORMSG             {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_NON_EXIST>           LT_NON_EXIST         {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_NON_QTY>             LT_NON_QTY           {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_WRONG_DIVISION>      LT_WRONG_DIVISION    {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_NON_PRICE>           LT_NON_PRICE         {get;set;}
        
        @AuraEnabled public List<IF_PARTS_009_Res_LT_NON_PURCHASE>        LT_NON_PURCHASE      {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_BAPIRET2>            LT_BAPIRET2          {get;set;}
        @AuraEnabled public List<IF_PARTS_009_Res_LT_WRONG_ITEM>          LT_WRONG_ITEM        {get;set;}
        @AuraEnabled public IF_PARTS_009_Res_LS_GENERAL                   LS_GENERAL           {get;set;}
        @AuraEnabled public IF_PARTS_009_Res_O_RETURN                     O_RETURN             {get;set;}
        @AuraEnabled public String                                        E_STAT               {get;set;}
        @AuraEnabled public String                                        ODKEY                {get;set;} // 오더 부품 고유 키

        public IF_PARTS_009_Res(){}
    }
    public class IF_PARTS_009_Res_LS_MAIN_HEAD_RESULT{
        @AuraEnabled public String KONDA                {get;set;}
        @AuraEnabled public String KUNNR                {get;set;}
        @AuraEnabled public String KUNNR_NAME           {get;set;}
        @AuraEnabled public String KUNNR_STREET         {get;set;}
        @AuraEnabled public String KUNAG                {get;set;}
        
        @AuraEnabled public String KUNAG_NAME           {get;set;}
        @AuraEnabled public String KUNAG_STREET         {get;set;}
        @AuraEnabled public String KUNNR_CR             {get;set;}
        @AuraEnabled public String NETWR                {get;set;}
        @AuraEnabled public String WAERK                {get;set;}
        
        @AuraEnabled public String CREDIT               {get;set;}
        @AuraEnabled public String CREDIT_WAERK         {get;set;}
        @AuraEnabled public String TOTAL_WEIGHT         {get;set;}
        @AuraEnabled public String GEWEI                {get;set;}
        @AuraEnabled public String VOLUM                {get;set;}
        
        @AuraEnabled public String VOLEH                {get;set;}
        @AuraEnabled public String KONDA_TEXT           {get;set;}
        @AuraEnabled public String KVGR5                {get;set;}
        @AuraEnabled public String NAME                 {get;set;}
        @AuraEnabled public String CITY                 {get;set;}
        
        @AuraEnabled public String STREET               {get;set;}
        @AuraEnabled public String COUNTRY              {get;set;}
        @AuraEnabled public String POSTL_CODE           {get;set;}
        @AuraEnabled public String TRANSPZONE           {get;set;}
        @AuraEnabled public String ORDER_DATE           {get;set;}
        
        @AuraEnabled public String PRICE_LIST           {get;set;}
        @AuraEnabled public String COLLECT_NO           {get;set;}
        @AuraEnabled public String ZTERM                {get;set;}
        @AuraEnabled public String ORD_REASON           {get;set;}
        @AuraEnabled public String BZIRK                {get;set;}
        
        @AuraEnabled public String DOCUFEE              {get;set;}

        public IF_PARTS_009_Res_LS_MAIN_HEAD_RESULT(){}
    }
    public class IF_PARTS_009_Res_LT_ITEM{
        @AuraEnabled public String CCHECK               {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String MATERIAL             {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}

        @AuraEnabled public String QTY                  {get;set;}
        @AuraEnabled public String UOM                  {get;set;}
        @AuraEnabled public String NET_PRICE            {get;set;}
        @AuraEnabled public String NET_ITEM_PRICE       {get;set;}
        @AuraEnabled public String NET_VALUE            {get;set;}
        
        @AuraEnabled public String LIST_PRICE           {get;set;}
        @AuraEnabled public String IF_CURRENCY          {get;set;}
        @AuraEnabled public String AVAILABILITY         {get;set;}
        @AuraEnabled public String REF_ORD              {get;set;}
        @AuraEnabled public String REF_ITEM             {get;set;}
        
        @AuraEnabled public String COMPLAINT            {get;set;}
        @AuraEnabled public String COMPLAINT_DESC       {get;set;}
        @AuraEnabled public String PLANT                {get;set;}
        @AuraEnabled public String O                    {get;set;}
        @AuraEnabled public String C                    {get;set;}
        
        @AuraEnabled public String D                    {get;set;}
        @AuraEnabled public String BD                   {get;set;}
        @AuraEnabled public String BO                   {get;set;}
        @AuraEnabled public String DB                   {get;set;}
        @AuraEnabled public String R                    {get;set;}
        
        @AuraEnabled public String PLANT_TX             {get;set;}
        @AuraEnabled public String USAGE_HILV           {get;set;}
        @AuraEnabled public String CHEKCABLE            {get;set;}
        @AuraEnabled public String MATNR_CHECK          {get;set;}
        @AuraEnabled public String A                    {get;set;}
        
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String MATNR_DESIGN         {get;set;}
        @AuraEnabled public String REQ_QTY_DESIGN       {get;set;}
        
        @AuraEnabled public String ZZDEALDT             {get;set;}
        @AuraEnabled public String WAERS                {get;set;}
        @AuraEnabled public String REASON               {get;set;}
        @AuraEnabled public String INPUT_QTY            {get;set;}
        @AuraEnabled public String EXCEL                {get;set;}
        
        @AuraEnabled public String MVGR5                {get;set;}
        @AuraEnabled public String MATERIAL_ENT         {get;set;}
        @AuraEnabled public String ERRORCHECK           {get;set;}
        @AuraEnabled public String ERRORMSG             {get;set;}
        @AuraEnabled public String SUGRD                {get;set;}
        
        @AuraEnabled public String COMPLAINT_REASON     {get;set;}
        @AuraEnabled public String ACCEPT               {get;set;}
        @AuraEnabled public String MATERIAL_N           {get;set;}
        @AuraEnabled public String NETPR                {get;set;}
        @AuraEnabled public String DIEUCE               {get;set;}

        @AuraEnabled public String DIEUFL               {get;set;}
        @AuraEnabled public String DIUK                 {get;set;}
        @AuraEnabled public String DIID                 {get;set;}
        @AuraEnabled public String DI                   {get;set;}
        @AuraEnabled public String DIUKL                {get;set;}
        
        @AuraEnabled public String MEINS                {get;set;}
        @AuraEnabled public String HERKL                {get;set;}
        @AuraEnabled public String KONDM                {get;set;}
        @AuraEnabled public String NTGEW                {get;set;}
        @AuraEnabled public String GEWEI                {get;set;}
        
        @AuraEnabled public String POUND                {get;set;}        
        @AuraEnabled public String KUNNR                {get;set;}
        @AuraEnabled public String TDLNR                {get;set;}
        @AuraEnabled public String TDLNR_NAME           {get;set;}
        @AuraEnabled public String BSTKD_E              {get;set;}
        
        @AuraEnabled public String BSTDK_E              {get;set;}
        @AuraEnabled public String AVAIL_QTY1           {get;set;}
        @AuraEnabled public String AVAIL_QTY2           {get;set;}
        @AuraEnabled public String ZZAPPMACHINE         {get;set;}
        @AuraEnabled public String ZZEQMASTER           {get;set;}
        @AuraEnabled public String ZZWORKHRS            {get;set;}
        
        @AuraEnabled public String TNDR_TRKID           {get;set;}
        @AuraEnabled public String STATUS               {get;set;}
        @AuraEnabled public String MITEM                {get;set;}
        @AuraEnabled public String TO_PART              {get;set;}
        @AuraEnabled public String BULLETIN             {get;set;}
        
        @AuraEnabled public String BULL_MATNR           {get;set;}
        @AuraEnabled public String MEMO                 {get;set;}
        @AuraEnabled public String MEMO_MATNR           {get;set;}
        @AuraEnabled public String EMERC                {get;set;}
        
        public IF_PARTS_009_Res_LT_ITEM(){}
    }
    public class IF_PARTS_009_Res_LT_PRICING_01{
        @AuraEnabled public String NAME     {get;set;}
        @AuraEnabled public String NEWR     {get;set;}
        @AuraEnabled public String WAERK    {get;set;}
        @AuraEnabled public String NETWR    {get;set;}

        public IF_PARTS_009_Res_LT_PRICING_01(){}
    }
    public class IF_PARTS_009_Res_LT_PRICING_02{
        @AuraEnabled public String NAME     {get;set;}
        @AuraEnabled public String NEWR     {get;set;}
        @AuraEnabled public String WAERK    {get;set;}
        @AuraEnabled public String NETWR    {get;set;}

        public IF_PARTS_009_Res_LT_PRICING_02(){}
    }
    public class IF_PARTS_009_Res_LT_STATUS{
        @AuraEnabled public String CODE {get;set;}
        @AuraEnabled public String TEXT {get;set;}
        @AuraEnabled public String NAME {get;set;}

        public IF_PARTS_009_Res_LT_STATUS(){}
    }
    public class IF_PARTS_009_Res_ERRORMSG{
        @AuraEnabled public String NAME {get;set;}
        @AuraEnabled public String TEXT {get;set;}

        public IF_PARTS_009_Res_ERRORMSG(){}
    }
    public class IF_PARTS_009_Res_LT_NON_EXIST{
        @AuraEnabled public String ERROR_MATNR          {get;set;}
        @AuraEnabled public String APPLY                {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String ID                   {get;set;}

        @AuraEnabled public String IF_NUMBER            {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String NOTCD                {get;set;}
        @AuraEnabled public String NOTCD_TEXT           {get;set;}
        @AuraEnabled public String PO_ITM_NO            {get;set;}

        public IF_PARTS_009_Res_LT_NON_EXIST(){}
    }
    public class IF_PARTS_009_Res_LT_NON_QTY{
        @AuraEnabled public String ERROR_MATNR      {get;set;}
        @AuraEnabled public String APPLY            {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String ID               {get;set;}

        @AuraEnabled public String IF_NUMBER        {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String NOTCD            {get;set;}
        @AuraEnabled public String NOTCD_TEXT       {get;set;}
        @AuraEnabled public String PO_ITM_NO        {get;set;}

        public IF_PARTS_009_Res_LT_NON_QTY(){}
    }
    public class IF_PARTS_009_Res_LT_WRONG_DIVISION{
        @AuraEnabled public String ERROR_MATNR          {get;set;}
        @AuraEnabled public String APPLY                {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String ID                   {get;set;}

        @AuraEnabled public String IF_NUMBER            {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String NOTCD                {get;set;}
        @AuraEnabled public String NOTCD_TEXT           {get;set;}
        @AuraEnabled public String PO_ITM_NO            {get;set;}
        
        public IF_PARTS_009_Res_LT_WRONG_DIVISION(){}
    }
    public class IF_PARTS_009_Res_LT_NON_PRICE{
        @AuraEnabled public String ERROR_MATNR      {get;set;}
        @AuraEnabled public String APPLY            {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String ID               {get;set;}

        @AuraEnabled public String IF_NUMBER        {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String NOTCD            {get;set;}
        @AuraEnabled public String NOTCD_TEXT       {get;set;}
        @AuraEnabled public String PO_ITM_NO        {get;set;}

        public IF_PARTS_009_Res_LT_NON_PRICE(){}
    }
    public class IF_PARTS_009_Res_LT_NON_PURCHASE{
        @AuraEnabled public String ERROR_MATNR      {get;set;}
        @AuraEnabled public String APPLY            {get;set;}
        @AuraEnabled public String ITEM             {get;set;}
        @AuraEnabled public String HILV             {get;set;}
        @AuraEnabled public String ID               {get;set;}

        @AuraEnabled public String IF_NUMBER        {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
        @AuraEnabled public String MATERIAL_TEXT    {get;set;}
        @AuraEnabled public String REQ_QTY          {get;set;}
        @AuraEnabled public String LOT_QTY          {get;set;}
        
        @AuraEnabled public String MIN_QTY          {get;set;}
        @AuraEnabled public String NOTCD            {get;set;}
        @AuraEnabled public String NOTCD_TEXT       {get;set;}
        @AuraEnabled public String PO_ITM_NO        {get;set;}

        public IF_PARTS_009_Res_LT_NON_PURCHASE(){}
    }
    public class IF_PARTS_009_Res_LT_BAPIRET2{
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
        
        public IF_PARTS_009_Res_LT_BAPIRET2(){}
    }
    public class IF_PARTS_009_Res_LT_WRONG_ITEM{
        @AuraEnabled public String ERROR_MATNR          {get;set;}
        @AuraEnabled public String APPLY                {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String ID                   {get;set;}

        @AuraEnabled public String IF_NUMBER            {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}
        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String REQ_QTY              {get;set;}
        @AuraEnabled public String LOT_QTY              {get;set;}
        
        @AuraEnabled public String MIN_QTY              {get;set;}
        @AuraEnabled public String NOTCD                {get;set;}
        @AuraEnabled public String NOTCD_TEXT           {get;set;}
        @AuraEnabled public String PO_ITM_NO            {get;set;}
        
        public IF_PARTS_009_Res_LT_WRONG_ITEM(){}
    }
    public class IF_PARTS_009_Res_LS_GENERAL{
        @AuraEnabled public String BSTNK                {get;set;}
        @AuraEnabled public String VDATU                {get;set;}
        @AuraEnabled public String INCO1                {get;set;}
        @AuraEnabled public String INCO2                {get;set;}
        @AuraEnabled public String VSBED                {get;set;}

        @AuraEnabled public String COMPLETE_DELIVERY    {get;set;}
        @AuraEnabled public String ROUTE                {get;set;}
        @AuraEnabled public String VSBED_TX             {get;set;}
        @AuraEnabled public String ROUTE_TX             {get;set;}
        @AuraEnabled public String SPECPROCID           {get;set;}
        
        @AuraEnabled public String POSSIBLE_DATE        {get;set;}
        @AuraEnabled public String IF_FROM              {get;set;}
        @AuraEnabled public String TO                   {get;set;}
        @AuraEnabled public String AUDAT                {get;set;}
        @AuraEnabled public String ERZET                {get;set;}
        
        @AuraEnabled public String BSTKD_E              {get;set;}
        @AuraEnabled public String ZZCFDAT              {get;set;}

        public IF_PARTS_009_Res_LS_GENERAL(){}
    }
    public class IF_PARTS_009_Res_O_RETURN{
        @AuraEnabled public String TYPE                 {get;set;}
        @AuraEnabled public String CODE                 {get;set;}
        @AuraEnabled public String MESSAGE              {get;set;}

        public IF_PARTS_009_Res_O_RETURN(){}
    }

    /** SFDC interface Id    : IF-PARTS-012
     * RFC Name              : ZCRM_EP_ORDERSTATUS_INFO2
     * Description           : 오더 상태 목록 조회
    */
    public class IF_PARTS_012_Req{
        @AuraEnabled public String I_FDATE                              {get;set;}
        @AuraEnabled public String I_TDATE                              {get;set;}
        @AuraEnabled public String I_VBELN                              {get;set;}
        @AuraEnabled public String I_BSTKD                              {get;set;}

        @AuraEnabled public String I_AUART                              {get;set;}
        @AuraEnabled public String I_KONDA                              {get;set;}
        @AuraEnabled public String I_PENDING                            {get;set;}
        @AuraEnabled public String I_MATNR                              {get;set;}
        
        @AuraEnabled public String I_DIG                                {get;set;}
        @AuraEnabled public String I_EQFNR                              {get;set;}
        @AuraEnabled public String I_STATUS                             {get;set;}
        @AuraEnabled public IF_PARTS_012_Req_I_USERINFO  I_USERINFO     {get;set;}
        
        public IF_PARTS_012_Req(){}
    }
    public class IF_PARTS_012_Req_I_USERINFO{
        @AuraEnabled public String BNAME   {get;set;}
        @AuraEnabled public String RNAME   {get;set;}
        @AuraEnabled public String HIER    {get;set;}
        @AuraEnabled public String KUNNR   {get;set;}
        @AuraEnabled public String LIFNR   {get;set;}

        @AuraEnabled public String VKORG   {get;set;}
        @AuraEnabled public String VTWEG   {get;set;}
        @AuraEnabled public String SPART   {get;set;}
        @AuraEnabled public String WERKS   {get;set;}
        @AuraEnabled public String ARBPL   {get;set;}

        @AuraEnabled public String PARNR   {get;set;}
        @AuraEnabled public String ENAME   {get;set;}
        @AuraEnabled public String KUNN2   {get;set;}
        @AuraEnabled public String LAND1   {get;set;}
        @AuraEnabled public String LGORT   {get;set;}
        
        @AuraEnabled public String DF_CHK  {get;set;}
        @AuraEnabled public String CO_CHK  {get;set;}

        public IF_PARTS_012_Req_I_USERINFO(){}
    }
    public class IF_PARTS_012_Res{
        @AuraEnabled public String O_MESG                             {get;set;}
        @AuraEnabled public String O_COUNT                            {get;set;}
        @AuraEnabled public IF_PARTS_012_Res_O_RETURN O_RETURN        {get;set;}
        @AuraEnabled public List<IF_PARTS_012_Res_T_HEADER> T_HEADER  {get;set;}

        public IF_PARTS_012_Res(){}
    }
    public class IF_PARTS_012_Res_O_RETURN{
        @AuraEnabled public String TYPE        {get;set;}
        @AuraEnabled public String CODE        {get;set;}
        @AuraEnabled public String MESSAGE     {get;set;}
        @AuraEnabled public String LOG_NO      {get;set;}

        @AuraEnabled public String LOG_MSG_NO  {get;set;}
        @AuraEnabled public String MESSAGE_V1  {get;set;}
        @AuraEnabled public String MESSAGE_V2  {get;set;}
        @AuraEnabled public String MESSAGE_V3  {get;set;}
        
        @AuraEnabled public String MESSAGE_V4  {get;set;}

        public IF_PARTS_012_Res_O_RETURN(){}
    }
    public class IF_PARTS_012_Res_T_HEADER{
        @AuraEnabled public String VBELN     {get;set;}
        @AuraEnabled public String BSTKD     {get;set;}
        @AuraEnabled public String AUART     {get;set;}
        @AuraEnabled public String AUART_T   {get;set;}
        @AuraEnabled public String KONDA     {get;set;}

        @AuraEnabled public String KONDA_T   {get;set;}
        @AuraEnabled public String ZTERM     {get;set;}
        @AuraEnabled public String ZTERM_T   {get;set;}
        @AuraEnabled public String VSBED     {get;set;}
        
        @AuraEnabled public String VSBED_T   {get;set;}
        @AuraEnabled public String WAERK     {get;set;}
        @AuraEnabled public String SO_ITEM   {get;set;}
        @AuraEnabled public String SO_AMT    {get;set;}
        
        @AuraEnabled public String RE_AMT    {get;set;}
        @AuraEnabled public String PI_AMT    {get;set;}
        @AuraEnabled public String IN_AMT    {get;set;}
        @AuraEnabled public String SH_AMT    {get;set;}
        
        @AuraEnabled public String BO_AMT    {get;set;}
        @AuraEnabled public String CA_AMT    {get;set;}
        @AuraEnabled public String KWMENG    {get;set;}
        @AuraEnabled public String SO_QTY    {get;set;}
        
        @AuraEnabled public String PI_QTY    {get;set;}
        @AuraEnabled public String SH_QTY    {get;set;}
        @AuraEnabled public String RE_QTY    {get;set;}
        @AuraEnabled public String IN_QTY    {get;set;}
        
        @AuraEnabled public String CFM_QTY   {get;set;}
        @AuraEnabled public String RJ_QTY    {get;set;}
        @AuraEnabled public String VRKME     {get;set;}
        @AuraEnabled public String ERDAT     {get;set;}
        
        @AuraEnabled public String EQFNR     {get;set;}
        @AuraEnabled public String KUNWE     {get;set;}
        @AuraEnabled public String NAME1     {get;set;}
        @AuraEnabled public String ZZAPPNO   {get;set;}
        
        @AuraEnabled public String NAME2     {get;set;}
        @AuraEnabled public String BNAME     {get;set;}
        @AuraEnabled public String STATUS    {get;set;}
        @AuraEnabled public String LIFSK     {get;set;}

        public IF_PARTS_012_Res_T_HEADER(){}
    }

    /** SFDC interface Id    : IF-PARTS-013
     *  RFC Name             : ZCRM_EP_STATUS_INFO_DETAIL2
     *  Description          : 오더 상태 상세 조회를 위한 I/F 호출
    */
    public class IF_PARTS_013_Req{
        @AuraEnabled public String I_FDATE                               {get;set;}
        @AuraEnabled public String I_TDATE                               {get;set;}
        @AuraEnabled public String I_VBELN                               {get;set;}
        @AuraEnabled public String I_BSTKD                               {get;set;}
        @AuraEnabled public String I_MATNR                               {get;set;}

        @AuraEnabled public String I_STATUS                              {get;set;}
        @AuraEnabled public String I_DROP                                {get;set;}
        @AuraEnabled public String I_SCOMB                               {get;set;}
        @AuraEnabled public List<IF_PARTS_013_Req_LT_VBELN> LT_VBELN     {get;set;}
        @AuraEnabled public IF_PARTS_013_Req_I_USERINFO     I_USERINFO   {get;set;}
        
        //2025.03.31 추가
        @AuraEnabled public String I_RESULT_REMARK      {get;set;}
        
        public IF_PARTS_013_Req(){}
    }
    public class IF_PARTS_013_Req_I_USERINFO{
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

        public IF_PARTS_013_Req_I_USERINFO(){}
    }
    public class IF_PARTS_013_Req_LT_VBELN{
        @AuraEnabled public String VBELN        {get;set;}

        public IF_PARTS_013_Req_LT_VBELN(){}
    }
    public class IF_PARTS_013_Res{
        @AuraEnabled public String O_MESG                                       {get;set;}
        @AuraEnabled public String O_COUNT                                      {get;set;}
        @AuraEnabled public IF_PARTS_013_Res_O_RETURN O_RETURN                  {get;set;}
        @AuraEnabled public List<IF_PARTS_013_Res_T_SALES_AREA> T_SALES_AREA    {get;set;}

        @AuraEnabled public List<IF_PARTS_013_Res_T_DETAIL> T_DETAIL            {get;set;}

        public IF_PARTS_013_Res(){}
    }
    public class IF_PARTS_013_Res_O_RETURN{
        @AuraEnabled public String TYPE         {get;set;}
        @AuraEnabled public String CODE         {get;set;}
        @AuraEnabled public String MESSAGE      {get;set;}
        @AuraEnabled public String LOG_NO       {get;set;}

        @AuraEnabled public String LOG_MSG_NO   {get;set;}
        @AuraEnabled public String MESSAGE_V1   {get;set;}
        @AuraEnabled public String MESSAGE_V2   {get;set;}
        @AuraEnabled public String MESSAGE_V3   {get;set;}
        
        @AuraEnabled public String MESSAGE_V4   {get;set;}

        public IF_PARTS_013_Res_O_RETURN(){}
    }
    public class IF_PARTS_013_Res_T_SALES_AREA{
        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}

        public IF_PARTS_013_Res_T_SALES_AREA(){}
    }
    public class IF_PARTS_013_Res_T_DETAIL{
        @AuraEnabled public String VBELN        {get;set;}
        @AuraEnabled public String BSTKD        {get;set;}
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String POSNR_H      {get;set;}

        @AuraEnabled public String ETENR        {get;set;}
        @AuraEnabled public String ERDAT        {get;set;}
        @AuraEnabled public String AUDAT        {get;set;}
        @AuraEnabled public String KONDA        {get;set;}
        
        @AuraEnabled public String KONDA_T      {get;set;}
        @AuraEnabled public String AUART        {get;set;}
        @AuraEnabled public String AUART_T      {get;set;}
        @AuraEnabled public String MATNR_SO     {get;set;}
        
        @AuraEnabled public String MATNR_SH     {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String SO_QTY       {get;set;}
        @AuraEnabled public String PI_QTY       {get;set;}
        
        @AuraEnabled public String SH_QTY       {get;set;}
        @AuraEnabled public String RE_QTY       {get;set;}
        @AuraEnabled public String IN_QTY       {get;set;}
        @AuraEnabled public String CFM_QTY      {get;set;}
        
        @AuraEnabled public String STB_QTY      {get;set;}
        @AuraEnabled public String VRKME        {get;set;}
        @AuraEnabled public String FST_ETD      {get;set;}
        @AuraEnabled public String LST_ETD      {get;set;}
        
        @AuraEnabled public String DODAT        {get;set;}
        @AuraEnabled public String VSTEL        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String EMERC        {get;set;}
        @AuraEnabled public String NETPR        {get;set;}
        @AuraEnabled public String WAERK        {get;set;}

        public IF_PARTS_013_Res_T_DETAIL(){}
    }

    /** SFDC interface Id   : IF-PARTS-026
     * RFC Name             : ZCRM_SS_RECV_CHANGE_EMERGENCY
     * Description          : 오더상세 화면에서 상태 저장
    */
    public class IF_PARTS_026_Req{
        @AuraEnabled public String I_VKORG      {get;set;}
        @AuraEnabled public String I_VTWEG      {get;set;}
        @AuraEnabled public String I_SPART      {get;set;}
        @AuraEnabled public String I_KUNNR      {get;set;}
        @AuraEnabled public String I_VBELN      {get;set;}

        @AuraEnabled public String I_USERID     {get;set;}
        @AuraEnabled public List<IF_PARTS_026_Req_IT_ITEM> IT_ITEM {get;set;}
        public IF_PARTS_026_Req (){}
    }
    public class IF_PARTS_026_Req_IT_ITEM{
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String ETENR        {get;set;}
        @AuraEnabled public String EMERC        {get;set;}

        public IF_PARTS_026_Req_IT_ITEM (){}
    }
    public class IF_PARTS_026_Res{
        @AuraEnabled public IF_PARTS_026_Res_ES_RETURN ES_RETURN {get;set;}

        public IF_PARTS_026_Res(){}
    }
    public class IF_PARTS_026_Res_ES_RETURN{
        @AuraEnabled public String TYPE             {get;set;}
        @AuraEnabled public String ID               {get;set;}
        @AuraEnabled public String IF_NUMBER        {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
        @AuraEnabled public String LOG_NO           {get;set;}

        @AuraEnabled public String LOG_MSG_NO       {get;set;}
        @AuraEnabled public String MESSAGE_V1       {get;set;}
        @AuraEnabled public String MESSAGE_V2       {get;set;}
        @AuraEnabled public String MESSAGE_V3       {get;set;}
        @AuraEnabled public String MESSAGE_V4       {get;set;}
        
        @AuraEnabled public String PARAMETER        {get;set;}
        @AuraEnabled public String ROW              {get;set;}
        @AuraEnabled public String FIELD            {get;set;}
        @AuraEnabled public String IF_SYSTEM        {get;set;}

        public IF_PARTS_026_Res_ES_RETURN (){}
    }

    /** SFDC interface Id   : IF-PARTS-034
     * RFC Name             : ZCRM_EP_ORDER_LIST_DETAIL
     * Description          : 부품 주문 데이터 ERP – CRM 동기화
    */
    public class IF_PARTS_034_Req{
        @AuraEnabled public IF_PARTS_034_Req_I_USERINFO     I_USERINFO      {get;set;}
        @AuraEnabled public String                          I_FDATE         {get;set;}
        @AuraEnabled public String                          I_TDATE         {get;set;}

        public IF_PARTS_034_Req(){}
    }
    public class IF_PARTS_034_Req_I_USERINFO{
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

        public IF_PARTS_034_Req_I_USERINFO(){}
    }
    public class IF_PARTS_034_Res{
        @AuraEnabled public IF_PARTS_034_Res_O_RETURN               O_RETURN        {get;set;}
        @AuraEnabled public List<IF_PARTS_034_Res_T_SALESAREA>      T_SALESAREA     {get;set;}
        @AuraEnabled public List<IF_PARTS_034_Res_T_HEADER>         T_HEADER        {get;set;}
        @AuraEnabled public List<IF_PARTS_034_Res_T_DETAIL>         T_DETAIL        {get;set;}

        public IF_PARTS_034_Res(){}
    }
    public class IF_PARTS_034_Res_O_RETURN{
        @AuraEnabled public String TYPE         {get;set;}
        @AuraEnabled public String CODE         {get;set;}
        @AuraEnabled public String MESSAGE      {get;set;}

        public IF_PARTS_034_Res_O_RETURN(){}
    }
    public class IF_PARTS_034_Res_T_SALESAREA{
        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}

        public IF_PARTS_034_Res_T_SALESAREA(){}
    }
    public class IF_PARTS_034_Res_T_HEADER{
        @AuraEnabled public String VBELN        {get;set;}
        @AuraEnabled public String BSTKD        {get;set;}
        @AuraEnabled public String AUART        {get;set;}
        @AuraEnabled public String AUART_T      {get;set;}
        @AuraEnabled public String KONDA        {get;set;}

        @AuraEnabled public String KONDA_T      {get;set;}
        @AuraEnabled public String ZTERM        {get;set;}
        @AuraEnabled public String ZTERM_T      {get;set;}
        @AuraEnabled public String VSBED        {get;set;}
        @AuraEnabled public String VSBED_T      {get;set;}
        
        @AuraEnabled public String WAERK        {get;set;}
        @AuraEnabled public String SO_ITEM      {get;set;}
        @AuraEnabled public String SO_AMT       {get;set;}
        @AuraEnabled public String RE_AMT       {get;set;}
        @AuraEnabled public String PI_AMT       {get;set;}
        
        @AuraEnabled public String IN_AMT       {get;set;}
        @AuraEnabled public String SH_AMT       {get;set;}
        @AuraEnabled public String BO_AMT       {get;set;}
        @AuraEnabled public String CA_AMT       {get;set;}
        @AuraEnabled public String KWMENG       {get;set;}
        
        @AuraEnabled public String SO_QTY       {get;set;}
        @AuraEnabled public String PI_QTY       {get;set;}
        @AuraEnabled public String SH_QTY       {get;set;}
        @AuraEnabled public String RE_QTY       {get;set;}
        @AuraEnabled public String IN_QTY       {get;set;}
        
        @AuraEnabled public String CFM_QTY      {get;set;}
        @AuraEnabled public String RJ_QTY       {get;set;}
        @AuraEnabled public String VRKME        {get;set;}
        @AuraEnabled public String ERDAT        {get;set;}
        @AuraEnabled public String EQFNR        {get;set;}
        
        @AuraEnabled public String KUNWE        {get;set;}
        @AuraEnabled public String NAME1        {get;set;}
        @AuraEnabled public String ZZAPPNO      {get;set;}
        @AuraEnabled public String NAME2        {get;set;}
        @AuraEnabled public String BNAME        {get;set;}
        
        @AuraEnabled public String STATUS       {get;set;}
        @AuraEnabled public String LIFSK        {get;set;}
        
        public IF_PARTS_034_Res_T_HEADER(){}
    }
    public class IF_PARTS_034_Res_T_DETAIL{
        @AuraEnabled public String VBELN        {get;set;}
        @AuraEnabled public String BSTKD        {get;set;}
        @AuraEnabled public String POSNR        {get;set;}
        @AuraEnabled public String POSNR_H      {get;set;}
        @AuraEnabled public String ETENR        {get;set;}

        @AuraEnabled public String ERDAT        {get;set;}
        @AuraEnabled public String AUDAT        {get;set;}
        @AuraEnabled public String KONDA        {get;set;}
        @AuraEnabled public String KONDA_T      {get;set;}
        @AuraEnabled public String AUART        {get;set;}
        
        @AuraEnabled public String AUART_T      {get;set;}
        @AuraEnabled public String MATNR_SO     {get;set;}
        @AuraEnabled public String MATNR_SH     {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String SO_QTY       {get;set;}
        
        @AuraEnabled public String PI_QTY       {get;set;}
        @AuraEnabled public String SH_QTY       {get;set;}
        @AuraEnabled public String RE_QTY       {get;set;}
        @AuraEnabled public String IN_QTY       {get;set;}
        @AuraEnabled public String CFM_QTY      {get;set;}
        
        @AuraEnabled public String STB_QTY      {get;set;}
        @AuraEnabled public String VRKME        {get;set;}
        @AuraEnabled public String FST_ETD      {get;set;}
        @AuraEnabled public String LST_ETD      {get;set;}
        @AuraEnabled public String DODAT        {get;set;}
        
        @AuraEnabled public String VSTEL        {get;set;}
        @AuraEnabled public String VTEXT        {get;set;}
        @AuraEnabled public String EMERC        {get;set;}
        @AuraEnabled public String LIFSK        {get;set;}
        @AuraEnabled public String VBELN2       {get;set;}
        
        @AuraEnabled public String RFGSK_TX_T   {get;set;}
        @AuraEnabled public String INVOICE      {get;set;}

        public IF_PARTS_034_Res_T_DETAIL(){}
    }
}