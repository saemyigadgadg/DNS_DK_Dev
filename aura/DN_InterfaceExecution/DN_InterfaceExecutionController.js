({
    init: function (component, event, helper) {        
        console.log('init');
        
        component.set('v.columns', [
            {label: 'Id', fieldName: 'Id', type: 'text'},
            {label: 'Status__c', fieldName: 'Status__c', type: 'text'},
            {label: 'RequestBody__c', fieldName: 'RequestBody__c', type: 'text'},
            {label: 'ResponseBody__c', fieldName: 'ResponseBody__c', type: 'text'},
            {label: 'ResponseTime__c', fieldName: 'ResponseTime__c', type: 'text'},
            {label: 'RequestTime__c', fieldName: 'RequestTime__c', type: 'text'}            
        ]);

        try {
            helper.apexCall(component, event, helper, 'getInterfaceList', {interfaceName : ''})
            .then($A.getCallback(function(result) {      
                console.log(result.r);
                component.set('v.items', result.r.items);
                component.set('v.itemMap', result.r.itemMap);
                component.set('v.url', result.r.url);
            }))
            .catch(function(error) {
                console.log('# getInit error : ' + error.message);
            });
            
        } catch (error) {
            console.log('Popup error ::: ', error);
        }
        // var items = [{
        //     "label": "User",
        //     "name": "1",
        //     "disabled": false,
        //     "expanded": true,
        //     "items": [{
        //         "label": "Standard User",
        //         "name": "2",
        //         "disabled": false,
        //         "expanded": true,
        //         "items": []
        //     }, {
        //         "label": "Chatter User",
        //         "name": "3",
        //         "disabled": false,
        //         "expanded": true,
        //         "items": []
        //     }]
        // }, {
        //     "label": "Administrator",
        //     "name": "4",
        //     "disabled": false,
        //     "expanded": true,
        //     "items": [{
        //         "label": "System Administrator",
        //         "name": "5",
        //         "disabled": false,
        //         "expanded": true,
        //         "items": []
        //     }, {
        //         "label": "Chatter Administrator",
        //         "name": "6",
        //         "disabled": false,
        //         "expanded": true,
        //         "items": []
        //     }]
        // }, {
        //     "label": "Community User",
        //     "name": "7",
        //     "disabled": false,
        //     "expanded": false,
        //     "items": [{
        //         "label": "Community Login User",
        //         "name": "8",
        //         "disabled": false,
        //         "expanded": false,
        //         "items": []
        //     }, {
        //         "label": "Community Plus Login User",
        //         "name": "9",
        //         "disabled": true,
        //         "expanded": true,
        //         "items": []
        //     }]
        // }];
        
    },
    handleSelect: function (component, event, helper) {
        // event.preventDefault();
        component.set('v.requestValue_d', '');
        var itemMap = component.get('v.itemMap');        
        var name = event.getParam('name');     
        component.set('v.InterfacId_s', name);
        var item = itemMap[name];
        var url = component.get('v.url');        
        if(item != undefined){            
            var endpointURL = item.EndpointURL__c;
            console.log(item);
            helper.getInterfaceLogList(component, event, helper, name);            
            var svgRichText = component.find("interfaceInfo");
            svgRichText.set("v.value", "<h1>Interface Info</h1>"
                                        +"<br/> Interface Id : " + "<a href=\"" + url + "/lightning/r/Interface__c/" + item.Id + "/view\">" + item.Name +"</a>"
                                        +"<p> System-Category  : " + item.System__c + "-" + item.Categroy__c + "</p>"
                                        +"<br/> Endpoint URL : <p class=\"disableLink\">" + endpointURL + "</p>"
                                        +"<br/> Description : <p>"  + item.Description__c + "</p>"                                
                                        );
            var a = document.querySelector(".disableLink a");
            a.href = '#';
            component.set('v.requestValue', item.RequestBodySample__c);                                            
            component.set('v.responseValue', '');
            component.set('v.requestValue_d', item.RequestBodySample__c);            
        }           
        
        
    },
    handleKeyUp: function (component, event, helper) {
        var value = component.get('v.inputValue');        
        console.log(value);
        try {
            window.setTimeout(
                $A.getCallback(function() {
                    helper.apexCall(component, event, helper, 'getInterfaceList', {interfaceName : value})
                    .then($A.getCallback(function(result) {      
                        console.log(result.r);
                        component.set('v.items', result.r.items);
                        component.set('v.itemMap', result.r.itemMap);
                    }))
                    .catch(function(error) {
                        console.log('# getInit error : ' + error.message);
                    });      
                }), 500
            );            
        } catch (error) {
            console.log('Popup error ::: ', error);
        }
    },
    handleRefresh: function (component, event, helper) {
        // event.preventDefault();
        var requestValue = component.get('v.requestValue_d');
        component.set('v.requestValue', requestValue);        
    },
    handleExecute: function (component, event, helper) {
        try {
            console.log('handleExecute');
            component.set('v.loaded', true);
            var requestValue = component.get('v.requestValue');
            var interfacId = component.get('v.InterfacId_s');
            
            helper.apexCall(component, event, helper, 'executeInterface', {
                parmString : requestValue,
                interfaceId : interfacId
            })
            .then($A.getCallback(function(result) {      
                console.log('result.r', result.r);
                component.set('v.responseValue', result.r)
                helper.getInterfaceLogList(component, event, helper, interfacId);        
            }))
            .catch(function(error) {
                console.log('# getInit error : ' + error.message);
            });
            component.set('v.loaded', false);
        } catch (error) {
            component.set('v.loaded', false);
            console.log('Popup error ::: ', error);
        }
    },
    handleCopy: function (component, event, helper) {
        // event.preventDefault();       
        var responseValue = component.get('v.responseValue');

        helper.copyTextHelper(component, event, responseValue);
    },
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');        
        component.set('v.selectedRow', selectedRows[0]);        
    },
    handleSetRequest: function (component, event, helper) {
        var selectedRow = component.get('v.selectedRow');        
        var requestBody = selectedRow.RequestBody__c      
        requestBody = requestBody.replace("inputParam={\"Input\":", "");
        requestBody = requestBody.replace("}}", "}");
        component.set('v.requestValue', requestBody);                                            
    }

})