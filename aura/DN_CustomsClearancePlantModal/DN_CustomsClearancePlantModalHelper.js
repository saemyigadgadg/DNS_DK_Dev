({
    closeModal : function(component) {
        var modal = component.find("customsClearancePlantModal");
        var modalBackGround = component.find("customsClearancePlantModalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
    },

    setPlantData : function(component) {
        var plantData = [
            {
                'plant': '274S',
                'description': 'DNS DNSC Service'
            },
            {
                'plant': '4119',
                'description': 'Export CE'
            },
            {
                'plant': '4129',
                'description': 'DIA Export FL'
            },
            {
                'plant': '4130',
                'description': 'DIA EG'
            },
            {
                'plant': '4139',
                'description': 'Export EG'
            },
            {
                'plant': '413S',
                'description': 'DIA EG CS'
            },
            {
                'plant': '1140',
                'description': 'MT - Namsan'
            },
            {
                'plant': '1141',
                'description': 'MT - Daewon'
            },
            {
                'plant': '1142',
                'description': 'MT - Sungjoo'
            },
            {
                'plant': '1146',
                'description': 'MT Parts'
            },
            {
                'plant': '1149',
                'description': 'MT CKD'
            },
            {
                'plant': '114S',
                'description': 'MT Service'
            },
            {
                'plant': '1840',
                'description': 'DNS - Namsan'
            },
            {
                'plant': '1842',
                'description': 'DNS - Sungjoo'
            },
            {
                'plant': '1846',
                'description': 'DNS Parts'
            },
            {
                'plant': '1849',
                'description': 'DNS CKD'
            },
            {
                'plant': '184S',
                'description': 'DNS Service'
            },
            {
                'plant': '2740',
                'description': 'DNS DNSC'
            },
            {
                'plant': '2746',
                'description': 'DNS DNSC Parts'
            },
            {
                'plant': '4140',
                'description': 'DNSA'
            },
            {
                'plant': '4146',
                'description': 'DNSA PDC'
            },
            {
                'plant': '4149',
                'description': 'DNSA Export'
            },
            {
                'plant': '414S',
                'description': 'DNSA CS'
            },
            {
                'plant': '4160',
                'description': 'DIA EG Suwanee PDC'
            },
            {
                'plant': '4169',
                'description': 'Export AM'
            },
            {
                'plant': '4179',
                'description': 'Export R&D'
            },
            {
                'plant': '4190',
                'description': 'DIA Suwanee'
            },
            {
                'plant': '7319',
                'description': 'DIG Export CE'
            },
            {
                'plant': '7329',
                'description': 'DIG Export FL'
            },
            {
                'plant': '7339',
                'description': 'DIG Export EG'
            },
            {
                'plant': '7340',
                'description': 'DNSEU'
            },
            {
                'plant': '7346',
                'description': 'DNSEU Parts'
            },
            {
                'plant': '7349',
                'description': 'DNSEU Export'
            },
            {
                'plant': '734S',
                'description': 'DNSEU CS'
            },
            {
                'plant': '7360',
                'description': 'DIG AM Parts'
            },
            {
                'plant': '7369',
                'description': 'DIG Export AM'
            },
            {
                'plant': '7379',
                'description': 'DIG Export R&D'
            }
        ];

        component.set('v.plantData', plantData);
    }
})