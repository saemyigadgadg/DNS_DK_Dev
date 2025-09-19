({
    doInit: function (component, event, helper) {
        console.log('출하이력 doInit');
    },
    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { 
            console.log(`${component.getName()}.setSubscriptionLMC`);
            console.log(JSON.stringify(message));
            console.log(JSON.stringify(params));
            console.log(params.type);
            switch (params.type) {
                case 'filterChange' :
                case 'defaultFilter':
                    console.log('출하이력');
                    console.log(params.type);
                    let headerParams = component.get('v.headerParams');
                    if(!!!headerParams) headerParams = {};
                    let isArray = Array.isArray(params.message);
                    if(isArray) {
                        [...params.message].forEach((headerParam)=>{
                            headerParams[headerParam.field] = headerParam.value;
                        });
                    } else {
                        headerParams[params.message.field] = params.message.value;
                    }
                    console.log('headerParamsheaderParams'+headerParams);
                    component.set('v.headerParams', headerParams);
                    break;
                case 'Seach':
                    console.log('출하이력 search');
                    component.set('v.giList',[]);
                    helper.doSearch(component,'Search');
                    break;
                default:
                    break;
            }  
            
        }
    }
    
})