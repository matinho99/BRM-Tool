public with sharing class BRMEngine implements Queueable {
    private List<Business_Role_Member_Access__c> memberAccessList;
    private List<Business_Role_Member__c> memberList;
    private String operation;

    public BRMEngine() {}
    
    public BRMEngine(List<Business_Role_Member_Access__c> al) {
        memberAccessList = al;
    }
    
    public BRMEngine(List<Business_Role_Member__c> ml) {
        memberList = ml;
    }
    
    public BRMEngine(List<Business_Role_Member_Access__c> al, String op) {
        memberAccessList = al;
        operation = op;
    }
    
    public BRMEngine(List<Business_Role_Member__c> ml, String op) {
        memberList = ml;
        operation = op;
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
    
    public void setMemberAccess() {
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
        // Database.upsert(newMemberAccesses, Business_Role_Member_Access__c.External_Id__c);
    }
    
    private void setUserAssignments() {
        Map<String, SObject> accessRecords = new Map<String, SObject>();
        getInsertData(accessRecords);
        setAssignments(accessRecords);
    }
    
    private void getInsertData(Map<String, SObject> accessRecords) {
        Set<String> permissionSetNames = new Set<String>();
        Set<String> queueNames = new Set<String>();
        Set<String> publicGroupNames = new Set<String>();
        Set<String> userRoleNames = new Set<String>();
        Set<String> profileNames = new Set<String>();
        
        for(Business_Role_Member_Access__c brma : memberAccessList) {                   
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
        
        for(Business_Role_Member_Access__c brma : memberAccessList) {
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
    
    public void deleteMemberAccess() {
        List<Business_Role_Member_Access__c> maList = [Select Business_Role_Member__c from Business_Role_Member_Access__c where Business_Role_Member__c in :memberList];
        delete maList;
    }
    
    private void deleteUserAssignments() {
        Map<String, SObject> assignmentRecords = new Map<String, SObject>();
        Map<String, Id> permissionSets = new Map<String, Id>();
        Map<String, Id> groups = new Map<String, Id>();        
        getDeleteData(assignmentRecords, permissionSets, groups);
        deleteAssignments(assignmentRecords, permissionSets, groups);        
    }
    
    private void getDeleteData(Map<String, SObject> assignmentRecords, Map<String, Id> permissionSets, Map<String, Id> groups) {
        Set<String> permissionSetNames = new Set<String>();
        Set<String> groupNames = new Set<String>();
        Set<Id> userIds = new Set<Id>();
        
        for(Business_Role_Member_Access__c brma : memberAccessList) {
            userIds.add(brma.User_Id_Calc__c);
            
            if(brma.Access_Type_Calc__c == 'PermissionSet') {
                permissionSetNames.add(brma.Access_Name_Calc__c);
            } else if(brma.Access_Type_Calc__c == 'Queue' || brma.Access_Type_Calc__c == 'Group') {
                groupNames.add(brma.Access_Name_Calc__c);
            }
        }
        
        for(PermissionSet ps : [Select Id, Name from PermissionSet where Name in :permissionSetNames]) {
            permissionSets.put(ps.Name.toUpperCase(), ps.Id);
        }
        
        for(Group g : [Select Id, DeveloperName, Type from Group where DeveloperName in :groupNames and (Type = 'Queue' or Type = 'Regular')]) {
            groups.put(g.DeveloperName.toUpperCase(), g.Id);
        }
        
        for(PermissionSetAssignment psa : [Select PermissionSetId, AssigneeId from PermissionSetAssignment where PermissionSetId in :permissionSets.values() and AssigneeId in :userIds]) {
            String key = (psa.PermissionSetId + '_' + psa.AssigneeId).toUpperCase();
            assignmentRecords.put(key, psa);
        }
        
        for(GroupMember gm : [Select GroupId, UserOrGroupId from GroupMember where GroupId in :groups.values() and UserOrGroupId in :userIds]) {
            String key = (gm.GroupId + '_' + gm.UserOrGroupId).toUpperCase();
            assignmentRecords.put(key, gm);
        }
    }
    
    private void deleteAssignments(Map<String, SObject> assignmentRecords, Map<String, Id> permissionSets, Map<String, Id> groups) {
        Map<Id, User> users = new Map<Id,User>();
        List<PermissionSetAssignment> oldPermissionSetAssignments = new List<PermissionSetAssignment>();
        List<GroupMember> oldGroupMembers = new List<GroupMember>();
        
        for(Business_Role_Member_Access__c brma : memberAccessList) {
            String key;
            SObject assignmentRec;
        
            if(brma.Access_Type_Calc__c == 'UserRole') {
                if(!users.containsKey(brma.User_Id_Calc__c)) {
                    users.put(brma.User_Id_Calc__c, new User(Id = brma.User_Id_Calc__c));
                }
                
                users.get(brma.User_Id_Calc__c).UserRoleId = null;
                continue;
            } else if(brma.Access_Type_Calc__c == 'Profile') {
                continue;
            }
        
            if(brma.Access_Type_Calc__c == 'PermissionSet') {
                key = (permissionSets.get(brma.Access_Name_Calc__c.toUpperCase()) + '_' + brma.User_Id_Calc__c).toUpperCase();
            } else if(brma.Access_Type_Calc__c == 'Queue' || brma.Access_Type_Calc__c == 'Group') {
                key = (groups.get(brma.Access_Name_Calc__c.toUpperCase()) + '_' + brma.User_Id_Calc__c).toUpperCase();
            }
            
            assignmentRec = assignmentRecords.get(key);
            
            if(assignmentRec != null) {
                if(brma.Access_Type_Calc__c == 'PermissionSet') {
                    oldPermissionSetAssignments.add((PermissionSetAssignment)assignmentRec);
                } else if (brma.Access_Type_Calc__c == 'Queue' || brma.Access_Type_Calc__c == 'Group') {
                    oldGroupMembers.add((GroupMember)assignmentRec);
                }
            }
        }
        
        delete oldPermissionSetAssignments;
        delete oldGroupMembers;
        update users.values();
    }
    
    public void execute(QueueableContext context) {
        if(memberAccessList != null) {
            if(operation == 'Insert') {
                setUserAssignments();
            } else if(operation == 'Delete') {
                deleteUserAssignments();
            }
        }
    }
}