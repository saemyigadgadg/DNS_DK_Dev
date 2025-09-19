/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-18-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    handleChageTest: function (component, event, helper) {
        console.log('test!!!!!');
    },
    doInit: function (component, event, helper) {
        component.set('v.filter', {
            'fieldApiName' : 'productCode',
            'parentFieldApiName' : '',
            'fieldType' : 'Lookup',
            'isRequired' : 'false'
        })

        var pathname = window.location.pathname; // 경로만 가져오기
        if(pathname.includes('other-goods-receipt')) {
            component.set('v.defaultValue', '3');
        } else {
            component.set('v.defaultValue', '1');
        }
        let defaultValue = component.get('v.defaultValue');

        var options = component.get('v.options');
        console.log('options', options);
        var grList = component.get("v.grList");
        var str = 10 + '';
        var objSelectItem = {
            "hang": str.padStart(6, '0'),
            "hangNumber": 10,
            "REASON": defaultValue,
            "CUQTY": '',
            "DISPR": '',
            "LOC": '',
            "MAKTX": '',
            "MATNR": '',
            "MEINS": '',
            "NETPR": '',
            "REQTY": '',
            "STQTY": '',
            "THREAD": '',
            "GRQTY": '',
            "WAERS": '',
            "STPR": '',
            "TOTAL": '',
            "DESC": ''
        };
        grList.push(Object.assign({}, objSelectItem));
        component.set("v.grList", grList);
    },

    // 추가버튼
    addPartsProduct: function (component, event, helper) {
        var options = component.get('v.options');
        console.log('options', options);
        var grList = component.get("v.grList");
        var num = (grList.length+1)*10;
        
        let formattedNumber = num.toString().padStart(6, '0');
        let defaultValue = component.get('v.defaultValue');

        var objSelectItem = {
            "hang": `${formattedNumber}`,
            "hangNumber": num + 10,
            "REASON": defaultValue,
            "CUQTY": '',
            "DISPR": '',
            "LOC": '',
            "MAKTX": '',
            "MATNR": '',
            "MEINS": '',
            "NETPR": '',
            "REQTY": '',
            "STQTY": '',
            "THREAD": '',
            "GRQTY": '',
            "WAERS": '',
            "STPR": '',
            "TOTAL": '',
            "DESC": ''
        }
        grList.push(Object.assign({}, objSelectItem));
        component.set("v.grList", grList);
    },

    // 전체 선택/해제
    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox");
        var isChecked = component.find("headerCheckbox").get("v.checked");
        var plist = [];
        let allData = component.get("v.grList");
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
        component.set('v.selectedGR', plist);
        let seleted = component.get('v.selectedGR');
        console.log('seletedList:', JSON.stringify(seleted));
    },

    // 개별 체크변경
    handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        let allData = component.get('v.grList');
        let selectedGR = component.get('v.selectedGR');
       
        if(check) {
            selectedGR.push(allData[index]);
        } else {
            selectedGR = selectedGR.filter(item => item !== allData[index]);
        }

        var isChecked = component.find("headerCheckbox").get("v.checked");

        if (isChecked == true) {
            component.find("headerCheckbox").set("v.checked", false);
        }
        console.log(JSON.stringify(selectedGR),' < ==selectedGR');
        component.set('v.selectedGR', selectedGR);
    },

    // 체크된 Row 삭제
    selectedDeleteGR: function (component, event, helper) {
        var selectedGR = component.get('v.selectedGR');
        var grList = component.get("v.grList");
        var filteredList = grList.filter(gr => 
            !selectedGR.some(selected => selected.hang === gr.hang)
        );
        var num = 10;
        filteredList.forEach((element, index) => {
            let formattedNumber = num.toString().padStart(6, '0');
            element.hang = `${formattedNumber}`;
            num = num+10;    
        });
        // selectedGR.sort(function (a, b) { return b - a; });

        // for (var i = 0; i < selectedGR.length; i++) {
        //     grList.splice(selectedGR[i], 1);
        // }

        var isChecked = component.find("headerCheckbox").get("v.checked");

        if (isChecked == true) {
            component.find("headerCheckbox").set("v.checked", false);
        }
        component.set('v.selectedGR', []);
        component.set('v.grList', []);
        new Promise((resolve) => {
            component.set('v.grList', filteredList);
            resolve();
        }).then(() => {
            helper.setInputValue(component, filteredList, 'productCode');
        });
        
        const ids = grList.map(item => item.Part__c).filter(Boolean);
        component.set('v.filterPartList',ids);
    },

     // -버튼으로 제거
    deletePartsProduct: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        var grList = component.get("v.grList");
        grList.splice(rowIndex, 1);
        var index = 10;
        grList.forEach((element,idx) => {
            let formattedNumber = index.toString().padStart(6, '0');
            element.hang = `${formattedNumber}`;
            index = index+10;
            
        });
        console.log(JSON.stringify(grList),' :: grList');
        new Promise((resolve) => {
            component.set('v.grList', []);
            component.set('v.grList', grList);
            resolve();
        }).then(() => {
            helper.setInputValue(component, grList, 'productCode');
        });
        
        
        const ids = grList.map(item => item.Part__c).filter(Boolean);
        component.set('v.filterPartList',ids);
        
    },

    // 부품번호 모달
    openSearchProductNumber: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedGRIndex', Number(rowIndex));
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
        let grList = component.get('v.grList');
        console.log(JSON.stringify(grList),' ::grList');
        if (!grList || !grList[index].MATNR) { 
            helper.toast('WARNING', `저장된 부품번호 값이 없습니다.`);
            return;
        }
    
        grList[index].MATNR = ''; 
        grList[index].MAKTX = ''; 
        grList[index].THREAD = ''; 
        grList[index].CUQTY = ''; 
        grList[index].GRQTY = ''; 
        grList[index].NETPR = ''; 
        grList[index].STPR = ''; 
        grList[index].DESC = '';
        grList[index].Part__c ='';
        component.set('v.grList', grList);
        const ids = grList.map(item => item.Part__c).filter(Boolean);
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

    // 가격조회
    searchPriceInfo: function (component, event, helper) {
        component.set('v.isLoading', true);
        let grList = component.get('v.grList');
        let duplicates = grList.filter((item, index, self) => 
            self.findIndex(t => t.MATNR === item.MATNR) !== index
        );
        if(duplicates.length>0) {
            helper.toast('error', `Duplicate Part No! `);
            component.set('v.isLoading', false);
            return;
        }
        //MATNR
        let partList = [];
        for(let i=0; i<grList.length; i++) {
            let element = grList[i];
            
            if(element.MATNR =='') {
                helper.toast('error', ` 부품번호가 입력되지 않는 항목이 있습니다. 부품번호 기입 후 가격조회 해주세요`);
                component.set('v.isLoading', false);
                return;
            } else {
                partList.push(element.MATNR);
            }
        }
        console.log(JSON.stringify(partList),' ::: partList');
        console.log(JSON.stringify(grList),' ::: grListsss');
        let noPartNumber = [];
        helper.apexCall(component,event,this, 'simulation', {
            partCodeList : partList
        })
        .then($A.getCallback(function(result) {
            let simMap = result.r;
            console.log(JSON.stringify(simMap),' :: simList'); //NETPR
            grList.forEach(element => {
                let simu = simMap[element.MATNR];
                if(simu != undefined) {
                    element.CUQTY = simu.currentStockQuantity;
                    element.NETPR = simu.customerPrice;
                    element.UNIT = simu.unit;
                    element.Part__c =simu.part;
                    element.MAKTX = simu.partDetails;
                    element.STPR = simu.customerPrice;
                    element.THREAD = simu.partSpec;
                    element.isSearch = true;
                } else {
                    element.CUQTY = 0;
                    element.NETPR = 0;
                    element.UNIT = '';
                    element.Part__c = '';
                    element.MAKTX = '';
                    element.STPR = 0;
                    element.THREAD = 0;
                    element.isSearch = false;
                    noPartNumber.push(element.MATNR);
                }
                
            });
            component.set('v.grList',grList);
            const ids = grList.map(item => item.Part__c).filter(Boolean);
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
                    let selectedGR = component.get('v.selectedGR');
                    let noPartNumber = component.get('v.noPartNumber');
                    if(selectedGR.length ==0) {
                        helper.toast('error','입고처리할 항목을 선택해주세요.');
                        break;
                    } else {
                        if(selectedGR.length > 170) {
                            helper.toast('error','입고처리할 항목은 최대 170개까지 가능합니다. 입고처리할 항목을 확인해주세요.');
                            break;
                        }
                        // 부품번호 확인
                        if(selectedGR.some(item => !item.Part__c)) {
                            helper.toast('error','입고처리할 항목을 선택해주세요. 부품번호를 검색하여 입력해주세요.');
                            break;
                        }
                        for(let i=0; i<selectedGR.length; i++) {
                            let currentPart = selectedGR[i];
                            if(!currentPart.isSearch) {
                                helper.toast('error',`품번 정보를 조회 바랍니다. ${currentPart.MATNR}`);
                                return;   
                            }
                            if(currentPart.GRQTY <=0) {
                                helper.toast('error',`${currentPart.MATNR} 입고량을 확인해주세요.`);
                                return;   
                            }
                               
                        }
                    }
                    // if(noPartNumber.length > 0) {
                    //     let checks =[];
                    //     for(let i=0; i<noPartNumber.length; i++) {
                    //         checks = selectedGR.filter(item => item.MATNR == noPartNumber[0]);
                    //     }
                    //     if(checks.length >0) {
                    //         helper.toast('error',`품번 정보를 조회 바랍니다.${noPartNumber}`);
                    //         break;  
                    //     }   
                    // }
                    helper.insertGRList(component);
                    break;
                
                default:
                    break;
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
                helper.toast('error', '입고 시 부품 목록은 최대 170개까지만 가능합니다.');
                component.set('v.isLoading', false);
                return;
            }
            let grList = [];
            let index = 10;
            excelData.forEach(element => {
                let options = component.get('v.options');
                let foundKey = Object.keys(element).find(key => key.includes('품번'));
                let foundKey2 = Object.keys(element).find(key => key.includes('입고량'));
                const reason = options.find(entry => entry.label === element['입고사유']);
                console.log(JSON.stringify(reason),' :::reason');
                grList.push({
                    "hang" : `0000${index}`,
                    "REASON" : reason ==null ? options[0].value : reason.value,
                    "CUQTY" : "",
                    "MATNR" : element[foundKey],
                    'MAKTX' : "",
                    "THREAD" : "",
                    "CUQTY" : "",
                    "GRQTY" : element[foundKey2],
                    "NETPR" : "",
                    "STPR" : "",
                    "DESC" : element['기타']
                });
                index++;
            }); 

            component.set('v.grList', grList);
            const ids = grList.map(item => item.Part__c).filter(Boolean);
            component.set('v.filterPartList',ids);
            new Promise((resolve) => {
                component.set('v.grList', grList);
                resolve();
            }).then(() => {
                helper.setInputValue(component, grList, 'productCode');
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
    // 모달에서 받은 정보
    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam('modalName');
        var message   = event.getParam('message');
        var idx       = component.get('v.selectedGRIndex');
        var grList    = component.get('v.grList');
    
        console.log('idx', idx);
        console.log('modalName', JSON.stringify(modalName, null, 4));
        console.log('message', JSON.stringify(message, null, 4));
        console.log("grList", JSON.stringify(grList));


        // 부품 번호 검색
        if (modalName === 'DN_SearchProductNumber') {
            if (idx !== undefined && idx >= 0 && idx < grList.length) {
                console.log(`부품 ${idx + 1} row`);
                var gr = grList[idx];
    
                gr.MATNR = message.ProductCode; // 부품 번호
                gr.MAKTX = message.Name;       // 품명
                gr.Part__c = message.Id;
                component.set('v.grList', grList);
                const ids = grList.map(item => item.Part__c).filter(Boolean);
                component.set('v.filterPartList',ids);
                new Promise((resolve) => {
                    component.set('v.grList', grList);
                    resolve();
                }).then(() => {
                    helper.setInputValue(component, grList, 'productCode');
                });
            } else {
                console.log('idx 가 유효하지 않음 => ' + idx);
            }
        }
    },

    handleInputChange: function (component, event, helper) {
        if(event.getParam('eventType') =='ENTER') {
            new Promise((resolve) => {
                let value = event.getParam('value'); 
                let matnr = event.getParam('label'); 
                let index = event.getParam('index');  
                let grList = component.get('v.grList');
                grList[index].MATNR =matnr;
                grList[index].Part__c = value;
                console.log(JSON.stringify(grList),'  handleInputChange grList');
                component.set('v.grList',grList); 
                const ids = grList.map(item => item.Part__c).filter(Boolean);
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
            let grList = component.get('v.grList');
            grList[index].MATNR =matnr;
            grList[index].Part__c = value;
        
            component.set('v.grList',grList);
            const ids = grList.map(item => item.Part__c).filter(Boolean);
            component.set('v.filterPartList',ids);
        }
    },
    handleQTYChange: function (component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let grList = component.get('v.grList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        grList[index].GRQTY = value;
        component.set('v.grList',grList);
    },
    handleSTPRChange: function (component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let grList = component.get('v.grList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        grList[index].STPR = value;
        component.set('v.grList',grList);
    }


})