@isTest
public class BRMTestUtil {
    public static void createUsers(List<String> userDataList) {
        List<User> testUsersList = new List<User>();
        Set<String> profileNames = new Set<String>();
        Map<String, Id> profileIdsMap = new Map<String, Id>();
        
        for(String s : userDataList) {
            List<String> splitList = s.split('\\|');
            profileNames.add(splitList.get(8));
        }
        
        for(Profile p : [Select Id, Name from Profile where Name in :profileNames]) {
            profileIdsMap.put(p.Name, p.Id);
        }
        
        for(String s : userDataList) {
            List<String> splitList = s.split('\\|');
            testUsersList.add(new User(FirstName = splitList.get(0), LastName = splitList.get(1), Email = splitList.get(2), Alias = splitList.get(3), Username = splitList.get(4), 
                                       CommunityNickname = splitList.get(5), LocaleSidKey = splitList.get(6), TimeZoneSidKey = splitList.get(7), 
                                       ProfileId = profileIdsMap.get(splitList.get(8)), EmailEncodingKey = splitList.get(9), LanguageLocaleKey = splitList.get(10)));
        }
                    
        Database.insert(testUsersList);
    }
    
    public static void createPermissionSets(List<String> psDataList) {
        List<PermissionSet> testPermissionSetsList = new List<PermissionSet>();
        
        for(String s : psDataList) {
            List<String> splitList = s.split('\\|');
            testPermissionSetsList.add(new PermissionSet(Label = splitList.get(0), Name = splitList.get(1)));
        }
        
        Database.insert(testPermissionSetsList);
    }
    
    public static void createGroups(List<String> groupDataList) {
        List<Group> testGroupsList = new List<Group>();
        
        for(String s :groupDataList) {
            List<String> splitList = s.split('\\|');
            testGroupsList.add(new Group(Type = splitList.get(0), DeveloperName = splitList.get(1), Name = splitList.get(2)));
        }
        
        Database.insert(testGroupsList);
    }
    
    public static void createBusinessRoles(List<String> brDataList) {
        List<Business_Role__c> testBusinessRolesList = new List<Business_Role__c>();
        
        for(String s :brDataList) {
            testBusinessRolesList.add(new Business_Role__c(Name = s));
        }
        
        Database.insert(testBusinessRolesList);
    }
    
