trigger BusinessRoleMemberAccessTrigger on Business_Role_Member_Access__c (before insert, before update, after insert, after update, after delete) {
    if(SObjectUtil.isTriggerEnabled(Business_Role_Member_Access__c.sObjectType)) {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            SObjectUtil.updateExternalId(Trigger.new, Business_Role_Member_Access__c.External_Id__c, Business_Role_Member_Access__c.External_Id_Calc__c);
        } else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            BRMEngine engine = new BRMEngine(Trigger.new, 'Insert');
            System.enqueueJob(engine);
        } else if(Trigger.isAfter && Trigger.isDelete) {
            BRMEngine engine = new BRMEngine(Trigger.old, 'Delete');
            System.enqueueJob(engine);
        }
    }
}