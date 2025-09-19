<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>RequestToUseCustomer</fullName>
        <description>Request to Use Customer</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/UseCustomerApprovalRequest</template>
    </alerts>
    <alerts>
        <fullName>UseCustomerApproved</fullName>
        <description>Use Customer Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/UseCustomerApproved</template>
    </alerts>
    <alerts>
        <fullName>UseCustomerRejected</fullName>
        <description>Use Customer Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/UseCustomerRejected</template>
    </alerts>
    <alerts>
        <fullName>Use_Customer_Approved_Ko</fullName>
        <description>Use Customer Approved_Ko</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/UseCustomerApproved_Ko</template>
    </alerts>
    <alerts>
        <fullName>Use_Customer_Rejected_ko</fullName>
        <description>Use Customer Rejected_ko</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/UseCustomerRejected_Ko</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateToApproved</fullName>
        <description>Update To Approved</description>
        <field>ApprovalStage__c</field>
        <literalValue>Approved</literalValue>
        <name>Update To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateToReject</fullName>
        <field>ApprovalStage__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update To Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateToRequestToUse</fullName>
        <description>Update To Request To Use</description>
        <field>ApprovalStage__c</field>
        <literalValue>Request To Use</literalValue>
        <name>Update To Request To Use</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
