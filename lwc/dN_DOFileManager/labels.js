// message
import DNS_M_Success from '@salesforce/label/c.DNS_M_Success'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_FileSizeError from '@salesforce/label/c.DNS_M_FileSizeError'; 

import DNS_C_Item from '@salesforce/label/c.DNS_C_Item'; 
import DNS_C_FileUpload from '@salesforce/label/c.DNS_C_FileUpload'; 

import DNS_C_BizRegistrationCertificate from '@salesforce/label/c.DNS_C_BizRegistrationCertificate'; 
import DNS_C_ShippingAddressMap from '@salesforce/label/c.DNS_C_ShippingAddressMap'; 
import DNS_C_Bond from '@salesforce/label/c.DNS_C_Bond'; 



const customLabels = {
    DNS_M_Success // Success, 성공
    , DNS_M_GeneralError // Error Occurred, 오류가 발생했습니다
    , DNS_M_FileSizeError // File size must not exceed 2MB., 파일 용량은 2MB를 초과할 수 없습니다.

    , DNS_C_Item // Item, 항목
    , DNS_C_FileUpload // File Upload, 파일 업로드
    , DNS_C_BizRegistrationCertificate // Biz Registration Certificate, 사업자 등록증
    , DNS_C_ShippingAddressMap // Shipping Address Map, 출하처 약도
    , DNS_C_Bond // Bond, 채권
};

export default customLabels;