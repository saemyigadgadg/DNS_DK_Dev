/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 02. 05. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-05 | Iltae seo      | 최초작성 
 */ 
public without sharing class DN_DealerLeadTimeManagementController {
    
    /**
     * @Description
     * 	- 데이터 조회 
    **/ 
    @AuraEnabled
    public static List<LeadTimeManagement> getDataList(Map<String,Object> whereCondition){
        try {
            List<LeadTimeManagement> returnList = new List<LeadTimeManagement>();
            String strQuery = 'select Id,';
            String strWhere =' where Part__c IN(select Part__c from ProductByPlant__c where PlannedDeliveryDay__c >0 AND Plant__c =\'1846\') ';
            strQuery += ' Plant__c, Part__c,';
            strQuery += ' PlannedDeliveryDays__c,ExternalKey__c,';
            strQuery += ' Part__r.ProductCode,Part__r.MaterialGroupCode__c,Part__r.FM_MaterialDetails__c,';
            strQuery += ' LastModifiedDate, LastModifiedBy.Name';
            strQuery += ' from DealerLeadTimeManagement__c';
            
            //Plant
            String plant = (String) whereCondition.get('plant');
            if(String.isNotBlank(plant)) {
                strWhere += ' AND Plant__c=\''+plant+'\'';
            }
            // Part
            String productCode = (String) whereCondition.get('productCode');
            if(String.isNotBlank(productCode)) {
                set<String> productSet = new set<String>(productCode.split(','));
                strWhere += ' AND Part__c IN(\''+String.join(productSet, '\',\'') + '\')';
            }
            // PartGroup 
            String partGroupCode = (String) whereCondition.get('PartGroupCode');
            if(String.isNotBlank(partGroupCode)) {
                strWhere += ' AND Part__r.MaterialGroupCode__c=\''+partGroupCode+'\'';
            }
            
            //	PlannedDeliveryDays
            String plannedDeliveryDays = (String) whereCondition.get('PlannedDeliveryDays');
            if(String.isNotBlank(plannedDeliveryDays)) {
                strWhere += ' AND Part__c IN(select Part__c from ProductByPlant__c where PlannedDeliveryDay__c ='+plannedDeliveryDays+' AND PlannedDeliveryDay__c>0 ) ';
            }
            System.debug(strQuery + strWhere + ' ::: strQuery + strWhere');
            set<String> productCodeSet = new set<String>();
            //DealerLeadTimeManagement__c 데이터 매핑
            List<DealerLeadTimeManagement__c> dealerLeadTimeList = Database.query(strQuery + strWhere + ' LIMIT 1000');
            for(DealerLeadTimeManagement__c leadTime : dealerLeadTimeList) {
                LeadTimeManagement leadTimes = new LeadTimeManagement(leadTime);
                productCodeSet.add(leadTimes.material);
                returnList.add(leadTimes);
            }
            // ProductBy Plant 데이터 매핑 //MRPType__c,InventoryManager__c,PlannedDeliveryDay__c
            String productByQ = 'select Part__c,Plant__c,MRPType__c,InventoryManager__c,PlannedDeliveryDay__c,Part__r.ProductCode from ProductByPlant__c where PlannedDeliveryDay__c>0 ';
            productByQ += ' AND Part__r.ProductCode IN(\'' +String.join(productCodeSet, '\',\'')+'\')'; 
            
            // MRPType 
            String mrpType = (String) whereCondition.get('MRPType');
            if(mrpType !='All') {
                productByQ += ' AND MRPType__c =\''+mrpType+'\'';
                //where Part__c IN (select Part__c from ProductByPlant__c where MRPType__c =\''
            }


            System.debug(productByQ + ' :: productByQ');
            List<ProductByPlant__c> productByPlantList = Database.query(productByQ + ' LIMIT 40000');
            Map<String,ProductByPlant__c> plantToPartMap = new Map<String,ProductByPlant__c>();
            for(ProductByPlant__c prod : productByPlantList) {
                plantToPartMap.put(prod.Plant__c +prod.Part__r.ProductCode,prod);
            } 
            System.debug(plantToPartMap + ' :: plantToPartMap');
            // 데이터 매핑 셋
            for(LeadTimeManagement timeSet : returnList) {
                ProductByPlant__c prodBy = plantToPartMap.get(timeSet.plant+timeSet.material);
                if(prodBy !=null) {
                    timeSet.convertProductByPlant(prodBy);
                }
            }
            return returnList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DealerLeadTimeManagementControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Save 
    **/ 
    @AuraEnabled
    public static void leadTimeSave(List<LeadTimeManagement> saveData){
        try {
            List<DealerLeadTimeManagement__c> dealerLeadTimeList = new List<DealerLeadTimeManagement__c>();
            for(LeadTimeManagement leadTime : saveData) {
                if(!leadTime.isStatus) {
                    throw new DN_DealerLeadTimeManagementControllerException('수정하지 않은 데이터가 선택되었습니다.');
                }
                dealerLeadTimeList.add(new DealerLeadTimeManagement__c(Id=leadTime.id,PlannedDeliveryDays__c=leadTime.dealerLeadTime, ExternalKey__c=leadTime.externalKey));
            }
            upsert dealerLeadTimeList ExternalKey__c;
            System.debug(saveData + ' ::: saveData');
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DealerLeadTimeManagementControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀 업로드 데이터 유효성 확인 
    **/ 
    @AuraEnabled
    public static List<LeadTimeManagement> uploadDataCheck(List<LeadTimeManagement> uploadData){
        try {
            System.debug(uploadData + ' ::: uploadData');
            Map<String,LeadTimeManagement> dealerLTMap = new Map<String,LeadTimeManagement>();
            set<String> plantIds = new set<String>();
            set<String> materialIds = new set<String>();
            List<LeadTimeManagement> returnList = new List<LeadTimeManagement>();
            for(LeadTimeManagement leadTime : uploadData) {
                leadTime.material = leadTime.material.trim();
                leadTime.plant = leadTime.plant.trim();
                
                plantIds.add(leadTime.plant);
                materialIds.add(leadTime.material);
            }
            System.debug(materialIds + ' :: materialIds');
            System.debug(plantIds + ' :: plantIds');
            Map<String,Product2> prodMap = new Map<String,Product2>();
            List<Product2> productList = [
                SELECT 
                Id, Name, ProductCode
                FROM Product2 where ProductCode IN:materialIds
            ];
            System.debug(productList + ' : :productList');
            for(Product2 prod : productList) {
                prodMap.put(prod.ProductCode,prod);
            }
            
            List<DealerLeadTimeManagement__c> leadTimeList = [
                SELECT Id,
                Plant__c, Part__c,
                PlannedDeliveryDays__c,ExternalKey__c,
                Part__r.ProductCode,Part__r.MaterialGroupCode__c,Part__r.FM_MaterialDetails__c,
                LastModifiedDate, LastModifiedBy.Name
                FROM DealerLeadTimeManagement__c
                WHERE Plant__c IN :plantIds
                AND Part__r.ProductCode IN : materialIds
            ];
            System.debug(leadTimeList + ' :: leadTimeList');
            for(DealerLeadTimeManagement__c leadTime : leadTimeList) {
                LeadTimeManagement leadTimes = new LeadTimeManagement(leadTime);
                returnList.add(leadTimes);
            }
            List<ProductByPlant__c> prodByPlantList = [
                select Part__c,Plant__c,
                MRPType__c,InventoryManager__c,
                PlannedDeliveryDay__c,Part__r.ProductCode 
                from ProductByPlant__c
                WHERE Plant__c IN :plantIds
                AND Part__r.ProductCode IN : materialIds
            ];
            Map<String,ProductByPlant__c> plantToPartMap = new Map<String,ProductByPlant__c>();
            for(ProductByPlant__c prod : prodByPlantList) {
                plantToPartMap.put(prod.Plant__c +prod.Part__r.ProductCode,prod);
            }
            // 데이터 매핑 셋
            for(LeadTimeManagement timeSet : returnList) {
                ProductByPlant__c prodBy = plantToPartMap.get(timeSet.plant+timeSet.material);
                if(prodBy !=null) {
                    timeSet.convertProductByPlant(prodBy);
                }
                dealerLTMap.put(timeSet.plant+timeSet.material,timeSet);
            }
            // 업로드 데이터중에 DB에 없는 것들은 별도로 담기
            for(LeadTimeManagement upload : uploadData) {
                
                LeadTimeManagement leadTime = dealerLTMap.get(upload.plant +upload.material);
                if(leadTime ==null) {
                    upload.isStatus = false;
                    // 업로드 데이터중에 해당 부품 존재 유무
                    if(prodMap.get(upload.material) ==null) {
                        upload.isPartCheck = false;
                    } else {
                        upload.isPartCheck = true;
                    }
                    returnList.add(upload);
                }   
            }
            System.debug(returnList + ' ::: returnList');
            return returnList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DealerLeadTimeManagementControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- DealerLeadTime 데이터 클래스 
    **/ 
    public class LeadTimeManagement {
        @AuraEnabled public String id {get;set;} // id
        @AuraEnabled public Boolean isPartCheck {get;set;} // 해당 부품이 유효한 부품인지
        @AuraEnabled public Boolean isStatus {get;set;} // 수정여부
        @AuraEnabled public String material {get;set;} // Product Code
        @AuraEnabled public String materialDetails {get;set;} // Product Details
        @AuraEnabled public String materialGroup {get;set;} // Product Group
        @AuraEnabled public String plant {get;set;} // plant 
        @AuraEnabled public Decimal dealerLeadTime {get;set;} // dealerLeadTime // DealerLeadTime에 값이 없으면 marc에 데이터로 
        @AuraEnabled public DateTime lastModifiedDate {get;set;} // lastModifiedDate
        @AuraEnabled public String lastModifiedBy {get;set;} // lastModifiedBy
        @AuraEnabled public String externalKey {get;set;} // ExternalKey__c
        // ProductByPlant
        @AuraEnabled public String mrptype {get;set;} // MRP Type
        @AuraEnabled public String inventoryManager {get;set;} // inventoryManager
        @AuraEnabled public Decimal plannedDeliveryDays {get;set;} // plannedDeliveryDays
        public LeadTimeManagement() {}
        
        public LeadTimeManagement(DealerLeadTimeManagement__c leadTime) {
            this.id                                     = leadTime.Id;
            this.isPartCheck                            = true;
            this.isStatus                               = false;
            this.material                               = leadTime.Part__r.ProductCode;
            this.materialDetails                        = leadTime.Part__r.FM_MaterialDetails__c;                        
            this.materialGroup                          = leadTime.Part__r.MaterialGroupCode__c;
            this.plant                                  = leadTime.Plant__c;                   
            this.dealerLeadTime                         = leadTime.PlannedDeliveryDays__c;                   
            this.lastModifiedDate                       = leadTime.LastModifiedDate;                 
            this.lastModifiedBy                         = leadTime.LastModifiedBy.Name;
            this.externalKey                            = leadTime.ExternalKey__c;
            this.plannedDeliveryDays                    = 0;
        }

        // ProductByPlant 데이터 매핑
        public void convertProductByPlant(ProductByPlant__c plant) {
            this.mrptype =plant.MRPType__c;
            this.inventoryManager =plant.InventoryManager__c;
            if(this.dealerLeadTime == null) {
                this.dealerLeadTime = plant.PlannedDeliveryDay__c;
            }
            this.plannedDeliveryDays = plant.PlannedDeliveryDay__c;
        }
    }

    public class DN_DealerLeadTimeManagementControllerException extends Exception {}
}