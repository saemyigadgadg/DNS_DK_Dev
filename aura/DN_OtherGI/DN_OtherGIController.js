/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 12-19-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-07   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.filter', {
            'fieldApiName' : 'productCode',
            'parentFieldApiName' : '',
            'fieldType' : 'Lookup',
            'isRequired' : 'false'
        })
        var options = component.get('v.options');
        console.log('options', options);
        component.set('v.giList',[]);
        var giList = component.get("v.giList");
        var str = 10 + '';
        var objSelectItem = {
            "hang": str.padStart(6, '0'),
            "hangNumber": 10,
            "REASON": options[0].value,
            "MATNR": '',
            "MAKTX": '',
            "THREAD": '',
            "STQTY": 0,
            "REQTY": 0,
            "NETPR": 0,
            "STPR": '',
            "DESC": ''
        };
        giList.push(Object.assign({}, objSelectItem));
        component.set("v.giList", giList);
    },


    // 가격조회
    searchPriceInfo: function (component, event, helper) {
        component.set('v.isLoading', true);
        let giList = component.get('v.giList');
        let duplicates = giList.filter((item, index, self) => 
            self.findIndex(t => t.MATNR === item.MATNR) !== index
        );
        if(duplicates.length>0) {
            helper.toast('error', `Duplicate Part No! `);
            component.set('v.isLoading', false);
            return;
        }
        console.log(JSON.stringify(giList), ' < ==giList');
        //MATNR
        let partList = [];
        giList.forEach(element => {
            if(element.MATNR !=null){
                partList.push(element.MATNR);
            }
        });
        let noPartNumber = [];
        helper.apexCall(component,event,this, 'simulation', {
            partCode : partList
        })
        .then($A.getCallback(function(result) {
            let simMap = result.r;
            console.log(JSON.stringify(simMap),' < ===simMap');
            giList.forEach(element => {
                let simu = simMap[element.MATNR];
                if(simu != undefined) {
                    element.NETPR = simu.customerPrice;//고객 판매가
                    element.STQTY = simu.currentStockQuantity;//출고 가능재고
                    element.Part__c = simu.part;
                    element.Unit__c = simu.unit;
                    element.MAKTX = simu.partDetails;
                    element.THREAD = simu.partSpec;
                    element.STPR = simu.customerPrice;
                } else {
                    element.NETPR = 0;//고객 판매가
                    element.STQTY = 0;//출고 가능재고
                    element.Part__c = '';
                    element.Unit__c = '';
                    element.MAKTX = '';
                    element.THREAD = '';
                    element.STPR = 0;
                    noPartNumber.push(element.MATNR);
                }
                console.log(element.MATNR,' < ===element.MATNR');
            });
            component.set('v.giList',giList);
            console.log(JSON.stringify(giList), ' < ==grList');
            const ids = giList.map(item => item.Part__c).filter(Boolean);
            component.set('v.filterPartList',ids);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
        }).finally(function () {
            if(noPartNumber.length > 0) {
                
                helper.toast('error', `다음 품번들의 상세 정보가 없습니다. [${noPartNumber.join(',')}]`);
            }
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },

    // LMC
    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(JSON.stringify(params), ' <===params');
            // console.log(" setSubscriptionLMC");
            // console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'Save':
                    let selectedGI = component.get('v.selectedGI');
                    let noPartNumber = component.get('v.noPartNumber');
                    if(selectedGI.length > 170) {
                        helper.toast('error','출고처리할 항목은 최대 170개까지 가능합니다.');
                        return;
                    }
                    console.log(JSON.stringify(selectedGI), ' < ==selectedGI');
                    if(selectedGI.length ==0) {
                        helper.toast('error','출고처리할 항목을 선택해주세요.');
                        break;
                    }
                    if(selectedGI.some(item => !item.Part__c)) {
                        helper.toast('error','출고처리할 항목을 선택해주세요. 부품번호를 검색하여 입력해주세요.');
                        break;
                    }
                    for(let i=0; i<selectedGI.length; i++) {
                        let element = selectedGI[i];
                        
                        if(!parseInt(element.REQTY)) {
                            helper.toast('error','출고처리할 항목의 수량을 확인해주세요.');
                            return;
                        }
                        if(parseInt(element.REQTY) < 0) {
                            helper.toast('error','출고처리할 항목의 수량을 확인해주세요.');
                            return;
                        }
                        if(parseInt(element.STQTY) <=0) {
                            helper.toast('error','출고처리할 항목의 재고가 부족합니다.');
                            return;
                        }
                        
                    }

                    if(noPartNumber.length > 0) {
                        let checks =[];
                        for(let i=0; i<noPartNumber.length; i++) {
                            checks = selectedGI.filter(item => item.MATNR == noPartNumber[0]);
                        }
                        if(checks.length >0) {
                            helper.toast('error',`품번 정보를 조회 바랍니다.${noPartNumber}`);
                            break;  
                        }   
                    }
                    helper.insertGIList(component);
                    break;
                
                default:
                    break;
            }  
        }
    },

    // 추가버튼
    addPartsProduct: function (component, event, helper) {
        var options = component.get('v.options');
        console.log('options', options);
        var giList = component.get("v.giList");
        var num = (giList.length+1)*10;
        let formattedNumber = num.toString().padStart(6, '0');
        

        var objSelectItem = {
            "hangNumber": num + 10,
            "hang": `${formattedNumber}`,
            "REASON": options[0].value,
            "MATNR": '',
            "MAKTX": '',
            "THREAD": '',
            "STQTY": 0,
            "REQTY": 0,
            "NETPR": 0,
            "STPR": '',
            "DESC": ''
        }
        giList.push(Object.assign({}, objSelectItem));
        component.set("v.giList", giList);
    },

    // 전체 선택/해제
    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox");
        var isChecked = component.find("headerCheckbox").get("v.checked");
        var plist = [];
        let allData = component.get('v.giList');
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
                plist = allData;
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
        component.set('v.selectedGI', plist);
        let seleted = component.get('v.selectedGI');
        console.log('seletedList:', JSON.stringify(seleted));
    },

    // 개별 체크변경
    handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        console.log(index,' < ===index');
        let allData = component.get('v.giList');
        let seletedList = component.get('v.selectedGI');
        if(check) {
            seletedList.push(allData[index]);
        } else {
            seletedList = seletedList.filter(item => item !== allData[index]);
        }
        var isChecked = component.find("headerCheckbox").get("v.checked");
        if (isChecked) {
            component.find("headerCheckbox").set("v.checked", false);
        }

        component.set('v.selectedGI', seletedList);
    },

    // 체크된 Row 삭제
    selectedDeleteGI: function (component, event, helper) {
        var selectedGI = component.get('v.selectedGI');
        var giList = component.get("v.giList");
        var filteredList = giList.filter(gi => 
            !selectedGI.some(selected => selected.hang === gi.hang)
        );
        var num = 10;
        filteredList.forEach(element => {
            let formattedNumber = num.toString().padStart(6, '0');
            element.hang = `${formattedNumber}`;
            element.hangNumber = num;
            num = num+10;
        });
        
        var isChecked = component.find("headerCheckbox").get("v.checked");

        if (isChecked) {
            component.find("headerCheckbox").set("v.checked", false);
        }
        console.log(JSON.stringify(filteredList),' ::: filteredList');
        component.set('v.selectedGI', []);
        component.set('v.giList',[]);
        const ids = giList.map(item => item.Part__c).filter(Boolean);
        component.set('v.filterPartList',ids);
        new Promise((resolve) => {
            component.set('v.giList', filteredList);
            resolve();
        }).then(() => {
            helper.setInputValue(component, filteredList, 'productCode');
        });
    },

     // -버튼으로 제거
    deletePartsProduct: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        console.log(rowIndex,' ::: rowIndex');
        var giList = component.get("v.giList");
        giList.splice(rowIndex, 1);
        var index = 10;
        giList.forEach(element => {
            let formattedNumber = index.toString().padStart(6, '0');
            element.hang = `${formattedNumber}`;
            element.hangNumber = index;
            index = index+10;
        });
        console.log(JSON.stringify(giList),'giList::::');
        
        
        const ids = giList.map(item => item.Part__c).filter(Boolean);
        component.set('v.filterPartList',ids);
        new Promise((resolve) => {
            component.set('v.giList', []);
            component.set('v.giList', giList);
            resolve();
        }).then(() => {
            helper.setInputValue(component, giList, 'productCode');
        });
    },

    //부품번호 모달
    openSearchProductNumber: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedGIIndex', Number(rowIndex));
        $A.createComponent("c:DN_SearchProductNumber",
            {
                "type": "부품번호",
                'filterPartList' : component.get('v.filterPartList')
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("SearchProductNumber");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    //주문품번 지우기
    clearField: function (component, event, helper) {
        let index = event.getSource().get('v.accesskey'); 
        let giList = component.get('v.giList');
        if (!giList || !giList[index].MATNR) { 
            helper.toast('WARNING', `저장된 부품번호 값이 없습니다.`);
            return;
        }
        console.log(giList[index],' ::: giList[index]');
        giList[index].MATNR = ''; 
        giList[index].NETPR = 0;
        giList[index].STQTY = 0;
        giList[index].Part__c = '';
        giList[index].Unit__c = '';
        giList[index].MAKTX = '';
        giList[index].THREAD = '';
        giList[index].STPR = 0;
        component.set('v.giList', giList);
        console.log(JSON.stringify(giList),' ::giList');
        const ids = giList.map(item => item.Part__c).filter(Boolean);
        console.log(JSON.stringify(ids), ' :: ids');
        component.set('v.filterPartList',ids);
        // inputbox 컴포넌트 데이터 매핑
        let inputCmpAll  = component.find('productCode');
        if (Array.isArray(inputCmpAll)) {
            //this.istable
            console.log('여러 개의 요소가 있습니다:', inputCmpAll);
            inputCmpAll[index].handleClear();
        } else {
            console.log('단일 요소입니다:', inputCmpAll);
            inputCmpAll.handleClear();
        }
    },

    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam('modalName');
        var message   = event.getParam('message');
        var idx       = component.get('v.selectedGIIndex');
        var giList    = component.get('v.giList');
        console.log(idx,' ::: idx');
        
        // 부품 번호 검색
        if (modalName === 'DN_SearchProductNumber') {
            if (idx !== undefined && idx >= 0 && idx < giList.length) {
                var gi = giList[idx];
    
                gi.MATNR = message.ProductCode; // 부품 번호
                gi.MAKTX = message.Name;       // 품명
                gi.Part__c = message.Id;
                console.log(JSON.stringify(giList),' ::giList');
                
                const ids = giList.map(item => item.Part__c).filter(Boolean);
                component.set('v.filterPartList',ids);
                new Promise((resolve) => {
                    component.set('v.giList', giList);
                    resolve();
                }).then(() => {
                    helper.setInputValue(component, giList, 'productCode');
                });
            } else {
                console.log('idx 가 유효하지 않음 => ' + idx);
            }
        }
    },

    // 엑셀 업로드 모달 오픈
    openUploadModal: function (component, event, helper) {
        component.set('v.excelUploadModal', true);
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
        helper.handleHeaderUpload(component,file,event)
        .then($A.getCallback(function(result) {
            //searchPriceInfo
            
            component.set('v.excelUploadModal', false);
            console.log(JSON.stringify(component.get('v.uploadData')), '< == uploadData');
            let excelData = component.get('v.uploadData');
            if(excelData.length > 170) {
                helper.toast('error', '출고 시 부품 목록은 최대 170개까지만 가능합니다.');
                component.set('v.isLoading', false);
                return;
            }
            let giList = [];
            let index = 10;
            excelData.forEach(element => {
                let options = component.get('v.options');
                console.log(JSON.stringify(element), ' ::::element');
                let foundKey = Object.keys(element).find(key => key.includes('품번'));
                let foundKey2 = Object.keys(element).find(key => key.includes('출고량'));
                const reason = options.find(entry => entry.label === element['출고사유']);
                console.log(JSON.stringify(reason),' :::reason');
                var num = (giList.length+1)*10;
                let formattedNumber = num.toString().padStart(6, '0');
                giList.push({
                    "hang" : `${formattedNumber}`,
                    "REASON" : reason ==null ? options[0].value : reason.value,
                    "CUQTY" : "",
                    "MATNR" : element[foundKey],
                    'MAKTX' : "",
                    "THREAD" : "",
                    "STQTY" : "",
                    "REQTY" : element[foundKey2],
                    "NETPR" : "",
                    "STPR" : "",
                    "DESC" : element['기타']
                });
                
                index++;
            }); 
            console.log(JSON.stringify(giList), ' < ==giList');
            component.set('v.giList', giList);
            const ids = giList.map(item => item.Part__c).filter(Boolean);
            component.set('v.filterPartList',ids);
            new Promise((resolve) => {
                component.set('v.giList', giList);
                resolve();
            }).then(() => {
                helper.setInputValue(component, giList, 'productCode');
            });
            let action = component.get('c.searchPriceInfo');
            $A.enqueueAction(action);
        }))
        .catch(error => {
            if(Array.isArray(error)) {
                helper.toast('error', error[0]);
            } else {
                helper.toast('error', error);
            }
            component.set('v.isLoading', false);
            console.error("Error during file upload:", error);
        });
        
    },
    // 
    handleInputChange: function (component, event, helper) {
        if(event.getParam('eventType') =='ENTER') {
            new Promise((resolve) => {
                let value = event.getParam('value'); 
                let matnr = event.getParam('label'); 
                let index = event.getParam('index');  
                let giList = component.get('v.giList');
                giList[index].MATNR =matnr;
                giList[index].Part__c = value;
                component.set('v.giList',giList);
                const ids = giList.map(item => item.Part__c).filter(Boolean);
                component.set('v.filterPartList',ids);
                resolve();
            }).then($A.getCallback(function(result) {
                let action = component.get('c.searchPriceInfo');
                $A.enqueueAction(action);
            }))
        } else {
            let value = event.getParam('value'); 
            let matnr = event.getParam('label'); 
            let index = event.getParam('index');  
            let giList = component.get('v.giList');
            giList[index].MATNR =matnr;
            giList[index].Part__c = value;
        
            component.set('v.giList',giList);
            const ids = giList.map(item => item.Part__c).filter(Boolean);
            component.set('v.filterPartList',ids);
        }
    },
    handeQTYChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        console.log(value,' ::: value');
        let index = event.getSource().get("v.accesskey");
        let giList = component.get('v.giList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        console.log(giList[index].REQTY,' :: giList[index].REQTY');
        giList[index].REQTY = value;
        setTimeout($A.getCallback(() => {
            component.set('v.giList',giList);
        }));
        
    },
    handlePriceChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let giList = component.get('v.giList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        giList[index].STPR = value;
        component.set('v.giList',giList);
    },


})