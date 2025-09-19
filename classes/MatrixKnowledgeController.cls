public with sharing class MatrixKnowledgeController {
  @AuraEnabled(cacheable=true)
  public static List<KnowledgeArticleVersion> findKnowledge(String searchKey) {
    System.debug('Knowledge 데이터 검색 중: ' + searchKey);
    String key = '%' + searchKey + '%';
    return [
      SELECT Id, Title
      FROM KnowledgeArticleVersion
      WHERE PublishStatus = 'online' AND Title LIKE :key AND Summary LIKE :key
      ORDER BY Title ASC
    ];
  }
}