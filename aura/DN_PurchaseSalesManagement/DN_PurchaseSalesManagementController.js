/**
 * @author            : Jun-Yeong Choi
 * @description       : 
 * @last modified on  : 2024-07-11
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   2024-06-18   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        console.log('Do Init');
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(`${component.getName()}.setSubscriptionLMC`);
            console.log(JSON.stringify(message));
            console.log(JSON.stringify(params.cmpName));
            switch (params.cmpName) {
                case 'dN_DealerPortalFilter':
                    if(params.type ==='filterChange' || params.type === 'defaultFilter') {
                        let headerParams = component.get('v.headerParams');
                        if(!!!headerParams) headerParams = {};
                        console.log(params.type);
                        console.log('type : filterChange');
                        console.log(params);
                        console.log(params.message.label);
                        console.log(params.message.value);
                       
                        //helper.getDetailTypeItem(component, params.message.label, params.message.value);
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
                    break;
                    
                case 'dN_DealerPortalButton':
                    if(params.type === 'Seach') {
                        console.log('매입매출 Seach');
                        component.set('v.psList',[]);
                        component.set('v.psCount','');
                        component.set('v.salCount','');
                        component.set('v.psTotal','');
                        component.set('v.salTotal','');
                        helper.forListSettup(component, null, 'Search');
                    }
                    if(params.type === 'ExcelDownload') {
                        console.log('매입매출 ExcelDownload');
                        helper.downloadExcel(component, null, 'downloadExcel');
                    }
                    break;
                
                case 'dN_DealerPortalQueryPage':
                    console.log('no need');
                    break;  
            }
        }
    },
   
    //문서정보
    openDetailInfoModal: function (component, event, helper) {
        var index = event.target.value;
        var psList = component.get('v.psList');
        var docNo = psList[index].giDocNumber;
        var navService = component.find("navService");
        var pageReference;
        console.log('index', index);
        console.log('psList[index]', JSON.stringify(psList[index]));
        console.log('docNo', docNo);
    
        if (docNo.startsWith('C5') || docNo.startsWith('C6') || docNo.startsWith('C7')
            || docNo.startsWith('5') || docNo.startsWith('6') || docNo.startsWith('7')
         ) {
            console.log('ffff');
            var type = psList[index].reordType;
            
            $A.createComponent("c:DN_GRGIDetailModal",
                {
                    'type': type,
                    'docNo' : docNo
                },
                function (content, status, errorMessage) {
                    if (status === "SUCCESS") {
                        var container = component.find("grgiDetailModal");
                        container.set("v.body", content);
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        } else if (docNo.startsWith('C8') || docNo.startsWith('8')) {
            console.log('windowopen');

            navService = component.find("navService");
            pageReference = {
                type: "standard__recordPage",
                attributes: {
                    recordId: psList[index].orderId,
                    actionName: 'view',
                },
                state: {
                    c_type:'readOnly'
                }
            };
            console.log('Page Reference:', pageReference);
            navService.generateUrl(pageReference).then(function(url) {
                window.open(`${url}`, `주문서 상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); // 새 창에서 열기
            }).catch(function(error) {
                console.log("Error generating URL: " + error);
            });
        } else {
        console.log('doc else');
        
        }
    },
    
    openDetailInfoModal2 : function(component, event, helper) {
        //참고문헌
        //S1 -> 대리점 구매내역
        //S2 -> DNS오더 오더상세
        //
        // //무상출고일때 팝업없음 HW
        var index = event.target.name;
        var psList = component.get('v.psList');
        var docNo = psList[index].refDocNumber;
        var recordId ='';
        var navService = component.find("navService");
        var pageReference;
        var isDnS =psList[index].inventoryChange+psList[index].recordDetail;
        console.log('psList[index]', JSON.stringify(psList[index]));
        console.log('docNo', docNo);
        console.log(isDnS);
        /*
            c5-c6 입출고내역
            c7 대리점구매상세 || DNS구매는 OrderDetail화면
            c8 주문서 번호   //주문상세
            c4 OrderDetail화면
        */
        switch (isDnS) {
            case 'S1':
            case 'H1':
                recordId =psList[index].delerOId;
                pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        recordId,
                        actionName: 'view',
                    },
                    state: {
                        c_type:'readOnly'
                    }
                };
                console.log('Page Reference:', pageReference);
                navService.generateUrl(pageReference).then(function(url) {
                    window.open(`${url}`, `대리점주문상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); // 새 창에서 열기
                }).catch(function(error) {
                    console.log("Error generating URL: " + error);
                });
                // var openUrl = `/partners/s/dealerpurchaseorder/${recordId}`;
                //     window.open(`${openUrl}`, `대리점주문상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); 
                break;
            case 'S2': //DNS 구매 주문 번호;;
            case 'H2':
                console.log('DNS');
                //recordId = psList[index].docNo;//DNS 구매 주문 번호;
                console.log(docNo);
                $A.createComponent("c:DN_PurchaseOrderDetail",
                    {
                       "partOrderNo" : docNo
                       ,"Type"        : 'OrderInquiry'
                    },
                    function (content, status, errorMessage) {
                        if (status === "SUCCESS") {
                            component.set('v.isLoading', false);
                            var container = component.find("PurchaseOrderDetail");
                            container.set("v.body", content);
                        } else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.");
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
                break;
            case 'HW':
                console.log('무상출고는 팝업없음!!');
                break;
            case 'HS':
            case 'SS':
                console.log('windowopen');

                pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: psList[index].orderId,
                        actionName: 'view',
                    },
                    state: {
                        c_type:'readOnly'
                    }
                };
                console.log('Page Reference:', pageReference);
                navService.generateUrl(pageReference).then(function(url) {
                    window.open(`${url}`, `주문서 상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); // 새 창에서 열기
                }).catch(function(error) {
                    console.log("Error generating URL: " + error);
                });
                break;
            default:
                var type = psList[index].reordType;
                recordId = psList[index].refDocNumber;
                console.log(recordId + type);
                $A.createComponent("c:DN_GRGIDetailModal",
                    {
                        'type': type,
                        'docNo' : recordId
                    },
                    function (content, status, errorMessage) {
                        if (status === "SUCCESS") {
                            var container = component.find("grgiDetailModal");
                            container.set("v.body", content);
                        } else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                        } else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    }
                );
                break;
        } 

        // if (docNo.startsWith('C5') || docNo.startsWith('C6')) {
        //     var type = psList[index].reordType;
        //     docNo = psList[index].refDocNumber;
        //     $A.createComponent("c:DN_GRGIDetailModal",
        //         {
        //             'type': type,
        //             'docNo' : docNo
        //         },
        //         function (content, status, errorMessage) {
        //             if (status === "SUCCESS") {
        //                 var container = component.find("grgiDetailModal");
        //                 container.set("v.body", content);
        //             } else if (status === "INCOMPLETE") {
        //                 console.log("No response from server or client is offline.")
        //             } else if (status === "ERROR") {
        //                 console.log("Error: " + errorMessage);
        //             }
        //         }
        //     );
        // } else if (docNo.startsWith('C8')|| docNo.startsWith('C9')) {
        //     console.log('windowopen');

        //     pageReference = {
        //         type: "standard__recordPage",
        //         attributes: {
        //             recordId: psList[index].orderId,
        //             actionName: 'view',
        //         }
        //     };
        //     console.log('Page Reference:', pageReference);
        //     navService.generateUrl(pageReference).then(function(url) {
        //         window.open(`${url}`, `주문서 상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); // 새 창에서 열기
        //     }).catch(function(error) {
        //         console.log("Error generating URL: " + error);
        //     });
        // } else if (docNo.startsWith('C7')){
           
        //     let recordId =psList[index].delerOId;
        //     var openUrl = `/partners/s/dealerpurchaseorder/${recordId}`;
        //         window.open(`${openUrl}`, `대리점주문상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); 

        // } else {
        //     console.log(isDnS);
           
        //}
    },
    handleScriptsLoaded: function (component, event, helper) {
        console.log('SheetJS Loading');
    },
    
})