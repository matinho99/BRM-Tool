trigger BusinessRoleAccessTrigger on Business_Role_Access__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(SObjectUtil.isTriggerEnabled(Business_Role_Access__c.sObjectType)) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            SObjectUtil.updateExternalId(Trigger.new, Business_Role_Access__c.External_Id__c, Business_Role_Access__c.External_Id_Calc__c);
        } else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            new BRMEngine(Trigger.new).onUpsertAccess();
        } else if(Trigger.isBefore && Trigger.isDelete) {
            new BRMEngine(Trigger.old).onDeleteAccess();
        }
    }
}