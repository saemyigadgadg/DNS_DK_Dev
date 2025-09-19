/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Hanyeong Choi 
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   01-24-2025   Hanyeong Choi   Initial Version
**/
public with sharing class IF_ERP_Account_Classes {
    public IF_ERP_Account_Classes() {}

    // SFDC interface Id    : IF_ACCOUNT_002
    // AS-IS RFC            : Z_SD_MS_SP_CHG       
    // New I/F              : ZCRM_SD_MS_SP_CHG				
    // Description          : CRM에서 잠재고객의 데이터가 변경되면 ERP 고객 마스터 데이터와 동기화     
    public class IF_ACCOUNT_002_Req { 
          @AuraEnabled public String I_KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String I_ANRED {get;set;} // ? Title
          @AuraEnabled public String I_NAME1 {get;set;} // ? Name 1
          @AuraEnabled public String I_NAME3 {get;set;} // ? Name 3
          @AuraEnabled public String I_SORT1 {get;set;} // ? Search Term 1

          @AuraEnabled public String I_NAME  {get;set;} // ? Name / 대표자명
          @AuraEnabled public String I_LOCATION {get;set;} // ? Street 5
          @AuraEnabled public String I_COUNTRY {get;set;} // ? Country Key
          @AuraEnabled public String I_REGION {get;set;} // ? Region (State, Province, County)
          @AuraEnabled public String I_PSTLZ {get;set;} // ? Postal Code

          @AuraEnabled public String I_STREET {get;set;} // ? Street
          @AuraEnabled public String I_CITY1 {get;set;} // ? City
          @AuraEnabled public String I_STR_SUPPL1 {get;set;} // ? Street 2
          @AuraEnabled public String I_TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
          @AuraEnabled public String I_MOB_NUMBER {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number

          @AuraEnabled public String I_FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number
          @AuraEnabled public String I_SMTP_ADDR {get;set;} // ? E-Mail Address
          @AuraEnabled public String I_JMZAH {get;set;} // ? Yearly number of employees
          @AuraEnabled public String I_JMJAH {get;set;} // ? Year for which the number of employees is given
          @AuraEnabled public String I_KATR1 {get;set;} // ? Customer group 1

          @AuraEnabled public String I_KATR2 {get;set;} // ? Customer group 2
          @AuraEnabled public String I_KATR3 {get;set;} // ? Customer group 3
          @AuraEnabled public String I_J_1KFTBUS {get;set;} // ? Type of Business
          @AuraEnabled public String I_J_1KFTIND {get;set;} // ? Type of Industry
          @AuraEnabled public String I_VKBUR {get;set;} // ? Sales Office

          @AuraEnabled public String I_BZIRK {get;set;} // ? Sales district
          @AuraEnabled public String I_TAXNUMBER1 {get;set;} // ? Tax Number 1
          @AuraEnabled public String I_KTONR {get;set;} // ? Number of an SD business partner
          @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel

          @AuraEnabled public String I_SPART {get;set;} // ? Division
          @AuraEnabled public String I_DEALER {get;set;} // ? Dealer
          @AuraEnabled public String I_SPRAS {get;set;} // ? Language
          @AuraEnabled public String I_TAXNUMBER4 {get;set;} // ? Tax Number 4(영업집조번호-15)
          @AuraEnabled public String I_EMAIL {get;set;} // ? 이메일
          @AuraEnabled public String I_AUFSD {get;set;}  // ? Blocked 여부
          @AuraEnabled public String I_WAERS {get;set;}  // Currency Key
          @AuraEnabled public String O_BLOCKED      {get;set;} // v1.3
          @AuraEnabled public String O_BLOCKED_MSG  {get;set;} // v1.3


        public IF_ACCOUNT_002_Req(){}
      }

      public class IF_ACCOUNT_002_Res { 
        @AuraEnabled public String O_RECODE {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String O_REMSG  {get;set;} // ? Message Text
    
        public IF_ACCOUNT_002_Res(){}
    }
  
    // SFDC interface Id    : IF_ACCOUNT_001
    // AS-IS RFC            : Z_SD_MS_SP_CRE    
    // New I/F              : ZCRM_SD_MS_SP_CRE		
    // Description          : CRM 잠재고객 정보를 ERP 고객 마스터에 전송  
    public class IF_Account_001_Req { 
      @AuraEnabled public String I_ANRED {get;set;}     // ? Title
      @AuraEnabled public String I_NAME1 {get;set;}     // ? Name 1
      @AuraEnabled public String I_NAME3 {get;set;}     // ? Name 3
      @AuraEnabled public String I_SORT1 {get;set;}     // ? Search Term 1
      @AuraEnabled public String I_NAME  {get;set;}     // ? 대표자명           => PARTNER 정보 가능 
      @AuraEnabled public String I_LOCATION {get;set;}  // ? City, described by different objects in the SAP System
      @AuraEnabled public String I_COUNTRY {get;set;}   // ? Country Key
      @AuraEnabled public String I_REGION {get;set;}    // ? Region (State, Province, County)
      @AuraEnabled public String I_PSTLZ {get;set;}     // ? Postal Code
      @AuraEnabled public String I_STREET {get;set;}    // ? Street

      @AuraEnabled public String I_CITY1 {get;set;}      // ? City
      @AuraEnabled public String I_STR_SUPPL1 {get;set;} // ? Street 2
      @AuraEnabled public String I_TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
      @AuraEnabled public String I_MOB_NUMBER {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
      @AuraEnabled public String I_FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number

      @AuraEnabled public String I_SMTP_ADDR {get;set;}  // ? E-Mail Address(실제로는 홈페이지)
      @AuraEnabled public String I_JMZAH {get;set;}      // ? Yearly number of employees
      @AuraEnabled public String I_JMJAH {get;set;}      // ? Year for which the number of employees is given
      @AuraEnabled public String I_KATR1 {get;set;}      // ? Customer group 1
      @AuraEnabled public String I_KATR2 {get;set;}      // ? Customer group 2

      @AuraEnabled public String I_KATR3 {get;set;}      // ? Customer group 3
      @AuraEnabled public String I_J_1KFTBUS {get;set;}  // ? Type of Business
      @AuraEnabled public String I_J_1KFTIND {get;set;}  // ? Type of Industry
      @AuraEnabled public String I_VKBUR {get;set;}      // ? Sales Office
      @AuraEnabled public String I_BZIRK {get;set;}      // ? Sales district

      @AuraEnabled public String I_TAXNUMBER1 {get;set;} // ? Tax Number 1
      @AuraEnabled public String I_KTONR {get;set;}      // ? Number of an SD business partner
      @AuraEnabled public String I_KTONR2 {get;set;}     // ? 파트너 펑션
      @AuraEnabled public String I_VKORG {get;set;}      // ? Sales Organization
      @AuraEnabled public String I_VTWEG {get;set;}      // ? Distribution Channel

      @AuraEnabled public String I_SPART {get;set;}      // ? Division
      @AuraEnabled public String I_DEALER {get;set;}     // ? Dealer
      @AuraEnabled public String I_SPRAS {get;set;}      // ? Language
      @AuraEnabled public String I_TAXNUMBER4 {get;set;} // ? Tax Number 4(영업집조번호-15)
      @AuraEnabled public String I_EMAIL {get;set;}      // ? E-Mail Address(진짜 이메일)
      @AuraEnabled public String I_WAERS {get;set;}      // ? Currency Key
    }

    public class IF_Account_001_Res { 
        @AuraEnabled public String O_RECODE  {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String O_REMSG   {get;set;} // ? Message Text
        @AuraEnabled public String O_KUNNR   {get;set;} // ? Customer Number 1
        @AuraEnabled public String O_DUP     {get;set;} // ? Duplication Flag

        @AuraEnabled public List<IF_Account_001_Res_ET_DATA> ET_DATA {get;set;} 
 
        public IF_Account_001_Res(){}
    }

    public class IF_Account_001_Res_ET_DATA { 
      @AuraEnabled  public String KUNNR_ZI  {get;set;} // ? Customer Number 1
      @AuraEnabled  public String NAME1_ZI  {get;set;} // ? Name 1
      @AuraEnabled  public String KUNNR     {get;set;} // ? Customer Number 1
      @AuraEnabled  public String NAME1_GP  {get;set;} // ? Name 1
      @AuraEnabled  public String TELF1     {get;set;} // ? First telephone number
          
      @AuraEnabled  public String TELF2     {get;set;} // ? Second telephone number
      @AuraEnabled  public String TELFX     {get;set;} // ? Fax Number
      @AuraEnabled  public String URL       {get;set;} // ? Uniform Resource Locator
      @AuraEnabled  public String VKORG     {get;set;} // ? Sales Organization
      @AuraEnabled  public String VTWEG     {get;set;} // ? Distribution Channel
          
      @AuraEnabled  public String SPART     {get;set;} // ? Division
      @AuraEnabled  public String LAND1     {get;set;} // ? Country Key
      @AuraEnabled  public String KTOKD     {get;set;} // ? Customer Account Group
      @AuraEnabled  public String ERDAT     {get;set;} // ? Date on Which Record Was Created
      @AuraEnabled  public String ERZET     {get;set;} // ? Entry time

      @AuraEnabled public String ANRED_ZI {get;set;} // ? Title
      @AuraEnabled public String ANRED    {get;set;} // ? Title


    public IF_Account_001_Res_ET_DATA(){}
  }

    // SFDC interface Id    : IF_ACCOUNT_006
    // AS-IS RFC            : Z_SD_MS_TC_CHG       
    // New I/F              : ZCRM_SD_MS_SP_TO_TC				
    // Description          : 잠재고객에서 실고객 전환 요청     
    public class IF_ACCOUNT_006_Req { 
      @AuraEnabled public String I_KUNNR       {get;set;} // ? Customer Number 1 -> not null 
      @AuraEnabled public String I_ANRED       {get;set;} // ? Title
      @AuraEnabled public String I_STCD1       {get;set;} // ? Tax Number 1
      @AuraEnabled public String I_STCD2       {get;set;} // ? Tax Number 2
      @AuraEnabled public String I_STCD3       {get;set;} // ? Tax Number 3

      @AuraEnabled public String I_LZONE       {get;set;} // ? Transportation zone to or from which the goods are delivered
      @AuraEnabled public String I_J_1KFTBUS   {get;set;} // ? Type of Business
      @AuraEnabled public String I_J_1KFTIND   {get;set;} // ? Type of Industry
      @AuraEnabled public String I_KTONR       {get;set;} // ? Number of an SD business partner
      @AuraEnabled public String I_VKBUR       {get;set;} // ? Sales Office

      @AuraEnabled public String I_BZIRK       {get;set;} // ? Sales district
      @AuraEnabled public String I_WAERS       {get;set;} // ? Currency
      @AuraEnabled public String I_INCO1       {get;set;} // ? Incoterms (Part 1)
      @AuraEnabled public String I_INCO2       {get;set;} // ? Incoterms (Part 2)
      @AuraEnabled public String I_VSBED       {get;set;} // ? Shipping Conditions

      @AuraEnabled public String I_TAXKD       {get;set;} // ? Tax classification for customer
      @AuraEnabled public String I_KDGRP       {get;set;} // ? Customer group
      @AuraEnabled public String I_ZTERM       {get;set;} // ? Terms of Payment Key
      @AuraEnabled public String I_KTGRD       {get;set;} // ? Account assignment group for this customer
      @AuraEnabled public String I_KTONR1      {get;set;} // ? BP(Bill-to party)

      @AuraEnabled public String I_KTONR2      {get;set;} // ? SH(Ship-to party)
      @AuraEnabled public String I_KTONR3      {get;set;} // ? ZM(Sales Resps.)
      @AuraEnabled public String I_KTONR4      {get;set;} // ? PY(Payer)
      @AuraEnabled public String I_KTONR5      {get;set;} // ? Z1(Service Dealer)
      @AuraEnabled public String I_KTONR6      {get;set;} // ? Z2(Credit Resps.)

      @AuraEnabled public String I_VKORG       {get;set;} // ? Sales Organization
      @AuraEnabled public String I_VTWEG       {get;set;} // ? Distribution Channel
      @AuraEnabled public String I_SPART       {get;set;} // ? Division
      @AuraEnabled public String I_DEALER      {get;set;} // ? Dealer
      @AuraEnabled public String I_SPRAS       {get;set;} // ? Language

      @AuraEnabled public String I_TAXNUMBER4  {get;set;} // ? Tax Number 4(영업집조번호-15)
      @AuraEnabled public String I_REGION      {get;set;} // ? Region (State, Province, County)
      @AuraEnabled public String I_BUTYP       {get;set;} // ? Business type
      @AuraEnabled public String I_BUCOD       {get;set;} // ? Business Conditions
      @AuraEnabled public String I_APPROVE_CHK {get;set;} // ? 승인필요여부 Flag ( 'X' 승인불필요건, ' ' 승인건 ) :: v1.3 
      @AuraEnabled public String I_KALKS       {get;set;} // ? Pricing procedure assigned to this customer :: 1.1 version
      @AuraEnabled public String I_J_1KFREPRE  {get;set;} // ? Pricing procedure assigned to this customer :: 1.1 version


      public IF_ACCOUNT_006_Req(){}

    }
    public class IF_ACCOUNT_006_Res { 
      @AuraEnabled public String O_RECODE      {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
      @AuraEnabled public String O_REMSG       {get;set;} // ? Message Text
    }

    // SFDC interface Id    : IF_ACCOUNT_003
    // AS-IS RFC            : NEW       
    // New I/F              : ZCRM_SD_MS_TC_CHG				
    // Description          : CRM에서 실고객의 데이터가 변경되면 ERP 고객 마스터 데이터와 동기화  
    public class IF_ACCOUNT_003_Req { 
      @AuraEnabled public String I_KUNNR      {get;set;} // ? Customer Number 1 => NOT NULL
      @AuraEnabled public String I_ANRED      {get;set;} // ? Title             => NOT NULL
      @AuraEnabled public String I_NAME1      {get;set;} // ? Name 1
      @AuraEnabled public String I_NAME3      {get;set;} // ? Name 3
      @AuraEnabled public String I_SORT1      {get;set;} // ? Search Term 1

      @AuraEnabled public String I_LOCATION   {get;set;} // ? Street 5
      @AuraEnabled public String I_COUNTRY    {get;set;} // ? Country Key
      @AuraEnabled public String I_REGION     {get;set;} // ? Region (State, Province, County)
      @AuraEnabled public String I_PSTLZ      {get;set;} // ? Postal Code
      @AuraEnabled public String I_STREET     {get;set;} // ? Street

      @AuraEnabled public String I_CITY1      {get;set;} // ? City
      @AuraEnabled public String I_STR_SUPPL1 {get;set;} // ? Street 2
      @AuraEnabled public String I_TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
      @AuraEnabled public String I_MOB_NUMBER {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
      @AuraEnabled public String I_FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number

      @AuraEnabled public String I_SMTP_ADDR  {get;set;} // ? E-Mail Address
      @AuraEnabled public String I_JMZAH      {get;set;} // ? Yearly number of employees
      @AuraEnabled public String I_JMJAH      {get;set;} // ? Year for which the number of employees is given
      @AuraEnabled public String I_KATR1      {get;set;} // ? Customer group 1
      @AuraEnabled public String I_KATR2      {get;set;} // ? Customer group 2

      @AuraEnabled public String I_KATR3      {get;set;} // ? Customer group 3
      @AuraEnabled public String I_J_1KFTBUS  {get;set;} // ? Type of Business
      @AuraEnabled public String I_J_1KFTIND  {get;set;} // ? Type of Industry
      @AuraEnabled public String I_VKBUR      {get;set;} // ? Sales Office
      @AuraEnabled public String I_BZIRK      {get;set;} // ? Sales district

      @AuraEnabled public String I_TAXNUMBER1 {get;set;} // ? Tax Number 1
      @AuraEnabled public String I_KTONR      {get;set;} // ? Number of an SD business partner
      @AuraEnabled public String I_VKORG      {get;set;} // ? Sales Organization
      @AuraEnabled public String I_VTWEG      {get;set;} // ? Distribution Channel
      @AuraEnabled public String I_SPART      {get;set;} // ? Division

      @AuraEnabled public String I_DEALER     {get;set;} // ? Dealer
      @AuraEnabled public String I_SPRAS      {get;set;} // ? Language
      @AuraEnabled public String I_TAXNUMBER4 {get;set;} // ? Tax Number 4(영업집조번호-15)
      @AuraEnabled public String I_EMAIL      {get;set;} // ? 이메일 
      @AuraEnabled public String I_NAME       {get;set;} // ? 이름
      @AuraEnabled public String I_AUFSD      {get;set;} // 
      @AuraEnabled public String I_WAERS      {get;set;} // 


      public IF_ACCOUNT_003_Req(){}

    }
    public class IF_ACCOUNT_003_Res { 
      public IF_ACCOUNT_003_Res(){}
      @AuraEnabled public String O_RECODE {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
      @AuraEnabled public String O_REMSG {get;set;} // ? Message Text
      @AuraEnabled public String O_BLOCKED {get;set;}
      @AuraEnabled public String O_BLOCKED_MSG {get;set;} 
    }

/** IF_ACCOUNT_004
    */  
    /**
         * Wrapper Name         : IF_ACCOUNT_004
         * SFDC interface Id    : IF-ACCOUNT-004
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_SD_MS_SH_CRE
         * Description          : CRM에서 Ship-to의 데이터가 생성되면 ERP 고객 마스터 데이터와 동기화
     */
    /** REQUEST 
      */    
        public class IF_ACCOUNT_004_Req {
          public IF_ACCOUNT_004_Req(String I_NAME1,String I_COUNTRY){
            this.I_NAME1   = I_NAME1;
            this.I_COUNTRY = I_COUNTRY;
          } 
          public IF_ACCOUNT_004_Req(){}
          @AuraEnabled public String I_ANRED {get;set;} // ? Title
          @AuraEnabled public String I_NAME1 {get;set;} // ? Name 1  ==> NOT NULL
          @AuraEnabled public String I_NAME3 {get;set;} // ? Name 3
          @AuraEnabled public String I_SORT1 {get;set;} // ? Search Term 1
          @AuraEnabled public String I_LOCATION {get;set;} // ? City, described by different objects in the SAP System

          @AuraEnabled public String I_COUNTRY {get;set;} // ? Country Key ==> NOT NULL
          @AuraEnabled public String I_REGION {get;set;} // ? Region (State, Province, County)
          @AuraEnabled public String I_PSTLZ {get;set;} // ? Postal Code
          @AuraEnabled public String I_STREET {get;set;} // ? Street
          @AuraEnabled public String I_CITY1 {get;set;} // ? City

          @AuraEnabled public String I_STR_SUPPL1 {get;set;} // ? Street 2
          @AuraEnabled public String I_TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
          @AuraEnabled public String I_MOB_NUMBER {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
          @AuraEnabled public String I_FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number
          @AuraEnabled public String I_SMTP_ADDR {get;set;} // ? E-Mail Address(실제로는 홈페이지)

          @AuraEnabled public String I_JMZAH {get;set;} // ? Yearly number of employees
          @AuraEnabled public String I_JMJAH {get;set;} // ? Year for which the number of employees is given
          @AuraEnabled public String I_KATR1 {get;set;} // ? Customer group 1
          @AuraEnabled public String I_KATR2 {get;set;} // ? Customer group 2
          @AuraEnabled public String I_KATR3 {get;set;} // ? Customer group 3

          @AuraEnabled public String I_J_1KFTBUS {get;set;} // ? Type of Business
          @AuraEnabled public String I_J_1KFTIND {get;set;} // ? Type of Industry
          @AuraEnabled public String I_VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String I_BZIRK {get;set;} // ? Sales district
          @AuraEnabled public String I_TAXNUMBER1 {get;set;} // ? Tax Number 1

          @AuraEnabled public String I_KTONR {get;set;} // ? Number of an SD business partner
          @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String I_SPART {get;set;} // ? Division
          @AuraEnabled public String I_DEALER {get;set;} // ? Dealer

          @AuraEnabled public String I_SPRAS {get;set;} // ? Language
          @AuraEnabled public String I_TAXNUMBER4 {get;set;} // ? Tax Number 4(영업집조번호-15)
          @AuraEnabled public String I_EMAIL {get;set;} // ? E-Mail Address(진짜 이메일)
          @AuraEnabled public String I_NAME {get;set;} // ? 대표자명 -> v1.1 
          @AuraEnabled public String I_WAERS  {get;set;}
        }

    /** RESPONSE 
      */            
      public class IF_ACCOUNT_004_Res { 
        public IF_ACCOUNT_004_Res(){}
        @AuraEnabled public String O_RECODE {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String O_REMSG {get;set;} // ? Message Text
        @AuraEnabled public String O_KUNNR {get;set;} // ? Customer Number 1
        @AuraEnabled public String O_DUP {get;set;} // ? Duplication Flag

        @AuraEnabled public List<IF_ACCOUNT_004_Res_ET_DATA> ET_DATA {get;set;} 
      }

      public class IF_ACCOUNT_004_Res_ET_DATA { 
        public IF_ACCOUNT_004_Res_ET_DATA(){}
        @AuraEnabled public String KUNNR_ZI {get;set;} // ? Customer Number 1
        @AuraEnabled public String NAME1_ZI {get;set;} // ? Name 1
        @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
        @AuraEnabled public String NAME1 {get;set;} // ? Name 1
        @AuraEnabled public String TELF1 {get;set;} // ? First telephone number

        @AuraEnabled public String TELF2 {get;set;} // ? Second telephone number
        @AuraEnabled public String TELFX {get;set;} // ? Fax Number
        @AuraEnabled public String KNURL {get;set;} // ? Uniform Resource Locator
        @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
        @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel

        @AuraEnabled public String SPART {get;set;} // ? Division
        @AuraEnabled public String LAND1 {get;set;} // ? Country Key
        @AuraEnabled public String KTOKD {get;set;} // ? Customer Account Group
        @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
        @AuraEnabled public String ERZET {get;set;} // ? Entry time

        @AuraEnabled public String ANRED_ZI {get;set;} // ? Title
        @AuraEnabled public String ANRED    {get;set;} // ? Title
      } 

/** IF_ACCOUNT_013
    */  
    /**
         * Wrapper Name         : IF_ACCOUNT_013
         * SFDC interface Id    : IF-ACCOUNT-013
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_SD_MS_SH_CHG
         * Description          : CRM에서 Ship-to의 데이터가 변경되면 ERP 고객 마스터 데이터와 동기화
     */
    /** REQUEST 
      */    
        public class IF_ACCOUNT_013_Req {
          public IF_ACCOUNT_013_Req(){} 
          public IF_ACCOUNT_013_Req(String I_KUNNR,String I_ANRED){
              this.I_KUNNR = I_KUNNR;
              this.I_ANRED = I_ANRED;
          } 
          @AuraEnabled public String I_KUNNR {get;set;} // ? Customer Number 1 => NOT NULL
          @AuraEnabled public String I_ANRED {get;set;} // ? Title             => NOT NULL
          @AuraEnabled public String I_NAME1 {get;set;} // ? Name 1
          @AuraEnabled public String I_NAME3 {get;set;} // ? Name 3
          @AuraEnabled public String I_SORT1 {get;set;} // ? Search Term 1
    
          @AuraEnabled public String I_LOCATION {get;set;} // ? Street 5
          @AuraEnabled public String I_COUNTRY {get;set;} // ? Country Key
          @AuraEnabled public String I_REGION {get;set;} // ? Region (State, Province, County)
          @AuraEnabled public String I_PSTLZ {get;set;} // ? Postal Code
          @AuraEnabled public String I_STREET {get;set;} // ? Street
    
          @AuraEnabled public String I_CITY1 {get;set;} // ? City
          @AuraEnabled public String I_STR_SUPPL1 {get;set;} // ? Street 2
          @AuraEnabled public String I_TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
          @AuraEnabled public String I_MOB_NUMBER {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
          @AuraEnabled public String I_FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number
    
          @AuraEnabled public String I_SMTP_ADDR {get;set;} // ? E-Mail Address
          @AuraEnabled public String I_JMZAH {get;set;} // ? Yearly number of employees
          @AuraEnabled public String I_JMJAH {get;set;} // ? Year for which the number of employees is given
          @AuraEnabled public String I_KATR1 {get;set;} // ? Customer group 1
          @AuraEnabled public String I_KATR2 {get;set;} // ? Customer group 2
    
          @AuraEnabled public String I_KATR3 {get;set;} // ? Customer group 3
          @AuraEnabled public String I_J_1KFTBUS {get;set;} // ? Type of Business
          @AuraEnabled public String I_J_1KFTIND {get;set;} // ? Type of Industry
          @AuraEnabled public String I_VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String I_BZIRK {get;set;} // ? Sales district
    
          @AuraEnabled public String I_TAXNUMBER1 {get;set;} // ? Tax Number 1
          @AuraEnabled public String I_KTONR {get;set;} // ? Number of an SD business partner
          @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String I_SPART {get;set;} // ? Division
    
          @AuraEnabled public String I_DEALER     {get;set;} // ? Dealer
          @AuraEnabled public String I_SPRAS      {get;set;} // ? Language
          @AuraEnabled public String I_TAXNUMBER4 {get;set;} // ? Tax Number 4(영업집조번호-15)
          @AuraEnabled public String I_EMAIL      {get;set;} // ? 이메일
          @AuraEnabled public String I_NAME       {get;set;} // ? 대표자명 V1.1
          @AuraEnabled public String I_WAERS      {get;set;}

        }

    /** RESPONSE 
      */            
      public class IF_ACCOUNT_013_Res { 
        public IF_ACCOUNT_013_Res(){}
        @AuraEnabled public String O_RECODE {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String O_REMSG {get;set;} // ? Message Text
      }

/** IF_ACCOUNT_015
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_015
         * SFDC interface Id    : IF-ACCOUNT-015
         * AS-IS RFC            : Z_SD_CREATE_CUSTOMER_DIA	
         * New I/F              : ZCRM_SD_CREATE_CUSTOMER_USA
         * Description          : 고객 생성 (CRM -> ERP)-실고객 생성/Care of에 대한 RFC Copy
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */    
      public class IF_ACCOUNT_015_Req { 
        @AuraEnabled public String I_CHECK         {get;set;} // ? Duplicate Check Flag
        @AuraEnabled public String I_CUSTOMER_TYPE {get;set;} // ? S':ShipTo,'D':Dealer,'C':Care of Rigger
        @AuraEnabled public String I_WAERS         {get;set;}
        @AuraEnabled public String I_BZIRK         {get;set;} // 5.2v

        @AuraEnabled public IF_ACCOUNT_015_Req_I_BASIC I_BASIC {get;set;} 
        @AuraEnabled public IF_ACCOUNT_015_I_USERINFO I_USERINFO {get;set;}
        public IF_ACCOUNT_015_Req(){}
      }

      public class IF_ACCOUNT_015_Req_I_BASIC { 
        public IF_ACCOUNT_015_Req_I_BASIC(){}

        @AuraEnabled public String STCD1 {get;set;} // ? Tax Number 1
        @AuraEnabled public String NAME1 {get;set;} // ? Name 1
        @AuraEnabled public String NAME3 {get;set;} // ? Name 3
        @AuraEnabled public String NAME2 {get;set;} // ? Name 2
        @AuraEnabled public String NAME4 {get;set;} // ? Name 4
  
        @AuraEnabled public String SMTP_ADDR {get;set;} // ? E-Mail Address
        @AuraEnabled public String COUNTRY {get;set;} // ? Country Key
        @AuraEnabled public String POST_CODE1 {get;set;} // ? City postal code
        @AuraEnabled public String CITY1 {get;set;} // ? City
        @AuraEnabled public String REGION {get;set;} // ? Region (State, Province, County)
  
        @AuraEnabled public String COUNC {get;set;} // ? County Code
        @AuraEnabled public String STREET {get;set;} // ? Street
        @AuraEnabled public String STR_SUPPL1 {get;set;} // ? Street 2
        @AuraEnabled public String NAME_CO {get;set;} // ? c/o name
        @AuraEnabled public String TRANSPZONE {get;set;} // ? Transportation zone to or from which the goods are delivered
  
        @AuraEnabled public String TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
        @AuraEnabled public String MOB_NUMBER {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
        @AuraEnabled public String FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number
        @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
        @AuraEnabled public String BRAN1 {get;set;} // ? Cust. Region(FL)
        @AuraEnabled public String J_1KFREPRE {get;set;} 

      }


      public class IF_ACCOUNT_015_I_USERINFO{
        public IF_ACCOUNT_015_I_USERINFO(){}
        @AuraEnabled public String BNAME {get;set;}
        @AuraEnabled public String RNAME {get;set;}
        @AuraEnabled public String HIER {get;set;}
        @AuraEnabled public String KUNNR {get;set;}
        @AuraEnabled public String LIFNR {get;set;}
        @AuraEnabled public String VKORG {get;set;}
        @AuraEnabled public String VTWEG {get;set;}
        @AuraEnabled public String SPART {get;set;}
        @AuraEnabled public String WERKS {get;set;}
        @AuraEnabled public String ARBPL {get;set;}
        @AuraEnabled public String PARNR {get;set;}
        @AuraEnabled public String ENAME {get;set;}
        @AuraEnabled public String KUNN2 {get;set;}
        @AuraEnabled public String LAND1 {get;set;}
        @AuraEnabled public String LGORT {get;set;}
        @AuraEnabled public String DF_CHK {get;set;}
        @AuraEnabled public String CO_CHK {get;set;}

      }
  
    /** RESPONSE 
      */    
      public class IF_ACCOUNT_015_Res { 
        public IF_ACCOUNT_015_Res(){}

        @AuraEnabled public String O_PERSON {get;set;} // ? Customer Number 1
        @AuraEnabled public IF_ACCOUNT_015_Res_O_RETURN O_RETURN {get;set;} 
      }
  
      public class IF_ACCOUNT_015_Res_O_RETURN { 
        public IF_ACCOUNT_015_Res_O_RETURN(){}

        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
      }
      
/** IF_ACCOUNT_016 
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_016
         * SFDC interface Id    : IF-ACCOUNT-016
         * AS-IS RFC            : Z_SD_CUSTOMER_LIST_DIA
         * New I/F              : ZCRM_SD_CUSTOMER_LIST_USA
         * Description          : Sales Person 조회 (CRM -> ERP)-Sales Person-Dealer Code 연결에 대한 RFC
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */          
      public class IF_ACCOUNT_016_Req { 
        @AuraEnabled public String I_KUNNR {get;set;} // ? Customer Number 1
        @AuraEnabled public String I_NAME1 {get;set;} // ? Name
        @AuraEnabled public String I_CUSTOMER_TYPE {get;set;} // ? 'S':ShipTo,'D':Dealer,'C':Care of Rigger, 'T':Sold to
        @AuraEnabled public String I_LANGU {get;set;} // ? Language Key
        @AuraEnabled public IF_ACCOUNT_016_Req_I_USERINFO I_USERINFO {get;set;}
  

        public IF_ACCOUNT_016_Req(){
          this.I_USERINFO = new IF_ACCOUNT_016_Req_I_USERINFO(); 
        }
  
      }

     public class IF_ACCOUNT_016_Req_I_USERINFO{
      public IF_ACCOUNT_016_Req_I_USERINFO(){}
        @AuraEnabled public String BNAME {get;set;}
        @AuraEnabled public String RNAME {get;set;}
        @AuraEnabled public String HIER {get;set;}
        @AuraEnabled public String KUNNR {get;set;}
        @AuraEnabled public String LIFNR {get;set;}
        @AuraEnabled public String VKORG {get;set;}
        @AuraEnabled public String VTWEG {get;set;}
        @AuraEnabled public String SPART {get;set;}
        @AuraEnabled public String WERKS {get;set;}
        @AuraEnabled public String ARBPL {get;set;}
        @AuraEnabled public String PARNR {get;set;}
        @AuraEnabled public String ENAME {get;set;}
        @AuraEnabled public String KUNN2 {get;set;}
        @AuraEnabled public String LAND1 {get;set;}
        @AuraEnabled public String LGORT {get;set;}
        @AuraEnabled public String DF_CHK {get;set;}
        @AuraEnabled public String CO_CHK {get;set;}
     }

  
    /** RESPONSE
      */           
      public class IF_ACCOUNT_016_Res { 
        public IF_ACCOUNT_016_Res(){
          this.O_RETURN = new IF_ACCOUNT_016_Res_O_RETURN();
          this.T_LIST   = new  List<IF_ACCOUNT_016_Res_T_LIST>(); 
        }
        @AuraEnabled public IF_ACCOUNT_016_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_ACCOUNT_016_Res_T_LIST> T_LIST {get;set;} 
  
      }
  
      public class IF_ACCOUNT_016_Res_O_RETURN { 
        public IF_ACCOUNT_016_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
      }
  
      public class IF_ACCOUNT_016_Res_T_LIST { 
        public IF_ACCOUNT_016_Res_T_LIST(){}
        @AuraEnabled public String KUNNR        {get;set;} // ? Customer Number 1
        @AuraEnabled public String NAME1        {get;set;} // ? Name 1
        @AuraEnabled public String NAME3        {get;set;} // ? Name 3
        @AuraEnabled public String NAME2X       {get;set;} // ? Name 2
        @AuraEnabled public String NAME4        {get;set;} // ? Name 4
  
        @AuraEnabled public String STCD1        {get;set;} // ? Tax Number 1
        @AuraEnabled public String CITY1        {get;set;} // ? City
        @AuraEnabled public String REGION       {get;set;} // ? Region (State, Province, County)
        @AuraEnabled public String COUNTRY      {get;set;} // ? Country Key
        @AuraEnabled public String POST_CODE1   {get;set;} // ? City postal code
  
        @AuraEnabled public String STREET       {get;set;} // ? Street
        @AuraEnabled public String STR_SUPPL1   {get;set;} // ? Street 2
        @AuraEnabled public String COUNC        {get;set;} // ? County Code
        @AuraEnabled public String TRANSPZONE   {get;set;} // ? Transportation zone to or from which the goods are delivered
        @AuraEnabled public String TEL_NUMBER   {get;set;} // ? First telephone no.: dialling code+number
  
        @AuraEnabled public String FAX_NUMBER   {get;set;} // ? First fax no.: dialling code+number
        @AuraEnabled public String MOB_NUMBER   {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
        @AuraEnabled public String SMTP_ADDR    {get;set;} // ? E-Mail Address
        @AuraEnabled public String NAME_CO      {get;set;} // ? c/o name
        @AuraEnabled public String REGIO_TEXT   {get;set;} // ? Description
  
        @AuraEnabled public String LAND1_TEXT   {get;set;} // ? Country Name
        @AuraEnabled public String KUNNR2       {get;set;} // ? Customer Number 1
        @AuraEnabled public String NAME2        {get;set;} // ? Name
        @AuraEnabled public String STATUS       {get;set;} // ? Status
        @AuraEnabled public String BRAN1        {get;set;} // ? Cust. Region(FL)
  
        @AuraEnabled public String TERRITORY_TX {get;set;} // ? Description
  
      }

/** IF-ACCOUNT-005
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF-ACCOUNT-005
         * SFDC interface Id    : IF_ACCOUNT_005 
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_MS_SP_LST
         * Description          : 고객마스터 전송 - 고객 마스터 정보 반환하여 ERP & CRM 데이터 동기화 (생성, 수정 삭제) 실고객, 잠재고객, 대리점, 딜러 
         * KeyValue             : X
         * NOT NULL             : X
     */         
    /** REQUEST 
      */
        public class IF_ACCOUNT_005_Req { 
          public IF_ACCOUNT_005_Req(){}
          @AuraEnabled public String I_SDATE {get;set;} // ? Date on which the Record Was Created
          @AuraEnabled public String I_EDATE {get;set;} // ? Date on which the Record Was Created
          @AuraEnabled public String  I_STIME;
          @AuraEnabled public String  I_ETIME;
        }

   /** RESPONSE 
    */    
      public class IF_ACCOUNT_005_Res { 
        public IF_ACCOUNT_005_Res(){
          this.T_KNA1 = new List<IF_ACCOUNT_005_Res_T_KNA1>(); 
        }
        @AuraEnabled public String O_RECODE {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String O_REMSG {get;set;} // ? Message Text
        @AuraEnabled public String O_COUNT {get;set;} // ? Total count
        @AuraEnabled public String O_BOBAI {get;set;} // ? BOBAI Count

        @AuraEnabled public List<IF_ACCOUNT_005_Res_T_KNA1> T_KNA1 {get;set;} 
        @AuraEnabled public List<IF_ACCOUNT_005_Res_T_KNVV> T_KNVV {get;set;} 
        @AuraEnabled public List<IF_ACCOUNT_005_Res_T_KNVP> T_KNVP {get;set;} 
      }

      public class IF_ACCOUNT_005_Res_T_KNA1 { 
        public IF_ACCOUNT_005_Res_T_KNA1(){}
        @AuraEnabled public String KUNNR     {get;set;} // ? Customer Number 1
        @AuraEnabled public String NAME1     {get;set;} // ? Name 1
        @AuraEnabled public String ORT01     {get;set;} // ? City
        @AuraEnabled public String STRAS     {get;set;} // ? House number and street
        @AuraEnabled public String LAND1     {get;set;} // ? Country Key
        @AuraEnabled public String LANDX     {get;set;} // ? Country Name
        @AuraEnabled public String ERNAM     {get;set;} // ? Name of Person who Created the Object
        @AuraEnabled public String ERDAT     {get;set;} // ? Date on which the Record Was Created
        @AuraEnabled public String KTOKD     {get;set;} // ? Customer Account Group
        @AuraEnabled public String KDGRP     {get;set;} // ? Customer group
        @AuraEnabled public String KTEXT     {get;set;} // ? Name
        @AuraEnabled public String ANRED     {get;set;} // ? Title
        @AuraEnabled public String LOCATION  {get;set;} // ? Street 5
        @AuraEnabled public String REGIO     {get;set;} // ? Region (State, Province, County)
        @AuraEnabled public String SORTL     {get;set;} // ? Sort field
        @AuraEnabled public String NAME3     {get;set;} // ? Name 3
        @AuraEnabled public String PSTLZ     {get;set;} // ? Postal Code
        @AuraEnabled public String TELF1     {get;set;} // ? First telephone number
        @AuraEnabled public String TELF2     {get;set;} // ? Second telephone number
        @AuraEnabled public String TELFX     {get;set;} // ? Fax Number
        @AuraEnabled public String KNURL     {get;set;} // ? Uniform Resource Locator
        @AuraEnabled public String KATR1     {get;set;} // ? Customer group 1
        @AuraEnabled public String VTEXT1    {get;set;} // ? Description
        @AuraEnabled public String KATR2     {get;set;} // ? Customer group 2
        @AuraEnabled public String VTEXT2    {get;set;} // ? Description
        @AuraEnabled public String KATR3     {get;set;} // ? Customer group 3
        @AuraEnabled public String VTEXT3    {get;set;} // ? Description
        @AuraEnabled public String STCD1     {get;set;} // ? Tax Number 1
        @AuraEnabled public String STCD2     {get;set;} // ? Tax Number 2
        @AuraEnabled public String J_1KFTBUS {get;set;} // ? Type of Business
        @AuraEnabled public String J_1KFTIND {get;set;} // ? Type of Industry
        @AuraEnabled public String JMZAH     {get;set;} // ? Yearly number of employees
        @AuraEnabled public String JMJAH     {get;set;} // ? Year for which the number of employees is given
        @AuraEnabled public String BZIRK     {get;set;} // ? Sales district
        @AuraEnabled public String BZTXT     {get;set;} // ? Name of the district
        @AuraEnabled public String VKBUR     {get;set;} // ? Sales Office
        @AuraEnabled public String BEZEI     {get;set;} // ? Name of the controlling area
        @AuraEnabled public String KTONR     {get;set;} // ? Customer number of business partner
        @AuraEnabled public String NAME2    {get;set;} // ? Name
        @AuraEnabled public String VSBED     {get;set;} // ? Shipping Conditions
        @AuraEnabled public String VTEXT4    {get;set;} // ? Description of the shipping conditions
        @AuraEnabled public String VKORG     {get;set;} // ? Sales Organization
        @AuraEnabled public String VTEXT5    {get;set;} // ? Description
        @AuraEnabled public String VTWEG     {get;set;} // ? Distribution Channel
        @AuraEnabled public String VTEXT6    {get;set;} // ? Description
        @AuraEnabled public String SPART     {get;set;} // ? Division
        @AuraEnabled public String VTEXT7    {get;set;} // ? Description
        @AuraEnabled public String MDLNM     {get;set;} // ? Model Name
        @AuraEnabled public String MATNR     {get;set;} // ? Material Number
        @AuraEnabled public String MAKTX     {get;set;} // ? Material Description (Short Text)
        @AuraEnabled public String MEINS     {get;set;} // ? Base Unit of Measure
        @AuraEnabled public String ADRNR     {get;set;} // ? Address
        @AuraEnabled public String FLAG      {get;set;} // ? Assign Flag(D:delete)
        @AuraEnabled public String STCD4     {get;set;} // ? Tax Number 4
        @AuraEnabled public String SATNR     {get;set;} // ? Cross-Plant Configurable Material
        @AuraEnabled public String AUFSD     {get;set;} // ? Customer order block (sales area)
        @AuraEnabled public String J_1KFREPRE {get;set;} // ? Name of Representative
        @AuraEnabled public String VBELN     {get;set;} // ? Sales Document
        @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date
        @AuraEnabled public String VRKME     {get;set;} // ? Sales unit
        @AuraEnabled public String LFIMG     {get;set;} // ? Actual quantity delivered (in sales units)
        @AuraEnabled public String TOTAL_LFIMG {get;set;} // ? Actual quantity delivered (in sales units)
        @AuraEnabled public String ZSEXTEN   {get;set;} // ? X : 4140 sales area extended, space : not extended
        @AuraEnabled public String ZMESSAGE  {get;set;} // ? Message: Please Extend Salea area(1140/10/10) of Ship to
        @AuraEnabled public String STCD3     {get;set;} // ? Tax Number 3
        @AuraEnabled public String KONZS     {get;set;} // ? Group key
        @AuraEnabled public String NAME_GR   {get;set;} // ? GKAM customer Mother text
        @AuraEnabled public String KATR10    {get;set;} // ? GKAM 수요산업 구분 1
        @AuraEnabled public String VTEXT10   {get;set;} // ? GKAM 수요산업 구분 1 TEXT
        @AuraEnabled public String KATR20    {get;set;} // ? GKAM 수요산업 구분 2
        @AuraEnabled public String VTEXT20   {get;set;} // ? GKAM 수요산업 구분 2 TEXT
        @AuraEnabled public String KATR30    {get;set;} // ? GKAM 수요산업 구분 3
        @AuraEnabled public String VTEXT30   {get;set;} // ? GKAM 수요산업 구분 3 TEXT
        @AuraEnabled public String GKAM_M    {get;set;} // ? M:GKAM Mother Customer
        @AuraEnabled public String ZTURNOVER {get;set;} // ? Turnover
        @AuraEnabled public String ZEMPL     {get;set;} // ? No. of employees
        @AuraEnabled public String ZPRESI    {get;set;} // ? President
        @AuraEnabled public String ZYEAR     {get;set;} // ? Year established
        @AuraEnabled public String ZHEADQ    {get;set;} // ? Headquarters
        @AuraEnabled public String ZVOL      {get;set;} // ? Number of manufacturing and operational sites
        @AuraEnabled public String ZPROD     {get;set;} // ? Production
        @AuraEnabled public String ZBUYER    {get;set;} // ? Main buyers
        @AuraEnabled public String ZWEBPAGE  {get;set;} // ? Web page
        @AuraEnabled public String REGIO_T   {get;set;} // ? Region text
        @AuraEnabled public String SMTP_ADDR {get;set;} // ? E-Mail Address

        @AuraEnabled public String SORT1      {get;set;} //? Search Term 1
        @AuraEnabled public String SORT2      {get;set;} //? Search Term 2
        @AuraEnabled public String LZONE      {get;set;} //? Transportation zone to or from which the goods are delivered
        @AuraEnabled public String SPRAS      {get;set;} //? Language Key
        @AuraEnabled public String STR_SUPPL1     {get;set;} //? Street 2
        @AuraEnabled public String STR_SUPPL2     {get;set;} //? Street 3
        @AuraEnabled public String STR_SUPPL3     {get;set;} //? Street 4        
      }

      public class IF_ACCOUNT_005_Res_T_KNVV{
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1 
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String BZIRK {get;set;} // ? Sales district
          @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String VKGRP {get;set;} // ? Sales Group
          @AuraEnabled public String KDGRP {get;set;} // ? Customer group
          @AuraEnabled public String WAERS {get;set;} // ? Currency Key
          @AuraEnabled public String INCO1 {get;set;} // ? Incoterms (Part 1)
          @AuraEnabled public String ZTERM {get;set;} // ? Warrenty Term
          @AuraEnabled public String KTGRD {get;set;} // ? Account assignment group for this customer
          @AuraEnabled public String VSBED {get;set;} // ? Shipping Conditions
          @AuraEnabled public String AUFSD {get;set;} // ? add v1.3 -> block checking : Customer blocked for orders     
      }

      public class IF_ACCOUNT_005_Res_T_KNVP{
        @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1 
        @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
        @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
        @AuraEnabled public String SPART {get;set;} // ? Division
        @AuraEnabled public String PARVW {get;set;} // ? Partner Function
        @AuraEnabled public String VTEXT {get;set;} // ? Description
        @AuraEnabled public String KUNN2 {get;set;} // ? Customer number of business partner
        @AuraEnabled public String KNREF {get;set;} // ? Customer description of partner (plant, storage location)
        @AuraEnabled public String DEFPA {get;set;} // ? Default Partner        
      }

/** IF_ACCOUNT_014 
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_014
         * SFDC interface Id    : IF-ACCOUNT-014
         * AS-IS RFC            : Z_SD_MS_CU_CHK
         * New I/F              : ZCRM_SD_MS_CU_CHK
         * Description          : 잠재 고객 중복 조회 => 잠재 고객이 ERP상에 존재여부 확인
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */  
        public class IF_ACCOUNT_014_Req {
          public IF_ACCOUNT_014_Req(){} 
          @AuraEnabled public String I_NAME1      {get;set;} // ? Name 1
          @AuraEnabled public String I_J_1KFREPRE {get;set;} // ? Representative Name

          // @AuraEnabled public String I_LOCATION {get;set;} // ? Street 5
          // @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
          // @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel
          // @AuraEnabled public String I_SPART {get;set;} // ? Division
    
          // @AuraEnabled public String I_DEALER {get;set;} // ? Dealer
          // @AuraEnabled public String I_SPRAS {get;set;} // ? Language
          // @AuraEnabled public String I_STCD2 {get;set;} // ? Tax Number 2
        }

    /** RESPONSE 
      */  
        public class IF_ACCOUNT_014_Res { 
          @AuraEnabled public String O_RECODE {get;set;} // ? S: success(고객생성가능) F: Fail(고객생성불가능)
          @AuraEnabled public String O_REMSG  {get;set;} // ? Message Text
          @AuraEnabled public String O_RETURN {get;set;} // ? Y:Dup, N:No data, S:Sales View 확장, D :Deletion Flag
    
          @AuraEnabled public List<IF_ACCOUNT_014_Res_T_KNA1> T_KNA1 {get;set;} 

          public IF_ACCOUNT_014_Res(){
              this.T_KNA1 = new List<IF_ACCOUNT_014_Res_T_KNA1>();
          }
        }
    
        public class IF_ACCOUNT_014_Res_T_KNA1 { 
          public IF_ACCOUNT_014_Res_T_KNA1(){}
          @AuraEnabled public String KUNNR     {get;set;} // ? Customer Number 1
          @AuraEnabled public String NAME1     {get;set;} // ? Name 1
          @AuraEnabled public String ORT01     {get;set;} // ? City
          @AuraEnabled public String STRAS     {get;set;} // ? House number and street
          @AuraEnabled public String LAND1     {get;set;} // ? Country Key
    
          @AuraEnabled public String LANDX     {get;set;} // ? Country Name
          @AuraEnabled public String ERNAM     {get;set;} // ? Name of Person who Created the Object
          @AuraEnabled public String ERDAT     {get;set;} // ? Date on which the Record Was Created
          @AuraEnabled public String KTOKD     {get;set;} // ? Customer Account Group
          @AuraEnabled public String KDGRP     {get;set;} // ? Customer group
    
          @AuraEnabled public String KTEXT     {get;set;} // ? Name
          @AuraEnabled public String ANRED     {get;set;} // ? Title
          @AuraEnabled public String LOCATION  {get;set;} // ? Street 5
          @AuraEnabled public String REGIO     {get;set;} // ? Region (State, Province, County)
          @AuraEnabled public String SORTL     {get;set;} // ? Sort field
    
          @AuraEnabled public String NAME3     {get;set;} // ? Name 3
          @AuraEnabled public String PSTLZ     {get;set;} // ? Postal Code
          @AuraEnabled public String TELF1     {get;set;} // ? First telephone number
          @AuraEnabled public String TELF2     {get;set;} // ? Second telephone number
          @AuraEnabled public String TELFX     {get;set;} // ? Fax Number
    
          @AuraEnabled public String KNURL     {get;set;} // ? Uniform Resource Locator
          @AuraEnabled public String KATR1     {get;set;} // ? Customer group 1
          @AuraEnabled public String VTEXT1    {get;set;} // ? Description
          @AuraEnabled public String KATR2     {get;set;} // ? Customer group 2
          @AuraEnabled public String VTEXT2    {get;set;} // ? Description
    
          @AuraEnabled public String KATR3     {get;set;} // ? Customer group 3
          @AuraEnabled public String VTEXT3    {get;set;} // ? Description
          @AuraEnabled public String STCD1     {get;set;} // ? Tax Number 1
          @AuraEnabled public String STCD2     {get;set;} // ? Tax Number 2
          @AuraEnabled public String J_1KFTBUS {get;set;} // ? Type of Business
    
          @AuraEnabled public String J_1KFTIND {get;set;} // ? Type of Industry
          @AuraEnabled public String JMZAH     {get;set;} // ? Yearly number of employees
          @AuraEnabled public String JMJAH     {get;set;} // ? Year for which the number of employees is given
          @AuraEnabled public String BZIRK     {get;set;} // ? Sales district
          @AuraEnabled public String BZTXT     {get;set;} // ? Name of the district
    
          @AuraEnabled public String VKBUR     {get;set;} // ? Sales Office
          @AuraEnabled public String BEZEI     {get;set;} // ? Name of the controlling area
          @AuraEnabled public String KTONR     {get;set;} // ? Customer number of business partner
          @AuraEnabled public String NAME22    {get;set;} // ? Name
          @AuraEnabled public String VSBED     {get;set;} // ? Shipping Conditions
    
          @AuraEnabled public String VTEXT4    {get;set;} // ? Description of the shipping conditions
          @AuraEnabled public String VKORG     {get;set;} // ? Sales Organization
          @AuraEnabled public String VTEXT5    {get;set;} // ? Description
          @AuraEnabled public String VTWEG     {get;set;} // ? Distribution Channel
          @AuraEnabled public String VTEXT6    {get;set;} // ? Description
    
          @AuraEnabled public String SPART     {get;set;} // ? Division
          @AuraEnabled public String VTEXT7    {get;set;} // ? Description
          @AuraEnabled public String MDLNM     {get;set;} // ? Model Name
          @AuraEnabled public String MATNR     {get;set;} // ? Material Number
          @AuraEnabled public String MAKTX     {get;set;} // ? Material Description (Short Text)
    
          @AuraEnabled public String MEINS     {get;set;} // ? Base Unit of Measure
          @AuraEnabled public String ADRNR     {get;set;} // ? Address
          @AuraEnabled public String FLAG      {get;set;} // ? Assign Flag(D:delete)
          @AuraEnabled public String STCD4     {get;set;} // ? Tax Number 4
          @AuraEnabled public String SATNR     {get;set;} // ? Cross-Plant Configurable Material
    
          @AuraEnabled public String AUFSD     {get;set;} // ? Customer order block (sales area)
          @AuraEnabled public String J_1KFREPRE {get;set;} // ? Name of Representative
          @AuraEnabled public String VBELN     {get;set;} // ? Sales Document
          @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date
          @AuraEnabled public String VRKME     {get;set;} // ? Sales unit
    
          @AuraEnabled public String LFIMG     {get;set;} // ? Actual quantity delivered (in sales units)
          @AuraEnabled public String TOTAL_LFIMG {get;set;} // ? Actual quantity delivered (in sales units)
          @AuraEnabled public String ZSEXTEN   {get;set;} // ? X : 4140 sales area extended, space : not extended
          @AuraEnabled public String ZMESSAGE  {get;set;} // ? Message: Please Extend Salea area(1140/10/10) of Ship to
          @AuraEnabled public String STCD3     {get;set;} // ? Tax Number 3
    
          @AuraEnabled public String KONZS     {get;set;} // ? Group key
          @AuraEnabled public String NAME_GR   {get;set;} // ? GKAM customer Mother text
          @AuraEnabled public String KATR10    {get;set;} // ? GKAM 수요산업 구분 1
          @AuraEnabled public String VTEXT10   {get;set;} // ? GKAM 수요산업 구분 1 TEXT
          @AuraEnabled public String KATR20    {get;set;} // ? GKAM 수요산업 구분 2
    
          @AuraEnabled public String VTEXT20   {get;set;} // ? GKAM 수요산업 구분 2 TEXT
          @AuraEnabled public String KATR30    {get;set;} // ? GKAM 수요산업 구분 3
          @AuraEnabled public String VTEXT30   {get;set;} // ? GKAM 수요산업 구분 3 TEXT
          @AuraEnabled public String GKAM_M    {get;set;} // ? M:GKAM Mother Customer
          @AuraEnabled public String ZTURNOVER {get;set;} // ? Turnover
    
          @AuraEnabled public String ZEMPL     {get;set;} // ? No. of employees
          @AuraEnabled public String ZPRESI    {get;set;} // ? President
          @AuraEnabled public String ZYEAR     {get;set;} // ? Year established
          @AuraEnabled public String ZHEADQ    {get;set;} // ? Headquarters
          @AuraEnabled public String ZVOL      {get;set;} // ? Number of manufacturing and operational sites
    
          @AuraEnabled public String ZPROD     {get;set;} // ? Production
          @AuraEnabled public String ZBUYER    {get;set;} // ? Main buyers
          @AuraEnabled public String ZWEBPAGE  {get;set;} // ? Web page
          @AuraEnabled public String REGIO_T   {get;set;} // ? Region text
          @AuraEnabled public String SMTP_ADDR {get;set;} // ? E-Mail Address
          }      

/** IF_ACCOUNT_017
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_017
         * SFDC interface Id    : IF-ACCOUNT-017
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_GET_DEALER_GRADE_LIST
         * Description          : 고객 마스터-대리점 등급 정보 조회 
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
         * 
         분석 
          유효 일자 범위를 기준으로 딜러 등급 데이터를 조회 
     */            
    /** REQUEST 
      */  
      public class IF_ACCOUNT_017_Req {
        public IF_ACCOUNT_017_Req(){} 
        @AuraEnabled public String I_FROMDATE {get;set;} // ? Validity end date of the condition record
        @AuraEnabled public String I_TODATE {get;set;} // ? Validity start date of the condition record
      }

  /** RESPONSE 
    */        
      public class IF_ACCOUNT_017_Res {
        public IF_ACCOUNT_017_Res(){} 

        @AuraEnabled public IF_ACCOUNT_017_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_ACCOUNT_017_Res_T_LIST> T_LIST {get;set;} 
  
      }
  
      public class IF_ACCOUNT_017_Res_O_RETURN { 
        public IF_ACCOUNT_017_Res_O_RETURN(){} 

        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
      }
  
      public class IF_ACCOUNT_017_Res_T_LIST {
        public IF_ACCOUNT_017_Res_T_LIST(){} 

        @AuraEnabled public String MANDT {get;set;} // ? Client
        @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
        @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
        @AuraEnabled public String SPART {get;set;} // ? Division
        @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
  
        @AuraEnabled public String NAME1 {get;set;} // ? Name
        @AuraEnabled public String KVGR4 {get;set;} // ? Customer group 4
        @AuraEnabled public String DATBI {get;set;} // ? Validity end date of the condition record
        @AuraEnabled public String DATAB {get;set;} // ? Validity start date of the condition record
      }

/** IF_ACCOUNT_012
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_012
         * SFDC interface Id    : IF-ACCOUNT-012
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_MS_TC_CRE
         * Description          : 실고객 생성 - 신규 고객 마스터 정보 반환하여 ERP & CRM 데이터 동기화
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
     */            
    /** REQUEST 
      */
        public class IF_ACCOUNT_012_Req { 
          public IF_ACCOUNT_012_Req(){}
          @AuraEnabled public String I_ANRED    {get;set;} // ? Title / Company, Mr., Mrs. 등…
          @AuraEnabled public String I_NAME1    {get;set;} // ? Name 1 / 회사명
          @AuraEnabled public String I_NAME3    {get;set;} // ? Name 3 / Name1에 대한 추가적인 정보
          @AuraEnabled public String I_SORT1    {get;set;} // ? 고객과 관련된 특정 키워드, 코드, 별칭 등
          @AuraEnabled public String I_LOCATION {get;set;} // ? Additional address field

          @AuraEnabled public String I_COUNTRY  {get;set;} // ? Country Key
          @AuraEnabled public String I_REGION   {get;set;} // ? Region Code (State, Province, County) ex)경상남도, 경기도…
          @AuraEnabled public String I_PSTLZ    {get;set;} // ? Postal Code
          @AuraEnabled public String I_STREET   {get;set;} // ? address
          @AuraEnabled public String I_CITY1    {get;set;} // ? City name as part of the address.

          @AuraEnabled public String I_TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
          @AuraEnabled public String I_MOB_NUMBER {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
          @AuraEnabled public String I_FAX_NUMBER {get;set;} // ? First fax no.: dialling code+number
          @AuraEnabled public String I_SMTP_ADDR {get;set;} // ? 홈페이지 주소
          @AuraEnabled public String I_JMZAH    {get;set;} // ? Yearly number of employees (연간 평균 직원 수)

          @AuraEnabled public String I_JMJAH    {get;set;} // ? Year for which the number of employees is given(직원 수가 기준이 되는 연도)
          @AuraEnabled public String I_KATR1    {get;set;} // ? Customer group 1 / Customer Group1~3 분류
          @AuraEnabled public String I_KATR2    {get;set;} // ? Customer group 2 / Customer Group1~3 분류
          @AuraEnabled public String I_KATR3    {get;set;} // ? Customer group 3 / Customer Group1~3 분류
          @AuraEnabled public String I_J_1KFTBUS {get;set;} // ? Type of Business

          @AuraEnabled public String I_J_1KFTIND {get;set;} // ? Type of Industry
          @AuraEnabled public String I_VKBUR    {get;set;} // ? Sales Office
          @AuraEnabled public String I_BZIRK    {get;set;} // ? Sales district
          @AuraEnabled public String I_TAXNUMBER1 {get;set;} // ? 사업자번호 
          @AuraEnabled public String I_KTONR    {get;set;} // ? Number of an SD business partner

          @AuraEnabled public String I_VKORG    {get;set;} // ? Sales Organization / '1846' 으로 고정해야함.
          @AuraEnabled public String I_VTWEG    {get;set;} // ? Distribution Channel
          @AuraEnabled public String I_SPART    {get;set;} // ? Division
          @AuraEnabled public String I_DEALER   {get;set;} // ? Dealer
          @AuraEnabled public String I_SPRAS    {get;set;} // ? Language

          @AuraEnabled public String I_TAXNUMBER4 {get;set;} // ? Tax Number 4(영업집조번호-15)
          @AuraEnabled public String I_EMAIL    {get;set;} // ? E-Mail Address(진짜 이메일)
          @AuraEnabled public String I_VSBED    {get;set;} // ? Shipping Conditions
          @AuraEnabled public String I_INCO1    {get;set;} // ? Incoterms (Part 1)
          @AuraEnabled public String I_INCO2    {get;set;} // ? Additional information for the primary Incoterm.

          @AuraEnabled public String I_ZTERM    {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String I_KTGRD    {get;set;} // ? Account assignment group for this customer
          @AuraEnabled public String I_TAXKD_CN {get;set;} // ? Tax classification for China
          @AuraEnabled public String I_TAXKD_KR {get;set;} // ? Tax classification for South Korea
          @AuraEnabled public String I_NAME     {get;set;} // ? 대표자 명

          // add since v1.2  
          @AuraEnabled public String I_PLTYP      {get;set;} // ? Price list type  v1.2
          @AuraEnabled public String I_KATR5      {get;set;} // ? Customer group 3 / Customer Group1~3, 5 분류 v1.2
          @AuraEnabled public String I_WAERS      {get;set;}
          @AuraEnabled public String I_NAME_CO    {get;set;}
          @AuraEnabled public String I_STR_SUPPL1 {get;set;}
          @AuraEnabled public String I_LZONE      {get;set;}

        }
        
    /** RESPONSE 
      */        
        public class IF_ACCOUNT_012_Res { 
          public IF_ACCOUNT_012_Res(){}
          @AuraEnabled public String O_RECODE {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String O_REMSG {get;set;} // ? Message Text
          @AuraEnabled public String O_KUNNR {get;set;} // ? 생성된 실고객 번호
          @AuraEnabled public String O_DUP {get;set;} // ? Duplication Flag / 중복생성일 경우 체크

          @AuraEnabled public List<IF_ACCOUNT_012_Res_ET_DATA> ET_DATA {get;set;} 
        }

        public class IF_ACCOUNT_012_Res_ET_DATA { 
          public IF_ACCOUNT_012_Res_ET_DATA(){}
          @AuraEnabled public String KUNNR_ZI {get;set;} // ? Related Dealer Number
          @AuraEnabled public String NAME1_ZI {get;set;} // ? Related Dealer Description
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number
          @AuraEnabled public String NAME1 {get;set;} // ? Customer Description
          @AuraEnabled public String TELF1 {get;set;} // ? First telephone number

          @AuraEnabled public String TELF2 {get;set;} // ? Second telephone number
          @AuraEnabled public String TELFX {get;set;} // ? Fax Number
          @AuraEnabled public String KNURL {get;set;} // ? Uniform Resource Locator
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel

          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String LAND1 {get;set;} // ? Country Key
          @AuraEnabled public String KTOKD {get;set;} // ? Customer Account Group
          @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String ERZET {get;set;} // ? Entry time

        }

/** IF_ACCOUNT_018
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_018
         * SFDC interface Id    : IF-ACCOUNT-018
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_CUSTOMER_SA_CRE				
         * Description          : Sales Area Data 생성
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
     */            
    /** REQUEST 
      */
        public class IF_ACCOUNT_018_Req { 
          @AuraEnabled public String I_KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String I_PLTYP {get;set;} // ? Price list type
          @AuraEnabled public String I_KALKS {get;set;} // ? Pricing procedure assigned to this customer
          @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel

          @AuraEnabled public String I_SPART {get;set;} // ? Division
          @AuraEnabled public String I_BZIRK {get;set;} // ? Sales district
          @AuraEnabled public String I_VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String I_KDGRP {get;set;} // ? Customer group
          @AuraEnabled public String I_WAERS {get;set;} // ? Currency Key

          @AuraEnabled public String I_INCO1 {get;set;} // ? Incoterms (Part 1)
          @AuraEnabled public String I_ZTERM {get;set;} // ? Warrenty Term
          @AuraEnabled public String I_KTGRD {get;set;} // ? Account assignment group for this customer
          @AuraEnabled public String I_VSBED {get;set;} // ? Shipping Conditions
          @AuraEnabled public String I_TAXKD_01 {get;set;} // ? Tax classification for customer

          @AuraEnabled public String I_TAXKD_02 {get;set;} // ? Tax classification for customer
          @AuraEnabled public String I_KVGR1 {get;set;} // ? Customer group 1
          @AuraEnabled public String I_KVGR2 {get;set;} // ? Customer group 1
          @AuraEnabled public String I_KVGR3 {get;set;} // ? Customer group 1
          @AuraEnabled public String I_KVGR5 {get;set;}
          @AuraEnabled public String I_VWERK {get;set;}

        }
    /** RESPONSE   
      */        
        public class IF_ACCOUNT_018_Res { 
          @AuraEnabled public String O_KUNNR {get;set;} // ? Customer Number 1

          @AuraEnabled public List<IF_ACCOUNT_018_Res_OT_RETURN> OT_RETURN {get;set;} 
        }

        public class IF_ACCOUNT_018_Res_OT_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }


/** IF_ACCOUNT_019
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_019
         * SFDC interface Id    : IF-ACCOUNT-019
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_CUSTOMER_SA_CHG 				
         * Description          : 고객 마스터 Sales Area 수정
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
     */            
    /** REQUEST 
      */
      public class IF_ACCOUNT_019_Req {
        @AuraEnabled public String I_KUNNR   {get;set;}
        @AuraEnabled public String I_VSBED   {get;set;}
        @AuraEnabled public IF_ACCOUNT_019_Req_I_SALES_AREA   I_SALES_AREA     {get;set;}
        @AuraEnabled public IF_ACCOUNT_019_Req_I_SALES_DETAIL I_SALES_DETAIL   {get;set;}
        @AuraEnabled public IF_ACCOUNT_019_Req_I_BILLING      I_BILLING        {get;set;}
     }      
     
     public class IF_ACCOUNT_019_Req_I_SALES_AREA{
        @AuraEnabled public String VKORG {get;set;}
        @AuraEnabled public String VTWEG {get;set;}
        @AuraEnabled public String SPART {get;set;}        
     }
     public class IF_ACCOUNT_019_Req_I_SALES_DETAIL{
        @AuraEnabled public String KALKS {get;set;}
        @AuraEnabled public String BZIRK {get;set;}
        @AuraEnabled public String VKBUR {get;set;}
        @AuraEnabled public String KDGRP {get;set;}
        @AuraEnabled public String WAERS {get;set;}      
     }
     public class IF_ACCOUNT_019_Req_I_BILLING{
        @AuraEnabled public String INCO1 {get;set;}
        @AuraEnabled public String INCO2 {get;set;}
        @AuraEnabled public String ZTERM {get;set;}
        @AuraEnabled public String KTGRD {get;set;}
        @AuraEnabled public String TAXKD_01 {get;set;}
        @AuraEnabled public String TAXKD_02 {get;set;}      
     }     

     public class IF_ACCOUNT_019_Res{
      @AuraEnabled public String O_KUNNR {get;set;}
      @AuraEnabled public IF_ACCOUNT_019_Res_O_RETURN O_RETURN {get;set;}
     }

     public class IF_ACCOUNT_019_Res_O_RETURN{
        @AuraEnabled public String TYPE {get;set;}
        @AuraEnabled public String CODE {get;set;}
        @AuraEnabled public String MESSAGE {get;set;}
     }



          
}