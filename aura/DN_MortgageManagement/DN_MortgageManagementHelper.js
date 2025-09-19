/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-28
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-10   yuhyun.park@sbtglobal.com   Initial Version
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


    cleanFieldsFormat: function (mortgageDetailList) {

        // console.log('cleanFieldsFormat >> ');

        mortgageDetailList.forEach(function (item) {

            // 날짜 필드 목록
            const dateFields = ['AGR_DATE', 'LEA_DATE', 'ENG_DATE', 'REG_DATE', 'EST_DOC_DAT', 'PLED_DATE', 'CANC_DATE', 'PAGR_DATE', 'STMP_DATE'];

            // 숫자 필드 목록
            const currencyFields = ['AMOUNT', 'EST_AMT', 'PRI_AMT', 'VAL_AMT', 'ESTA_AMT'];

            // 날짜 필드 처리
            dateFields.forEach(function (field) {
                if (item[field] === "0000-00-00") {
                    item[field] = ''; // 빈 값으로 변경
                }
            });

            // 숫자 필드 처리
            currencyFields.forEach(function (field) {
                if (item[field] && !isNaN(item[field])) {
                    // item[field] = Number(item[field]); // 숫자 타입으로 변환
                    item[field] = Number(item[field]) * 100;
                }
            });

        });

        return mortgageDetailList;
    },





    // 한글화된 필드명으로 변환
    convertToKoreanFieldNames: function (mortgageDetailList) {
        return mortgageDetailList.map(function (item) {
            return {
                "딜러명": item.NAME1,
                "대표자": item.J_1KFREPRE,
                "제공자": item.PROVIDER,
                "소유자": item.OWNER,
                "담보구분": item.MORT_TEXT,
                "담보크기": item.MORTSIZE,
                "담보상세": item.ADD_DATA,
                "담보평가문서": item.EST_DOC_DAT,
                "등록일": item.REG_DATE,
                "설정계약서": item.ENG_DATE,
                "동의서": item.AGR_DATE,
                "임대차확인서": item.LEA_DATE,
                "임감증명": item.STMP_DATE,
                "질권설정서": item.PLED_DATE,
                "질권동의서": item.PAGR_DATE,
                "만기일": item.DUE_DATE,
                "감정가": item.EST_AMT,
                "선순위": item.PRI_AMT,
                "유효가치": item.VAL_AMT,
                "설정액": item.ESTA_AMT,
                "통화": item.WAERS,
                "순위": item.ESTA_RANK,
                "선순위내역": item.PRI_INFO,
                "담보금액": item.AMOUNT,
                "취소날짜": item.CANC_DATE,
                "대체담보": item.ALT_MNGNO,
                "대체담보상세": item.ALT_INFO
            };
        });
    }


})