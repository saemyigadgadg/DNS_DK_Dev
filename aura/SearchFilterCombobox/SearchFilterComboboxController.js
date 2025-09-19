({
    handleSearch: function (component, event, helper) {
        const keyword = event.getSource().get("v.value");
        console.log('keyWord', keyword);
        component.set("v.searchKeyword", keyword);
        helper.fetchFilteredOpportunities(component, keyword);
        // if(!$A.util.isEmpty(component.set('v.lookupValue'))){
        //     helper.fetchFilteredOpportunities(component, keyword);
        // }else{
        //     if (keyword.length >= 1) {
        //         helper.fetchFilteredOpportunities(component, keyword);
        //     } else {
        //         component.set("v.isDropdownOpen", false);
        //         component.set("v.opportunityOptions", []);
        //     }
        // }

        
    },

    handleOptionSelect: function (component, event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedLabel = event.currentTarget.innerText;
        console.log('selectedId', selectedId);
        console.log('selectedLabel', selectedLabel);

        component.set("v.selectedOpportunity", selectedId);
        component.set("v.searchKeyword", selectedLabel);
        component.set("v.isDropdownOpen", false);
        component.set("v.isSelect", true);
    },

    handleLower : function(component, event, helper){
        var lowerVal = event.getParams('value');
        console.log('value', event.getParams('value'));
        if(lowerVal.length > 0){
            console.log('있음');
            component.set('v.isSelect', true);
            component.set('v.isDropdownOpen', false);
        }else{
            console.log('없음');
            component.set('v.isSelect', false);
            component.set('v.isDropdownOpen', true);
            component.set('v.searchKeyword', '');
        }
    }
});