/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-07-09
 * @last modified by  : suheon.ha@sobetec.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-27   yeongdeok.seo@sbtglobal.com   Initial Version
**/
// POListReviewController.js
({
    doInit: function (component, event, helper) {
        component.set('v.isSpinner', true);
        // TEST: 
        // METHOD : getPartInfos >> I/F 으로 자재정보 호출
        // METHOD : init >> I/F x
        helper.apexCall(component, event, helper, 'getPartInfos', {'requestStockMap':helper.gfnGetRequestParam(component)})
             .then($A.getCallback(function (result) {
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            component.set('v.isSpinner', false);
            if(r.status.code === 200 ) {    
                let availableStockSize = r.availableStockList.length
                if(availableStockSize == 0) {
                    helper.toast('Warning', ' 조건에 해당하는 데이터가 없습니다. ');
                    return ;
                }

                component.set('v.dealerStockList', helper.gfnSetStaus(component, r.availableStockList));
            }
            else {
                helper.toast('Warning', r.status.msg);
            }
        }));

        // helper.apexCall(component, event, helper, 'getPartInfos', {'requestStockMap':helper.gfnGetRequestParam(component)}).then($A.getCallback(function (result) {
        //     let { r, state } = result;

        //     console.log('getPartInfos.r : ',  r);
        //     console.log('getPartInfos.state : ',  state);
        //     component.set('v.isSpinner', false);
        //     if(r.status.code === 200 ) {    
        //     }
        //     else {
        //         helper.toast('Warning', ' 관리자한테 문의해주세요. ');
        //     }
        // }));


        // var odList = component.get('v.odList');
        // console.log('odList', JSON.stringify(odList));
        // var resultList = [];

        // odList.forEach(function (od) {
        //     var objList = [];
        //     if (od.MATNR == '110408-00282') {
        //         objList = [
        //             {
        //                 'NAME1': '영진기계',
        //                 'MATNR': od.MATNR,
        //                 'MENGE': od.MENGE,
        //                 'AVQTY': '5',
        //                 'NONQTY': '0',
        //                 'NETPR': '1445320',
        //                 'RATE': '10.00',
        //                 'DISPR': '1300788',
        //                 'REPNR': '110408-00282',
        //                 'DEALER_CD' : '123123',
        //                 'stockStatus': ''
        //             },
        //             {
        //                 'NAME1': '디에스공작기계(주)',
        //                 'MATNR': od.MATNR,
        //                 'MENGE': od.MENGE,
        //                 'AVQTY': '2',
        //                 'NONQTY': '0',
        //                 'NETPR': '1445320',
        //                 'RATE': '5.00',
        //                 'DISPR': '1373054',
        //                 'REPNR': '110408-00282',
        //                 'DEALER_CD' : '123124',
        //                 'stockStatus': ''
        //             }
        //         ];
        //     } else if (od.MATNR == '0456050') {
        //         objList = [
        //             {
        //                 'NAME1': '새우기계',
        //                 'MATNR': od.MATNR,
        //                 'MENGE': od.MENGE,
        //                 'AVQTY': '5',
        //                 'NONQTY': '0',
        //                 'NETPR': '363300',
        //                 'RATE': '10.00',
        //                 'DISPR': '326970',
        //                 'REPNR': '140107-00230',
        //                 'DEALER_CD' : '123125',
        //                 'stockStatus': ''
        //             },
        //             {
        //                 'NAME1': '너구리기계(주)',
        //                 'MATNR': od.MATNR,
        //                 'MENGE': od.MENGE,
        //                 'AVQTY': '2',
        //                 'NONQTY': '0',
        //                 'NETPR': '363300',
        //                 'RATE': '5.00',
        //                 'DISPR': '345135',
        //                 'REPNR': '140107-00230',
        //                 'DEALER_CD' : '123126',
        //                 'stockStatus': ''
        //             }
        //         ];
        //     } else {
        //         objList = [
        //             {
        //                 'NAME1': '영진기계',
        //                 'MATNR': '101565-00030',
        //                 'MENGE': '6',
        //                 'AVQTY': '5',
        //                 'NONQTY': '0',
        //                 'NETPR': '128600',
        //                 'RATE': '10.00',
        //                 'DISPR': '115740',
        //                 'REPNR': '101565-00030',
        //                 'DEALER_CD' : '123123',
        //                 'stockStatus': ''
        //             },
        //             {
        //                 'NAME1': '링엔지니어링',
        //                 'MATNR': '101565-00030',
        //                 'MENGE': '2',
        //                 'AVQTY': '5',
        //                 'NONQTY': '0',
        //                 'NETPR': '128600',
        //                 'RATE': '10.00',
        //                 'DISPR': '115740',
        //                 'REPNR': '101565-00030',
        //                 'DEALER_CD' : '123127',
        //                 'stockStatus': ''
        //             },
        //             {
        //                 'NAME1': '디에스공작기계(주)',
        //                 'MATNR': '101565-00030',
        //                 'MENGE': '2',
        //                 'AVQTY': '1',
        //                 'NONQTY': '0',
        //                 'NETPR': '128600',
        //                 'RATE': '10.00',
        //                 'DISPR': '115740',
        //                 'REPNR': '101565-00030',
        //                 'DEALER_CD' : '123124',
        //                 'stockStatus': ''
        //             },
        //             {
        //                 'NAME1': '명성기계',
        //                 'MATNR': '101565-00030',
        //                 'MENGE': '2',
        //                 'AVQTY': '31',
        //                 'NONQTY': '0',
        //                 'NETPR': '128600',
        //                 'RATE': '10.00',
        //                 'DISPR': '115740',
        //                 'REPNR': '101565-00030',
        //                 'DEALER_CD' : '123128',
        //                 'stockStatus': ''
        //             },
        //             {
        //                 'NAME1': '㈜디씨에스',
        //                 'MATNR': '101565-00030',
        //                 'MENGE': '2',
        //                 'AVQTY': '3',
        //                 'NONQTY': '0',
        //                 'NETPR': '128600',
        //                 'RATE': '10.00',
        //                 'DISPR': '115740',
        //                 'REPNR': '101565-00030',
        //                 'DEALER_CD' : '123129',
        //                 'stockStatus': ''
        //             }
        //         ];
        //     }
        //     resultList.push(...objList);
        // });


        // // 재고보유 상태 요청유량, 가용재고 비교
        // resultList.forEach(function (item) {
        //     item.stockStatus = parseInt(item.AVQTY) >= parseInt(item.MENGE) ? '전체 보유' : '부분 보유';
        // });

        // component.set('v.odsList', resultList);
    },

    otherDealerStockModalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    handleCheckboxChange: function (component, event, helper) {
        helper.updateCheckboxState(component, event);
    },

    selectDealerStock: function (component, event, helper) {
        // let checkboxes = component.find("checkbox");
        let dealerStockList = component.get('v.dealerStockList');
        if(dealerStockList.length == 0) {

            return;
        }
        let selectDealerStock = dealerStockList.filter((dealerStock)=>dealerStock.isSelected);
        let message = {};
        selectDealerStock.forEach(dealerStock=> {
            message[dealerStock.partName] = dealerStock;
        });

        console.log('selectDealerStock', JSON.stringify(selectDealerStock));

        // publish event
        const compEvent = component.getEvent("cmpEvent");
        compEvent.setParams({
            "modalName": 'DN_OtherDealerStockQtyModal',
            "actionName": 'Close',
            message
        });

        compEvent.fire();
        helper.closeModal(component);

    }
})