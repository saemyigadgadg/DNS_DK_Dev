({
    
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
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
    closeModal : function(component) {
        var modal = component.find("RegsiterMultiPartModal");
        var modalBackGround = component.find("modalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            const pasteArea = component.find("pasteDiv").getElement();
            pasteArea.getElement().removeEventListener("paste", (event) => {
                console.log('복붙이벤트 종료');
            });
            e.stopPropagation();
            
        });
            
        // const pasteBTN = component.find("pasteBTN").getElement();
        // pasteBTN.getElement().removeEventListener("paste", (event) => {
            
        // });
        // const pasteHandler = component._pasteHandler;
        // //if (pasteHandler) {
        //     pasteHandler.getElement().removeEventListener("paste", pasteHandler);
        //     delete component._pasteHandler; // 참조 해제
        // //}
    },
    handlePaste: function (component, event, helper) {
        console.log('handlePaste');
        event.preventDefault(); // 기본 붙여넣기 방지
        let keywordList = component.get('v.keywordList');
        console.log(event.clipboardData, ' ::: event.clipboardData');
        console.log(window.clipboardData, ' ::: window.clipboardData');
        // 클립보드 데이터 가져오기
        const clipboardData = event.clipboardData || window.clipboardData;
        const pastedText = clipboardData.getData('text');
        //console.log(pastedText, ' ::::pastedText');
        // 데이터 파싱
        const rows = pastedText.split('\n').filter(row => String(row).trim() !== '');
        //console.log(JSON.stringify(rows),' ::: rows');
        
        rows.forEach(element => {
            keywordList.push(String(element).trim());
        });           
        component.set('v.keywordList', keywordList);
    },

    
    // writeExcelCopiedStr : function(component, event){
    //     // var clipboardData = event.clipboardData || window.clipboardData;  
    //     // console.log("clipboardData ::: " + clipboardData);

    //     // navigator.permissions.query({name: "clipboard-read"}).then((result) => {
    //     //     console.log('결과 ::: ' + result);
    //     //     navigator.clipboard.read().then((item) => {
    //     //         console.log('item ::: ' + item);
    //     //     })
    //     // })
    //     try {
    //         console.log('copy paste 실행');
    //         var tempTable;
    //         var curTableLength = 0;
    //         var keywordList = component.get('v.keywordList');

    //         navigator.clipboard.readText().then((clipText) => {
    //             //indexOf, includes, split(String.fromCharCode(13)); 뭐를 써도 상관없음
    //             clipText = '\n' + clipText;
    //             var clipRows = clipText.split(String.fromCharCode(13));

    //             for (let i=0; i<clipRows.length; i++) {
    //                 clipRows[i] = clipRows[i].split(String.fromCharCode(9));
    //             }

    //             tempTable = document.getElementById("tempTableforParts");
    //             if(tempTable == null || tempTable == undefined){
    //                 tempTable = document.createElement("table");
    //                 tempTable.setAttribute("id", "tempTableforParts");
    //             }
    //             else{
    //                 curTableLength = tempTable.rows.length;
    //             }

    //             for (let i=curTableLength; i<clipRows.length + curTableLength - 1; i++) {
    
    //                 var newRow = tempTable.insertRow();
    //                 newRow.setAttribute("id", "tr"+i);
                    
    //                 for (let j=0; j<clipRows[i - curTableLength].length; j++) {
    //                     let newCell = newRow.insertCell();
    //                     if (clipRows[i - curTableLength][j].length == 0) {
    //                         newCell.innerText = ' ';
    //                     }
    //                     else {
    //                         const cssClassNm = 'svgClose';
    //                         // newCell.innerHTML = '<span style="font-size: 20px;">' + clipRows[i][j] + '</span>' + "&nbsp;&nbsp;<div class='" + cssClassNm +"' onclick='trDelete("+i+");' style='cursor:pointer;' />";
    //                         //newCell.innerHTML = clipRows[i][j] + "&nbsp;&nbsp;<div class='" + cssClassNm +"'/>";
    //                         // newCell.innerHTML = clipRows[i][j] + '&nbsp;&nbsp;<img src="' + $A.get('$Resource.CloseBtn') + '" onclick="trDelete();" style="cursor:pointer;" />';
                        
    //                         // 텍스트 노드를 생성하여 추가
    //                         var spanText = document.createElement('span');
    //                         spanText.style.fontSize = '20px';
    //                         spanText.innerHTML = clipRows[i - curTableLength][j] + "&nbsp;&nbsp";
    //                         newCell.appendChild(spanText);

    //                         var newDiv = document.createElement('div');
    //                         newDiv.className = cssClassNm;
    //                         newDiv.style.cursor = 'pointer';
    //                         newDiv.addEventListener('click', function() {
    //                             var table = document.getElementById("tempTableforParts");
    //                             var tr = document.getElementById("tr"+i).rowIndex;
    //                             keywordList.splice(tr, 1);
    //                             table.deleteRow(tr);
    //                             component.set('v.keywordList', keywordList);
    //                         });
    //                         newCell.appendChild(newDiv);
    //                         keywordList.push(clipRows[i - curTableLength][j].slice(1));
    //                     }
    //                 }
    //             }
    //             component.set('v.keywordList', keywordList);
    //             let modalBody = component.find('RegsiterMultiPartModalBody').getElement();
    //             modalBody.appendChild(tempTable);   
    //         });
    //     } catch (error) {
    //         console.log('error ::::: ' + error);
    //     }
    // }
})