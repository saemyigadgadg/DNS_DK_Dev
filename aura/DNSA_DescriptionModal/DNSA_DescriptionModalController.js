({
    init: function(component, event, helper) {
        const originalText = component.get("v.sqText");
        var textList = originalText.split('#$').filter(item => item.trim() !== '');
        component.set("v.textList", textList);
    },

    handleClickClose : function(component, event, helper) {
        helper.cancelModal(component);helper.cancelModal(component);
    }
})