public with sharing class DMLResult {
    private Boolean isSuccess;
    private List<Error> errors;
    
    public DMLResult(Database.SaveResult sr) {
        isSuccess = sr.isSuccess();
        errors = initErrors(sr.getErrors());
    }
    
    public DMLResult(Database.UpsertResult ur) {
        isSuccess = ur.isSuccess();
        errors = initErrors(ur.getErrors());
    }
    
    public DMLResult(Database.DeleteResult dr) {
        isSuccess = dr.isSuccess();
        errors = initErrors(dr.getErrors());
    }
    
    public static List<DMLResult> asDMLResults(List<Object> databaseResult) {
        List<DMLResult> results = new List<DMLResult>();
        
        for(Object dbResult : databaseResult) {
            if(dbResult != null && dbResult instanceof Database.SaveResult) {
            	results.add(new DMLResult((Database.SaveResult)dbResult));
            } else if(dbResult != null && dbResult instanceof Database.UpsertResult) {
                results.add(new DMLResult((Database.UpsertResult)dbResult));
            } else if(dbResult != null && dbResult instanceof Database.DeleteResult) {
                results.add(new DMLResult((Database.DeleteResult)dbResult));
            }
        }
        
        return results;
    }
    
    public Boolean isSuccess() {
        return isSuccess;
    }
    
    public List<Error> getErrors() {
        return errors;
    }
    
    private List<Error> initErrors(List<Database.Error> databaseErrors) {
        List<Error> errors = new List<Error>();
        
        for(Database.Error err : databaseErrors) {
            errors.add(new Error(err));
        }
        
        return errors;
    }
    
    public class Error {
        private System.StatusCode statusCode;
        private String message;
        
        public Error(Database.Error err) {
            statusCode = err.getStatusCode();
            message = err.getMessage();
        }
        
        public System.StatusCode getStatusCode() {
            return statusCode;
        }
        
        public String getMessage() {
            return message;
        }
    }
}