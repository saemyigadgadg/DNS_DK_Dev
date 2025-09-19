<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PSConfirmed</fullName>
        <description>PSConfirmed</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/RFQReviewConfirmed_Ko</template>
    </alerts>
    <alerts>
        <fullName>RFQConfirmed_En</fullName>
        <description>RFQ Confirmed_En</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/RFQReviewConfirmed_En</template>
    </alerts>
    <alerts>
        <fullName>RFQRejceted_En</fullName>
        <description>RFQ Rejceted_En</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/RFQReviewRejected_En</template>
    </alerts>
    <alerts>
        <fullName>RFQRejected</fullName>
        <description>RFQ Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/RFQReviewRejected_Ko</template>
    </alerts>
    <alerts>
        <fullName>RFQ_ApprovalRequest</fullName>
        <description>RFQ Approval Request</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/RFQApprovalRequest_kr</template>
    </alerts>
    <fieldUpdates>
        <fullName>RecallPS</fullName>
        <description>PS에 대한 추가정보 기입을 위한 Recall</description>
        <field>Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Recall PS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateToConfirmed</fullName>
        <description>Update To Confirmed</description>
        <field>Status__c</field>
        <literalValue>SalesConfirm</literalValue>
        <name>Update To Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateToReview</fullName>
        <description>Update To Request to Review</description>
        <field>Status__c</field>
        <literalValue>RequestToReview</literalValue>
        <name>Update To Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateToSalesREview</fullName>
        <description>PS작성 후, 검토요청</description>
        <field>Status__c</field>
        <literalValue>SalesReview</literalValue>
        <name>Update To Sales Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
