trigger AssassinationTrigger on UnrefusableOffer__c (after insert, after update) {
    AssassinationUtil.createAssassinationTasks(Trigger.new);
}