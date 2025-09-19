({
    doInit : function(component, event, helper) {
        //const mySelf = component.find("RegsiterMultiPartModalBody");
        // const element = mySelf.getElement();
        // const pasteHandler = function (e) {
        //     console.log(' pasteHandler');
        //     helper.handlePaste(component, e);
        // };
        // component._pasteHandler = pasteHandler;
        // window.addEventListener("paste", pasteHandler);
        setTimeout(() => {
            console.log(component.get('v.type'), ' type ++++');
            const pasteArea = component.find("pasteDiv").getElement();
            pasteArea.addEventListener("paste", (event) => {
                helper.handlePaste(component, event);
            }); 
            // const pasteBTN = component.find("pasteBTN").getElement();
            // pasteBTN.addEventListener("paste", (event) => {
            //     helper.handlePaste(component, event);
            // }); 
              
        }, 500);
        

    },
   

    handlePasteButton : function(component, event, helper) {
        navigator.clipboard.readText()
        .then((text) => {
            let keywordList = component.get('v.keywordList');
            //Please press CTRL+V to paste.
            console.log(text,' :: text');
            const pastedText = text;
            const rows = pastedText.split('\n').filter(row => String(row).trim() !== '');
            rows.forEach(element => {
                keywordList.push(String(element).trim());
            });           
            component.set('v.keywordList', keywordList);

        })
        .catch(err => {
            console.error("클립보드 읽기 실패: ", err);
        });
        // new Promise((resolve, reject) => {
        //     // 비동기 작업 수행
        //     console.log(navigator.clipboard.readText(), ' test');
        // });
        
        //helper.handlePaste(component, event);
        // Handle paste logic
        //alert("CTRL+V를 동시에 눌러주세요.");
    },
    
    removeText : function(component, event, helper) {
        let index = event.currentTarget.name;
        let keywordList = component.get('v.keywordList');
        component.set('v.keywordList', []);
        let keySet = keywordList.splice(index,1); 
        component.set('v.keywordList',keywordList);
        console.log(' testset');
    },


    handleConfirm : function(component, event, helper) {
        console.log(JSON.stringify(component.get('v.keywordList')), ' key List');
        helper.apexCall(component, event, helper, 'getParts', {
			partSearch : component.get('v.keywordList')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            let keywordList = component.get('v.keywordList');  
            
            let msg = '';
            
            let valPart = '';
            let label = [];
            let value = [];
            // 있는 목록으로 변경을 해야함.
            r.forEach(element => {
                label.push(element.label);
                value.push(element.value);
                console.log(element.label,' :: 11');
                
                msg += element.label + ',';//msg.replace(element.label+',','');
            });
            
            if(msg.length > 0 ) {
                msg = msg.substring(0, msg.length-1);
                msg =  `[${msg}] 해당 부품들이 있습니다.`+'\n';
            } else {
                helper.toast('error', ' 조회되는 품번이 없습니다. 품번을 확인해주세요');
                return;
            }
            
            helper.openConfirm(`${msg}붙여넣기 하시겠습니까?`, 'default', 'headerless')
            .then($A.getCallback(function(result) {
                if(result) {
                    let labelSet = label.length ==0 ? '' : label.join(',');
                    let valueSet = value.length ==0 ? '' : value.join(',');
                    const compEvent = component.getEvent("cmpEvent");
                    compEvent.setParams({
                        "modalName": 'DN_DemandAdjPerAgencyPopupResMultiPart',
                        "actionName": '',
                        "message": { 'label': labelSet,'value': valueSet, 'parentCmp': component.get('v.parentCmp')}
                    });
                    compEvent.fire();
                    helper.closeModal(component);
                }
            }))
            .catch(error => {
                console.error("Error during confirmation:", error);
            });
        }))
        .catch(function(error) {
        }).finally(function () {
        });
    },
    // 저장위치 중복체크
    handleStorege : function(component, event, helper) {
        console.log(JSON.stringify(component.get('v.keywordList')), ' key List');
        helper.apexCall(component, event, helper, 'getStorege', {
			binSearch : component.get('v.keywordList')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            let keywordList = component.get('v.keywordList');  
            
            let msg = keywordList.join(',')+',';
            
            let valPart = '';
            let label = [];
            let value = [];
            r.forEach(element => {
                label.push(element.label);
                value.push(element.value);
                console.log(element.label,' :: 11');
                console.log(msg.replace(element.label+',',''),' test');

                msg = msg.replace(element.label+',','');
            });
            
            let valMsg = '';
            msg = msg.substring(0, msg.length-1);
            if(msg.length > 0)  valMsg+= `해당 저장 위치가 없습니다.[${msg}]`+'\n';
            
            helper.openConfirm(`${valMsg}붙여넣기 하시겠습니까?`, 'default', 'headerless')
            .then($A.getCallback(function(result) {
                if(result) {
                    let labelSet = label.length ==0 ? '' : label.join(',');
                    let valueSet = value.length ==0 ? '' : value.join(',');
                    const compEvent = component.getEvent("cmpEvent");
                    let type = component.get('v.type');
                    let modalName = type == 'Part' ? 'DN_DemandAdjPerAgencyPopupResMultiPart' : 'DN_DemandAdjPerAgencyPopupResMultiBin'
                    compEvent.setParams({
                        "modalName": modalName,
                        "actionName": '',
                        "message": { 'label': labelSet,'value': valueSet, 'parentCmp': component.get('v.parentCmp')}
                    });
                    compEvent.fire();
                    helper.closeModal(component);
                }
            }))
            .catch(error => {
                console.error("Error during confirmation:", error);
            });
        }))
        .catch(function(error) {
        }).finally(function () {
        });
    },

    handleClose : function(component, event, helper) {
        // Handle close logic
        // console.log("Close button clicked");
        helper.closeModal(component);
    },

    handleKeydown : function(component, event, helper) {
        // https://www.toptal.com/developers/keycode keyevent 참고
        if(event.keyCode == 27) {
            console.log("ESC key pressed");
            helper.closeModal(component);
        }
    }
})