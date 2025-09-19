/**
 * @description       : 
 * @author            : Junhee Jang
 * @group             : 
 * @last modified on  : 06-21-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-21-2024   Junhee Jang     Initial Version
**/
public with sharing class IF_NTS_BusinessNumber {
    public static String SecretKey = getSecretKey();

    // init method
    private static String getSecretKey(){
        IF_Authentication__mdt ifAuthMdt = [
            SELECT  Id, SecretKey__c
            FROM    IF_Authentication__mdt
            WHERE   System__c = '국세청'
            LIMIT   1
        ];

        return ifAuthMdt.SecretKey__c;
    }

    // main method
    public static Map<String, Object> getBusinessNumber(String businessNumber){
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            InterfaceCommonUtil util = new InterfaceCommonUtil();
            System.debug(SecretKey);
            util.queryStringParam = '?serviceKey=' + SecretKey;

            String parameters = 
                '{'
            +        '"b_no": '
            +        '['
            +           '"' + businessNumber + '"'
            +       ']'
            +   '}';

            IF_NTS_BusinessNumber_Class.GetBusinessNumberRes resbody = 
                (IF_NTS_BusinessNumber_Class.GetBusinessNumberRes) JSON.deserialize(
                    util.sendHttp(
                        parameters,
                        'NTS_BusinessNumber',
                        'IF_NTS_BusinessNumber',
                        false),
                    IF_NTS_BusinessNumber_Class.GetBusinessNumberRes.class);

            resMap.put('resBody', resbody);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            resMap.put('errorMessage', e.getMessage() + '[ ' + e.getLineNumber() + ']');
            resMap.put('flag', 'fail');
        }
        return resMap;
    }

}