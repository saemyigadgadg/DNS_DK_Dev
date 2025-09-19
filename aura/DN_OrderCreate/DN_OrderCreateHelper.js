/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-15
 * @last modified by  : KyongyunJung@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-05-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    apexCall : function(component, methodName, params) {
        console.log('helper 동작 확인' + ' || ' + methodName)
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's': response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    catchUrl : function(component, event) {
        console.log('catchUrl')
        let params = new URLSearchParams(window.location.search);
        let partsList = []; 
        console.log('params' + params);

        if (!params.toString())  {
            return [];
        } else {
            let qtyArray = [];

            // `c_Material`이 있는 경우 처리
            if (params.has("c_Material")) {
                let materialString = params.get("c_Material");
                partsList = materialString ? materialString.split(',') : [];
                component.set('v.poName', partsList);

                let qtyString = params.get("c_QTY");
                qtyArray = qtyString ? qtyString.split(',') : [];
                component.set('v.qtyArray', qtyArray);

                return partsList;
            }
            
            // `c__parts`이 있는 경우 처리
            if (params.has("c__parts")) {
                let partsString = params.get('c__parts');
                partsList = partsString.split(',').map(part => part.trim());

                let qtyString = params.get("c_QTY");
                qtyArray = qtyString ? qtyString.split(',') : [];
                component.set('v.qtyArray', qtyArray);
                return partsList;
            }
        }
    },

    deepCopy: function(obj) {
        if (typeof obj !== "object" || obj === null) return obj;
        let copy = Array.isArray(obj) ? [] : {};
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                copy[key] = this.deepCopy(obj[key]);
            }
        }
        return copy;
    },

    searchProduct: function(component, event, helper) {
        var self = this;
        return new Promise(function(resolve, reject) {  
            try {
                let confirmParts = component.get('v.confirmParts');
                let qtyArray     = component.get('v.qtyArray');
                let isExcel      = component.get('v.isExcel');
                let initsList    = component.get('v.initsList');

                let partsList;
                if(isExcel) {
                    partsList = component.get('v.initsList');    
                }else {
                    partsList = component.get('v.partsList');
                }
                
                component.set('v.partsList', partsList);
                console.log('helper isExcel >> ' +JSON.stringify(isExcel,null,4))
                console.log('helper initsList >> ' +JSON.stringify(initsList,null,4))
                
                console.log('helper confirmParts >> ' +JSON.stringify(confirmParts,null,4));
                console.log('helper partsList >> ' +JSON.stringify(partsList,null,4))
                console.log('helper qtyArray >> ' +JSON.stringify(qtyArray,null,4))
                

                let emptyRow = partsList.filter(e => e.orderPartNo.trim() === '');
                // parsList 길이
                var psLen = partsList.length;
                // pastList 중 빈값의 길이
                var erLen = emptyRow.length;
                // 확정 부품의 길이
                var cpLen = confirmParts.length;
                // 전체 중 비어 있는 row 개수
                var gap1 = psLen - erLen;
                // 비어 있는 row와 들어갸야할 데이터의 차이
                var gap2 = erLen - cpLen;

                console.log('psLen > ' +psLen)
                console.log('erLen > ' +erLen)
                console.log('cpLen > ' +cpLen)
                console.log('gap1 > ' +gap1)
                console.log('gap2 > ' +gap2)
    
                if (gap1 === 0 && gap2 >= 0) {
                    console.log(`case01 :: ${gap1} = 0 / ${gap2} >= 0`);
                    for (let i = 0; i < cpLen; i++) {
                        partsList[i].orderPartNo = confirmParts[i].ProductCode;
                        partsList[i].partName = confirmParts[i].FM_MaterialDetails__c;
                        partsList[i].orderPartId = confirmParts[i].Id;
                        if(qtyArray !== null ) {
                            partsList[i].quantity = qtyArray[i] || '';
                        }
                    }
                } else if (gap1 > 0 && gap2 >= 0) {
                    console.log(`case02 :: ${gap1} > 0 / ${gap2} >= 0`);
                    for (let i = 0; i < cpLen; i++) {
                        partsList[i + gap1].orderPartNo = confirmParts[i].ProductCode;
                        partsList[i + gap1].partName = confirmParts[i].FM_MaterialDetails__c;
                        partsList[i + gap1].orderPartId = confirmParts[i].Id;
                    }
                } else if (gap1 === 0 && gap2 < 0) {
                    console.log(`case03 :: ${gap1} = 0 / ${gap2} < 0`);
                    let j = 0;
                    let n = Number(gap2)*-1;

                    self.addList(component, event, helper, n);
                    console.log('리스트 생성');
                    console.log('case03 PartsList '+JSON.stringify(partsList,null,4));
                    partsList = component.get('v.partsList');
                    for (let i = 0; i < cpLen; i++) {
                        partsList[i].orderPartNo = confirmParts[i].ProductCode;
                        partsList[i].partName    = confirmParts[i].FM_MaterialDetails__c;
                        partsList[i].orderPartId = confirmParts[i].Id;
                        if(qtyArray !== null ) {
                            partsList[i].quantity = qtyArray[i] || '';
                        }
                    }
                    console.log('case03 PartsList '+JSON.stringify(partsList,null,4));
                    console.log('case03 완료');
                } else if (gap1 > 0 && gap2 < 0) {
                    console.log(`case04 :: ${gap1} > 0 / ${gap2} < 0`);
                    // let j = 0;
                    // while (j > gap2) {
                    //     self.addList(component, event, helper, 1);
                    //     j--;
                    // }
                    // let partsList = component.get('v.partsList');
                    let n = Number(gap2)*-1;

                    self.addList(component, event, helper, n);
                    partsList = component.get('v.partsList');
                    console.log('리스트 생성');
                    for (let i = 0; i < cpLen; i++) {
                        partsList[i + gap1].orderPartNo = confirmParts[i].ProductCode;
                        partsList[i + gap1].partName = confirmParts[i].FM_MaterialDetails__c;
                        partsList[i + gap1].orderPartId = confirmParts[i].Id;
                    }
                } else {
                    console.log('또 다른 경우의 수가 있을까요?');
                }
                
                console.log('helper 작업 끝');
                component.set('v.partsList', partsList);  // 값 업데이트
                component.set('v.isExcel', false);
                resolve(partsList);
            } catch (error) {
                reject(error);
                component.set('v.isExcel', false);
            }
        });
    },
    

    addList : function(component, event, helper, addNum) {
        console.log('add List 추가 시작');
        var partsList = component.get('v.partsList');
        var partsList2 = partsList.filter(e => e.hang % 10 == 0);
        var partListLength = component.get('v.partListLength');

        // if(partsList2.length > 169) {
        //     helper.toast('INFO', '추가 ROW는 최대 170건 까지 입니다.');
        //     return;
        // }

        if(partListLength > 201) {
            helper.toast('INFO', $A.get("{!$Label.c.ORC_MSG_19}"));//부품은 최대 200건 까지 주문 가능 합니다.
            return;
        }

        var num = 0;
        if (partsList2.length > 0) {
            num = Number(partsList2[partsList2.length - 1].hang);
        }
        for (var i = 0; i < addNum; i++) {
            var num2 = num + ((i + 1) * 10);
            var str = num2 + '';
            var objSelectItem = {
                'hangNumber'     : num2,
                'hang'           : String(num2).padStart(6, '0'), // 항목
                'orderPartNo'    : '',                   // 주문품번
                'supplyPartNo'   : '',                   // 공급풉번
                'partName'       : '',                   // 품명
                'urgency'        : false,                // 긴급도
                'quantity'       : '',                   // 주문 수량
                'salesUnit'      : '',                   // 판매 단위
                'unit'           : '',                   // 단위
                'unitPrice'      : '',                   // 단가
                'partsAmount'    : '',                   // 금액
                'piCurrency'     : '',                   // 통화
                'availableStock' : '',                   // 가용 재고
                'twp'            : '',                   // TWP
                'bulletin'       : '',                   // bullentin
                'note'           : '',                   // note
                'machine'        : '',                   // 기종
                'equipment'      : '',                   // 장비번호

                'orderPartId'    : '',                   // 주문품번 Id
                'supplyPartId'   : '',                   // 공급품번 Id
            };
            partsList.push(Object.assign({}, objSelectItem));
        }
        component.set('v.partsList', partsList);
        console.log('helper 의 add List >> partsList \n ' + JSON.stringify(partsList,null,4));
    },

    // 오더 유형 입력값 설정
    updateFieldValue: function(component, event) {
        let evt   = event.getSource();
        let name  = evt.get('v.name');
        let value = evt.get('v.value');

        let isSave    = component.get('v.isSave');
        let partsList = component.get("v.partsList");
        let isYDEO    = component.get('v.isYDEO');

        component.set("v." + name, value);

        console.log(name + value);
        console.log('isSave >> ' + isSave);

        if(name == "orderType") {
            component.set('v.isSave', false);
            partsList = partsList.filter(part => part.orderPartNo);
            if(partsList.length > 0) {
                if(value != "YDEO" && isYDEO) {
                    partsList.forEach(part => {
                        part.urgency = false;
                    })
                    component.set("v.partsList", partsList);
                    // component.set('v.isSave', false);
                    component.set('v.isYDEO', false);
                    this.toast('WARNING', $A.get("{!$Label.c.ORC_MSG_20}")); //주문 유형 변경으로 모든 긴급도가 해제 됩니다.
                } 
                else if (value == "YDEO") {
                    partsList.forEach(part => {
                        part.urgency = true;
                    })
                    component.set("v.partsList", partsList);
                    // component.set('v.isSave', false);
                    component.set('v.isYDEO', true);
                    this.toast('SUCCESS', $A.get("{!$Label.c.ORC_S_MSG_2}")); //입력한 값들의 긴급도가 체크 됩니다.
                }
            }
          console.log('isSave >> ' +component.get('v.isSave'));  
        }
    },    

    // 단순 입력값 설정
    updateFieldValue1: function(component, event, helper) {

        let evt   = event.getSource();
        let name  = evt.get('v.name');
        let value = evt.get('v.value');
        let keyNo = evt.get('v.accesskey');

        console.log('name > ' + name);
        console.log('value > ' + value);

        component.set('v.'+name, value);

        let pls = component.get('v.partsList');

        if(name == 'machine' || name == 'equipment') {
            let opn = pls[keyNo].orderPartNo;
            pls.forEach(item => {
                if (item.orderPartNo != '' && item.orderPartNo === opn) {
                    item[name] = value;
                }
            });
    
            component.set('v.partsList', pls);    
        }
    },

    // 부품 관련 입력값 설정
    updateFieldValue2: function(component, event, helper) {
        component.set('v.isSave', false);
        const self = this;

        let evt   = event.getSource();
        let name  = evt.get('v.name');
        let value = evt.get('v.value');
        let keyNo = evt.get('v.accesskey');
        
        let pls    = component.get('v.partsList');
        
        let opn = pls[keyNo][name];

        console.log('name > ' + name);
        console.log('value > ' + value);
        console.log('opn >' + opn);
        console.log('keyNo > ' + keyNo);
        console.log('pls >> ' +JSON.stringify(pls,null,4))
        
        value = value.toUpperCase()

        if(name === 'orderPartNo' && value.trim() == '') {
            evt.set('v.value', null);
        }

        // 부품 중복 입력 검사
        let samePart = pls.some((row, idx) => {
            // return row.orderPartNo == value && idx !== keyNo;
            return row.hang % 10 === 0 && row.orderPartNo == value && idx !== keyNo;
        });

        console.log('samePart >>' +samePart);

        if(name === 'orderPartNo' && samePart && value) {
            evt.set('v.value', null);
            self.toast('INFO',$A.get("{!$Label.c.DNS_CAM_T_EXISTCOMMONPARTS}")); //이미 같은 부품이 입력되어 있습니다  ->이미 선택된 부품입니다.
            return;
        }else {
            evt.set('v.value', value);
        }
        
        // 수량 변경 검사
        if (name === 'quantity' && value <= 0) {
            evt.set('v.value', null);
            self.toast('INFO',$A.get("{!$Label.c.DNS_M_QuantityGreater0}"));  //수량이 0 이하가 될 수 없습니다.->수량은 0보다 커야 합니다.	
            return;
        }else {
            evt.set('v.value', value);
        }

        if(name === 'quantity' && value.length > 6) {
            evt.set('v.value', null);
            self.toast('INFO',$A.get("{!$Label.c.ORC_MSG_21}")); //수량은 최대 999999 까지 가능합니다.
            return;
        }else {
            evt.set('v.value', value);
        }

        // if(name == 'machine' || name == 'equipment') {
        //     let opn = pls[keyNo].orderPartNo;
        //     pls.forEach(item => {
        //         if (item.orderPartNo != '' && item.orderPartNo === opn) {
        //             item[name] = value;
        //         }
        //     });
    
        //     component.set('v.partsList', pls);    
        // }
    },

    dayCount: function(selDay, num) {
    
        let newDate = new Date(selDay);
    
        if (num !== undefined) {
            newDate.setDate(newDate.getDate() + num);
        }
    
        let year  = newDate.getFullYear();
        let month = newDate.getMonth() + 1;
        let day   = newDate.getDate();
    
        return `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
    },
    readExcelFile: function (component, file, event) {
        return new Promise(function (resolve, reject) {
            var reader = new FileReader();
            reader.onload = function(e) {
                try {
                    var data = new Uint8Array(e.target.result);
                    var workbook = XLSX.read(data, { type: "array" });

                    var firstSheetName = workbook.SheetNames[0];
                    var worksheet = workbook.Sheets[firstSheetName];

                    var jsonData = XLSX.utils.sheet_to_json(worksheet, {header: 1});
                    resolve(jsonData);
                } catch (error) {
                    console.error('Excel parsing error:', error);
                    reject(error);
                }
            };
            reader.readAsArrayBuffer(file);
        });
    },



    // 뭐지?
    // readExcelFile: function (component, file, event) {
    //     return new Promise(function (resolve, reject) {
    //         var reader = new FileReader();
    //         reader.onload = function(e) {
    //             try {
    //                 var data = new Uint8Array(e.target.result);
    //                 var workbook = XLSX.read(data, {type: "array"});

    //                 var firstSheetName = workbook.SheetNames[0];
    //                 var worksheet = workbook.Sheets[firstSheetName];

    //                 var jsonData = XLSX.utils.sheet_to_json(worksheet, {header: 1});
    //                 // component.set('v.excelData', jsonData);
    //                 resolve(jsonData);
    //             }
    //             catch (error) {
    //                 console.log('error message :: ' +error);
    //                 reject(error);
    //             }
    //         }
    //         reader.readAsArrayBuffer(file);
    //     })
    // },

    backOrderInquiry: function (component, event, helper) {
        component.set('v.isLoading', true);
        const navOrderInquiry = component.find("navOrderInquiry");
        const page = {
            type: "standard__webPage",
            attributes: {
                url: "/order-inquiry",
            }
        };
        navOrderInquiry.navigate(page);
        component.set('v.isLoading', false);
    }, 


    addMessageListener: function(component, event) {
        const listener = function(event) {
            // const trustedOrigin = "https://dn-solutions--dev--c.sandbox.vf.force.com";
            const trustedOrigin = 'https://dn-solutions--c.vf.force.com';
            // Validate origin
            if (event.origin !== trustedOrigin) {
                console.error("Untrusted origin:", event.origin);
                return;
            }

            // Process the received data
            const data = event.data;
            console.log("Received data from iframe:", data);

            // Store the received data in an Aura attribute
            component.set("v.receivedData", JSON.stringify(data));
        };

        // Add the message listener
        window.addEventListener("message", listener);

        // Store the listener reference for removal
        component.set("v.messageListener", listener);
    },

    removeMessageListener: function(component) {
        // Retrieve the listener reference
        const listener = component.get("v.messageListener");
        if (listener) {
            // Remove the listener
            window.removeEventListener("message", listener);
            component.set("v.messageListener", null);
        }
    },

    formatPrice : function(price) {
        var num1 = price.split('.')[0];
        var num2 = Number(num1);
        var num3 = num2.toLocaleString();
        return num3;
    },

    fireCompEvent: function(component, modalName, message) {
        let compEvent = component.getEvent("cmpEvent");
        compEvent.setParams({
            modalName: modalName,
            message: message
        });
        compEvent.fire();
        console.log(`${modalName} 이벤트 발생:`, JSON.stringify(message, null, 4));
    },

    excelList : function(component, event, helper) {
        console.log('excelList 추가 시작');
        var initsList = [];

        for (var i = 0; i < 10; i++) {
            var num2 = ((i + 1) * 10);
            var objSelectItem = {
                'hangNumber'     : num2,
                'hang'           : String(num2).padStart(6, '0'), // 항목
                'orderPartNo'    : '',                   // 주문품번
                'supplyPartNo'   : '',                   // 공급풉번
                'partName'       : '',                   // 품명
                'urgency'        : false,                // 긴급도
                'quantity'       : '',                   // 주문 수량
                'salesUnit'      : '',                   // 판매 단위
                'unit'           : '',                   // 단위
                'unitPrice'      : '',                   // 단가
                'partsAmount'    : '',                   // 금액
                'piCurrency'     : '',                   // 통화
                'availableStock' : '',                   // 가용 재고
                'twp'            : '',                   // TWP
                'bulletin'       : '',                   // bullentin
                'note'           : '',                   // note
                'machine'        : '',                   // 기종
                'equipment'      : '',                   // 장비번호

                'orderPartId'    : '',                   // 주문품번 Id
                'supplyPartId'   : '',                   // 공급품번 Id
            };
            initsList.push(objSelectItem);
        }    
        component.set('v.initsList', initsList);
    },

    // DD 250515
    gpesEventListener: function(component, event, helper) {
        console.log('작동');
        // window.addEventListener('message', event);
        window.addEventListener('message', $A.getCallback(function(event) {
            console.log('event        > ' +JSON.stringify(event,null,4));
            console.log('event.origin > ' +JSON.stringify(event.origin,null,4));
            console.log('event.data   > ' +JSON.stringify(event.data,null,4));
        }))
        // window.addEventListener(
        //     'message',
        //     $A.getCallback(function(event) {
        //         console.log('GPES 작동 여부 >>> ' + JSON.stringify(event, null, 4));
        //         console.log('event.origin >>> ' + event.origin);

        //         // 개발 환경 도메인 체크
        //         if (event.origin === 'https://dn-solutions--dev.sandbox.my.site.com') {
        //         // 운영 환경 사용 시 아래 코드 사용
        //         // if (event.origin === 'https://gpes.dn-solutions.com') {
        //             try {
        //                 const data = event.data;
        //                 const parsedData = JSON.parse(data);
        //                 component.set('v.receivedData', parsedData);

        //                 var selectPartsNo = [];
        //                 for (var i = 0; i < parsedData.length; i++) {
        //                     selectPartsNo.push(parsedData[i].partNo);
        //                 }

        //                 component.set('v.selectPartsNo', selectPartsNo);
        //                 component.set('v.isGPESModal', false);

        //                 var partNo = component.get('v.selectPartsNo');
        //                 helper.apexCall(component, 'SearchPartNo', { pn: partNo })
        //                     .then($A.getCallback(function(result) {
        //                         let response = result.r;
        //                         component.set('v.confirmParts', response);
        //                         return helper.searchProduct(component, event, helper);
        //                     }))
        //                     .then($A.getCallback(function(result) {
        //                         // 후속 처리 로직
        //                     }))
        //                     .catch($A.getCallback(function(errors) {
        //                         component.set('v.isLoading', false);
        //                         console.log('error>> ' + JSON.stringify(errors, null, 4));
        //                     }));
        //             } catch (error) {
        //                 component.set('v.isLoading', false);
        //                 console.log('error>> ' + JSON.stringify(error, null, 4));
        //                 helper.toast('ERROR', 'Failed to parse the message.');
        //             }
        //         } else {
        //             console.warn('Unauthorized message origin: ', event.origin);
        //         }
        //     })
        // );
    }
        
    
})