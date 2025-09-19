/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-03-26
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-26   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ResourceAbsenceListview_TEST {
    public DN_ResourceAbsenceListview_TEST() {}

    
    @isTest
    static void returnUrlPageTest() {
        DN_ResourceAbsenceListview instance = new DN_ResourceAbsenceListview();
        String result = DN_ResourceAbsenceListview.returnUrlPage();
    }
}