/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-12
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-19-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        let params = new URLSearchParams(window.location.search);
        let partsList = component.get('v.partsList');
        let attachFile = component.get('v.attachFile');
        let peNo = params.get("peNo");
        component.set('v.peNo',peNo);

        // if(peNo == '5000000079') {
        //     component.set('v.isTest', true);
        // }    

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result){
            let response = result.r;
            component.set('v.dealerInfo', response);

            return helper.apexCall(component, 'GetStatusDetail', {
                dli : response,
                pen : peNo
            });
        }))
        .then($A.getCallback(function(result){
            let dli = component.get('v.dealerInfo');
            let response = result.r;
            console.log('response >> ' +JSON.stringify(response,null,4));
            if(response.returnStatus === 'S') {
                attachFile = response.attachFile;
                partsList = response.statusRecord;
                partsList.forEach(e=> {
                    e.systemPrice  = Number(e.systemPrice).toLocaleString();
                    e.suggestPrice = Number(e.suggestPrice).toLocaleString();
                    e.newPrice = Number(e.newPrice).toLocaleString();
                })
                console.log('partsList >> ' +JSON.stringify(partsList,null,4))
                let detailInfo = {
                    creationDate  : response.creationDate,
                    equipmentName : response.equipmentName,
                    equipmentNo   : response.equipmentNo,
                    partDealer    : response.partDealer,
                    peNo          : response.peNo,
                    poNo          : response.poNo,
                    requester     : response.requester,
                    requesterEmail : response.requesterEmail,
                    returnStatus  : response.returnStatus,
                    remark        : response.remark,
                    rjReason      : response.rjReason,
                    status        : response.status,
                }
                component.set('v.detailInfo', detailInfo);
                component.set('v.partsList', partsList);
                // component.set('v.attachFile', attachFile);

                return helper.apexCall(component, 'GetCrmFile', { dli : dli, pen : peNo})

                // return helper.apexCall(component, 'GetAttachFile', { dli : dli, pen : peNo})

            }else {
                helper.toast('ERROR', $A.get("$Label.c.PES_E_MSG_2"));//'관리자에게 문의 부탁 드립니다.');
            }
        }))
        .then($A.getCallback(function(result){
            let response = result.r;
            let fileList = [];
            component.set('v.isLoading', false);
            console.log('crm file >> ' +JSON.stringify(response,null,4));
            if(response.length != 0) {
                if(response[0].ContentDocumentLinks) {
                    response.forEach(e=> {
                        e.ContentDocumentLinks.forEach(f=> {
                            let fileInfo = {
                                Id : f.ContentDocument.Id,
                                Title : f.ContentDocument.Title
                            }
                            fileList.push(fileInfo)
                        })
                    })
                    console.log('fileList >> ' +JSON.stringify(fileList,null,4))
                    component.set('v.attachFile', fileList);
                }    
            }
        }))
        .catch($A.getCallback(function(error){
            component.set('v.isLoading', false);
            console.error('ERROR >> ' +JSON.stringify(error,null,4));
        }))
    },

    backPage: function (component, event, helper) {
        // window.history.back();
        var backUrl = component.get('v.backPageUrl');
        const navProgressStatusView = component.find('navProgressStatusView');
        const page = {
            type: 'standard__webPage',
            attributes: {
                url: backUrl
            }
        }
        navProgressStatusView.navigate(page);
    }, 

    //프린트 모달 close
    modalCancel : function (component, event, helper) {
        component.set("v.pdfModalOpen", false);
    },

    //프린트 모달 open
    openPrintPDF: function(component, event, helper) {
        let pdfUrl = component.get('v.pdfUrl');
        let peNo = component.get('v.peNo')
        component.set('v.pdfUrl', `${pdfUrl}?peNo=${peNo}`)
        component.set("v.pdfModalOpen", true);        
    },

    doDownload : function(component, event, helper) {
        let fId = event.getSource().get("v.value");
        console.log("File ID: " + fId);

        var dlUrl = component.get('v.dlUrl');
        let baseUrl = window.location.origin;
        let downloadUrl = baseUrl + dlUrl + fId;
        console.log('Download URL:', downloadUrl);
        window.open(downloadUrl, '_blank');
        // return downloadUrl;
    },

    doTestDown : function(component, event, helper) {
        let dli = component.get('v.dealerInfo');
        let pen = component.get('v.peNo');

        helper.apexCall(component, 'GetAttachFile', {dli : dli, pen : pen})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('파일 소환 >> ' +JSON.stringify(response,null,4));

        }))
        helper.apexCall(component,'saveAttachment', {})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('파일 결과 값 >> ' +JSON.stringify(response,null,4));
        }))
        .catch($A.getCallback(function(error) {
            console.log('error >> ' +JSON.stringify(error,null,4));
        }))

        

    }
})