({
//   afterRender: function(component, helper) {
//     this.superAfterRender();

//     if (component.get("v.scrollListenerInitialized")) return;

//     const container = component.find('scrollContainer').getElement();
//     const cmp = component;

//     container.addEventListener("scroll", function () {
//         if (cmp.get('v.isLoading')) return;

//         if (container.scrollTop + container.clientHeight >= container.scrollHeight - 100) {
//             console.log('[스크롤 하단 도달] → loadMore 실행');
//             helper.loadMore(cmp);
//         }
//     });

//     component.set("v.scrollListenerInitialized", true);
// }



})