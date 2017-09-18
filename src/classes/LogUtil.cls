public with sharing class LogUtil implements Queueable {
    private transient List<Business_Role_Member_Access__c> operationRecords;
    private transient List<DMLResult> databaseResults;
    private List<Error_Log__c> newErrorLogs;
    
    public LogUtil() {
        operationRecords = new List<Business_Role_Member_Access__c>();
        databaseResults = new List<DMLResult>();
    }
    
    public LogUtil addResults(List<Business_Role_Member_Access__c> recs, List<Object> results) {
        operationRecords.addAll(recs);
        databaseResults.addAll(DMLResult.asDMLResults(results));
        return this;
    }
    
    public void insertErrorLog() {
        newErrorLogs = new List<Error_Log__c>();
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
        
        if(!newErrorLogs.isEmpty()) {
        	System.enqueueJob(this);
        }
    }
    
    public void execute(QueueableContext context) {
        Database.insert(newErrorLogs);
    }
}