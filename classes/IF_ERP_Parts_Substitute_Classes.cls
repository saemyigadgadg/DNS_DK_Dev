public with sharing class IF_ERP_Parts_Substitute_Classes {
    public IF_ERP_Parts_Substitute_Classes() {}

    // SFDC interface Id    : IF-PARTS-004
    // AS-IS RFC            : Z_SD_PREPARE_TOGETHER_PARTS
    // New I/F              : ZCRM_SD_PREPARE_TOGETHER_PARTS
    // Description          : 대체품 조회를 위한 I/F 호출 
    public class IF_PARTS_004_Req{
        @AuraEnabled public String                          I_WERKS {get;set;}
        @AuraEnabled public List<IF_PARTS_004_Req_T_ITEM>   T_ITEM  {get;set;}

        public IF_PARTS_004_Req(){}
    }
    public class IF_PARTS_004_Req_T_ITEM{
        @AuraEnabled public String CCHECK               {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String MATERIAL             {get;set;}

        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String QTY                  {get;set;}
        @AuraEnabled public String UOM                  {get;set;}
        @AuraEnabled public String NET_PRICE            {get;set;}
        
        @AuraEnabled public String NET_VALUE            {get;set;}
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
        @AuraEnabled public String STAWN                {get;set;}
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
        @AuraEnabled public String MATERIAL_DIA         {get;set;}
        @AuraEnabled public String ERRORCHECK           {get;set;}
        @AuraEnabled public String ERRORMSG             {get;set;}
        
        @AuraEnabled public String SUGRD                {get;set;}
        @AuraEnabled public String COMPLAINT_REASON     {get;set;}
        @AuraEnabled public String ACCEPT               {get;set;}
        @AuraEnabled public String MATERIAL_N           {get;set;}
        
        @AuraEnabled public String CUST_MAT22           {get;set;}
        @AuraEnabled public String NETPR                {get;set;}
        @AuraEnabled public String DIEUCE               {get;set;}
        @AuraEnabled public String DIEUFL               {get;set;}
        
        @AuraEnabled public String DIUK                 {get;set;}
        @AuraEnabled public String DIID                 {get;set;}
        @AuraEnabled public String DI                   {get;set;}
        @AuraEnabled public String DIUKL                {get;set;}
        
        @AuraEnabled public String DIEUMT               {get;set;}
        @AuraEnabled public String MEINS                {get;set;}
        @AuraEnabled public String KONDM                {get;set;}
        @AuraEnabled public String NTGEW                {get;set;}
        
        @AuraEnabled public String GEWEI                {get;set;}
        @AuraEnabled public String KUNNR                {get;set;}
        @AuraEnabled public String KBETR                {get;set;}
        @AuraEnabled public String HERKL                {get;set;}
        
        @AuraEnabled public String KUNNR_SHIP           {get;set;}
        @AuraEnabled public String ZZAPPMACHINE         {get;set;}
        @AuraEnabled public String ZZEQMASTER           {get;set;}
        @AuraEnabled public String STORE_LOC            {get;set;}
        
        @AuraEnabled public String ZZWORKHRS            {get;set;}
        @AuraEnabled public String LIST_PRICE           {get;set;}
        @AuraEnabled public String LOT_CHECK            {get;set;}
        @AuraEnabled public String BULLETIN             {get;set;}
        
        @AuraEnabled public String BULL_MATNR           {get;set;}
        @AuraEnabled public String POUND                {get;set;}
        @AuraEnabled public String KSTOCK               {get;set;}
        @AuraEnabled public String CORE_PARTS           {get;set;}
        
        @AuraEnabled public String SPEC                 {get;set;}
        @AuraEnabled public String TO_PART              {get;set;}
        @AuraEnabled public String MITEM                {get;set;}
        @AuraEnabled public String ATP_QTY              {get;set;}
        
        @AuraEnabled public String LANDX                {get;set;}
        @AuraEnabled public String MTPOS                {get;set;}
        @AuraEnabled public String RT_QTY               {get;set;}
        @AuraEnabled public String HQ_QTY               {get;set;}
        
        public IF_PARTS_004_Req_T_ITEM(){}
    }
    public class IF_PARTS_004_Res{
        @AuraEnabled public List<IF_PARTS_004_Res_T_ITEM> T_ITEM {get;set;}

        public IF_PARTS_004_Res(){}
    }
    public class IF_PARTS_004_Res_T_ITEM{
        @AuraEnabled public String CCHECK               {get;set;}
        @AuraEnabled public String ITEM                 {get;set;}
        @AuraEnabled public String HILV                 {get;set;}
        @AuraEnabled public String MATERIAL             {get;set;}

        @AuraEnabled public String MATERIAL_TEXT        {get;set;}
        @AuraEnabled public String QTY                  {get;set;}
        @AuraEnabled public String UOM                  {get;set;}
        @AuraEnabled public String NET_PRICE            {get;set;}
        
        @AuraEnabled public String NET_VALUE            {get;set;}
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
        @AuraEnabled public String STAWN                {get;set;}
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
        @AuraEnabled public String MATERIAL_DIA         {get;set;}
        @AuraEnabled public String ERRORCHECK           {get;set;}
        @AuraEnabled public String ERRORMSG             {get;set;}
        
        @AuraEnabled public String SUGRD                {get;set;}
        @AuraEnabled public String COMPLAINT_REASON     {get;set;}
        @AuraEnabled public String ACCEPT               {get;set;}
        @AuraEnabled public String MATERIAL_N           {get;set;}
        
        @AuraEnabled public String CUST_MAT22           {get;set;}
        @AuraEnabled public String NETPR                {get;set;}
        @AuraEnabled public String DIEUCE               {get;set;}
        @AuraEnabled public String DIEUFL               {get;set;}
        
        @AuraEnabled public String DIUK                 {get;set;}
        @AuraEnabled public String DIID                 {get;set;}
        @AuraEnabled public String DI                   {get;set;}
        @AuraEnabled public String DIUKL                {get;set;}
        
        @AuraEnabled public String DIEUMT               {get;set;}
        @AuraEnabled public String MEINS                {get;set;}
        @AuraEnabled public String KONDM                {get;set;}
        @AuraEnabled public String NTGEW                {get;set;}
        
        @AuraEnabled public String GEWEI                {get;set;}
        @AuraEnabled public String KUNNR                {get;set;}
        @AuraEnabled public String KBETR                {get;set;}
        @AuraEnabled public String HERKL                {get;set;}
        
        @AuraEnabled public String KUNNR_SHIP           {get;set;}
        @AuraEnabled public String ZZAPPMACHINE         {get;set;}
        @AuraEnabled public String ZZEQMASTER           {get;set;}
        @AuraEnabled public String STORE_LOC            {get;set;}
        
        @AuraEnabled public String ZZWORKHRS            {get;set;}
        @AuraEnabled public String LIST_PRICE           {get;set;}
        @AuraEnabled public String LOT_CHECK            {get;set;}
        @AuraEnabled public String BULLETIN             {get;set;}
        
        @AuraEnabled public String BULL_MATNR           {get;set;}
        @AuraEnabled public String POUND                {get;set;}
        @AuraEnabled public String KSTOCK               {get;set;}
        @AuraEnabled public String CORE_PARTS           {get;set;}
        
        @AuraEnabled public String SPEC                 {get;set;}
        @AuraEnabled public String TO_PART              {get;set;}
        @AuraEnabled public String MITEM                {get;set;}
        @AuraEnabled public String ATP_QTY              {get;set;}
        
        @AuraEnabled public String LANDX                {get;set;}
        @AuraEnabled public String MTPOS                {get;set;}
        @AuraEnabled public String RT_QTY               {get;set;}
        @AuraEnabled public String HQ_QTY               {get;set;}

        public IF_PARTS_004_Res_T_ITEM(){}
    }
}