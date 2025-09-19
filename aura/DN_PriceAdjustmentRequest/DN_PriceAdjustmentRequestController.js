/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-11
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-19-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        let today = new Date().toISOString().slice(0,10);
        component.set('v.today',today);

        // 마지막 숫자만큼 row 생성합니다. 하나 생성이 이 페이지 기본입니다.
        helper.addList(component, event, helper, 1);

        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let response = result.r;
            component.set('v.dealerInfo', response);
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            if (errors && errors[0] && errors[0].message) {
                console.log('사용자 에러 발생: ' + errors[0].message);
            } else {
                console.log('예상치 못한 에러 발생.');
            }
        }))
    },

    inputText : function(component, event, helper) {
        let inputCmp = event.getSource(); 
        let value = inputCmp.get("v.value");

        if(value.length > 12) {
            helper.toast('INFO', $A.get("$Label.c.PAR_E_MSG_1"));//'12자리 까지 입력 가능 합니다다.');
            return
        }
    },

    // 관련 파일 첨부
    handleUploadFinished: function(component, event, helper) {
        var uploadedFiles = event.getParam("files"); // 방금 업로드된 파일 정보
        var filesList = component.get('v.filesList');  // 기존 파일 리스트
        console.log('uploadedFiles >> ' +JSON.stringify(uploadedFiles,null,4))
        let fileSize = [];
        let maxFileSize = component.get('v.maxFileSize');
        uploadedFiles.forEach(e=> {
            fileSize.push(e.documentId);
        })

        helper.apexCall(component, 'CheckFileSize', {fId : fileSize, size : maxFileSize})
        .then($A.getCallback(function(result){
            let response = result.r;
            console.log('response size info'+JSON.stringify(response,null,4));

            let filteredFiles = uploadedFiles.filter(file => 
                response.some(res => res.Id === file.documentId)
            );

            console.log('filteredFiles >> ' +JSON.stringify(filteredFiles,null,4));

            filteredFiles.forEach(file => {
                if (!filesList.some(existingFile => existingFile.name === file.name)) {
                    filesList.push(file);
                }
            });

            component.set('v.filesList', filesList);
    
            let contendVersionId = [];
            filesList.forEach(e => {
                contendVersionId.push(e.contentVersionId);
            })

            return helper.apexCall(component, 'ConvertFile', { versionIds : contendVersionId })
        }))
        .then($A.getCallback(function(result) {
            let response = result.r;
            component.set('v.urlFilesList', response);

            return helper.apexCall(component, 'SplitFile', {urlId : response})
        }))
        .then($A.getCallback(function(result) {
            let response = result.r;
            component.set('v.splitFilesList', response);
        }))
        .catch($A.getCallback(function(error){
            console.log('url 변환 error >> ' +JSON.stringify(error,null,4));
        }))
        
    },
    
    // 첨부 파일 삭제
    removeFile: function (component, event, helper) {
        var fileName = event.currentTarget.dataset.file; 
        var fileId   = event.currentTarget.dataset.id;

        var filesList = component.get("v.filesList");
        var splitFilesList = component.get("v.splitFilesList");
        
        var fileIndex = filesList.findIndex(function(file) {
            return file.name.trim() === fileName.trim();
        });

        var fileIndexURL = splitFilesList.findIndex(function(file) {
            return file.FILE_NAME.trim().split('.')[0] === fileName.trim().split('.')[0];
        });

        let deleteList =[];
        deleteList.push(splitFilesList[fileIndexURL].FILE_DOC_ID);
        deleteList.push(filesList[fileIndex].documentId);

        if (deleteList.length > 0) {
            helper.deleteFile(component, deleteList);
        }
        
        if (fileIndex > -1) {
            filesList.splice(fileIndex, 1);
            splitFilesList.splice(fileIndexURL, 1);
        } 

        component.set("v.filesList", filesList);
        component.set("v.splitFilesList", splitFilesList);

        console.log('filesList >> ' +JSON.stringify(filesList));
        console.log('splitFilesList >> ' +JSON.stringify(splitFilesList));
    },


    // 추가 버튼(사용하진 않으나 개발 요청으로 구성)
    addRow: function (component, event, helper) {
        helper.addList(component, event, helper, 1);
        component.find('headerCheckbox').set('v.checked', false);
    },

    // 전체 체크박스 선택(사용하진 않으나 개발 요청으로 구성)
    doCheckAll : function(component, event, helper) {
        component.set('v.checkList', []);
        let checkList = component.get('v.checkList');

        var checkboxes = component.find('checkbox');
        var isChecked = component.find('headerCheckbox').get('v.checked');

        checkboxes.forEach((e, index) => {
            e.set('v.checked', isChecked);
            checkList.push(index);
        })

        component.set('v.checkList', checkList);
    },

    // 체크박스 선택/해제(사용하진 않으나 개발 요청으로 구성)
    doCheck: function (component, event, helper) {
        let partsList = component.get('v.partsList');
        let accesskey = event.getSource().get('v.accesskey');
        let checkList = component.get('v.checkList');

        let index = checkList.indexOf(accesskey);
        
        if (index > -1) { checkList.splice(index, 1); } 
        else { checkList.push(accesskey); }
        
        checkList.sort((a,b) => b-a);
        console.log('checkList >> ' +JSON.stringify(checkList,null,4));
        component.set('v.checkList',checkList);

        if(partsList.length != checkList.length) {
            component.find('headerCheckbox').set('v.checked', false);
        } else {
            component.find('headerCheckbox').set('v.checked', true);
        }
    },
    
    // 개별 삭제 (사용하진 않으나 개발 요청으로 구성)
    deleteRow: function(component, event, helper) {
        let checkList = component.get('v.checkList');
        let partsList = component.get('v.partsList');

        let updatedPartsList = partsList.filter((_, index) => !checkList.includes(index));

        console.log('BF updatedPartsList >> '+JSON.stringify(updatedPartsList,null,4));

        for(let i = 0; i < updatedPartsList.length; i++) {
            updatedPartsList[i].itemNo = String((i+1)*10).padStart(4, '0');
        }

        console.log('AF updatedPartsList >> '+JSON.stringify(updatedPartsList,null,4));

        component.set('v.partsList', updatedPartsList);
        component.set('v.checkList', []);
        component.find('headerCheckbox').set('v.checked', false);
    },    

    // 소문자 대문자로 변환
    handleUpperCase: function (component, event, helper) {
        let inputCmp = event.getSource(); 
        let value = inputCmp.get("v.value");
        
        console.log('inputCmp >> '+inputCmp);
        console.log('value >> '+value);
    
        if (value) {
            inputCmp.set("v.value", value.toUpperCase());
            component.set('v.isExecute', false);
        }
    },

    // 품명 enter
    handleKeyPress: function (component, event, helper) {
        let targetElement = event.target;
        let tdElement = targetElement.closest("td");
        let keyJ = tdElement.getAttribute("accesskey");

        let partsList = component.get('v.partsList');
        let partRecord = partsList[keyJ].partNo;

        let part = component.get('v.part');
        console.log('out part >> ' +JSON.stringify(part,null,4))

        console.log('partRecord >> ' +partRecord);
        if(event.keyCode === 13) {
            if( partRecord == null || partRecord.trim() == '' ) {
                helper.toast('INFO',$A.get("$Label.c.PAR_E_MSG_2"));//'해당 품명에 값이 없습니다.');
            }            
            else {
                part.push(partsList[keyJ]);
                console.log('in part >> ' +JSON.stringify(part,null,4))
                component.set('v.part', part);

                let excute = component.get('c.doExecute');
                $A.enqueueAction(excute);
            }
        }
    },

    // 제안 가격 클릭
    handleFocus: function (component, event, helper) {
        let row = event.getSource().get('v.accesskey');
        let partsList = component.get('v.partsList');
        let partRecord = partsList[row].partNo;
        let part = component.get('v.part');
        if(partRecord == null || partRecord.trim() == '')  {
            helper.toast('INFO',$A.get("$Label.c.PAR_E_MSG_2"));//'해당 품명에 값이 없습니다.');
        }else{
            part.push(partsList[row]);
            component.set('v.part', part);            
            let excute = component.get('c.doExecute');
            $A.enqueueAction(excute);
        }
    },

    // 3자리 콤마
    formatNumber: function (component, event, helper) {
        let inputCmp = event.getSource(); 
        let value = inputCmp.get("v.value");
    
        if (value) {
            let formattedValue = value.replace(/[^\d]/g, '');
            formattedValue = Number(formattedValue).toLocaleString();
            inputCmp.set("v.value", formattedValue);
        }
    },      

    // 실행 버튼
    doExecute : function(component, event, helper) {
        component.set('v.isLoading', true);
        let dealerInfo = component.get('v.dealerInfo');
        let part = component.get('v.part');
        let partsList = component.get('v.partsList');

        let ponList = [];

        if(part.length > 0) {
            ponList = part;
        }else {
            ponList = partsList;
        }

        ponList = ponList.filter(e => e.partNo != null && e.partNo !='');

        if(ponList.length == 0) {
            helper.toast('INFO',$A.get("$Label.c.PAR_E_MSG_3"));//'품번을 입력해주세요.');
            component.set('v.isLoading', false);
            return;
        }

        helper.apexCall(component, 'GetPriceInfo', {dli : dealerInfo, pon : ponList})
        .then($A.getCallback(function(result) {
            component.set('v.isExecute', true);
            let res = result.r;
            partsList.forEach(e => {
                res.forEach(re => {
                    if(e.itemNo == re.itemNo) {
                        e.partNo      = re.partNo;
                        e.partName    = re.partName;
                        e.curr        = re.curr;
                        e.systemPrice = Number(re.systemPrice.split('.')[0]).toLocaleString();
                    }

                    if(e.partNo == null || e.partNo == '') {
                        e.partNo      = null;
                        e.partName    = null;
                        e.curr        = null;
                        e.systemPrice = null;
                    }
                })
            })
            console.log('partsList 초기 생성 >> ' +JSON.stringify(partsList,null,4))
            component.set('v.partsList', partsList);
            component.set('v.part', []);
            component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            if (errors && errors[0] && errors[0].message) {
                console.log('시뮬 에러 발생: ' + errors[0].message);
            } else {
                console.log('예상치 못한 에러 발생.');
            }
        }))
    },

    // 완성 버튼(저장)
    doComplete: function(component, event, helper) {
        component.set('v.isLoading', true);
        let dealerInfo     = component.get('v.dealerInfo');
        let inquiryPONo    = component.get('v.inquiryPONo');
        let requester      = component.get('v.requester');
        let requesterEmail = component.get('v.requesterEmail');
        let equipmentName  = component.get('v.equipmentName');
        let equipmentNo    = component.get('v.equipmentNo');
        let today          = component.get('v.today');

        let filesList      = component.get('v.filesList');
        let splitFilesList = component.get('v.splitFilesList');

        let partsList      = component.get('v.partsList');
        let isExecute      = component.get('v.isExecute');

        let poeFileIds = [];
        filesList.forEach(e => {
            poeFileIds.push(e.documentId)
        });

        partsList = partsList.filter(e => e.partNo != null && e.partNo != '');
        if(partsList.length == 0) {
            component.set('v.isLoading', false);
            return helper.toast('INFO',$A.get("$Label.c.PAR_E_MSG_3"));//'품번을 입력해주세요.');
        }

        // let simulation = partsList.filter(e => e.systemPrice != null);
        // if(simulation.length == 0) {
        //     component.set('v.isLoading', false);
        //     return helper.toast('INFO','실행 버튼을 눌러주세요.');
        // }

        if(!isExecute) {
            component.set('v.isLoading', false);
            return helper.toast('INFO',$A.get("$Label.c.PAR_E_MSG_4"));//'실행 버튼을 눌러주세요.');
        }

        let sugestPrice = partsList.filter(e => e.sugestPrice != null && e.sugestPrice != '' && e.sugestPrice != 0);
        if(sugestPrice.length == 0) {
            component.set('v.isLoading', false);
            return helper.toast('INFO',$A.get("$Label.c.PAR_E_MSG_5"));//'0이 아닌 제안 가격을 입력해주세요.');
        }

        partsList.forEach(e => {
            e.systemPrice = e.systemPrice.replace(/,/g,'');
            e.sugestPrice = e.sugestPrice.replace(/,/g,'');
        });

        let params = {
            inquiryPONo    : inquiryPONo,
            requester      : requester,
            requesterEmail : requesterEmail,
            equipmentName  : equipmentName,
            equipmentNo    : equipmentNo,
            today          : today.replace(/-/g,''),
            partsList      : partsList,
        }        
        helper.apexCall(component, 'CreatePriceRequest', {
                dli     : dealerInfo,
                params  : params,
                poeFile : poeFileIds,
                upload  : splitFilesList
        })
        .then($A.getCallback(function(result) {
            let response = result.r;
            helper.toast('SUCCESS', `${response} 번으로 요청이 생성 되었습니다.`);
            component.set('v.peNo',response);
            helper.backDetailview(component); 

        }))
        .catch($A.getCallback(function(errors) {
            console.log('errors >>> ' +errors);
        }))
    },
})