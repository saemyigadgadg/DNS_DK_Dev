<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DNSA_FieldUpdate</fullName>
        <field>Stage__c</field>
        <literalValue>Sales Review</literalValue>
        <name>DNSA_FieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Init_Update_Stage</fullName>
        <description>Stage__c 필드 업데이트</description>
        <field>Stage__c</field>
        <literalValue>Sales Approval</literalValue>
        <name>Update Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Update_Stage</fullName>
        <description>Stage__c 필드 업데이트</description>
        <field>Stage__c</field>
        <literalValue>R&amp;D Confirm</literalValue>
        <name>Update  Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage</fullName>
        <description>Stage__c 필드 업데이트</description>
        <field>Stage__c</field>
        <literalValue>Final Confirm</literalValue>
        <name>Update Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
