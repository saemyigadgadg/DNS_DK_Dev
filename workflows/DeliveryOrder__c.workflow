<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DeliveryOrderRequestInternalApproval</fullName>
        <description>Delivery Order Request Internal Approval</description>
        <protected>false</protected>
        <recipients>
            <field>InternalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DNSolutions/DO_InnerApprovalRequest</template>
    </alerts>
    <fieldUpdates>
        <fullName>DOInternalStatusToApproved</fullName>
        <description>Delivery Order Internal Approval Status를 Approved로 변경</description>
        <field>InternalApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>DOInternalStatusToApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DOInternalStatusToNotStarted</fullName>
        <description>Delivery Order Internal Approval Status를 다시 Not Started로 변경</description>
        <field>InternalApprovalStatus__c</field>
        <literalValue>Not Started</literalValue>
        <name>DOInternalStatusToNotStarted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DOInternalStatusToProcessing</fullName>
        <description>Delivery Order Internal Approval Status를 Processing으로 변경</description>
        <field>InternalApprovalStatus__c</field>
        <literalValue>Processing</literalValue>
        <name>DOInternalStatusToProcessing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateToApproved</fullName>
        <field>Status__c</field>
        <literalValue>DOInternalApproved</literalValue>
        <name>Update To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_To_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>DOCreated</literalValue>
        <name>Update To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
