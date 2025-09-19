public with sharing class IF_ERP_ShipmentOrder_Classes {
    public IF_ERP_ShipmentOrder_Classes() {}


/** IF_CSPLUS_029
    */  
    /**
         * Apex Class           : IF_ERP_ShipmentOrder
         * Wrapper Class        : IF_ERP_ShipmentOrder_Classes
         * Wrapper Name         : IF_CSPLUS_029
         * SFDC interface Id    : IF-CSPLUS-029
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_CS_MT_GET_SHIPPING_DOC_IN
         * Description          : 장비의 출하지시서 조회  - 기존 출하지시서 I/F(5건) 통합으로 신규 생성 
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */    
      public class IF_CSPLUS_029_Req { 
        public IF_CSPLUS_029_Req(){}
        @AuraEnabled public String I_TYPBZ    {get;set;} // ? Manufacturer model number
        @AuraEnabled public String I_SERNR    {get;set;} // ? Serial number
        @AuraEnabled public String I_DEL_FLAG {get;set;} // ? 삭제 레코드 조회 여부
      
      }

  
    /** RESPONSE 
      */              
      public class IF_CSPLUS_029_Res {
        public IF_CSPLUS_029_Res(){}

        @AuraEnabled public IF_CSPLUS_029_Res_O_RETURN                      O_RETURN                {get;set;} 
        @AuraEnabled public IF_CSPLUS_029_Res_O_HEADER                      O_HEADER                {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_029_Res_T_O_Classification>      T_O_Classification      {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_029_Res_T_O_MANNUAL>             T_O_MANNUAL             {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_029_Res_T_O_REMARK>              T_O_REMARK              {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_029_Res_T_O_MATERIAL >           T_O_MATERIAL            {get;set;} 
        // @AuraEnabled public List<IF_CSPLUS_029_Res_T_O_SO_ITEMS >        T_O_SO_ITEMS            {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST > T_O_SHIPPING_PART_LIST  {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_029_Res_T_O_RSP_LIST>            T_O_RSP_LIST            {get;set;} 
  
      }
  
        public class IF_CSPLUS_029_Res_O_RETURN {
          public IF_CSPLUS_029_Res_O_RETURN(){}

          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }
  
        public class IF_CSPLUS_029_Res_O_HEADER {
          public IF_CSPLUS_029_Res_O_HEADER(){}

          @AuraEnabled public String CONT_NO {get;set;} // ? Contract no or Sales order
          @AuraEnabled public String ISSUE_NO {get;set;} // ? Issue no or Delivery no
          @AuraEnabled public String TYPBZ {get;set;} // ? Manufacturer model number
          @AuraEnabled public String SERNR {get;set;} // ? Serial number
          @AuraEnabled public String TYPE  {get;set;} // ? TYPE
    
          @AuraEnabled public String WADAT {get;set;} // ? Goods Issue Date
          @AuraEnabled public String INBDT {get;set;} // ? First start-up date
        }
  
        public class IF_CSPLUS_029_Res_T_O_Classification { 
          public IF_CSPLUS_029_Res_T_O_Classification(){}

          @AuraEnabled public String WKADDR  {get;set;} // ? Characteristic
          @AuraEnabled public String WKVALUE {get;set;} // ? Value
        }
  
        public class IF_CSPLUS_029_Res_T_O_MANNUAL { 
          public IF_CSPLUS_029_Res_T_O_MANNUAL(){}

          @AuraEnabled public String MANDT {get;set;} // ? Client
          @AuraEnabled public String MANULDV {get;set;} // ? Mannual Classification
          @AuraEnabled public String MANUL {get;set;} // ? Mannual Description
          @AuraEnabled public String BOOKN {get;set;} // ? Book number
          @AuraEnabled public String COPIS {get;set;} // ? Copies
    
          @AuraEnabled public String PPNOF {get;set;} // ? Notification Number
          @AuraEnabled public String SPRAS  {get;set;} // ? Language 
          @AuraEnabled public String SLANG  {get;set;} // ? 표준매뉴얼 언어 
          @AuraEnabled public String SERIAL {get;set;} // ? Serial number                     
        }
  
        public class IF_CSPLUS_029_Res_T_O_REMARK {
          public IF_CSPLUS_029_Res_T_O_REMARK(){}
          @AuraEnabled public String TDFORMAT {get;set;} // ? 
          @AuraEnabled public String ZTEXT {get;set;} // ? Text
        }
  
        public class IF_CSPLUS_029_Res_T_O_MATERIAL  { 
          public IF_CSPLUS_029_Res_T_O_MATERIAL(){}
          @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item 
          @AuraEnabled public String MATNR {get;set;} // ? Material Number 
          @AuraEnabled public String ARKTX {get;set;} // ? Short text for sales order item 
          @AuraEnabled public String ATWRT {get;set;} // ? Characteristic Value 
          @AuraEnabled public String KWMENG {get;set;} // ?  Order Qty                                       
          @AuraEnabled public String VRKME {get;set;} // ? Sales unit 
          @AuraEnabled public String BESKZ {get;set;} // ? Procurement Type 
          @AuraEnabled public String CUOBJ {get;set;} // ? Configuration 
          @AuraEnabled public String MTART {get;set;} // ? Material Type 
          @AuraEnabled public String ZZFOR {get;set;} // ? Foreign Indicator 
          @AuraEnabled public String STICO {get;set;} // ? 상태 아이콘                                       
          @AuraEnabled public String MSGTY {get;set;} // ? Message Type 
          @AuraEnabled public String MSGTX {get;set;} // ? Message text           
        }
    
        public class IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST  {
          public  IF_CSPLUS_029_Res_T_O_SHIPPING_PART_LIST(){}
          @AuraEnabled public String MANDT {get;set;} // ? Client
          @AuraEnabled public String PPNOF {get;set;} // ? Notification Number
          @AuraEnabled public String POSNR {get;set;} // ? Item number of the SD document
          @AuraEnabled public String MATNR {get;set;} // ? Material Number
          @AuraEnabled public String ZSPEC {get;set;} // ? Spec
    
          @AuraEnabled public String MENGE {get;set;} // ? Quantity
          @AuraEnabled public String MEINS {get;set;} // ? Base Unit of Measure
          @AuraEnabled public String ISSUE {get;set;} // ? Indicator: issue deliveries
          @AuraEnabled public String BESKZ {get;set;} // ? Procurement Type
          @AuraEnabled public String SCHGT {get;set;} // ? Indicator: Bulk Material
    
          @AuraEnabled public String POSNR_VA {get;set;} // ? Sales Document Item
          @AuraEnabled public String PSTYV {get;set;} // ? Sales document item category
          @AuraEnabled public String BEAKZ {get;set;} // ? Line already processed
          @AuraEnabled public String MARKT {get;set;} // ? Indicator for selected line
          @AuraEnabled public String REMAK {get;set;} // ? Remark
    
          @AuraEnabled public String ZWARE {get;set;} // ? Warehouse Controller
          @AuraEnabled public String ERNAM {get;set;} // ? User who Created Record
          @AuraEnabled public String ERDAT {get;set;} // ? Date Record Created on (Date)
          @AuraEnabled public String ERTIM {get;set;} // ? Time Record Created at (Time)
          @AuraEnabled public String AENAM {get;set;} // ? User who Changed Record
    
          @AuraEnabled public String AEDAT {get;set;} // ? Date Record Changed on (Date)
          @AuraEnabled public String AETIM {get;set;} // ? Time when Record Was Changed
          @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String ETENR {get;set;} // ? Delivery Schedule Line Number
          @AuraEnabled public String ETTYP {get;set;} // ? Schedule line category
    
          @AuraEnabled public String SOBSL {get;set;} // ? Special procurement type
          @AuraEnabled public String LGPRO {get;set;} // ? Issue Storage Location
          @AuraEnabled public String LGPRO_F {get;set;} // ?  X:저장위치 오류                                 
          @AuraEnabled public String STICO {get;set;} // ?  상태아이콘
          @AuraEnabled public String MSGTY {get;set;} // ? Message Type
    
          @AuraEnabled public String MSGTX {get;set;} // ? Message text
        }
    
        public class IF_CSPLUS_029_Res_T_O_RSP_LIST {
          public IF_CSPLUS_029_Res_T_O_RSP_LIST(){} 
          @AuraEnabled public String MANDT {get;set;} // ? Client
          @AuraEnabled public String PPNOF {get;set;} // ? Notification Number
          @AuraEnabled public String POSNR {get;set;} // ? Item number of the SD document
          @AuraEnabled public String MATNR {get;set;} // ? Material Number
          @AuraEnabled public String ZSPEC {get;set;} // ? Spec
    
          @AuraEnabled public String MENGE {get;set;} // ? Quantity
          @AuraEnabled public String MEINS {get;set;} // ? Base Unit of Measure
          @AuraEnabled public String ISSUE {get;set;} // ? Indicator: issue deliveries
          @AuraEnabled public String BESKZ {get;set;} // ? Procurement Type
          @AuraEnabled public String SCHGT {get;set;} // ? Indicator: Bulk Material
    
          @AuraEnabled public String POSNR_VA {get;set;} // ? Sales Document Item
          @AuraEnabled public String PSTYV {get;set;} // ? Sales document item category
          @AuraEnabled public String BEAKZ {get;set;} // ? Line already processed
          @AuraEnabled public String MARKT {get;set;} // ? Indicator for selected line
          @AuraEnabled public String REMAK {get;set;} // ? Remark
    
          @AuraEnabled public String ZWARE {get;set;} // ? Warehouse Controller
          @AuraEnabled public String ERNAM {get;set;} // ? User who Created Record
          @AuraEnabled public String ERDAT {get;set;} // ? Date Record Created on (Date)
          @AuraEnabled public String ERTIM {get;set;} // ? Time Record Created at (Time)
          @AuraEnabled public String AENAM {get;set;} // ? User who Changed Record
    
          @AuraEnabled public String AEDAT {get;set;} // ? Date Record Changed on (Date)
          @AuraEnabled public String AETIM {get;set;} // ? Time when Record Was Changed
          @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String ETENR {get;set;} // ? Delivery Schedule Line Number
          @AuraEnabled public String ETTYP {get;set;} // ? Schedule line category
    
          @AuraEnabled public String SOBSL {get;set;} // ? Special procurement type
          @AuraEnabled public String LGPRO {get;set;} // ? Issue Storage Location
          @AuraEnabled public String LGPRO_F {get;set;} // ?  X:저장위치 오류                                 
          @AuraEnabled public String STICO {get;set;} // ?  상태아이콘
          @AuraEnabled public String MSGTY {get;set;} // ? Message Type
    
          @AuraEnabled public String MSGTX {get;set;} // ? Message text
        }

}