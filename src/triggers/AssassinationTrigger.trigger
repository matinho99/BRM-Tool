trigger AssassinationTrigger on UnrefusableOffer__c (before insert) {
    FamilyEnemy__c dead;
    List<Task> tasks = new List<Task>();
    List<FamilyEnemy__c> enemies = [SELECT Name, FirstName__c, LastName__c, Email__c from FamilyEnemy__c];
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for(UnrefusableOffer__c uo : Trigger.new) {
        String[] target;
        Task tsk = new Task(Subject = 'Buying fish', WhatID = uo.FamilyEnemy__c);
        tasks.add(tsk);        
        tsk = new Task(Subject = 'Sending Death Email', WhatID = uo.FamilyEnemy__c);
        tasks.add(tsk);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        for(FamilyEnemy__c fe : enemies) {
            if(fe.ID.equals(uo.FamilyEnemy__c)) {
                dead=fe;
                break;
            }
        }
        
        target = new String[] { dead.Email__c, 'matinho99@gmail.com', 'b.osowiecki@gmail.com' };
        email.setSubject(dead.FirstName__c+' '+dead.LastName__c+' gon be dead.. like for real, dude');
        email.setHtmlBody('<html><body><h2>He gon die.. He gon to da ground, The Corleone Family gon pop his eye, he better get to da choppa!!!</h2><img src="https://thumb1.shutterstock.com/display_pic_with_logo/2714281/277212563/stock-photo-dead-fish-on-the-beach-water-pollution-concept-277212563.jpg" alt="Fish" style="width:450px;height:333px;"></body></html>');
        email.setToAddresses(target);
        emails.add(email);        
    }
    
    Messaging.sendEmail(emails);
    insert tasks;
}