({
    gfnDoInit : function(component, event) {
        let self = this;
        let warrantySeq = component.get('v.warrantySeq');
        this.apexCall(component, event, this, 'warrantyDetailInit', {warrantySeq}).then($A.getCallback(function(result){
            let { r, state } = result;
            console.log(component.getName());
            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                component.set('v.claimOrder' , r.claimDetails);
            }
            else {
                self.toast('Warning', ' 관리자한테 문의해주세요. ');
            }
        }));
    }
})