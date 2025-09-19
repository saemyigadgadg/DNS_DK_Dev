/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-12
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-06-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        // 날짜 초기값 셋팅
        let eDay      = new Date();
        let sDay      = new Date();
        sDay.setDate(1);

        let endDate   = helper.dayCount(eDay);
        let startDate = helper.dayCount(sDay);

        component.set('v.endDate', endDate);
        component.set('v.startDate', startDate);

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('response :: ' +JSON.stringify(response,null,4));
            component.set('v.dealerInfo', response);

            return helper.apexCall(component, 'GetPicklistInfo', {})
        }))
        .then($A.getCallback(function(result){
            let response = result.r;

            component.set('v.complaintType1', response.cpReasonPicklist1);
            component.set('v.complaintType2', response.cpReasonPicklist2);

            const partOrderNo = localStorage.getItem('partOrderNo');
            if (partOrderNo) {
                console.log('오더 생성시 실행되는 로직.')
                component.set('v.returnOrderNo', partOrderNo);
                localStorage.removeItem('partOrderNo');
    
                // doSearch 호출
                var search = component.get('c.doSearch');
                $A.enqueueAction(search);
            }

        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message){
                console.log('errors :: ' +errors[0].message);
            }else{
                console.log('errors :: ㅇㅅㅇ??');
            }
        }))
    },

    //반품상세 모달 open
    openReturnDetailModal : function(component, event, helper) {
        console.log('모달창 오픈')
        component.set('v.returnDetailModal', true)
        var refundList = component.get('v.refundList');
        var clickedElement = event.currentTarget;
        var returnOrderNo = clickedElement.getAttribute("data-returnOrderNo"); // 선택한 (부품)주문번호
        var refundDetail = refundList.filter(e => e.returnOrderNo == returnOrderNo);
        console.log('refundDetail :: ' + JSON.stringify(refundDetail,null,4));

        component.set('v.refundDetail', refundDetail);
    },

    doDownload : function(component, event, helper) {
        let fId = event.getSource().get("v.value");
        console.log("File ID: " + fId);

        let baseUrl = window.location.origin;
        var dlUrl = component.get('v.dlUrl');
        let downloadUrl = baseUrl + dlUrl + fId;
        console.log('Download URL:', downloadUrl);
        window.open(downloadUrl, '_blank');
        // return downloadUrl;
    },

    // generateDownloadUrl: function(contentDocumentId) {
    //     // Salesforce 기본 URL 가져오기
    //     let baseUrl = window.location.origin;
    //     // ContentDocumentId로 다운로드 URL 생성
    //     // https://dn-solutions--dev.sandbox.my.site.com/partners/sfc/servlet.shepherd/document/download/069JO000000UxfNYAS?operationContext=S1
    //     let downloadUrl = baseUrl + '/partners/sfc/servlet.shepherd/document/download/' + contentDocumentId;
    //     console.log('Download URLL:', downloadUrl);
    //     return downloadUrl;
    // },

    //반품상세모달, 프린트 모달 close
    modalCancel : function (component, event, helper) {
        component.set('v.returnDetailModal', false)
        component.set("v.pdfModalOpen", false);
    },

    //프린트 모달 open
    openPrintPDF: function(component, event, helper) {
        component.set("v.returnDetailModal", false);

        const refundDetail = component.get("v.refundDetail");
        if (refundDetail && refundDetail.length > 0) {
            const returnOrderNo = refundDetail[0].returnOrderNo;
            var pdfLabelUrl = component.get('v.pdfLabelUrl');
            const pdfUrl = pdfLabelUrl + encodeURIComponent(returnOrderNo);
            
            component.set("v.pdfUrl", pdfUrl);
        }
        component.set("v.pdfModalOpen", true);        

    },

    // 본문 row 전체 선택
    mainSelectAll: function (component, event, helper) {
        console.log('전체 선택')
        helper.selectAllRows(component, event, helper, "checkboxId", "headerCheckboxId");
    },

    // 본문 체크박스 선택/해제
    mainCheckboxChange: function (component, event, helper) {
        helper.handleCheckboxChange(component, event, helper, "checkboxId");
    },

    doReturnCreate : function (component, event, helper) {
        component.set('v.isLoading', true);
        const navReturnCreate = component.find("navReturnCreate");
        const backUrl = component.get('v.backUrl');
        const page = {
            type: "standard__webPage",
            attributes: {
                url: backUrl
            }
        };
        navReturnCreate.navigate(page);
        component.set('v.isLoading', false);
    },

    inputAttribute : function(component, event, helper) {
        helper.saveAttribute(component, event);
    },

    // 검색
    doSearch : function(component, event, helper) {
        component.set('v.isLoading', true);
        var dealerInfo    = component.get('v.dealerInfo')
        var returnOrderNo = component.get('v.returnOrderNo')
        var referenceNo   = component.get('v.referenceNo')
        var orderPartNo   = component.get('v.orderPartNo')
        var startDate     = component.get('v.startDate')
        var endDate       = component.get('v.endDate')

        var returnReason1 = component.get('v.complaintType1');
        var returnReason2 = component.get('v.complaintType2');

        var dateCheck = helper.dayCounter(startDate, endDate);
        console.log('dateCheck >> ' +JSON.stringify(dateCheck,null,4))

        if(dateCheck < 0) {
            helper.toast('error',$A.get("$Label.c.RI_E_MSG_1"));//'종료일보다 늦은 날짜를 시작일로 선택할 수는 없습니다.');
            component.set('v.isLoading', false);
            return;
        }

        console.log('returnReason1 : '+JSON.stringify(returnReason1,null,4))
        var refundTerms = {
            'dealerInfo'    : dealerInfo,
            'returnOrderNo' : returnOrderNo,
            'referenceNo'   : referenceNo,
            'orderPartNo'   : orderPartNo,
            'startDate'     : startDate,
            'endDate'       : endDate
        }
        console.log('refundTerms ::: ' + JSON.stringify(refundTerms, null, 4));

        helper.apexCall(component, 'GetReturnOrderInfo', {'rft' : refundTerms})
        .then($A.getCallback(function(result) {
            let response = result.r;
            let refundList = [];
            console.log('bf response :: '+JSON.stringify(response,null,4));
            
            response.forEach(e => {
                refundList.push({
                    returnOrderNo     : e.PurchaseOrder__r.PartOrderNo__c,
                    customerOrderNo   : e.PurchaseOrder__r.CustomerOrderNo__c,
                    // orderNo           : e.ItemNo__c,
                    orderNo           : e.OrderNo__c,
                    orderPartNo       : e.OrderPartNo__c,
                    orderPartName     : e.Description__c,
                    orderQuantity     : e.Quantity__c,
                    returnReason1     : e.ComplaintReason1__c,
                    returnReason2     : e.ComplaintReason2__c,
                    docDate           : String(e.PurchaseOrder__r.CreatedDate).split('T')[0].replace(/-/g,'.'),
                    orgDate           : String(e.OriginDocDate__c).replace(/-/g,'.'),
                    referenceNo	      : e.Invoice__c,
                    totalAmount       : Number(e.UnitPrice__c) * Number(e.Quantity__c) * 1.1,
                    poiCurrency       : e.CurrencyIsoCode,
                    note              : e.Note__c,
                    hqOrderNo         : e.HQOrderNo__c,
                    status            : e.Status__c,
                    // status            : e.Status__c == null ? '미진행' : e.Status__c,
                    fileId            : e.ContentDocumentLinks
                })
            })
            console.log('af refundList :: '+JSON.stringify(refundList,null,4));
            component.set('v.isChecked', true);
            component.set('v.refundList', refundList);
            component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(errors) {
            if (errors && errors[0] && errors[0].message) {
                console.error('Error: ' + errors[0].message);
                component.set('v.isLoading', false);
            } else {
                console.error('Unknown error occurred.');
                component.set('v.isLoading', false);
            }
        }));
    },

    // 레코드 삭제
    doDelete : function(component, event, helper) {
        component.set('v.isLoading', true);
        var refundList = component.get('v.refundList');
        var selectedRows = component.get('v.selectedRows');
        var dealerInfo = component.get('v.dealerInfo');

        let deleteOrderList = [];

        console.log('selectedRows :: ' + JSON.stringify(selectedRows,null,4))

        var deleteDuplicateList = new Set(selectedRows);
        deleteOrderList = [...deleteDuplicateList];

        const filtered = refundList.filter(item => 
            item.hqOrderNo && selectedRows.includes(item.returnOrderNo)
        );

        if(filtered.length > 0) {
            helper.toast('ERRORS',$A.get("$Label.c.RI_E_MSG_2"));//'본사 접수번호를 받은 반품 주문은 삭제할 수 없습니다.');
            component.set('v.isLoading', false);
            return;
        }
        
        helper.apexCall(component, 'DeleteReturnOrderItems', {dli : dealerInfo, dol : deleteOrderList})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('response :: ' +JSON.stringify(response,null,4));
            
            component.set('v.returnOrderNo','');
            component.set('v.referenceNo','');
            component.set('v.orderPartNo','');
            component.set('v.isLoading', false);

            helper.toast('SUCCESS', $A.get("$Label.c.RI_S_MSG_1"));//'선택한 레코드가 삭제 되었습니다.');
            let action = component.get('c.doSearch');
            $A.enqueueAction(action);

            
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            if(errors && errors[0] && errors[0].message) {
                console.log('errors :: '+errors[0].message);
            }else{
                console.log('errors :: ㅇㅅㅇ?? ');
            }
        }))
    }
})