@isTest
private class MatrixKnowledgeControllerTest {

    static testMethod void testMatrixKnowledgeController() {


        // 테스트 실행
        Test.startTest();

                // 테스트 실행

                

        List<KnowledgeArticleVersion> result = MatrixKnowledgeController.findKnowledge('test');



        Test.stopTest();
    }
}