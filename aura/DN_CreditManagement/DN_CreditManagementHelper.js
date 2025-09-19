/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-21
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-17   yuhyun.park@sbtglobal.com   Initial Version
**/
({

    apexCall: function (component, event, helper, methodName, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            let action = component.get('c.' + methodName);

            if (typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({ 'c': component, 'h': helper, 'r': response.getReturnValue(), 'state': response.getState() });
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },


    cleanFieldsFormat: function (creditDetailList) {
        // console.log('cleanFieldsFormat >> ');
        creditDetailList.forEach(function (item) {

            // 날짜 필드 목록
            const dateFields = ['FKDAT'];

            // 숫자 필드 목록
            const currencyFields = ['NETWR', 'CLAMT', 'AVGAR', 'FBAMT', 'MRAMT'];
            // const currencyFields = ['MTAMT', 'EVAMT', 'LMAMT', 'TCAMT', 'ICAMT', 'RCLAT', 'NETWR', 'CLAMT', 'AVGAR', 'FBAMT', 'MRAMT'];


            // 날짜 필드 처리
            dateFields.forEach(function (field) {
                if (item[field] === "0000-00-00") {
                    item[field] = ''; // 빈 값으로 변경
                }
            });

            // 숫자 필드 처리
            currencyFields.forEach(function (field) {
                if (item[field] && !isNaN(item[field])) {
                    item[field] = Number(item[field]); // 숫자 타입으로 변환
                }
            });



        });

        return creditDetailList;
    },

    multipleCurrency: function (creditSummary){
        creditSummary.forEach(function (item){

            //  *100 처리 필드 목록
            const multiply100Fields = ['EVAMT'];

            // *100
            multiply100Fields.forEach(function(field) {
                if (item[field] && !isNaN(item[field])) {
                    item[field] = Number(item[field]) * 100;
                }
            });
        });    

        return creditSummary;
    
    },


    // 한글화된 필드명으로 변환
    convertToKoreanFieldNames: function (creditDetailList) {
        return creditDetailList.map(function (item) {
            return {
                "지불인":       item.NAME1,
                "대표자":       item.J_1KFREPRE,
                "계약번호":     item.VBELN_VA,
                "판매번호":     item.VBELN_VF,
                "청구일":       item.FKDAT,
                "매출액":       item.NETWR,
                "수금금액":     item.CLAMT,
                "매출채권":     item.AVGAR,
                "캐피탈 AR":    item.FBAMT,
                "담보채권":     item.MRAMT,
            };
        });
    }



})