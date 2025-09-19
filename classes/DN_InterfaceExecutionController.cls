/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-13-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-20-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_InterfaceExecutionController {
    
    public String documentId {get;set;}
    public DN_InterfaceExecutionController(){
        System.debug(ApexPages.currentPage().getParameters());
        System.debug(URL.getOrgDomainUrl().toExternalForm());        
    }

    @AuraEnabled
    public static Map<String, Object> getInterfaceList(String interfaceName) {
        
        String searchName = '%';
        if(String.isNotBlank(interfaceName) && String.isNotEmpty(interfaceName)){
            searchName = '%' + interfaceName.toUpperCase() + '%';
        }
         
        List<Interface__c> interfaceList = [SELECT Id, Name, Requirement__c, WebServiceType__c, ProcessingType__c, Description__c, Cycle__c, EndpointURL__c, System__c, IsActive__c, 
                                            HttpMethod__c, TtrafficDirection__c, Categroy__c, ContentType__c, Timeout__c, RequestBodySample__c, ResponseBodySample__c, SubCategory__c
                                            FROM Interface__c WHERE Name like :searchName AND TtrafficDirection__c = 'Outbound' ORDER BY Name];

        Map<String, Map<String, List<Interface__c>>> interfaceSystemMap = new Map<String, Map<String, List<Interface__c>>>();

        for(Interface__c ifv : interfaceList){
            Map<String, List<Interface__c>> interfaceCategoryMap = new Map<String, List<Interface__c>>();
            List<Interface__c> interfaceCategoryList = new List<Interface__c>();

            String systemName = ifv.System__c == null ? 'Other' : ifv.System__c;
            String category = ifv.Categroy__c == null ? 'Other' : ifv.Categroy__c;

            if(interfaceSystemMap.get(systemName) != null){
                interfaceCategoryMap = interfaceSystemMap.get(systemName);
            }

            if(interfaceCategoryMap.get(category) != null ){
                interfaceCategoryList = interfaceCategoryMap.get(category);
            }
            interfaceCategoryList.add(ifv);
            interfaceCategoryMap.put(category, interfaceCategoryList);
            interfaceSystemMap.put(systemName, interfaceCategoryMap);            
        }

        integer i = 1;
        List<IneterfaceItem> ineterfaceItemList = new List<IneterfaceItem>();
        Map<String, Interface__c> itemMap = new Map<String, Interface__c>();
        for(String systemName : interfaceSystemMap.keySet()){
        	System.debug(systemName);
        	IneterfaceItem ifi_system = new IneterfaceItem(systemName, String.valueOf(i++));
        	Map<String, List<Interface__c>> interfaceCategoryMap =interfaceSystemMap.get(systemName);
            
        	for(String category : interfaceCategoryMap.keySet()){
                IneterfaceItem ifi_category = new IneterfaceItem(category, String.valueOf(i++));
                System.debug('-' + category); 
                for(Interface__c ifv : interfaceCategoryMap.get(category)){                        
                    IneterfaceItem ifi_item = new IneterfaceItem(ifv.Name, String.valueOf(i++));          			
                    ifi_category.items.add(ifi_item);
                    itemMap.put(ifv.Name, ifv);
                    if(interfaceCategoryMap.keySet().size() == 1) ifi_system.items.add(ifi_item);
                }
                if(interfaceCategoryMap.keySet().size() != 1) ifi_system.items.add(ifi_category);
        	}
        	ineterfaceItemList.add(ifi_system);
        }

        return new Map<String, Object>{
            'items' =>  ineterfaceItemList,
            'itemMap' => itemMap,
            'url' => System.URL.getOrgDomainUrl().toExternalForm()
        };    
        
    }

    @AuraEnabled
    public static Map<String, Object> getInterfaceLogList(String interfaceName){
        try {
            List<InterfaceLog__c> interfaceLogList = [SELECT Id, Name, RequestBody__c, ResponseBody__c, ResponseTime__c, RequestTime__c, Status__c
                                                    FROM InterfaceLog__c 
                                                    WHERE Interface__r.Name = :interfaceName
                                                    ORDER BY CreatedDate DESC 
                                                    LIMIT 100
            ];
            // List<Map<String, String>> columnsList= new List<Map<String, String>>();
            // for(InterfaceLog__c ifl : interfaceLogList){
            //     new Map<String, String> {
            //         'label' => ifl.RequestBody__c,
            //         'value' => ifl.Id
            //     }
            //     columnsList.add();
            // }

            return new Map<String, Object>{
                'data' => interfaceLogList
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string executeInterface(String interfaceId, String parmString){
        try {
            System.debug(parmString);
            // Map<String, Object> parmeters = (Map<String, Object>) JSON.deserializeUntyped(parmString);
            // System.debug(parmeters);
            InterfaceCommonUtil interfaceUtil = new InterfaceCommonUtil();
            String apexClassName = 'Interface_Execution';
            // String parmetersString = interfaceUtil.getParmetersString(parmeters);
            String responseString = interfaceUtil.sendHttp(parmString, interfaceId, apexClassName, TRUE);

            // responseString = interfaceUtil.getResponseString(responseString);    

            return responseString;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class IneterfaceItem{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean disabled {get;set;}
        @AuraEnabled public Boolean expanded {get;set;}
        @AuraEnabled public List<IneterfaceItem> items {get;set;}
        
        public IneterfaceItem(String label, String name){
            this.label = label;
            this.name = label;
            this.disabled = false;
            this.expanded = true;
            this.items = new List<IneterfaceItem>();
        }
    }
}