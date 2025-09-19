/** 
 * @Class :  SequenceGenerator
 * 
 * @Test: SequenceGenerator_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 18. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-18 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class SequenceGenerator {
    private final String PATTERN_REGEXP = '(\\{0+\\})';
    private String sObjectAPI    {get; set;}
    private Map<String,Sequence__c> sequenceMap {
        get {
            if(sequenceMap == null) {
                sequenceMap = new Map<String, Sequence__c>();
            }
            return sequenceMap;
        } 
        set;
    }

    private Map<String,String> currentSequenceMap {
        get {
            if(currentSequenceMap == null) {
                currentSequenceMap = new Map<String, String>();
            }
            return currentSequenceMap;
        } 
        set;
    }
    
    /*
     * @ Method : SequenceGenerator
     * @ Description : 대리점 재고 관리에서 Trigger또는 클래스에서 SeqSequence를 사용
     * @ Description : 초기값 설정 - SequenceGenerator seq = new SequenceGenerator('오브젝트명')
     * @ Parameter : sObjectAPI - 오브젝트명
     */
    public SequenceGenerator(String sObjectAPI) {
        this.setSObjectAPI(sObjectAPI);
    }

    public SequenceGenerator setSObjectAPI(String sObjectAPI) {
        this.sObjectAPI = sObjectAPI;
        this.initialize();
        return this;
    }

    private void initialize() {
        if(String.isBlank(this.sObjectAPI)) throw new CustomException('Sequence Object API is blank');
        sequenceMap.clear();
        for(Sequence__c sequence : [SELECT Type__c, Pattern__c, StartNumber__c FROM Sequence__c WHERE  SObjectAPI__c = :sObjectAPI FOR UPDATE]) {
            sequenceMap.put(sequence.Type__c, sequence);
        }
        if(sequenceMap.size() == 0 ) throw new CustomException('Sequence is Not Found');
    }

    /*
     * @ Method : setSequncePattern
     * @ Description : 
     * @ Parameter : Sequence__c - Custom Setting에 Seq정보
     *  
     */
    private void setSequncePattern(Sequence__c sequence) {
        List<String> seqPatterns = new List<String>();
        // * 제약사항 {0+} 패턴이 여러개인 채번 규칙 적용 불가.
        // {0+} 가 단일 패턴만 채번 규칙 적용
        Matcher seqMatcher = Pattern.compile(PATTERN_REGEXP).matcher(sequence.Pattern__c);
        while(seqMatcher.find()) {
            seqPatterns.add(seqMatcher.group());
        }
        
        Integer targetIdx = seqPatterns.size() - 1;
        if(targetIdx == -1) throw new CustomException('Does Not Match Sequence Pattern ');

        String removedBracesPatten = seqPatterns[targetIdx].replaceAll('[\\{\\}]','');
        // System.debug('removedBracesPatten : '+removedBracesPatten);
        Integer defaultDigit = removedBracesPatten.length();
        Integer currentSeqNumber = Integer.valueOf(removedBracesPatten) + Integer.valueOf(sequence.StartNumber__c);

        String calculatedSeq = String.valueOf(currentSeqNumber).leftPad(defaultDigit, '0');
        // System.debug('calculatedSeq : '+calculatedSeq);
        currentSequenceMap.put(sequence.Type__c, sequence.Pattern__c.replace(seqPatterns[targetIdx], calculatedSeq));

        //Set Next Sequence
        sequence.StartNumber__c += 1;
        if(String.valueOf(sequence.StartNumber__c).length() > defaultDigit) {
            //자리수가 변경되면 0으로 초기화
            sequence.StartNumber__c = 0; 
        }
    }

    /*
     * @ Method : updateNextSequenceInfo
     * @ Description : 채번 부여 후 채번정보 업데이트
     *  
     */
    public void updateNextSequenceInfo() {
        update sequenceMap.values();
    }

    
    /*
     * @ Method : generate
     * @ Description : Trigger 또는 Class에서 해당 필드에 채번 부여
     *  
     */
    public String generate(String type) {
        Sequence__c sequnceInfo = sequenceMap.get(type);
        if(sequnceInfo == null) throw new CustomException('Sequence is Not Found');
        
        nextSequence(sequnceInfo);
        String currentSeq = currentSequenceMap.get(type);
        return currentSeq;
    }

    /*
     * @ Method : nextSequence
     * @ Description : 다음 시퀀스 채번
     *  
     */
    private void nextSequence(Sequence__c sequence) {
        System.debug(sequence + ' ::sequence');
        System.debug('nextSequence');
        setSequncePattern(sequence);
    }

    public class CustomException extends Exception {}

}