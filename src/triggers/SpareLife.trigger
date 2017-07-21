trigger SpareLife on UnrefusableOffer__c (before delete) {
    List<UnrefusableOffer__c> deleteOffers = trigger.old;
    List<FamilyEnemy__c> enemies = [SELECT Name from FamilyEnemy__c];
    
    for(UnrefusableOffer__c uo : deleteOffers) {
         for(FamilyEnemy__c fe : enemies) {
            if(fe.ID.equals(uo.FamilyEnemy__c)) {
                fe.GonnaDie__c = false;
                break;
            }
        }
    }
    
    update enemies;
}