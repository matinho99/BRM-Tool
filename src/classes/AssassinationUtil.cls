public with sharing class AssassinationUtil {
    public static void createAssassinationTasks(List<UnrefusableOffer__c> newUnrefusableOffers) {
        Task tsk;
        List<Task> tasks = new List<Task>();
        Set<Id> enemyIds = new Set<Id>();
        Map<Id, FamilyEnemy__c> enemies;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> et = new List<EmailTemplate>([Select ID, DeveloperName from EmailTemplate where DeveloperName like 'CorleoneTemplate']);
    
        for(UnrefusableOffer__c uo : newUnrefusableOffers) {
            enemyIds.add(uo.FamilyEnemy__c);
        }
        
        enemies = new Map<Id, FamilyEnemy__c>([SELECT Id, Email__c from FamilyEnemy__c where Id in :enemyIds]);
        
        for(UnrefusableOffer__c uo : newUnrefusableOffers) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] target;
            FamilyEnemy__c dead = enemies.get(uo.FamilyEnemy__c);
            
            if(dead==null) {
                break;
            }
            
            dead.GonnaDie__c = true;
            target = new String[] { dead.Email__c, AssassinationEmail__c.getInstance('mosowiecki').Email__c };
            email.setTemplateID(et.get(0).ID);
            email.setTargetObjectId(UserInfo.getUserId());
            email.setWhatId(uo.ID);
            email.setSaveAsActivity(false);
            email.setToAddresses(target);
            emails.add(email);
            tsk = new Task(Subject = 'Buying fish', WhatID = uo.FamilyEnemy__c);
            tasks.add(tsk);        
            tsk = new Task(Subject = 'Sending Death Email', WhatID = uo.FamilyEnemy__c);
            tasks.add(tsk);     
        }
        
        Database.SaveResult[] insertTasks = Database.insert(tasks, false);
        
        for(Database.SaveResult sr : insertTasks) {
            if(sr.isSuccess()) {
                System.debug('Succesfully inserted new task');
            } else {
                for(Database.Error er : sr.getErrors()) {
                    System.debug('Failed to insert new task.');
                    System.debug(er.getStatusCode() + ': ' + er.getMessage());
                }
            }
        }
        
        Messaging.sendEmail(emails);
        update enemies.values();
    }
}