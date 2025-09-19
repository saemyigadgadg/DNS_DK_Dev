/**
 * @author            : iltae.seo
 * @last modified on  : 2024-11-22
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-22   iltae.seo     Initial Version
**/
public with sharing class DN_BoardYoutubeController {
    /**
    * @description 게시판에 유투브 링크 조회해 전달
    * @author iltae.seo | 2024-11-22 
    * @param String recordId 
    **/
    @AuraEnabled
    public static String getYoutubeId(String recordId){
        try {
            String youtubeId = '';
            Board__c board = [select Id,Name,Youtube__c from Board__c where Id=:recordId];
            youtubeId = board.Youtube__c;
            return youtubeId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}