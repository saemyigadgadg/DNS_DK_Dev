/**
 * @author            : Jun-Yeong Choi
 * @Description       : 
 * @last modified on  : 12-20-2024
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        let today = new Date();
        let formattedDate = today.getFullYear() + '-' +
            String(today.getMonth() + 1).padStart(2, '0') + '-' +
            String(today.getDate()).padStart(2, '0');
        component.set('v.printDate', formattedDate);
        //디폴트 쿼리 설정
        helper.setQuery(component);
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(" setSubscriptionLMC");
            console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach':
                    helper.getDataQuery(component, params.type, '검색이 완료되었습니다.')
                        .then($A.getCallback(function(result) {
                            component.set('v.isExcelData', false);
                            component.set('v.isExcelButton', false);
                            component.set('v.excelData', []);
                            let totalRecordSize = component.get('v.totalRecordSize');
                            if(totalRecordSize > 0) {

                                let TOTALSIZE = component.get('v.totalPage');
                                // if(totalRecordSize < 35) {
                                //     TOTALSIZE = 1;
                                // }
                                console.log(TOTALSIZE, ' ::: TOTALSIZE');

                                let index = 0; // 현재 처리 중인 인덱스
                                const batchSize = 20;// 한 번에 실행할 개수

                                function processNext() {
                                    if (index >= TOTALSIZE) {
                                        component.set('v.isExcelData', true);
                                        //setTimeout(() => {
                                            helper.excelDataSet(component)
                                            .then($A.getCallback(function(message) {
                                                console.log('Excel 다운로드 완료');
                                                if(component.get('v.isExcelButton')) {
                                                    helper.handleExcelDownload(component,params.type);    
                                                    component.set('v.isExcelButton', false);
                                                }
                                            }))
                                            .catch($A.getCallback(function(error) {
                                                console.error('Excel 생성 실패:', error);
                                                //alert('Excel 파일 생성 중 오류가 발생했습니다.');
                                            }));
                                            return;    
                                        //}, 0);
                                    }
                                    let promises = [];
                                    for (let i = 0; i < batchSize && index < TOTALSIZE; i++, index++) {
                                        console.log(index + 1, ' Processing...');
                                        promises.push(helper.setExcelData(component, index + 1));
                                    }

                                    // 한 번에 batchSize만큼 실행 후 다음 프레임에서 처리
                                    Promise.all(promises)
                                        .then(() => {
                                            //setTimeout(() => {
                                                requestAnimationFrame(processNext);
                                            // }
                                            // , 0);
                                            
                                        })
                                        .catch(error => {
                                            console.log(error, ' :: 처리 중 오류 발생');
                                        });
                                }
                                // 첫 번째 작업 시작
                                requestAnimationFrame(processNext);
                            }
                        })).then($A.getCallback(function(result) {
                            console.log('Excel 다운로드 완료');
                            
                        }))
                        .catch(error => {
                            console.log(error,' :: sserror');
                        });
                            
                       
                    break;
                case 'Delete':  // 저장위치 삭제
                    helper.setDelete(component,params.type);
                    break;
                case 'ExcelDownload': 
                    component.set('v.isLoading', true);
                    component.set('v.isExcelButton', true);
                    if(component.get('v.isExcelData')) {
                        helper.handleExcelDownload(component,params.type); 
                        component.set('v.isExcelButton', false);
                    }
                    break;
                case 'Output':
                    helper.handleOutput(component,params.type);
                    break;    
                case 'PageChnage':
                    //console.log(JSON.stringify(msg), ' msg');
                    component.set('v.nextPage',params.message.nextpage);
                    component.set('v.currentPage',params.message.currentPage);
                    helper.getDataQuery(component,params.type, '검색이 완료되었습니다.');
                    break; 
                case 'ExcelUpload':
                    component.set('v.excelUploadModal', true);
                    // setTimeout(function() {
                    //     let childComponent = component.find('excelTemplate');
                    //     console.log(JSON.stringify(childComponent.uploadTemplate), ' ::: chiltess');
                    //     component.set('v.uploadTemplate', childComponent.uploadTemplate.columnList);
                    // },0);
                    break;
                default:
                    break;
            }  
        }
    },
    

    //엑셀 업로드 모달 close
    closeUploadExcel: function (component, event, helper) {
        component.set('v.excelUploadModal', false);
    },

    //uploadExcel
    uploadExcel: function (component, event, helper) { 
        component.set('v.isLoading', true);
        let uploadedFiles = event.getSource().get("v.files");
        let file = uploadedFiles[0];
        

        helper.handleNotOneRowUpload(component,file,event)
        .then($A.getCallback(function(result) {
            //searchPriceInfo
            
            component.set('v.excelUploadModal', false);
            console.log(JSON.stringify(component.get('v.uploadData')), '< == uploadData');
            let excelData = component.get('v.uploadData');
            if(excelData.length >170) {
                component.set('v.isLoading', false);
                helper.toast('Error','업로드 가능한 최대 Row는 170개입니다. 업로드 문서를 수정해주세요');
                return ;    
            }
            let param = {};
            excelData.forEach(element => {
                let prodCode = '';
                let fmLoc = [];
                if(Object.keys(element).length > 0) {
                    for(let i=0; i<Object.keys(element).length; i++) {
                        console.log(JSON.stringify(element), ' test');
                        if(element[i] !='') {
                            if(i==0) {
                                console.log(element[i]);
                                prodCode =  String(element[i]).trim();
                                
                            } else {
                                fmLoc.push(String(element[i]).trim());
                            }
                        }
                    }
                    param[prodCode] = fmLoc.join('-');
                } 
                console.log(prodCode,' ::: prodCode');
                console.log(fmLoc,' ::: fmLoc');
            }); 
            
            console.log(JSON.stringify(param),' ::::param');
            helper.apexCall(component,event,this, 'excelUpload', {
                uploadMap : param
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                // 업로드 후 새로 조회 및 엑셀 데이터
                helper.getDataQuery(component, 'Seach', '업로드 되었습니다.')
                        .then($A.getCallback(function(result) {
                            component.set('v.isExcelData', false);
                            let promises = [];
                            const TOTALSIZE = component.get('v.totalPage');
                            for (let i = 0; i < TOTALSIZE; i++) {
                                //helper.setExcelData(component, i+1)
                                console.log(i+1, ' iiiiiii::');
                                promises.push(
                                    helper.setExcelData(component, i+1)
                                ); 
                            }
                            Promise.all(promises).then(() => {
                                component.set('v.isExcelData', true);
                                //엑셀 버튼 누른 경우
                                if(component.get('v.isExcelButton')) {
                                    helper.handleExcel(component);
                                }
                            }).catch(error => {
                                console.log(error,' :: aaaasserror');
                            });
                        })).then($A.getCallback(function(result) {
                            console.log(' 엑셀데이터 작업 종료');
                        }))
                        .catch(error => {
                            console.log(error,' :: sserror');
                        })
            })).catch(function(error) {
                helper.toast('error', error[0].message);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                component.set('v.isLoading', false);
            });
        })).catch(error => {
            if(Array.isArray(error)) {
                helper.toast('error', error[0]);
            } else {
                helper.toast('error', error);
            }
            
            
            console.error("Error during file upload:", error);
            component.set('v.isLoading', false);
        }).finally(function () {
            component.set('v.isLoading', false);
        });
        
    },

    //모든 체크박스 선택
    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox");
        var isChecked = component.find("headerCheckbox").get("v.checked");
        var plist = [];
        let allData = component.get('v.recordList');
        console.log(isChecked,' ::: isChecked');

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    console.log(index,' :::ALL index');
                    checkbox.set("v.checked", isChecked);
                    plist.push(allData[index]);
                });
            } else { 
                checkboxes.set("v.checked", isChecked);
                plist = [];
            }
        } else {
            console.log(isChecked, ' else :: isChecked');
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    console.log(index,' :::ALL index');
                    checkbox.set("v.checked", isChecked);
                    
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
            plist = [];
        }
        component.set('v.seletedList', plist);
        let seleted = component.get('v.seletedList');
        console.log('seletedList:', JSON.stringify(seleted));
    },

    // 체크박스 선택
    handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        console.log(index,' < ===index');
        let allData = component.get('v.recordList');
        let seletedList = component.get('v.seletedList');
        if(check) {
            seletedList.push(allData[index]);
        } else {
            seletedList = seletedList.filter(item => item.id !== allData[index].id);
        }
        console.log(JSON.stringify(seletedList), ' ::::seletedList');
        component.set('v.seletedList', seletedList);
    },

    //저장위치 상세정보
    storageBinDetail: function (component, event, helper) {
        component.set('v.storageBin', true);
        var index = event.currentTarget.name;
        console.log(event.currentTarget.dataset.id);
        helper.storageBinDetailInfo(component,event,event.currentTarget.dataset.id);
        //var data = component.get('v.recordList');
        // var selectedRow = data[index];
        // console.log('selectedRow::', selectedRow);
        // component.set('v.selectedRow', selectedRow);
    },
    // 상세정보 닫기
    storageBinModalCancel: function (component, event, helper) {
        component.set('v.storageBin', false);
    },

    // 로우마다 저장위치 설정
    storageBinSetting: function (component, event, helper) {
        component.set('v.isLoading', true);
        var index = event.currentTarget.name;
        console.log(index,' < ===index');
        var storageBinList = component.get('v.recordList');
        console.log(JSON.stringify(storageBinList[index]), ' row :::');
        var type = 'Setting';
        let parts = {
            'buyerName' : storageBinList[index].dealerName,
            'partNumber' : storageBinList[index].partNumber,
            'stockLocation' : storageBinList[index].location,
            'partId' : storageBinList[index].partId
        };
        console.log(JSON.stringify(parts), ' M===parts');
        
        $A.createComponent("c:DN_SettingStorageModal",
            {
                "type": type,
                "parts": parts
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("settingStorageModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        component.set('v.isLoading', false);
    },
    
    //저장위치 Modal Event
    handleModalEvent : function(component, event, helper) {
        let message = event.getParam('message');
        console.log(JSON.stringify(message), ' < ==message');
        if(message=='Save') {
            // let action = component.get('c.doInit');
            // $A.enqueueAction(action);
            helper.getDataQuery(component,'Seach','저장위치가 저장되었습니다.');
        }
    },

})