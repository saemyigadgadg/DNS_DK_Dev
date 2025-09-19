/**
 * @LAYER 
 * 0. TEST FOR DEBUGGING : 디버깅을 위한 주석 -> '본인전화번호' 에 실제 본인의 전화번호를 입력
 * 1. FIELDS : 해당 클래스에서 사용하는 필드들을 선언 
 * 2. CONSTRUCTOR : 생성자 -> 기본 생성자만 존재 
 * 3. VIEW CONNECTOR : 화면에서 사용할 METHOD
 * 4. MAIN LOGIC : 해당 클래스의 메인 메소드
 * 5. SUB LOGIC : 해당 클래스의 메인 메소드 구현을 위한 보조 메소드
 * 6. SUB LOGIC - DATA BRING : 보조 메소드들 중 DB 에 적재된 데이터를 불 러오는 메소드 ( 메타 데이터 )
 * 7. INNER CLASS : 해당 클래스에서만 사용할 보조 클래스
 * @author : SUNG SEO UK 
 * @email : seouk.sung@sbtglbal.com
 * @date : 2024-10-25
 */
public with sharing class IF_SWEET_TRACKER {

    // ** 0. TEST FOR DEBUGGING
        /***
         // SYSTEM DEBUG TEST
        IF_SWEET_TRACKER st = new IF_SWEET_TRACKER();
        st.callOut('AT','본인전화번호','sendMessage','template_141'); 
        IF_SWEET_TRACKER.invoke('AT','본인전화번호','sendMessage','template_141');
        */

    // ** 1. FIELDS
        public static final String apexClassName = 'IF_SWEET_TRACKER';
        public static InterfaceCommonUtil utils = new InterfaceCommonUtil();   

    // ** 2. CONSTRUCTOR
        public IF_SWEET_TRACKER() {}

    // ** 3. VIEW CONNECTOR
        @AuraEnabled
        public static string invoke(
            String apiType      , // AT
            String phNum        , // 01092679328   
            String apiNm        ,  
            String templateCode ,
            Map<String, String> elementMap
        ){

            IF_SWEET_TRACKER sweetTracker = new IF_SWEET_TRACKER(); 

            try {
                return sweetTracker.invoke_sendMessage(apiType, phNum, apiNm, templateCode, elementMap);             

            } catch (Exception e) {
                System.debug('error ::: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }

        @AuraEnabled
        public static List<String> getTemplateCodeListByMeta(){
            try {
                return new IF_SWEET_TRACKER().findAllTemplateCodeList();
            } catch (Exception e) {
                System.debug('SEARCH BUT EMERGE AT META DATA');
                throw new AuraHandledException(e.getMessage());
            }
        }

    // ** 4. MAIN LOGIC
        public String invoke_sendMessage(String type,String phNum,String apiNm ,String templateCode, Map<String, String> elementMap){
            IF_Authentication__mdt  settingMeta     = getConnectByIFAuthentiation(); 
            Alimtalk_Tamplate__mdt  alimMeta        = getAlimTemplateMetaBy(templateCode);

            ButtonObj button1 = new ButtonObj();
            if (alimMeta.IsButton__c) {
                button1.name = alimMeta.ButtonName1__c;
                button1.type = alimMeta.ButtonType1__c;
                button1.url_mobile = replaceBodyAndButton(alimMeta.MoblieLink1__c, elementMap);
                if (alimMeta.AddPCUrl__c) {
                    button1.url_pc = alimMeta.PCLink1__c == null ? replaceBodyAndButton(alimMeta.MoblieLink1__c, elementMap) : replaceBodyAndButton(alimMeta.PCLink1__c, elementMap);
                }
            }

            String bodyText = replaceBodyAndButton(alimMeta.TemplateBody__c, elementMap);

            // ** 1. Request Body 
            String requestBody = generateRequestBodyString_SendMessage(
                type, // AT
                settingMeta.SecretKey__c,
                phNum,
                remove_v2(templateCode),
                bodyText,
                '00000000000000',
                button1,
                alimMeta.IsButton__c
        );

        // ** 2. queryStringParameters
            Map<String,String> profilekeyUserId = new Map<String,String>();
            profilekeyUserId.put('profileKey', settingMeta.SecretKey__c);
            profilekeyUserId.put('userId', settingMeta.SystemId__c);
            profilekeyUserId.put('apiNm', apiNm);

            // ** 3. system debug for checking 
            System.debug('Request Body : '+requestBody);
            System.debug('profilekeyUserId : '+JSON.serialize(profilekeyUserId));
            
            utils.queryStringParams = profilekeyUserId;
            utils.isMulti = false;
            String result = utils.sendHttp(requestBody, 'Sweet_Tracker_SendMessage_Op', apexClassName, false);

            System.debug('Sweet_Tracker_SendMessage_Op \'s RESPONSE : '+result);
            return result;
        }

    // ** 5. SUB LOGIC  
        private String generateRequestBodyString_SendMessage(
                String msgType, 
                String profile_key,
                String receiver_num,
                String template_code,
                String message,
                String reserved_time,
                ButtonObj button1,
                Boolean isButton
                ){
            Map<String,Object> body = new Map<String,Object>();
            body.put('msgid', generateMsgId());
            body.put('message_type', msgType);
            body.put('profile_key', profile_key);
            body.put('receiver_num', receiver_num);
            body.put('template_code', template_code);
            body.put('message', message);
            body.put('reserved_time', reserved_time);
            if (isButton) body.put('button1',button1);

            List<Map<String,Object>> resultRequestBody = new List<Map<String,Object>>();
            resultRequestBody.add(body);
            
            System.debug('JSON.serialize(resultRequestBody) : '+JSON.serialize(resultRequestBody));

            return JSON.serialize(resultRequestBody);
        }

        public List<String> findAllTemplateCodeList(){
            List<Alimtalk_Tamplate__mdt> metaAll = [
                SELECT TemplateCode__c		
                FROM Alimtalk_Tamplate__mdt];

            List<String> templateCodeList = new List<String>();
        
            for (Alimtalk_Tamplate__mdt template : metaAll) {
                templateCodeList.add(template.TemplateCode__c);
            }
                
            return templateCodeList;
        }

        private String remove_v2(String templateCode){
            if(templateCode.contains('_v2')){
                return templateCode.replace('_v2', '');
            }
            return templateCode;
        }

        private String modifyPhNum(String phNum){
            return '82'+phNum.substring(1);
        }

        private String generateMsgId(){
            Datetime currentTime = Datetime.now();
            
            String year         = currentTime.year().toString();
            String month        = generateTwoDigit(currentTime.month());
            String day          = generateTwoDigit(currentTime.day());
            String hour         = generateTwoDigit(currentTime.hour());
            String minute       = generateTwoDigit(currentTime.minute());
            String second       = generateTwoDigit(currentTime.second());
            String millisecond  = generateTwoDigit(currentTime.millisecond());

            return year+month+day+'_'+hour+minute+second+'_'+millisecond;
        }    

        private String generateTwoDigit(Integer digit){
            return digit > 9 ? digit.toString():'0'+digit;
        }

        private String replaceBodyAndButton(String body, Map<String, String> elementMap) {
            for (String key : elementMap.keySet()) {
                body = body.replace('#{' + key + '}', elementMap.get(key));
            }
    
            return body;
        }

    // ** 6. SUB LOGIC - DATA BRING
        private Sweet_Tracker_Setting__mdt getConnectMetaByNm(String apiNm){
            Sweet_Tracker_Setting__mdt myconfig  = [
                                                    SELECT url__c, userId__c, profileKey__c, apiNm__c 
                                                    FROM Sweet_Tracker_Setting__mdt
                                                    WHERE apiNm__c = :apiNm
                                                    ];
            return myconfig;
        }

        private IF_Authentication__mdt getConnectByIFAuthentiation(){
            // sweet_tracker_sendMessage
            IF_Authentication__mdt myconfig = [
                                            SELECT System__c,SecretKey__c,SystemId__c
                                            FROM IF_Authentication__mdt
                                            WHERE MasterLabel = 'sweet_tracker' 
                                            AND IsActive__c = true 
                                        ];
            return myconfig;
        } 

        private Alimtalk_Tamplate__mdt getAlimTemplateMetaBy(String templateCode){
            Alimtalk_Tamplate__mdt myconfig = [
                SELECT TemplateCode__c, TemplateBody__c, ButtonType1__c, ButtonName1__c, MoblieLink1__c, AddPCUrl__c, IsButton__c, PCLink1__c		
                FROM Alimtalk_Tamplate__mdt
                WHERE TemplateCode__c =: templateCode
                ];
            return myconfig;
        }

    // ** 7. INNER CLASS 
        class ButtonObj {
            public ButtonObj(){}
            public String name       {get;set;}
            public String type       {get;set;}
            public String url_mobile {get;set;}
            public String url_pc {get;set;}
        }

    

}