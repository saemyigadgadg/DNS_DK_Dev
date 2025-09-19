({
    doInit : function(component, event, helper) {
        console.log(`${component.getName()}.doInit : `);
        // let recordId = component.get('v.recordId');
        // component.set('v.isLoading', true);
        // helper.apexCall(component, event, helper, 'doDownloadQuote', {recordId})
        //        .then($A.getCallback(function(result) {

        //     let { r, state } = result;

        //     console.log('r : ',  r);
        //     console.log('state : ',  state);
        //     if(r.status.code === 200 ) {
        //         helper.gfnExcelDownload(component, r.quote);
        //     }
        //     if(r.status.code === 500 ) {
        //         helper.toast('warning', '저장 중에 오류가 발생하였습니다. 관리자한테 문의해주세요. ');
        //     }
            
        // })).catch(function(error) {
        //     console.log('# addError error : ' + error.message);
            
        // });

    },

    excelLoadingComplete : function(component, event, helper) {
        console.log(`${component.getName()}.excelLoadingComplete : `);
        component.set('v.progressValue', '10');
        helper.gfnDoinit(component, event);
    }
})