trigger BusinessRoleMemberTrigger on Business_Role_Member__c (before insert, before update, before delete, after insert, after update) {
    if(SObjectUtil.isTriggerEnabled(Business_Role_Member__c.sObjectType)) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            SObjectUtil.updateExternalId(Trigger.new, Business_Role_Member__c.External_Id__c, Business_Role_Member__c.External_Id_Calc__c);
        } else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            new BRMEngine(Trigger.new).onUpsertMember();
        } else if(Trigger.isBefore && Trigger.isDelete) {
            new BRMEngine(Trigger.old).onDeleteMember();
        }
    }
}