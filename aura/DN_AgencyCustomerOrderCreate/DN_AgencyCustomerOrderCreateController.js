/**
 * @author            : Jun-Yeong Choi
 * @Description       :
 * @last modified on  : 01-17-2025
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
 
 
 * Memo               : discountRate, 주문수량
**/
({
    doInit: function (component, event, helper) {
        // window.addEventListener('popstate', $A.getCallback(function(event) {
        //     window.sessionStorage.setItem('isBack','true');
        //     // 추가 동작 가능
        // }));

        component.set('v.filter', {
            'fieldApiName' : 'productCode',
            'parentFieldApiName' : '',
            'fieldType' : 'Lookup',
            'isRequired' : 'false'
        })
        helper.gfnShowLoading(component);
        helper.gfnDoInit(component,event,helper);
       
        var orderDetailList = helper.getUrlParameter('orderDetailList');
        console.log('orderDetailList', orderDetailList);
        var parseOrderDetailList = JSON.parse(orderDetailList);
        console.log('parseOrderDetailList', parseOrderDetailList);
        component.set("v.orderDetailList", parseOrderDetailList);
    },

    // 이벤트 Catch : 고객사명 모달, 배송처 모달
    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam("modalName");
        console.log('modalName::', modalName);
        
        var message = event.getParam("message");
        console.log(JSON.stringify(message),' < ===message');

        if (modalName == 'DN_inputModalOpen') {
            //ShipTo 일반고객 선택
            let customerCode = component.get('v.customerCode');
            let orderHeaderInfo = component.get('v.orderHeaderInfo');
            orderHeaderInfo.postalCode = message.inputZipCode;
            orderHeaderInfo.customerShipToName = message.inputAddress;
            orderHeaderInfo.city = message.inputAddress.replace(message.detailAddress , '');
            orderHeaderInfo.street = message.detailAddress;
            orderHeaderInfo.representative = message.inputManager;
            orderHeaderInfo.phone = message.inputPhone;
            orderHeaderInfo.customerShipToCode = '9999999999';
            orderHeaderInfo.customerShipTo = undefined;
            
            //일반 고객시
            if('9999999999' === customerCode && message.inputCustomerName)
                component.set('v.customerName', '일반고객 ' + message.inputCustomerName);

            let inputShipTo = `${message.inputCustomerName} ${orderHeaderInfo.postalCode} ${orderHeaderInfo.customerShipToName}` ;
            orderHeaderInfo.customerShipToName = inputShipTo +', '+ message.inputManager;
            //orderHeaderInfo.shipToLabel =  inputShipTo +', '+ message.inputManager;
            component.set('v.orderHeaderInfo', orderHeaderInfo);
            
            // component.set('v.inputShipTo', inputShipTo);

        } else if (modalName == 'DN_AgencyCustomerShipToModal') {
            //TODO : customerShipToName > 포뮬러필드 점검 필요
            let orderHeaderInfo = component.get('v.orderHeaderInfo');
            orderHeaderInfo.postalCode = message.postalCode;
            orderHeaderInfo.city = message.city;
            orderHeaderInfo.street = message.street;
            orderHeaderInfo.customerShipToName = `${message.customerName} ${orderHeaderInfo.postalCode} ${orderHeaderInfo.city}`;
            if(orderHeaderInfo.street) orderHeaderInfo.customerShipToName += `, `+orderHeaderInfo.street;
            if(message.manager) orderHeaderInfo.customerShipToName +=', '+message.manager;

            orderHeaderInfo.representative = message.manager;
            orderHeaderInfo.phone = message.phone;
            orderHeaderInfo.customerShipToCode = '';
            orderHeaderInfo.customerShipTo = message.id;
            //orderHeaderInfo.shipToLabel =  message.customerName+' '+ orderHeaderInfo.postalCode + message.city +', '+message.manager;
            //TODO: customerShipTo__c 아이디값 입력필요
            component.set('v.orderHeaderInfo', orderHeaderInfo);

        } else if (modalName == 'DN_AgencyCustomerListModal' ) {
            helper.gfnSetCustomerInfo(component, message.id, message.id, message.customerName);
            helper.gfnSetDiscountRate(component, message.discountRate);
            
            if(message.customerShipTo) {
                let {customerShipTo} = message;
                if(customerShipTo.id) {
                    console.log('shipTo도 세팅');
                    let orderHeaderInfo = component.get('v.orderHeaderInfo');
                    orderHeaderInfo.postalCode = customerShipTo.postalCode;
                    orderHeaderInfo.city = customerShipTo.city;
                    orderHeaderInfo.street = customerShipTo.street;
                    orderHeaderInfo.customerShipToName = `${message.customerName} ${orderHeaderInfo.postalCode} ${orderHeaderInfo.city}`;
                    if(orderHeaderInfo.street) orderHeaderInfo.customerShipToName += `, `+orderHeaderInfo.street;
                    if(customerShipTo.manager) orderHeaderInfo.customerShipToName +=`, ${customerShipTo.manager}`;

                    orderHeaderInfo.representative = customerShipTo.manager;
                    orderHeaderInfo.phone = customerShipTo.phone;
                    orderHeaderInfo.customerShipToCode = '';
                    orderHeaderInfo.customerShipTo = customerShipTo.id;
                    //orderHeaderInfo.shipToLabel =  `${message.customerName} ${orderHeaderInfo.postalCode} ${orderHeaderInfo.city}, ${customerShipTo.manager}`;
                    //TODO: customerShipTo__c 아이디값 입력필요
                    component.set('v.orderHeaderInfo', orderHeaderInfo);
                }
                
            }
            

        } /*else if (modalName == 'DN_ModelSearchModal') {
            var index = component.get("v.selectedModelIndex");
            var partsList = component.get("v.partsList");
            
            partsList[index].machineName = message.label;
            component.set('v.partsList', partsList);
            component.set('v.selectedModelIndex', null);

        }*/ else if (modalName == 'DN_SearchProductNumber') {
            var index = component.get("v.selectedPartsIndex");
            var partsList = component.get("v.partsList");
            console.log('parts', message);
            partsList[index].partName = message.ProductCode;
            partsList[index].part = message.Id;
            component.set('v.selectedPartsIndex', null);
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


        } else if(modalName =='SerialModal') {
            var index = component.get("v.selectedModelIndex");
            var partsList = component.get("v.partsList");
            partsList[index].machineName = message.machineName;
            partsList[index].equipment = message.label;
            component.set('v.partsList', partsList);
            component.set('v.selectedModelIndex', null);
        } else if(modalName =='MachineModal') {
            var index = component.get("v.selectedModelIndex");
            var partsList = component.get("v.partsList");
            partsList[index].machineName = message.label;
            component.set('v.partsList', partsList);
            component.set('v.selectedModelIndex', null);
        }
    },

    // 고객사명 모달 열기
    openCustomerList: function (component, event, helper) {
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_AgencyCustomerListModal",
            {
                'type' : 'All'
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("AgencyCustomerListModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 일괄배송여부 Change
    deliveryChange: function (component, event, helper) {
    },

    // 배송처 모달 열기
    openCustomerShipTo: function (component, event, helper) {
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_AgencyCustomerShipToModal",
            {},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("AgencyCustomerShipToModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    clearCustomer: function (component, event, helper) {
        let customerName = component.get("v.customerName");
        if (!customerName) {
            helper.showMyToast("WARNING", "저장된 고객사명 값이 없습니다."); // 고객코드 값이 없을 때 알림
            return;
        }
        component.set("v.customerName", "");
    },

    clearCustomerShipTo: function (component, event, helper) {
        let orderHeader = component.get("v.orderHeaderInfo");
        let inputShipTo = orderHeader.customerShipToName;
        
        if (!inputShipTo) {
            helper.showMyToast("WARNING", "저장된 배송처 값이 없습니다."); // 배송처 값이 없을 때 알림
            return;
        }
        orderHeader.customerShipToName = "";
        //orderHeader.shipToLabel ="";
        component.set("v.orderHeaderInfo", orderHeader);
    },

    

    // Parts List 10개 추가
    bulkAddPartsProduct: function (component, event, helper) {
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

    // 선택된 Parts List 삭제
    selectedDeletePartsProduct: function (component, event, helper) {
        let partsList = component.get("v.partsList");

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
        console.log(JSON.stringify(partsList), ' ::: partsList');
        new Promise((resolve) => {
            component.set("v.partsList", []);
            component.set("v.partsList", partsList);
            resolve();
        }).then(() => {
        
            let partsListSet = partsList.filter(part => part.partName).map(part => ({ 
                MATNR: part.partName 
            }));
            console.log(JSON.stringify(partsListSet), ' :: partsListSet');
            helper.setInputValue(component, partsListSet, 'productCode');
        });

        let headerCheckbox = component.find("headerCheckbox");
        if (headerCheckbox) {
            headerCheckbox.set("v.checked", false);
        }
        helper.gfnOrderPriceCalculation(component);

    },

    // Parts List 추가
    addPartsProduct: function (component, event, helper) {
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

        // console.log("partsList", JSON.stringify(partsList));
        component.set("v.partsList", partsList);
    },

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
            component.set('v.partsList', partsList);
            resolve();
        }).then(() => {
            let partsListSet = partsList.filter(part => part.partName).map(part => ({ 
                MATNR: part.partName 
            }));
            helper.setInputValue(component, partsListSet, 'productCode');
        });
        
        helper.gfnOrderPriceCalculation(component);

    },

    // 체크박스 선택/해제
    // handleCheckboxChange: function (component, event, helper) {
    //     var checkbox = component.find('checkbox');
    //     var selectedProducts = [];
    //     for (var i = 0; i < checkbox.length; i++) {
    //         if (checkbox[i].get("v.checked")) {
    //             selectedProducts.push(i);
    //         }
    //     }
    //     component.set('v.selectedProducts', selectedProducts);
    // },

    // 기종 / 장비번호 모달
    openModelModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        var rowIndex = event.getSource().get('v.accesskey');
        console.log(event.getSource().getLocalId(),' < ==event.getSource()');
        var type = event.getSource().getLocalId();
        component.set('v.selectedModelIndex', Number(rowIndex));
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 기종 지우기
    clearMachine: function (component, event, helper) {
        let index = event.getSource().get('v.accesskey'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index].machineName) { 
            helper.toast('WARNING', `저장된 기종 값이 없습니다.`);
            return;
        }
    
        partsList[index].machineName = ''; 
        component.set('v.partsList', partsList);
    },

    //장비번호 지우기
    clearAsset : function (component, event, helper) {
        let index = event.getSource().get('v.accesskey'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index].equipment) { 
            helper.toast('WARNING', `저장된 장비번호 값이 없습니다.`);
            return;
        }
    
        partsList[index].equipment = ''; 
        component.set('v.partsList', partsList);
    },
    
    // 부품번호 지우기
    clearProductNumber: function (component, event, helper) {
        let index = event.getSource().get('v.accesskey'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index].partName) { 
            helper.toast('WARNING', `저장된 부품번호 값이 없습니다.`);
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
        partsList[index] = helper.gfnCalcuateDiscountRate(partsList[index]);
        partsList[index] = helper.gfnCalcuateDiscountAmount(partsList[index]);
        helper.gfnTotalDisCountCalculation(component, partsList)
        component.set('v.partsList', partsList);

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
    


    // 주문품번 td에서 부품번호 Modal 띄우기
    openSearchProductNumber: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedPartsIndex', Number(rowIndex));
        console.log('rowIndex', rowIndex);

        let filterPartList = component.get('v.partsList').filter(part=> part.part && part.partName).map(part=>part.part);
        console.log(JSON.stringify(filterPartList));

        $A.createComponent("c:DN_SearchProductNumber",
            {
                "type": "부품번호"
                ,"filterPartList": filterPartList
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

    clickDiscount: function (component, event, helper) {
        let selectedPartList = component.get('v.partsList').filter(part=>part.isSelected);
        if (selectedPartList.length < 1) {
            helper.showMyToast('Error', '한 개 이상의 품번을 선택해주세요.');
        } else {
            component.set('v.discountModal', true);
        }
    },

    discountModalCancel: function (component, event, helper) {
        component.set('v.discountModal', false);
    },

    //discountConfirm
    discountConfirm: function (component, event, helper) {
        let discountRate = component.get('v.discountRate');
        let partsList = component.get('v.partsList');

        if(!discountRate || Number(discountRate) < 0) {
            discountRate = 0;
        } else {
            discountRate = discountRate;
        }

        for (let i = 0; i < partsList.length; i++) {
            let part = partsList[i];
            if(part.isSelected)
                part.discountRate = discountRate;
        }
        
        component.set('v.partsList', [...partsList]);
        helper.gfnOrderPriceCalculation(component);
        
        component.set('v.discountModal', false);


        // const partsList = component.get("v.partsList");
        // const discountRate = component.get("v.discountRate");

        // if (discountRate === null || discountRate === undefined || discountRate === "") {
        //     helper.toast('WARNING', '할인율을 입력해주세요.');
        //     return;
        // }

        // const updatedPartsList = partsList.map(parts => {
        //     if (parts.isSelected) {
        //         parts.discountRate = discountRate; // 할인율 업데이트
        //     }
        //     return parts;
        // });

        // component.set("v.partsList", updatedPartsList);
        // helper.gfnQuotePriceCalculation(component,event);
        // component.set("v.isDiscountModal", false);
        // helper.toast('SUCCESS', '할인율이 적용되었습니다.');
    },

    clickRefresh: function (component, event, helper) {
        // component.set('v.inputShipTo', '');
        let orderHeader = component.get("v.orderHeaderInfo");
        orderHeader.customerShipToName = "";
        component.set("v.orderHeaderInfo", orderHeader);
    },

    // 고객 주문서 저장 (생성, 수정)
    handleSave: function (component, event, helper) {
        if (component.get("v.isSave")) return;
        console.log('주문서 저장! :: ', JSON.stringify(component.get('v.orderHeaderInfo')));
        // helper.gfnShowLoading(component);
        component.set('v.isSpinner', true);
        component.set('v.isSave', true);

        let orderHeaderInfo = component.get('v.orderHeaderInfo');
        orderHeaderInfo.customerName = component.get('v.customerName');

        let requireFields = [
            { field: 'customerOrerNumber' , id: 'customerOrderNoId', message: '고객 주문 번호를 입력하세요.' },
            { field: 'customerName' , id: 'customerNameId', message: '고객사명을 입력하세요.' },
            { field: 'customerShipToName' , id: 'inputShipToId', message: '배송처를 입력하세요.' }
        ];

        let emptyField = requireFields.find((requiredField)=> (!orderHeaderInfo[requiredField.field]) );
        if(emptyField) {
            component.find(emptyField.id).focus();
            helper.showMyToast('Error', emptyField.message);

            if (emptyField.id === 'customerNameId') {
                helper.createComponentHelper(component, "c:DN_AgencyCustomerListModal", "AgencyCustomerListModal");
            }
            else if (emptyField.id === 'inputShipToId') {
                    helper.createComponentHelper(component, "c:DN_AgencyCustomerShipToModal", "AgencyCustomerShipToModal");
            }

            helper.gfnStopLoading(component, 1000);
            component.set('v.isSave', false);
            return;
        }

        let avaliablePartList = helper.gfnGetAvailiablePartList(component);

        if(avaliablePartList.length == 0) {
            helper.toast('Warning', '주문할 품목을 등록해주세요.');
            helper.gfnStopLoading(component);
            component.set('v.isSave', false);
            return;
        }
        
        if(!avaliablePartList.every(part=>part.discountPrice)) { //!avaliablePartList.every(part=>part.discountPrice)
            helper.toast('Warning', 'Simualtion 을 진행하지 않은 품목이 존재합니다.');
            helper.gfnStopLoading(component);
            component.set('v.isSave', false);
            return;
        }

        if(!helper.gfnCustomerPriceValidatoin(component,event)){
            helper.toast('Warning', '고객판매가가 0 인 항목이 존재합니다.');
            helper.gfnStopLoading(component);
            component.set('v.isSave', false);
            return;
        }
        
        // let dmlType =  orderHeaderInfo.id ==undefined ? 'createOrder': 'updateOrder';
        // helper.gfnSimulation(component, event)
        //     .then($A.getCallback(function(result) {
        //         let partList = component.get('v.partsList');
        //         if(!partList.every(part=>part.discountPrice)) {
        //             helper.toast('Warning', '부품이 올바르지 않습니다. 부품을 확인해주세요');
        //         } else {
        //             helper.gfnSaveOrder(component, event, `${dmlType}`);
        //             return;
        //         }
        //     }))
        //     .catch(error => {
        //         console.log(error,' :: sserror');
        //     })
        let partList = helper.gfnGetAvailiablePartList(component);
        if(partList.length > 170) {
            helper.toast('Warning', '주문서의 품목은 최대 170개까지 가능합니다.');
            helper.gfnStopLoading(component);
            component.set('v.isSave', false);
            return;
        }
        console.log(JSON.stringify(partList), ' partList');
        if(!orderHeaderInfo.id) {
            //isSimulation
            for(let i=0; i<partList.length; i++) {
                if(!partList[i].isSimulation) {
                    helper.toast('Warning', 'Simualtion 을 진행하지 않은 품목이 존재합니다.');
                    helper.gfnStopLoading(component);
                    component.set('v.isSave', false);
                    return;
                }
            }
            helper.gfnSaveOrder(component, event, 'createOrder');
            // helper.gfnSimulation(component, event)
            // .then($A.getCallback(function(result) {
            //     let partList = helper.gfnGetAvailiablePartList(component);
            //     if(!partList.every(part=>part.discountPrice)) {
            //         helper.toast('Warning', '부품이 올바르지 않습니다. 부품을 확인해주세요');
            //         helper.gfnStopLoading(component);
            //     } else {
            //         helper.gfnSaveOrder(component, event, 'createOrder');
            //         return;
            //     }
                
            // }))
            // .catch(error => {
            //     console.log(error,' :: sserror');
            // })
        }else {
            //출고수량보다 변경수량이 작을 수 
            if( !helper.gfnOrderQuantityValidatoin(component, event) || avaliablePartList.length == 0 ) {
                helper.toast('Warning', '변경수량이 출고수량 보다 작습니다.');
                helper.gfnStopLoading(component);
                component.set('v.isSave', false);
                return;
            }
            helper.gfnSaveOrder(component, event, 'updateOrder');
            return;
        }
    },

    // 테이블 세로 스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

    // Simulation
    simulationExecute: function (component, event, helper) {
        // Validation
        helper.gfnSimulationExecute(component, event);
    },

    // 모달창 할인율 chnage event
    handleDiscountRate : function (component, event, helper) {
        let value = event.getSource().get("v.value");
        let valueSet = 0;

        if(!value || Number(value) < 0) {
            component.set('v.isRenderDiscountRate', false);
            valueSet = 0;
            setTimeout(()=>{
                component.set("v.discountRate",valueSet);
                component.set('v.isRenderDiscountRate', true);
            }, 0);
        } else {
            valueSet = value;
            component.set('v.discountRate',valueSet);
        }

        // ///[^0-9]/.test(value)
        // // if(/[^0-9]/.test(value)) {
        // //     valueSet = 0;
        // // } else {
        // //     valueSet = Number(value);
        // // }
        
    },

    changeQuantity : function (component, event, helper) {
        let orderQty = event.getSource().get('v.value');
        if(/[^0-9]/.test(orderQty)) {
            orderQty = 0;
        } else {
            orderQty = Number(orderQty);
        }
        if(orderQty > 1000) {
            helper.showMyToast('Error', '수량은 1,000개까지만 입력 가능합니다.');
            return;
        }
        let index = event.getSource().getElement().id;
        let partsList = component.get("v.partsList");
        partsList[index].quantity = orderQty;
        let parts = partsList[index];

        parts = helper.gfnCalcuateDiscountRate(parts);
        parts = helper.gfnCalcuateDiscountAmount(parts);
        helper.gfnTotalDisCountCalculation(component, partsList);
        component.set("v.partsList", partsList);
        
    },

    //할인율 적용
    changeDiscount : function (component, event, helper) {
        let value = event.getSource().get("v.value");
        let index = event.getSource().get("v.accesskey");
        let partsList = component.get("v.partsList").map(part=>part);

        if(!value || Number(value) < 0) {
            value = partsList[index].discountRate = 0;
            partsList[index].isRendered = false;
            component.set('v.partsList', partsList);
        } else {
            partsList[index].discountRate = value;
        }
        
        console.log(value);
        // if(/[^0-9]/.test(value)) {
        //     value = 0;
        // } else {
        //     value = Number(value);
        // }
        
        setTimeout($A.getCallback(() => {
            partsList[index].isRendered = true;
            component.set('v.partsList', partsList);
            helper.gfnOrderPriceCalculation(component,event);
        }))
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
        helper.gfnOrderPriceCalculation(component);
    },

    handleChangePageReference : function (component, event, helper) {
        console.log(component.getName(),'.handleChangePageReference');
        let pageRef = component.get('v.pageReference');
        console.log(JSON.stringify(pageRef));
    },

    moveCreateOrder : function(component, event, helper) {
        component.find('redirect').redirectPage('AddMoreOrder', 'moveToURL', component.get('v.sourceId'));
        // helper.gfnMoveCustomPage(component, 'CustomerOrderCreate__c', undefined, false);
        //URL 변경후 Refresh
        // $A.get('e.force:refreshView').fire();
    },

    selectedDeletePartsEditMode : function(component, event , helper) {
        helper.gfnShowLoading(component);
        helper.gfnDeleteOrderItems(component,event);
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
        // let headerParams = {
        //     "Part No.": 'partName',
        //     "Qty": 'quantity',
        //     "Model No.": 'machineName',
        //     "Serial No.": 'equipment',
        // };

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

            let excelUploadTemplate = component.get('v.excelUploadTemplate');
            console.log(JSON.stringify(excelUploadTemplate), '< == excelUploadTemplate');

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
            console.log(JSON.stringify())
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

            //helper.handleHeaderUpload > ex) [{"Part No.":"S4006532","Qty":10,"Model No.":"TEST","Serial No.":"TEST"}]
            //helper.handleUpload > ex) [["Part No.","Qty","Model No.","Serial No."],["S4006532",10,"TEST","TEST"]]

            
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

    //뒤로 가기
	goBack :function(component, event, helper) {
		if(history.length > 1) {
            window.history.back();
        } else {
            component.find('redirect').redirectPage('OrderDetail', 'directMove', component.get('v.sourceId'));
        }
	},

    handleInputChange : function (component, event, helper) {
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
            partsList[index].partName =matnr;
            partsList[index].part = value;
            partsList[index].isSimulation = false;
            component.set('v.partsList',partsList);
        }
    },

    handleFocus : function(component, event, helper) {
        let inputComponent = event.getSource();
        if (inputComponent) {
            let inputElement = inputComponent.getElement();
            inputElement.addEventListener("keydown", function(evt) {
                        helper.gfnHandleKeyPress(component, evt);
            });
        }
    },

    handleKeyPress : function(component, event, helper) {
        console.log('div Binding handleKeyPress');
        helper.gfnHandleKeyPress(component, event);
    },

    changeUpperCase : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        if(value) {
            event.getSource().set('v.value', value.toUpperCase());
        }
    }

})