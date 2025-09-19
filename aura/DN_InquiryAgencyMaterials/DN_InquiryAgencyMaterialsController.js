/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 12-26-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        
        component.set('v.currentUrl', location.href);
        //window.history.pushState({ query: 'initialState' }, '', location.href);
        history.replaceState({page: 'init'}, '', location.href);
        window.onpopstate = function(event) {
            try {
                console.log(event.state.query,' ::: event.state.query');
                if (event.state && event.state.query) {
                    // 이전 검색 상태 복원
                    if(event.state.query) {
                        new Promise((resolve, reject) => {
                            component.set('v.inputPart',event.state.query);
                            // let inputCmpAll  = component.find(`productCode`);
                            //inputCmpAll.handleCmpValue(event.state.query);
                            resolve();
                        }).then(() => {
                            //document.querySelector("form").requestSubmit();
                            helper.handleSearch(component, event, helper,'preview');    
                        });
                    }
                } 
                console.log(component.get('v.currentUrl'),' testst');
                console.log(location.href,' location.href');
                // 검색정보 초기화
                if(event.state.query ==undefined) {
                    component.set('v.ifData', null) //performance //dealerStock
                    component.set('v.performance', null);
                    component.set('v.dealerStock', {});
                    component.set('v.prodByPlant',null)
                    component.set('v.mpps', null);
                    component.set('v.mppsData', null);
                    component.set('v.otherDealerStockList',[]);
                    component.set('v.inputPart', '');
                    // let inputCmpAll  = component.find('productCode');
                    // //console.log('단일 요소입니다:', inputCmpAll);
                    // inputCmpAll.handleClear();
                }
                if(component.get('v.currentUrl') !=location.href) {
                    window.onpopstate = null;    
                    window.location.href = location.href;
                }
            } catch (error) {
                console.log(error, ' error');
                if(component.get('v.currentUrl') !=location.href) {
                    window.onpopstate = null;    
                    window.location.href = location.href;
                }
            }
            
        };

        var today = new Date();
        component.set('v.printDate', today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate());
        component.set('v.isLoading', true);
        component.set('v.filter', {
            'fieldApiName' : 'productCode',
            'parentFieldApiName' : '',
            'fieldType' : 'Lookup',
            'isRequired' : 'false'
        })
        helper.apexCall(component, event, helper, 'getCurrentAgency', {})
        .then($A.getCallback(function(result) {
            let r = result.r;
            component.set('v.errorMSG','');
            component.set('v.currentUser', r);
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            //console.log(JSON.stringify(error),' < ===error');
            component.set('v.isLoading', false);
        })
        //getCurrentAgency
    },
    
    doDestroy : function(component, event, helper) {
        //window.onpopstate = null;    
        //window.location.href = location.href;
    },

    handleCopy : function(component, event, helper) {
        new Promise((resolve) => {
            // let inputCmpAll  = component.find('productCode');
            // let partNumber = inputCmpAll.getInputValue();
            component.get('v.inputPart');
            resolve();
        }).then(() => {
            const element = component.find("copyTarget").getElement();
            const cloned = element.cloneNode(true);
             // "무시할" 요소들 제거
            cloned.querySelectorAll(".copy-ignore").forEach(el => el.remove());
            const html = cloned.innerHTML;
            const listener = function(e) {
                e.clipboardData.setData("text/html", html);
                e.clipboardData.setData("text/plain", html.replace(/<[^>]+>/g, "")); // 단순 텍스트 fallback
                e.preventDefault();
            };
            document.addEventListener("copy", listener);
            document.execCommand("copy");
            document.removeEventListener("copy", listener);
            helper.toast('success', '복사되었습니다.');
        });
    },

    // 대리점 자재 종합 조회 검색
    handleSearch : function(component, event, helper, type) {
        //document.querySelector("form").requestSubmit();
        helper.handleSearch(component, event, helper, '');
        
        
    },

    // 부품번호 Modal 띄우기
    openSearchProductNumber : function(component, event, helper) {
        $A.createComponent("c:DN_SearchProductNumber",
            {
                "type" : "부품번호"
            },
            function(content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("SearchProductNumber");
                    container.set("v.body", content);
                }else if (status === "INCOMPLETE") {
                    //console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    //console.log("Error: " + errorMessage);
                }
            }
        );
    },
    
    // Event에서 값 받아오기
    handleCompEvent : function(component, event, helper) {
        var modalName = event.getParam("modalName");
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");

        //console.log('modalName', modalName);
        //console.log('actionName', actionName);
        //console.log('message', message);
        new Promise((resolve) => {
            component.set('v.partsNumber', message.ProductCode);
            component.set('v.errorMSG', '');
            resolve();
        }).then(() => {
            if(message.ProductCode !=null) {
                component.set('v.isLoading', true);
                let partList = [{
                    'MATNR' : message.ProductCode, 
                }];
                component.set('v.inputPart',message.ProductCode);
                //helper.setInputValue(component, partList, 'productCode');
                //document.querySelector("form").requestSubmit();
                helper.handleSearch(component, event, helper, '');
                // let action = component.get('c.handleSearch');
                // $A.enqueueAction(action);
            }
        });
    },

    //부품번호 값 지우기
    clearPartsNumber: function (component, event, helper) {
        let partsNumber = component.get("v.inputPart");
        if (!partsNumber) {
            helper.toast("WARNING", "저장된 부품번호 값이 없습니다."); 
            return;
        }
        component.set("v.partsNumber", "");
        component.set('v.inputPart', '');
        // let inputCmpAll  = component.find('productCode');
        // //console.log('단일 요소입니다:', inputCmpAll);
        // inputCmpAll.handleClear();
        
    },

    // 저장
    handleSave : function(component, event, helper) {
        //console.log(Object.keys(component.get('v.dealerStock')).length);
        
        let inputCmpAll  = component.find('productCode');
        if (!component.get('v.dealerStock') || Object.keys(component.get('v.dealerStock')).length === 0) {
            helper.toast('ERROR', '현재 대리점에서 관리하는 부품의 재고가 없습니다.');
        } else {
            if(component.get('v.dealerStock').Part__r.ProductCode !=component.get('v.inputPart', '')) {
                helper.toast('ERROR', '해당 부품을 조회 후 저장하세요.');//해당 부품은 대리점의 재고에 없습니다.
                return ;
            }

            let dealerStock = component.get('v.dealerStock');
            if(dealerStock.CurrentStockQuantity__c <dealerStock.BlockQuantity__c) {
                helper.toast('ERROR', 'Block 수량은 창고재고 수량보다 많이 입력할 수 없습니다.');
                return;
            }
            component.set('v.isLoading', true);
            let dealerSet = {
                Id : component.get('v.dealerStock').Id,
                BlockQuantity__c : component.find('BlockQuantity__c').get('v.value'),
                Note__c : component.find('Note__c').get('v.value')
            };
            
            component.set('v.saveDealerStock', dealerSet);
            helper.apexCall(component, event, helper, 'stockSave', {
                stock : component.get('v.saveDealerStock')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                component.set('v.dealerStock',r);
                helper.toast('SUCCESS', '저장되었습니다.');
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                //console.log(JSON.stringify(error),' < ===error');
                if(error.length > 0) {
                    helper.toast('ERROR', error[0].message);
                    
                } else {
                    helper.toast('ERROR', 'An error occurred, please contact your administrator.');
                }
                component.set('v.isLoading', false);
            })
        }
    },
    // 프린트
    handlePrint : function(component, event, helper) {
        let stock = component.get('v.dealerStock');
        console.log(JSON.stringify(stock), ' ::::stock');
        let partNumber = component.get('v.inputPart');
        if(stock !=null) {
            let qty = component.get('v.printQty');
            let printDate = component.get('v.printDate');
            component.set('v.openUrl', `/s/DealerPortalPrintView?c_record=${partNumber}&c_qty=${qty}&c_type=대리점자재종합조회&c_printDate=${printDate}`);
            helper.handleprint(component);
        } else {
            helper.toast('ERROR', '부품 번호를 검색 후 출력해주세요');
        }
        
    },

    //MPPS 확장 기능
    handleMpps : function(component, event, helper) {
        component.set('v.isLoading', true);
        // let partNumber ='';
        //let inputCmpAll  = component.find('productCode');
        let partNumber = component.get('v.inputPart');//inputCmpAll.getInputValue();
        //console.log(inputCmpAll.getInputValue(), ' test111');
        helper.apexCall(component, event, helper, 'insertMpps', {
			productCode : partNumber
        })
        .then($A.getCallback(function(result) {
            helper.toast('success', '확장되었습니다.');
            document.querySelector("form").submit();
            helper.handleSearch(component, event, helper, '');
            // let action = component.get('c.handleSearch');
            // $A.enqueueAction(action);
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            //console.log(JSON.stringify(error),' < ===error');
            if(error.length > 0) {
                helper.toast('ERROR', error[0].message);
                //$A.get('e.force:refreshView').fire();
            } else {
                helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            }
            component.set('v.isLoading', false);
        })
    },

    // GPES열기
    handleGPES : function(component, event, helper) {
        // Apex URL 설정 //https://dn-solutions--dev.sandbox.my.salesforce.com
        //let apexPageURL = 'https://dn-solutions--dev.sandbox.my.site.com/partners/apex/IF_GPES_T';//https://dn-solutions--dev--c.sandbox.vf.force.com
        let apexPageURL = $A.get("$Label.c.DN_VfPage") +'/apex/IF_GPES_T';

        //let partsNumber; //         = component.get('v.partsNumber');
        //let inputCmpAll  = component.find('productCode');
        let partsNumber =component.get('v.inputPart'); //inputCmpAll.getInputValue();
        //console.log('GPES partsNumber : ', partsNumber);
        if(partsNumber) {
            apexPageURL += `?type=partinfo&part_no=${partsNumber}`;
        }
        

        component.set('v.apexPageURL', apexPageURL);
        component.set('v.isGPESModal', true);
    },
    // 모달 닫기
    closeModal : function(component, event, helper) {
        component.set('v.isGPESModal', false);
    },

    // Block 수량 벨리데이션
    handleValue : function(component, event, helper) {
        let regex = /^[0-9]*$/; 
        let value = event.getSource().get("v.value");
        if (!regex.test(value)) {
            let matchedValue = value.match(/^[0-9]*/);
            
            if (matchedValue) {
                value = matchedValue[0]; // 첫 번째 매칭된 값 사용
            } else {
                value = 0; // 숫자가 없으면 빈 값으로 설정
            }

            event.getSource().set("v.value", value); // 수정된 값 반영
        }
    },


    handleInputChange: function (component, event, helper) {
        let errorValue = '';
        if(event.getParam('eventType') =='ENTER') {
            component.set('v.isLoading', true);
            new Promise((resolve) => {
                let value = event.getParam('value'); 
                let matnr = event.getParam('label'); 
                let index = event.getParam('index');  
                component.set('v.partsNumber',matnr);
                
                //console.log(matnr + ' :: 자재종합조회 matnr');
                //console.log(value + ' :: 자재종합조회 value');
                 
                resolve();
            }).then($A.getCallback(function(result) {
                //console.log(' then!!!');
                if(errorValue !='') {
                    helper.toast('error', errorValue);
                    
                } else {
                    if(!component.get('v.isEnter')) {
                        component.set('v.isEnter', true);
                        component.set('v.isLoading', true);//handleBlur
                        //document.querySelector("form").requestSubmit();
                        helper.handleSearch(component, event, helper, '');
                        // let action = component.get('c.handleSearch');
                        // $A.enqueueAction(action, false);
                        component.find('productCode').handleBlur();
                    }
                }
            }))
        } else {
            //console.log('input change CMP');
            let value = event.getParam('value'); 
            let matnr = event.getParam('label'); 
            let index = event.getParam('index');  
            component.set('v.partsNumber',matnr);
            // if(value == '') {
            //     errorValue = '부품번호의 입력값이 올바르지 않습니다.';
                
            // }
            // component.set('v.errorMSG', errorValue); 
        }
    },
    handleValueChange: function (component, event, helper) {
        let inputValue = event.getSource().get("v.value");
        let upperValue = inputValue.toUpperCase();
        upperValue = upperValue.trim();
        console.log(upperValue,' ::: upperValue');
        component.set("v.inputPart", upperValue);
    },


    handleKeyUp: function (component, event, helper) {
        if(component.get('v.isEnter')) {
            return;   
        }
        if(event.key === 'Enter') {
            component.set('v.isEnter', true);
            //document.querySelector("form").requestSubmit();
            helper.handleSearch(component, event, helper,'');
        }
        
        
    },
    handleKeydown: function (component, event, helper) {
        if(component.get('v.isEnter')) {
            return;   
        }
        console.log("enter");
        console.log("Pressed KeyCode:", event.keyCode);
        console.log("Pressed Key:", event.key);
        
        if(event.key === 'Enter') {
            component.set('v.isEnter', true);
            //document.querySelector("form").requestSubmit();
            helper.handleSearch(component, event, helper,'');
        }
    },

})