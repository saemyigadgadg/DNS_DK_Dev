/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 01-02-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-05-31   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.filter', {
            'fieldApiName' : 'productCode',
            'parentFieldApiName' : '',
            'fieldType' : 'Lookup',
            'isRequired' : 'false'
        })
        helper.gfnDoinit(component, event);
    },

    // +버튼으로 추가
    addPartsProduct: function (component, event, helper) {
        let partsList = component.get("v.partsList");
        let num = 0;
        if (partsList.length > 0) {
            num = partsList[partsList.length - 1].hangNumber;
        }
        let str = num + 10 + '';

        console.log('항목', str.padStart(6, '0'));
        let dealerName = component.get('v.dealerNameForOrder');
        let dealer = component.get('v.dealerForOrder');

        let objSelectItem = {
            "hangNumber": num + 10,
            "itemSeq": str.padStart(6, '0'),
            "partName": "",
            "replacingPartName": "",
            "replaceSize":1,
            "check": false,
            "quantity": "",
            "discountRate": 0.0,
            "isSelected":false,
        }
        if(dealerName) {
            objSelectItem.dealerName = dealerName;
            objSelectItem.dealer = dealer;
        }
        partsList.push(Object.assign({}, objSelectItem));
        component.set("v.partsList", partsList);
    },

    // -버튼으로 제거
    deletePartsProduct: function (component, event, helper) {
        let partsList = component.get("v.partsList");

        let index = event.getSource().get('v.accesskey');
        let removePart = partsList[index];
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

        helper.gfnTotalDisCountCalculation(component, partsList);

        let headerCheckbox = component.find("headerCheckbox");
        if (headerCheckbox) {
            headerCheckbox.set("v.checked", false);
        }
        
    },

    // 추가버튼으로 10개 추가
    bulkAddPartsProduct: function (component, event, helper) {
        var partsList = component.get("v.partsList");
        var num = 0;
        if (partsList.length > 0) {
            num = partsList[partsList.length - 1].hangNumber;
        }
        let dealerName = component.get('v.dealerNameForOrder');
        let dealer = component.get('v.dealerForOrder');
        for (var i = 0; i < 10; i++) {
            var num2 = num + ((i + 1) * 10);
            var str = num2 + '';
            var objSelectItem = {
                "hangNumber": num2,
                "itemSeq": str.padStart(6, '0'),
                "partName": "",
                "replacingPartName": "",
                "replaceSize":1,
                "check": false,
                "quantity": "",
                "discountRate": 0.0,
                "isSelected":false,
            };
            if(dealerName) {
                objSelectItem.dealerName = dealerName;
                objSelectItem.dealer = dealer;
            }
            partsList.push(Object.assign({}, objSelectItem));
        }
        component.set("v.partsList", partsList);
    },

    // 전체 선택/해제
    selectAll: function (component, event, helper) {
        let isChecked = component.find("headerCheckbox").get("v.checked");

        let partList = component.get('v.partsList');
        partList.forEach((part)=> {
            if(part.partName) part.isSelected = isChecked;
        });
        component.set('v.partsList', partList);
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

    // 체크된 Row 삭제
    selectedDeletePartsProduct: function (component, event, helper) {
        let partsList = component.get("v.partsList");

        // for (let lastIdx = partsList.length - 1 ; lastIdx >= 0; lastIdx--) {
        //     let part = partsList[lastIdx];
        //     if(part.isSelected)
        //         partsList.splice(lastIdx, 1);
        // }
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
            component.set('v.partsList', partsList);
            resolve();
        }).then(() => {
            let partsListSet = partsList.filter(part => part.partName).map(part => ({ 
                MATNR: part.partName 
            }));
            helper.setInputValue(component, partsListSet, 'productCode');
        });
    },

    // Simulation
    getSimulationInfo : function (component, event, helper) {
        console.log('시뮬 시작');

        helper.gfnSimulation(component, event);
        
        // helper.gfnSimulation2(component, event);

    },

    // 배송처 Modal 띄우기
    openSearchShipToModal: function (component, event, helper) {
        $A.createComponent("c:DN_AgencyCustomerShipToModal",
            {},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("SearchShipToModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    openOtherDealerStockModal: function (component, event, helper) {
        let partsList = component.get("v.partsList").filter((part)=>part.isSelected);

        let partList = [];

        let nullCheck = true;
        let message = '';
        
        

        let inputCmpAll  = component.find('productCode');
        partsList.forEach((part,index) => {
            if (nullCheck) {
                let parts = part;
                console.log(parts.partName);
                console.log(parts.quantity);
                if (parts.partName != null && parts.partName != '' && parts.quantity != null && parts.quantity != '') {
                    
                    partList.push({
                        'partName': inputCmpAll[index].getInputValue(),//parts.partName,
                        'requestQuantity': Number(parts.quantity)
                    });
                } else {
                    if (parts.partName == null || parts.partName == '') {
                        message = '선택한 항목의 품번을 확인해주세요.';
                    } else if (parts.quantity == null || parts.quantity == '') {
                        message = '선택한 항목의 수량을 확인해주세요.';
                    }
                    nullCheck = false;
                }
            }
        });

        console.log('partList', JSON.stringify(partList));

        if (partList.length > 0 && nullCheck) {
            $A.createComponent("c:DN_OtherDealerStockQtyModal",
                {
                    'partList': partList
                },
                function (content, status, errorMessage) {
                    if (status === "SUCCESS") {
                        var container = component.find("OtherDealerStockModal");
                        container.set("v.body", content);
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        } else if (!nullCheck) {
            helper.toast('Waring', message);
            console.log(message);
        } else if (partList.length == 0) {
            console.log('항목을 선택해주세요.');
            helper.toast('Waring', '항목을 선택해주세요.');
        }
    },

    // 배송처 초기화
    refreshShippingAddress: function (component, event, helper) {
        component.set('v.inputShipTo', null);
    },

    // 주문품번 모달
    openSearchProductNumber: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedPartsIndex', Number(rowIndex));
        component.set('v.costInfoModal', false);

        let filterPartList = component.get('v.partsList').filter(part=> part.part && part.partName).map(part=>part.part);
        console.log(JSON.stringify(filterPartList));

        $A.createComponent('c:DN_SearchProductNumber',
            {
                'type': '부품번호'
                ,"filterPartList":filterPartList
            },
            function (content, status, errorMessage) {
                if (status === 'SUCCESS') {
                    var container = component.find('SearchProductNumber');
                    container.set('v.body', content);
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.')
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            }
        );
    },

    // 기종 모달
    openMachineModal: function (component, event, helper) {
        component.set('v.isLoading', true);
        //열려 있는 모달창 닫기
        let rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedMachineNameIndex',Number(rowIndex));
        console.log(component.get('v.selectedMachineNameIndex'));
        let type = '기종';
        $A.createComponent('c:DN_ModelSearchModal',
            {
                'type': type
            },
            function (content, status, errorMessage) {
                if (status === 'SUCCESS') {
                    var container = component.find('ModelSearchModal');
                    console.log('container', container);
                    container.set('v.body', content);
                    // component.set('v.equipmentName');
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.')
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            }
        );
        component.set('v.isLoading', false);
    },

    // 장비번호 모달 
    openEquipmentModal: function (component, event, helper) {
        component.set('v.isLoading', true);
        //열려 있는 모달창 닫기
        // component.set('v.excelUploadModal', false);
        // component.set('v.costInfoModal', false);

        let rowIndex = event.getSource().get('v.accesskey');
        component.set('v.selectedEquipmentIndex', Number(rowIndex));
        let partList = component.get('v.partsList');
        
        let machine = ''
        console.log('장비번호 값 관련 rowIndex :: ' + rowIndex)

        if(partList[rowIndex].machineName) {
            machine = partList[rowIndex].machineName;
        }
        
        let type = '장비번호';

        $A.createComponent('c:DN_ModelSearchModal',
            {
                'type' : type,
                'MachineName' : machine
            },
            function (content, status, errorMessage) {
                if (status === 'SUCCESS') {
                    var container = component.find('ModelSearchModal');
                    container.set('v.body', content);
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.')
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            }
        );
        component.set('v.isLoading', false);
    },  

    clearMachine: function (component, event, helper) {
        helper.clearField(component, event, helper, 'machineName', '저장된 기종이 없습니다.');
    },
    
    clearAsset: function (component, event, helper) {
        helper.clearField(component, event, helper, 'equipment', '저장된 장비번호가 없습니다.');
    },
    
    clearProductNumber: function (component, event, helper) {
        let index = event.getSource().get('v.accesskey'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index].partName) { 
            helper.toast('WARNING', '저장된 부품번호가 없습니다.');
            return;
        }
        helper.gfnResetPart(partsList[index] , true);
        partsList = helper.gfnCalcuateDiscountRate(partsList);
        partsList = helper.gfnCalcuateDiscountAmount(partsList);
        helper.gfnTotalDisCountCalculation(component, partsList);
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

    // Modal에서 값 받아오기
    handleCompEvent: function (component, event, helper) {
        let modalName = event.getParam("modalName");
        let message = event.getParam("message");
        let partsList = component.get("v.partsList");

        if (modalName == 'DN_SearchProductNumber') {
            //부품 번호
            let idx   = component.get('v.selectedPartsIndex');
            let parts = partsList[idx];
            let isNotDealerReset =  parts['dealer'] == component.get('v.dealerForOrder');
            parts = helper.gfnResetPart(parts, isNotDealerReset);

            parts.part     = message.Id;
            parts.partName = message.ProductCode; 
            
            component.set('v.selectedPartsIndex', -1);
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
            //장비번호
            let idx   = component.get('v.selectedEquipmentIndex');
            let parts = partsList[idx];

            parts.equipment = message.label;

            component.set('v.partsList', partsList);
            component.set('v.selectedEquipmentIndex', -1);
        } else if(modalName =='MachineModal') {
            //기종
            let idx   = component.get("v.selectedMachineNameIndex");
            let parts = partsList[idx];

            parts.machineName = message.label;

            component.set('v.partsList', partsList);
            component.set('v.selectedMachineNameIndex', -1);
        } else if(modalName == 'DN_OtherDealerStockQtyModal') {
            console.log('DN_OtherDealerStockQtyModal');
            console.log(message);

            //Disbaled 대리점이 다를경우 > 
            let dealerCodes = new Set();
            let orderDealerCode = component.get('v.dealerCodeForOrder');
            if(orderDealerCode) dealerCodes.add(orderDealerCode);
            partsList.forEach(part=>{
                if(part.isSelected && message[part.partName]) {
                    let dealerStock = message[part.partName];
                    part.dealer               = dealerStock.dealer;
                    part.dealerName           = dealerStock.dealerName;
                    part.dealerCode           = dealerStock.dealerCode;
                    dealerCodes.add(part.dealerCode);
                    part.partDetails          = dealerStock.partDetails;
                    part.replacingPart        = dealerStock.replacingPart;
                    part.replacingPartName    = dealerStock.replacingPartName;
                    part.replacingPartDetails = dealerStock.replacingPartDetails;
                    part.salesUnit            = undefined;
                    part.customerPrice        = dealerStock.customerPrice || 0;
                    part.discountPrice        = dealerStock.discountPrice || 0;
                    part.discountRate         = dealerStock.discountRate  || 0;

                    part = helper.gfnCalcuateDiscountRate(part);
                    part = helper.gfnCalcuateDiscountAmount(part);
                }
            });
            helper.gfnTotalDisCountCalculation(component, partsList);

            if(dealerCodes.size > 1) {
                let field ='CustomerName__c';
                let message = {
                    field,
                    value: true,
                    label:'',
                    value:''
                };
                let togglePayload = {
                    uuid : component.get('v.uuid'),
                    cmpName : 'DN_CreateAnotherAgencyPurchase',
                    type : 'filterToggleDisabled',
                    message
                };
                component.find("dealerPortalLMC").publish(togglePayload);
                //기존 이벤트 재활용
                let resetPayload = {
                    uuid : component.get('v.uuid'),
                    cmpName : 'DN_CreateAnotherAgencyPurchase',
                    type : 'filterReset',
                    message
                };
                component.find("dealerPortalLMC").publish(resetPayload);
                let headerParams = component.get('v.headerParams');
                headerParams[field] = '';
                component.set('v.headerParams', headerParams);
                component.set('v.dealerNameForOrder', '');
                component.set('v.dealerForOrder', '');
                component.set('v.dealerCodeForOrder', '');
                
            }

            component.set('v.partsList', partsList);
        }
    },
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },


    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(`${component.getName()}.setSubscriptionLMC`);
            console.log(JSON.stringify(message));
           
            switch (params.cmpName) {
                case 'dN_DealerPortalFilter':
                    if(params.type ==='filterChange' || params.type === 'defaultFilter') {
                        let headerParams = component.get('v.headerParams');
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

                        //대리점명 초기화시 
                        if(params.message.field === 'CustomerName__c' && !params.message.value) {
                            helper.gfnSetDealerOrderItem(component, '', '', '');
                            component.set('v.dealerNameForOrder', '');
                            component.set('v.dealerForOrder', '');
                        }
                    }
                    break;
                case 'DN_DealerPortalDisplay': 
                    if(params.type ==='filterModal') {
                        //고객사 선택시 DN_DealerPortalDisplay 이벤트 수신 (label, value 값 가져오기위해)
                        if(params.message.field === 'CustomerName__c') {
                            helper.gfnSetDealerOrderItem(component, params.message.label, params.message.value, params.message.customerCode);
                            
                            component.set('v.dealerNameForOrder', params.message.label);
                            component.set('v.dealerForOrder', params.message.value);
                            component.set('v.dealerCodeForOrder', params.message.customerCode);
                        }else if(params.message.field === 'shipTo') {
                            //배송처
                            let {postalCode, city, street, customerName, representative, phone } = params.message;
                            component.set('v.postalCode',postalCode);
                            component.set('v.city',city);
                            component.set('v.street',street);
                            component.set('v.customerName',customerName);
                            component.set('v.shipToName',customerName);
                            component.set('v.representative',representative);
                            component.set('v.phone',phone);
                        }
                    }
                    break;
                case 'dN_DealerPortalButton':
                    if(params.type === 'Seach') {
                        // helper.gfnSearchReturnRequestOrder(component, null, 'Search');
                    }else if(params.type === 'Save') {
                        //let order = helper.gfnMeregeOrderAndItem(component);
                        let partList = component.get('v.partsList');
                        let partSetList = partList.filter((orderItem)=>orderItem.partName && !orderItem.disabled);
                        if(partSetList.length > 50) {
                            helper.toast('Warning', '주문품번 목록은 최대 50개까지만 가능합니다. Parts List를 확인해주세요.');
                            return;
                        }
                        for(let i=0; i<partSetList.length; i++) {
                            if(!partSetList[i].isSimulation) {
                                helper.toast('Warning', 'Simualtion 을 진행하지 않은 품목이 존재합니다.');
                                helper.gfnStopLoading(component);
                                return;
                            }
                        }
                        helper.gfnSaveOrder(component, event, 'createOrder');
                        // helper.gfnSimulation(component)
                        // .then($A.getCallback(function(result) {
                        //     // let partList = component.get('v.partsList');
                        //     // if(!partList.every(part=>part.discountPrice)) {
                        //     //     helper.toast('Warning', '부품이 올바르지 않습니다. 부품을 확인해주세요');
                        //     //     helper.gfnStopLoading(component);
                        //     // } else {
                        //         helper.gfnSaveOrder(component, event, 'createOrder');
                        //         return;
                        //     //}
                        // }))
                        // .catch(error => {
                        //     console.log(error,' :: sserror');
                        // })
                        
                    }
                    break;
                
                case 'dN_DealerPortalQueryPage':
                    console.log('dN_DealerPortalQueryPage');
                    console.log(JSON.stringify(params), ' msg');
                    component.set('v.nextPage',    params.message.nextpage);
                    component.set('v.currentPage', params.message.currentPage);
                    // helper.gfnSearchReturnRequestOrder(component, null, 'PageChange');
                    break;  
            }
        }
    },

    changeDiscountPriceAmount : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let partsList = component.get('v.partsList');
        let rowIndex = event.getSource().get('v.accesskey');
        let part = partsList[rowIndex];

        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        partsList[rowIndex].quantity = value;
        
        


        part = helper.gfnCalcuateDiscountRate(part);
        part = helper.gfnCalcuateDiscountAmount(part);
        helper.gfnTotalDisCountCalculation(component, partsList);
        component.set('v.partsList', partsList);

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