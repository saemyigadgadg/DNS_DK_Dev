/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   01-24-2025   Hanyeong Choi   Initial Version
**/
public with sharing class IF_ERP_Order_Classes {
    public IF_ERP_Order_Classes() {}

// ** IF-ORDER-001				
/**
  */
  /**
         * Wrapper Name         : IF_ORDER_001
         * SFDC interface Id    : IF-ORDER-001
         * AS-IS RFC            : Z_SD_CREATE_SALES_ORDER_ME	
         * New I/F              : ZCRM_SD_CREATE_SALES_ORDER_ME
         * Description          : CRM에서 CPO 생성 후 ERP에 전송 
  */    
    // ** REQUEST
    /**
        */
        public class IF_ORDER_001_Req { 
            public IF_ORDER_001_Req(){
                this.I_USERINFO = new IF_ORDER_001_Req_I_USERINFO();
                this.I_HEAD = new IF_ORDER_001_Req_I_HEAD();
                this.I_GENERAL = new IF_ORDER_001_Req_I_GENERAL();
                this.I_PARTNER = new IF_ORDER_001_Req_I_PARTNER();
                this.I_COLLECTION = new IF_ORDER_001_Req_I_COLLECTION();
                this.I_WARRANT_OPT = new IF_ORDER_001_Req_I_WARRANT_OPT();
                this.I_NOTE = new IF_ORDER_001_Req_I_NOTE();
                this.I_NOTE2 = new IF_ORDER_001_Req_I_NOTE2();
                this.I_ZPDC = new IF_ORDER_001_Req_I_ZPDC();
                this.I_NOTE3 = new IF_ORDER_001_Req_I_NOTE3();
                this.I_NOTE4 = new IF_ORDER_001_Req_I_NOTE4();
                this.I_NOTE5 = new IF_ORDER_001_Req_I_NOTE5();
                this.I_NOTE_ZH27 = new IF_ORDER_001_Req_I_NOTE_ZH27();
                this.I_COM_DEALER = new IF_ORDER_001_Req_I_COM_DEALER();
        
                // 리스트 속성 초기화 (빈 리스트)
                this.T_ITEM = new List<IF_ORDER_001_Req_T_ITEM>();
                this.T_CONFIG = new List<IF_ORDER_001_Req_T_CONFIG>();
                this.T_SEL_CONFIG = new List<IF_ORDER_001_Req_T_SEL_CONFIG>();
                this.T_PRICING = new List<IF_ORDER_001_Req_T_PRICING>();
                this.T_PRICING_ADD = new List<IF_ORDER_001_Req_T_PRICING_ADD>();
                this.T_PRICING_RATE = new List<IF_ORDER_001_Req_T_PRICING_RATE>();
                this.T_WARRANTY_PARTS = new List<IF_ORDER_001_Req_T_WARRANTY_PARTS>();
                this.T_ORDER_REASON = new List<IF_ORDER_001_Req_T_ORDER_REASON>();
                this.T_ADD_DATA = new List<IF_ORDER_001_Req_T_ADD_DATA>();
                this.T_FILE = new List<IF_ORDER_001_Req_T_FILE>();
                this.T_WARRANTY_PARTSBK = new List<IF_ORDER_001_Req_T_WARRANTY_PARTSBK>();
                this.T_MULTICOND = new List<IF_ORDER_001_Req_T_MULTICOND>();                
            }
            @AuraEnabled public String I_UNAME        {get;set;} // ? User Name
            @AuraEnabled public String I_REF_ORDER    {get;set;} // ? Sales Document
            @AuraEnabled public String I_GUBUN        {get;set;} // ? 'C' = Create, 'U' = Change, 'D' = Delete
            @AuraEnabled public String I_TESTRUN      {get;set;} // ? Simulation
            @AuraEnabled public String I_SUBMI        {get;set;} // ? Dealer Ref.No
            @AuraEnabled public String I_ORG_VBELN    {get;set;} // ? Sales Document
            @AuraEnabled public String I_ZINDUS       {get;set;} // ? DI Machine Tool Industry Category 1
            @AuraEnabled public String I_ZINDUS2      {get;set;} // ? DI Machine Tool Industry Category 2
            @AuraEnabled public String I_STATUS       {get;set;} // ? [SD] SalesOrder Status
            @AuraEnabled public String I_SUPPLY_DATE  {get;set;} // ? Date
            @AuraEnabled public String I_SALESTERM    {get;set;} // ? Payment Terms(Extension)
            @AuraEnabled public String I_LAND1        {get;set;} // ? Country Key
            @AuraEnabled public String I_EXPORT       {get;set;} // ? Export or not : X means Export
            @AuraEnabled public String I_SPDC         {get;set;} // ? DMT domestic Spedical D/C flag
            @AuraEnabled public String I_PORTAL_GUBUN {get;set;} // ? Portal 입력위치구분
            @AuraEnabled public String I_ZZKVGR4      {get;set;}
            @AuraEnabled public String I_ZZWARRPER    {get;set;} // ? v2.2 Warranty Period 
            @AuraEnabled public String I_ZZPERUNIT    {get;set;} // ? v2.2 Warranty Indicator 
            @AuraEnabled public String I_ZZWARHRS     {get;set;} // ? v2.2 Warranty Hours 
            @AuraEnabled public String I_ZZWARRDAT    {get;set;} // ? v2.2 Warranty Valid on 
            @AuraEnabled public String I_ZZPR_WAR     {get;set;} // ? v2.2 Pricing Factor(Warranty) 
            @AuraEnabled public String I_ZZCOVERAGE   {get;set;} // ? v2.2 Warranty - Coverage 
            @AuraEnabled public String I_ZZCOVERAGE_B {get;set;} // ? v2.2 Warranty - Coverage (Added)             
            @AuraEnabled public String I_ZZSOCHAN     {get;set;}
            
            @AuraEnabled public IF_ORDER_001_Req_I_USERINFO I_USERINFO                       {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_HEAD I_HEAD                               {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_GENERAL I_GENERAL                         {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_PARTNER I_PARTNER                         {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_COLLECTION I_COLLECTION                   {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_WARRANT_OPT I_WARRANT_OPT                 {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_NOTE I_NOTE                               {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_NOTE2 I_NOTE2                             {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_ZPDC I_ZPDC                               {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_NOTE3 I_NOTE3                             {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_NOTE4 I_NOTE4                             {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_NOTE5 I_NOTE5                             {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_NOTE_ZH27 I_NOTE_ZH27                     {get;set;} 
            @AuraEnabled public IF_ORDER_001_Req_I_COM_DEALER I_COM_DEALER                   {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_ITEM> T_ITEM                         {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_CONFIG> T_CONFIG                     {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_SEL_CONFIG> T_SEL_CONFIG             {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_PRICING> T_PRICING                   {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_PRICING_ADD> T_PRICING_ADD           {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_PRICING_RATE> T_PRICING_RATE         {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_WARRANTY_PARTS> T_WARRANTY_PARTS     {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_ORDER_REASON> T_ORDER_REASON         {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_ADD_DATA> T_ADD_DATA                 {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_FILE> T_FILE                         {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_WARRANTY_PARTSBK> T_WARRANTY_PARTSBK {get;set;} 
            @AuraEnabled public List<IF_ORDER_001_Req_T_MULTICOND> T_MULTICOND               {get;set;} 
    
        }
    
        public class IF_ORDER_001_Req_I_USERINFO { 
            public IF_ORDER_001_Req_I_USERINFO(){}
            @AuraEnabled public String RNAME {get;set;}// ?  	Log테이블 저장을 위한 12자리 ID
            @AuraEnabled public String BNAME {get;set;}// ?  	S/F CRM User ID
            @AuraEnabled public String HIER {get;set;}// ?    [SS] User Hierrchy (Portal)
            @AuraEnabled public String KUNNR {get;set;}// ?  	Customer Number 1
            @AuraEnabled public String VKORG {get;set;}// ?  	Sales Organization
        }
    
        public class IF_ORDER_001_Req_I_HEAD { 
            public IF_ORDER_001_Req_I_HEAD(){}

            @AuraEnabled public String AUART {get;set;} // ? Sales Document Type
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
            @AuraEnabled public String SPART {get;set;} // ? Division
            @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
            @AuraEnabled public String KUNAG {get;set;} // ? Customer Number 1
            @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
            @AuraEnabled public String IHREZ {get;set;} // ? Your Reference

            // @AuraEnabled public String BEZEI {get;set;} // ? Description
            // @AuraEnabled public String VKORG_T {get;set;} // ? Name
            // @AuraEnabled public String VTWEG_T {get;set;} // ? Name
            // @AuraEnabled public String SPART_T {get;set;} // ? Name
    
            // @AuraEnabled public String KUNNR_NAME {get;set;} // ? Name 1
            // @AuraEnabled public String KUNNR_STREET {get;set;} // ? House number and street
            // @AuraEnabled public String KUNAG_NAME {get;set;} // ? Name 1
            // @AuraEnabled public String KUNAG_STREET {get;set;} // ? House number and street

    
            // @AuraEnabled public String VKBUR_TX {get;set;} // ? Name of the controlling area
            // @AuraEnabled public String VSBED {get;set;} // ? Shipping Conditions
            // @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            // @AuraEnabled public String AUDAT {get;set;} // ? Document Date (Date Received/Sent)
    
            // @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
            // @AuraEnabled public String BUKRS {get;set;} // ? Company Code
    
        }
    
        public class IF_ORDER_001_Req_I_GENERAL { 
            public IF_ORDER_001_Req_I_GENERAL(){}

            @AuraEnabled public String BSTNK    {get;set;} // ? Customer purchase order number
            @AuraEnabled public String VDATU    {get;set;} // ? Requested delivery date
            @AuraEnabled public String INCO1    {get;set;} // ? Incoterms (Part 1)
            @AuraEnabled public String INCO2    {get;set;} // ? Incoterms (Part 2)
            @AuraEnabled public String AUGRU    {get;set;} // ? Order reason (reason for the business transaction)
            @AuraEnabled public String ABRVW    {get;set;} // ? Usage Indicator
            @AuraEnabled public String BZIRK    {get;set;} // ? Sales district
            @AuraEnabled public String WAERK    {get;set;} // ? SD Document Currency
            @AuraEnabled public String WERK     {get;set;} // ? Delivering Plant (Own or External)
            @AuraEnabled public String BZIRK_TX {get;set;} // ? Sales district Txt
            @AuraEnabled public String PLTYP    {get;set;} // ? Price list type
            @AuraEnabled public String ZZSQNO   {get;set;} // ? Seqeunce Number
            @AuraEnabled public String ZTERM    {get;set;} // ? Terms of Payment Key
            @AuraEnabled public String ZSDFUNC  {get;set;} // ? Sales Function
            @AuraEnabled public String ZZREP_VKBUR {get;set;} // ? Responsible of office
            @AuraEnabled public String ZZSQITEM {get;set;} // ? SQ Item
    
            // @AuraEnabled public String WAERK_TX {get;set;} // ? Currency Txt
            // @AuraEnabled public String AUGRU_TX {get;set;} // ? Description
            // @AuraEnabled public String REP_NAME {get;set;} // ? Name of Representative
            // @AuraEnabled public String EXPORT_DATE {get;set;} // ? Date
            // @AuraEnabled public String ZZTECHARG {get;set;} // ? Tech Agreemnet Number
            // @AuraEnabled public String ZSDFUNC_TX {get;set;} // ? Function Txt
            // @AuraEnabled public String ZZREP_VKBUR_TX {get;set;} // ? Text (20 Characters)
            // @AuraEnabled public String ZPLAN_DT {get;set;} // ? Date
        }
    
        public class IF_ORDER_001_Req_I_PARTNER { 
            public IF_ORDER_001_Req_I_PARTNER(){}

            @AuraEnabled public String KUNNR1      {get;set;} // ? Customer Number 1
            @AuraEnabled public String KUNNR2      {get;set;} // ? Customer Number 1
            @AuraEnabled public String KVGRP1      {get;set;} // ? Customer group 1
            @AuraEnabled public String KVGRP2      {get;set;} // ? Customer group 2
            @AuraEnabled public String KVGRP3      {get;set;} // ? Customer group 3
            @AuraEnabled public String KUNNR3      {get;set;} // ? Customer Number 1
            @AuraEnabled public String KUNNR4      {get;set;} // ? Customer Number 1
            @AuraEnabled public String KUNNR2_TX   {get;set;} // ? CUSTOMER NAME
            @AuraEnabled public String KUNNR5      {get;set;} // ? Customer Number 1
            @AuraEnabled public String KUNNR6      {get;set;} // ? Account Number of Vendor or Creditor
            @AuraEnabled public String KUNNR6_TX   {get;set;} // ? CUSTOMER NAME
            @AuraEnabled public String KUNNR4_TX   {get;set;} // ? CUSTOMER NAME
            @AuraEnabled public String KUNNR3_TX   {get;set;} // ? CUSTOMER NAME
            @AuraEnabled public String KUNNR5_TX   {get;set;} // ? CUSTOMER NAME
            @AuraEnabled public String KUNNR1_TX   {get;set;} // ? CUSTOMER NAME
            @AuraEnabled public String KUNNR_ZP    {get;set;} // ? Customer Number 1
            @AuraEnabled public String KUNNR_ZP_TX {get;set;} // ? CUSTOMER NAME
            @AuraEnabled public String KUNNR7      {get;set;} // ? Related Dealer : ZI => since 1.6v 
            @AuraEnabled public String KUNNR7_TX    {get;set;} // ? Related Dealer  Text => since 1.6v 
    
        }
    
        public class IF_ORDER_001_Req_I_COLLECTION { 
            public IF_ORDER_001_Req_I_COLLECTION(){}

            @AuraEnabled public String ZZUSEDCAR_NO {get;set;} // ? Used Car Management No.
            @AuraEnabled public String ZZPERM_NO {get;set;} // ? Military Goods Permission No
            @AuraEnabled public String ZZCAPITAL_NO {get;set;} // ? Capital No.
            @AuraEnabled public String MORT_CODE1 {get;set;} // ? Mortgage Code
            @AuraEnabled public String MORT_DATE1 {get;set;} // ? Mortgage Date
            @AuraEnabled public String MORT_CODE2 {get;set;} // ? Mortgage Code
            @AuraEnabled public String MORT_DATE2 {get;set;} // ? Mortgage Date
            @AuraEnabled public String MORT_CODE3 {get;set;} // ? Mortgage Code
            @AuraEnabled public String MORT_DATE3 {get;set;} // ? Mortgage Date
            @AuraEnabled public String MORT_CODE4 {get;set;} // ? Mortgage Code
            @AuraEnabled public String MORT_DATE4 {get;set;} // ? Mortgage Date
            @AuraEnabled public String MORT_CODE5 {get;set;} // ? Mortgage Code
            @AuraEnabled public String MORT_DATE5 {get;set;} // ? Mortgage Date
            @AuraEnabled public String MORT_CODE6 {get;set;} // ? Mortgage Code
            @AuraEnabled public String MORT_DATE6 {get;set;} // ? Mortgage Date
            @AuraEnabled public String ZZWARRDAT {get;set;} // ? Warranty Valid on
            @AuraEnabled public String BASE_DATE {get;set;} // ? Incoming Plan Base Date
            @AuraEnabled public String ZZINCOM_NO {get;set;} // ? Incoming Plan NO
            @AuraEnabled public String NETWR     {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String NETWR1    {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String WAERK     {get;set;} // ? SD Document Currency
            @AuraEnabled public String INCOM_CODE {get;set;} // ? Incoming Plan Code
            @AuraEnabled public String ZTERM     {get;set;} // ? Terms of Payment Key
            @AuraEnabled public String EST_DAT   {get;set;} // ? Est.Incoming Date
            @AuraEnabled public String EST_AMT   {get;set;} // ? Est.Incoming AMT
            @AuraEnabled public String FA_CODE   {get;set;} // ? Financial Agency Code
            @AuraEnabled public String DOWN_REQ_NO {get;set;} // ? Downpayment Req.NO
            @AuraEnabled public String MODIFY_NETWR {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String ZZPERIOD  {get;set;} // ? Deferment Period
            @AuraEnabled public String ZZRAT_REDUCE {get;set;} // ? Interest rate reduce
            @AuraEnabled public String RESIDUAL  {get;set;} // ? Est.Incoming AMT
            @AuraEnabled public String ZZDRAFTNO {get;set;} // ? Draft Number            
            // @AuraEnabled public String ZZWARRPER {get;set;} // ? Warranty Period
            // @AuraEnabled public String ZZPERUNIT {get;set;} // ? Warranty Indicator
            // @AuraEnabled public String ZZWARHRS  {get;set;} // ? Warranty Hours

    
            // @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date

    
        }
    
        public class IF_ORDER_001_Req_I_WARRANT_OPT { 
            public IF_ORDER_001_Req_I_WARRANT_OPT(){}

            @AuraEnabled public String ZZWARRPER    {get;set;} // ? Warranty Period
            @AuraEnabled public String ZZWARHRS     {get;set;} // ? Warranty Hours
            @AuraEnabled public String ZZPR_WAR     {get;set;} // ? Pricing Factor(Warranty)
            @AuraEnabled public String ZZCOVERAGE   {get;set;} // ? Warranty - Coverage
            @AuraEnabled public String ZZCOVERAGE_B {get;set;} // ? Warranty - Coverage (Added)            
            // @AuraEnabled public String CONCATE      {get;set;} // ? Concate Txt

    
        }
    
        public class IF_ORDER_001_Req_I_NOTE { 
            public IF_ORDER_001_Req_I_NOTE(){}
            @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
            // @AuraEnabled public String USAGE {get;set;} // ? Char255
    
        }
    
        public class IF_ORDER_001_Req_I_NOTE2 { 
            public IF_ORDER_001_Req_I_NOTE2(){}
            @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
            // @AuraEnabled public String USAGE {get;set;} // ? Char255
    
        }
    
        public class IF_ORDER_001_Req_I_ZPDC { 
            public IF_ORDER_001_Req_I_ZPDC(){}

            @AuraEnabled public String EMP_NO      {get;set;} // ? Employee ID
            @AuraEnabled public String REASON_CODE {get;set;} // ? Promotion discount reason code for ZPDC
    
        }
    
        public class IF_ORDER_001_Req_I_NOTE3 {
            public IF_ORDER_001_Req_I_NOTE3(){}
            @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
            // @AuraEnabled public String USAGE {get;set;} // ? Char255
    
        }
    
        public class IF_ORDER_001_Req_I_NOTE4 { 
            public IF_ORDER_001_Req_I_NOTE4(){}
            @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
            // @AuraEnabled public String USAGE {get;set;} // ? Char255
        }
    
        public class IF_ORDER_001_Req_I_NOTE5 { 
            public IF_ORDER_001_Req_I_NOTE5(){}
            @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
            // @AuraEnabled public String USAGE {get;set;} // ? Char255
        }
    
        public class IF_ORDER_001_Req_I_NOTE_ZH27 { 
            public IF_ORDER_001_Req_I_NOTE_ZH27(){}
            @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
            // @AuraEnabled public String USAGE {get;set;} // ? Char255
    
        }
    
        public class IF_ORDER_001_Req_I_COM_DEALER { 
            public IF_ORDER_001_Req_I_COM_DEALER(){}
            // @AuraEnabled public String KUNNR        {get;set;} // ? Customer Number 1
            // @AuraEnabled public String NAME1_SOLDTO {get;set;} // ? Name 1
            // @AuraEnabled public String NAME1_VENDER {get;set;} // ? Name 1
            @AuraEnabled public String LIFNR        {get;set;} // ? Account Number of Vendor or Creditor
            @AuraEnabled public String ZDLRCOM_AMT  {get;set;} // ? Dealer Commission Amount => since v1.5
            @AuraEnabled public String KONDA        {get;set;} // ? Price group (customer)   => since v1.5
            @AuraEnabled public String WAERS        {get;set;} // ? Price group (customer)   => since v1.5
        }
    
        public class IF_ORDER_001_Req_T_ITEM {
            public IF_ORDER_001_Req_T_ITEM(){}

            @AuraEnabled public String POSNR {get;set;} // ? Item number of the SD document
            @AuraEnabled public String PARENT {get;set;} // ? Material Number
            @AuraEnabled public String MATNR {get;set;} // ? Material Number
            @AuraEnabled public String ARKTX {get;set;} // ? Short text for sales order item
            @AuraEnabled public String KWMENG {get;set;} // ? Cumulative Order Quantity in Sales Units
            @AuraEnabled public String REQ_DATE {get;set;} // ? Schedule line date
            @AuraEnabled public String VRKME {get;set;} // ? Sales unit
            @AuraEnabled public String NETPR {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String WERKS {get;set;} // ? Plant (Own or External)
            @AuraEnabled public String PSTYV {get;set;} // ? Sales document item category
            @AuraEnabled public String NOTE  {get;set;} // ? Note Long Txt
            @AuraEnabled public String ZZSQCOD {get;set;} // ? SQ Code
            @AuraEnabled public String ZZSQTITLE {get;set;} // ? SQ Title
            @AuraEnabled public String ZZDEALDT {get;set;} // ? Dealer's sales date
            // @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
            // @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
            // @AuraEnabled public String CHECK {get;set;} // ? Check Flag
            // @AuraEnabled public String EQUIP_CHECK {get;set;} // ? Equip Check Flag
            // @AuraEnabled public String MWST  {get;set;} // ? Net price
            
            // @AuraEnabled public String NETWR {get;set;} // ? Net Value in Document Currency
            // @AuraEnabled public String VTEXT {get;set;} // ? Description
            // @AuraEnabled public String MWSBP {get;set;} // ? Tax amount in document currency

            // @AuraEnabled public String INPUT_P {get;set;} // ? Latest scheduled start: Execution (date)
            // @AuraEnabled public String INPUT_A {get;set;} // ? Posting date
            // @AuraEnabled public String BUILT_P {get;set;} // ? Latest finish date of operation
    
            // @AuraEnabled public String BUILT_A {get;set;} // ? Posting date
            // @AuraEnabled public String TEST_P {get;set;} // ? Latest finish date of operation
            // @AuraEnabled public String TEST_A {get;set;} // ? Posting date
            // @AuraEnabled public String PAINT_P {get;set;} // ? Latest finish date of operation
            // @AuraEnabled public String PAINT_A {get;set;} // ? Posting date
    
            // @AuraEnabled public String RTS_P {get;set;} // ? Latest finish date of operation
            // @AuraEnabled public String RTS_A {get;set;} // ? Posting date
            // @AuraEnabled public String DECK_P {get;set;} // ? Latest finish date of operation
            // @AuraEnabled public String DECK_A {get;set;} // ? Posting date
            // @AuraEnabled public String EDATU {get;set;} // ? Schedule line date
        }
    
        public class IF_ORDER_001_Req_T_CONFIG { 
            public IF_ORDER_001_Req_T_CONFIG(){}

            @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
            @AuraEnabled public String ATNAM    {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATBEZ    {get;set;} // ? Characteristic description
            // @AuraEnabled public String ZSEQNO   {get;set;} // ? Sequence Number (3byte)
            // @AuraEnabled public String SHOW     {get;set;} // ? Single-Character Indicator
    
            // @AuraEnabled public String READONLY {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
    
        }
    
        public class IF_ORDER_001_Req_T_SEL_CONFIG {
            public IF_ORDER_001_Req_T_SEL_CONFIG(){}

            @AuraEnabled public String POSNR {get;set;} // ? Item number of the SD document
            @AuraEnabled public String MATNR {get;set;} // ? Material Number
            @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value
    
        }
    
        public class IF_ORDER_001_Req_T_PRICING { 
            public IF_ORDER_001_Req_T_PRICING(){}

            @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT   {get;set;} // ? Description
            @AuraEnabled public String KWERT   {get;set;} // ? Condition value
            @AuraEnabled public String WAERK   {get;set;} // ? SD Document Currency
    
            // @AuraEnabled public String VISIBLE {get;set;} // ? Visible
    
        }
    
        public class IF_ORDER_001_Req_T_PRICING_ADD {
            public IF_ORDER_001_Req_T_PRICING_ADD(){}

            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document Currency
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
           
            // @AuraEnabled public String ZISI_DISPLAY {get;set;} // ? Display
            // @AuraEnabled public String VISIBLE    {get;set;} // ? Visible
            // @AuraEnabled public String VISIBLE_01 {get;set;} // ?                                                             
    
    
        }
    
        public class IF_ORDER_001_Req_T_PRICING_RATE { 
            public IF_ORDER_001_Req_T_PRICING_RATE(){}
            
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String RATE       {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document Currency
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String NWAERK     {get;set;} // ? SD Document Currency
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
    
    
        }
    
        public class IF_ORDER_001_Req_T_WARRANTY_PARTS {
            public IF_ORDER_001_Req_T_WARRANTY_PARTS(){}

            @AuraEnabled public String ZZWAGRP  {get;set;} // ? Warrnanty Parts Group
            @AuraEnabled public String ZZWAGRPNM {get;set;} // ? Warranty Parts Descrption
            @AuraEnabled public String ZZWARRPER {get;set;} // ? Warranty Period
            @AuraEnabled public String ZZWARHRS {get;set;} // ? Warranty Hours
    
        }
    
        public class IF_ORDER_001_Req_T_ORDER_REASON {
            public IF_ORDER_001_Req_T_ORDER_REASON(){}

            @AuraEnabled public String VBELN {get;set;} // ? Sales Document
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
            @AuraEnabled public String SPART {get;set;} // ? Division
            @AuraEnabled public String ZFCODE {get;set;} // ? Order reason code
            @AuraEnabled public String ZFSEQ {get;set;} // ? Order reason seq
            @AuraEnabled public String ZFTEXT {get;set;} // ? Order reason text
            @AuraEnabled public String ZFLAG {get;set;} // ? 입력필드여부(X)
    
        }
    
        public class IF_ORDER_001_Req_T_ADD_DATA { 
            public IF_ORDER_001_Req_T_ADD_DATA(){}

            @AuraEnabled public String VBELN   {get;set;} // ? Sales Document
            @AuraEnabled public String ZFMAINP {get;set;} // ? 원청업체
            @AuraEnabled public String ZFLASTP {get;set;} // ? 최종수요업체
    
        }
    
        public class IF_ORDER_001_Req_T_FILE {
            public IF_ORDER_001_Req_T_FILE(){}

            @AuraEnabled public String INT_NO   {get;set;} // ? Natural Number
            @AuraEnabled public String CHECK    {get;set;} // ? Character Field Length 1
            @AuraEnabled public String DOCU_ITEM {get;set;} // ? Sales Document Item
            @AuraEnabled public String VISIBLE  {get;set;} // ? Character Field Length 1
            @AuraEnabled public String FILE_NAME {get;set;} // ? Text field length 200
            @AuraEnabled public String DESCRIPTION {get;set;} // ? Text field length 200
            @AuraEnabled public String FILE_DATA {get;set;} // ? Table analysis: For external table data up to length 1024
            @AuraEnabled public String FILE_NO  {get;set;} // ? Natural Number
            @AuraEnabled public String FILESIZE {get;set;} // ? Numeric field 12
    
        }
    
        public class IF_ORDER_001_Req_T_WARRANTY_PARTSBK { 
            public IF_ORDER_001_Req_T_WARRANTY_PARTSBK(){}

            @AuraEnabled public String CHECK {get;set;} // ? Select record Y/N
            @AuraEnabled public String TYPBZ {get;set;} // ? Manufacturer model number
            @AuraEnabled public String OBJCOD {get;set;} // ? Object Code
            @AuraEnabled public String OBJTXT {get;set;} // ? Text Field of Length 60
            @AuraEnabled public String MGANR {get;set;} // ? Master warranty number
    
    
        }
    
        public class IF_ORDER_001_Req_T_MULTICOND {
            public IF_ORDER_001_Req_T_MULTICOND(){}

            @AuraEnabled public String CHAK  {get;set;} // ? Control activate
            @AuraEnabled public String VARCOND {get;set;} // ? Variant condition
            @AuraEnabled public String KNUMH {get;set;} // ? Condition record number
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition amount or percentage)
            @AuraEnabled public String KWERT {get;set;} // ? Condition value
            @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
    
        }

    // ** RESPONSE
    /**
        */        
        public class IF_ORDER_001_Res { 
            public IF_ORDER_001_Res(){}
            @AuraEnabled public String O_VBELN {get;set;} // ? Sales Document
      
            @AuraEnabled public IF_ORDER_001_Res_O_RETURN               O_RETURN          {get;set;} 
            @AuraEnabled public IF_ORDER_001_Res_O_NET_VALUE            O_NET_VALUE       {get;set;}
            @AuraEnabled public List<IF_ORDER_001_Res_T_RETURN>         T_RETURN          {get;set;}
            @AuraEnabled public List<IF_ORDER_001_Res_T_COND_EX>        T_COND_EX         {get;set;}
            @AuraEnabled public List<IF_ORDER_001_Res_T_PRICING_RETURN> T_PRICING_RETURN  {get;set;}
          }
      
          public class IF_ORDER_001_Res_O_RETURN { 
            public IF_ORDER_001_Res_O_RETURN(){}

            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
          }
      
          public class IF_ORDER_001_Res_T_RETURN { 
            public IF_ORDER_001_Res_T_RETURN(){}
            @AuraEnabled public String TYPE   {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String ID     {get;set;} // ? Message Class
            @AuraEnabled public String IF_NUMBER {get;set;} // ? Message Number
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
            @AuraEnabled public String LOG_NO {get;set;} // ? Application log: log number
            @AuraEnabled public String LOG_MSG_NO {get;set;} // ? Application log: Internal message serial number
            @AuraEnabled public String MESSAGE_V1 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V2 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V3 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V4 {get;set;} // ? Message Variable
            @AuraEnabled public String PARAMETER {get;set;} // ? Parameter Name
            @AuraEnabled public String ROW    {get;set;} // ? Lines in parameter
            @AuraEnabled public String FIELD  {get;set;} // ? Field in parameter
            @AuraEnabled public String IF_SYSTEM {get;set;} // ? Logical system from which message originates
          }
                    
          // 2.0 v 부터 추가 
          public class IF_ORDER_001_Res_O_NET_VALUE{
            @AuraEnabled public String NETPR {get;set;} // ? Net price
            @AuraEnabled public String NETWR {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String MWST {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
            @AuraEnabled public String NETWR_CH {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String NETWR_CC06 {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String CB01_INFO1 {get;set;} // ? Add Info 1
            @AuraEnabled public String CB01_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
            @AuraEnabled public String CI06_INFO1 {get;set;} // ? Add Info 1
            @AuraEnabled public String CI06_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
            @AuraEnabled public String CC06_INFO1 {get;set;} // ? Add Info 1
            @AuraEnabled public String CC06_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
            @AuraEnabled public String LP_BM {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String LP_OP {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String LP_SUM {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String PROMO_PRC {get;set;} // ? Net Value in Document Currency
          }

          // 2.0 v 부터 추가 CURRENCY -> IF_CURRENCY
          public class IF_ORDER_001_Res_T_COND_EX{
            @AuraEnabled public String ITM_NUMBER {get;set;} // ? Condition item number
            @AuraEnabled public String COND_ST_NO {get;set;} // ? Step number
            @AuraEnabled public String COND_COUNT {get;set;} // ? Condition counter
            @AuraEnabled public String COND_TYPE {get;set;} // ? Condition type
            @AuraEnabled public String COND_VALUE {get;set;} // ? Condition rate
            @AuraEnabled public String IF_CURRENCY {get;set;} // ? Currency Key
            @AuraEnabled public String COND_UNIT {get;set;} // ? Condition unit
            @AuraEnabled public String COND_P_UNT {get;set;} // ? Condition pricing unit
            @AuraEnabled public String CURR_ISO {get;set;} // ? ISO code currency
            @AuraEnabled public String CD_UNT_ISO {get;set;} // ? Condition unit of measure in UoM
            @AuraEnabled public String REFOBJTYPE {get;set;} // ? Object Type
            @AuraEnabled public String REFOBJKEY {get;set;} // ? Object key
            @AuraEnabled public String REFLOGSYS {get;set;} // ? Logical system
            @AuraEnabled public String APPLICATIO {get;set;} // ? Application
            @AuraEnabled public String CONPRICDAT {get;set;} // ? Condition pricing date
            @AuraEnabled public String CALCTYPCON {get;set;} // ? Calculation type for condition
            @AuraEnabled public String CONBASEVAL {get;set;} // ? Condition base value
            @AuraEnabled public String CONEXCHRAT {get;set;} // ? Condition exchange rate for conversion to local currency
            @AuraEnabled public String NUMCONVERT {get;set;} // ? Numerator for converting condition units to base units
            @AuraEnabled public String DENOMINATO {get;set;} // ? Denominator for converting condition units to base units
            @AuraEnabled public String CONDTYPE {get;set;} // ? Condition category (examples: tax, freight, price, cost)
            @AuraEnabled public String STAT_CON {get;set;} // ? Condition is used for statistics
            @AuraEnabled public String SCALETYPE {get;set;} // ? Scale Type
            @AuraEnabled public String ACCRUALS {get;set;} // ? Condition is Relevant for Accrual  (e.g. Freight)
            @AuraEnabled public String CONINVOLST {get;set;} // ? Condition for invoice list
            @AuraEnabled public String CONDORIGIN {get;set;} // ? Origin of the condition
            @AuraEnabled public String GROUPCOND {get;set;} // ? Group condition
            @AuraEnabled public String COND_UPDAT {get;set;} // ? Condition update
            @AuraEnabled public String ACCESS_SEQ {get;set;} // ? Access sequence - Access number
            @AuraEnabled public String CONDCOUNT {get;set;} // ? Sequential number of the condition
            @AuraEnabled public String ROUNDOFFDI {get;set;} // ? Currency amount for BAPIS (with 9 decimal places)
            @AuraEnabled public String CONDVALUE {get;set;} // ? Condition value
            @AuraEnabled public String CURRENCY_2 {get;set;} // ? SD Document Currency
            @AuraEnabled public String CURR_ISO_2 {get;set;} // ? ISO code currency
            @AuraEnabled public String CONDCNTRL {get;set;} // ? Condition control
            @AuraEnabled public String CONDISACTI {get;set;} // ? Condition is inactive
            @AuraEnabled public String CONDCLASS {get;set;} // ? Condition class
            @AuraEnabled public String FACTBASVAL {get;set;} // ? Factor for condition base value
            @AuraEnabled public String SCALEBASIN {get;set;} // ? Scale basis indicator
            @AuraEnabled public String SCALBASVAL {get;set;} // ? Scale base value of the condition
            @AuraEnabled public String UNITMEASUR {get;set;} // ? Condition scale unit of measure
            @AuraEnabled public String ISO_UNIT {get;set;} // ? ISO code for unit of measurement
            @AuraEnabled public String CURRENCKEY {get;set;} // ? Scale currency
            @AuraEnabled public String CURRENISO {get;set;} // ? ISO code currency
            @AuraEnabled public String CONDINCOMP {get;set;} // ? Condition for inter-company billing
            @AuraEnabled public String CONDCONFIG {get;set;} // ? Condition for configuration
            @AuraEnabled public String CONDCHAMAN {get;set;} // ? Condition changed manually
            @AuraEnabled public String COND_NO {get;set;} // ? Condition record number
            @AuraEnabled public String TAX_CODE {get;set;} // ? Sales Tax Code
            @AuraEnabled public String VARCOND {get;set;} // ? Variant condition
            @AuraEnabled public String ACCOUNTKEY {get;set;} // ? Account key
            @AuraEnabled public String ACCOUNT_KE {get;set;} // ? Account key - accruals / provisions
            @AuraEnabled public String WT_WITHCD {get;set;} // ? Withholding tax code
            @AuraEnabled public String STRUCTCOND {get;set;} // ? Structure condition
            @AuraEnabled public String FACTCONBAS {get;set;} // ? Factor for condition basis (period)
            @AuraEnabled public String CONDCOINHD {get;set;} // ? Condition counter for (header conditions)
            @AuraEnabled public String VCTEXT {get;set;} // ? Description
            @AuraEnabled public String MATNR_AC {get;set;} // ? Material Number
            @AuraEnabled public String ZZSQCOD {get;set;} // ? SQ Code
          }

          // 2.0 v 부터 추가 
          public class IF_ORDER_001_Res_T_PRICING_RETURN{
            @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT {get;set;} // ? Description
            @AuraEnabled public String KWERT {get;set;} // ? Condition value
            @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
          }
      
// ** IF-ORDER-004				
/**
  */
  /**
         * Wrapper Name         : IF_ORDER_004
         * SFDC interface Id    : IF-ORDER-004
         * AS-IS RFC            : Z_SD_CHANGE_SALES_ORDER_ME	
         * New I/F              : ZCRM_SD_CHANGE_SALES_ORDER_ME
         * Description          : CRM에서 CPO 수정 후 ERP에 전송 
         * IF_NUMBER, IF_SYSTEM
  */    

    // ** REQUEST
    /**
        */     
        public class IF_ORDER_004_Req { 
          @AuraEnabled public String I_UNAME {get;set;} // ? User Name
          @AuraEnabled public String I_REF_ORDER {get;set;} // ? Sales Document
          @AuraEnabled public String I_GUBUN {get;set;} // ? 'C' = Create, 'U' = Change, 'D' = Delete
          @AuraEnabled public String I_ORG_VBELN {get;set;} // ? Sales Document
          @AuraEnabled public String I_ZINDUS {get;set;} // ? DI Machine Tool Industry Category 1
          @AuraEnabled public String I_ZINDUS2 {get;set;} // ? DI Machine Tool Industry Category 2
          @AuraEnabled public String I_STATUS {get;set;} // ? [SD] SalesOrder Status
          @AuraEnabled public String I_SUPPLY_DATE {get;set;} // ? Date
          @AuraEnabled public String I_LAND1 {get;set;} // ? Country Key
          @AuraEnabled public String I_EXPORT {get;set;} // ? Export or not : X means Export
          @AuraEnabled public String I_SPDC {get;set;} // ? DMT domestic Spedical D/C flag

          public IF_ORDER_004_Req() {
            this.I_USERINFO = new IF_ORDER_004_Req_I_USERINFO();
            this.I_HEAD = new IF_ORDER_004_Req_I_HEAD();
            this.I_GENERAL = new IF_ORDER_004_Req_I_GENERAL();
            this.I_PARTNER = new IF_ORDER_004_Req_I_PARTNER();
            this.I_COLLECTION = new IF_ORDER_004_Req_I_COLLECTION();
            this.I_WARRANT_OPT = new IF_ORDER_004_Req_I_WARRANT_OPT();
            this.I_NOTE = new IF_ORDER_004_Req_I_NOTE();
            this.I_NOTE2 = new IF_ORDER_004_Req_I_NOTE2();
            this.I_ZPDC = new IF_ORDER_004_Req_I_ZPDC();
            this.I_NOTE3 = new IF_ORDER_004_Req_I_NOTE3();
            this.I_NOTE4 = new IF_ORDER_004_Req_I_NOTE4();
            this.I_NOTE5 = new IF_ORDER_004_Req_I_NOTE5();
            this.I_NOTE_ZH27 = new IF_ORDER_004_Req_I_NOTE_ZH27();
            this.T_ITEM = new List<IF_ORDER_004_Req_T_ITEM>();
            this.T_CONFIG = new List<IF_ORDER_004_Req_T_CONFIG>();
            this.T_SEL_CONFIG = new List<IF_ORDER_004_Req_T_SEL_CONFIG>();
            this.T_PRICING = new List<IF_ORDER_004_Req_T_PRICING>();
            this.T_PRICING_RATE = new List<IF_ORDER_004_Req_T_PRICING_RATE>();
            this.T_PRICING_ADD = new List<IF_ORDER_004_Req_T_PRICING_ADD>();
            this.T_WARRANTY_PARTS = new List<IF_ORDER_004_Req_T_WARRANTY_PARTS>();
            this.T_ORDER_REASON = new List<IF_ORDER_004_Req_T_ORDER_REASON>();
            this.T_ADD_DATA = new List<IF_ORDER_004_Req_T_ADD_DATA>();
            this.T_CHANGE_REASON = new List<IF_ORDER_004_Req_T_CHANGE_REASON>();
            this.T_FILE = new List<IF_ORDER_004_Req_T_FILE>();
            this.T_WARRANTY_PARTSBK = new List<IF_ORDER_004_Req_T_WARRANTY_PARTSBK>();
        }
          @AuraEnabled public IF_ORDER_004_Req_I_USERINFO I_USERINFO {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_HEAD I_HEAD {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_GENERAL I_GENERAL {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_PARTNER I_PARTNER {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_COLLECTION I_COLLECTION {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_WARRANT_OPT I_WARRANT_OPT {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_NOTE I_NOTE {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_NOTE2 I_NOTE2 {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_ZPDC I_ZPDC {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_NOTE3 I_NOTE3 {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_NOTE4 I_NOTE4 {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_NOTE5 I_NOTE5 {get;set;} 
          @AuraEnabled public IF_ORDER_004_Req_I_NOTE_ZH27 I_NOTE_ZH27 {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_ITEM> T_ITEM {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_CONFIG> T_CONFIG {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_SEL_CONFIG> T_SEL_CONFIG {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_PRICING> T_PRICING {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_PRICING_RATE> T_PRICING_RATE {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_PRICING_ADD> T_PRICING_ADD {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_WARRANTY_PARTS> T_WARRANTY_PARTS {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_ORDER_REASON> T_ORDER_REASON {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_ADD_DATA> T_ADD_DATA {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_CHANGE_REASON> T_CHANGE_REASON {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_FILE> T_FILE {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Req_T_WARRANTY_PARTSBK> T_WARRANTY_PARTSBK {get;set;} 

        }

        public class IF_ORDER_004_Req_I_USERINFO { 
          public IF_ORDER_004_Req_I_USERINFO(){}
          @AuraEnabled public String BNAME {get;set;} // ? S/F CRM User ID
          @AuraEnabled public String RNAME {get;set;} // ? Log테이블 저장을 위한 12자리 ID
          @AuraEnabled public String HIER  {get;set;} // ? [SS] User Hierrchy (Portal)
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String LIFNR {get;set;} // ? Account Number of Vendor or Creditor
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String WERKS {get;set;} // ? Plant

        }


        public class IF_ORDER_004_Req_I_HEAD {
          public IF_ORDER_004_Req_I_HEAD(){}

          @AuraEnabled public String AUART {get;set;} // ? Sales Document Type
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNAG {get;set;} // ? Customer Number 1
          @AuraEnabled public String BEZEI {get;set;} // ? Description
          @AuraEnabled public String VKBUR {get;set;} // ? Sales Office

          // @AuraEnabled public String VKORG_T {get;set;} // ? Name
          // @AuraEnabled public String VTWEG_T {get;set;} // ? Name
          // @AuraEnabled public String SPART_T {get;set;} // ? Name

          // @AuraEnabled public String KUNNR_NAME {get;set;} // ? Name 1
          // @AuraEnabled public String KUNNR_STREET {get;set;} // ? House number and street
          // @AuraEnabled public String KUNAG_NAME {get;set;} // ? Name 1
          // @AuraEnabled public String KUNAG_STREET {get;set;} // ? House number and street

          // @AuraEnabled public String VKBUR_TX {get;set;} // ? Name of the controlling area
          // @AuraEnabled public String VSBED {get;set;} // ? Shipping Conditions
          // @AuraEnabled public String IHREZ {get;set;} // ? Your Reference
          // @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
          // @AuraEnabled public String AUDAT {get;set;} // ? Document Date (Date Received/Sent)

          // @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
          // @AuraEnabled public String BUKRS {get;set;} // ? Company Code
      }

        public class IF_ORDER_004_Req_I_GENERAL {
          public IF_ORDER_004_Req_I_GENERAL(){}

          @AuraEnabled public String BSTNK    {get;set;} // ? Customer purchase order number
          @AuraEnabled public String VDATU    {get;set;} // ? Requested delivery date
          @AuraEnabled public String INCO1    {get;set;} // ? Incoterms (Part 1)
          @AuraEnabled public String INCO2    {get;set;} // ? Incoterms (Part 2)
          @AuraEnabled public String AUGRU    {get;set;} // ? Order reason (reason for the business transaction)
          @AuraEnabled public String ABRVW    {get;set;} // ? Usage Indicator
          @AuraEnabled public String BZIRK    {get;set;} // ? Sales district
          @AuraEnabled public String WAERK    {get;set;} // ? SD Document Currency
          @AuraEnabled public String WERK     {get;set;} // ? Delivering Plant (Own or External)
          @AuraEnabled public String PLTYP    {get;set;} // ? Price list type
          @AuraEnabled public String ZZSQNO   {get;set;} // ? Seqeunce Number
          @AuraEnabled public String ZTERM    {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String ZZREP_VKBUR {get;set;} // ? Responsible of office
          @AuraEnabled public String ZZSQITEM {get;set;} // ? SQ Item
          @AuraEnabled public String ZPLAN_DT {get;set;} // ? Date          
          // @AuraEnabled public String BZIRK_TX {get;set;} // ? Sales district Txt

          // @AuraEnabled public String WAERK_TX {get;set;} // ? Currency Txt
          // @AuraEnabled public String AUGRU_TX {get;set;} // ? Description
          // @AuraEnabled public String REP_NAME {get;set;} // ? Name of Representative
          // @AuraEnabled public String EXPORT_DATE {get;set;} // ? Date

          // @AuraEnabled public String ZZTECHARG {get;set;} // ? Tech Agreemnet Number
          // @AuraEnabled public String ZSDFUNC  {get;set;} // ? Sales Function
          // @AuraEnabled public String ZSDFUNC_TX {get;set;} // ? Function Txt

          // @AuraEnabled public String ZZREP_VKBUR_TX {get;set;} // ? Text (20 Characters)


      }

        public class IF_ORDER_004_Req_I_PARTNER { 
          public IF_ORDER_004_Req_I_PARTNER(){}

          @AuraEnabled public String KUNNR1      {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR2      {get;set;} // ? Customer Number 1
          @AuraEnabled public String KVGRP1      {get;set;} // ? Customer group 1
          @AuraEnabled public String KVGRP2      {get;set;} // ? Customer group 2
          @AuraEnabled public String KVGRP3      {get;set;} // ? Customer group 3
          @AuraEnabled public String KUNNR3      {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR4      {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR2_TX   {get;set;} // ? CUSTOMER NAME
          @AuraEnabled public String KUNNR5      {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR6      {get;set;} // ? Account Number of Vendor or Creditor
          @AuraEnabled public String KUNNR6_TX   {get;set;} // ? CUSTOMER NAME
          @AuraEnabled public String KUNNR4_TX   {get;set;} // ? CUSTOMER NAME
          @AuraEnabled public String KUNNR3_TX   {get;set;} // ? CUSTOMER NAME
          @AuraEnabled public String KUNNR5_TX   {get;set;} // ? CUSTOMER NAME
          @AuraEnabled public String KUNNR1_TX   {get;set;} // ? CUSTOMER NAME
          @AuraEnabled public String KUNNR_ZP    {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR_ZP_TX {get;set;} // ? CUSTOMER NAME

      }

        public class IF_ORDER_004_Req_I_COLLECTION { 
          public IF_ORDER_004_Req_I_COLLECTION(){}

          @AuraEnabled public String ZZUSEDCAR_NO {get;set;} // ? Used Car Management No.
          @AuraEnabled public String ZZPERM_NO {get;set;} // ? Military Goods Permission No
          @AuraEnabled public String ZZCAPITAL_NO {get;set;} // ? Capital No.
          @AuraEnabled public String MORT_CODE1 {get;set;} // ? Mortgage Code
          @AuraEnabled public String MORT_DATE1 {get;set;} // ? Mortgage Date
          @AuraEnabled public String MORT_CODE2 {get;set;} // ? Mortgage Code
          @AuraEnabled public String MORT_DATE2 {get;set;} // ? Mortgage Date
          @AuraEnabled public String MORT_CODE3 {get;set;} // ? Mortgage Code
          @AuraEnabled public String MORT_DATE3 {get;set;} // ? Mortgage Date
          @AuraEnabled public String MORT_CODE4 {get;set;} // ? Mortgage Code
          @AuraEnabled public String MORT_DATE4 {get;set;} // ? Mortgage Date
          @AuraEnabled public String MORT_CODE5 {get;set;} // ? Mortgage Code
          @AuraEnabled public String MORT_DATE5 {get;set;} // ? Mortgage Date
          @AuraEnabled public String MORT_CODE6 {get;set;} // ? Mortgage Code
          @AuraEnabled public String MORT_DATE6 {get;set;} // ? Mortgage Date
          @AuraEnabled public String ZZWARRDAT {get;set;} // ? Warranty Valid on
          @AuraEnabled public String BASE_DATE {get;set;} // ? Incoming Plan Base Date
          @AuraEnabled public String ZZINCOM_NO {get;set;} // ? Incoming Plan NO
          @AuraEnabled public String NETWR     {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String NETWR1    {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WAERK     {get;set;} // ? SD Document Currency
          @AuraEnabled public String INCOM_CODE {get;set;} // ? Incoming Plan Code
          @AuraEnabled public String ZTERM     {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String ZZPERIOD  {get;set;} // ? Deferment Period
          @AuraEnabled public String ZZRAT_REDUCE {get;set;} // ? Interest rate reduce
          @AuraEnabled public String ZZDRAFTNO {get;set;} // ? Draft Number

          // @AuraEnabled public String ZZWARRPER {get;set;} // ? Warranty Period
          // @AuraEnabled public String ZZPERUNIT {get;set;} // ? Warranty Indicator
          // @AuraEnabled public String ZZWARHRS  {get;set;} // ? Warranty Hours

          // @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date

          // @AuraEnabled public String EST_DAT   {get;set;} // ? Est.Incoming Date
          // @AuraEnabled public String EST_AMT   {get;set;} // ? Est.Incoming AMT
          // @AuraEnabled public String FA_CODE   {get;set;} // ? Financial Agency Code

          // @AuraEnabled public String DOWN_REQ_NO {get;set;} // ? Downpayment Req.NO
          // @AuraEnabled public String MODIFY_NETWR {get;set;} // ? Net Value in Document Currency

          // @AuraEnabled public String RESIDUAL  {get;set;} // ? Est.Incoming AMT


      }

        public class IF_ORDER_004_Req_I_WARRANT_OPT { 
          public IF_ORDER_004_Req_I_WARRANT_OPT(){}

          @AuraEnabled public String ZZWARRPER    {get;set;} // ? Warranty Period
          @AuraEnabled public String ZZWARHRS     {get;set;} // ? Warranty Hours
          @AuraEnabled public String ZZCOVERAGE   {get;set;} // ? Warranty - Coverage
          @AuraEnabled public String ZZCOVERAGE_B {get;set;} // ? Warranty - Coverage (Added)          
          // @AuraEnabled public String ZZPR_WAR     {get;set;} // ? Pricing Factor(Warranty)
          // @AuraEnabled public String CONCATE      {get;set;} // ? Concate Txt


      }

        public class IF_ORDER_004_Req_I_NOTE { 
          public IF_ORDER_004_Req_I_NOTE(){}

          @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
          // @AuraEnabled public String USAGE {get;set;} // ? Char255

      }

        public class IF_ORDER_004_Req_I_NOTE2 {
          public IF_ORDER_004_Req_I_NOTE2(){}
          
          @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
          // @AuraEnabled public String USAGE {get;set;} // ? Char255

      }

        public class IF_ORDER_004_Req_I_ZPDC {
          public IF_ORDER_004_Req_I_ZPDC(){}

          @AuraEnabled public String EMP_NO      {get;set;} // ? Employee ID
          @AuraEnabled public String REASON_CODE {get;set;} // ? Promotion discount reason code for ZPDC

      }

        public class IF_ORDER_004_Req_I_NOTE3 {
          public IF_ORDER_004_Req_I_NOTE3(){}

          @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
          // @AuraEnabled public String USAGE {get;set;} // ? Char255

      }

        public class IF_ORDER_004_Req_I_NOTE4 {
          public IF_ORDER_004_Req_I_NOTE4(){}

          @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
          // @AuraEnabled public String USAGE {get;set;} // ? Char255

      }

        public class IF_ORDER_004_Req_I_NOTE5 { 
          public IF_ORDER_004_Req_I_NOTE5(){}

          @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
          // @AuraEnabled public String USAGE {get;set;} // ? Char255

      }

        public class IF_ORDER_004_Req_I_NOTE_ZH27 {
          public IF_ORDER_004_Req_I_NOTE_ZH27(){}

          @AuraEnabled public String HEAD  {get;set;} // ? Character 1024
          // @AuraEnabled public String USAGE {get;set;} // ? Char255

      }

        public class IF_ORDER_004_Req_T_ITEM {
          public IF_ORDER_004_Req_T_ITEM(){}

          @AuraEnabled public String POSNR {get;set;} // ? Item number of the SD document
          @AuraEnabled public String MATNR {get;set;} // ? Material Number
          @AuraEnabled public String ARKTX {get;set;} // ? Short text for sales order item
          @AuraEnabled public String KWMENG {get;set;} // ? Cumulative Order Quantity in Sales Units
          @AuraEnabled public String REQ_DATE {get;set;} // ? Schedule line date
          @AuraEnabled public String VRKME {get;set;} // ? Sales unit
          @AuraEnabled public String NETPR {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
          @AuraEnabled public String PSTYV {get;set;} // ? Sales document item category
          @AuraEnabled public String ZZSQCOD {get;set;} // ? SQ Code
          @AuraEnabled public String ZZSQTITLE {get;set;} // ? SQ Title
          @AuraEnabled public String NOTE  {get;set;} // ? Note Long Txt
          @AuraEnabled public String WERKS {get;set;} // ? Plant (Own or External)
          // @AuraEnabled public String CHECK {get;set;} // ? Check Flag
          // @AuraEnabled public String EQUIP_CHECK {get;set;} // ? Equip Check Flag
          // @AuraEnabled public String MWST  {get;set;} // ? Net price
          // @AuraEnabled public String NETWR {get;set;} // ? Net Value in Document Currency
          // @AuraEnabled public String VTEXT {get;set;} // ? Description
          // @AuraEnabled public String MWSBP {get;set;} // ? Tax amount in document currency
          // @AuraEnabled public String PARENT {get;set;} // ? Material Number
          // @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)          
          // @AuraEnabled public String ZZDEALDT {get;set;} // ? Dealer's sales date
          // @AuraEnabled public String INPUT_P {get;set;} // ? Latest scheduled start: Execution (date)
          // @AuraEnabled public String INPUT_A {get;set;} // ? Posting date
          // @AuraEnabled public String BUILT_P {get;set;} // ? Latest finish date of operation

          // @AuraEnabled public String BUILT_A {get;set;} // ? Posting date
          // @AuraEnabled public String TEST_P {get;set;} // ? Latest finish date of operation
          // @AuraEnabled public String TEST_A {get;set;} // ? Posting date
          // @AuraEnabled public String PAINT_P {get;set;} // ? Latest finish date of operation
          // @AuraEnabled public String PAINT_A {get;set;} // ? Posting date

          // @AuraEnabled public String RTS_P {get;set;} // ? Latest finish date of operation
          // @AuraEnabled public String RTS_A {get;set;} // ? Posting date
          // @AuraEnabled public String DECK_P {get;set;} // ? Latest finish date of operation
          // @AuraEnabled public String DECK_A {get;set;} // ? Posting date
          // @AuraEnabled public String EDATU {get;set;} // ? Schedule line date

      }

        public class IF_ORDER_004_Req_T_CONFIG {
          public IF_ORDER_004_Req_T_CONFIG(){}
          public IF_ORDER_004_Req_T_CONFIG(String POSNR,String ATNAM,String ATBEZ){
              this.POSNR = POSNR;
              this.ATNAM = ATNAM;
              this.ATBEZ = ATBEZ;
          }

          @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
          @AuraEnabled public String ATNAM    {get;set;} // ? Characteristic Name
          @AuraEnabled public String ATBEZ    {get;set;} // ? Characteristic description
          // @AuraEnabled public String ZSEQNO   {get;set;} // ? Sequence Number (3byte)
          // @AuraEnabled public String SHOW     {get;set;} // ? Single-Character Indicator

          // @AuraEnabled public String READONLY {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False

      }

        public class IF_ORDER_004_Req_T_SEL_CONFIG {
          public IF_ORDER_004_Req_T_SEL_CONFIG(){}
          public IF_ORDER_004_Req_T_SEL_CONFIG(String POSNR,String ATNAM, String ATWRT){
            this.POSNR = POSNR;
            this.ATNAM = ATNAM;
            this.ATWRT = ATWRT;
          }

          @AuraEnabled public String POSNR {get;set;} // ? Item number of the SD document
          @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
          @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value          
          // @AuraEnabled public String MATNR {get;set;} // ? Material Number


      }

        public class IF_ORDER_004_Req_T_PRICING {
          public IF_ORDER_004_Req_T_PRICING(){}

          @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
          @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
          @AuraEnabled public String VTEXT   {get;set;} // ? Description
          @AuraEnabled public String KWERT   {get;set;} // ? Condition value
          @AuraEnabled public String WAERK   {get;set;} // ? SD Document Currency

          // @AuraEnabled public String VISIBLE {get;set;} // ? Visible

      }

        public class IF_ORDER_004_Req_T_PRICING_RATE {
          public IF_ORDER_004_Req_T_PRICING_RATE(){}

          @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
          @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
          @AuraEnabled public String VTEXT      {get;set;} // ? Description
          @AuraEnabled public String RATE       {get;set;} // ? Condition value
          @AuraEnabled public String WAERK      {get;set;} // ? SD Document Currency
          @AuraEnabled public String STUNR      {get;set;} // ? Step number
          @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
          @AuraEnabled public String KWERT      {get;set;} // ? Condition value
          @AuraEnabled public String NWAERK     {get;set;} // ? SD Document Currency
          @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator


      }

        public class IF_ORDER_004_Req_T_PRICING_ADD {
          public IF_ORDER_004_Req_T_PRICING_ADD(){}

          @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
          @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
          @AuraEnabled public String VTEXT      {get;set;} // ? Description
          @AuraEnabled public String KWERT      {get;set;} // ? Condition value
          @AuraEnabled public String WAERK      {get;set;} // ? SD Document Currency
          @AuraEnabled public String STUNR      {get;set;} // ? Step number
          @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
          @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator

          // @AuraEnabled public String ZISI_DISPLAY {get;set;} // ? Display

          // @AuraEnabled public String VISIBLE    {get;set;} // ? Visible
          // @AuraEnabled public String VISIBLE_01 {get;set;} // ?                                                             


      }

        public class IF_ORDER_004_Req_T_WARRANTY_PARTS {
          public IF_ORDER_004_Req_T_WARRANTY_PARTS(){}

          @AuraEnabled public String ZZWAGRP  {get;set;} // ? Warrnanty Parts Group
          @AuraEnabled public String ZZWAGRPNM {get;set;} // ? Warranty Parts Descrption
          @AuraEnabled public String ZZWARRPER {get;set;} // ? Warranty Period
          @AuraEnabled public String ZZWARHRS {get;set;} // ? Warranty Hours

      }

        public class IF_ORDER_004_Req_T_ORDER_REASON {
          public IF_ORDER_004_Req_T_ORDER_REASON(){}
          public IF_ORDER_004_Req_T_ORDER_REASON(String ZFCODE, String ZFSEQ){
            this.ZFCODE = ZFCODE;
            this.ZFSEQ  = ZFSEQ;
          }

          @AuraEnabled public String VBELN {get;set;} // ? Sales Document
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String ZFCODE {get;set;} // ? Order reason code
          @AuraEnabled public String ZFSEQ {get;set;} // ? Order reason seq
          @AuraEnabled public String ZFTEXT {get;set;} // ? Order reason text
          @AuraEnabled public String ZFLAG {get;set;} // ? 입력필드여부(X)

      }

        public class IF_ORDER_004_Req_T_ADD_DATA {
          public IF_ORDER_004_Req_T_ADD_DATA(){}
          public IF_ORDER_004_Req_T_ADD_DATA(String ZFMAINP, String ZFLASTP){
            this.ZFMAINP = ZFMAINP;
            this.ZFLASTP = ZFLASTP;
          }

          @AuraEnabled public String VBELN   {get;set;} // ? Sales Document
          @AuraEnabled public String ZFMAINP {get;set;} // ? 원청업체
          @AuraEnabled public String ZFLASTP {get;set;} // ? 최종수요업체

      }

        public class IF_ORDER_004_Req_T_CHANGE_REASON {
          public IF_ORDER_004_Req_T_CHANGE_REASON(){}

          @AuraEnabled public String TDFORMAT {get;set;} // ? Tag column
          @AuraEnabled public String TDLINE {get;set;} // ? Text Line

      }

        public class IF_ORDER_004_Req_T_FILE { 
          public IF_ORDER_004_Req_T_FILE(){}

          @AuraEnabled public String INT_NO   {get;set;} // ? Natural Number
          @AuraEnabled public String CHECK    {get;set;} // ? Character Field Length 1
          @AuraEnabled public String DOCU_ITEM {get;set;} // ? Sales Document Item
          @AuraEnabled public String VISIBLE  {get;set;} // ? Character Field Length 1
          @AuraEnabled public String FILE_NAME {get;set;} // ? Text field length 200
          @AuraEnabled public String DESCRIPTION {get;set;} // ? Text field length 200
          @AuraEnabled public String FILE_DATA {get;set;} // ? Table analysis: For external table data up to length 1024
          @AuraEnabled public String FILE_NO  {get;set;} // ? Natural Number
          @AuraEnabled public String FILESIZE {get;set;} // ? Numeric field 12

      }

        public class IF_ORDER_004_Req_T_WARRANTY_PARTSBK {
          public IF_ORDER_004_Req_T_WARRANTY_PARTSBK(){}

          @AuraEnabled public String CHECK {get;set;} // ? Select record Y/N
          @AuraEnabled public String TYPBZ {get;set;} // ? Manufacturer model number
          @AuraEnabled public String OBJCOD {get;set;} // ? Object Code
          @AuraEnabled public String OBJTXT {get;set;} // ? Text Field of Length 60
          @AuraEnabled public String MGANR {get;set;} // ? Master warranty number


      }

    // ** RESPONSE
    /**
        */  
        public class IF_ORDER_004_Res { 
          public IF_ORDER_004_Res(){
            this.O_RETURN = new IF_ORDER_004_Res_O_RETURN();
            this.T_RETURN = new List<IF_ORDER_004_Res_T_RETURN>(); 
          }

          @AuraEnabled public String O_VBELN {get;set;} // ? Sales Document
          @AuraEnabled public IF_ORDER_004_Res_O_RETURN       O_RETURN {get;set;} 
          @AuraEnabled public List<IF_ORDER_004_Res_T_RETURN> T_RETURN {get;set;} 

          }

        public class IF_ORDER_004_Res_O_RETURN {
          public IF_ORDER_004_Res_O_RETURN(){} 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text

        }

        public class IF_ORDER_004_Res_T_RETURN {
          public IF_ORDER_004_Res_T_RETURN(){} 

          @AuraEnabled public String TYPE   {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String ID     {get;set;} // ? Message Class
          @AuraEnabled public String IF_NUMBER {get;set;} // ? Message Number
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
          @AuraEnabled public String LOG_NO {get;set;} // ? Application log: log number
          @AuraEnabled public String LOG_MSG_NO {get;set;} // ? Application log: Internal message serial number
          @AuraEnabled public String MESSAGE_V1 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V2 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V3 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V4 {get;set;} // ? Message Variable
          @AuraEnabled public String PARAMETER {get;set;} // ? Parameter Name
          @AuraEnabled public String ROW    {get;set;} // ? Lines in parameter
          @AuraEnabled public String FIELD  {get;set;} // ? Field in parameter
          @AuraEnabled public String IF_SYSTEM {get;set;} // ? Logical system from which message originates

        }

// ** IF-ORDER-003				
/**
  */
  /**
         * Wrapper Name         : IF_ORDER_003
         * SFDC interface Id    : IF-ORDER-003
         * AS-IS RFC            : Z_SD_SALES_NOTICE_MACHINE	
         * New I/F              : ZCRM_SD_SALES_NOTICE_MACHINE
         * Description          : 수주통지서 항목 I/F 
  */    
    // ** REQUEST
    /**
        */             
        public class IF_ORDER_003_Req { 
          @AuraEnabled public String I_VBELN   {get;set;}         // ? Sales Document
    
          public IF_ORDER_003_Req(){}
        }
  // ** RESPONSE
  /**
      */            
        public class IF_ORDER_003_Res { 
          public IF_ORDER_003_Res(){}

          @AuraEnabled public IF_ORDER_003_Res_O_RETURN        O_RETURN  {get;set;} 
          @AuraEnabled public IF_ORDER_003_Res_OS_TITLE        OS_TITLE  {get;set;} 
          @AuraEnabled public IF_ORDER_003_Res_OS_HEADER       OS_HEADER {get;set;} 

          @AuraEnabled public List<IF_ORDER_003_Res_OT_DATA>   OT_DATA   {get;set;} 
          @AuraEnabled public List<IF_ORDER_003_Res_OT_INCOM>  OT_INCOM  {get;set;} 
          @AuraEnabled public List<IF_ORDER_003_Res_OT_INCOMH> OT_INCOMH {get;set;} 
          @AuraEnabled public List<IF_ORDER_003_Res_OT_TEXT>   OT_TEXT   {get;set;} 
          @AuraEnabled public List<IF_ORDER_003_Res_OT_TEXT02> OT_TEXT02 {get;set;} 
        }
        public class IF_ORDER_003_Res_O_RETURN { 
          public IF_ORDER_003_Res_O_RETURN(){}

          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }
        public class IF_ORDER_003_Res_OS_TITLE{
          public IF_ORDER_003_Res_OS_TITLE(){}

          @AuraEnabled public String TEXT_01  {get;set;}
          @AuraEnabled public String TEXT_02  {get;set;}
          @AuraEnabled public String TEXT_03  {get;set;}
          @AuraEnabled public String TEXT_04  {get;set;}
          @AuraEnabled public String TEXT_05  {get;set;}
          @AuraEnabled public String TEXT_06  {get;set;}
          @AuraEnabled public String TEXT_07  {get;set;}
          @AuraEnabled public String TEXT_08  {get;set;}
          @AuraEnabled public String TEXT_09  {get;set;}
          @AuraEnabled public String TEXT_10  {get;set;}
          @AuraEnabled public String TEXT_11  {get;set;}
          @AuraEnabled public String TEXT_12  {get;set;}
          @AuraEnabled public String TEXT_13  {get;set;}
          @AuraEnabled public String TEXT_14  {get;set;}
          @AuraEnabled public String TEXT_15  {get;set;}
          @AuraEnabled public String TEXT_16  {get;set;}
          @AuraEnabled public String TEXT_17  {get;set;}
          @AuraEnabled public String TEXT_18  {get;set;}
          @AuraEnabled public String TEXT_19  {get;set;}
          @AuraEnabled public String TEXT_20  {get;set;}
          @AuraEnabled public String TEXT_21  {get;set;}
          @AuraEnabled public String TEXT_22  {get;set;}
          @AuraEnabled public String TEXT_23  {get;set;}
          @AuraEnabled public String TEXT_24  {get;set;}
          @AuraEnabled public String TEXT_25  {get;set;}
          @AuraEnabled public String TEXT_26  {get;set;}
          @AuraEnabled public String TEXT_27  {get;set;}
          @AuraEnabled public String TEXT_28  {get;set;}
          @AuraEnabled public String TEXT_29  {get;set;}
          @AuraEnabled public String TEXT_30  {get;set;}
          @AuraEnabled public String TEXT_31  {get;set;}
          @AuraEnabled public String TEXT_32  {get;set;}
          @AuraEnabled public String TEXT_33  {get;set;}
          @AuraEnabled public String TEXT_34  {get;set;}
          @AuraEnabled public String TEXT_35  {get;set;}
          @AuraEnabled public String TEXT_36  {get;set;}
          @AuraEnabled public String TEXT_37  {get;set;}
          @AuraEnabled public String TEXT_38  {get;set;}
          @AuraEnabled public String TEXT_39  {get;set;}
          @AuraEnabled public String TEXT_40  {get;set;}
          @AuraEnabled public String TEXT_41  {get;set;}
          @AuraEnabled public String TEXT_42  {get;set;}
          @AuraEnabled public String TEXT_43  {get;set;}
          @AuraEnabled public String TEXT_44  {get;set;}
          @AuraEnabled public String TEXT_45  {get;set;}
          @AuraEnabled public String TEXT_46  {get;set;}
          @AuraEnabled public String TEXT_47  {get;set;}
          @AuraEnabled public String TEXT_48  {get;set;}
          @AuraEnabled public String TEXT_49  {get;set;}
          @AuraEnabled public String TEXT_50  {get;set;}
          @AuraEnabled public String TEXT_51  {get;set;}
          @AuraEnabled public String TEXT_52  {get;set;}
          @AuraEnabled public String TEXT_53  {get;set;}
          @AuraEnabled public String TEXT_54  {get;set;}
          @AuraEnabled public String TEXT_55  {get;set;}
          @AuraEnabled public String TEXT_56  {get;set;}
          @AuraEnabled public String TEXT_57  {get;set;}
          @AuraEnabled public String TEXT_58  {get;set;}
        }
        public class IF_ORDER_003_Res_OS_HEADER{
          public IF_ORDER_003_Res_OS_HEADER(){}

          @AuraEnabled public String ZZSTATUS_TXT {get;set;}
          @AuraEnabled public String APP_DATE {get;set;}
          @AuraEnabled public String PS_POSID {get;set;}
          @AuraEnabled public String ERNAM_TXT  {get;set;}
          @AuraEnabled public String SERNR  {get;set;}
          @AuraEnabled public String VBELN  {get;set;}
          @AuraEnabled public String PRT_DATE {get;set;}
          @AuraEnabled public String SOLD_TO  {get;set;}
          @AuraEnabled public String SOLD_ORT01 {get;set;}
          @AuraEnabled public String SOLD_CAP {get;set;}
          @AuraEnabled public String SATNR  {get;set;}
          @AuraEnabled public String ERDAT  {get;set;}
          @AuraEnabled public String AEDAT  {get;set;}
          @AuraEnabled public String VDATU  {get;set;}
          @AuraEnabled public String WAERK  {get;set;}
          @AuraEnabled public String NETWR  {get;set;}
          @AuraEnabled public String PAYMENT  {get;set;}
          @AuraEnabled public String INCOTERMS  {get;set;}
          @AuraEnabled public String BSTNK  {get;set;}
          @AuraEnabled public String SHIP_TO  {get;set;}
          @AuraEnabled public String SHIP_ORT01 {get;set;}
          @AuraEnabled public String SHIP_CAP {get;set;}
          @AuraEnabled public String AUDAT  {get;set;}
          @AuraEnabled public String TEXT_1 {get;set;}
          @AuraEnabled public String TEXT_2 {get;set;}
          @AuraEnabled public String TOT_CNT  {get;set;}
          @AuraEnabled public String VKBUR_T  {get;set;}
          @AuraEnabled public String BSTKD  {get;set;}
          @AuraEnabled public String MORT_T {get;set;}
          @AuraEnabled public String ZZCOVERAGE {get;set;}
          @AuraEnabled public String ZZCOVERAGE_B {get;set;}
          @AuraEnabled public String ZZDRAFTNO  {get;set;}
          @AuraEnabled public String ZZCAPITAL_NO {get;set;}
          @AuraEnabled public String AUGRU_T  {get;set;}
          @AuraEnabled public String CONFEE {get;set;}
          @AuraEnabled public String OTHFEE {get;set;}
          @AuraEnabled public String SUMFEE {get;set;}
          @AuraEnabled public String BODYDC {get;set;}
          @AuraEnabled public String BODYRTE  {get;set;}
          @AuraEnabled public String OTHDC  {get;set;}
          @AuraEnabled public String OTHRTE {get;set;}
          @AuraEnabled public String INTDC  {get;set;}
          @AuraEnabled public String INTRTE {get;set;}
          @AuraEnabled public String SUMDC  {get;set;}
          @AuraEnabled public String SUMRTE {get;set;}
          @AuraEnabled public String STANDARD {get;set;}
          @AuraEnabled public String TOTALAMT {get;set;}
          @AuraEnabled public String BODYAMT  {get;set;}
          @AuraEnabled public String OPTAMT {get;set;}
          @AuraEnabled public String ITMAMT {get;set;}
          @AuraEnabled public String TOTALAMT_UNIT  {get;set;}
          @AuraEnabled public String BODYAMT_UNIT {get;set;}
          @AuraEnabled public String OPTAMT_UNIT  {get;set;}
          @AuraEnabled public String ITMAMT_UNIT  {get;set;}
          @AuraEnabled public String TOTALAMT_NET {get;set;}
          @AuraEnabled public String BODYAMT_NET  {get;set;}
          @AuraEnabled public String OPTAMT_NET {get;set;}
          @AuraEnabled public String ITMAMT_NET {get;set;}
          @AuraEnabled public String ZZPR_WAR_TEXT  {get;set;}
          @AuraEnabled public String PSO_NO {get;set;}
          @AuraEnabled public String KVGR1_T  {get;set;}
          @AuraEnabled public String KVGR23_T {get;set;}
        }
        public class IF_ORDER_003_Res_OT_DATA{
          public IF_ORDER_003_Res_OT_DATA(){}

          @AuraEnabled public String SEQ    {get;set;}
          @AuraEnabled public String SEQ_1  {get;set;}
          @AuraEnabled public String MAKTX  {get;set;}
          @AuraEnabled public String QTY    {get;set;}
          @AuraEnabled public String PRICE  {get;set;}
          @AuraEnabled public String AMOUNT {get;set;}
          @AuraEnabled public String TEXT   {get;set;}
          @AuraEnabled public String ATWTB  {get;set;}
        }
        public class IF_ORDER_003_Res_OT_INCOM{
          public IF_ORDER_003_Res_OT_INCOM(){}

          @AuraEnabled public String ZZINCOM_NO {get;set;}
          @AuraEnabled public String ZZINCOM_VER  {get;set;}
          @AuraEnabled public String INCOM_CODE {get;set;}
          @AuraEnabled public String SERIAL_NO  {get;set;}
          @AuraEnabled public String ZTERM  {get;set;}
          @AuraEnabled public String ZZTERM {get;set;}
          @AuraEnabled public String FA_CODE  {get;set;}
          @AuraEnabled public String EST_DAT  {get;set;}
          @AuraEnabled public String EST_AMT  {get;set;}
          @AuraEnabled public String PRI_AMT  {get;set;}
          @AuraEnabled public String NOTAX_INT_AMT  {get;set;}
          @AuraEnabled public String DOWN_REQ_NO  {get;set;}
          @AuraEnabled public String ZRESCHE  {get;set;}
          @AuraEnabled public String WAERK  {get;set;}
          @AuraEnabled public String BASE_DATE  {get;set;}
          @AuraEnabled public String ZBD1T  {get;set;}
          @AuraEnabled public String FKDAT  {get;set;}
          @AuraEnabled public String ZPARTIAL_BILLNO  {get;set;}
          @AuraEnabled public String DPCL_AMT {get;set;}
          @AuraEnabled public String EST_DAT_OLD  {get;set;}
          @AuraEnabled public String ZCLASS {get;set;}
          @AuraEnabled public String ERDAT  {get;set;}
          @AuraEnabled public String ERNAM  {get;set;}
          @AuraEnabled public String ERZET  {get;set;}
          @AuraEnabled public String AEDAT  {get;set;}
          @AuraEnabled public String AENAM  {get;set;}
          @AuraEnabled public String AEZET  {get;set;}
        }
        public class IF_ORDER_003_Res_OT_INCOMH{
          public IF_ORDER_003_Res_OT_INCOMH(){}

          @AuraEnabled public String ZZINCOM_NO {get;set;}
          @AuraEnabled public String ZZINCOM_VER  {get;set;}
          @AuraEnabled public String ZTERM  {get;set;}
          @AuraEnabled public String ZZTERM {get;set;}
          @AuraEnabled public String ZZINTER_RATE {get;set;}
          @AuraEnabled public String BASE_DATE  {get;set;}
          @AuraEnabled public String NETWR  {get;set;}
          @AuraEnabled public String ZZTAX  {get;set;}
          @AuraEnabled public String WAERK  {get;set;}
          @AuraEnabled public String PRE_NETWR  {get;set;}
          @AuraEnabled public String ZPARTIAL_FLAG  {get;set;}
          @AuraEnabled public String ZGUBUN {get;set;}
          @AuraEnabled public String ZDOWNPAY_A {get;set;}
          @AuraEnabled public String ZDOWNPAY_P {get;set;}
          @AuraEnabled public String ZTIMES {get;set;}
          @AuraEnabled public String ZMONTH {get;set;}
          @AuraEnabled public String ZCLASS {get;set;}
          @AuraEnabled public String ERDAT  {get;set;}
          @AuraEnabled public String ERNAM  {get;set;}
          @AuraEnabled public String ERZET  {get;set;}
        }
        public class IF_ORDER_003_Res_OT_TEXT{
          public IF_ORDER_003_Res_OT_TEXT(){}

          @AuraEnabled public String TDFORMAT {get;set;}
          @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_ORDER_003_Res_OT_TEXT02{
          public IF_ORDER_003_Res_OT_TEXT02(){}

          @AuraEnabled public String TDFORMAT {get;set;}
          @AuraEnabled public String TDLINE {get;set;}
        }
      
/** IF_ORDER_008
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-008
         * SFDC interface Id    : IF_ORDER_008
         * AS-IS RFC            : Z_SD_GET_KIT_LIST_CAT
         * New I/F              : ZCRM_SD_GET_KIT_LIST_CAT_USA
         * Description          : Option Only Order 생성(Factory Order)-PKMT(모델)을 입력해서 추가자재 중분류를 가져오는 RFC
         * KeyValue             : X
         * NOT NULL             : X
     */            
     /** REQUEST 
      */
      public class IF_ORDER_008_Req { 
        public IF_ORDER_008_Req(){}
        @AuraEnabled public String I_KIT_CAT {get;set;} // ? Kit Category
        @AuraEnabled public String I_MATNR {get;set;} // ? Material Number
        @AuraEnabled public String I_KIT {get;set;} // ? Material Number
  
     /** RESPONSE 
      */          
      }
      public class IF_ORDER_008_Res {
        public IF_ORDER_008_Res(){
          this.O_RETURN = new IF_ORDER_008_Res_O_RETURN();
          this.T_LIST   = new List<IF_ORDER_008_Res_T_LIST>(); 
        }
        @AuraEnabled public IF_ORDER_008_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_ORDER_008_Res_T_LIST> T_LIST {get;set;} 
      }
  
      public class IF_ORDER_008_Res_O_RETURN { 
        public IF_ORDER_008_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
      }
  
      public class IF_ORDER_008_Res_T_LIST { 
        public IF_ORDER_008_Res_T_LIST(){}
        @AuraEnabled public String KIT_CAT     {get;set;} // ? Kit Category
        @AuraEnabled public String KIT_CAT_DSC {get;set;} // ? Description
  
      }  

/** IF_ORDER_009
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-009
         * SFDC interface Id    : IF_ORDER_009
         * AS-IS RFC            : Z_SD_GET_KIT_LIST
         * New I/F              : ZCRM_SD_GET_KIT_LIST_USA
         * Description          : Option Only Order 생성(Factory Order)-추가자재 중분류(I_KIT_CAT)를 입력해서 세부 Kit 데이터를 가져오는 RFC
         * KeyValue             : X
         * NOT NULL             : X
     */            
     /** REQUEST 
      */
      public class IF_ORDER_009_Req { 
        public IF_ORDER_009_Req(){}
        @AuraEnabled public String I_KIT_CAT {get;set;} // ? Kit Category
        @AuraEnabled public String I_MATNR {get;set;} // ? Material Number
        @AuraEnabled public String I_KIT {get;set;} // ? Material Number
        @AuraEnabled public String I_VKBUR {get;set;} // ? Sales Office
  
  
        }

     /** RESPONSE 
      */        
      public class IF_ORDER_009_Res {
        public IF_ORDER_009_Res(){
          this.O_RETURN = new IF_ORDER_009_Res_O_RETURN();
          this.T_LIST   = new List<IF_ORDER_009_Res_T_LIST>();

        }
        @AuraEnabled public IF_ORDER_009_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_ORDER_009_Res_T_LIST> T_LIST {get;set;} 
        }
  
      public class IF_ORDER_009_Res_O_RETURN {
        public IF_ORDER_009_Res_O_RETURN(){} 
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
      }
  
      public class IF_ORDER_009_Res_T_LIST {
        public IF_ORDER_009_Res_T_LIST(){} 
        @AuraEnabled public String MATNR    {get;set;} // ? Material Number
        @AuraEnabled public String MATNR_T  {get;set;} // ? Material Description (Short Text)
        @AuraEnabled public String KIT      {get;set;} // ? Material Number
        @AuraEnabled public String KIT_T    {get;set;} // ? Material Description (Short Text)
        @AuraEnabled public String KIT_CAT  {get;set;} // ? Kit Category
        @AuraEnabled public String MEINS    {get;set;} // ? Unit
        @AuraEnabled public String KBETR    {get;set;} // ? Unit
        @AuraEnabled public String WAERK    {get;set;} // ? Unit
        @AuraEnabled public String DISCOUNT {get;set;}
        @AuraEnabled public String PERCENT  {get;set;} 

      }

/** IF-ORDER-010 
 *  RFC Name             : ZCRM_SD_BOOKING_LIST_USA
 *  Description          : Booking List Interface
    */
    public class IF_ORDER_010_Req {
      public IF_ORDER_010_Req(){}
      @AuraEnabled public String I_ORDER_STS  {get;set;}
      @AuraEnabled public String I_MATNR      {get;set;}
      @AuraEnabled public String I_VKORG      {get;set;}
      @AuraEnabled public String I_VTWEG      {get;set;}
      @AuraEnabled public String I_SPART      {get;set;}
      @AuraEnabled public String I_VBELN_ST   {get;set;}
    }
    public class IF_ORDER_010_Res {
      public IF_ORDER_010_Res(){}
      @AuraEnabled public String O_RECODE                       {get;set;}
      @AuraEnabled public String O_REMSG                        {get;set;}
      @AuraEnabled public List<IF_ORDER_010_Res_T_ITEM> T_ITEM  {get;set;}
      @AuraEnabled public List<IF_ORDER_010_Res_T_SQTXT> T_SQTXT  {get;set;}
    }
    public class IF_ORDER_010_Res_T_ITEM {
      public IF_ORDER_010_Res_T_ITEM(){}
      @AuraEnabled public String VBELN_ST          {get;set;}        
      @AuraEnabled public String INVENTORY_STS     {get;set;}              
      @AuraEnabled public String ORDER_STS         {get;set;}          
      @AuraEnabled public String VBELN_RE          {get;set;}        
      @AuraEnabled public String DNSA_MODEL        {get;set;}
      @AuraEnabled public String MC_TC             {get;set;}      
      @AuraEnabled public String NC                {get;set;}  
      @AuraEnabled public String BASE_CODE         {get;set;}          
      @AuraEnabled public String SERIAL_NUMBER     {get;set;}              
      @AuraEnabled public String PROD_DATE         {get;set;}          
      @AuraEnabled public String OPEN_NOTES        {get;set;}          
      @AuraEnabled public String PORT              {get;set;}    
      @AuraEnabled public String DEALER_PO         {get;set;}          
      @AuraEnabled public String DEALER            {get;set;}      
      @AuraEnabled public String DEALER_NAME       {get;set;}            
      @AuraEnabled public String CUSTOMER          {get;set;}        
      @AuraEnabled public String CUSTOMER_NAME     {get;set;}              
      @AuraEnabled public String DNSA_PO           {get;set;}        
      @AuraEnabled public String DNS_CPO           {get;set;}        
      @AuraEnabled public String DNS_PSO           {get;set;}        
      @AuraEnabled public String DEPT              {get;set;}    
      @AuraEnabled public String ETA_DATE          {get;set;}        
      @AuraEnabled public String RES_THRU          {get;set;}        
      @AuraEnabled public String LOCATION          {get;set;}        
      @AuraEnabled public String WAERK             {get;set;}      
      @AuraEnabled public String LIST_PRICE        {get;set;}          
      @AuraEnabled public String PERCENT_OFF       {get;set;}            
      @AuraEnabled public String ADJUSTED_LIST     {get;set;}              
      @AuraEnabled public String CREATE_BY         {get;set;}          
      @AuraEnabled public String CREATE_DATE       {get;set;}            
      @AuraEnabled public String UPDATE_BY         {get;set;}          
      @AuraEnabled public String UPDATE_DATE       {get;set;}            
      @AuraEnabled public String INVOICED_DATE     {get;set;}              
      @AuraEnabled public String RELEASE_NO        {get;set;}          
      @AuraEnabled public String RELEASE_DATE      {get;set;}
      @AuraEnabled public String ZDELETE           {get;set;} 
      @AuraEnabled public String CRM_ID            {get;set;} 
      @AuraEnabled public String CRM_NAME          {get;set;} 
      @AuraEnabled public String CRM_KUNNR         {get;set;} 
      @AuraEnabled public String CRM_SOLD_TO       {get;set;} 
      @AuraEnabled public String CRM_ID1           {get;set;} 
      @AuraEnabled public String CRM_NAME1         {get;set;} 
      @AuraEnabled public String CRM_KUNNR1        {get;set;} 
      @AuraEnabled public String CRM_SOLD_TO1      {get;set;} 
      @AuraEnabled public String CRM_ID2           {get;set;} 
      @AuraEnabled public String CRM_NAME2         {get;set;} 
      @AuraEnabled public String CRM_KUNNR2        {get;set;} 
      @AuraEnabled public String CRM_SOLD_TO2      {get;set;} 
      @AuraEnabled public String CRM_ID3           {get;set;} 
      @AuraEnabled public String CRM_NAME3         {get;set;} 
      @AuraEnabled public String CRM_KUNNR3        {get;set;} 
      @AuraEnabled public String CRM_SOLD_TO3      {get;set;} 
      @AuraEnabled public String CRM_REID          {get;set;} 
      
    }
    public class IF_ORDER_010_Res_T_SQTXT{
      public IF_ORDER_010_Res_T_SQTXT(){}
      @AuraEnabled public String VBELN_ST          {get;set;}
      @AuraEnabled public String SQTXT             {get;set;}
    }
/** IF-ORDER-011
 *  RFC Name             : ZCRM_SD_CHG_BOOKING_STAT_US
 *  Description          : Stock Reserve/Cancel
    */
    public class IF_ORDER_011_Req {
      public IF_ORDER_011_Req(){}
      @AuraEnabled public String I_OKCODE      {get;set;}
      @AuraEnabled public String I_BNAME       {get;set;}

      @AuraEnabled public String I_CRM_ID      {get;set;}
      @AuraEnabled public String I_CRM_NAME    {get;set;}
      @AuraEnabled public String I_KUNNR       {get;set;}
      @AuraEnabled public String I_CRM_SOLD_TO {get;set;}            
      
      @AuraEnabled public List<IF_ORDER_011_Req_T_ITEM> T_ITEM  {get;set;}
    }
    public class IF_ORDER_011_Req_T_ITEM {
      public IF_ORDER_011_Req_T_ITEM(){}
      @AuraEnabled public String VBELN_ST   {get;set;}
      @AuraEnabled public String DEALER     {get;set;}
      @AuraEnabled public String CUSTOMER   {get;set;}
      @AuraEnabled public String CRM_REID   {get;set;}
    }
    public class IF_ORDER_011_Res {
      public IF_ORDER_011_Res(){}
      @AuraEnabled public String O_RECODE                       {get;set;}
      @AuraEnabled public String O_REMSG                        {get;set;}
      @AuraEnabled public List<IF_ORDER_011_Res_T_ITEM> T_ITEM  {get;set;}
    }
    public class IF_ORDER_011_Res_T_ITEM {
      public IF_ORDER_011_Res_T_ITEM(){}
      @AuraEnabled public String VBELN_ST       {get;set;}          
      @AuraEnabled public String INVENTORY_STS  {get;set;}                
      @AuraEnabled public String ORDER_STS      {get;set;}            
      @AuraEnabled public String VBELN_RE       {get;set;}          
      @AuraEnabled public String DNSA_MODEL     {get;set;}
      @AuraEnabled public String MC_TC          {get;set;}        
      @AuraEnabled public String NC             {get;set;}    
      @AuraEnabled public String BASE_CODE      {get;set;}            
      @AuraEnabled public String SERIAL_NUMBER  {get;set;}                
      @AuraEnabled public String PROD_DATE      {get;set;}            
      @AuraEnabled public String OPEN_NOTES     {get;set;}            
      @AuraEnabled public String PORT           {get;set;}      
      @AuraEnabled public String DEALER_PO      {get;set;}            
      @AuraEnabled public String DEALER         {get;set;}        
      @AuraEnabled public String DEALER_NAME    {get;set;}              
      @AuraEnabled public String CUSTOMER       {get;set;}          
      @AuraEnabled public String CUSTOMER_NAME  {get;set;}                
      @AuraEnabled public String DNSA_PO        {get;set;}          
      @AuraEnabled public String DNS_CPO        {get;set;}          
      @AuraEnabled public String DNS_PSO        {get;set;}          
      @AuraEnabled public String DEPT           {get;set;}      
      @AuraEnabled public String ETA_DATE       {get;set;}          
      @AuraEnabled public String RES_THRU       {get;set;}          
      @AuraEnabled public String LOCATION       {get;set;}          
      @AuraEnabled public String WAERK          {get;set;}        
      @AuraEnabled public String LIST_PRICE     {get;set;}            
      @AuraEnabled public String PERCENT_OFF    {get;set;}              
      @AuraEnabled public String ADJUSTED_LIST  {get;set;}                
      @AuraEnabled public String CREATE_BY      {get;set;}            
      @AuraEnabled public String CREATE_DATE    {get;set;}              
      @AuraEnabled public String UPDATE_BY      {get;set;}            
      @AuraEnabled public String UPDATE_DATE    {get;set;}              
      @AuraEnabled public String INVOICED_DATE  {get;set;}                
      @AuraEnabled public String RELEASE_NO     {get;set;}            
      @AuraEnabled public String RELEASE_DATE   {get;set;}    
      @AuraEnabled public String CRM_ID1        {get;set;}
      @AuraEnabled public String CRM_NAME1      {get;set;}
      @AuraEnabled public String CRM_KUNNR1     {get;set;}
      @AuraEnabled public String CRM_SOLD_TO1   {get;set;}
      @AuraEnabled public String CRM_ID2        {get;set;}
      @AuraEnabled public String CRM_NAME2      {get;set;}
      @AuraEnabled public String CRM_KUNNR2     {get;set;}
      @AuraEnabled public String CRM_SOLD_TO2   {get;set;}
      @AuraEnabled public String CRM_ID3        {get;set;}
      @AuraEnabled public String CRM_NAME3      {get;set;}
      @AuraEnabled public String CRM_KUNNR3     {get;set;}
      @AuraEnabled public String CRM_SOLD_TO3   {get;set;}
      @AuraEnabled public String CRM_REID       {get;set;}                
    }

/** IF_ORDER_012
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-012
         * SFDC interface Id    : IF_ORDER_012
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_SALES_ORDER_INFO_USA
         * Description          : DNSA의 Order 정보 Interface용 RFC 
     */
     /** REQUEST 
      */              
        public class IF_ORDER_012_Req { 
          public IF_ORDER_012_Req(){}
          @AuraEnabled public String I_VBELN   {get;set;} // ? Sales Document Number
          @AuraEnabled public String I_AEDAT_F {get;set;} // ? From Date Changed On
          @AuraEnabled public String I_AEDAT_T {get;set;} // ? To Date Changed On 
        }

     /** RESPONSE 
      */        
      public class IF_ORDER_012_Res {
        public IF_ORDER_012_Res(){
          this.O_RETURN = new IF_ERP_Order_Classes.IF_ORDER_012_Res_O_RETURN();
          this.T_ORDER  = new List<IF_ERP_Order_Classes.IF_ORDER_012_Res_T_ORDER>();
          this.T_ZCRMS0094 = new List<IF_ERP_Order_Classes.IF_ORDER_012_Res_T_ZCRMS0094>();
        }
        @AuraEnabled public IF_ORDER_012_Res_O_RETURN           O_RETURN    {get;set;} 
        @AuraEnabled public List<IF_ORDER_012_Res_T_ORDER>      T_ORDER     {get;set;}
        @AuraEnabled public List<IF_ORDER_012_Res_T_ZCRMS0094>  T_ZCRMS0094 {get;set;} 
      }
  
      public class IF_ORDER_012_Res_O_RETURN { 
        public IF_ORDER_012_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
      }
  
      public class IF_ORDER_012_Res_T_ORDER { 
        public IF_ORDER_012_Res_T_ORDER(){}
        @AuraEnabled public String VKORG {get;set;}
        @AuraEnabled public String VTWEG {get;set;}
        @AuraEnabled public String SPART {get;set;}  
        @AuraEnabled public String AUART {get;set;}  
        @AuraEnabled public String BSTDK {get;set;}  
        @AuraEnabled public String AUART_TX {get;set;}  
        @AuraEnabled public String BSTKD {get;set;}  
        @AuraEnabled public String ERDAT {get;set;}  
        @AuraEnabled public String VBELN {get;set;}  
        @AuraEnabled public String ERDAT_D {get;set;}  
        @AuraEnabled public String GUBUN {get;set;}  
        @AuraEnabled public String MODEL {get;set;}  
        @AuraEnabled public String MODEL_TX {get;set;}  
        @AuraEnabled public String TOTAL_AMT {get;set;}  
        @AuraEnabled public String DISC_AMT {get;set;}  
        @AuraEnabled public String SURC_AMT {get;set;}  
        @AuraEnabled public String NETWR_AMT {get;set;}  
        @AuraEnabled public String WAERK {get;set;}  
        @AuraEnabled public String VSART {get;set;}  
        @AuraEnabled public String VSART_TX {get;set;}  
        @AuraEnabled public String ZTERM {get;set;}  
        @AuraEnabled public String ZTERM_TX {get;set;}  
        @AuraEnabled public String VDATU {get;set;}  
        @AuraEnabled public String KUNNR_AG {get;set;}  
        @AuraEnabled public String KUNNR_AG_TX {get;set;}  
        @AuraEnabled public String KUNNR_WE {get;set;}  
        @AuraEnabled public String KUNNR_WE_TX {get;set;}  
        @AuraEnabled public String KUNNR_RE {get;set;}  
        @AuraEnabled public String KUNNR_RE_TX {get;set;}  
        @AuraEnabled public String KUNNR_RG {get;set;}  
        @AuraEnabled public String KUNNR_RG_TX {get;set;}  
        @AuraEnabled public String KUNNR_ZM {get;set;}  
        @AuraEnabled public String KUNNR_ZM_TX {get;set;}  
        @AuraEnabled public String ERNAM {get;set;}  
        @AuraEnabled public String NAME {get;set;}  
        @AuraEnabled public String APPROVAL {get;set;}  
        @AuraEnabled public String REJECT {get;set;}  
        @AuraEnabled public String BUTTTON_ENABLE {get;set;}  
        @AuraEnabled public String ZZSTATUS {get;set;}  
        @AuraEnabled public String ZZSTATUS_TX {get;set;}  
        @AuraEnabled public String ZSDFUNC {get;set;}  
        @AuraEnabled public String ZSDFUNC_TX {get;set;}  
        @AuraEnabled public String ABGRU {get;set;}  
        @AuraEnabled public String ABGRU_TX {get;set;}  
        @AuraEnabled public String TAX_AMT {get;set;}  
        @AuraEnabled public String SERNR {get;set;}  
        @AuraEnabled public String MAKTX {get;set;}  
        @AuraEnabled public String TOTAL_DC_RATE {get;set;}  
        @AuraEnabled public String FKDAT {get;set;}  
        @AuraEnabled public String VSBED {get;set;}  
        @AuraEnabled public String VSBED_TX {get;set;}  
        @AuraEnabled public String MBDAT {get;set;}  
        @AuraEnabled public String KUNNR_ZV {get;set;}  
        @AuraEnabled public String KUNNR_ZV_TX {get;set;}  
        @AuraEnabled public String ICON_V {get;set;}  
        @AuraEnabled public String BMENG {get;set;}  
        @AuraEnabled public String ADEPDT {get;set;}  
        @AuraEnabled public String VRKME {get;set;}  
        @AuraEnabled public String OALIAS {get;set;}  
        @AuraEnabled public String IHREZ {get;set;}  
        @AuraEnabled public String VBELN_ST {get;set;}  
        @AuraEnabled public String KWERT {get;set;}  
        @AuraEnabled public String WAERS {get;set;}  
        @AuraEnabled public String KBETR {get;set;}  
        @AuraEnabled public String WAERS_DC {get;set;}  
        @AuraEnabled public String KWERT_DC {get;set;}  
        @AuraEnabled public String ATTACH {get;set;}  
        @AuraEnabled public String ZZAPPNO {get;set;}  
        @AuraEnabled public String ZZAPPNO_T {get;set;}  
        @AuraEnabled public String LOCATION {get;set;}  
        @AuraEnabled public String KUNNR_Z2 {get;set;}  
        @AuraEnabled public String Z2_NAME {get;set;}  
        @AuraEnabled public String VSNMR_V {get;set;}  
        @AuraEnabled public String EQUNR {get;set;}  
        @AuraEnabled public String MDLNM {get;set;}  
        @AuraEnabled public String EDATE {get;set;}  
        @AuraEnabled public String RDATE {get;set;}  
        @AuraEnabled public String RTDAT {get;set;}  
        @AuraEnabled public String STAGE {get;set;}  
        @AuraEnabled public String NOTE_ZH03 {get;set;}  
        @AuraEnabled public String EDATU {get;set;}  
        @AuraEnabled public String FKSTK {get;set;}  
        @AuraEnabled public String AUGRU {get;set;}  
        @AuraEnabled public String AUGRU_T {get;set;}  
        @AuraEnabled public String SERGE {get;set;}  
        @AuraEnabled public String ZSTOCKTEX {get;set;} 
        @AuraEnabled public String VBELN_STO {get;set;} 
        @AuraEnabled public String UPTDATE {get;set;} 
        @AuraEnabled public String ZPPDATE {get;set;} 
        @AuraEnabled public String OPT1 {get;set;} 
        @AuraEnabled public String OPT2 {get;set;} 
        @AuraEnabled public String OPT3 {get;set;} 
        @AuraEnabled public String OPT4 {get;set;} 
        @AuraEnabled public String OPT5 {get;set;} 
        @AuraEnabled public String OPT6 {get;set;} 
        @AuraEnabled public String ACDAT {get;set;} 
        @AuraEnabled public String J_1KFREPRE {get;set;} 
        @AuraEnabled public String CARNO {get;set;} 
        @AuraEnabled public String AMOUNT {get;set;} 
        @AuraEnabled public String BAS_RATE {get;set;} 
        @AuraEnabled public String ALL_RATE {get;set;} 
        @AuraEnabled public String PRO_RATE {get;set;} 
        @AuraEnabled public String TOTAL_DC_AMT {get;set;} 
        @AuraEnabled public String TOTAL_DC {get;set;} 
        @AuraEnabled public String DC_AMT {get;set;} 
        @AuraEnabled public String ATWRT {get;set;} 
        @AuraEnabled public String VBELN_V {get;set;} 
        @AuraEnabled public String ZTRAC {get;set;} 
        @AuraEnabled public String POSNR {get;set;} 
        @AuraEnabled public String LIFNR {get;set;} 
        @AuraEnabled public String NAME1 {get;set;} 
        @AuraEnabled public String MATNR {get;set;} 
        @AuraEnabled public String ETDAT {get;set;} 
        @AuraEnabled public String PRODAT {get;set;} 
        @AuraEnabled public String ZETADAT {get;set;} 
        @AuraEnabled public String VKBUR {get;set;} 
        @AuraEnabled public String EBELN {get;set;} 
        @AuraEnabled public String ZPORT {get;set;} 
        @AuraEnabled public String SHP_DT {get;set;} 
        @AuraEnabled public String DLV_DT {get;set;} 
        @AuraEnabled public String MANUFACTURER {get;set;} 
        @AuraEnabled public String AEDAT {get;set;} 
        @AuraEnabled public String WADAT_IST {get;set;} 
        @AuraEnabled public String PSO_NUM {get;set;}   
        @AuraEnabled public String ZDELFLAG {get;set;}
        @AuraEnabled public String ZRETURNS {get;set;}           
        @AuraEnabled public String INCO1    {get;set;}
        @AuraEnabled public String INCO2    {get;set;}        
      }

      public class IF_ORDER_012_Res_T_ZCRMS0094{
        public IF_ORDER_012_Res_T_ZCRMS0094(){}
        @AuraEnabled public String VBELN_SO {get;set;}
        @AuraEnabled public String PSO_NUM {get;set;}
        @AuraEnabled public String VBELN {get;set;}
        @AuraEnabled public String WADAT {get;set;}
        @AuraEnabled public String WAUHR {get;set;}
        @AuraEnabled public String LFDAT {get;set;}
        @AuraEnabled public String LFUHR {get;set;}
        @AuraEnabled public String WADAT_IST {get;set;}
        @AuraEnabled public String ZZSTATUS {get;set;}
        @AuraEnabled public String ZFETD {get;set;}
        @AuraEnabled public String ZFETA {get;set;}
        @AuraEnabled public String ZFCSHCP {get;set;}
        @AuraEnabled public String ZFCARNM {get;set;}
        @AuraEnabled public String ZFPLDVLD {get;set;}
        @AuraEnabled public String ZFPLDVCD {get;set;}
        @AuraEnabled public String ZFPLDV {get;set;}
        @AuraEnabled public String NAME1 {get;set;}            
      }
  

/** IF_ORDER_007
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-007
         * SFDC interface Id    : IF_ORDER_007
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_CREATE_SO_FCT_OPT_USA 
         * Description          : Real Sales Order 생성(Factory Order/Option Only Order )
     */
     /** REQUEST 
      */     
          public class IF_ORDER_007_Req {
            public IF_ORDER_007_Req(){
              this.I_HEAD = new IF_ORDER_007_Req_I_HEAD();
              this.I_COLLECTION = new IF_ORDER_007_Req_I_COLLECTION();
              this.I_USERINFO   = new IF_ORDER_007_Req_I_USERINFO();
              this.T_ITEM = new List<IF_ORDER_007_Req_T_ITEM>();
              this.T_PARTNER = new List<IF_ORDER_007_Req_T_PARTNER>();
              this.T_CONFIG = new List<IF_ORDER_007_Req_T_CONFIG>();
              this.T_SEL_CONFIG = new List<IF_ORDER_007_Req_T_SEL_CONFIG>();
              this.T_PRICING = new List<IF_ORDER_007_Req_T_PRICING>();
              this.T_PRICING_ADD = new List<IF_ORDER_007_Req_T_PRICING_ADD>();
              this.T_PRICING_RATE = new List<IF_ORDER_007_Req_T_PRICING_RATE>();
              this.T_NOTES = new List<IF_ORDER_007_Req_T_NOTES>();
              this.T_FILE = new List<IF_ORDER_007_Req_T_FILE>();
              this.T_RETURN = new List<IF_ORDER_007_Req_T_RETURN>();
              this.T_CONDTEXT = new List<IF_ORDER_007_Req_T_CONDTEXT>();
            }
          
            @AuraEnabled public String I_REF_ORDER {get;set;} // ? Sales Document
            @AuraEnabled public String I_COMPLAIN {get;set;} // ? Return Order: 'X', Normal : ' '
            @AuraEnabled public String I_GUBUN {get;set;} // ? 'C' = Create, 'U' = Change, 'D' = Delete
            @AuraEnabled public String I_TESTRUN {get;set;} // ? Simulation
            @AuraEnabled public String I_INQUIRY {get;set;} // ? 'I' = Inquiry, 'C' = Claim
            @AuraEnabled public String I_MDOWN {get;set;} // ? Machine Down 'Y' or 'N'
            @AuraEnabled public String I_EMAIL {get;set;} // ? Leader mail

            @AuraEnabled public IF_ORDER_007_Req_I_HEAD       I_HEAD {get;set;} 
            @AuraEnabled public IF_ORDER_007_Req_I_COLLECTION I_COLLECTION {get;set;} 
            @AuraEnabled public IF_ORDER_007_Req_I_USERINFO   I_USERINFO {get;set;} 

            @AuraEnabled public List<IF_ORDER_007_Req_T_ITEM> T_ITEM {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_PARTNER> T_PARTNER {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_CONFIG> T_CONFIG {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_SEL_CONFIG> T_SEL_CONFIG {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_PRICING> T_PRICING {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_PRICING_ADD> T_PRICING_ADD {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_PRICING_RATE> T_PRICING_RATE {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_NOTES> T_NOTES {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_FILE> T_FILE {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_RETURN> T_RETURN {get;set;} 
            @AuraEnabled public List<IF_ORDER_007_Req_T_CONDTEXT> T_CONDTEXT {get;set;} 
          }

          public class IF_ORDER_007_Req_I_HEAD { 
            @AuraEnabled public String AUART   {get;set;} // ? Sales Document Type
            @AuraEnabled public String VKORG   {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG   {get;set;} // ? Distribution Channel
            @AuraEnabled public String SPART   {get;set;} // ? Division
            @AuraEnabled public String VKBUR   {get;set;} // ? Sales Office
            @AuraEnabled public String VDATU   {get;set;} // ? Requested delivery date
            @AuraEnabled public String BSTKD   {get;set;} // ? Character Field of Length 780
            @AuraEnabled public String BZIRK   {get;set;} // ? Sales district
            @AuraEnabled public String INCO1   {get;set;} // ? Incoterms (Part 1)
            @AuraEnabled public String INCO2   {get;set;} // ? Incoterms (Part 2)
            @AuraEnabled public String ZTERM   {get;set;} // ? Terms of Payment Key
            @AuraEnabled public String LIFSK   {get;set;} // ? Delivery block (document header)
            @AuraEnabled public String FAKSK   {get;set;} // ? Billing block in SD document
            @AuraEnabled public String AUGRU   {get;set;} // ? Order reason (reason for the business transaction)
            @AuraEnabled public String KVGR1   {get;set;} // ? Customer group 1
            @AuraEnabled public String KVGR2   {get;set;} // ? Customer group 2
            @AuraEnabled public String KVGR3   {get;set;} // ? Customer group 3
            @AuraEnabled public String KVGR4   {get;set;} // ? Customer group 4
            @AuraEnabled public String KVGR5   {get;set;} // ? Customer group 5
            @AuraEnabled public String WAERK   {get;set;} // ? SD Document Currency
            @AuraEnabled public String WERKS   {get;set;} // ? Delivering Plant (Own or External)
            @AuraEnabled public String SUBMI   {get;set;} // ? Collective Number
            @AuraEnabled public String AUTLF   {get;set;} // ? Complete delivery defined for each sales order?
            @AuraEnabled public String KNUMV   {get;set;} // ? Number of the document condition
            @AuraEnabled public String ERNAM   {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ZZINCOM_VER {get;set;} // ? Incoming Plan Version
            @AuraEnabled public String BASE_DATE {get;set;} // ? Incoming Plan Base Date
            @AuraEnabled public String GI_DATE {get;set;} // ? Actual Goods Movement Date
            @AuraEnabled public String T_NETWR {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String T_EST_AMT {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String ERDAT   {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERZET   {get;set;} // ? Entry time
            @AuraEnabled public String BUKRS_VF {get;set;} // ? Company code to be billed
            @AuraEnabled public String NETWR   {get;set;} // ? Net Value of the Sales Order in Document Currency
            @AuraEnabled public String ABRVW   {get;set;} // ? Usage Indicator
            @AuraEnabled public String REFDOCTYPE {get;set;} // ? Document type of reference object
            @AuraEnabled public String REF_DOC {get;set;} // ? Document number of the reference document
            @AuraEnabled public String REFDOC_CAT {get;set;} // ? Document category of preceding SD document
            @AuraEnabled public String REF_PROC {get;set;} // ? Referencing requirement: Procedure
            @AuraEnabled public String KZAZU   {get;set;} // ? Order Combination Indicator
            @AuraEnabled public String BSTDK   {get;set;} // ? Customer purchase order date
            @AuraEnabled public String FKDAT   {get;set;} // ? Billing date for billing index and printout
            @AuraEnabled public String VBTYP   {get;set;} // ? SD document category
            @AuraEnabled public String PLTYP   {get;set;} // ? Price list type
            @AuraEnabled public String VSBED   {get;set;} // ? Shipping Conditions
            @AuraEnabled public String KONDA   {get;set;} // ? Price group (customer)
            @AuraEnabled public String SDABW   {get;set;} // ? Special processing indicator
            @AuraEnabled public String EQUNR   {get;set;} // ? Equipment Number
            @AuraEnabled public String VSNMR_V {get;set;} // ? Sales document version number
            @AuraEnabled public String BNAME   {get;set;} // ? Name of orderer
            @AuraEnabled public String TELF1   {get;set;} // ? Telephone Number
            @AuraEnabled public String IHREZ   {get;set;} // ? Your Reference
            @AuraEnabled public String VSART   {get;set;} // ? Shipping type
            @AuraEnabled public String BSTKD_E {get;set;} // ? Ship-to Party's Purchase Order Number
            @AuraEnabled public String IHREZ_E {get;set;} // ? Ship-to party character
            @AuraEnabled public String AUART_T {get;set;} // ? Description
            @AuraEnabled public String ZTERM_T {get;set;} // ? Description of terms of payment
            @AuraEnabled public String VSBED_T {get;set;} // ? Description of the shipping conditions
            @AuraEnabled public String ABRVW_T {get;set;} // ? Description
            @AuraEnabled public String ANGDT   {get;set;} // ? Quotation/Inquiry is valid from
            @AuraEnabled public String BNDDT   {get;set;} // ? Date until which bid/quotation is binding (valid-to date)
            @AuraEnabled public String SERGE   {get;set;} // ? Manufacturer serial number
            @AuraEnabled public String ZSDFUNC {get;set;} // ? Sales Function
            @AuraEnabled public String ZZSTATUS {get;set;} // ? Approval Status
            @AuraEnabled public String ZZUSEDCAR_NO {get;set;} // ? Used Car Management No.
            @AuraEnabled public String ZZINCOM_NO {get;set;} // ? Incoming Plan NO
            @AuraEnabled public String ZZPERM_NO {get;set;} // ? Military Goods Permission No
            @AuraEnabled public String ZZCAPITAL_NO {get;set;} // ? Capital No.
            @AuraEnabled public String ZZPERIOD {get;set;} // ? Deferment Period
            @AuraEnabled public String ZZRAT_REDUCE {get;set;} // ? Interest rate reduce
            @AuraEnabled public String ZZWARRPER {get;set;} // ? Warranty Period
            @AuraEnabled public String ZZPERUNIT {get;set;} // ? Warranty Indicator
            @AuraEnabled public String ZZWARHRS {get;set;} // ? Warranty Hours
            @AuraEnabled public String ZZWARRPER_B {get;set;} // ? Warranty Period
            @AuraEnabled public String ZZPERUNIT_B {get;set;} // ? Warranty Indicator
            @AuraEnabled public String ZZWARHRS_B {get;set;} // ? Warranty Hours
            @AuraEnabled public String ZZWARRDAT {get;set;} // ? Warranty Valid on
            @AuraEnabled public String ZZPR_WAR {get;set;} // ? Pricing Factor(Warranty)
            @AuraEnabled public String ZZPR_WAR_B {get;set;} // ? Pricing Factor(Warranty)
            @AuraEnabled public String ZZCOVERAGE {get;set;} // ? Warranty - Coverage
            @AuraEnabled public String ZZCOVERAGE_B {get;set;} // ? Warranty - Coverage (Added)
            @AuraEnabled public String ZZSQNO  {get;set;} // ? Seqeunce Number
            @AuraEnabled public String ZZTECHARG {get;set;} // ? Tech Agreemnet Number
            @AuraEnabled public String ZZDRAFTNO {get;set;} // ? Draft Number
            @AuraEnabled public String ZZAPPNO {get;set;} // ? Strategic Material Approval Number
            @AuraEnabled public String ZZAPPNO_T {get;set;} // ? Name 1
            @AuraEnabled public String ZZCAPITAL_NO_T {get;set;} // ? Description
            @AuraEnabled public String ZZMACNO {get;set;} // ? Machine no
            @AuraEnabled public String ZZQUINO {get;set;} // ? Equipment no
            @AuraEnabled public String ZZISDAT {get;set;} // ? Installation date
            @AuraEnabled public String ZZCFSTA {get;set;} // ? Confirm status
            @AuraEnabled public String ZZCFUSR {get;set;} // ? Confirmed user
            @AuraEnabled public String CUSTOMS_BRO {get;set;} // ? Customs Broker
            @AuraEnabled public String ZZURGEN {get;set;} // ? Priority
          }

          public class IF_ORDER_007_Req_I_COLLECTION { 
            @AuraEnabled public String ZZUSEDCAR_NO {get;set;} // ? ZZUSEDCAR_NO
            @AuraEnabled public String ZZPERM_NO {get;set;} // ? ZZPERM_NO
            @AuraEnabled public String ZZCAPITAL_NO {get;set;} // ? ZZCAPITAL_NO
            @AuraEnabled public String MORT_CODE1 {get;set;} // ? MORT_CODE1
            @AuraEnabled public String MORT_DATE1 {get;set;} // ? MORT_DATE1
            @AuraEnabled public String MORT_CODE2 {get;set;} // ? MORT_CODE2
            @AuraEnabled public String MORT_DATE2 {get;set;} // ? MORT_DATE2
            @AuraEnabled public String MORT_CODE3 {get;set;} // ? MORT_CODE3
            @AuraEnabled public String MORT_DATE3 {get;set;} // ? MORT_DATE3
            @AuraEnabled public String MORT_CODE4 {get;set;} // ? MORT_CODE4
            @AuraEnabled public String MORT_DATE4 {get;set;} // ? MORT_DATE4
            @AuraEnabled public String MORT_CODE5 {get;set;} // ? MORT_CODE5
            @AuraEnabled public String MORT_DATE5 {get;set;} // ? MORT_DATE5
            @AuraEnabled public String MORT_CODE6 {get;set;} // ? MORT_CODE6
            @AuraEnabled public String MORT_DATE6 {get;set;} // ? MORT_DATE6
            @AuraEnabled public String ZZWARRPER {get;set;} // ? ZZWARRPER
            @AuraEnabled public String ZZPERUNIT {get;set;} // ? ZZPERUNIT
            @AuraEnabled public String ZZWARHRS  {get;set;} // ? ZZWARHRS
            @AuraEnabled public String ZZWARRDAT {get;set;} // ? ZZWARRDAT
            @AuraEnabled public String BASE_DATE {get;set;} // ? BASE_DATE
            @AuraEnabled public String WADAT_IST {get;set;} // ? WADAT_IST
            @AuraEnabled public String ZZINCOM_NO {get;set;} // ? ZZINCOM_NO
            @AuraEnabled public String NETWR     {get;set;} // ? NETWR
            @AuraEnabled public String NETWR1    {get;set;} // ? NETWR1
            @AuraEnabled public String WAERK     {get;set;} // ? WAERK
            @AuraEnabled public String INCOM_CODE {get;set;} // ? INCOM_CODE
            @AuraEnabled public String ZTERM     {get;set;} // ? ZTERM
            @AuraEnabled public String EST_DAT   {get;set;} // ? EST_DAT
            @AuraEnabled public String EST_AMT   {get;set;} // ? EST_AMT
            @AuraEnabled public String FA_CODE   {get;set;} // ? FA_CODE
            @AuraEnabled public String DOWN_REQ_NO {get;set;} // ? DOWN_REQ_NO
            @AuraEnabled public String MODIFY_NETWR {get;set;} // ? MODIFY_NETWR
            @AuraEnabled public String ZZPERIOD  {get;set;} // ? ZZPERIOD
            @AuraEnabled public String ZZRAT_REDUCE {get;set;} // ? ZZRAT_REDUCE
            @AuraEnabled public String RESIDUAL  {get;set;} // ? RESIDUAL
            @AuraEnabled public String ZZDRAFTNO {get;set;} // ? ZZDRAFTNO
          }

          public class IF_ORDER_007_Req_T_ITEM { 
                @AuraEnabled public String POSNR {get;set;}
                @AuraEnabled public String UEPOS {get;set;}
                @AuraEnabled public String MATNR {get;set;}
                @AuraEnabled public String ARKTX {get;set;}
                @AuraEnabled public String ABGRU {get;set;}
                @AuraEnabled public String VKAUS {get;set;}
                @AuraEnabled public String NETWR {get;set;}
                @AuraEnabled public String NETPR {get;set;}
                @AuraEnabled public String MWST {get;set;}
                @AuraEnabled public String WAERK {get;set;}
                @AuraEnabled public String MWSBP {get;set;}
                @AuraEnabled public String KWMENG {get;set;}
                @AuraEnabled public String KBMENG {get;set;}
                @AuraEnabled public String KLMENG {get;set;}
                @AuraEnabled public String VRKME {get;set;}
                @AuraEnabled public String MEINS {get;set;}
                @AuraEnabled public String WERKS {get;set;}
                @AuraEnabled public String ROUTE {get;set;}
                @AuraEnabled public String ANZSN {get;set;}
                @AuraEnabled public String UPDATEFLAG {get;set;}
                @AuraEnabled public String KZWI1 {get;set;}
                @AuraEnabled public String LIST_PRICE {get;set;}
                @AuraEnabled public String SUB_TOTAL {get;set;}
                @AuraEnabled public String PSTYV {get;set;}
                @AuraEnabled public String REF_DOC {get;set;}
                @AuraEnabled public String REF_DOC_IT {get;set;}
                @AuraEnabled public String REF_DOC_CA {get;set;}
                @AuraEnabled public String POSEX {get;set;}
                @AuraEnabled public String MAKTX {get;set;}
                @AuraEnabled public String KDMAT {get;set;}
                @AuraEnabled public String VSTEL {get;set;}
                @AuraEnabled public String REQ_DATE {get;set;}
                @AuraEnabled public String PRSDT {get;set;}
                @AuraEnabled public String KONDA {get;set;}
                @AuraEnabled public String LGORT {get;set;}
                @AuraEnabled public String LGOBE {get;set;}
                @AuraEnabled public String VSART {get;set;}
                @AuraEnabled public String PARENT {get;set;}
                @AuraEnabled public String EDATU {get;set;}
                @AuraEnabled public String POSNRX {get;set;}
                @AuraEnabled public String TNDR_TRKID {get;set;}
                @AuraEnabled public String IHREZ_E {get;set;}
                @AuraEnabled public String ST_7020 {get;set;}
                @AuraEnabled public String ZZACCPTCD {get;set;}
                @AuraEnabled public String ZZDEALDT {get;set;}
                @AuraEnabled public String ZZAPPMACHINE {get;set;}
                @AuraEnabled public String ZZEQMASTER {get;set;}
                @AuraEnabled public String ZZWORKHRS {get;set;}
                @AuraEnabled public String ZZCMPCD {get;set;}
                @AuraEnabled public String ZZREASON {get;set;}
                @AuraEnabled public String ZZKMAT {get;set;}
                @AuraEnabled public String EQUIP_CHECK {get;set;}
                @AuraEnabled public String AVAIL_DATE {get;set;}
                @AuraEnabled public String VENDOR {get;set;}
                @AuraEnabled public String CARRIER {get;set;}
                @AuraEnabled public String TRACKING_NO {get;set;}
                @AuraEnabled public String VDATU {get;set;}
                @AuraEnabled public String REMARK {get;set;}
          }

          public class IF_ORDER_007_Req_T_PARTNER { 
            @AuraEnabled public String VBELN      {get;set;} // ? Sales Document
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String PARVW      {get;set;} // ? Partner Function
            @AuraEnabled public String KUNNR      {get;set;} // ? Customer Number 1
            @AuraEnabled public String NAME1      {get;set;} // ? Name 1
            @AuraEnabled public String NAME2      {get;set;} // ? Name 2
            @AuraEnabled public String NAME3      {get;set;} // ? Name 3
            @AuraEnabled public String NAME4      {get;set;} // ? Name 4
            @AuraEnabled public String STREET1    {get;set;} // ? Street
            @AuraEnabled public String STREET2    {get;set;} // ? Street 2
            @AuraEnabled public String CITY1      {get;set;} // ? City
            @AuraEnabled public String CITY2      {get;set;} // ? District
            @AuraEnabled public String STATE      {get;set;} // ? Region (State, Province, County)
            @AuraEnabled public String ZIP        {get;set;} // ? City postal code
            @AuraEnabled public String HOUSE_NUM1 {get;set;} // ? House Number
            @AuraEnabled public String TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
            @AuraEnabled public String FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number
            @AuraEnabled public String EMAIL      {get;set;} // ? E-Mail Address
            @AuraEnabled public String SIC_CODE   {get;set;} // ? City (different from postal city)
            @AuraEnabled public String MAIL_OK    {get;set;} // ? Mailing Service
            @AuraEnabled public String COUNTRY    {get;set;} // ? Country Key
            @AuraEnabled public String TZONE      {get;set;} // ? Transportation zone to or from which the goods are delivered
            @AuraEnabled public String CONTACT    {get;set;} // ? c/o name
            @AuraEnabled public String SORT2      {get;set;} // ? Search Term 2
            @AuraEnabled public String PO_BOX_LOC {get;set;} // ? PO Box city
            
          }

          public class IF_ORDER_007_Req_T_CONFIG { 
            @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
            @AuraEnabled public String ATNAM    {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATBEZ    {get;set;} // ? Characteristic description
            @AuraEnabled public String ZSEQNO   {get;set;} // ? Sequence Number (3byte)
            @AuraEnabled public String SHOW     {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String READONLY {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
          }

          public class IF_ORDER_007_Req_T_SEL_CONFIG { 
            @AuraEnabled public String POSNR {get;set;} // ? Item number of the SD document
            @AuraEnabled public String MATNR {get;set;} // ? Material Number
            @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value
          }

          public class IF_ORDER_007_Req_T_PRICING { 
            @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT   {get;set;} // ? Description
            @AuraEnabled public String KWERT   {get;set;} // ? Condition value
            @AuraEnabled public String WAERK   {get;set;} // ? SD Document Currency
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
          }

          public class IF_ORDER_007_Req_T_PRICING_ADD { 
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document Currency
            @AuraEnabled public String ZISI_DISPLAY {get;set;} // ? Display
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
            @AuraEnabled public String VISIBLE    {get;set;} // ? Visible
            @AuraEnabled public String VISIBLE_01 {get;set;} // ?                                                             
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
          }

          public class IF_ORDER_007_Req_T_PRICING_RATE { 
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String RATE       {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document Currency
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? I
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String NWAERK     {get;set;} // ? SD Document Currency
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
          }

          public class IF_ORDER_007_Req_T_NOTES { 
            @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
            @AuraEnabled public String SEQNO {get;set;} // ? Seq no
            @AuraEnabled public String TDID {get;set;} // ? Text ID
            @AuraEnabled public String LINE {get;set;} // ? Text Line
          }

          public class IF_ORDER_007_Req_T_FILE { 
            @AuraEnabled public String INT_NO   {get;set;} // ? Natural Number
            @AuraEnabled public String CHECK    {get;set;} // ? Character Field Length 1
            @AuraEnabled public String DOCU_ITEM {get;set;} // ? Sales Document Item
            @AuraEnabled public String VISIBLE  {get;set;} // ? Character Field Length 1
            @AuraEnabled public String FILE_NAME {get;set;} // ? Text field length 200
            @AuraEnabled public String DESCRIPTION {get;set;} // ? Text field length 200
            @AuraEnabled public String FILE_DATA {get;set;} // ? Table analysis: For external table data up to length 1024
            @AuraEnabled public String FILE_NO  {get;set;} // ? Natural Number
            @AuraEnabled public String FILESIZE {get;set;} // ? Numeric field 12
          }

          // NUMBER => IF_NUMBER :  SYSTEM => IF_SYSTEM
          public class IF_ORDER_007_Req_T_RETURN { 
            @AuraEnabled public String TYPE   {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String ID     {get;set;} // ? Message Class
            @AuraEnabled public String IF_NUMBER {get;set;} // ? Message Number
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
            @AuraEnabled public String LOG_NO {get;set;} // ? Application log: log number
            @AuraEnabled public String LOG_MSG_NO {get;set;} // ? Application log: Internal message serial number
            @AuraEnabled public String MESSAGE_V1 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V2 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V3 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V4 {get;set;} // ? Message Variable
            @AuraEnabled public String PARAMETER {get;set;} // ? Parameter Name
            @AuraEnabled public String ROW    {get;set;} // ? Lines in parameter
            @AuraEnabled public String FIELD  {get;set;} // ? Field in parameter
            @AuraEnabled public String IF_SYSTEM {get;set;} // ? Logical system from which message originates
          }

          public class IF_ORDER_007_Req_T_CONDTEXT { 
            @AuraEnabled public String MANDT {get;set;} // ? Client
            @AuraEnabled public String VBELN {get;set;} // ? Sales and Distribution Document Number
            @AuraEnabled public String ZSEQ  {get;set;} // ? seq.
            @AuraEnabled public String KSCHL {get;set;} // ? Condition Type
            @AuraEnabled public String ZZTEXT {get;set;} // ? description
            @AuraEnabled public String ZEMAIL {get;set;} // ? Email
            @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value
            @AuraEnabled public String KWERT {get;set;} // ? Condition value
            @AuraEnabled public String WAERS {get;set;} // ? Currency Key
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
          }

          public class IF_ORDER_007_Req_I_USERINFO { 
            @AuraEnabled public String BNAME  {get;set;} // ? S/F CRM User ID
            @AuraEnabled public String RNAME  {get;set;} // ? User Name in User Master Record
            @AuraEnabled public String HIER   {get;set;} // ? [SS] User Hierrchy (Portal)
            @AuraEnabled public String KUNNR  {get;set;} // ? Customer Number 1
            @AuraEnabled public String LIFNR  {get;set;} // ? Account Number of Vendor or Creditor
            @AuraEnabled public String VKORG  {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG  {get;set;} // ? Distribution Channel
            @AuraEnabled public String SPART  {get;set;} // ? Division
            @AuraEnabled public String WERKS  {get;set;} // ? Plant
            @AuraEnabled public String ARBPL  {get;set;} // ? Work center
            @AuraEnabled public String PARNR  {get;set;} // ? Partner
            @AuraEnabled public String ENAME  {get;set;} // ? Formatted Name of Employee or Applicant
            @AuraEnabled public String KUNN2  {get;set;} // ? Customer Number 1
            @AuraEnabled public String LAND1  {get;set;} // ? Country Key
            @AuraEnabled public String LGORT  {get;set;} // ? Storage Location
            @AuraEnabled public String DF_CHK {get;set;} // ? Default Check
            @AuraEnabled public String CO_CHK {get;set;} // ? corporation check
          }

     /** RESPONSE 
      */     
        public class IF_ORDER_007_Res { 
          public IF_ORDER_007_Res(){}
          @AuraEnabled public String O_VBELN {get;set;} // ? Sales Document
          @AuraEnabled public IF_ORDER_007_Res_O_RETURN O_RETURN {get;set;} 

        }

        public class IF_ORDER_007_Res_O_RETURN {
          public IF_ORDER_007_Res_O_RETURN(){}
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

/** IF_ORDER_002 -> KNUMH	0482721047

    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-002
         * SFDC interface Id    : IF_ORDER_002
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_SEARCH_ORDER_LIST  
         * Description          : Real Sales Order 생성(Factory Order/Option Only Order )
     */
     /** REQUEST 
      */     
        public class IF_ORDER_002_Req {
          public IF_ORDER_002_Req(){
            this.I_ORG = new IF_ORDER_002_Req_I_ORG();
          } 
          @AuraEnabled public String I_ERDAT_F  {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String I_ERDAT_T  {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String I_AUART    {get;set;} // ? Sales Document Type
          @AuraEnabled public String I_USERTYPE {get;set;} // ? USER TYPE(A, B,SPACE)
          @AuraEnabled public IF_ORDER_002_Req_I_ORG             I_ORG      {get;set;}
          @AuraEnabled public List<IF_ORDER_002_Req_T_I_VBELN>   T_I_VBELN  {get;set;}  
        }

        public class IF_ORDER_002_Req_I_ORG { 
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String WERKS {get;set;} // ? Plant
          @AuraEnabled public String ARBPL {get;set;} // ? Work center
          @AuraEnabled public String AMSCCTL {get;set;} // ? M : MMI
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String HIER  {get;set;} // ? [SS] User Hierrchy (Portal)
          @AuraEnabled public String BNAME {get;set;} // ? User Name in User Master Record
        }

        public class IF_ORDER_002_Req_T_I_VBELN{
          @AuraEnabled public String SIGN    {get;set;}
          @AuraEnabled public String OPTION  {get;set;}
          @AuraEnabled public String LOW     {get;set;}
          @AuraEnabled public String HIGH    {get;set;}
        }        

     /** RESPONSE 
      */     
        public class IF_ORDER_002_Res { 
          public IF_ORDER_002_Res(){
            this.O_RETURN      = new IF_ORDER_002_Res_O_RETURN();
            this.T_LIST        = new List<IF_ORDER_002_Res_T_LIST>();
            this.T_INCENTIVE   = new List<IF_ORDER_002_Res_T_INCENTIVE>();
            this.T_KUNNR       = new List<IF_ORDER_002_Res_T_KUNNR>();      
          }
          @AuraEnabled public IF_ORDER_002_Res_O_RETURN O_RETURN              {get;set;}
          @AuraEnabled public List<IF_ORDER_002_Res_T_LIST>      T_LIST       {get;set;} 
          @AuraEnabled public List<IF_ORDER_002_Res_T_INCENTIVE> T_INCENTIVE  {get;set;} 
          @AuraEnabled public List<IF_ORDER_002_Res_T_KUNNR>     T_KUNNR      {get;set;} 
        }

        // NUMBER => IF_NUMBER
        public class IF_ORDER_002_Res_O_RETURN { 
          public IF_ORDER_002_Res_O_RETURN(){}
          @AuraEnabled public String TYPE       {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String ID         {get;set;} // ? Message Class
          @AuraEnabled public String IF_NUMBER     {get;set;} // ? Message Number
          @AuraEnabled public String MESSAGE    {get;set;} // ? Message Text
          @AuraEnabled public String LOG_NO     {get;set;} // ? Application log: log number
          @AuraEnabled public String LOG_MSG_NO {get;set;} // ? Application log: Internal message serial number
          @AuraEnabled public String MESSAGE_V1 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V2 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V3 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V4 {get;set;} // ? Message Variable
        }

        public class IF_ORDER_002_Res_T_LIST { 
          public IF_ORDER_002_Res_T_LIST(){}
          @AuraEnabled public String VBELN {get;set;} // ? Sales Document
          @AuraEnabled public String AUART {get;set;} // ? Sales Document Type
          @AuraEnabled public String BSTDK {get;set;} // ? Customer purchase order date
          @AuraEnabled public String BSTKD {get;set;} // ? Customer purchase order number
          @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
          @AuraEnabled public String MODEL {get;set;} // ? Material Number
          @AuraEnabled public String MATNR {get;set;} // ? Material Number
          @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
          @AuraEnabled public String TOTAL_AMT {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String NETWR_AMT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String TAX_AMT {get;set;} // ? Tax amount in document currency
          @AuraEnabled public String DISC_AMT {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String SURC_AMT {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String VSART {get;set;} // ? Shipping type
          @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String VDATU {get;set;} // ? Requested delivery date
          @AuraEnabled public String KUNNR_AG {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR_RE {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR_RG {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR_WE {get;set;} // ? Customer Number 1
          @AuraEnabled public String KUNNR_ZM {get;set;} // ? Customer Number 1
          @AuraEnabled public String CONFIRM {get;set;} // ? Confirm possible ('X')
          @AuraEnabled public String CHANGE {get;set;} // ? Change possible ('X')
          @AuraEnabled public String ZZSTATUS {get;set;} // ? Approval Status
          @AuraEnabled public String ZSDFUNC {get;set;} // ? Sales Function
          @AuraEnabled public String WRBTR {get;set;} // ? Amount in document currency
          @AuraEnabled public String KNUMV {get;set;} // ? Number of the document condition
          @AuraEnabled public String BUKRS_VF {get;set;} // ? Company code to be billed
          @AuraEnabled public String ABGRU {get;set;} // ? Reason for rejection of quotations and sales orders
          @AuraEnabled public String VSBED {get;set;} // ? Shipping Conditions
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String SUBSEQUENCE {get;set;} // ? Subsequent Document
          @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
          @AuraEnabled public String SERNR {get;set;} // ? Serial number
          @AuraEnabled public String MTART {get;set;} // ? Material Type
          @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
          @AuraEnabled public String MBDAT {get;set;} // ? Material Staging/Availability Date
          @AuraEnabled public String DLVCR {get;set;} // ? Single-Character Indicator
          @AuraEnabled public String APPDATE {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String BMENG {get;set;} // ? Confirmed Quantity
          @AuraEnabled public String VRKME {get;set;} // ? Sales unit
          @AuraEnabled public String ADEPDT {get;set;} // ? Actual departure date
          @AuraEnabled public String AUGRU {get;set;} // ? Order reason (reason for the business transaction)
          @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date
          @AuraEnabled public String ZZSO_SORT {get;set;} // ? Production Related info (Virtual/Real)
          @AuraEnabled public String VBELN_D {get;set;} // ? Sales and Distribution Document Number
          @AuraEnabled public String ERDAT_D {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String OALIAS {get;set;} // ? Export Order Alias(Fixed Name)
          @AuraEnabled public String G_OALIAS {get;set;} // ? Export Order Alias(Given Name)
          @AuraEnabled public String IHREZ {get;set;} // ? Your Reference
          @AuraEnabled public String VSTEL {get;set;} // ? Shipping Point/Receiving Point
          @AuraEnabled public String EDATU {get;set;} // ? Schedule line date
          @AuraEnabled public String FKSTK {get;set;} // ? Billing status
          @AuraEnabled public String CARNO {get;set;} // ? Used Car Management No.
          @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String KUNNR_ZI {get;set;} // ? Related Dealer 필드 -> 1.2v 
          @AuraEnabled public String VBELN_I  {get;set;} // ? Preceding sales and distribution document / Inquiry   -> 1.2v 
          @AuraEnabled public String VBELN_Q  {get;set;} // ? Preceding sales and distribution document / Quotation -> 1.2v
          @AuraEnabled public String ARKTX    {get;set;} // ? Description for sales order item
          @AuraEnabled public String ZDELFLAG {get;set;} // ? 삭제플래그
          @AuraEnabled public String ZRETURNS {get;set;} // ? 반품오더번호    
          @AuraEnabled public String INCO1    {get;set;} // ? Incoterms (Part 1)
          @AuraEnabled public String INCO2    {get;set;} // ? Incoterms (Part 2)
          @AuraEnabled public String KVGR1    {get;set;} // ? Customer group 1
          @AuraEnabled public String KVGR2    {get;set;} // ? Customer group 2
          @AuraEnabled public String KVGR3    {get;set;} // ? Customer group 3
          @AuraEnabled public String PLTYP    {get;set;} // ? Price list type
          @AuraEnabled public String BZIRK    {get;set;} // ? Sales district    
          @AuraEnabled public String LIFSK    {get;set;} 
          @AuraEnabled public String ZZAPPNO  {get;set;}
          @AuraEnabled public String ZZSOCHAN {get;set;}

        }

        public class IF_ORDER_002_Res_T_INCENTIVE { 
          public IF_ORDER_002_Res_T_INCENTIVE(){}
          @AuraEnabled public String VBELN {get;set;} // ? Sales Document
          @AuraEnabled public String PERIOD {get;set;} // ? Creation Month
          @AuraEnabled public String KBETR {get;set;} // ? Rate (condition amount or percentage)
          @AuraEnabled public String WAERS {get;set;} // ? Currency Key
        }

        public class IF_ORDER_002_Res_T_KUNNR {
          public IF_ORDER_002_Res_T_KUNNR(){}
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
        }

/** IF_ORDER_015
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-015
         * SFDC interface Id    : IF_ORDER_015
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_GET_DRAFT_NO_SH  
         * Description          : 내역 : 주문 생성을 위한 Draft 번호 조회
     */
     /** REQUEST 
      */     
        public class IF_ORDER_015_Req { 
          @AuraEnabled public String I_DRAFTNO {get;set;} // ? Doodream Doc. No.(230315~)
          @AuraEnabled public String I_DRAFTDT_FR {get;set;}
          @AuraEnabled public String I_DRAFTDT_TO {get;set;}
        }

     /** RESPONSE 
      */             
        public class IF_ORDER_015_Res { 
          @AuraEnabled public IF_ORDER_015_Res_O_RETURN O_RETURN {get;set;} 
          @AuraEnabled public List<IF_ORDER_015_Res_T_LIST> T_LIST {get;set;} 
        }

        public class IF_ORDER_015_Res_O_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text

        }

        public class IF_ORDER_015_Res_T_LIST { 
          @AuraEnabled public String DOC_NO          {get;set;} // ? Doodream Doc No
          @AuraEnabled public String REQ_ID          {get;set;} // ? Request Empl. AD Account
          @AuraEnabled public String DOC_TYPE        {get;set;} // ? Draft Type
          @AuraEnabled public String DTYP_DESC       {get;set;} // ? Drafte Type
          @AuraEnabled public String DRAFTER         {get;set;} // ? Drafter
          @AuraEnabled public String DRAFTER_ID      {get;set;} // ? Drafter ID
          @AuraEnabled public String DEPTID          {get;set;} // ? Department Code
          @AuraEnabled public String DEPTNAME        {get;set;} // ? Draft Dept.
          @AuraEnabled public String DRAFT_DATE      {get;set;} // ? Draft Date
          @AuraEnabled public String DOC_TITLE       {get;set;} // ? Doc Title
          @AuraEnabled public String APPROVE_DATE    {get;set;} // ? Approved Date
          @AuraEnabled public String REQ_NAME        {get;set;} // ? Requester
          @AuraEnabled public String DOC_URL         {get;set;} // ? String for CRM object link URLs (für RFCs)
          @AuraEnabled public String CPUDT           {get;set;} // ? Day On Which Accounting Document Was Entered
          @AuraEnabled public String CPUTM           {get;set;} // ? Time of Entry
          @AuraEnabled public String DOODREAM_DOC_NO {get;set;} // ? Doodream Doc No
        }

/** IF_ORDER_006
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-006
         * SFDC interface Id    : IF_ORDER_006
         * RFC Name             : ZCRM_SD_CREATE_SO_COMM_USA
         * Description          : Real Sales Order 생성(Commodity)
         * UPATE DATE           : 2025.02.20 => T_ITEM, T_PRICING, T_PRICING_ADD, T_PRICING_RATE, T_PARTNERS
     */
     /** REQUEST 
      */     
        public class IF_ORDER_006_Req { 
          @AuraEnabled public String I_DOC_NUMB       {get;set;}
          @AuraEnabled public String I_DOC_TYPE       {get;set;}
          @AuraEnabled public String I_RDD            {get;set;}
          @AuraEnabled public String I_KUNNR_SOLD     {get;set;}
          @AuraEnabled public String I_KUNNR_SHIP     {get;set;}
          @AuraEnabled public String I_BSTKD          {get;set;}
          @AuraEnabled public String I_LGORT          {get;set;}
          
          @AuraEnabled public IF_ORDER_006_Req_IS_PARTNER   IS_PARTNER {get;set;}
          @AuraEnabled public IF_ORDER_006_Req_IS_HEADER    IS_HEADER  {get;set;}
          @AuraEnabled public IF_ORDER_006_Req_IS_NOTE_ON   IS_NOTE_ON {get;set;}
          @AuraEnabled public IF_ORDER_006_Req_IS_NOTE_SI   IS_NOTE_SI {get;set;}
          @AuraEnabled public IF_ORDER_006_Req_IS_NOTE_CC   IS_NOTE_CC {get;set;}

          @AuraEnabled public List<IF_ORDER_006_Req_T_ITEM>         T_ITEM          {get;set;}
          @AuraEnabled public List<IF_ORDER_006_Req_T_PRICING>      T_PRICING       {get;set;}
          @AuraEnabled public List<IF_ORDER_006_Req_T_PRICING_ADD>  T_PRICING_ADD   {get;set;}
          @AuraEnabled public List<IF_ORDER_006_Req_T_PRICING_RATE> T_PRICING_RATE  {get;set;}
          @AuraEnabled public List<IF_ORDER_006_Req_T_PARTNERS>     T_PARTNERS      {get;set;}
        }
        public class IF_ORDER_006_Req_IS_PARTNER{
          @AuraEnabled public String KUNNR1 {get;set;}
          @AuraEnabled public String KUNNR2 {get;set;}
          @AuraEnabled public String KUNNR3 {get;set;}
          @AuraEnabled public String KUNNR4 {get;set;}
          @AuraEnabled public String KUNNR2_TX {get;set;}
          @AuraEnabled public String KUNNR5 {get;set;}
          @AuraEnabled public String KUNNR4_TX {get;set;}
          @AuraEnabled public String KUNNR3_TX {get;set;}
          @AuraEnabled public String KUNNR5_TX {get;set;}
          @AuraEnabled public String KUNNR1_TX {get;set;}        
        }
        public class IF_ORDER_006_Req_IS_HEADER{
          @AuraEnabled public String VDATU {get;set;}
          @AuraEnabled public String ZTERM {get;set;}
          @AuraEnabled public String KVGR1 {get;set;}
          @AuraEnabled public String KVGR2 {get;set;}
          @AuraEnabled public String KVGR3 {get;set;}
          @AuraEnabled public String ZZWARRPER {get;set;}
          @AuraEnabled public String ZZPERUNIT {get;set;}
          @AuraEnabled public String ZZWARHRS {get;set;}
          @AuraEnabled public String ZZPR_WAR {get;set;}
          @AuraEnabled public String ZZCAPITAL_NO {get;set;} // 1.4?
        }
        public class IF_ORDER_006_Req_IS_NOTE_ON{
          @AuraEnabled public String HEAD {get;set;}
        }
        public class IF_ORDER_006_Req_IS_NOTE_SI{
          @AuraEnabled public String HEAD {get;set;}
        }
        public class IF_ORDER_006_Req_IS_NOTE_CC{
          @AuraEnabled public String HEAD {get;set;}
        }       
        
        public class IF_ORDER_006_Req_T_ITEM{
          @AuraEnabled public String POSNR    {get;set;}
          @AuraEnabled public String UEPOS    {get;set;}
          @AuraEnabled public String MATNR    {get;set;}
          @AuraEnabled public String ARKTX    {get;set;}       
          @AuraEnabled public String KWMENG   {get;set;}   
          @AuraEnabled public String WERKS    {get;set;}
          @AuraEnabled public String PSTYV    {get;set;}
          @AuraEnabled public String KDMAT    {get;set;}
          @AuraEnabled public String VSTEL    {get;set;}
          @AuraEnabled public String REQ_DATE {get;set;}
        }

        public class IF_ORDER_006_Req_T_PRICING{
          @AuraEnabled public String POSNR    {get;set;}
          @AuraEnabled public String KSCHL    {get;set;}
          @AuraEnabled public String VTEXT    {get;set;}
          @AuraEnabled public String KWERT    {get;set;}
          @AuraEnabled public String WAERK    {get;set;}
          @AuraEnabled public String VISIBLE  {get;set;}          
        }

        public class IF_ORDER_006_Req_T_PRICING_ADD{
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
        }

        public class IF_ORDER_006_Req_T_PRICING_RATE{
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
        }
        
        public class IF_ORDER_006_Req_T_PARTNERS{
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
        }        

     /** RESPONSE 
      */             
        public class IF_ORDER_006_Res { 
          @AuraEnabled public String E_VBELN    {get;set;}
          @AuraEnabled public      IF_ORDER_006_Res_O_RETURN           O_RETURN         {get;set;}
          @AuraEnabled public List<IF_ORDER_006_Res_T_RETURN>          T_RETURN         {get;set;}
          @AuraEnabled public List<IF_ORDER_006_Res_T_COND_EX>         T_COND_EX        {get;set;}
          @AuraEnabled public List<IF_ORDER_006_Res_T_PRICING_RETURN>  T_PRICING_RETURN {get;set;}
        }
        public class IF_ORDER_006_Res_O_RETURN {
          @AuraEnabled public String TYPE     {get;set;}
          @AuraEnabled public String CODE     {get;set;}
          @AuraEnabled public String MESSAGE  {get;set;}
        }
        public class IF_ORDER_006_Res_T_RETURN  {
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
        }

        // IF_CASE
        public class IF_ORDER_006_Res_T_COND_EX{
          @AuraEnabled public String ITM_NUMBER       {get;set;}
          @AuraEnabled public String COND_ST_NO       {get;set;}
          @AuraEnabled public String COND_COUNT       {get;set;}
          @AuraEnabled public String COND_TYPE        {get;set;}
          @AuraEnabled public String COND_VALUE       {get;set;}
          @AuraEnabled public String IF_CURRENCY      {get;set;}
          @AuraEnabled public String COND_UNIT        {get;set;}
          @AuraEnabled public String COND_P_UNT       {get;set;}
          @AuraEnabled public String CURR_ISO         {get;set;}
          @AuraEnabled public String CD_UNT_ISO       {get;set;}
          @AuraEnabled public String REFOBJTYPE       {get;set;}
          @AuraEnabled public String REFOBJKEY        {get;set;}
          @AuraEnabled public String REFLOGSYS        {get;set;}
          @AuraEnabled public String APPLICATIO       {get;set;}
          @AuraEnabled public String CONPRICDAT       {get;set;}
          @AuraEnabled public String CALCTYPCON       {get;set;}
          @AuraEnabled public String CONBASEVAL       {get;set;}
          @AuraEnabled public String CONEXCHRAT       {get;set;}
          @AuraEnabled public String NUMCONVERT       {get;set;}
          @AuraEnabled public String DENOMINATO       {get;set;}
          @AuraEnabled public String CONDTYPE         {get;set;}
          @AuraEnabled public String STAT_CON         {get;set;}
          @AuraEnabled public String SCALETYPE        {get;set;}
          @AuraEnabled public String ACCRUALS         {get;set;}
          @AuraEnabled public String CONINVOLST       {get;set;}
          @AuraEnabled public String CONDORIGIN       {get;set;}
          @AuraEnabled public String GROUPCOND        {get;set;}
          @AuraEnabled public String COND_UPDAT       {get;set;}
          @AuraEnabled public String ACCESS_SEQ       {get;set;}
          @AuraEnabled public String CONDCOUNT        {get;set;}
          @AuraEnabled public String ROUNDOFFDI       {get;set;}
          @AuraEnabled public String CONDVALUE        {get;set;}
          @AuraEnabled public String CURRENCY_2       {get;set;}
          @AuraEnabled public String CURR_ISO_2       {get;set;}
          @AuraEnabled public String CONDCNTRL        {get;set;}
          @AuraEnabled public String CONDISACTI       {get;set;}
          @AuraEnabled public String CONDCLASS        {get;set;}
          @AuraEnabled public String FACTBASVAL       {get;set;}
          @AuraEnabled public String SCALEBASIN       {get;set;}
          @AuraEnabled public String SCALBASVAL       {get;set;}
          @AuraEnabled public String UNITMEASUR       {get;set;}
          @AuraEnabled public String ISO_UNIT         {get;set;}
          @AuraEnabled public String CURRENCKEY       {get;set;}
          @AuraEnabled public String CURRENISO        {get;set;}
          @AuraEnabled public String CONDINCOMP       {get;set;}
          @AuraEnabled public String CONDCONFIG       {get;set;}
          @AuraEnabled public String CONDCHAMAN       {get;set;}
          @AuraEnabled public String COND_NO          {get;set;}
          @AuraEnabled public String TAX_CODE         {get;set;}
          @AuraEnabled public String VARCOND          {get;set;}
          @AuraEnabled public String ACCOUNTKEY       {get;set;}
          @AuraEnabled public String ACCOUNT_KE       {get;set;}
          @AuraEnabled public String WT_WITHCD        {get;set;}
          @AuraEnabled public String STRUCTCOND       {get;set;}
          @AuraEnabled public String FACTCONBAS       {get;set;}
          @AuraEnabled public String CONDCOINHD       {get;set;}
          @AuraEnabled public String VCTEXT           {get;set;}
          @AuraEnabled public String MATNR_AC         {get;set;}
          @AuraEnabled public String ZZSQCOD          {get;set;}          
        }

        public class IF_ORDER_006_Res_T_PRICING_RETURN {
          @AuraEnabled public String POSNR {get;set;}
          @AuraEnabled public String KSCHL {get;set;}
          @AuraEnabled public String VTEXT {get;set;}
          @AuraEnabled public String KWERT {get;set;}
          @AuraEnabled public String WAERK {get;set;}
          @AuraEnabled public String VISIBLE {get;set;} 
          @AuraEnabled public String MATNR {get;set;}          
        }

/** IF_ORDER_014
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF-ORDER-014
         * SFDC interface Id    : IF-ORDER-014
         * New I/F              : ZCRM_SD_INCOMING_PLAN_FOR_WEB
         * Description          : 수금 스케쥴 생성(CRM -> ERP)
     */
     /** REQUEST 
      */     
      public class IF_ORDER_014_Req { 
        @AuraEnabled public String I_VKORG      {get;set;}
        @AuraEnabled public String I_VTWEG      {get;set;}
        @AuraEnabled public String I_SPART      {get;set;}
        @AuraEnabled public String I_AUART      {get;set;}
        @AuraEnabled public String I_VBELN      {get;set;}
        @AuraEnabled public String I_BUKRS      {get;set;}
        @AuraEnabled public String I_BDATE      {get;set;}
        @AuraEnabled public String I_IPLAN      {get;set;}
        @AuraEnabled public String I_KUNNR      {get;set;}
        @AuraEnabled public String I_NETWR      {get;set;}
        @AuraEnabled public String I_WAERK      {get;set;}
        @AuraEnabled public String I_HORIZON    {get;set;}
        @AuraEnabled public String I_BUCKET     {get;set;}
        @AuraEnabled public String I_EST_AMT    {get;set;}
        @AuraEnabled public String I_PRI_AMT    {get;set;}

        @AuraEnabled public List<IF_ORDER_014_Req_ITAB> ITAB  {get;set;}
      }
      public class IF_ORDER_014_Req_ITAB {
        @AuraEnabled public String INCOM_CODE   {get;set;}
        @AuraEnabled public String ZTERM        {get;set;}
        @AuraEnabled public String EST_DAT      {get;set;}
        @AuraEnabled public String EST_AMT      {get;set;}
        @AuraEnabled public String ZBD1T        {get;set;}
        @AuraEnabled public String FA_CODE      {get;set;}
        @AuraEnabled public String WAERK        {get;set;}
        @AuraEnabled public String ZZTERM       {get;set;}
      }

   /** RESPONSE 
    */             
      public class IF_ORDER_014_Res { 
        @AuraEnabled public String O_IPLAN    {get;set;}
        @AuraEnabled public String O_MESSAGE  {get;set;}
        @AuraEnabled public List<IF_ORDER_014_Res_O_RETURN>     O_RETURN  {get;set;}
      }
      public class IF_ORDER_014_Res_O_RETURN {
        @AuraEnabled public String TYPE           {get;set;}
        @AuraEnabled public String ID             {get;set;}
        @AuraEnabled public String IF_NUMBER      {get;set;}
        @AuraEnabled public String MESSAGE        {get;set;}
        @AuraEnabled public String LOG_NO         {get;set;}
        @AuraEnabled public String LOG_MSG_NO     {get;set;}
        @AuraEnabled public String MESSAGE_V1     {get;set;}
        @AuraEnabled public String MESSAGE_V2     {get;set;}
        @AuraEnabled public String MESSAGE_V3     {get;set;}
        @AuraEnabled public String MESSAGE_V4     {get;set;}
        @AuraEnabled public String PARAMETER      {get;set;}
        @AuraEnabled public String ROW            {get;set;}
        @AuraEnabled public String FIELD          {get;set;}
        @AuraEnabled public String IF_SYSTEM      {get;set;}
      }

/** IF_ORDER_018
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_018
         * SFDC interface Id    : IF-ORDER-018
         * New I/F              : ZCRM_SD_REIMBURSEMENT_PRICE
         * Description          : Service Reimbursement 조회 - Sales Area, Currency, PKMT, 생성일 입력 후 Reimbursement 조회
     */
     /** REQUEST 
      */
        public class IF_ORDER_018_Req { 
          @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String I_MATNR {get;set;} // ? Material Number
          @AuraEnabled public String I_WAERK {get;set;} // ? SD Document Currency
          @AuraEnabled public String I_WARRANTY {get;set;} // ? Pricing Factor(Warranty) - ZMWA
          @AuraEnabled public String I_WARRANTY1 {get;set;} // ? Pricing Factor(Warranty) - ZMCA
          @AuraEnabled public String I_DATE  {get;set;} // ? Date
          @AuraEnabled public String I_BZIRK {get;set;} // ? Sales district
        }
     /** RESPONSE 
      */
        public class IF_ORDER_018_Res { 
          @AuraEnabled public String O_PRICE {get;set;} // ? Rate (condition amount or percentage)
          @AuraEnabled public String O_PRICE_ZMWA {get;set;} // ? Rate (condition amount or percentage) / i_warranty에 값이 있을 때
          @AuraEnabled public String O_PRICE_ZMCA {get;set;} // ? Rate (condition amount or percentage) / i_warranty1에 값이 있을 때
          @AuraEnabled public String O_WAERK {get;set;} // ? SD Document Currency

          @AuraEnabled public IF_ORDER_018_Res_O_RETURN O_RETURN {get;set;} 

        }

        public class IF_ORDER_018_Res_O_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

/** IF_ORDER_020
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_020
         * SFDC interface Id    : IF-ORDER-020
         * New I/F              : ZCRM_SD_GET_BRANCH_LIST
         * Description          : DNSA Distributor-Distributor간 Related Dealer 조회
     */
     /** REQUEST 
      */ 
        public class IF_ORDER_020_Req { 
            @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String I_KUNNR1 {get;set;} // ? Customer
            @AuraEnabled public String I_KUNNR2 {get;set;} // ? Customer Number 1
            @AuraEnabled public String I_NAME1 {get;set;} // ? Name 1
            @AuraEnabled public String I_REGIO {get;set;} // ? Region (State, Province, County)
            @AuraEnabled public String I_ORT01 {get;set;} // ? City
            @AuraEnabled public String I_PSTLZ {get;set;} // ? Postal Code
        }

     /** RESPONSE    
      */ 
        public class IF_ORDER_020_Res { 
        @AuraEnabled public IF_ORDER_020_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_ORDER_020_Res_T_LIST> T_LIST {get;set;} 
        }

        public class IF_ORDER_020_Res_O_RETURN { 
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

        public class IF_ORDER_020_Res_T_LIST { 
        @AuraEnabled public String KUNN1 {get;set;} // ? Ship-to party
        @AuraEnabled public String NAME1 {get;set;} // ? Name 1
        @AuraEnabled public String KUNN2 {get;set;} // ? Ship-to party
        @AuraEnabled public String NAME2 {get;set;} // ? Name 1
        @AuraEnabled public String ORT01 {get;set;} // ? City
        @AuraEnabled public String PSTLZ {get;set;} // ? Postal Code
        @AuraEnabled public String REGIO {get;set;} // ? Region (State, Province, County)
        @AuraEnabled public String SORTL {get;set;} // ? Sort field
        @AuraEnabled public String STRAS {get;set;} // ? House number and street
        @AuraEnabled public String TELF1 {get;set;} // ? First telephone number
        @AuraEnabled public String TELFX {get;set;} // ? Fax Number
        @AuraEnabled public String LAND1 {get;set;} // ? Country Key
        @AuraEnabled public String LANDX {get;set;} // ? Country Name
        }

/** IF_ORDER_016
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_016
         * SFDC interface Id    : IF-ORDER-016
         * New I/F              : ZCRM_SD_PROMOTION_DISP
         * Description          : 프로모션 데이터 조회 (ERP -> CRM)
     */
     /** REQUEST 
      */         
          public class IF_ORDER_016_Req { 
            @AuraEnabled public String I_VKORG    {get;set;} // ? Sales Organization
            @AuraEnabled public String I_VTWEG    {get;set;} // ? Distribution Channel
            @AuraEnabled public String I_WAERK    {get;set;} // ? SD Document Currency
            @AuraEnabled public String I_VALID_ON {get;set;} // ? Valid on
          }

     /** RESPONSE
      */                   
          public class IF_ORDER_016_Res { 
            @AuraEnabled public IF_ORDER_016_Res_O_RETURN O_RETURN {get;set;} 
            @AuraEnabled public List<IF_ORDER_016_Res_T_O_ZSSY> T_O_ZSSY {get;set;} 
            @AuraEnabled public List<IF_ORDER_016_Res_T_O_ZSSX> T_O_ZSSX {get;set;} 
          }
      
          public class IF_ORDER_016_Res_O_RETURN { 
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
          }
      
          public class IF_ORDER_016_Res_T_O_ZSSY { 
            @AuraEnabled public String KSCHL {get;set;} // ? Condition type
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
            @AuraEnabled public String WAERK {get;set;} // ? SD Document
            @AuraEnabled public String VARCOND {get;set;} // ? Variant condition
            @AuraEnabled public String VCTEXT {get;set;} // ? Description 
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition
            @AuraEnabled public String KONWA {get;set;} // ? Rate unit
            @AuraEnabled public String DATAB {get;set;} //
            @AuraEnabled public String DATBI {get;set;} //
          } 
      
          public class IF_ORDER_016_Res_T_O_ZSSX { 
            @AuraEnabled public String KSCHL {get;set;} // ? Condition type
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
            @AuraEnabled public String WAERK {get;set;} // ? SD Document
            @AuraEnabled public String VARCOND {get;set;} // ? Variant condition
            @AuraEnabled public String VCTEXT {get;set;} // ? Description 
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition
            @AuraEnabled public String KONWA {get;set;} // ? Rate unit
            @AuraEnabled public String DATAB {get;set;} // ?
            @AuraEnabled public String DATBI {get;set;} // ?            
          }
      
/** IF_ORDER_017
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_017
         * SFDC interface Id    : IF-ORDER-017
         * New I/F              : ZCRM_SD_WARRANTY_DISP
         * Description          : Warranty 데이터 조회 (ERP -> CRM)
     */
     /** REQUEST 
      */             
          public class IF_ORDER_017_Req { 
            @AuraEnabled public List<IF_ORDER_017_Req_T_VKORG> T_VKORG {get;set;} 
          }
      
          public class IF_ORDER_017_Req_T_VKORG { 
            @AuraEnabled public String KAPPL {get;set;} // ? Application
            @AuraEnabled public String KSCHL {get;set;} // ? Condition type
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
            @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
            @AuraEnabled public String ZZKVGR4 {get;set;} // ? Customer group 4
            @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
            @AuraEnabled public String MATNR {get;set;} // ? Material Number
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition amount or percentage) where no scale exists
          }
      
     /** RESPONSE 
      */      
          public class IF_ORDER_017_Res { 
            @AuraEnabled public List<IF_ORDER_017_Res_T_DATA> T_DATA {get;set;} 
          }
      
          public class IF_ORDER_017_Res_T_DATA { 
            @AuraEnabled public String KSCHL {get;set;} // ? Condition type
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String SPART {get;set;} // ? Division
            @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
            @AuraEnabled public String ZZPR_WAR {get;set;} // ? Pricing Factor(Warranty)
            @AuraEnabled public String PERCENT {get;set;} // ? Rate (condition amount or percentage) where no scale exists
            @AuraEnabled public String DATBI {get;set;} // ? Validity end date of the condition record
            @AuraEnabled public String DATAB {get;set;} // ? Validity start date of the condition record
            @AuraEnabled public String ZZWARRPER {get;set;} // ? Warranty Period
            @AuraEnabled public String ZZPERUNIT {get;set;} // ? Warranty Indicator
            @AuraEnabled public String ZZWARHRS {get;set;} // ? Warranty Hours
            @AuraEnabled public String ZZCOVERAGE {get;set;} // ? Warranty - Coverage
            @AuraEnabled public String ZZCOVERAGE_B {get;set;} // ? Warranty - Coverage (Added)
            @AuraEnabled public String BZIRK {get;set;} // ? Sales district
            @AuraEnabled public String KNUMH {get;set;} // ? Condition record number
            @AuraEnabled public String KOPOS {get;set;} // ? Sequential number of the condition
          }
      
/** IF_ORDER_021
    */  
    /**
         * Apex Class           : IF_ERP_Order
         * Wrapper Class        : IF_ERP_Order_Classes
         * Wrapper Name         : IF_ORDER_021
         * SFDC interface Id    : IF-ORDER-021
         * New I/F              : ZCRM_SD_SO_CV_MANAGE
         * Description          : Order CV 변환
         * IF_CURRENCY
     */
  /** REQUEST 
        */    
        public class IF_ORDER_021_Req { 
          @AuraEnabled public String I_VBELN {get;set;} // ? Sales Document Number

          @AuraEnabled public List<IF_ORDER_021_Req_T_VARIANT> T_VARIANT {get;set;} 
      }
      public class IF_ORDER_021_Req_T_VARIANT { 
          @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
          @AuraEnabled public String ATINN {get;set;} // ? Internal characteristic
          @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
          @AuraEnabled public String ATBEZ {get;set;} // ? Characteristic description
          @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value
          @AuraEnabled public String ATWTB {get;set;} // ? Characteristic value description
      }

  /** RESPONSE 
   */            
      public class IF_ORDER_021_Res { 
          @AuraEnabled public String O_VBELN {get;set;} // ? Sales Document Number

          @AuraEnabled public IF_ORDER_021_Res_O_RETURN O_RETURN {get;set;} 
          @AuraEnabled public IF_ORDER_021_Res_O_NET_VALUE O_NET_VALUE {get;set;} 
          @AuraEnabled public List<IF_ORDER_021_Res_OT_VARIANT_ERR> OT_VARIANT_ERR {get;set;} 
          @AuraEnabled public List<IF_ORDER_021_Res_T_COND_EX> T_COND_EX {get;set;} 
          @AuraEnabled public List<IF_ORDER_021_Res_T_PRICING> T_PRICING {get;set;} 
      }

      public class IF_ORDER_021_Res_O_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
      }

      public class IF_ORDER_021_Res_O_NET_VALUE { 
          @AuraEnabled public String NETPR     {get;set;} // ? Net price
          @AuraEnabled public String NETWR     {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String MWST      {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WAERK     {get;set;} // ? SD Document Currency
          @AuraEnabled public String NETWR_CH  {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String NETWR_CC06 {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String CB01_INFO1 {get;set;} // ? Add Info 1
          @AuraEnabled public String CB01_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
          @AuraEnabled public String CI06_INFO1 {get;set;} // ? Add Info 1
          @AuraEnabled public String CI06_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
          @AuraEnabled public String CC06_INFO1 {get;set;} // ? Add Info 1
          @AuraEnabled public String CC06_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
          @AuraEnabled public String LP_BM     {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String LP_OP     {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String LP_SUM    {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String PROMO_PRC {get;set;} // ? Net Value in Document Currency
      }

      public class IF_ORDER_021_Res_OT_VARIANT_ERR { 
          @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
          @AuraEnabled public String ATINN {get;set;} // ? Internal characteristic
          @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
          @AuraEnabled public String ATBEZ {get;set;} // ? Characteristic description
          @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value
          @AuraEnabled public String ATWTB {get;set;} // ? Characteristic value description
      }

      public class IF_ORDER_021_Res_T_COND_EX { 
          @AuraEnabled public String ITM_NUMBER {get;set;} // ? Condition item number
          @AuraEnabled public String COND_ST_NO {get;set;} // ? Step number
          @AuraEnabled public String COND_COUNT {get;set;} // ? Condition counter
          @AuraEnabled public String COND_TYPE {get;set;} // ? Condition type
          @AuraEnabled public String COND_VALUE {get;set;} // ? Condition rate`
          @AuraEnabled public String IF_CURRENCY {get;set;} // ? Currency Key
          @AuraEnabled public String COND_UNIT {get;set;} // ? Condition unit
          @AuraEnabled public String COND_P_UNT {get;set;} // ? Condition pricing unit
          @AuraEnabled public String CURR_ISO {get;set;} // ? ISO code currency
          @AuraEnabled public String CD_UNT_ISO {get;set;} // ? Condition unit of measure in UoM
          @AuraEnabled public String REFOBJTYPE {get;set;} // ? Object Type
          @AuraEnabled public String REFOBJKEY {get;set;} // ? Object key
          @AuraEnabled public String REFLOGSYS {get;set;} // ? Logical system
          @AuraEnabled public String APPLICATIO {get;set;} // ? Application
          @AuraEnabled public String CONPRICDAT {get;set;} // ? Condition pricing date
          @AuraEnabled public String CALCTYPCON {get;set;} // ? Calculation type for condition
          @AuraEnabled public String CONBASEVAL {get;set;} // ? Condition base value
          @AuraEnabled public String CONEXCHRAT {get;set;} // ? Condition exchange rate for conversion to local currency
          @AuraEnabled public String NUMCONVERT {get;set;} // ? Numerator for converting condition units to base units
          @AuraEnabled public String DENOMINATO {get;set;} // ? Denominator for converting condition units to base units
          @AuraEnabled public String CONDTYPE {get;set;} // ? Condition category (examples: tax, freight, price, cost)
          @AuraEnabled public String STAT_CON {get;set;} // ? Condition is used for statistics
          @AuraEnabled public String SCALETYPE {get;set;} // ? Scale Type
          @AuraEnabled public String ACCRUALS {get;set;} // ? Condition is Relevant for Accrual  (e.g. Freight)
          @AuraEnabled public String CONINVOLST {get;set;} // ? Condition for invoice list
          @AuraEnabled public String CONDORIGIN {get;set;} // ? Origin of the condition
          @AuraEnabled public String GROUPCOND {get;set;} // ? Group condition
          @AuraEnabled public String COND_UPDAT {get;set;} // ? Condition update
          @AuraEnabled public String ACCESS_SEQ {get;set;} // ? Access sequence - Access number
          @AuraEnabled public String CONDCOUNT {get;set;} // ? Sequential number of the condition
          @AuraEnabled public String ROUNDOFFDI {get;set;} // ? Currency amount for BAPIS (with 9 decimal places)
          @AuraEnabled public String CONDVALUE {get;set;} // ? Condition value
          @AuraEnabled public String CURRENCY_2 {get;set;} // ? SD Document Currency
          @AuraEnabled public String CURR_ISO_2 {get;set;} // ? ISO code currency
          @AuraEnabled public String CONDCNTRL {get;set;} // ? Condition control
          @AuraEnabled public String CONDISACTI {get;set;} // ? Condition is inactive
          @AuraEnabled public String CONDCLASS {get;set;} // ? Condition class
          @AuraEnabled public String FACTBASVAL {get;set;} // ? Factor for condition base value
          @AuraEnabled public String SCALEBASIN {get;set;} // ? Scale basis indicator
          @AuraEnabled public String SCALBASVAL {get;set;} // ? Scale base value of the condition
          @AuraEnabled public String UNITMEASUR {get;set;} // ? Condition scale unit of measure
          @AuraEnabled public String ISO_UNIT {get;set;} // ? ISO code for unit of measurement
          @AuraEnabled public String CURRENCKEY {get;set;} // ? Scale currency
          @AuraEnabled public String CURRENISO {get;set;} // ? ISO code currency
          @AuraEnabled public String CONDINCOMP {get;set;} // ? Condition for inter-company billing
          @AuraEnabled public String CONDCONFIG {get;set;} // ? Condition for configuration
          @AuraEnabled public String CONDCHAMAN {get;set;} // ? Condition changed manually
          @AuraEnabled public String COND_NO {get;set;} // ? Condition record number
          @AuraEnabled public String TAX_CODE {get;set;} // ? Sales Tax Code
          @AuraEnabled public String VARCOND {get;set;} // ? Variant condition
          @AuraEnabled public String ACCOUNTKEY {get;set;} // ? Account key
          @AuraEnabled public String ACCOUNT_KE {get;set;} // ? Account key - accruals / provisions
          @AuraEnabled public String WT_WITHCD {get;set;} // ? Withholding tax code
          @AuraEnabled public String STRUCTCOND {get;set;} // ? Structure condition
          @AuraEnabled public String FACTCONBAS {get;set;} // ? Factor for condition basis (period)
          @AuraEnabled public String CONDCOINHD {get;set;} // ? Condition counter for (header conditions)
          @AuraEnabled public String VCTEXT  {get;set;} // ? Description
          @AuraEnabled public String MATNR_AC {get;set;} // ? Material Number
          @AuraEnabled public String ZZSQCOD {get;set;} // ? SQ Code
      }

      public class IF_ORDER_021_Res_T_PRICING { 
          @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
          @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
          @AuraEnabled public String VTEXT   {get;set;} // ? Description
          @AuraEnabled public String KWERT   {get;set;} // ? Condition value
          @AuraEnabled public String WAERK   {get;set;} // ? SD Document Currency
          @AuraEnabled public String VISIBLE {get;set;} // ? Visible
      }

/** IF_ORDER_022
    */  
    /**
         * SFDC interface Id    : IF-ORDER-022
         * RFC                  : ZCRM_SD_GET_PSO_PRICE
     */
  /** REQUEST 
        */

        public class IF_ORDER_022_Req{
        public IF_ORDER_022_Req(){}

        @AuraEnabled public String I_FROM_DATE  {get;set;}
        @AuraEnabled public String I_TO_DATE    {get;set;}        
      }          

      public class IF_ORDER_022_Res{
        public IF_ORDER_022_Res(){}

        @AuraEnabled public   IF_ORDER_022_Res_O_RETURN              O_RETURN  {get;set;}
        @AuraEnabled public   List<IF_ORDER_022_Res_OT_NET_VALUE>    OT_NET_VALUE{get;set;}
      }

      public class IF_ORDER_022_Res_O_RETURN{
        public IF_ORDER_022_Res_O_RETURN(){}

          @AuraEnabled public String TYPE {get;set;}
          @AuraEnabled public String CODE {get;set;}
          @AuraEnabled public String MESSAGE  {get;set;}        
      }

      public class IF_ORDER_022_Res_OT_NET_VALUE{
          public IF_ORDER_022_Res_OT_NET_VALUE(){}
          @AuraEnabled public String VBELN {get;set;}
          @AuraEnabled public String AUART {get;set;}
          @AuraEnabled public String NETWR {get;set;}
          @AuraEnabled public String MWST {get;set;}
          @AuraEnabled public String WAERK {get;set;}        
      }


}