    public static void createAccesses(List<String> accessDataList) {
        List<Business_Role_Access__c> testBusinessRoleAccessesList = new List<Business_Role_Access__c>();
        Set<String> roleNames = new Set<String>();
        Map<String, Id> roleIdsMap = new Map<String, Id>();
        
        for(String s : accessDataList) {
            List<String> splitList = s.split('\\|');
            roleNames.add(splitList.get(2));
        }
        
        for(Business_Role__c br : [Select Id, Name from Business_Role__c where Name in :roleNames]) {
            roleIdsMap.put(br.Name, br.Id);
        }
        
        for(String s :accessDataList) {
            List<String> splitList = s.split('\\|');
             testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = splitList.get(0), Type__c = splitList.get(1), 
                                                                     Business_Role__c = roleIdsMap.get(splitList.get(2))));
        }
        
        Database.insert(testBusinessRoleAccessesList);
    }
    
    public static void removeAccesses(Boolean onlyDeactivate, List<String> accessDataList) {
        List<Business_Role_Access__c> testBusinessRoleAccessesList = new List<Business_Role_Access__c>();
        Set<String> accessKeys = new Set<String>();
        
        for(String s : accessDataList) {
             List<String> splitList = s.split('\\|');
             accessKeys.add(splitList.get(0) + '_' + splitList.get(1) + '_' + splitList.get(2));
        }
        
        for(Business_Role_Access__c bra : [Select Id, Is_Active__c, External_Id__c from Business_Role_Access__c where External_Id__c in :accessKeys]) {
            testBusinessRoleAccessesList.add(bra);
            
            if(onlyDeactivate) {
                bra.Is_Active__c = false;
            }
        }
        
        if(onlyDeactivate) {
            Database.update(testBusinessRoleAccessesList);
        } else {
            Database.delete(testBusinessRoleAccessesList);
        }
    }
    
    public static void createMembers(List<String> memberDataList) {
        List<Business_Role_Member__c> testBusinessRoleMembersList = new List<Business_Role_Member__c>();
        Set<String> userNames = new Set<String>();
        Set<String> roleNames = new Set<String>();
        Map<String, Id> userIdsMap = new Map<String, Id>();
        Map<String, Id> roleIdsMap = new Map<String, Id>();
        
        for(String s : memberDataList) {
            List<String> splitList = s.split('\\|');
            userNames.add(splitList.get(0));
            roleNames.add(splitList.get(1));
        }
        
        for(User u : [Select Id, Name from User where Name in :userNames]) {
            userIdsMap.put(u.Name, u.Id);
        }
        
        for(Business_Role__c br : [Select Id, Name from Business_Role__c where Name in :roleNames]) {
            roleIdsMap.put(br.Name, br.Id);
        }
        
        for(String s : memberDataList) {
            List<String> splitList = s.split('\\|');
            testBusinessRoleMembersList.add(new Business_Role_Member__c(User__c = userIdsMap.get(splitList.get(0)), Business_Role__c = roleIdsMap.get(splitList.get(1))));
        }
        
        Database.insert(testBusinessRoleMembersList);
    }
    
    public static void removeMembers(Boolean onlyDeactivate, List<String> memberDataList) {
        List<Business_Role_Member__c> testBusinessRoleMembersList = new List<Business_Role_Member__c>();
        Set<String> userNames = new Set<String>();
        Set<String> roleNames = new Set<String>();
        Set<String> memberKeys = new Set<String>();
        
        for(String s : memberDataList) {
            List<String> splitList = s.split('\\|');
            userNames.add(splitList.get(0));
            roleNames.add(splitList.get(1));
            memberKeys.add((splitList.get(0) + '_' + splitList.get(1)).toUpperCase());
        }
        
        for(Business_Role_Member__c brm : [Select User__r.Name, Business_Role__r.Name, Is_Active__c from Business_Role_Member__c 
                                           where User__r.Name in :userNames and Business_Role__r.Name in :roleNames]) {
            if(memberKeys.contains((brm.User__r.Name + '_' + brm.Business_Role__r.Name).toUpperCase())) {
                testBusinessRoleMembersList.add(brm);
                
                if(onlyDeactivate) {
                    brm.Is_Active__c = false;
                }
            }
        }
        
        if(onlyDeactivate) {
            Database.update(testBusinessRoleMembersList);
        } else {
        	Database.delete(testBusinessRoleMembersList);
        }
    }
    
    public static void assertAccesses(List<String> accessDataList) {
        Set<String> accessNames = new Set<String>();
        Set<String> accessTypes = new Set<String>();
        Set<String> roleNames = new Set<String>();
        Set<String> accessKeys = new Set<String>();
        
        for(String s : accessDataList) {
            List<String> splitList = s.split('\\|');
            accessNames.add(splitList.get(1));
            accessTypes.add(splitList.get(2));
            roleNames.add(splitList.get(3));
        }
        
        for(Business_Role_Access__c bra : [Select Name, Type__c, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c where Name in :accessNames and Type__c in :accessTypes 
                                          and Business_Role__r.Name in :roleNames]) {
            String key = (bra.Name + '_' + bra.Type__c + '_' + bra.Business_Role__r.Name + '_' + bra.Is_Active__c).toUpperCase();
            accessKeys.add(key);
        }
        
        for(String s : accessDataList) {
            String msg;
            List<String> splitList = s.split('\\|');
            String key = (splitList.get(1) + '_' + splitList.get(2) + '_' + splitList.get(3) + '_' + Boolean.valueOf(splitList.get(4))).toUpperCase();
            
            if(Boolean.valueOf(splitList.get(0))) {
                msg = '{' + splitList.get(3) + ' business role - ' + splitList.get(1) + ' of type ' + splitList.get(2) + ' access} access should exist';
                
                if(!Boolean.valueOf(splitList.get(3))) {
                    msg = msg + ' and be deactivated';
                }
            } else {
                msg = '{' + splitList.get(3) + ' business role - ' + splitList.get(1) + ' of type ' + splitList.get(2) + ' access} access should not exist';
            }
            
            System.assertEquals(Boolean.valueOf(splitList.get(0)), accessKeys.contains(key), msg);
        }
    }
    
    public static void assertMembers(List<String> memberDataList) {
        Set<String> roleNames = new Set<String>();
        Set<String> userNames = new Set<String>();
        Set<String> memberKeys = new Set<String>();
        
        for(String s : memberDataList) {
            List<String> splitList = s.split('\\|');
            userNames.add(splitList.get(1));
            roleNames.add(splitList.get(2));
        }
        
        for(Business_Role_Member__c brm : [Select User__r.Name, Business_Role__r.Name, Is_Active__c from Business_Role_Member__c 
                                          where User__r.Name in :userNames and Business_Role__r.Name in :roleNames]) {
            String key = (brm.User__r.Name + '_' + brm.Business_Role__r.Name + '_' + brm.Is_Active__c).toUpperCase();
			memberKeys.add(key);
        }
        
        for(String s : memberDataList) {
            String msg;
            List<String> splitList = s.split('\\|');
            String key = (splitList.get(1) + '_' + splitList.get(2) + '_' + Boolean.valueOf(splitList.get(3))).toUpperCase();
            
            if(Boolean.valueOf(splitList.get(0))) {
                msg = '{' + splitList.get(2) + ' business role - ' + splitList.get(1) + ' user} member should exist';
                
                if(!Boolean.valueOf(splitList.get(3))) {
                    msg = msg + ' and be deactivated';
                }
            } else {
                msg = '{' + splitList.get(2) + ' business role - ' + splitList.get(1) + ' user} member should not exist';
            }
            
            System.assertEquals(Boolean.valueOf(splitList.get(0)), memberKeys.contains(key), msg);
        }
    }
    
    public static void assertMemberAccesses(List<String> memberAccessDataList) {
        Set<String> userNames = new Set<String>();
        Set<String> roleNames = new Set<String>();
        Set<String> accessNames = new Set<String>();
        Map<Id, String> userMap = new Map<Id, String>();
        Set<String> memberAccessKeys = new Set<String>();
        
        for(String s : memberAccessDataList) {
            List<String> splitList = s.split('\\|');
            accessNames.add(splitList.get(2));
            userNames.add(splitList.get(3));
            roleNames.add(splitList.get(4));
        }
        
        for(User u : [Select Id, Name from User where Name in :userNames]) {
            userMap.put(u.Id, u.Name);
        }
        
        for(Business_Role_Member_Access__c brma : [Select Access_Type_Calc__c, Access_Name_Calc__c, User_Id_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                                   where Access_Name_Calc__c in :accessNames and User_Id_Calc__c in :userMap.keySet() and Business_Role__r.Name in :roleNames]) {
        	String key = (brma.Access_Type_Calc__c + '_' + brma.Access_Name_Calc__c + '_' + userMap.get(brma.User_Id_Calc__c) + '_' + brma.Business_Role__r.Name).toUpperCase();
            memberAccessKeys.add(key);
        }
        
        for(String s : memberAccessDataList) {
            String msg;
            List<String> splitList = s.split('\\|');
            String key = (splitList.get(1) + '_' + splitList.get(2) + '_' + splitList.get(3) + '_' + splitList.get(4)).toUpperCase();
            
            if(Boolean.valueOf(splitList.get(0))) {
                msg = '{' + splitList.get(4) + ' business role - ' + splitList.get(3) + ' user - ' + splitList.get(2) + ' of type ' + splitList.get(1) + ' access} member access should exist';
            } else {
                msg = '{' + splitList.get(4) + ' business role - ' + splitList.get(3) + ' user - ' + splitList.get(2) + ' of type ' + splitList.get(1) + ' access} member access should not exist';
            }
            
            System.assertEquals(Boolean.valueOf(splitList.get(0)), memberAccessKeys.contains(key), msg);
        }
    }
    
    public static void assertPermissionSets(List<String> psDataList) {
        Set<String> permissionSetNames = new Set<String>();
        Set<String> userNames = new Set<String>();
        Set<String> permissionSetKeys = new Set<String>();
        
        for(String s : psDataList) {
            List<String> splitList = s.split('\\|');
            permissionSetNames.add(splitList.get(1));
            userNames.add(splitList.get(2));
        }
        
        for(PermissionSetAssignment psa : [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name in :permissionSetNames 
                                           and Assignee.Name in :userNames]) {
            String key = (psa.PermissionSet.Name + '_' + psa.Assignee.Name).toUpperCase();
            permissionSetKeys.add(key);
        }
        
        for(String s : psDataList) {
            String msg;
            List<String> splitList = s.split('\\|');
            String key = (splitList.get(1) + '_' + splitList.get(2)).toUpperCase();
            
            if(Boolean.valueOf(splitList.get(0))) {
                msg = '{' + splitList.get(1) + ' permission set - ' + splitList.get(2) + ' user} assignment should exist';
            } else {
                msg = '{' + splitList.get(1) + ' permission set - ' + splitList.get(2) + ' user} assignment should not exist';
            }
            
            System.assertEquals(Boolean.valueOf(splitList.get(0)), permissionSetKeys.contains(key), msg);
        }
    }
    
    public static void assertGroups(List<String> groupDataList) {
        Set<String> groupNames = new Set<String>();
        Set<String> userNames = new Set<String>();
        Map<Id, String> userMap = new Map<Id, String>();
        Set<String> groupKeys = new Set<String>();
        
        for(String s : groupDataList) {
            List<String> splitList = s.split('\\|');
            groupNames.add(splitList.get(2));
            userNames.add(splitList.get(3));
        }
        
        for(User u : [Select Id, Name from User where Name in :userNames]) {
            userMap.put(u.Id, u.Name);
        }
        
        for(GroupMember gm : [Select Group.DeveloperName, Group.Type, UserOrGroupId from GroupMember where Group.DeveloperName in :groupNames and UserOrGroupId in :userMap.keySet()]) {
            String key = (gm.Group.Type + '_' + gm.Group.DeveloperName + '_' + userMap.get(gm.UserOrGroupId)).toUpperCase();
            groupKeys.add(key);
        }
        
        for(String s : groupDataList) {
            String msg;
            List<String> splitList = s.split('\\|');
            String key = (splitList.get(1) + '_' + splitList.get(2) + '_' + splitList.get(3)).toUpperCase();
            
            if(Boolean.valueOf(splitList.get(0))) {
                msg = '{' + splitList.get(2) + ' of type ' + splitList.get(1) + ' group - ' + splitList.get(3) + ' user} assignment should exist';
            } else {
                msg = '{' + splitList.get(2) + ' of type ' + splitList.get(1) + ' group - ' + splitList.get(3) + ' user} assignment should not exist';
            }
            
            System.assertEquals(Boolean.valueOf(splitList.get(0)), groupKeys.contains(key), msg);
        }
    }
    
    public static void assertUserRoles(List<String> userRoleDataList) {
        Set<String> userNames = new Set<String>();
        Set<String> userRoleKeys = new Set<String>();
        
        for(String s : userRoleDataList) {
            List<String> splitList = s.split('\\|');
            userNames.add(splitList.get(0));
        }
        
        for(User u : [Select Name, UserRole.DeveloperName from User where Name in :userNames]) {
            String key = (u.Name + '_' + u.UserRole.DeveloperName).toUpperCase();
            userRoleKeys.add(key);
        }
        
        for(String s : userRoleDataList) {
            String msg;
            List<String> splitList = s.split('\\|');
            String key = (splitList.get(0) + '_' + splitList.get(1)).toUpperCase();
            
            if(splitList.get(1) == 'null') {
                msg = splitList.get(0) + ' user should have no user role';
            } else {
                msg = splitList.get(0) + ' user should have ' + splitList.get(1) + ' user role';
            }
            
            System.assertEquals(true, userRoleKeys.contains(key), msg);
        }
    }
    
    public static void assertProfiles(List<String> profileDataList) {
        Set<String> userNames = new Set<String>();
        Set<String> profileKeys = new Set<String>();
        
        for(String s : profileDataList) {
            List<String> splitList = s.split('\\|');
            userNames.add(splitList.get(0));
        }
        
        for(User u : [Select Name, Profile.Name from User where Name in :userNames]) {
            String key = (u.Name + '_' + u.Profile.Name).toUpperCase();
            profileKeys.add(key);
        }
        
        for(String s : profileDataList) {
            List<String> splitList = s.split('\\|');
            String key = (splitList.get(0) + '_' + splitList.get(1)).toUpperCase();
            String msg = splitList.get(0) + ' user should have ' + splitList.get(1) + 'user role';
            System.assertEquals(true, profileKeys.contains(key), msg);
        }
    }
}