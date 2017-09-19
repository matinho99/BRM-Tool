public with sharing class LogUtil implements Queueable {
    private transient List<Business_Role_Member_Access__c> operationRecords;
    private transient List<DMLResult> databaseResults;
    private List<Error_Log__c> newErrorLogs;
    
    public LogUtil() {
        newErrorLogs = new List<Error_Log__c>();
        operationRecords = new List<Business_Role_Member_Access__c>();
        databaseResults = new List<DMLResult>();
    }
    
    public LogUtil addResults(List<Business_Role_Member_Access__c> recs, List<Object> results) {
        operationRecords.addAll(recs);
        databaseResults.addAll(DMLResult.asDMLResults(results));
        return this;
    }
    
    public LogUtil addErrorLogs(List<Error_Log__c> logs) {
        newErrorLogs.addAll(logs);
        return this;
    }
    
    public void insertErrorLog() {
        Map<Id, Boolean> roleExistMap = new Map<Id, Boolean>();
        Map<Id, Boolean> accessExistMap = new Map<Id, Boolean>();
        Map<Id, Boolean> memberExistMap = new Map<Id, Boolean>();
        Integer i = 0;
        
        for(Business_Role_Member_Access__c brma : operationRecords) {
            roleExistMap.put(brma.Business_Role__c, false);
            accessExistMap.put(brma.Business_Role_Access__c, false);
            memberExistMap.put(brma.Business_Role_Member__c, false);
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
        
        for(DMLResult r : databaseResults) {
            if(!r.isSuccess()) {
                Error_Log__c el = new Error_Log__c(Business_Role__c = (roleExistMap.get(operationRecords.get(i).Business_Role__c) == true ? 
                                                                       operationRecords.get(i).Business_Role__c : null), 
                                                   Business_Role_Access__c = (accessExistMap.get(operationRecords.get(i).Business_Role_Access__c) == true ? 
                                                                              operationRecords.get(i).Business_Role_Access__c : null), 
                                                   Business_Role_Member__c = (memberExistMap.get(operationRecords.get(i).Business_Role_Member__c) == true ? 
                                                                              operationRecords.get(i).Business_Role_Member__c : null));
                
                for(DMLResult.Error e : r.getErrors()) {
                    el.Description__c = (el.Description__c == null ? '' : el.Description__c) + e.getStatusCode() + ': ' + e.getMessage() + '\r\n'; 
                }
                
                newErrorLogs.add(el);
            }
            
            i++;
        }
        
        if(!newErrorLogs.isEmpty()) {
        	System.enqueueJob(this);
        }
    }
    
    public void execute(QueueableContext context) {
        Database.insert(newErrorLogs);
    }
}