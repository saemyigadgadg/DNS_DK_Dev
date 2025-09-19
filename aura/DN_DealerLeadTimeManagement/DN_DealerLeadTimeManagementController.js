({
    doInit : function(component, event, helper) {
        helper.setQuery(component);
        component.set('v.recordList', []);
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach':
                    helper.getDataQuery(component);
                    break;
                case 'ExcelUpload':
                    component.set('v.excelUploadModal', true);
                    break;
                default:
                    break;
            }  
        }
    },

    // mass Adjust 입력값 화면
    handleSearch : function(component, message, helper) {
        let seletedList = component.get('v.selectList');
        if(seletedList.length ==0) {
            helper.toast('error', 'PDF Rate입력할 항목을 선택해주세요');
            return; 
        }
        component.set('v.isMass', true);
    },
    
    //mass Adjust 모달 닫기
    massModalCancel : function(component, message, helper) {
        component.set('v.isMass', false);
    },
    
    //Excel Upload Modal Close
    excelModalClose : function(component, message, helper) {
        component.set('v.excelUploadModal', false);
    },
    //uploadExcel
    uploadExcel: function (component, event, helper) { 
        component.set('v.isLoading', true);
        let uploadedFiles = event.getSource().get("v.files");
        let file = uploadedFiles[0];
        helper.handleHeaderUpload(component,file,event)
        .then($A.getCallback(function(result) {
            //searchPriceInfo
            component.set('v.excelUploadModal', false);
            //console.logJSON.stringify(component.get('v.uploadData')), '< == uploadData');
            let excelData = component.get('v.uploadData');
            let param =[];
            if(excelData.length >200) {
                component.set('v.isLoading', false);
                helper.toast('Error','업로드 가능한 최대 Row는 200개입니다. 업로드 문서를 수정해주세요');
                return ;    
            }

            excelData.forEach(element => {
                let part = element.Part;
                let plant = element.Plant;
                param.push({
                    material : part,
                    plant : plant,
                    dealerLeadTime : element['Dealer L/T'],
                    externalKey : plant +'-'+part
                });
            });
            //console.logJSON.stringify(param),' ::: param');
            helper.apexCall(component,event,this, 'uploadDataCheck', {
                uploadData : param
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                component.set('v.recordList',[]);
                //console.logJSON.stringify(result.r),' ::::result.r');
                
                // component.set('v.recordList2',JSON.parse(JSON.stringify(result.r)));
                r.forEach(element => {
                    if(element.isPartCheck) {
                        let ele = param.filter( (part)=> part.material == element.material);
                        //console.logJSON.stringify(ele), ' ::: ele');
                        if(ele.length > 0) {
                            element.dealerLeadTime = ele[0].dealerLeadTime;
                        }
                        element.isStatus = true;
                    }
                });
                component.set('v.recordList',r);
                //helper.getDataQuery(component);
            })).catch(function(error) {
                helper.toast('error', error[0].message);
                //console.log'# addError error : ' + error.message);
            }).finally(function () {
                // 모든 호출 완료 후 로딩 상태 해제
                component.set('v.isLoading', false);
            });
        })).catch(error => {
            if(Array.isArray(error)) {
                helper.toast('error', error[0]);
            } else {
                helper.toast('error', error);
            }
            component.set('v.isLoading', false);
        });
        
    },


    // PDT RATE 적용
    handlePDTRate : function(component, event, helper) {
        let pdtRate = component.get('v.pdtRate');
        let allData = component.get('v.recordList');
        let seletedList = component.get('v.selectList');
        allData.forEach(function (element, index) {
            seletedList.filter(item => {
                if(item.id === element.id) {
                    // pdtRate 백분율 필요
                    //console.logelement.plannedDeliveryDays, ' :: element.plannedDeliveryDays');
                    let plannedDeliveryDays = element.plannedDeliveryDays == undefined? 0 : element.plannedDeliveryDays;
                    element.dealerLeadTime = Math.round(( parseInt(plannedDeliveryDays) * parseInt(pdtRate)) / 100); //(element.plannedDeliveryDays *pdtRate) / 100 
                    element.isStatus = true;
                }
            });
        });
        component.set('v.pdtRate', 0);
        component.set('v.recordList',allData);
        component.set('v.isMass', false);  
    },

    // Dealer L/T 수기 입력
    handleValue: function (component, event, helper) {
        let value = event.getSource().get("v.value");
        let allData = component.get('v.recordList');
        let index = event.getSource().get("v.name");
        allData[index].isStatus = true;
        let regex = /^[0-9]*$/; 
        if (!regex.test(value)) {
            // 0.0 ~ 99.9 범위에서 올바른 값만 추출
            let matchedValue = value.match(/^[0-9]*/);
            if (matchedValue) {
                value = matchedValue[0]; // 첫 번째 매칭된 값 사용
            } else {
                value = 0; // 숫자가 없으면 빈 값으로 설정
            }
            event.getSource().set("v.value", value); // 수정된 값 반영
        }
        component.set('v.recordList',allData);
    },
    // 정규식 추가 PDT
    handlePDTValue: function (component, event, helper) {
        let value = event.getSource().get("v.value");
        let regex = /^[0-9]*$/; 
        if (!regex.test(value)) {
            let matchedValue = value.match(/^[0-9]*/);
            if (matchedValue) {
                value = matchedValue[0]; 
            } else {
                value = 0; // 숫자가 없으면 빈 값으로 설정
            }
            event.getSource().set("v.value", value); // 수정된 값 반영
        }
    },

    //전체 선택
    selectAll : function(component, event, helper) {
        let checked = event.getSource().get("v.checked");
        let allData = component.get('v.recordList');
        let checkbox = component.find('checkbox');
       
        checkbox.forEach(function (checkbox, index) {
            let row = allData[index];
            if(row.isPartCheck) {
                checkbox.set('v.checked', checked);
            }
           
        });
        if(checked) { 
            let seleted = allData.filter(item => item.isPartCheck == true);
            component.set('v.selectList',seleted);
        } else {
            component.set('v.selectList',[]);
        }
    },

    // 선택
    handleCheckboxChange : function(component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        let allData = component.get('v.recordList');
        let seletedList = component.get('v.selectList');
        if(check) {
            seletedList.push(allData[index]);
        } else {
            seletedList = seletedList.filter(item => item.id !== allData[index].id);
        }
        //console.logJSON.stringify(seletedList), ' selected List'); 
        component.set('v.selectList', seletedList);
    },
    // 저장기능
    handleSave : function(component, event, helper) {
        let selected = component.get('v.selectList');
        if(selected.length ==0) {
            helper.toast('error', '저장할 항목을 선택해주세요');
            return;
        }
        for(let i =0; i<selected.length; i++) {
            if(!selected[i].isStatus) {
                helper.toast('error', '수정하지 않은 데이터가 선택되었습니다.');
                return;
            }
            //console.logselected[i].dealerLeadTime, ' ::: selected[i].dealerLeadTime');
            //console.logparseInt(selected[i].dealerLeadTime), ' :: parseInt(selected[i].dealerLeadTime)');
            if(selected[i].dealerLeadTime =='') {
                helper.toast('error', 'Dealer L/T가 잘못입력되었습니다.');
                return;
            }
        }
        helper.openConfirm(`저장하시겠습니까?`, 'default', 'headerless')
            .then($A.getCallback(function(result) {
                if(result) {
                    component.set('v.isLoading', true);
                    helper.apexCall(component,event,this, 'leadTimeSave', {
                        saveData : selected
                    })
                    .then($A.getCallback(function(result) {
                        helper.toast('success', '저장되었습니다.');
                        component.set('v.selectList',[]);
                        component.find('headerCheckbox').set('v.checked',false);
                        helper.getDataQuery(component);
                    })).catch(function(error) {
                        helper.toast('error', error[0].message);
                        //console.log'# addError error : ' + error.message);
                    }).finally(function () {
                        // 모든 호출 완료 후 로딩 상태 해제
                        component.set('v.isLoading', false);
                    });
                }
            }))
            .catch(error => {
                console.error("Error during confirmation:", error);
            }); 
    }
})