/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 31. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-31 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_DealerPortalExcelUploadController {
    /**
     * @Description
     * 	- Excel Upload 탬플릿 관리용도로 메타데이터 조회
    **/
    @AuraEnabled
    public static ExcelTemplate getTemplate(String uploadName){
        try {
            DealerPortalExcelUploadTemplate__mdt  template = [
                select Id, DeveloperName, 
                MasterLabel,Label, 
                QualifiedApiName,TabName__c, 
                FileName__c, IsTableView__c, 
                TemplateName__c 
                from DealerPortalExcelUploadTemplate__mdt 
                where TemplateName__c =:uploadName
            ];
            ExcelTemplate excelTemplate = new ExcelTemplate(template);
            List<DealerPortalExcelUploadColumn__mdt> columnList = [
                select Id, DeveloperName, 
                MasterLabel, Label, 
                QualifiedApiName,
                DealerPortalExcelUploadTemplate__c, 
                ColumnLabel__c, ColumnApi__c, Index__c, IsRequired__c 
                from DealerPortalExcelUploadColumn__mdt
                where DealerPortalExcelUploadTemplate__c =:template.Id
                order by Index__c asc
            ];
            for(DealerPortalExcelUploadColumn__mdt col : columnList) {
                excelTemplate.columnList.add(new ExcelTemplateColumn(col));
            }
            return excelTemplate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀 템플릿 클래스
    **/
    public class ExcelTemplate {
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String tabName {get;set;}
        @AuraEnabled public String templateName {get;set;}
        @AuraEnabled public Boolean isTableView {get;set;}
        @AuraEnabled public List<ExcelTemplateColumn> columnList {get;set;}
        public ExcelTemplate() {
        }
        public ExcelTemplate(DealerPortalExcelUploadTemplate__mdt template) {
            this.columnList = new List<ExcelTemplateColumn>();
            this.fileName            = template.FileName__c;
            this.tabName             = template.TabName__c;
            this.templateName        = template.TemplateName__c;
            this.isTableView         = template.IsTableView__c;
        }
    }

    /**
     * @Description
     * 	- 엑셀 템플릿 컬럼 클래스
    **/
    public class ExcelTemplateColumn {
        @AuraEnabled public String columnLabel {get;set;}
        @AuraEnabled public String columnApi {get;set;}
        @AuraEnabled public Decimal index {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        
        public ExcelTemplateColumn() {
        }

        public ExcelTemplateColumn(DealerPortalExcelUploadColumn__mdt column) {
            this.columnLabel = column.IsRequired__c ? '* '+ column.ColumnLabel__c : column.ColumnLabel__c;
            this.columnApi = column.ColumnApi__c;
            this.index = column.Index__c;
            this.isRequired = column.IsRequired__c;
        }
    }
}