public with sharing class BRMLogUtil implements Queueable {
    private transient List<Business_Role_Member_Access__c> operationRecords;
    private transient List<DMLResult> databaseResults;
    private List<Error_Log__c> newErrorLogs;
    
    public BRMLogUtil() {
        newErrorLogs = new List<Error_Log__c>();
        operationRecords = new List<Business_Role_Member_Access__c>();
        databaseResults = new List<DMLResult>();
    }
    
    public BRMLogUtil addResults(List<Business_Role_Member_Access__c> recs, List<Object> results) {
        operationRecords.addAll(recs);
        databaseResults.addAll(DMLResult.asDMLResults(results));
        return this;
    }
    
    public BRMLogUtil addErrorLogs(List<Error_Log__c> logs) {
        newErrorLogs.addAll(logs);
        return this;
    }
    
    public void setupErrorLogs() {
        Integer i = 0;
        
        for(DMLResult r : databaseResults) {
            if(!r.isSuccess()) {
                Error_Log__c el = new Error_Log__c(Business_Role__c = operationRecords.get(i).Business_Role__c, 
                                                   Business_Role_Access__c = operationRecords.get(i).Business_Role_Access__c, 
                                                   Business_Role_Member__c = operationRecords.get(i).Business_Role_Member__c);
                
                for(DMLResult.Error e : r.getErrors()) {
                    el.Description__c = (el.Description__c == null ? '' : el.Description__c) + e.getStatusCode() + ': ' + e.getMessage() + '\r\n'; 
                }
                
                newErrorLogs.add(el);
            }
            
            i++;
        }
        
        if(!newErrorLogs.isEmpty() && !Test.isRunningTest()) {
        	System.enqueueJob(this);
        } else if(!newErrorLogs.isEmpty() && Test.isRunningTest()) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                execute(null);
            }
        }
    }
    
    private void insertErrorLogs() {
        Map<Id, Boolean> roleExistMap = new Map<Id, Boolean>();
        Map<Id, Boolean> accessExistMap = new Map<Id, Boolean>();
        Map<Id, Boolean> memberExistMap = new Map<Id, Boolean>();
        
        for(Error_Log__c el : newErrorLogs) {
            roleExistMap.put(el.Business_Role__c, false);
            accessExistMap.put(el.Business_Role_Access__c, false);
            memberExistMap.put(el.Business_Role_Member__c, false);
        }
        
        for(Business_Role__c br : [Select Id from Business_Role__c where Id in :roleExistMap.keySet()]) {
            roleExistMap.put(br.Id, true);
        }
        
        for(Business_Role_Access__c bra : [Select Id from Business_Role_Access__c where Id in :accessExistMap.keySet()]) {
            accessExistMap.put(bra.Id, true);
        }
        
        for(Business_Role_Member__c brm : [Select Id from Business_Role_Member__c where Id in :memberExistMap.keySet()]) {
            memberExistMap.put(brm.Id, true);
        }
        
        for(Error_Log__c el : newErrorLogs) {
            if(roleExistMap.get(el.Business_Role__c) == false) {
                el.Business_Role__c = null;
            }
            
            if(accessExistMap.get(el.Business_Role_Access__c) == false) {
                el.Business_Role_Access__c = null;
            }
            
            if(memberExistMap.get(el.Business_Role_Member__c) == false) {
                el.Business_Role_Member__c = null;
            }
        }
        
        Database.insert(newErrorLogs);
    }
    
    public void execute(QueueableContext context) {
        insertErrorLogs();
    }
}