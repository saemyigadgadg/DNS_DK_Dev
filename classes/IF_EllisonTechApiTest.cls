@IsTest 
public with sharing class IF_EllisonTechApiTest {
    
    // Mock HTTP 응답 정의
    public with sharing class EllisonTech_HttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String resBody = '{"code":"201","message":"create success","data":{}}';
            res.setBody(resBody);
            res.setStatusCode(201);

            return res;
        }
    }    

    @IsTest
    static void ellisonTechTest(){
        // Mock 등록 (실제 HTTP 요청을 막고 가짜 응답 반환)
        Test.setMock(HttpCalloutMock.class, new EllisonTech_HttpMock());

        // RestRequest 및 RestResponse 설정
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/insert_ellison_objects/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        // 요청 JSON 데이터
        String requestBody = '{"Opportunity":[{"OwnerId":"0051t000004t9RRAAY","DNSAModel":"Model1","Probability":"0.75","CloseDate":"2025-01-30","RequestDelieveryDate":"2025-02-10","PO":"PO12345","Name":"John Doe","Competitor":"CompetitorX","OpportunityId":"0061t00000ZydzQAAR"}],"Account":[{"CustomerCode":"CUST123","Name":"Acme Corporation","OwnerId":"0051t000004t9RRAAY","Representative":"John Manager","CountryLookup":"US","RegionLookup":"California","ShippingCountry":"United States","ShippingStreet":"1234 Elm St","ShippingCity":"San Francisco","ShippingState":"CA","ShippingPostalCode":"94105","Phone":"+1 415-555-1234","Email":"contact@acme.com","AccountId":"0011t00000W6J0aAAJ"}],"Contact":[{"OwnerId":"0051t000004t9RRAAY","LastName":"Doe","MiddleName":"M","FirstName":"John","AccountId":"0011t00000W6J0aAAJ","Email":"john.doe@example.com","MobilePhone":"+1 415-555-5678","Phone":"+1 415-555-1234"}]}';

        // 요청 본문 설정
        req.requestBody = Blob.valueOf(requestBody);

        // RestContext 설정 (callOut() 메서드에서 RestRequest를 사용할 수 있도록)
        RestContext.request = req;
        RestContext.response = res;

        // 테스트 실행
        Test.startTest();
        Map<String, String> responseMap = IF_EllisonTechApi.callOut();
        Test.stopTest();

        // 응답 검증
        System.assertNotEquals(null, responseMap);
        System.assertEquals('201', responseMap.get('code'));
        System.assertEquals('create success', responseMap.get('message'));
        
        System.debug('Test Response: ' + responseMap);
    }
}