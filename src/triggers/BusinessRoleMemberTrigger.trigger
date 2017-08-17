trigger BusinessRoleMemberTrigger on Business_Role_Member__c (before insert, before update, after insert, after update) {
    if(SObjectUtil.isTriggerEnabled(Business_Role_Member__c.sObjectType)) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            SObjectUtil.updateExternalId(Trigger.new, Business_Role_Member__c.External_Id__c, Business_Role_Member__c.External_Id_Calc__c);
        } else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            BRMEngine engine = new BRMEngine();
            engine.setMemberAccess(Trigger.new);
        }
    }
}