/**
* @Class : CS_SequenceGenerator
*
* @Author : Iltae, Seo
* @Date : 2025. 07. 02.
* @Version : 1.0
* @Modified : 2025. 07. 04
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-07-02 | Iltae, Seo     | 최초작성
*
*/
public without sharing class CS_SequenceGenerator {
    public Integer startIndex {get; set;}
    public Integer lastIndex {get; set;}
    private String assignmentRuleName {get; set;} 
    private String assignmentRullId {get; set;} 
    private String lastCurrentUserId {get; set;}
    private Map<Integer,AssignmentMember__c> sequenceMap {
        get {
            if(sequenceMap == null) {
                sequenceMap = new Map<Integer, AssignmentMember__c>();
            }
            return sequenceMap;
        } 
        set;
    }

    /**
     * @Description
     * 	- 배정룰 CS_SequenceGenerator 생성자
     * @author iltae.seo | 2025-07-02
     * @param assignmentRuleName(배정룰명)
    **/ 
    public CS_SequenceGenerator(String assignmentRuleName) {
        Integer startIndex = 1;
        this.setStartIndex(startIndex,assignmentRuleName);
        
    }
    
    /**
     * @Description
     * 	- setStartIndex 초기 전역변수 설정 및 initialize 실행
     * @author iltae.seo | 2025-07-02
     * @param startIndex(최초 실행시 1로 디폴트)
     * @param assignmentRuleName(배정룰명)
    **/ 
    public CS_SequenceGenerator setStartIndex(Integer startIndex,String assignmentRuleName) {
        this.startIndex = startIndex;
        this.assignmentRuleName = assignmentRuleName;
        this.initialize();
        return this;
    }

    /**
     * @Description
     * 	- initialize 휴가자 제외 후 sequenceMap에 배정받을 유저의 INDEX 및 정보 저장
     * @author iltae.seo | 2025-07-02
    **/ 
    private void initialize() {
        if(String.isBlank(String.valueOf(this.startIndex))) throw new CustomException('Sequence Index is blank');
        sequenceMap.clear();
        Map<Integer,AssignmentMember__c> indexMap = new Map<Integer, AssignmentMember__c>();
        List<Integer> indexList = new List<Integer>();
         List<ConsultationAttendance__c> caList = [SELECT Id, Name, CurrencyIsoCode, Consultant__c, Consultant__r.Name, AttendanceDate__c, AttendanceType__c, OffStartTime__c, OffEndTime__c  
                                                    FROM ConsultationAttendance__c
                                                    WHERE AttendanceDate__c = TODAY];
        System.debug('caList : ' + Json.serialize(caList));
        SET<ID> userIDs = new SET<ID>();            
        for(ConsultationAttendance__c obj : caList){
            if(obj.AttendanceType__c != 'Waiting' &&  obj.OffStartTime__c != null){
                Integer startHours = String.isEmpty(obj.OffStartTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(0,2));
                Integer startMinute = String.isEmpty(obj.OffStartTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffStartTime__c.subString(2,4));
                Integer endHours = String.isEmpty(obj.OffEndTime__c.subString(0,2)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(0,2));
                Integer endMinute = String.isEmpty(obj.OffEndTime__c.subString(2,4)) ? 0 : Integer.valueOf(obj.OffEndTime__c.subString(2,4));
                
                Datetime offStartDatetime = Datetime.newinstance(Date.today(), Time.newInstance(startHours, startMinute,0,0));
                Datetime offEndDatetime = Datetime.newinstance(Date.today(), Time.newInstance(endHours, endMinute,0,0));
                
                if(offStartDatetime <= System.now() && offEndDatetime >= System.now()){
                    userIDs.add(obj.Consultant__c);
                }  
            }
        }
        for(AssignmentMember__c assignmentMebmer : [SELECT Id, User__c, Index__c, CurrentAssignment__c,AssignmentRule__c
                                            FROM AssignmentMember__c
                                            WHERE AssignmentRule__r.Name=:assignmentRuleName AND User__c NOT IN:userIDs FOR UPDATE]) 
        
        {
            this.assignmentRullId = assignmentMebmer.AssignmentRule__c;
            indexMap.put((Integer)assignmentMebmer.Index__c, assignmentMebmer);
            indexList.add((Integer)assignmentMebmer.Index__c);
        }

        indexList.sort();
        Boolean notFound = true;

        for(Integer indx : indexList) {   
            if(indexMap.get(indx).CurrentAssignment__c) {
                this.startIndex = indexList.indexOf(indx) == (indexList.size()-1) ? indexList[0]  : indexList[indexList.indexOf(indx)+1];
                notFound = false;
            }  
            sequenceMap.put(indx,indexMap.get(indx));
            this.lastIndex = indx;
        }
        //휴가자 내에 True가 있는 경우
        if(notFound) {
            Boolean assignNullCheck = true;
            Integer currentIndex = 0;
            this.startIndex = indexList[0];

            for (AssignmentMember__c member : [
                SELECT Index__c
                FROM AssignmentMember__c
                WHERE AssignmentRule__r.Name =:assignmentRuleName AND CurrentAssignment__c = TRUE
                LIMIT 1
            ]) {
                currentIndex = (Integer) member.Index__c;
            }
            
            for(Integer notFoundIndx : indexList) { 
                if(notFoundIndx > currentIndex ) {
                    this.startIndex = notFoundIndx; 
                    assignNullCheck = false;
                    break;              
                }
            }
        }

        
        if(sequenceMap.size() == 0 ) throw new CustomException('Sequence is Not Found');
    }

    /**
     * @Description
     * 	- generate - 배정받을 사람의 USER ID 반환
     * @author iltae.seo | 2025-07-02
     * @param index(배정받을 사람의 INDEX값)
     * @return sequnceInfo.User__c(배정받아야할 사람의 ID 리턴)
    **/ 
    public String generate(Integer index) {
        AssignmentMember__c sequnceInfo = sequenceMap.get(index);
        if(sequnceInfo == null) throw new CustomException('Sequence is Not Found');
        this.lastCurrentUserId = sequnceInfo.User__c;
        return sequnceInfo.User__c;
    }

    /**
     * @Description
     * 	- updateForCurrentAssignment - AssignmentMember__c의 마지막 배정받은 사람 업데이트
     * lastCurrentUserId의 값과 동일한 사용자가 마지막 배정받았으므로 해당 레코드 업데이트
     * @author iltae.seo | 2025-07-02
    **/ 
    public void updateForCurrentAssignment() {
        AssignmentMember__c currentAssignment = new AssignmentMember__c();
        for(Integer indx :sequenceMap.keySet()) {
            AssignmentMember__c assignmentMember = sequenceMap.get(indx);
            if(this.lastCurrentUserId == assignmentMember.User__c) {
                assignmentMember.CurrentAssignment__c = true;
                currentAssignment = assignmentMember;
            } else {
                assignmentMember.CurrentAssignment__c = false;
            }
        }
        List<AssignmentMember__c> forUpdateMember = [SELECT Id, User__c, Index__c, CurrentAssignment__c,AssignmentRule__c
                                            FROM AssignmentMember__c
                                            WHERE AssignmentRule__r.Name=:assignmentRuleName  FOR UPDATE];
        update sequenceMap.values();
    }
    public class CustomException extends Exception {}
}