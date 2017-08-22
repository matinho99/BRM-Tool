trigger BusinessRoleMemberTrigger on Business_Role_Member__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(SObjectUtil.isTriggerEnabled(Business_Role_Member__c.sObjectType)) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            SObjectUtil.updateExternalId(Trigger.new, Business_Role_Member__c.External_Id__c, Business_Role_Member__c.External_Id_Calc__c);
        } else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            BRMEngine engine = new BRMEngine(Trigger.new);
            engine.setMemberAccess();
        } else if(Trigger.isBefore && Trigger.isDelete) {
            BRMEngine engine = new BRMEngine(Trigger.old);
            engine.deleteMemberAccess();
        }
    }
}