public with sharing class AssassinationUtil {
    public static void createAssassinationTasks(List<UnrefusableOffer__c> newUnrefusableOffers) {
        FamilyEnemy__c dead;
        Task tsk;
        List<Task> tasks = new List<Task>();
        List<FamilyEnemy__c> enemies = [SELECT Name, FirstName__c, LastName__c, Email__c, GonnaDie__c from FamilyEnemy__c];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [Select ID, Name from EmailTemplate where Name like 'Corleone Template'];
    
        for(UnrefusableOffer__c uo : newUnrefusableOffers) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] target;
            dead = null;
            
            for(FamilyEnemy__c fe : enemies) {
                if(fe.ID.equals(uo.FamilyEnemy__c)) {
                    dead=fe;
                    dead.GonnaDie__c = true;
                    break;
                }
            }
            
            if(dead==null) {
                break;
            }
            
            target = new String[] { dead.Email__c, AssassinationEmail__c.getInstance('mosowiecki').Email__c };
            email.setTemplateID(et.ID);
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
        update enemies;
    }
}