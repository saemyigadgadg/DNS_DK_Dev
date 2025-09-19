import DNS_H_PortalFileTitle from '@salesforce/label/c.DNS_H_PortalFileTitle'; 

import Files from '@salesforce/label/c.Files'; 
import DNS_FSL_NoFilesAttached from '@salesforce/label/c.DNS_FSL_NoFilesAttached'; 

import DNS_F_FileName from '@salesforce/label/c.DNS_F_FileName'; 

import DNS_C_OwnerName from '@salesforce/label/c.DNS_C_OwnerName'; 
import DNS_C_LastModifiedDate from '@salesforce/label/c.DNS_C_LastModifiedDate'; 

import DNS_M_FileSuccess from '@salesforce/label/c.DNS_M_FileSuccess'; 
import DNS_M_Success from '@salesforce/label/c.DNS_M_Success'; 
import DNS_M_GeneralError from '@salesforce/label/c.DNS_M_GeneralError'; 
import DNS_M_DeleteFileConfirm from '@salesforce/label/c.DNS_M_DeleteFileConfirm'; 
import DNS_M_DeleteFileSuccess from '@salesforce/label/c.DNS_M_DeleteFileSuccess'; 

const customLabels = {
    DNS_H_PortalFileTitle // Files Shared on Portal, 포탈 공유용 파일

    , Files // Files, 파일
    , DNS_FSL_NoFilesAttached // No files are attached., 첨부된 파일이 없습니다.

    , DNS_F_FileName // File Name, 파일명

    , DNS_C_OwnerName // Owner, 소유자
    , DNS_C_LastModifiedDate // Last Modified Date, 최종 수정일

    , DNS_M_FileSuccess // The file(s) has been uploaded successfully., 파일이 성공적으로 업로드되었습니다.
    , DNS_M_Success // Success, 성공
    , DNS_M_GeneralError // Error Occurred., 오류가 발생했습니다.
    , DNS_M_DeleteFileConfirm // Are you sure you want to delete the file?, 파일을 삭제하시겠습니까?
    , DNS_M_DeleteFileSuccess // The file has been deleted., 파일이 삭제되었습니다.
}

export default customLabels;