trigger BusinessRoleAccessTrigger on Business_Role_Access__c (before insert, before update) {
    if(SObjectUtil.isTriggerEnabled(Business_Role_Access__c.sObjectType)) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            SObjectUtil.updateExternalId(Trigger.new, Business_Role_Access__c.External_Id__c, Business_Role_Access__c.External_Id_Calc__c);
        }
    }
}