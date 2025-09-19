/**
 * @description       : 
 * @author            : Hayeong Min
 * @group             : 
 * @last modified on  : 10-11-2024
 * @last modified by  : Hayeong Min
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   10-11-2024   Hayeong Min   Initial Version
**/


public class DN_SearchFilterComboboxController {

    /**
     * @Description
     * 	- 선택한 W/C의 활성화된 작업자 목록 가져오기
     * 
     * @author Hayeong Min | 10-11-2024
     * @Parameter
     * @Parameter
     *  - workcenterId   : W/C Id
     *  - workerId       : 작업자 ID
    **/ 
    @AuraEnabled
    public static List<MapWrapper> getServiceResourceList(String workcenterId, String workerId){
        List<MapWrapper> mapList = new List<MapWrapper>();
        try {
            String query = 'SELECT Id, Name FROM ServiceResource WHERE IsActive = TRUE AND ';
            //workcenter X, worker X
            if(String.isEmpty(workcenterId) && String.isEmpty(workerId)){
                query += 'Service_Territory__c != NULL';
            }
            //workcenter X, worker O
            else if(String.isEmpty(workcenterId) && String.isNotEmpty(workerId)){
                query += 'Id = '+'\''+workerId+'\'';
            }
            //workcenter O, worker X
            else if(String.isNotEmpty(workcenterId) && String.isEmpty(workerId)){
                query += 'Service_Territory__c = '+'\''+workcenterId+'\'';
            }
            //workcenter O, worker O
            else{
                query += 'Service_Territory__c = '+'\''+workcenterId+'\' AND Id = '+'\''+workerId+'\'';
            }
            List<ServiceResource> srList = Database.query(query);
            for(ServiceResource sr : srList){
                MapWrapper mw = new MapWrapper();
                mw.label = sr.Name;
                mw.value = sr.Id;
                mapList.add(mw);
            }
        } catch (Exception e) {
            System.debug('getServiceResourceList ERROR : '+e.getMessage());
        }
        return mapList;
    }

    /**
     * @Description
     * 	- 선택한 작업자의 W/C 정보 가져오기
     * 
     * @author Hayeong Min | 10-04-2024
     * @Parameter
     *  - workerId   : 작업자 ID
    **/ 
    @AuraEnabled
    public static String getWorkcenterId(String workerId){
        // List<MapWrapper> mapList = new List<MapWrapper>();
        ServiceResource[] sr = [SELECT Id, Service_Territory__c FROM ServiceResource WHERE Id = :workerId];
        String workcenterId = (!sr.isEmpty()) ? sr[0].Service_Territory__c : '' ;
        return workcenterId;
    }

    /**
     * @Description
     * 	- 검색값을 포함하는 작업자 목록 가져오기
     * 
     * @author Hayeong Min | 10-04-2024
     * @Parameter
     *  - searchKey      : 검색 단어
     *  - workcenterId   : W/C Id
    **/
    @AuraEnabled
    public static List<MapWrapper> getSearchWorker(String searchKey, String workcenterId){
        List<MapWrapper> mapList = new List<MapWrapper>();
        try{
            String query = 'SELECT Id, Name FROM ServiceResource WHERE IsActive = TRUE AND Name LIKE '+'\'%'+searchKey+'%\'';

            if(String.isNotEmpty(workcenterId)){
               query += ' AND Service_Territory__c = '+'\''+workcenterId+'\'';
            }
            List<ServiceResource> srList = Database.query(query);
            for(ServiceResource sr : srList){
                MapWrapper mw = new MapWrapper();
                mw.label = sr.Name;
                mw.value = sr.Id;
                mapList.add(mw);
            }
        }catch(Exception e){
            System.debug('getServiceResourceList ERROR : '+e.getMessage());
        }
        return mapList;
    }

    /*
     * @Description 
     *  - picklist로 묶는 Wrapper
     * 
     * @Variable 
     *  - label 		: label
     *  - value 	    : value
     * 
     */ 
    public class MapWrapper {
        @AuraEnabled
        public String label		{get; set;} 
        @AuraEnabled
        public String value		{get; set;}
        
        public MapWrapper(){
            this.label 	= '';
            this.value 	= '';
        }
    }
}