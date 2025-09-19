/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-09-10
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-05-29   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    searchPartsModalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    handleScriptsLoaded: function () {
        console.log('ExcelReady');
    },

    downloadExcel: function (component, event, helper) {
        try {
            var replacementList = component.get('v.replacementList');
            // sheetJS 라이브러리 사용 workbook 생성
            var wb = XLSX.utils.book_new();

            var resultList = component.get('v.replacementList');

            const reorderedList = replacementList.map(item => {
                return {
                    MATNR: item.MATNR,
                    MAKTX: item.MAKTX,
                    AVA_FLAG: item.AVA_FLAG
                };
            });

            // 데이터를 생성.
            var excelData = [];
            var sheetName = 'substitution_part_list';


            var header = ['부품번호', '품명', '재고유무'];
            var headerStyles = {
                font: {
                    name: '맑은 고딕',
                    bold: true,
                    color: { rgb: "000000" }
                },
                // fill: { 
                //     fgColor: { rgb: "F3F3F3" } 
                // },
                alignment: {
                    vertical: "center",
                    horizontal: "center"
                },
                border: {
                    top: { style: 'thin', color: { rgb: '000000' } },
                    bottom: { style: 'thin', color: { rgb: '000000' } },
                    left: { style: 'thin', color: { rgb: '000000' } },
                    right: { style: 'thin', color: { rgb: '000000' } }
                }
            };

            // 헤더에 스타일 적용
            var headerRow = header.map(item => ({ v: item, s: headerStyles }));
            excelData.push(headerRow);
            console.log('headerRow : '+ JSON.stringify(headerRow,null,4));
            console.log('excelData : '+ JSON.stringify(excelData,null,4));

            for (let i = 0; i < reorderedList.length; i++) {
                excelData.push(Object.values(reorderedList[i]));
                console.log('excelData : '+ i +'__'+ JSON.stringify(excelData,null,4));
                console.log('reorderedList[i] : '+ JSON.stringify(reorderedList[i],null,4));
            }

            // 워크시트를 생성하고 데이터를 추가합니다.
            var ws = XLSX.utils.aoa_to_sheet(excelData);
            console.log('ws :: ' + ws)
            console.log('ws :: ' + JSON.stringify(ws,null,4))
            // 워크북에 워크시트를 추가합니다.
            XLSX.utils.book_append_sheet(wb, ws, sheetName);

            // 엑셀 파일을 생성하고 다운로드합니다.
            var wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'binary' });

            function s2ab(s) {
                var buf = new ArrayBuffer(s.length);
                var view = new Uint8Array(buf);
                for (var i = 0; i < s.length; i++) view[i] = s.charCodeAt(i) & 0xFF;
                return buf;
            }

            var blob = new Blob([s2ab(wbout)], { type: "application/octet-stream" });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'substitution_part_list.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } catch (error) {
            console.log('에러 내역 알려주세요 ::: ' + error);
            console.log('에러 내역 알려주세요 ::: ' + error.message);
        }
    },

    // 입력값 처리
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },

    searchParts : function (component, event, helper) {
        component.set('v.isLoading', true);
        var partCode = component.get('v.partCode');
        var partName = component.get('v.partName');

        console.log('bf partCode :::' + partCode);
        console.log('bf partName :::' + partName);

        // 입력값 검증 함수
        if ((!partCode || partCode.trim() == '') && (!partName || partName.trim() == '')) {
            helper.toast('WARNING', $A.get("$Label.c.BPI_E_MSG_9"));//'부품번호나 품명 중 1개는 입력하셔야 합니다.');
            component.set('v.isLoading', false);
            return;
        }
        if(partCode && partCode.length < 3) {
            helper.toast('WARNING', $A.get("$Label.c.BPI_E_MSG_10"));//'부품 번호를 3자리 이상 입력해주세요.');
            component.set('v.isLoading', false);
            return;
        }
        if(partName && partName.length < 3) {
            helper.toast('WARNING', $A.get("$Label.c.BPI_E_MSG_11"));//'품명을 3자리 이상 입력해주세요.');
            component.set('v.isLoading', false);
            return;
        }

        partCode = partCode != undefined ? partCode.trim() : null;
        partName = partName != undefined ? partName.trim() : null;

        console.log('af partCode :::' + partCode);
        console.log('af partName :::' + partName);
        
        var action = component.get('c.getPartsInfo');
        action.setParams({
            'partCode' : partCode,
            'partName' : partName,
            'partList' : component.get('v.filterPartList'),
            'isDNSA'   : true,
        });

        action.setCallback(this, function(response) {
            const status = response.getState();
            component.set('v.isLoading', false);
        
            if (status === 'SUCCESS') {
                const result = response.getReturnValue();
                
                if (!result || result.length === 0) {
                    helper.toast('ERROR', $A.get("$Label.c.service_msg_validation_013"));
                } else {
                    helper.toast('SUCCESS', $A.get("$Label.c.service_msg_validation_010"));
                    //25.01.07 Hyunwook Jin Name 필드 언어별 품명 대입
                    result.forEach(part => {
                        part.Name = part.FM_MaterialDetails__c;
                    });
                    component.set('v.partsList', result);
                }
            } else if (status === 'ERROR') {
                const errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error('Error:', errors[0].message);
                } else {
                    console.error('오류 확인 불가');
                }
            }
        });
        
        $A.enqueueAction(action);
    },

    // SelectkRow: function (component, event, helper) {
    //     var type = component.get('v.type');

    //     var partsList = [];

    //     if (type == '부품번호') {
    //         partsList = component.get('v.partsList');
    //     } else if (type == '대체품') {
    //         partsList = component.get('v.replacePartsList');
    //     }
    //     var partsIndex = event.currentTarget.dataset.record;
    //     var parts = partsList[partsIndex];

    //     // publish event
    //     const compEvent = component.getEvent("cmpEvent");
    //     compEvent.setParams({
    //         "modalName": 'DN_SearchProductNumber',
    //         "actionName": 'Close',
    //         "message": parts
    //     });
        
    //     compEvent.fire();
    //     helper.closeModal(component);
    // },

    clickRow: function (component, event, helper) {
        try {
            var type = component.get('v.type');
            console.log('type: '+type);

            var partsList = [];

            if (type == '부품번호') {
                partsList = component.get('v.partsList');
            } else if (type == '대체품') {
                partsList = component.get('v.replacePartsList');
            }
            var partsIndex = event.currentTarget.dataset.record;
            var parts = partsList[partsIndex];

            console.log('idx: '+partsIndex);
            console.log('parts: ', JSON.stringify(parts));
            parts.parentCmp = component.get('v.parentCmp');
            // publish event
            const compEvent = component.getEvent("cmpEvent");
            compEvent.setParams({
                "modalName": 'DN_SearchProductNumber',
                "actionName": 'Close',
                "message": parts
            });
            compEvent.fire();
            helper.closeModal(component);
        } catch (e) {
            console.error('clickRow 실행 중 오류 발생: ', e.message);
        }
    },

    handleKeyPress: function (component, event, helper) {
        console.log("enter11");
        if(event.keyCode === 13) {
            console.log("enter");
            $A.enqueueAction(component.get('c.searchParts'));
        }
    }
})