/**
*
* @Author : iltae, Seo
* @Date : 2025. 01. 20.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-01-20 | iltae, Seo     | 최초작성
*
*/
public with sharing class DN_DealerCustomerAgencyController {
    
    /**
     * @Description
     * 	- KDGRP - 02이며 , 레코드타입이 딜러인 경우 대리점 재고관리에서 사용하는 DealerCustomer__c에 적재하는 메소드
    **/
    public static List<DealerCustomer__c> insertAgency(List<Account> newAccList){
        try {
            List<DealerCustomer__c> dealerCustomerList = new List<DealerCustomer__c>();
            List<DealerCustomerShipTo__c> dealerShipToList = new List<DealerCustomerShipTo__c>();
            Map<String,String> detailAddressMap = new Map<String,String>();
            for(Account newAcc :newAccList) {
                String detail = newAcc.DetailAddress__c==null ? '' : newAcc.DetailAddress__c;
                String roadddr = newAcc.get('ShippingStreet')!=null ? newAcc.ShippingStreet.replace(detail,'') : '';
                DealerCustomer__c newDealerCustomer = new DealerCustomer__c(
                    Name = newAcc.Name,
                    AccountNameEnglish__c =newAcc.AccountNameEnglish__c,
                    CurrencyIsoCode ='KRW', 
                    SalesOrganization__c = newAcc.SalesOrganization__c,
                    DistributionChannel__c = newAcc.DistributionChannel__c,
                    Division__c = newAcc.Division__c,
                    CustomerCode__c = newAcc.CustomerCode__c,
                    SourceAccount__c = newAcc.Id,
                    BusinessNumber__c  = newAcc.BusinessNumber__c,
                    sggNm__c = newAcc.sggNm__c,
                    Phone__c = newAcc.Phone,
                    Representative__c = newAcc.Representative__c,
                    TypeOfBusiness__c = newAcc.TypeOfBusiness__c,
                    IsDealer__c = true,
                    IsActive__c = true,
                    Address__Street__s = newAcc.ShippingStreet,
                    Address__PostalCode__s = newAcc.ShippingPostalCode,
                    Address__City__s = newAcc.ShippingCity,
                    RoadAddr__c = roadddr,
                    DetailInfo__c = detail,
                    Address__CountryCode__s ='kr',
                    ExternalKey__c = newAcc.SalesOrganization__c +'-'+ newAcc.DistributionChannel__c +'-'+ newAcc.Division__c +'-'+newAcc.CustomerCode__c,
                    SourceSystem__c = 'ERP'
                );
                dealerCustomerList.add(newDealerCustomer);
                
                detailAddressMap.put(newAcc.Id,detail);
            }
            upsert dealerCustomerList ExternalKey__c;
        
            for(DealerCustomer__c dealer : dealerCustomerList) {
                System.debug(detailAddressMap + ' :::detailAddressMap');
                System.debug(dealer.get('Address__Street__s') + ' :::::');
                String roadddr = dealer.get('Address__Street__s')!=null ? dealer.Address__Street__s.replace(detailAddressMap.get(dealer.SourceAccount__c),'') : '';
                DealerCustomerShipTo__c newShip = new DealerCustomerShipTo__c(
                    Customer__c = dealer.Id,
                    Address__Street__s = dealer.Address__Street__s,
                    Address__City__s = dealer.Address__City__s,
                    Address__PostalCode__s = dealer.Address__PostalCode__s,
                    Address__CountryCode__s ='kr',
                    RoadAddr__c = dealer.Address__City__s,
                    DetailInfo__c = dealer.Address__Street__s,
                    IsDealer__c = true,
                    SourceSystem__c = 'ERP',
                    ExternalKey__c = dealer.SalesOrganization__c +'-'+ dealer.DistributionChannel__c +'-'+ dealer.Division__c +'-'+dealer.CustomerCode__c
                );
                dealerShipToList.add(newShip);
            }
            upsert dealerShipToList ExternalKey__c;
            return dealerCustomerList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            throw new DN_DealerCustomerAgencyControllerException(e.getMessage());
        }
    }



    public class DN_DealerCustomerAgencyControllerException extends Exception {}
}