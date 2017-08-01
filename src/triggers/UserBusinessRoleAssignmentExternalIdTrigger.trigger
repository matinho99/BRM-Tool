trigger UserBusinessRoleAssignmentExternalIdTrigger on User_Business_Role_Assignment__c (before insert, before update) {
    if(SObjectUtil.isTriggerEnabled(User_Business_Role_Assignment__c.sObjectType)) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            SObjectUtil.updateExternalId(Trigger.new, User_Business_Role_Assignment__c.External_Id__c, User_Business_Role_Assignment__c.External_Id_Calc__c);
        }
    }
}