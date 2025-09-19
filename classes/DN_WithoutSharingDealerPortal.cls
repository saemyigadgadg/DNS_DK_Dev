public without sharing class DN_WithoutSharingDealerPortal {
    /**
     * @Description
     *  - 딜러포털에서 판매처 리스트 조회
     * @author KYJUNG | 01.23.2025
    **/
    public static Map<String, Account> withoutSearchSeller(String queryString) {
        Map<String, Account> sellerMap = new Map<String, Account>();
        System.debug('queryString 판매처 ::: ' + queryString);
        for(Account acc : Database.query(queryString)){
            sellerMap.put(acc.CustomerCode__c , acc);
        }
        return sellerMap;
    }
    public static List<sObject> withoutObjectList(String queryString) {
        return Database.query(queryString);
    }

    // /**
    //  * @Description
    //  *  - Portal 서비스 이력 조회 (영업포탈) List
    //  * @author Chungwoo Lee | 12-20-2024
    // **/
    // public static List<WorkOrder> withoutSearchWorkOrder(String queryString) {
    //     List<WorkOrder> serviceHistoryList = new List<WorkOrder>();
    //     System.debug('queryString ::: ' + queryString);
    //     return serviceHistoryList = Database.query(queryString);
    // }

    // /**
    //  * @Description
    //  *  - Update Portal Service Report to Case
    //  * @author Chungwoo Lee | 01-10-2025
    // **/
    // public static void withoutUpdateCase(Case caseData) {
    //     System.debug('caseData ::: ' + caseData);
    //     if(caseData != null) {
    //         update caseData;
    //     }
    //     return;
    // }

    // /**
    //  * @Description
    //  *  - Update Portal Service Report to Asset
    //  * @author Chungwoo Lee | 12-18-2024
    //  * @Parameter
    //  *  - accShrList        : AccountShare List
    // **/
    // public static void withoutUpdateAsset(Asset assetData) {
    //     System.debug('assetData ::: ' + assetData);
    //     if(assetData != null) {
    //         update assetData;
    //     }
    //     return;
    // }

    // /**
    //  * @Description
    //  *  - Portal 서비스 리포트 저장 시 작업 내역 삭제
    //  * @author Chungwoo Lee | 01-10-2025
    // **/
    // public static void withoutDeleteWorkOrderResult(List<WorkOrderResult__c> worList) {
    //     if(worList != null) {
    //         delete worList;
    //     }
    //     return;
    // }

    // /**
    //  * @Description
    //  *  - Portal 서비스 리포트 저장 시 작업 내역 기반 SA 업데이트
    //  * @author Chungwoo Lee | 01-10-2025
    // **/
    // public static void withoutUpdateSA(List<ServiceAppointment> appointmentsToUpdate) {
    //     if(appointmentsToUpdate != null) {
    //         update appointmentsToUpdate;
    //     }
    //     return;
    // }

}