/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-06-17
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-28-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
@RestResource(urlMapping='/CTI/getPhoneNumber')
global class IF_CTI_UserInfo_API {
    
    // GET 요청을 처리하는 메소드
    @HttpGet
    global static Map<String, String> getPhoneNumber() {
        return new Map<String, String>{'Name' => '', 'Phone' => ''};
    }
}