/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-07-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-13-2024   youjin.shim@sbtglobal.com   Initial Version
 * 1.1   12-24-2024   Hyunwook Jin                저장 기능 추가
**/
({
    doInit: function (component, event, helper) {
        component.set('v.filter', {
            'fieldApiName' : 'productCode',
            'parentFieldApiName' : '',
            'fieldType' : 'Lookup',
            'isRequired' : 'false'
        })
        const processNumber = num => Math.floor(num * 0.1) * 10;
        var partsList = [];
        var num = 0; 
        var num2 = processNumber(num);

        for (var i = 1; i <= 10; i++) {
            var objSelectItem = {
                hangNumber: num2 + i * 10,
                itemSeq: String(num2 + i * 10).padStart(6, '0'),
                partName: '',
                replacingPartName: '',
                replaceSize:1,
                check: '',
                unit: '',
                partDetails: '',
                quantity: '',
                customerPrice: '',
                discountRate: '',
                discountPrice: '',
                discountAmount: '',
                isSelected:false,
                isRendered:true
            };
            partsList.push(objSelectItem);
        }

        component.set("v.partsList", partsList);
    },
    
    // 전체 row 선택
    selectAll: function (component, event, helper) {
        let checkboxes = component.find("checkbox");
        let isChecked = component.find("headerCheckbox").get("v.checked");

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked == true) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
        } else {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
        }
    },

    //parts List 추가
    addParts: function (component, event, helper) {
        let partsList = component.get("v.partsList");
        let num = 0;
        if (partsList.length > 0) {
            let lastSeq  = partsList[partsList.length - 1].itemSeq; 
            lastSeq = lastSeq.slice(0, -1) + '0';
            num = Number(lastSeq/10);
        }

        let newPartList = helper.gfnDefaultPartList(component, 10, num);
        partsList = partsList.concat(newPartList);
    
        component.set("v.partsList", partsList);
    },

    // Part 추가
    addPart: function (component, event, helper) {
        let partsList = component.get("v.partsList");
        console.log("partsList", partsList);
        let num = 0;
        if (partsList.length > 0) {
            let lastSeq  = partsList[partsList.length - 1].itemSeq; 
            lastSeq = lastSeq.slice(0, -1) + '0';
            num = Number(lastSeq/10);
        }

        let newPartList = helper.gfnDefaultPartList(component, 1, num);
        partsList = partsList.concat(newPartList);
        component.set("v.partsList", partsList);
    },

    // parts List 삭제
    deleteParts: function (component, event, helper) {
        let partsList = component.get("v.partsList");
        //partsList.filter((_, index) => checkboxes[index].get("v.checked"));
        for(let index = partsList.length-1; index >=0; index--) {
            let removePart = partsList[index];
            if(removePart.isSelected) {
                if('0' === removePart.itemSeq.slice(-1)) {
                    let replacingPart = partsList[index +1];
                    //다음 품목이 대체품인지 확인 후 제거
                    if(replacingPart && Number(replacingPart.itemSeq) - 1 ==  Number(removePart.itemSeq)) {
                        replacingPart.itemSeq = removePart.itemSeq;
                        replacingPart.replaceSize = 1;
                    }
                }else {
                    let supplyPart = partsList[index - 1];
                    supplyPart.replaceSize = 1;
                    supplyPart.disabled = false;
                }
                partsList.splice(index, 1);
            }
        }
        new Promise((resolve) => {
            component.set("v.partsList", []);
            component.set('v.partsList', partsList);
            resolve();
        }).then($A.getCallback(function(result) {
            let partsListSet = partsList.filter(part => part.partName).map(part => ({ 
                MATNR: part.partName 
            }));
            helper.setInputValue(component, partsListSet, 'productCode');

        }));
        let headerCheckbox = component.find("headerCheckbox");
        if (headerCheckbox) {
            headerCheckbox.set("v.checked", false);
        }
        helper.gfnQuotePriceCalculation(component,event);

        
    },

    // -버튼으로 제거
    deletePartsProduct: function (component, event, helper) {
        let rowIndex = event.getSource().get('v.accesskey');
        let partsList = component.get("v.partsList");
        
        let removePart = partsList[rowIndex];
        
        if('0' === removePart.itemSeq.slice(-1)) {
            let replacingPart = partsList[rowIndex +1];
            if(replacingPart && Number(replacingPart.itemSeq) - 1 ==  Number(removePart.itemSeq)) {
                replacingPart.itemSeq = removePart.itemSeq;
                replacingPart.replaceSize = 1;
            }
        }else {
            let supplyPart = partsList[rowIndex - 1];
            supplyPart.replaceSize = 1;
            supplyPart.disabled = false;
        }
        partsList.splice(rowIndex, 1);
        new Promise((resolve) => {
            component.set("v.partsList", []);
            component.set("v.partsList", partsList);
            resolve();
        }).then(() => {
            let partsListSet = partsList.filter(part => part.partName).map(part => ({ 
                MATNR: part.partName 
            }));
            helper.setInputValue(component, partsListSet, 'productCode');
        });
        helper.gfnQuotePriceCalculation(component,event);
    },

    //parts List 할인 모달 열기
    discountParts : function (component, event, helper) {
        const partsList = component.get("v.partsList");
        const hasCheckedItems = partsList.some(parts => parts.isSelected);
        if (hasCheckedItems) {
            component.set("v.isDiscountModal", true);
        } else {
            helper.toast('WARNING', '하나 이상의 부품을 선택해주세요.');
        }
    },

    //모달에서 할인 적용
    discountConfirm : function (component, event, helper) {
        const partsList = component.get("v.partsList");
        const discountRate = component.get("v.discountRate");
        

        if (discountRate === null || discountRate === undefined || discountRate === "") {
            helper.toast('WARNING', '할인율을 입력해주세요.');
            return;
        }

        const updatedPartsList = partsList.map(parts => {
            if (parts.isSelected) {
                parts.discountRate = discountRate; // 할인율 업데이트
            }
            return parts;
        });

        component.set("v.partsList", updatedPartsList);
        helper.gfnQuotePriceCalculation(component,event);
        component.set("v.isDiscountModal", false);
        helper.toast('SUCCESS', '할인율이 적용되었습니다.');

    },
    // 모달창 할인율 change event
    handlediscountRate : function (component, event, helper) {
        let value = event.getSource().get("v.value");
        let valueSet = 0;
        console.log(value);
        if(!value || Number(value) < 0) {
            component.set('v.isRenderDiscountRate', false);
            valueSet = 0;
            setTimeout(()=>{
                component.set("v.discountRate",valueSet);
                component.set('v.isRenderDiscountRate', true);
            }, 0);
        } else {
            valueSet = value;
            component.set("v.discountRate",valueSet);
        }

        ///[^0-9]/.test(value)
        // if(/[^0-9]/.test(value)) {
        //     valueSet = 0;
        // } else {
        //     valueSet = Number(value);
        // }
        
    },

    //모달 닫기
    closeModal : function (component, event, helper) {
        component.set("v.isDiscountModal", false);
    },

    //할인율 적용
    ChangeDiscount : function (component, event, helper) {
        let partsList = component.get("v.partsList").map(part=>part);
        let index = event.getSource().get("v.accesskey");
        let value = event.getSource().get("v.value"); 
       
        if(!value || Number(value) < 0) {
            partsList[index].discountRate = 0;
            partsList[index].isRendered = false;
            component.set('v.partsList', partsList);
        } else {
            partsList[index].discountRate = value;
        }
        
        ///[^0-9]/.test(value)
        // if(/[^0-9]/.test(value)) {
        //     partsList[index].discountRate = 0;
        // } else {
        //     partsList[index].discountRate = Number(value);
        // }
        setTimeout($A.getCallback(() => {
            partsList[index].isRendered = true;
            component.set('v.partsList', partsList);
            helper.gfnQuotePriceCalculation(component,event);
        }));
    },

    //수량 적용
    ChangeQuantity: function (component, event, helper) {
        let partsList = component.get("v.partsList");
        let index = event.getSource().get("v.accesskey");
        let value = event.getSource().get("v.value");
       
        ///[^0-9]/.test(value)
        if(/[^0-9]/.test(value)) {
            partsList[index].quantity = 0;
        } else {
            partsList[index].quantity = Number(value);
        }
        
        component.set('v.partsList', partsList);
        helper.gfnQuotePriceCalculation(component,event);
        
        
    },

    //Simulation 부품의 품명, 판매가, 대체품 등 디테일한 정보 가져오기
    simulation : function(component, event, helper) {
        helper.gfnShowLoading(component);
        helper.gfnSimulation(component,event);
    },

    // 주문품번 td에서 부품번호 Modal 띄우기
    openSearchProductNumber: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedPartsIndex', Number(rowIndex));
        component.set("v.costInfoModal", false);

        let filterPartList = component.get('v.partsList').filter(part=> part.part && part.partName).map(part=>part.part);
        console.log(JSON.stringify(filterPartList));

        $A.createComponent("c:DN_SearchProductNumber",
            {
                "type": "부품번호"
                ,"filterPartList":filterPartList
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

    clearOrderNumber: function (component, event, helper) {
        let index = event.getSource().get('v.accesskey'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index].partName) { 
            helper.toast('WARNING', '저장된 주문품번이 없습니다.');
            return;
        }
    
        partsList[index].part = '';
        partsList[index].partName = ''; 
        partsList[index].partDetails = '';
        partsList[index].replacingPart = '';
        partsList[index].replacingPartName = ''; 
        partsList[index].quantity = ''; 
        partsList[index].avaiableQuantity = ''; 
        partsList[index].salesUnit = ''; 
        partsList[index].unit = ''; 
        partsList[index].customerPrice = ''; 
        partsList[index].discountPrice = ''; 
        partsList[index].discountAmount = ''; 
        partsList = helper.gfnCalcuateDiscountRate(partsList);
        partsList = helper.gfnCalcuateDiscountAmount(partsList);
        helper.gfnTotalQuotePriceCalculation(component, partsList);
        component.set('v.partsList', partsList);
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

    //주문품번 지우기
    clearField: function (component, event, helper) {
        let index = event.getSource().get("v.accesskey");
        let fieldName = event.getSource().get("v.name");
        let partsList = component.get("v.partsList");

        // 인덱스가 유효한지 확인
        if (index >= 0 && index < partsList.length) {
            if (partsList[index] && partsList[index][fieldName]) {
                partsList[index][fieldName] = ""; 
                partsList[index].partName = ''; 
                component.set("v.partsList", partsList); 
            } else {
                helper.toast("WARNING", `저장된 ${fieldName} 값이 없습니다.`);
            }
        } else {
            console.error('유효하지 않은 인덱스:', index);
        }
        
    },

    // 이벤트 값 가져와서 해당 속성에 분배(Parts List)
    handleCompEvent: function(component, event, helper) {
        var modalName = event.getParam("modalName");
        var message   = event.getParam("message");
        var idx       = component.get("v.selectedPartsIndex");
        var partsList = component.get("v.partsList");

        // 부품
        if(modalName === 'DN_SearchProductNumber') {
            if(idx !== undefined && idx >= 0 && idx < partsList.length) {
                console.log(`부품 ${idx+1} row`);
                var part = partsList[idx];

                part.part      = message.Id;             // Id
                //part.partDetails    = message.Name;           // 품명
                part.partName = message.ProductCode;    // 품번
                part.model       = message.Model__c;       // 모델
                new Promise((resolve) => {
                    component.set('v.partsList', partsList);
                    resolve();
                }).then(() => {
                    //MATNR
                    let partsListSet = partsList.filter(part => part.partName).map(part => ({ 
                        MATNR: part.partName 
                    }));
                    
                    helper.setInputValue(component, partsListSet, 'productCode');
                });
            } else {
                console.log('idx 가 유효하지 않음1 => ' +idx);
            }
            
        }
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log("DN_DealerPortalQuoteCreate setSubscriptionLMC");
            console.log(JSON.stringify(message));
            switch (params.cmpName) {
                case 'DN_DealerPortalDisplay': 
                    if(params.type ==='filterModal') {
                        //고객사 선택시 DN_DealerPortalDisplay 이벤트 수신 (label, value 값 가져오기위해)
                        if(params.message.field === 'CustomerName__c') {
                            component.set('v.discountRate', params.message.discountRate || 0);
                            helper.gfnSetDiscountRate(component, params.message.discountRate);
                            
                        }else if(params.message.field === 'Type') {
                            // helper.setInputValue(component, [
                            //     {MATNR: params.message.value}
                            // ], 'SerialNumber'); 
                            
                        }
                    }
                    break;
                case 'dN_DealerPortalFilter':
                    if(params.type ==='filterChange' || params.type === 'defaultFilter') {
                        let headerParams = component.get('v.headerParams');
                        console.log(JSON.stringify(params),' ::: params');
                        console.log(JSON.stringify(headerParams),' headerParams');
                        if(!!!headerParams) headerParams = {};
    
                        console.log('type : filterChange');
                        let isArray = Array.isArray(params.message);
                        
                        if(isArray) {
                            [...params.message].forEach((headerParam)=>{
                                headerParams[headerParam.field] = headerParam.value;
                            });
    
                        }else {
                            headerParams[params.message.field] = params.message.value;
                        }
                        component.set('v.headerParams', headerParams);
                    }
                case 'dN_DealerPortalButton':
                    if(params.type === 'Save') {
                        component.set('v.isSpinner', true);
                        console.log('type : Save ');
                        let quoteItemList = component.get('v.partsList').filter((part)=> part.partName && !part.disabled);
                        console.log(quoteItemList,' ::: quoteItemList');
                        if(quoteItemList.length > 170) {
                            component.set('v.isSpinner', false);
                            helper.toast('Error','주문품번은 최대 170개까지만 저장 가능합니다. 주문품번을 수정해주세요');
                            return;
                        }
                        helper.gfnSave(component, null);
                    }
                    break;
                    
            }
                // switch (params.type) {
                //     case 'filterChange':
                       
                //         break;
                //     case 'Save':
                //         component.set('v.isSpinner', true);
                //         console.log('type : Save ');
                //         helper.gfnSave(component, null);
                //         break;
                //     default:
                //         break;
                // }
            
            

            // // 뒤로가기
            // if(params.type == 'Back') {
            //     window.history.back();
            // }
            // // 커스텀으로 생성한 페이지 이동
            // if (params.type == 'CustomPage') { //modalName -> 페이지 이동인 경우 페이지명 넣기
            //     let hostname = window.location.hostname;
            //     let pathName = window.location.pathname;
            //     let navService = component.find('navService');
            //     pathName = pathName.substring(0, pathName.lastIndexOf('/') + 1);
            //     console.log(window.location,' < ==window.location');
            //     console.log(hostname,' < ==hostname');
                
            //     let pageReference = {
            //         type: "standard__webPage",
            //         attributes: {
            //             url: hostname + pathName +params.message.modalName ,
            //         }
            //     };
            //     navService.navigate(pageReference)
            // }
            
        }
    },

    //주문품번과 연관 대체품 변경
    swapTargetPart : function(component, event, helper) {
        let index = event.getSource().get("v.accesskey");
        let check = event.getSource().get("v.checked");

        let partList = component.get('v.partsList');
        let part = partList[index];
        part.disabled = !check;
        let replacePart = partList.find((parts)=> (Number(part.itemSeq) + 1) == Number(parts.itemSeq));
        replacePart.disabled = check;

        component.set('v.partsList', partList);
        helper.gfnQuotePriceCalculation(component,event);
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
        console.log(component.getName(),'.handleHeaderUpload : ');
        let uploadedFiles = event.getSource().get("v.files");
        let file = uploadedFiles[0];
        helper.handleHeaderUpload(component,file,event)
        .then($A.getCallback(function(result) {
            // component.set('v.excelUploadModal', false);
            let excelData = component.get('v.uploadData');
            if(excelData.length >170) {
                component.set('v.isLoading', false);
                helper.toast('Error','업로드 가능한 최대 Row는 170개입니다. 업로드 문서를 수정해주세요');
                return ;    
            }
            // console.log(JSON.stringify(excelData), '< == uploadData');
            let excelUploadTemplate = component.get('v.excelUploadTemplate');
            // console.log(JSON.stringify(excelUploadTemplate), '< == excelUploadTemplate');
            let isInvalidFormat = false;
            let partList = helper.gfnDefaultPartList(component, excelData.length);
            
            let removeDuplicate = {};
            for(let startIdx=0; startIdx < excelData.length; startIdx++) {
                let part = {};
                
                let importData = excelData[startIdx];
                excelUploadTemplate.columnList.forEach(column=>{
                    if(column.isRequired && importData[column.columnLabel]) {
                        part[column.columnApi] = importData[column.columnLabel];
                    }else if(!column.isRequired) {
                        part[column.columnApi] = importData[column.columnLabel];
                    }else {
                        isInvalidFormat = true;
                    }
                });

                if(isInvalidFormat) break;

                removeDuplicate[part.partName] = part;
            }

            Object.values(removeDuplicate).forEach((nonPart, idx)=>{
                let part = partList[idx];

                for (const [key, value] of Object.entries(nonPart)) {
                    part[key] = value;
                }
            });
                

            if(isInvalidFormat) {
                component.set('v.isLoading', false);
                helper.toast('Error','업로드 양식과 일치하지 않은 데이터가 존재합니다. 수정 후 다시 업로드 부탁드립니다.');
                return ;    
            }
            
            
            component.set('v.excelUploadModal', false);
            component.set('v.isLoading', false);
            new Promise((resolve) => {
                component.set('v.partsList', partList);
                resolve();
            }).then(() => {
                //MATNR
                let partsListSet = partList.filter(part => part.partName).map(part => ({ 
                    MATNR: part.partName 
                }));
                helper.setInputValue(component, partsListSet, 'productCode');
            });

        }))
        .catch(error => {
            
            if(Array.isArray(error)) {
                helper.toast('error', error[0]);
            } else {
                helper.toast('error', error);
            }
            component.set('v.isLoading', false);
        });
        
    },

    handleInputChange: function (component, event, helper) {
        if(event.getParam('eventType') =='ENTER') {
            new Promise((resolve) => {
                let value = event.getParam('value'); 
                let matnr = event.getParam('label'); 
                let index = event.getParam('index');  //part : id, partName : ProductCode

                let partsList = component.get('v.partsList');
                partsList[index].partName =matnr;
                partsList[index].part = value;
                partsList[index].isSimulation = false;
                component.set('v.partsList',partsList); 
                // const ids = grList.map(item => item.Part__c).filter(Boolean);
                // component.set('v.filterPartList',ids);
                resolve();
            }).then($A.getCallback(function(result) {
                // let action = component.get('c.searchPriceInfo');
                // $A.enqueueAction(action);
            }))
        } else {
            let value = event.getParam('value'); 
            let matnr = event.getParam('label'); 
            let index = event.getParam('index');  
            let partsList = component.get('v.partsList');
            partsList[index].partName = matnr;
            partsList[index].part = value;
            partsList[index].isSimulation = false;
            component.set('v.partsList',partsList);
        }
    },

    handleKeyPress: function(component, event, helper) {
        console.log('div Binding handleKeyPress');
        helper.gfnHandleKeyPress(component, event);
    }
})