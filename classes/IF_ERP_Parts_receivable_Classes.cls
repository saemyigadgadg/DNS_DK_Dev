public with sharing class IF_ERP_Parts_receivable_Classes {
    public IF_ERP_Parts_receivable_Classes() {}
    
    /**  SFDC interface Id  : IF-PARTS-020
     * AS-IS RFC            : Z_EP_INVOICE_LIST2
     * New I/F              : ZCRM_EP_INVOICE_LIST2
     * Description          : 외상매입금 리스트 조회
        */
        public class IF_PARTS_020_Req{
            @AuraEnabled public String I_KUNNR      {get;set;}
            @AuraEnabled public String I_VKORG      {get;set;}
            @AuraEnabled public String I_VTWEG      {get;set;}
            @AuraEnabled public String I_SPART      {get;set;}

            @AuraEnabled public String I_F_VBELN    {get;set;}
            @AuraEnabled public String I_T_VBELN    {get;set;}
            @AuraEnabled public String I_F_ZFCIVNO  {get;set;}
            @AuraEnabled public String I_T_ZFCIVNO  {get;set;}
            
            @AuraEnabled public String I_F_BLDAT    {get;set;}
            @AuraEnabled public String I_T_BLDAT    {get;set;}
            @AuraEnabled public String I_SPRAS      {get;set;}
            @AuraEnabled public String I_AUART      {get;set;}

            public IF_PARTS_020_Req(){}
        }
        public class IF_PARTS_020_Res{
            @AuraEnabled public String                            O_MESG      {get;set;}
            @AuraEnabled public String                            O_COUNT     {get;set;}
            @AuraEnabled public IF_PARTS_020_Res_O_RETURN         O_RETURN    {get;set;}
            @AuraEnabled public List<IF_PARTS_020_Res_T_INVOICE>  T_INVOICE   {get;set;}
            @AuraEnabled public List<IF_PARTS_020_Res_T_INVOICE1> T_INVOICE1  {get;set;}

            public IF_PARTS_020_Res(){}
        }
        public class IF_PARTS_020_Res_O_RETURN{
            @AuraEnabled public String TYPE             {get;set;}
            @AuraEnabled public String CODE             {get;set;}
            @AuraEnabled public String MESSAGE          {get;set;}
            @AuraEnabled public String LOG_NO           {get;set;}

            @AuraEnabled public String LOG_MSG_NO       {get;set;}
            @AuraEnabled public String MESSAGE_V1       {get;set;}
            @AuraEnabled public String MESSAGE_V2       {get;set;}
            @AuraEnabled public String MESSAGE_V3       {get;set;}

            @AuraEnabled public String MESSAGE_V4       {get;set;}

            public IF_PARTS_020_Res_O_RETURN(){}
        }
        public class IF_PARTS_020_Res_T_INVOICE{
            @AuraEnabled public String VBELN            {get;set;}
            @AuraEnabled public String ZFCIVNO          {get;set;}
            @AuraEnabled public String ZTERM            {get;set;}
            @AuraEnabled public String VTEXT            {get;set;}

            @AuraEnabled public String BUZEI            {get;set;}
            @AuraEnabled public String BLDAT            {get;set;}
            @AuraEnabled public String FAEDT            {get;set;}
            @AuraEnabled public String WRBTR            {get;set;}
            
            @AuraEnabled public String WAERK            {get;set;}
            @AuraEnabled public String WRSHB            {get;set;}
            @AuraEnabled public String VERZN            {get;set;}
            @AuraEnabled public String SHKZG            {get;set;}
            
            @AuraEnabled public String WRBTR2           {get;set;}
            @AuraEnabled public String SEQNO            {get;set;}

            public IF_PARTS_020_Res_T_INVOICE(){}
        }
        public class IF_PARTS_020_Res_T_INVOICE1{
            @AuraEnabled public String VBELN            {get;set;}
            @AuraEnabled public String ZFCIVNO          {get;set;}
            @AuraEnabled public String ZTERM            {get;set;}
            @AuraEnabled public String VTEXT            {get;set;}

            @AuraEnabled public String BUZEI            {get;set;}
            @AuraEnabled public String BLDAT            {get;set;}
            @AuraEnabled public String FAEDT            {get;set;}
            @AuraEnabled public String WRBTR            {get;set;}
            
            @AuraEnabled public String WAERK            {get;set;}
            @AuraEnabled public String WRSHB            {get;set;}
            @AuraEnabled public String VERZN            {get;set;}
            @AuraEnabled public String SHKZG            {get;set;}
            
            @AuraEnabled public String WRBTR2           {get;set;}
            @AuraEnabled public String SEQNO            {get;set;}

            public IF_PARTS_020_Res_T_INVOICE1(){}
        }

    // SFDC interface Id    : IF-PARTS-023
    // AS-IS RFC            : ZSS_RECV_EP_INVOICE_DETAIL
    // New I/F              : ZCRM_SS_RECV_EP_INVOICE_DETAIL
    // Description          : Parts > 채무현황 > 외상매입금 리스트
    public class IF_PARTS_023_Req{
        @AuraEnabled public String I_VBELN {get;set;}

        public IF_PARTS_023_Req(){}
    }
    public class IF_PARTS_023_Res{
        @AuraEnabled public String                          E_TOTAL     {get;set;}
        @AuraEnabled public IF_PARTS_023_Res_ES_RETURN      ES_RETURN   {get;set;}
        @AuraEnabled public List<IF_PARTS_023_Res_ET_LIST>  ET_LIST     {get;set;}

        public IF_PARTS_023_Res(){}
    }
    public class IF_PARTS_023_Res_ES_RETURN{
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

        public IF_PARTS_023_Res_ES_RETURN(){}
    }
    public class IF_PARTS_023_Res_ET_LIST{
        @AuraEnabled public String AUBEL    {get;set;}
        @AuraEnabled public String POSNR    {get;set;}
        @AuraEnabled public String MATNR    {get;set;}
        @AuraEnabled public String MAKTX    {get;set;}

        @AuraEnabled public String FKIMG    {get;set;}
        @AuraEnabled public String VRKME    {get;set;}
        @AuraEnabled public String NETWR    {get;set;}
        @AuraEnabled public String MWSBP    {get;set;}
        
        @AuraEnabled public String TOTAL    {get;set;}
        @AuraEnabled public String WAERK    {get;set;}
        @AuraEnabled public String VGBEL    {get;set;}

        public IF_PARTS_023_Res_ET_LIST(){}
    }

}