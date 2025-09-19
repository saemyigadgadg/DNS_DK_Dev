public with sharing class IF_NTS_BusinessNumber_Class {
    public class GetBusinessNumberRes{
        @AuraEnabled public String status_code {get;set;} // ? API 상태 코드
        @AuraEnabled public String match_cnt   {get;set;} // ? 조회 매칭 수
        @AuraEnabled public String request_cnt {get;set;} // ? 조회 요청 수
        @AuraEnabled public List<Data> data    {get;set;} // ? 사업자등록 상태조회 결과
    }
    public class Data{
        @AuraEnabled public String b_no                  {get;set;} // ? 사업자등록번호
        @AuraEnabled public String b_stt                 {get;set;} // ? 납세자상태(명칭): 01: 계속사업자, 02: 휴업자, 03: 폐업자
        @AuraEnabled public String b_stt_cd              {get;set;} // ? 납세자상태(코드): 01: 계속사업자, 02: 휴업자, 03: 폐업자
        @AuraEnabled public String tax_type              {get;set;} // ? 과세유형메세지(명칭): 01:부가가치세 일반과세자, 02:부가가치세 간이과세자, 03:부가가치세 과세특례자, 04:부가가치세 면세사업자, 05:수익사업을 영위하지 않는 비영리법인이거나 고유번호가 부여된 단체,국가기관 등, 06:고유번호가 부여된 단체, 07:부가가치세 간이과세자(세금계산서 발급사업자), * 등록되지 않았거나 삭제된 경우: "국세청에 등록되지 않은 사업자등록번호입니다"
        @AuraEnabled public String tax_type_cd           {get;set;} // ? 과세유형메세지(코드): 01:부가가치세 일반과세자, 02:부가가치세 간이과세자, 03:부가가치세 과세특례자, 04:부가가치세 면세사업자, 05:수익사업을 영위하지 않는 비영리법인이거나 고유번호가 부여된 단체,국가기관 등, 06:고유번호가 부여된 단체, 07:부가가치세 간이과세자(세금계산서 발급사업자), * 등록되지 않았거나 삭제된 경우: "국세청에 등록되지 않은 사업자등록번호입니다"
        @AuraEnabled public String end_dt                {get;set;} // ? 폐업일 (YYYYMMDD 포맷)
        @AuraEnabled public String utcc_yn               {get;set;} // ? 단위과세전환폐업여부(Y,N)
        @AuraEnabled public String tax_type_change_dt    {get;set;} // ? 최근과세유형전환일자 (YYYYMMDD 포맷)
        @AuraEnabled public String invoice_apply_dt      {get;set;} // ? 세금계산서적용일자 (YYYYMMDD 포맷)
        @AuraEnabled public String rbf_tax_type          {get;set;} // ? 직전과세유형메세지(명칭): 01:부가가치세 일반과세자, 02:부가가치세 간이과세자, 07:부가가치세 간이과세자(세금계산서 발급사업자), 99:해당없음
    }
}