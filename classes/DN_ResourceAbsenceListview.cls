/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-06   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_ResourceAbsenceListview {

    public DN_ResourceAbsenceListview() {}

    // Apex Page를 사용해서 ResourceAbsence 리스트뷰 화면으로 이동시키는 메서드
    @RemoteAction
    public static String returnUrlPage() {
        String host = URL.getOrgDomainUrl().getHost();
        String returnUrl = 'https://' + host +'/lightning/o/ResourceAbsence/home';
        return returnUrl;
    }
    
}