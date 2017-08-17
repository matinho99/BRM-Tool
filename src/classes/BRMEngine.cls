public with sharing class BRMEngine implements Queueable {
    private List<Business_Role_Member_Access__c> assignmentList;

    public BRMEngine() {
        assignmentList = null;
    }
    
    public BRMEngine(List<Business_Role_Member_Access__c> al) {
        assignmentList = al;
    }
 
    private void cacheAccessRecord(String accessType, Map<String, SObject> dest, List<SObject> recs, Schema.SObjectField fld) {
        if(recs == null) {
            return;
        }
        
        for(SObject r : recs) {
            String key = (accessType+ r.get(String.valueOf(fld))).toUpperCase();
            dest.put(key, r);
        }
    }
    
    private void getAccessData(Map<String, SObject> accessRecords) {
        Set<Id> roleIds = new Set<Id>();
        Set<String> permissionSetNames = new Set<String>();
        Set<String> queueNames = new Set<String>();
        Set<String> publicGroupNames = new Set<String>();
        Set<String> userRoleNames = new Set<String>();
        Set<String> profileNames = new Set<String>();
        
        for(Business_Role_Member_Access__c brma : assignmentList) {                   
            if(brma.Access_Type_Calc__c == 'PermissionSet') {
                permissionSetNames.add(brma.Access_Name_Calc__c);
            } else if (brma.Access_Type_Calc__c == 'Queue') {
                queueNames.add(brma.Access_Name_Calc__c);
            } else if (brma.Access_Type_Calc__c == 'Group') {
                publicGroupNames.add(brma.Access_Name_Calc__c);
            } else if (brma.Access_Type_Calc__c == 'UserRole') {
                userRoleNames.add(brma.Access_Name_Calc__c);
            } else if (brma.Access_Type_Calc__c == 'Profile') {
                profileNames.add(brma.Access_Name_Calc__c);
            }
        }
        
        cacheAccessRecord('PermissionSet', accessRecords, !permissionSetNames.isEmpty() ? [Select Id, Name from PermissionSet where Name in :permissionSetNames] : null, PermissionSet.Name);
        cacheAccessRecord('Queue', accessRecords, !queueNames.isEmpty() ? [Select Id, DeveloperName from Group where Type = 'Queue' and DeveloperName in :queueNames] : null, Group.DeveloperName);
        cacheAccessRecord('Group', accessRecords, !publicGroupNames.isEmpty() ? [Select Id, DeveloperName from Group where Type = 'Regular' and DeveloperName in :publicGroupNames] : null, Group.DeveloperName);
        cacheAccessRecord('UserRole', accessRecords, !userRoleNames.isEmpty() ? [Select Id, DeveloperName from UserRole where DeveloperName in :userRoleNames] : null, UserRole.DeveloperName);
        cacheAccessRecord('Profile', accessRecords, !profileNames.isEmpty() ? [Select Id, Name from Profile where Name in :profileNames] : null, Profile.Name);
    }
    
    private void setAssignments(Map<String, SObject> accessRecords) {
        Map<Id, User> users = new Map<Id, User>();
        List<PermissionSetAssignment> newPermissionSetAssignments = new List<PermissionSetAssignment>();
        List<GroupMember> newGroupAssignments = new List<GroupMember>();
        
        for(Business_Role_Member_Access__c brma : assignmentList) {
            String key = (brma.Access_Type_Calc__c + brma.Access_Name_Calc__c).toUpperCase();
            SObject accessRec = accessRecords.get(key);
             
            if(accessRec != null) {
                if(brma.Access_Type_Calc__c == 'PermissionSet') {
                    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = accessRec.Id, AssigneeId = brma.User_Id_Calc__c);
                    newPermissionSetAssignments.add(psa);
                } else if (brma.Access_Type_Calc__c == 'Queue') {
                    GroupMember gm = new GroupMember(GroupId = accessRec.Id, UserOrGroupId = brma.User_Id_Calc__c);    
                    newGroupAssignments.add(gm);
                } else if (brma.Access_Type_Calc__c == 'Group') {
                    GroupMember gm = new GroupMember(GroupId = accessRec.Id, UserOrGroupId = brma.User_Id_Calc__c);                   
                    newGroupAssignments.add(gm);
                } else if (brma.Access_Type_Calc__c == 'UserRole') {
                    if(!users.containsKey(brma.User_Id_Calc__c)) {
                        users.put(brma.User_Id_Calc__c, new User(Id = brma.User_Id_Calc__c));
                    }
                    
                    users.get(brma.User_Id_Calc__c).UserRoleId = accessRec.Id;
                } else if (brma.Access_Type_Calc__c == 'Profile') {
                    if(!users.containsKey(brma.User_Id_Calc__c)) {
                        users.put(brma.User_Id_Calc__c, new User(Id = brma.User_Id_Calc__c));
                    }
                    
                    users.get(brma.User_Id_Calc__c).ProfileId = accessRec.Id;               
                }
            }                
        }
        
        insert newPermissionSetAssignments;
        insert newGroupAssignments;
        update users.values();
    }
    
    public void setMemberAccess(List<Business_Role_Member__c> memberList) {
        Set<Id> roleIds = new Set<Id>();
        Map<Id, List<Business_Role_Access__c>> roleAccessMap = new Map<Id, List<Business_Role_Access__c>>();
        List<Business_Role_Member_Access__c> newMemberAccesses = new List<Business_Role_Member_Access__c>();
        
        for(Business_Role_Member__c brm : memberList) {
            roleIds.add(brm.Business_Role__c);
        }
        
        for(Business_Role_Access__c bra : [Select Name, Type__c, Business_Role__c from Business_Role_Access__c where Business_Role__c in :roleIds and Is_Active__c = true]) {
            if(!roleAccessMap.containsKey(bra.Business_Role__c)) {
                roleAccessMap.put(bra.Business_Role__c, new List<Business_Role_Access__c>());
            }
            
            roleAccessMap.get(bra.Business_Role__c).add(bra);
        }
        
        for(Business_Role_Member__c brm : memberList) {
            if(roleAccessMap.containsKey(brm.Business_Role__c)) {
                for(Business_Role_Access__c bra : roleAccessMap.get(brm.Business_Role__c)) {
                    Business_Role_Member_Access__c brma = new Business_Role_Member_Access__c();
                    brma.Business_Role__c = brm.Business_Role__c;
                    brma.Business_Role_Member__c = brm.Id;
                    brma.Business_Role_Access__c = bra.Id;
                    newMemberAccesses.add(brma);
                }
            }
        }
        
        insert newMemberAccesses;
    }
    
    public void setUserAssignments() {
        Map<String, SObject> accessRecords = new Map<String, SObject>();
        getAccessData(accessRecords);
        setAssignments(accessRecords);
    }
    
    public void execute(QueueableContext context) {
        setUserAssignments();
    }
}