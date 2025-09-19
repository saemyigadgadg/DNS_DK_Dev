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
    doInit: function (component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.originDocDate", today);

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('딜러 정보');
            console.log('dealerInfo :: ' +JSON.stringify(response,null,4));
            component.set('v.dealerInfo', response);

            return helper.apexCall(component, 'GetPicklistInfo', {})
        }))
        .then($A.getCallback(function(result){
            let response = result.r;

            component.set('v.complaintType1', response.cpReasonPicklist1);
            component.set('v.complaintType2', response.cpReasonPicklist2);
            component.set('v.isBTN', false);

        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.log('errors :: ' + errors[0].message);
            }else{
                console.log('errors :: ...?');
            }
        }))
    },

    // 반품 대상 찾기 버튼
    doSearchInModal : function(component, event, helper) {
        component.set('v.isModalLoading', true);
        component.set('v.poiList', []);
        
        var dli = component.get('v.dealerInfo');
        var son = component.find('orderNoId').get('v.value');
        var sop = component.find('orderPartNoId').get('v.value');

        if((!son || son.trim() == '') && (!sop || sop.trim() == '')) {
            helper.toast('WARNING',$A.get("$Label.c.RC_E_MSG_1"));//'주문번호나 주문품번 중 하나의 값을 넣어주세요.');
            component.set('v.isModalLoading', false);
            component.set('v.isEmpty', false);
            return;
        }

        son = son != undefined ? son.trim() : null;
        sop = sop != undefined ? sop.trim() : null; 

        helper.apexCall(component, 'GetReturnOrderItems', {dli : dli, son : son, sop : sop})
        .then($A.getCallback(function(result) {
            // 중복된 반품 정보 확인
            let response = result.r;
            component.set('v.itemSpr', response);

            return helper.apexCall(component, 'GetReturnOrder', {dli : dli, son : son, sop : sop})
        }))
        .then($A.getCallback(function(result){
            let response = result.r;
            if(response.length == 0) {
                helper.toast('SUCCESS', $A.get("$Label.c.BPI_E_MSG_3"));//'검색 결과가 없습니다.');
                component.set('v.isModalLoading', false);
                return
            }else {
                component.set('v.isEmpty', true);
                var itemSpr = component.get('v.itemSpr');

                response.forEach(e => {
                    itemSpr.forEach(f => {
                        if(f.ItemSpr__c == e.invoice + e.itemNo) {
                            e.unCheck = true;
                        }
                    })
                })
                component.set('v.poiList', response);
                component.set('v.orderNo', son);
                component.set('v.isModalLoading', false);
            }

        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.log('errors :: '+errors[0].message);
                component.set('v.isModalLoading', false);
            }else{
                console.log('errors :: errors???');
                component.set('v.isModalLoading', false);
            }
        }))
    },

    dontSelect : function(componsnet, event, helper) {
        helper.toast('WARNING', $A.get("$Label.c.RC_E_MSG_2"));//'이미 반품 처리된 부품 입니다. 다른 부품을 선택해 주세요.');
    },

    // 반품 선택
    doSelect : function(component, event, helper) {
        var refundList = component.get('v.refundList');
        var selectedRows = component.get('v.selectedRows');
        var poiList = component.get('v.poiList');
        let selectList = [];
        let orderQtyList = [];

        if(selectedRows.length == 0) {
            helper.toast('WARNING', $A.get("$Label.c.RC_E_MSG_3"));//'최소 하나의 값을 선택하셔야 합니다.');
            return;
        }

        for(let i = 0; i < selectedRows.length; i++) {
            selectList.push(poiList[selectedRows[i]]);
        }
        
        let firstInvoce = selectList[0].invoice;

        let checkInvoice = selectList.every(e => e.invoice == firstInvoce);

        if(!checkInvoice) {
            firstInvoce = '';
            selectList = [];
            helper.toast('WARNING', $A.get("$Label.c.RC_E_MSG_4"));//'invoice 값은 같아야 합니다.');
            return;
        }

        if(refundList.length != 0) {
            for(let i = Number(selectedRows[0]); i < Number(selectedRows[0])+1; i++){
                var duplication = refundList.some(e => e.invoice === poiList[i].invoice);
                if(duplication) {
                    var duplication = refundList.some(e => e.itemNo === poiList[i].itemNo);
                    if(duplication) {
                        helper.toast('SUCCESS', $A.get("$Label.c.RC_E_MSG_5"));//'이미 선택된 대상 입니다.');
                        return;
                    } else {
                        refundList.push(poiList[i]);
                        component.set('v.refundList', refundList);

                        var lastOne = [...component.get('v.refundList')];
                        var netvalue = lastOne.pop().netValue.split('.')[0];
                        var strValue = Number(netvalue).toLocaleString();
                        helper.toast('SUCCESS', `${strValue}`);

                        component.set('v.searchReturnTargetModal', false);
                    }
                } else{
                    helper.toast('SUCCESS', $A.get("$Label.c.RC_E_MSG_6"));//'Invoice 값이 같은 경우에만 추가 선택이 가능합니다.');
                    return;
                }
            }
        } else {
            refundList = [];

            for (let i = 0; i < selectedRows.length; i++) {
                refundList.push(poiList[selectedRows[i]]);
            }

            refundList.forEach(e=>{
                orderQtyList.push(e.orderQty);
            })

            component.set('v.refundList', refundList);
            component.set('v.orderQtyList', orderQtyList);

            var lastOne = [...component.get('v.refundList')];
            var netvalue = lastOne.pop().netValue.split('.')[0];
            var strValue = Number(netvalue).toLocaleString();
            helper.toast('SUCCESS', `${strValue}`);
            
            component.set('v.searchReturnTargetModal', false);
        }

        component.set('v.selectedRows', []);
        // component.set('v.isEmpty', false);
    },    

    // 반품 생성 버튼
    doSave : function(component, event, helper) {
        component.set('v.isLoading', true)
        console.log('저장 로직 시작');
        var dealerInfo            = component.get('v.dealerInfo');
        var partOrderNo           = component.get('v.partOrderNo');
        var refundCustomerOrderNo = component.get('v.refundCustomerOrderNo');
        var refundList            = component.get('v.refundList');
        
        if(refundCustomerOrderNo == null || refundCustomerOrderNo == '') {
            helper.toast('WARNING', $A.get("$Label.c.ORC_MSG_7"));//'고객주문번호를 입력해주세요');
            component.set('v.isLoading', false)
            return;
        }

        if(refundList.length == '0') {
            helper.toast('WARNING', $A.get("$Label.c.RC_E_MSG_8"));//'반품하실 부품을 선택해 주세요.');
            component.set('v.isLoading', false)
            return;
        }

        if (refundList && refundList.length > 0) {
            var missingFields = [];
            
            for (var index = 0; index < refundList.length; index++) {
                var item = refundList[index];
                var emptyFields = [];
                
                if (!item.complaintReason1 || item.complaintReason1.trim() === '') {
                    emptyFields.push('환불 사유1');
                }
                if (!item.complaintReason2 || item.complaintReason2.trim() === '') {
                    emptyFields.push('환불 사유2');
                }
                if (!item.note || item.note.trim() === '') {
                    emptyFields.push('환불 내용');
                }
        
                if (emptyFields.length > 0) {
                    missingFields.push('환불 건 ' + (index + 1) + '>> ' + emptyFields.join(' || '));
                }
            }
        
            // 누락된 필드가 있는 경우
            if (missingFields.length > 0) {
                helper.toast("WARNING", '[ 비어있는 필드 ] ' + missingFields);
                component.set('v.isLoading', false)
                return;
            }
        }

        refundList.forEach(e => {
            e.filesInfo = JSON.stringify(e.filesInfo)
            e.itemSpr = e.invoice + e.itemNo;
        })

        var refundOrderInfo = {
            dealerInfo             : dealerInfo,
            partOrderNo            : partOrderNo,
            refundCustomerOrderNo  : refundCustomerOrderNo,
            refundList             : refundList
        }
        console.log('refundOrderInfo :: '+JSON.stringify(refundOrderInfo,null,4))
        
        component.set('v.isBTN', true);
        helper.apexCall(component, 'saveRefundOrder', { 'ri' : refundOrderInfo })
        .then($A.getCallback(function(result) {
            let response = result.r;
            console.log('저장 완료');
            helper.toast('SUCCESS', `${response} 번으로 반품 신청이 되었습니다.`);

            if(response != '생성 실패') {
                const partOrderNo = response;
                localStorage.setItem('partOrderNo', partOrderNo);
                helper.abackOrderInquiry(component);    
            }else{
                component.set('v.isLoading', false)
                component.set('v.isBTN', false);
                helper.toast('ERROR', $A.get("$Label.c.RC_E_MSG_10"));//'레코드 생성에 실패했습니다. 반복될 경우 관리자에게 문의 바랍니다.')
            }

        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false)
            component.set('v.isBTN', false);
            console.log('errors>> '+JSON.stringify(errors,null,4))
            helper.toast('ERROR', $A.get("$Label.c.PES_E_MSG_2"));//'관리자에게 문의 바랍니다.')
        }));
    },

    //반품상세 모달 open
    openModal : function(component, event, helper) {
        component.set('v.searchReturnTargetModal', true);
        component.set('v.poiList', '');
    },

    //반품상세모달, 프린트 모달 close
    modalCancel : function (component, event, helper) {
        component.set('v.searchReturnTargetModal', false)
    },

    // 뒤로 돌아가기
    backReturnInquiry: function (component, event, helper) {
        window.history.back();
    }, 

    // 모달 체크박스 선택/해제
    modalCheckboxChange: function (component, event, helper) {
        helper.handleCheckboxChange(component, event, helper, "checkbox");
    },

    // 본문 체크박스 선택/해제
    mainCheckboxChange: function (component, event, helper) {
        helper.handleCheckboxChange(component, event, helper, "checkboxId");
    },

    // 모달 row 전체 선택
    modalSelectAll: function (component, event, helper) {
        helper.selectAllRows(component, event, helper, "checkbox", "headerCheckbox");
    },

    // 본문 row 전체 선택
    mainSelectAll: function (component, event, helper) {
        helper.selectAllRows(component, event, helper, "checkboxId", "headerCheckboxId");
    },

    // 선택된 Parts List 삭제
    selectedDeletePartsProduct: function (component, event, helper) {
        var selectedRows = component.get('v.selectedRows');
        var refundList = component.get("v.refundList");

        if(selectedRows.length == 0) {
            helper.toast('WARNING', $A.get("$Label.c.RC_E_MSG_3"));//'최소 하나의 값을 선택하셔야 합니다.');
            return;
        }

        selectedRows.sort(function (a, b) { return b - a; });

        for (var i = 0; i < selectedRows.length; i++) {
            refundList.splice(selectedRows[i], 1);
        }

        component.set('v.selectedRows', []);
        component.set('v.refundList', refundList);
    },

    // value 입력
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },

    // 파일 업로드
    handleUploadFinished: function(component, event, helper) {
        component.set('v.isLoading', true);
        let fId = [];
        let deleteFileId = [];
        let crmFileList = component.get('v.crmFileList');
        console.log('crmFileList >> ' +JSON.stringify(crmFileList,null,4))
        // let crmFileList = [];

        let uploadedFiles = event.getParam("files"); // 방금 업로드된 파일 정보

        let excludedFileTypes = [
            "asp", "aspx", "jsp", "php", "inc", "cgi",  
            "html", "htm", "js", "jar", "jhtml", "php3", "phtml"
        ];

        let maxFileSize = component.get('v.maxFileSize');
        
        
        console.log('uploadedFiles >> ' +JSON.stringify(uploadedFiles,null,4));

        let fileList = uploadedFiles.filter(file => {
            let fileExtension = file.name.split('.').pop().toLowerCase();
            let isExcluded = excludedFileTypes.includes(fileExtension);
            
            if(isExcluded) {
                helper.toast('INFO', `"${file.name}" ${$A.get("$Label.c.RC_E_MSG_11")}`);//은 업로드 할 수 없는 파일 입니다.`); ★
                deleteFileId.push(file.documentId);
            };
            return !isExcluded;
        });
        
        console.log("확장자 걸러내기:", JSON.stringify(fileList,null,4));

        fileList.forEach(e=>{
            fId.push(e.documentId);
        })

        if(fileList.length == 0) {
            helper.toast('INFO',$A.get("$Label.c.RC_E_MSG_12"));//'업로할 파일이 없습니다.');
        }else {
            helper.apexCall(component, 'checkFileSize', { fId: fId })
            .then($A.getCallback(function (result) {
                let response = result.r;
                let fileList = response.filter(file => {
                    if(file.ContentSize > maxFileSize) {
                        helper.toast('INFO', `"${file.Title}" ${$A.get("$Label.c.RC_E_MSG_13")}`);//은 제한 용량을 초과 했습니다.`);
                        deleteFileId.push(file.Id);
                        return;
                    }else {
                        return file;
                    };
                })
    
                console.log('삭제 ID >' + JSON.stringify(deleteFileId, null, 4));
                console.log('업로드 ID>' + JSON.stringify(fileList, null, 4));
                console.log('최초의 crmFileList>>' + JSON.stringify(crmFileList, null, 4));

                // 깊은 복사 하기
                crmFileList.push(...helper.deepCopy(fileList));
                
                console.log('Id 업로드 crmFileList>>', JSON.stringify(crmFileList,null,4));

                component.set('v.filesList', fileList);
                return helper.apexCall(component, 'DeleteFiles', {fileId : deleteFileId, idType: null})
            }))
            .then($A.getCallback(function(result) {
                let response = result.r;
                console.log(response);
                let filesList = component.get('v.filesList');
                let docIds = [];
                filesList.forEach(e => {
                    docIds.push(e.Id);
                })

                return helper.apexCall(component, 'ConvertFile', {docIds : docIds})
            }))
            .then($A.getCallback(function(result){
                let response = result.r;
                console.log('html version Id >> ' +JSON.stringify(response,null,4));

                return helper.apexCall(component, 'SplitFile', {urlId : response})
            }))
            .then($A.getCallback(function(result) {
                let response = result.r;
                console.log('최종 response >>' +JSON.stringify(response,null,4));
                let refundList = component.get('v.refundList');
                let rowIndex = event.getSource().get('v.accesskey');

                console.log('매칭 전 값 확인 crmFileList >>> ', JSON.stringify(crmFileList,null,4));
                crmFileList.forEach(e => {
                    response.forEach(f => {
                        if(e.Title.trim() == f.FILE_NAME.trim().split('.')[0]) {
                            e.verId = f.FILE_ID;
                        }    
                    })
                })
                
                console.log('매칭 후 값 확인 crmFileList >>> ' +JSON.stringify(crmFileList,null,4));

                console.log('rowIndex>>>> '+JSON.stringify(rowIndex,null,4))
                console.log('refundList>>>> '+JSON.stringify(refundList[rowIndex],null,4))

                if(refundList[rowIndex].fileInfo == null) {
                    refundList[rowIndex].fileInfo = response;
                }else {
                    refundList[rowIndex].fileInfo.push(...response);
                }

                refundList[rowIndex].crmFileInfo = crmFileList;

                component.set('v.refundList', refundList);

                console.log('refundList>>>> '+JSON.stringify(refundList,null,4))
                console.log('crmFileList >>> ' +JSON.stringify(crmFileList,null,4));
                component.set('v.isLoading', false);

            }))
            .catch($A.getCallback(function (errors) {
                component.set('v.isLoading', false);
                if (errors && errors[0] && errors[0].message) {
                    console.log('errors[0].message ::: ' + errors[0].message);
                } else {
                    console.log('errors[0].message empty');
                }
            }));
        }
    },

    // 파일 remove 
    removeFile: function (component, event, helper) {
        console.log('1')
        let fileName = event.currentTarget.dataset.file;
        let rowIndex = event.currentTarget.dataset.index;
        let refundList = component.get('v.refundList');
        let ver = 'ver';
        console.log(fileName +'____'+rowIndex);


        // 해당 행의 fileNames 및 fileIds 업데이트
        let filesInfo = refundList[rowIndex].fileInfo;
        let crmFileInfo = refundList[rowIndex].crmFileInfo;
        
        console.log('filesInfo >> ' +JSON.stringify(filesInfo,null,4))
        console.log('crmFileInfo >> ' +JSON.stringify(crmFileInfo,null,4))

        // 파일 이름의 인덱스를 찾고 제거
        let fileIndex = filesInfo.findIndex(file => file.FILE_NAME === fileName);
        let fileIndexC = crmFileInfo.findIndex(file => file.Title === fileName.split('.')[0]);

        console.log('fileIndex >> ' +JSON.stringify(fileIndex,null,4))
        console.log('fileIndexC >> ' +JSON.stringify(fileIndexC,null,4))

        let deleteFileIds = [];
        let deleteCrmFileIds = [];

        deleteFileIds.push(filesInfo[fileIndex].FILE_DOC_ID);
        deleteFileIds.push(crmFileInfo[fileIndexC].Id);
        // deleteCrmFileIds.push(crmFileInfo[fileIndexC].Id);

        console.log('html delete list '+JSON.stringify(deleteFileIds,null,4))
        console.log('crm delete list '+JSON.stringify(deleteCrmFileIds,null,4))

        if (fileIndex > -1) {
            filesInfo.splice(fileIndex, 1);
            crmFileInfo.splice(fileIndexC, 1);
        }

        refundList[rowIndex].fileInfo = filesInfo;
        refundList[rowIndex].crmFileInfo = crmFileInfo;
        component.set("v.refundList", refundList);

        helper.apexCall(component, 'DeleteFiles', {fileId : deleteFileIds, idType : null})
        .then($A.getCallback(function(result){
            let response = result.r;
            console.log(response);

        //     return helper.apexCall(component,'DeleteFiles', {fileId : deleteCrmFileIds, idType : null})
        // }))
        // .then($A.getCallback(function(result){
        //     let response = result.r;
        //     console.log(response);
        //     component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(error){
            component.set('v.isLoading', false);
            console.log('에러 >> ' +error);
        }))
        console.log('refundList>>>> '+JSON.stringify(refundList,null,4))
    },
    
})