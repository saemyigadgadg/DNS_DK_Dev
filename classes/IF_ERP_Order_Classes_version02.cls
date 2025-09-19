public with sharing class IF_ERP_Order_Classes_version02 {
    public IF_ERP_Order_Classes_version02() {}

// ** IF-ORDER-005				
/**
  */
  /**
         * Wrapper Name         : IF_ORDER_005
         * SFDC interface Id    : IF-ORDER-005
         * AS-IS RFC            : Z_SD_GET_PRICING_PROCESS_ME
         * New I/F              : ZCRM_SD_GET_PRICING_PROCESS_ME
         * Description          : Multi Model에 대한 Pricing 정보를 시뮬레이션
         * CAUTION              : DEFAULT, CURRENCY, NUMBER, SYSTEM
  */    
    // ** REQUEST
    /**
        */        
        public class IF_ORDER_005_Req { 
            public IF_ORDER_005_Req(){}
            @AuraEnabled public String I_VBELN_VA   {get;set;} // ? Sales Document
            @AuraEnabled public String I_PRICE_DATE {get;set;} // ? Date for pricing and exchange rate
      
            @AuraEnabled public IF_ORDER_005_Req_I_HEAD               I_HEAD {get;set;} 
            @AuraEnabled public IF_ORDER_005_Req_I_GENERAL            I_GENERAL {get;set;} 
            @AuraEnabled public IF_ORDER_005_Req_I_PARTNER            I_PARTNER {get;set;} 
            @AuraEnabled public IF_ORDER_005_Req_I_WARRANT_OPT        I_WARRANT_OPT {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_ITEM>         T_ITEM {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_CONFIG>       T_CONFIG {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_SUB>          T_SUB {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_PRICING>      T_PRICING {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_PRICING_ADD>  T_PRICING_ADD {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_PRICING_RATE> T_PRICING_RATE {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_OPTION>       T_OPTION {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_PRICING_EX>   T_PRICING_EX {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_COND_EX>      T_COND_EX {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_BM_DESC>      T_BM_DESC {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Req_T_MULTICOND>    T_MULTICOND {get;set;} 
            // @AuraEnabled public IF_ORDER_005_Req_T_PRICING_ADD T_PRICING_ADD {get;set;} 
      
          }
      
          public class IF_ORDER_005_Req_I_HEAD { 
            public IF_ORDER_005_Req_I_HEAD(){}
  
            @AuraEnabled public String AUART {get;set;} // ? Sales Document Type
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
            @AuraEnabled public String SPART {get;set;} // ? Division
            @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
            @AuraEnabled public String KUNAG {get;set;} // ? Customer Number 1
            @AuraEnabled public String BEZEI {get;set;} // ? Description
            @AuraEnabled public String VKORG_T {get;set;} // ? Name
            @AuraEnabled public String VTWEG_T {get;set;} // ? Name
            @AuraEnabled public String SPART_T {get;set;} // ? Name
            @AuraEnabled public String KUNNR_NAME {get;set;} // ? Name 1
            @AuraEnabled public String KUNNR_STREET {get;set;} // ? House number and street
            @AuraEnabled public String KUNAG_NAME {get;set;} // ? Name 1
            @AuraEnabled public String KUNAG_STREET {get;set;} // ? House number and street
            @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
            @AuraEnabled public String VKBUR_TX {get;set;} // ? Name of the controlling area
            @AuraEnabled public String VSBED {get;set;} // ? Shipping Conditions
            @AuraEnabled public String IHREZ {get;set;} // ? Your Reference
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String AUDAT {get;set;} // ? Document Date (Date Received/Sent)
            @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
            @AuraEnabled public String BUKRS {get;set;} // ? Company Code
      
        }
      
          public class IF_ORDER_005_Req_I_GENERAL { 
            public IF_ORDER_005_Req_I_GENERAL(){}
  
            @AuraEnabled public String BSTNK    {get;set;} // ? Customer purchase order number
            @AuraEnabled public String VDATU    {get;set;} // ? Requested delivery date
            @AuraEnabled public String INCO1    {get;set;} // ? Incoterms (Part 1)
            @AuraEnabled public String INCO2    {get;set;} // ? Incoterms (Part 2)
            @AuraEnabled public String AUGRU    {get;set;} // ? Order reason (reason for the business transaction)
            @AuraEnabled public String ABRVW    {get;set;} // ? Usage Indicator
            @AuraEnabled public String BZIRK    {get;set;} // ? Sales district
            @AuraEnabled public String WAERK    {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String WERK     {get;set;} // ? Delivering Plant (Own or External)
            @AuraEnabled public String BZIRK_TX {get;set;} // ? Sales district Txt
            @AuraEnabled public String WAERK_TX {get;set;} // ? IF_CURRENCY Txt
            @AuraEnabled public String AUGRU_TX {get;set;} // ? Description
            @AuraEnabled public String REP_NAME {get;set;} // ? Name of Representative
            @AuraEnabled public String EXPORT_DATE {get;set;} // ? Date
            @AuraEnabled public String PLTYP    {get;set;} // ? Price list type
            @AuraEnabled public String ZZSQNO   {get;set;} // ? Seqeunce Number
            @AuraEnabled public String ZZTECHARG {get;set;} // ? Tech Agreemnet Number
            @AuraEnabled public String ZTERM    {get;set;} // ? Terms of Payment Key
            @AuraEnabled public String ZSDFUNC  {get;set;} // ? Sales Function
            @AuraEnabled public String ZSDFUNC_TX {get;set;} // ? Function Txt
            @AuraEnabled public String ZZREP_VKBUR {get;set;} // ? Responsible of office
            @AuraEnabled public String ZZREP_VKBUR_TX {get;set;} // ? Text (20 Characters)
            @AuraEnabled public String ZZSQITEM {get;set;} // ? SQ Item
            @AuraEnabled public String ZPLAN_DT {get;set;} // ? Date
      
        }
      
          public class IF_ORDER_005_Req_I_PARTNER { 
            public IF_ORDER_005_Req_I_PARTNER(){}
  
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
      
          public class IF_ORDER_005_Req_I_WARRANT_OPT { 
            public IF_ORDER_005_Req_I_WARRANT_OPT(){}
  
            @AuraEnabled public String ZZWARRPER    {get;set;} // ? Warranty Period
            @AuraEnabled public String ZZWARHRS     {get;set;} // ? Warranty Hours
            @AuraEnabled public String ZZPR_WAR     {get;set;} // ? Pricing Factor(Warranty)
            @AuraEnabled public String CONCATE      {get;set;} // ? Concate Txt
            @AuraEnabled public String ZZCOVERAGE   {get;set;} // ? Warranty - Coverage
            @AuraEnabled public String ZZCOVERAGE_B {get;set;} // ? Warranty - Coverage (Added)
      
        }
      
          public class IF_ORDER_005_Req_T_ITEM { 
            public IF_ORDER_005_Req_T_ITEM(){}
  
            @AuraEnabled public String POSNR    {get;set;} // ? Item number of the SD document
            @AuraEnabled public String MATNR    {get;set;} // ? Material Number
            @AuraEnabled public String ARKTX    {get;set;} // ? Short text for sales order item
            @AuraEnabled public String KWMENG   {get;set;} // ? Cumulative Order Quantity in Sales Units
            @AuraEnabled public String VRKME    {get;set;} // ? Sales unit
            @AuraEnabled public String NETPR    {get;set;} // ? Net price
            @AuraEnabled public String WAERK    {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String WERKS    {get;set;} // ? Plant (Own or External)
            @AuraEnabled public String CHECK    {get;set;} // ? Check Flag
            @AuraEnabled public String EQUIP_CHECK {get;set;} // ? Equip Check Flag
            @AuraEnabled public String MWST     {get;set;} // ? Net price
            @AuraEnabled public String PSTYV    {get;set;} // ? Sales document item category
            @AuraEnabled public String NOTE     {get;set;} // ? Note Long Txt
            @AuraEnabled public String NET      {get;set;} // ? Net price
            @AuraEnabled public String VTEXT    {get;set;} // ? Description
            @AuraEnabled public String STDPD    {get;set;} // ? Configurable material
            @AuraEnabled public String ZZDEALDT {get;set;} // ? Dealer's sales date
            @AuraEnabled public String ZZSQCOD {get;set;} // ? SQ Code

      
        }
      
          public class IF_ORDER_005_Req_T_CONFIG { 
            public IF_ORDER_005_Req_T_CONFIG(){}
  
            @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
            @AuraEnabled public String ATNAM    {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATBEZ    {get;set;} // ? Characteristic description
            @AuraEnabled public String ZSEQNO   {get;set;} // ? Sequence Number (3byte)
            @AuraEnabled public String SHOW     {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String READONLY {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
      
        }
      
          public class IF_ORDER_005_Req_T_SUB {
            public IF_ORDER_005_Req_T_SUB(){}
            
            public IF_ORDER_005_Req_T_SUB(
              String POSNR,
              String ATNAM,
              String ATBEZ,
              String ATWRT,
              String ATWTB,
              String ZSEQNO
          ) {
              this.POSNR = POSNR; // Sales Document Item
              this.ATNAM = ATNAM; // Characteristic Name
              this.ATBEZ = ATBEZ; // Characteristic description
              this.ATWRT = ATWRT; // Characteristic Value
              this.ATWTB = ATWTB; // Characteristic value description
              this.ZSEQNO = ZSEQNO; // Sequence Number (3byte)
          }
            @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
            @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATBEZ {get;set;} // ? Characteristic description
            @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value
            @AuraEnabled public String ATWTB {get;set;} // ? Characteristic value description
            @AuraEnabled public String IF_DEFAULT {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String ZSEQNO {get;set;} // ? Sequence Number (3byte)
            @AuraEnabled public String SHOW {get;set;} // ? Single-Character Indicator
      
        }
      
          public class IF_ORDER_005_Req_T_PRICING { 
            public IF_ORDER_005_Req_T_PRICING(){}
  
            @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT   {get;set;} // ? Description
            @AuraEnabled public String KWERT   {get;set;} // ? Condition value
            @AuraEnabled public String WAERK   {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
      
        }
      
          public class IF_ORDER_005_Req_T_PRICING_ADD { 
            public IF_ORDER_005_Req_T_PRICING_ADD(){}
  
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String ZISI_DISPLAY {get;set;} // ? Display
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
            @AuraEnabled public String VISIBLE    {get;set;} // ? Visible
            @AuraEnabled public String VISIBLE_01 {get;set;} // ?                                                             
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
      
        }
      
          public class IF_ORDER_005_Req_T_PRICING_RATE { 
            public IF_ORDER_005_Req_T_PRICING_RATE(){}
            
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String RATE       {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String NWAERK     {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
      
      
        }
      
          public class IF_ORDER_005_Req_T_OPTION { 
            public IF_ORDER_005_Req_T_OPTION(){}
  
            @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT   {get;set;} // ? Description
            @AuraEnabled public String KWERT   {get;set;} // ? Condition value
            @AuraEnabled public String WAERK   {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
      
        }
      
          public class IF_ORDER_005_Req_T_PRICING_EX { 
            public IF_ORDER_005_Req_T_PRICING_EX(){}
  
            @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT {get;set;} // ? Description
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition amount or percentage)
            @AuraEnabled public String KWERT {get;set;} // ? Condition value
            @AuraEnabled public String WAERK {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
            @AuraEnabled public String GUBUN {get;set;} // ? Condition Type Gubun Flag
      
        }
      
          public class IF_ORDER_005_Req_T_COND_EX { 
            public IF_ORDER_005_Req_T_COND_EX(){}
  
            @AuraEnabled public String ITM_NUMBER {get;set;} // ? Condition item number
            @AuraEnabled public String COND_ST_NO {get;set;} // ? Step number
            @AuraEnabled public String COND_COUNT {get;set;} // ? Condition counter
            @AuraEnabled public String COND_TYPE {get;set;} // ? Condition type
            @AuraEnabled public String COND_VALUE {get;set;} // ? Condition rate
            @AuraEnabled public String IF_CURRENCY {get;set;} // ? IF_CURRENCY Key
            @AuraEnabled public String COND_UNIT {get;set;} // ? Condition unit
            @AuraEnabled public String COND_P_UNT {get;set;} // ? Condition pricing unit
            @AuraEnabled public String CURR_ISO {get;set;} // ? ISO code IF_CURRENCY
            @AuraEnabled public String CD_UNT_ISO {get;set;} // ? Condition unit of measure in UoM
            @AuraEnabled public String REFOBJTYPE {get;set;} // ? Object Type
            @AuraEnabled public String REFOBJKEY {get;set;} // ? Object key
            @AuraEnabled public String REFLOGSYS {get;set;} // ? Logical system
            @AuraEnabled public String APPLICATIO {get;set;} // ? Application
            @AuraEnabled public String CONPRICDAT {get;set;} // ? Condition pricing date
            @AuraEnabled public String CALCTYPCON {get;set;} // ? Calculation type for condition
            @AuraEnabled public String CONBASEVAL {get;set;} // ? Condition base value
            @AuraEnabled public String CONEXCHRAT {get;set;} // ? Condition exchange rate for conversion to local IF_CURRENCY
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
            @AuraEnabled public String ROUNDOFFDI {get;set;} // ? IF_CURRENCY amount for BAPIS (with 9 decimal places)
            @AuraEnabled public String CONDVALUE {get;set;} // ? Condition value
            @AuraEnabled public String IF_CURRENCY_2 {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String CURR_ISO_2 {get;set;} // ? ISO code IF_CURRENCY
            @AuraEnabled public String CONDCNTRL {get;set;} // ? Condition control
            @AuraEnabled public String CONDISACTI {get;set;} // ? Condition is inactive
            @AuraEnabled public String CONDCLASS {get;set;} // ? Condition class
            @AuraEnabled public String FACTBASVAL {get;set;} // ? Factor for condition base value
            @AuraEnabled public String SCALEBASIN {get;set;} // ? Scale basis indicator
            @AuraEnabled public String SCALBASVAL {get;set;} // ? Scale base value of the condition
            @AuraEnabled public String UNITMEASUR {get;set;} // ? Condition scale unit of measure
            @AuraEnabled public String ISO_UNIT {get;set;} // ? ISO code for unit of measurement
            @AuraEnabled public String CURRENCKEY {get;set;} // ? Scale IF_CURRENCY
            @AuraEnabled public String CURRENISO {get;set;} // ? ISO code IF_CURRENCY
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
            @AuraEnabled public String MATNR_AC {get;set;} // ? Description
            @AuraEnabled public String ZZSQCOD {get;set;} // ? Description


      
        }
      
          public class IF_ORDER_005_Req_T_BM_DESC { 
            public IF_ORDER_005_Req_T_BM_DESC(){}
            
            @AuraEnabled public String TDFORMAT {get;set;} // ? Tag column
            @AuraEnabled public String TDLINE {get;set;} // ? Text Line
      
        }
      
          public class IF_ORDER_005_Req_T_MULTICOND { 
            public IF_ORDER_005_Req_T_MULTICOND(){}
  
            @AuraEnabled public String CHAK  {get;set;} // ? Control activate
            @AuraEnabled public String VARCOND {get;set;} // ? Variant condition
            @AuraEnabled public String KNUMH {get;set;} // ? Condition record number
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition amount or percentage)
            @AuraEnabled public String KWERT {get;set;} // ? Condition value
            @AuraEnabled public String WAERK {get;set;} // ? SD Document IF_CURRENCY
      
        }
      
    // ** RESPONSE
    /**
        */              
          public class IF_ORDER_005_Res {
            public IF_ORDER_005_Res(){}
  
            @AuraEnabled public String O_DRAFT_NO {get;set;} // ? Draft No flag ; 'X' = necessary
      
            @AuraEnabled public IF_ORDER_005_Res_O_NET_VALUE  O_NET_VALUE {get;set;} 
            @AuraEnabled public IF_ORDER_005_Res_O_NET_VALUE2 O_NET_VALUE2 {get;set;} 
            @AuraEnabled public IF_ORDER_005_Res_O_RETURN     O_RETURN {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_ITEM>         T_ITEM {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_CONFIG>       T_CONFIG {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_SUB>          T_SUB {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_PRICING>      T_PRICING {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_PRICING_ADD>  T_PRICING_ADD {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_PRICING_RATE> T_PRICING_RATE {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_OPTION>       T_OPTION {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_PRICING_EX>   T_PRICING_EX {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_COND_EX>      T_COND_EX {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_BM_DESC>      T_BM_DESC {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_MULTICOND>    T_MULTICOND {get;set;} 
            @AuraEnabled public List<IF_ORDER_005_Res_T_RETURN>       T_RETURN {get;set;} 
            
      
          }
          public class IF_ORDER_005_Res_O_NET_VALUE2 { 
            public IF_ORDER_005_Res_O_NET_VALUE2(){}
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

          public class IF_ORDER_005_Res_O_NET_VALUE { 
            public IF_ORDER_005_Res_O_NET_VALUE(){}
  
            @AuraEnabled public String NETPR     {get;set;} // ? Net price
            @AuraEnabled public String NETWR     {get;set;} // ? Net Value in Document IF_CURRENCY
            @AuraEnabled public String MWST      {get;set;} // ? Net Value in Document IF_CURRENCY
            @AuraEnabled public String WAERK     {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String NETWR_CH  {get;set;} // ? Net Value in Document IF_CURRENCY
            @AuraEnabled public String NETWR_CC06 {get;set;} // ? Net Value in Document IF_CURRENCY
            @AuraEnabled public String CB01_INFO1 {get;set;} // ? Add Info 1
            @AuraEnabled public String CB01_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
            @AuraEnabled public String CI06_INFO1 {get;set;} // ? Add Info 1
            @AuraEnabled public String CI06_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
            @AuraEnabled public String CC06_INFO1 {get;set;} // ? Add Info 1
            @AuraEnabled public String CC06_TAXINFO {get;set;} // ? ADD info 2(tax, gubun)
            @AuraEnabled public String LP_BM     {get;set;} // ? Net Value in Document IF_CURRENCY
            @AuraEnabled public String LP_OP     {get;set;} // ? Net Value in Document IF_CURRENCY
            @AuraEnabled public String LP_SUM    {get;set;} // ? Net Value in Document IF_CURRENCY
            @AuraEnabled public String PROMO_PRC {get;set;} // ? Net Value in Document IF_CURRENCY
      
        }
      
          public class IF_ORDER_005_Res_O_RETURN { 
            public IF_ORDER_005_Res_O_RETURN(){}
  
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
      
        }
      
          public class IF_ORDER_005_Res_T_ITEM { 
            public IF_ORDER_005_Res_T_ITEM(){}
  
            @AuraEnabled public String POSNR    {get;set;} // ? Item number of the SD document
            @AuraEnabled public String MATNR    {get;set;} // ? Material Number
            @AuraEnabled public String ARKTX    {get;set;} // ? Short text for sales order item
            @AuraEnabled public String KWMENG   {get;set;} // ? Cumulative Order Quantity in Sales Units
            @AuraEnabled public String VRKME    {get;set;} // ? Sales unit
            @AuraEnabled public String NETPR    {get;set;} // ? Net price
            @AuraEnabled public String WAERK    {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String WERKS    {get;set;} // ? Plant (Own or External)
            @AuraEnabled public String CHECK    {get;set;} // ? Check Flag
            @AuraEnabled public String EQUIP_CHECK {get;set;} // ? Equip Check Flag
            @AuraEnabled public String MWST     {get;set;} // ? Net price
            @AuraEnabled public String PSTYV    {get;set;} // ? Sales document item category
            @AuraEnabled public String NOTE     {get;set;} // ? Note Long Txt
            @AuraEnabled public String NET      {get;set;} // ? Net price
            @AuraEnabled public String VTEXT    {get;set;} // ? Description
            @AuraEnabled public String STDPD    {get;set;} // ? Configurable material
            @AuraEnabled public String ZZDEALDT {get;set;} // ? Dealer's sales date
      
        }
      
          public class IF_ORDER_005_Res_T_CONFIG { 
            public IF_ORDER_005_Res_T_CONFIG(){}
  
            @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
            @AuraEnabled public String ATNAM    {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATBEZ    {get;set;} // ? Characteristic description
            @AuraEnabled public String ZSEQNO   {get;set;} // ? Sequence Number (3byte)
            @AuraEnabled public String SHOW     {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String READONLY {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
      
        }
      
          public class IF_ORDER_005_Res_T_SUB { 

            public IF_ORDER_005_Res_T_SUB(){}
  
            @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
            @AuraEnabled public String ATNAM {get;set;} // ? Characteristic Name
            @AuraEnabled public String ATBEZ {get;set;} // ? Characteristic description
            @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value
            @AuraEnabled public String ATWTB {get;set;} // ? Characteristic value description
            @AuraEnabled public String IF_DEFAULT {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String ZSEQNO {get;set;} // ? Sequence Number (3byte)
            @AuraEnabled public String SHOW {get;set;} // ? Single-Character Indicator
      
        }
      
          public class IF_ORDER_005_Res_T_PRICING { 
            public IF_ORDER_005_Res_T_PRICING(){}
  
            @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT   {get;set;} // ? Description
            @AuraEnabled public String KWERT   {get;set;} // ? Condition value
            @AuraEnabled public String WAERK   {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
      
        }
      
          public class IF_ORDER_005_Res_T_PRICING_ADD {
            public IF_ORDER_005_Res_T_PRICING_ADD(){}
  
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String ZISI_DISPLAY {get;set;} // ? Display
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
            @AuraEnabled public String VISIBLE    {get;set;} // ? Visible
            @AuraEnabled public String VISIBLE_01 {get;set;} // ?                                                             
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
      
        }
      
          public class IF_ORDER_005_Res_T_PRICING_RATE { 
            public IF_ORDER_005_Res_T_PRICING_RATE(){}
  
            @AuraEnabled public String POSNR      {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL      {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT      {get;set;} // ? Description
            @AuraEnabled public String RATE       {get;set;} // ? Condition value
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String STUNR      {get;set;} // ? Step number
            @AuraEnabled public String ZAEHK      {get;set;} // ? Condition counter
            @AuraEnabled public String KWERT      {get;set;} // ? Condition value
            @AuraEnabled public String NWAERK     {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
      
      
        }
      
          public class IF_ORDER_005_Res_T_OPTION { 
            public IF_ORDER_005_Res_T_OPTION(){}
  
            @AuraEnabled public String POSNR   {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL   {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT   {get;set;} // ? Description
            @AuraEnabled public String KWERT   {get;set;} // ? Condition value
            @AuraEnabled public String WAERK   {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
      
        }
      
          public class IF_ORDER_005_Res_T_PRICING_EX {
            public IF_ORDER_005_Res_T_PRICING_EX(){}
  
            @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
            @AuraEnabled public String KSCHL {get;set;} // ? Condition Type
            @AuraEnabled public String VTEXT {get;set;} // ? Description
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition amount or percentage)
            @AuraEnabled public String KWERT {get;set;} // ? Condition value
            @AuraEnabled public String WAERK {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String VISIBLE {get;set;} // ? Visible
            @AuraEnabled public String GUBUN {get;set;} // ? Condition Type Gubun Flag
      
        }
      
          public class IF_ORDER_005_Res_T_COND_EX {
            public IF_ORDER_005_Res_T_COND_EX(){}
  
            @AuraEnabled public String ITM_NUMBER {get;set;} // ? Condition item number
            @AuraEnabled public String COND_ST_NO {get;set;} // ? Step number
            @AuraEnabled public String COND_COUNT {get;set;} // ? Condition counter
            @AuraEnabled public String COND_TYPE {get;set;} // ? Condition type
            @AuraEnabled public String COND_VALUE {get;set;} // ? Condition rate
            @AuraEnabled public String IF_CURRENCY {get;set;} // ? IF_CURRENCY Key
            @AuraEnabled public String COND_UNIT {get;set;} // ? Condition unit
            @AuraEnabled public String COND_P_UNT {get;set;} // ? Condition pricing unit
            @AuraEnabled public String CURR_ISO {get;set;} // ? ISO code IF_CURRENCY
            @AuraEnabled public String CD_UNT_ISO {get;set;} // ? Condition unit of measure in UoM
            @AuraEnabled public String REFOBJTYPE {get;set;} // ? Object Type
            @AuraEnabled public String REFOBJKEY {get;set;} // ? Object key
            @AuraEnabled public String REFLOGSYS {get;set;} // ? Logical system
            @AuraEnabled public String APPLICATIO {get;set;} // ? Application
            @AuraEnabled public String CONPRICDAT {get;set;} // ? Condition pricing date
            @AuraEnabled public String CALCTYPCON {get;set;} // ? Calculation type for condition
            @AuraEnabled public String CONBASEVAL {get;set;} // ? Condition base value
            @AuraEnabled public String CONEXCHRAT {get;set;} // ? Condition exchange rate for conversion to local IF_CURRENCY
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
            @AuraEnabled public String ROUNDOFFDI {get;set;} // ? IF_CURRENCY amount for BAPIS (with 9 decimal places)
            @AuraEnabled public String CONDVALUE {get;set;} // ? Condition value
            @AuraEnabled public String IF_CURRENCY_2 {get;set;} // ? SD Document IF_CURRENCY
            @AuraEnabled public String CURR_ISO_2 {get;set;} // ? ISO code IF_CURRENCY
            @AuraEnabled public String CONDCNTRL {get;set;} // ? Condition control
            @AuraEnabled public String CONDISACTI {get;set;} // ? Condition is inactive
            @AuraEnabled public String CONDCLASS {get;set;} // ? Condition class
            @AuraEnabled public String FACTBASVAL {get;set;} // ? Factor for condition base value
            @AuraEnabled public String SCALEBASIN {get;set;} // ? Scale basis indicator
            @AuraEnabled public String SCALBASVAL {get;set;} // ? Scale base value of the condition
            @AuraEnabled public String UNITMEASUR {get;set;} // ? Condition scale unit of measure
            @AuraEnabled public String ISO_UNIT {get;set;} // ? ISO code for unit of measurement
            @AuraEnabled public String CURRENCKEY {get;set;} // ? Scale IF_CURRENCY
            @AuraEnabled public String CURRENISO {get;set;} // ? ISO code IF_CURRENCY
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
      
        }
      
          public class IF_ORDER_005_Res_T_BM_DESC { 
            public IF_ORDER_005_Res_T_BM_DESC(){}
  
            @AuraEnabled public String TDFORMAT {get;set;} // ? Tag column
            @AuraEnabled public String TDLINE {get;set;} // ? Text Line
      
        }
      
          public class IF_ORDER_005_Res_T_MULTICOND {
            public IF_ORDER_005_Res_T_MULTICOND(){}
  
            @AuraEnabled public String CHAK  {get;set;} // ? Control activate
            @AuraEnabled public String VARCOND {get;set;} // ? Variant condition
            @AuraEnabled public String KNUMH {get;set;} // ? Condition record number
            @AuraEnabled public String KBETR {get;set;} // ? Rate (condition amount or percentage)
            @AuraEnabled public String KWERT {get;set;} // ? Condition value
            @AuraEnabled public String WAERK {get;set;} // ? SD Document IF_CURRENCY
      
        }
      
          public class IF_ORDER_005_Res_T_RETURN {
            public IF_ORDER_005_Res_T_RETURN(){}
  
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
            @AuraEnabled public String ROW       {get;set;} // ? Lines in parameter
            @AuraEnabled public String FIELD     {get;set;} // ? Field in parameter
            @AuraEnabled public String IF_SYSTEM {get;set;} // ? Logical system from which message originates
      
        }
      
}