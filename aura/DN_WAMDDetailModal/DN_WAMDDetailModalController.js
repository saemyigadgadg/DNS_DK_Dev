/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-28-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-27-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({

    doInit: function (component, event, helper) {
        //modalType': 'DUEOUT',
        component.set("v.isLoading", true)
        let modalType = component.get('v.modalType');
        switch (modalType) {
            case 'DUEOUT':
                console.log(modalType, ' ::modalType');
                helper.getDueOut(component);        
                break;
            case 'DUEIN':
                console.log(modalType, ' ::modalType');
                helper.getDueIn(component, event, helper);
                break;
            case 'WAMD':
                console.log(modalType, ' ::modalType');
                helper.getWAMD(component, event, helper);
                break;
            case 'LABST':
                console.log(modalType, ' ::modalType');
                helper.getStockQty(component);
                break;

            default:
                break;
        }
        
    },

    wamdDetailModalCancel : function (component, event, helper) {
        helper.closeModal(component);
    },

    PDFModalCancel : function (component, event, helper) {
        component.set("v.pdfModalOpen", false);
    },

    handlePrint : function(component, event, helper) {
        let docNum = component.get('v.docNum');
        console.log(docNum, ' ::: docNum');
        const today = new Date();
        const formattedDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;

        // 운영 OR 샌드박스 구분
        var baseUrl = window.location.origin;
        if(!baseUrl.includes(".sandbox")) {
            baseUrl += '/s'
        } else {
            baseUrl += '/partners/s'
        }

        let openUrl = `${baseUrl}/DealerPortalPrintView?c_record=${docNum}&c_type=DueOut&c_printDate=${formattedDate}`;
        const B = window.open(`${openUrl}`, `출력`, `top=10, left=10, width=1200, height=1200, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`);
        // Open the modal VF PAGE
        //component.set("v.pdfModalOpen", true);
    },

    // 검색결과 Row선택시 Event로 값 전달
    hadleClick : function (component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var soldToPartyList = component.get('v.soldToPartyList');

        console.log('index', index);
        console.log('soldToParty', soldToPartyList[index]);

        // publish event
        const compEvent = component.getEvent("cmpEvent");
        compEvent.setParams({
            "modalName": 'DN_SoldToPartyListModal',
            "actionName": 'Close',
            "message": soldToPartyList[index]
        });
            
        compEvent.fire();
        helper.closeModal(component);
    }
})