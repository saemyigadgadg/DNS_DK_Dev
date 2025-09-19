({
    doInit: function (component, event, helper) {
      console.log('doInit');
        
    },

    handleScriptsLoaded: function(component, event, helper) {
        console.log('ExcelJS loaded successfully.');
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(`${component.getName()}.setSubscriptionLMC`);
            console.log(JSON.stringify(message));
            console.log(JSON.stringify(params));
            console.log(params.type);
            switch (params.type) {
                case 'filterChange' :
                case 'defaultFilter':
                    console.log(params.type);
                    let headerParams = component.get('v.headerParams');
                    if(!!!headerParams) headerParams = {};
                    let isArray = Array.isArray(params.message);
                    if(isArray) {
                        [...params.message].forEach((headerParam)=>{
                            headerParams[headerParam.field] = headerParam.value;
                            if(headerParam.field == 'productCode') {
                                headerParams['productLabel'] = headerParam.label;
                            }
                        });
                    } else {
                        headerParams[params.message.field] = params.message.value;
                        if(params.message.field == 'productCode') {
                            headerParams['productLabel'] = params.message.label;
                        }
                    }
                    console.log('headerParamsheaderParams'+headerParams);
                    component.set('v.headerParams', headerParams);
                    break;
                case 'Seach':
                    
                    component.set('v.resultList',[]);
                    component.set('v.grSum1','');
                    component.set('v.grSum2','');
                    component.set('v.grSum3','');
                    component.set('v.grSum4','');
                    component.set('v.grSum5','');
                    component.set('v.grSum6','');
                    component.set('v.grSumAll','');
                    component.set('v.giSum1','');
                    component.set('v.giSum2','');
                    component.set('v.giSum3','');
                    component.set('v.giSum4','');
                    component.set('v.giSum5','');
                    component.set('v.giSum6','');
                    component.set('v.giSumAll','');
                 
                    helper.searchGRGIList(component,'Search');
                    break;
                case 'ExcelDownload':
                    helper.downloadExcel(component);
                    break;
                default:
                    break;
            }  
            
        }
    },

    openDetailInfoModal: function (component, event, helper) {
        var index = event.target.value;
        var resultList = component.get('v.resultList');
        var docNo = resultList[index].giDocNumber;
        var navService = component.find("navService");
        var recordId;
        var pageReference;
        console.log('resultList[index]', JSON.stringify(resultList[index]));

        if (docNo.startsWith('C5') ||   docNo.startsWith('C6') || docNo.startsWith('C7')
            || docNo.startsWith('5') || docNo.startsWith('6') || docNo.startsWith('7')
         ) {
                console.log('ffff');
                var type = resultList[index].reordType;
                recordId = docNo;
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
        } else if (
            docNo.startsWith('C8')|| docNo.startsWith('C9')
            || docNo.startsWith('8')|| docNo.startsWith('9')
        ) {
            console.log('windowopen');

            navService = component.find("navService");
            pageReference = {
                type: "standard__recordPage",
                attributes: {
                    recordId: resultList[index].orderId,
                    actionName: 'view',
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

    openDetailInfoModal2: function (component, event, helper) {
        var index = event.target.value;
       
        var resultList = component.get('v.resultList');
        var docNo = resultList[index].refDocNumber;
        var navService = component.find("navService");
        var pageReference;
        var recordId='';
        var isDnS = resultList[index].searchDtFileter;
        console.log('resultList[index]', JSON.stringify(resultList[index]));
        console.log('docNo', docNo);
        /*
            c5-c6 입출고내역
            c7 대리점구매상세 || DNS구매는 OrderDetail화면 c4
            c8 주문서 번호   //주문상세
            무상출고 HW-> claim wjdqh
            c4 OrderDetail화면
            'S2' 'DNS구매'
            'H2' 'DNS반품'
            ---------------
            'S1' '대리점구매'
            'H1' '대리점구매반품'
            -------------------
            'SW' '무상출고취소'
            'HW' '무상출고'
            -------------------
            'HS' '주문서출고'
            'SS' '주문서반품' 
            ------------------
            'S3' '기타입고'
            'SO' '기타출고취소'
            'H3' '기타입고취소'
            'HO' '기타출고'

           
        */
        console.log(docNo);
        console.log(isDnS);
        switch (isDnS) {
            case 'S1': //대리점 구매
            case 'H1': //대리점 구매반품
                console.log(docNo);
                recordId =resultList[index].delerOId;
                console.log(recordId);
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
                // window.open(`${openUrl}`, `대리점주문상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); 
                break;
            case 'S2': //DNS 구매 주문 ;
            case 'H2': //DNS 구매 주문 반품;
               // recordId = resultList[index].dnsBuyId;//DNS 구매 주문 번호;;
                console.log('DNS 구매 주문');
                console.log(docNo);
                $A.createComponent("c:DN_PurchaseOrderDetail",
                    {
                        "partOrderNo": docNo
                    },
                    function (content, status, errorMessage) {
                        if (status === "SUCCESS") {
                            var container = component.find("PurchaseOrderDetail");
                            container.set("v.body", content);
                        } else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.");
                        } else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                        }
                    }
                );
                // $A.createComponent("c:DN_PurchaseOrderDetail",
                //     {
                //         "partOrderNo" : docNo,
                //         "Type"        : 'OrderInquiry'
                //     },
                //     function (content, status, errorMessage) {
                //         if (status === "SUCCESS") {
                //             //component.set('v.isLoading', false);
                //             var container = component.find("PurchaseOrderDetail");
                //             container.set("v.body", content);
                //         } else if (status === "INCOMPLETE") {
                //             console.log("No response from server or client is offline.");
                //         } else if (status === "ERROR") {
                //             console.log("Error: " + errorMessage);
                //         }
                //     }
                // );
                break;
            case 'HW':
            case 'SW':
                console.log('무상출고 Claim화면');

                if(docNo.startsWith('C6') || docNo.startsWith('6') ) {
                    
                    return;
                }

                let payload = {
                    uuid : component.get('v.uuid'),
                    type : 'CustomModalOverlay',
                    message : {
                        param : `warrantySeq=${docNo}`,
                        modalName:'DN_WarrantyDetails',
                        headerLabel:'Claim 정보'
                    }
                };
        
                component.find("dealerPortalLMC").publish(payload);
                break;
            case 'HS':
            case 'SS':
                console.log('windowopen');

                pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: resultList[index].orderId,
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
                var type = resultList[index].reordType;
                recordId = resultList[index].refDocNumber;
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
        //     var type = resultList[index].reordType;
        //     recordId = resultList[index].refDocNumber;
        //     console.log(recordId + type);
        //     $A.createComponent("c:DN_GRGIDetailModal",
        //         {
        //             'type': type,
        //             'docNo' : recordId
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
        // } else if (docNo.startsWith('C8')) {
        //     console.log('windowopen');

        //     pageReference = {
        //         type: "standard__recordPage",
        //         attributes: {
        //             recordId: resultList[index].orderId,
        //             actionName: 'view',
        //         }
        //     };
        //     console.log('Page Reference:', pageReference);
        //     navService.generateUrl(pageReference).then(function(url) {
        //         window.open(`${url}`, `주문서 상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); // 새 창에서 열기
        //     }).catch(function(error) {
        //         console.log("Error generating URL: " + error);
        //     });
        // } else if (docNo.startsWith('C4')){
        //     console.log('docNo.startsWith(C4)');
        //     recordId =resultList[index].delerOId;
        //     console.log(recordId);
        //     var openUrl = `/partners/s/dealerpurchaseorder/${recordId}`;
        //        window.open(`${openUrl}`, `대리점주문상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); 
        // } else{
        //     switch (isDnS) {
        //         case 'S2': //DNS 구매 주문 번호;;
        //         case 'H2': //DNS 구매 주문 번호;;
        //             recordId = resultList[index].dnsBuyId;//DNS 구매 주문 번호;;
        //             $A.createComponent("c:DN_PurchaseOrderDetail",
        //                 {
        //                     "PartOrderNo" : recordId,
        //                     "Type"        : 'OrderInquiry'
        //                 },
        //                 function (content, status, errorMessage) {
        //                     if (status === "SUCCESS") {
        //                         component.set('v.isLoading', false);
        //                         var container = component.find("PurchaseOrderDetail");
        //                         container.set("v.body", content);
        //                     } else if (status === "INCOMPLETE") {
        //                         console.log("No response from server or client is offline.");
        //                     } else if (status === "ERROR") {
        //                         console.log("Error: " + errorMessage);
        //                     }
        //                 }
        //             );  
        //             break;
        //         case 'HW':
        //         case 'SW':
        //             console.log('무상출고 Claim화면');
        //             let payload = {
        //                 uuid : component.get('v.uuid'),
        //                 type : 'CustomModalOverlay',
        //                 message : {
        //                     param : `warrantySeq=${docNo}`,
        //                     modalName:'DN_WarrantyDetails',
        //                     headerLabel:'Claim 정보'
        //                 }
        //             };
            
        //             component.find("dealerPortalLMC").publish(payload);
        //             break;
        //         default:
        //             let recordId =resultList[index].delerOId;
        //             var openUrl = `/partners/s/dealerpurchaseorder/${recordId}`;
        //                window.open(`${openUrl}`, `대리점주문상세`, `top=10, left=10, width=1000, height=1000, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`); 
        //             break;
        //     }
        // } 
    },
    handleScroll : function(component, event, helper) {          
        var table2 = event.target; 
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();        
        table1.scrollTo({top:scrollY, left:0, behavior:'auto'});
    },
    
})