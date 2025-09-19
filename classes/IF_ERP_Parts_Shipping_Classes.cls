public with sharing class IF_ERP_Parts_Shipping_Classes {
    public IF_ERP_Parts_Shipping_Classes() {}

    // SFDC interface Id    : IF-PARTS-002
    // AS-IS RFC            : Z_EP_SHIPPING_INFO
    // New I/F              : ZCRM_EP_SHIPPING_INFO
    // Description          : 배송정보 목록 가져오기
    public class IF_PARTS_002_Req{
        @AuraEnabled public String I_VKORG      {get;set;}
        @AuraEnabled public String I_VTWEG      {get;set;}
        @AuraEnabled public String I_SPART      {get;set;}
        @AuraEnabled public String I_KUNNR      {get;set;}

        @AuraEnabled public String I_VSBED      {get;set;}
        @AuraEnabled public String I_ROUTE      {get;set;}
        @AuraEnabled public String I_ZTERM      {get;set;}
        @AuraEnabled public String I_LANG       {get;set;}
        
        public IF_PARTS_002_Req(){}
    }
    public class IF_PARTS_002_Res{
        @AuraEnabled public IF_PARTS_002_Res_O_RETURN           O_RETURN             {get;set;}
        @AuraEnabled public List<IF_PARTS_002_Res_T_LIST>       T_LIST               {get;set;}
        @AuraEnabled public List<IF_PARTS_002_Res_T_VALUE_SET>  T_VALUE_SET          {get;set;}

        public IF_PARTS_002_Res(){}
    }
    public class IF_PARTS_002_Res_O_RETURN{
        public IF_PARTS_002_Res_O_RETURN(){}
        @AuraEnabled public String TYPE             {get;set;}
        @AuraEnabled public String CODE             {get;set;}
        @AuraEnabled public String MESSAGE          {get;set;}
    }
    public class IF_PARTS_002_Res_T_LIST{
        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}

        @AuraEnabled public String VSBED        {get;set;}
        @AuraEnabled public String ROUTE        {get;set;}
        @AuraEnabled public String ZTERM        {get;set;}
        @AuraEnabled public String INCO1        {get;set;}
        
        @AuraEnabled public String INCO2        {get;set;}
        @AuraEnabled public String VSBED_TX     {get;set;}
        @AuraEnabled public String ROUTE_TX     {get;set;}
        @AuraEnabled public String ZTERM_TX     {get;set;}

        public IF_PARTS_002_Res_T_LIST(){}
    }
    public class IF_PARTS_002_Res_T_VALUE_SET{
        @AuraEnabled public String VALUE        {get;set;}
        @AuraEnabled public String TEXT         {get;set;}

        public IF_PARTS_002_Res_T_VALUE_SET(){}
    }

    // SFDC interface Id    : IF-PARTS-014
    // AS-IS RFC            : Z_CS_GET_DELIVERY_STAT_SHIP_NO
    // New I/F              : ZCRM_CS_GET_DELIVERY_STAT_SHIP_NO
    // Description          : 배송번호 조회
    public class IF_PARTS_014_Req{
        public IF_PARTS_014_Req_I_INPUT I_INPUT {get;set;}

        public IF_PARTS_014_Req(){}
    }
    public class IF_PARTS_014_Req_I_INPUT{
        @AuraEnabled public String TKNUM {get;set;}
        @AuraEnabled public String TDLNR {get;set;}
        @AuraEnabled public String EXTI1 {get;set;}
        @AuraEnabled public String EXTI2 {get;set;}

        @AuraEnabled public String ROUTE {get;set;}
        @AuraEnabled public String DTABF {get;set;}
        @AuraEnabled public String DATBG {get;set;}
        @AuraEnabled public String DATEN {get;set;}

        public IF_PARTS_014_Req_I_INPUT(){}
    }
    public class IF_PARTS_014_Res{
        @AuraEnabled public IF_PARTS_014_Res_O_RETURN       O_RETURN    {get;set;}
        @AuraEnabled public List<IF_PARTS_014_Res_T_LIST>   T_LIST      {get;set;}

        public IF_PARTS_014_Res(){}
    }
    public class IF_PARTS_014_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_PARTS_014_Res_O_RETURN(){}
    }
    public class IF_PARTS_014_Res_T_LIST{
        @AuraEnabled public String TKNUM    {get;set;}
        @AuraEnabled public String TDLNR    {get;set;}
        @AuraEnabled public String EXTI1    {get;set;}
        @AuraEnabled public String EXTI2    {get;set;}

        @AuraEnabled public String ROUTE    {get;set;}
        @AuraEnabled public String DTABF    {get;set;}
        @AuraEnabled public String DATBG    {get;set;}
        @AuraEnabled public String DATEN    {get;set;}

        public IF_PARTS_014_Res_T_LIST(){}
    }

    /** SFDC interface Id    : IF-PARTS-015
     *  RFC Name             : ZCRM_EP_SHIPMENT_LIST2
     *  Description          : 배송상태 조회
        */
        public class IF_PARTS_015_Req{
            @AuraEnabled public String I_FDATE                              {get;set;}
            @AuraEnabled public String I_TDATE                              {get;set;}
            @AuraEnabled public String I_TKNUM                              {get;set;}
            @AuraEnabled public String I_VBELN                              {get;set;}
            @AuraEnabled public String I_MATNR                              {get;set;}

            @AuraEnabled public String I_BSTNK                              {get;set;}
            @AuraEnabled public String I_STTRG                              {get;set;}
            @AuraEnabled public String I_LANGU                              {get;set;}
            @AuraEnabled public String I_GUBUN                              {get;set;}
            @AuraEnabled public IF_PARTS_015_Req_I_USERINFO I_USERINFO      {get;set;}

            public IF_PARTS_015_Req(){}
        }
        public class IF_PARTS_015_Req_I_USERINFO{
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

            public IF_PARTS_015_Req_I_USERINFO(){}
        }
        public class IF_PARTS_015_Res{
            @AuraEnabled public String O_MESG                                       {get;set;}
            @AuraEnabled public String O_COUNT                                      {get;set;}
            @AuraEnabled public IF_PARTS_015_Res_O_RETURN O_RETURN                  {get;set;}
            @AuraEnabled public List<IF_PARTS_015_Res_T_SALES_AREA> T_SALES_AREA    {get;set;}

            @AuraEnabled public List<IF_PARTS_015_Res_T_LIST> T_LIST                {get;set;}

            public IF_PARTS_015_Res(){}
        }
        public class IF_PARTS_015_Res_O_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
            @AuraEnabled public String LOG_NO       {get;set;}

            @AuraEnabled public String LOG_MSG_NO   {get;set;}
            @AuraEnabled public String MESSAGE_V1   {get;set;}
            @AuraEnabled public String MESSAGE_V2   {get;set;}
            @AuraEnabled public String MESSAGE_V3   {get;set;}
            
            @AuraEnabled public String MESSAGE_V4   {get;set;}

            public IF_PARTS_015_Res_O_RETURN(){}
        }
        public class IF_PARTS_015_Res_T_SALES_AREA{
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}
            @AuraEnabled public String SPART        {get;set;}

            public IF_PARTS_015_Res_T_SALES_AREA(){}
        }
        public class IF_PARTS_015_Res_T_LIST{
            @AuraEnabled public String TKNUM        {get;set;}
            @AuraEnabled public String COUNT1       {get;set;}
            @AuraEnabled public String COUNT2       {get;set;}
            @AuraEnabled public String NETWR        {get;set;}
            
            @AuraEnabled public String WAERK        {get;set;}
            @AuraEnabled public String BRGEW        {get;set;}
            @AuraEnabled public String GEWEI_MAX    {get;set;}
            @AuraEnabled public String BEZEI20      {get;set;}
            
            @AuraEnabled public String KUNNZ        {get;set;}
            @AuraEnabled public String NAME1        {get;set;}
            @AuraEnabled public String VSART        {get;set;}
            @AuraEnabled public String BEZEI        {get;set;}
            
            @AuraEnabled public String VSBED        {get;set;}
            @AuraEnabled public String VTEXT        {get;set;}
            @AuraEnabled public String TDLNR        {get;set;}
            @AuraEnabled public String NAME2        {get;set;}
            
            @AuraEnabled public String STTRG        {get;set;}
            @AuraEnabled public String STTRG_T      {get;set;}
            @AuraEnabled public String ZFCIVNO      {get;set;}
            @AuraEnabled public String ZFMBLNO      {get;set;}
            
            @AuraEnabled public String ZFOBDT       {get;set;}
            @AuraEnabled public String ZFETA        {get;set;}
            @AuraEnabled public String DATEN        {get;set;}
            @AuraEnabled public String VBELN        {get;set;}
            
            @AuraEnabled public String VGBEL        {get;set;}
            @AuraEnabled public String BSTNK        {get;set;}
            @AuraEnabled public String TPLST        {get;set;}
            @AuraEnabled public String BEZEI_T      {get;set;}
            
            @AuraEnabled public String EXTI1        {get;set;}
            @AuraEnabled public String KDINVOICE    {get;set;}
            @AuraEnabled public String VSTEL    {get;set;}

            public IF_PARTS_015_Res_T_LIST(){}
        }

    /** SFDC interface Id    : IF-PARTS-027
     *  AS-IS RFC            : ZCRM_EP_SHIPMENT_DETAIL 
     *  Description          : 배송세부정보 조회
        */
        public class IF_PARTS_027_Req{
            @AuraEnabled public String I_VKORG      {get;set;}
            @AuraEnabled public String I_VTWEG      {get;set;}
            @AuraEnabled public String I_SPART      {get;set;}
            @AuraEnabled public String I_KUNNR      {get;set;}
            @AuraEnabled public String I_TKNUM      {get;set;}
            
            @AuraEnabled public String I_EXIDV      {get;set;}
            @AuraEnabled public String I_VBELN      {get;set;}
            @AuraEnabled public String I_MATNR      {get;set;}
            @AuraEnabled public String I_BSTNK      {get;set;}
            @AuraEnabled public String I_STTRG      {get;set;}
            
            @AuraEnabled public String I_FDATE      {get;set;}
            @AuraEnabled public String I_TDATE      {get;set;}
            @AuraEnabled public String I_LANGU      {get;set;}
            @AuraEnabled public String I_DELVE      {get;set;}
            @AuraEnabled public String I_FGDAT      {get;set;}
            
            @AuraEnabled public String I_TGDAT      {get;set;}

            public IF_PARTS_027_Req(){}
        }
        public class IF_PARTS_027_Res{
            @AuraEnabled public String O_MESG       {get;set;}
            @AuraEnabled public String O_COUNT      {get;set;}
            @AuraEnabled public IF_PARTS_027_Res_O_RETURN           O_RETURN        {get;set;}
            @AuraEnabled public List<IF_PARTS_027_Res_T_SALES_AREA> T_SALES_AREA    {get;set;}
            @AuraEnabled public List<IF_PARTS_027_Res_T_DETAIL>     T_DETAIL        {get;set;}
        
            public IF_PARTS_027_Res(){}
        }
        public class IF_PARTS_027_Res_O_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
            @AuraEnabled public String LOG_NO       {get;set;}
            @AuraEnabled public String LOG_MSG_NO   {get;set;}

            @AuraEnabled public String MESSAGE_V1   {get;set;}
            @AuraEnabled public String MESSAGE_V2   {get;set;}
            @AuraEnabled public String MESSAGE_V3   {get;set;}
            @AuraEnabled public String MESSAGE_V4   {get;set;}

            public IF_PARTS_027_Res_O_RETURN(){}
        }
        public class IF_PARTS_027_Res_T_SALES_AREA{
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}
            @AuraEnabled public String SPART        {get;set;}

            public IF_PARTS_027_Res_T_SALES_AREA(){}
        }
        public class IF_PARTS_027_Res_T_DETAIL{
            @AuraEnabled public String TKNUM        {get;set;}
            @AuraEnabled public String EXIDV        {get;set;}
            @AuraEnabled public String MATNR_SO     {get;set;}
            @AuraEnabled public String MATNR_SH     {get;set;}
            @AuraEnabled public String MAKTX        {get;set;}
            
            @AuraEnabled public String LFIMG        {get;set;}
            @AuraEnabled public String MEINS        {get;set;}
            @AuraEnabled public String NETPR        {get;set;}
            @AuraEnabled public String NETWR        {get;set;}
            @AuraEnabled public String WAERK        {get;set;}
            
            @AuraEnabled public String HERKL        {get;set;}
            @AuraEnabled public String INTCA3       {get;set;}
            @AuraEnabled public String BSTKD        {get;set;}
            @AuraEnabled public String STTRG        {get;set;}
            @AuraEnabled public String STTRG_T      {get;set;}
            
            @AuraEnabled public String ZFOBDT       {get;set;}
            @AuraEnabled public String ZFDONO       {get;set;}
            @AuraEnabled public String VBELN2       {get;set;}
            @AuraEnabled public String KVGR5        {get;set;}
            @AuraEnabled public String ZFCIVNO      {get;set;}
            
            @AuraEnabled public String ZFMBLNO      {get;set;}
            @AuraEnabled public String COUNT1       {get;set;}
            @AuraEnabled public String COUNT2       {get;set;}
            @AuraEnabled public String ZFHBLNO      {get;set;}
            @AuraEnabled public String ZFCIVDT      {get;set;}
            
            @AuraEnabled public String STABF        {get;set;}
            @AuraEnabled public String VSBED        {get;set;}
            @AuraEnabled public String KWERT        {get;set;}
            @AuraEnabled public String NTGEW        {get;set;}
            @AuraEnabled public String BRGEW        {get;set;}
            
            @AuraEnabled public String GEWEI        {get;set;}
            @AuraEnabled public String NTGEW_T      {get;set;}
            @AuraEnabled public String BRGEW_T      {get;set;}
            @AuraEnabled public String NETPR2       {get;set;}
            @AuraEnabled public String NETWR2       {get;set;}
            
            @AuraEnabled public String ZFTRSAMT     {get;set;}
            @AuraEnabled public String ZFINSAMT     {get;set;}
            @AuraEnabled public String ZFETCAMT     {get;set;}
            @AuraEnabled public String ZFTOTAL      {get;set;}
            @AuraEnabled public String ZFSTRAMT     {get;set;}
            
            @AuraEnabled public String ZFCUSAMT     {get;set;}
            @AuraEnabled public String ZFDOCAMT     {get;set;}
            @AuraEnabled public String ZFETCAMT_S   {get;set;}
            @AuraEnabled public String ZFETCAMT_D   {get;set;}
            @AuraEnabled public String STAWN        {get;set;}
            
            @AuraEnabled public String VBELN_DO     {get;set;}
            @AuraEnabled public String POSNR_DO     {get;set;}
            @AuraEnabled public String PO_ITM_NO    {get;set;}
            @AuraEnabled public String KWMENG       {get;set;}
            @AuraEnabled public String VTEXT       {get;set;}
            @AuraEnabled public String VSTEL       {get;set;}

            public IF_PARTS_027_Res_T_DETAIL(){}
        }
}