@IsTest
public with sharing class IF_MOIS_ADDRESS_Test {
    private static String className = 'IF_MOIS_ADDRESS';

/** Mock Classes
 */
    /** MOIS
        setInterface('IF_ExternalApi','IF-MOIS-Address-HttpMock')
    */
    public with sharing class MOIS_ADDRESS_SUCCESS_HttpMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');

            String responseBody = '{"results":{"common":{"errorMessage":"정상","countPerPage":"15","totalCount":"2","errorCode":"0","currentPage":"1"},"juso":[{"detBdNmList":"","engAddr":"10 Tongil-ro, Jung-gu, Seoul","rn":"통일로","emdNm":"남대문로5가","zipNo":"04527","roadAddrPart2":" (남대문로5가)","emdNo":"01","sggNm":"중구","jibunAddr":"서울특별시 중구 남대문로5가 84-11 연세대학교 세브란스빌딩","siNm":"서울특별시","roadAddrPart1":"서울특별시 중구 통일로 10","bdNm":"연세대학교 세브란스빌딩","admCd":"1114011800","udrtYn":"0","lnbrMnnm":"84","roadAddr":"서울특별시 중구 통일로 10 (남대문로5가)","lnbrSlno":"11","buldMnnm":"10","bdKdcd":"0","liNm":"","rnMgtSn":"111403000008","mtYn":"0","bdMgtSn":"1114011800100840011021410","buldSlno":"0"},{"detBdNmList":"원당세브란스크리닉","engAddr":"866 Wondang-daero, Seo-gu, Incheon","rn":"원당대로","emdNm":"당하동","zipNo":"22682","roadAddrPart2":" (당하동, 세브란스빌딩)","emdNo":"02","sggNm":"서구","jibunAddr":"인천광역시 서구 당하동 1028-13 세브란스빌딩","siNm":"인천광역시","roadAddrPart1":"인천광역시 서구 원당대로 866","bdNm":"세브란스빌딩","admCd":"2826011400","udrtYn":"0","lnbrMnnm":"1028","roadAddr":"인천광역시 서구 원당대로 866 (당하동, 세브란스빌딩)","lnbrSlno":"13","buldMnnm":"866","bdKdcd":"1","liNm":"","rnMgtSn":"282602156002","mtYn":"0","bdMgtSn":"2826011400100220002030151","buldSlno":"0"}]}}';
            
            response.setBody(responseBody);
            response.setStatusCode(200);

            return response;        
        }
    }

    @IsTest
    static void findAddress_SUCCESS() {
        InterfaceCommonUtil.setInterface('MOIS_ADDRESS', className, 'SUCCESS');
        Test.startTest();
        IF_MOIS_Address mois = new IF_MOIS_Address();
        mois.getAddressInfo('대왕판교로','1');
        Test.stopTest();
    }

}