@isTest
private class BRMEngineTest {
    private static testMethod void insertDeleteMemberTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            List<Business_Role_Member__c> testInsertMemberList = new List<Business_Role_Member__c>();
            List<Business_Role_Member__c> testDeleteMemberList = new List<Business_Role_Member__c>();
            testInsertMemberList.add(new Business_Role_Member__c(User__c = [Select Id, Name from User where Name = 'Test One'].Id,
                                                                        Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testInsertMemberList.add(new Business_Role_Member__c(User__c = [Select Id, Name from User where Name = 'Test Two'].Id,
                                                                        Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            testDeleteMemberList.add(testInsertMemberList.get(1));
            Test.startTest();
            Database.insert(testInsertMemberList);
            Database.delete(testDeleteMemberList);
			Test.stopTest();
            
            System.assertEquals(1, [Select Id from Business_Role_Member__c].size(), 'Invalid number of test members');
            System.assertEquals(1, [Select User__r.Name, Business_Role__r.Name from Business_Role_Member__c where User__r.Name = 'Test One' 
                                    and Business_Role__r.Name = 'Test Admin' limit 1].size(), '{Test Admin business role - Test One user} member should exist');
            System.assertEquals(0, [Select User__r.Name, Business_Role__r.Name from Business_Role_Member__c where User__r.Name = 'Test Two' 
                                    and Business_Role__r.Name = 'Test Viewer' limit 1].size(), '{Test Viewer business role - Test Two user} member should exist');
            System.assertEquals(0, [Select User__r.Name, Business_Role__r.Name from Business_Role_Member__c where User__r.Name = 'Test One' 
                                    and Business_Role__r.Name = 'Test Viewer' limit 1].size(), '{Test Viewer business role - Test One user} member should not exist');
            System.assertEquals(0, [Select User__r.Name, Business_Role__r.Name from Business_Role_Member__c where User__r.Name = 'Test Two' 
                                    and Business_Role__r.Name = 'Test Admin' limit 1].size(), '{Test Admin business role - Test Two user} member should not exist');
            System.assertEquals(7, [Select Id from Business_Role_Member_Access__c].size(), 'Invalid number of test member accesses');
            
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'PermissionSet' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'Test_Admin_PS' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - Test_Admin_PS of type PermissionSet access} member access should exist');
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Queue' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'TestAdminQueue' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - TestAdminQueue of type Queue access} member access should exist');
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Group' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'TestAdminGroup' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - TestAdminGroup of type Group access} member access should exist');
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'PermissionSet' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'Test_Fake_PS' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - Test_Fake_PS of type PermissionSet access} member access should exist');
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Group' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'TestFakeGroup' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - TestFakeGroup of type Group access} member access should exist');
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Profile' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'Standard Platform User' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - Standard Platform User of type Profile access} member access should exist');
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'UserRole' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'CEO' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - CEO of type UserRole access} member access should exist');
            
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'PermissionSet' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test Two'].Id 
                                    and Access_Name_Calc__c = 'Test_Viewer_PS' and Business_Role__r.Name = 'Test Viewer' limit 1].size(), 
                                '{Test Viewer business role - Test Two user - Test_Viewer_PS of type PermissionSet access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Queue' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test Two'].Id 
                                    and Access_Name_Calc__c = 'TestViewerQueue' and Business_Role__r.Name = 'Test Viewer' limit 1].size(), 
                                '{Test Viewer business role - Test Two user - TestViewerQueue of type Queue access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Group' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test Two'].Id 
                                    and Access_Name_Calc__c = 'TestViewerGroup' and Business_Role__r.Name = 'Test Viewer' limit 1].size(), 
                                '{Test Viewer business role - Test Two user - TestViewerGroup of type Group access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'PermissionSet' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test Two'].Id 
                                    and Access_Name_Calc__c = 'Test_Fake_PS' and Business_Role__r.Name = 'Test Viewer' limit 1].size(), 
                                '{Test Viewer business role - Test Two user - Test_Fake_PS of type PermissionSet access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Queue' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test Two'].Id 
                                    and Access_Name_Calc__c = 'TestFakeQueue' and Business_Role__r.Name = 'Test Viewer' limit 1].size(), 
                                '{Test Viewer business role - Test Two user - TestFakeQueue of type Queue access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Profile' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test Two'].Id 
                                    and Access_Name_Calc__c = 'Standard Platform User' and Business_Role__r.Name = 'Test Viewer' limit 1].size(), 
                                '{Test Viewer business role - Test Two user - Standard Platform User of type Profile access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'UserRole' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test Two'].Id 
                                    and Access_Name_Calc__c = 'MarketingTeam' and Business_Role__r.Name = 'Test Viewer' limit 1].size(), 
                                '{Test Viewer business role - Test Two user - MarketingTeam of type UserRole access} member access should not exist');
            
            System.assertEquals(1, [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name = 'Test_Admin_PS' 
                                    and Assignee.Name = 'Test One' limit 1].size(), '{Test_Admin_PS permission set - Test One user} assignment should exist');
            System.assertEquals(0, [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name = 'Test_Fake_PS' 
                                    and Assignee.Name = 'Test One' limit 1].size(), '{Test_Fake_PS permission set - Test One user} assignment should not exist');
            System.assertEquals(1, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestAdminQueue' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test One'].Id limit 1].size(), 
                                '{TestAdminQueue group - Test One user} assignment should exist');
            System.assertEquals(1, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestAdminGroup' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test One'].Id limit 1].size(), 
                                '{TestAdminGroup group - Test One user} assignment should exist');
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestFakeGroup' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test One'].Id limit 1].size(), 
                                '{TestFakeGroup group - Test One user} assignment should not exist');
            System.assertEquals('CEO', [Select Name, UserRole.DeveloperName from User where Name = 'Test One'].UserRole.DeveloperName, 
                                'Test One user should have CEO user role');
            System.assertEquals('Standard Platform User', [Select Name, Profile.Name from User where Name = 'Test One'].Profile.Name, 
                                'Test One user should have Standard Platform User profile');
            
            System.assertEquals(0, [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name = 'Test_Viewer_PS' 
                                    and Assignee.Name = 'Test Two' limit 1].size(), '{Test_Viewer_PS permission set - Test Two user} assignment should not exist');
            System.assertEquals(0, [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name = 'Test_Fake_PS' 
                                    and Assignee.Name = 'Test Two' limit 1].size(), '{Test_Fake_PS permission set - Test Two user} assignment should not exist');
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestViewerQueue' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test Two'].Id limit 1].size(), 
                                '{TestViewerQueue group - Test Two user} assignment should not exist');
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestViewerGroup' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test Two'].Id limit 1].size(), 
                                '{TestViewerGroup group - Test Two user} assignment should not exist');
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestFakeQueue' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test Two'].Id limit 1].size(), 
                                '{TestFakeQueue group - Test Two user} assignment should not exist');
            System.assertEquals(null, [Select Name, UserRoleId from User where Name = 'Test Two'].UserRoleId, 'Test Two user should have no user role');
            System.assertEquals('Standard Platform User', [Select Name, Profile.Name from User where Name = 'Test Two'].Profile.Name, 
                                'Test Two user should have Standard Platform User profile');
        }
    }
    
    private static testMethod void deactivateMemberTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Business_Role_Member__c testMember = new Business_Role_Member__c(User__c = [Select Id, Name from User where Name = 'Test One'].Id, 
                                                                  Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id);
            Test.startTest();
            Database.insert(testMember);
            testMember.Is_Active__c = false;
            Database.update(testMember);
            Test.stopTest();
            
            System.assertEquals(1, [Select Id from Business_Role_Member__c].size(), 'Invalid number of test members');
            System.assertEquals(1, [Select User__r.Name, Business_Role__r.Name, Is_Active__c from Business_Role_Member__c where User__r.Name = 'Test One' 
                                    and Business_Role__r.Name = 'Test Admin' and Is_Active__c = false limit 1].size(), 
                                '{Test Admin business role - Test One user} member should exist and be deactivated');
            System.assertEquals(0, [Select Id from Business_Role_Member_Access__c].size(), 'Invalid number of test member accesses');
            System.assertEquals(0, [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name = 'Test_Admin_PS' 
                                    and Assignee.Name = 'Test One' limit 1].size(), '{Test_Admin_PS permission set - Test One user} assignment should not exist');
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestAdminQueue' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test One'].Id limit 1].size(), 
                                '{TestAdminQueue group - Test One user} assignment should not exist');
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestAdminGroup' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test One'].Id limit 1].size(), 
                                '{TestAdminGroup group - Test One user} assignment should not exist');
            System.assertEquals(null, [Select Name, UserRoleId from User where Name = 'Test One'].UserRoleId, 'Test One user should have no user role');
            System.assertEquals('Standard Platform User', [Select Name, Profile.Name from User where Name = 'Test One'].Profile.Name, 
                                'Test One user should have Standard Platform User profile');
        }
    }
    
    private static testMethod void insertDeleteAccessTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            List<Business_Role_Access__c> testInsertAccessList = new List<Business_Role_Access__c>();
            List<Business_Role_Access__c> testDeleteAccessList = new List<Business_Role_Access__c>();
            testDeleteAccessList.add([Select Name, Type__c, Business_Role__c from Business_Role_Access__c where Name = 'Test_Admin_PS' and Type__c = 'PermissionSet' 
                                     and Business_Role__c = :[Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id limit 1]);
            testDeleteAccessList.add([Select Name, Type__c, Business_Role__c from Business_Role_Access__c where Name = 'Test_Fake_PS' and Type__c = 'PermissionSet' 
                                     and Business_Role__c = :[Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id limit 1]);
            testDeleteAccessList.add([Select Name, Type__c, Business_Role__c from Business_Role_Access__c where Name = 'TestAdminGroup' and Type__c = 'Group' 
                                     and Business_Role__c = :[Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id limit 1]);
            testInsertAccessList.add(new Business_Role_Access__c(Name = 'BRM_Admin', Type__c = 'PermissionSet', 
                                                                 Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            Test.startTest();
            Database.insert(new Business_Role_Member__c(User__c = [Select Id, Name from User where Name = 'Test One'].Id,
                                                        Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            Database.insert(testInsertAccessList);
            Database.delete(testDeleteAccessList);
            Test.stopTest();
            
            System.assertEquals(5, [Select Id, Business_Role__r.Name from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin'].size(), 
                                'Invalid number of Test Admin accesses');
            System.assertEquals(1, [Select Name, Type__c, Business_Role__r.Name from Business_Role_Access__c where Name = 'BRM_Admin' and Type__c = 'PermissionSet' 
                                    and Business_Role__r.Name = 'Test Admin' limit 1].size(), '{Test Admin business role - BRM_Admin of type PermissionSet access} access should exist');
            System.assertEquals(0, [Select Name, Type__c, Business_Role__r.Name from Business_Role_Access__c where Name = 'Test_Admin_PS' and Type__c = 'PermissionSet' 
                                    and Business_Role__r.Name = 'Test Admin' limit 1].size(), '{Test Admin business role - Test_Admin_PS of type PermissionSet access} access should not exist');
            System.assertEquals(0, [Select Name, Type__c, Business_Role__r.Name from Business_Role_Access__c where Name = 'Test_Fake_PS' and Type__c = 'PermissionSet' 
                                    and Business_Role__r.Name = 'Test Admin' limit 1].size(), '{Test Admin business role - Test_Fake_PS of type PermissionSet access} access should not exist');
            System.assertEquals(0, [Select Name, Type__c, Business_Role__r.Name from Business_Role_Access__c where Name = 'TestAdminGroup' and Type__c = 'Group' 
                                    and Business_Role__r.Name = 'Test Admin' limit 1].size(), '{Test Admin business role - TestAdminGroup of type Group access} access should not exist');
            
            System.assertEquals(1, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'PermissionSet' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'BRM_Admin' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - BRM_Admin of type PermissionSet access} member access should exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'PermissionSet' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'Test_Admin_PS' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - Test_Admin_PS of type PermissionSet access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'PermissionSet' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'Test_Fake_PS' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - Test_Fake_PS of type PermissionSet access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Group' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'TestAdminGroup' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - TestAdminGroup of type Group access} member access should not exist');
            
            System.assertEquals(1, [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name = 'BRM_Admin' 
                                    and Assignee.Name = 'Test One' limit 1].size(), '{BRM_Admin permission set - Test One user} assignment should exist');
            System.assertEquals(0, [Select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where PermissionSet.Name = 'Test_Admin_PS' 
                                    and Assignee.Name = 'Test One' limit 1].size(), '{Test_Admin_PS permission set - Test One user} assignment should not exist');
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestAdminGroup' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test One'].Id limit 1].size(), 
                                '{TestAdminGroup group - Test One user} assignment should not exist');
        }
    }
    
    private static testMethod void deactivateAccessTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Business_Role_Member__c testMember = new Business_Role_Member__c(User__c = [Select Id, Name from User where Name = 'Test One'].Id, 
                                                                  Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id);
            List<Business_Role_Access__c> testAccessList = [Select Id, Name, Type__c, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c 
                                                           where Business_Role__r.Name = 'Test Admin'];
            Test.startTest();
            Database.insert(testMember);
            
            for(Business_Role_Access__c bra : testAccessList) {
                if(bra.Type__c == 'Group' || bra.Type__c == 'UserRole') {
                    bra.Is_Active__c = false;
                }
            }
            
            Database.update(testAccessList);
            Test.stopTest();
            
            System.assertEquals(7, [Select Id, Business_Role__r.Name from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin'].size(), 
                                'Invalid number of Test Admin accesses');
            System.assertEquals(4, [Select Id, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin' 
                                    and Is_Active__c = true].size(), 'Invalid number of active Test Admin accesses');
            System.assertEquals(1, [Select Name, Type__c, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c where Name = 'TestAdminGroup' and Type__c = 'Group' 
                                    and Business_Role__r.Name = 'Test Admin' and Is_Active__c = false limit 1].size(), 
                                '{Test Admin business role - TestAdminGroup of type Group access} access should exist and be deactivated');
            System.assertEquals(1, [Select Name, Type__c, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c where Name = 'TestFakeGroup' and Type__c = 'Group' 
                                    and Business_Role__r.Name = 'Test Admin' and Is_Active__c = false limit 1].size(), 
                                '{Test Admin business role - TestFakeGroup of type Group access} access should exist and be deactivated');
            System.assertEquals(1, [Select Name, Type__c, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c where Name = 'CEO' and Type__c = 'UserRole' 
                                    and Business_Role__r.Name = 'Test Admin' and Is_Active__c = false limit 1].size(), 
                                '{Test Admin business role - CEO of type UserRole access} access should exist and be deactivated');
            
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Group' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'TestAdminGroup' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - TestAdminGroup of type Group access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'Group' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'TestFakeGroup' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - TestFakeGroup of type Group access} member access should not exist');
            System.assertEquals(0, [Select Access_Type_Calc__c, User_Id_Calc__c, Access_Name_Calc__c, Business_Role__r.Name from Business_Role_Member_Access__c 
                                    where Access_Type_Calc__c = 'UserRole' and User_Id_Calc__c = :[Select Id, Name from User where Name = 'Test One'].Id 
                                    and Access_Name_Calc__c = 'CEO' and Business_Role__r.Name = 'Test Admin' limit 1].size(), 
                                '{Test Admin business role - Test One user - CEO of type UserRole access} member access should not exist');
            
            System.assertEquals(0, [Select Group.DeveloperName, UserOrGroupId from GroupMember where Group.DeveloperName = 'TestAdminGroup' 
                                    and UserOrGroupId = :[Select Id, Name from User where Name = 'Test One'].Id limit 1].size(), 
                                '{TestAdminGroup group - Test One user} assignment should not exist');
            System.assertEquals(null, [Select Name, UserRoleId from User where Name = 'Test One'].UserRoleId, 'Test One user should have no user role');
        }
    }
    
	@testSetup
    private static void initData() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            List<User> testUsersList = new List<User>();            
            testUsersList.add(new User(FirstName = 'Test', LastName = 'One', Email = 'test1@test.com', Alias = 'test1', Username = 'testOne@abcdef.com', CommunityNickname = 'tOne', 
                                    LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT', ProfileId = [Select Id from Profile where Name = 'Standard Platform User'].Id, 
                                       EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'));
            testUsersList.add(new User(FirstName = 'Test', LastName = 'Two', Email = 'test2@test.com', Alias = 'test2', Username = 'testTwo@abcdef.com', CommunityNickname = 'tTwo', 
                                LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT', ProfileId = [Select Id from Profile where Name = 'Standard Platform User'].Id, 
                                       EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US'));
            Database.insert(testUsersList);
            
            List<PermissionSet> testPermissionSetsList = new List<PermissionSet>();
            testPermissionSetsList.add(new PermissionSet(Label = 'Test Admin PS', Name = 'Test_Admin_PS'));
            testPermissionSetsList.add(new PermissionSet(Label = 'Test Viewer PS', Name = 'Test_Viewer_PS'));
            Database.insert(testPermissionSetsList);
            
            List<Group> testGroupsList = new List<Group>();
            testGroupsList.add(new Group(Type = 'Queue', DeveloperName = 'TestAdminQueue', Name = 'Test Admin Queue'));
            testGroupsList.add(new Group(Type = 'Queue', DeveloperName = 'TestViewerQueue', Name = 'Test Viewer Queue'));
            testGroupsList.add(new Group(Type = 'Regular', DeveloperName = 'TestAdminGroup', Name = 'Test Admin Group'));
            testGroupsList.add(new Group(Type = 'Regular', DeveloperName = 'TestViewerGroup', Name = 'Test Viewer Group'));
            Database.insert(testGroupsList);
            
            List<Business_Role__c> testBusinessRolesList = new List<Business_Role__c>();
            testBusinessRolesList.add(new Business_Role__c(Name = 'Test Admin'));
            testBusinessRolesList.add(new Business_Role__c(Name = 'Test Viewer'));
            Database.insert(testBusinessRolesList);
            
            List<Business_Role_Access__c> testBusinessRoleAccessesList = new List<Business_Role_Access__c>();
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'CEO', Type__c = 'UserRole', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'Test_Admin_PS', Type__c = 'PermissionSet', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'TestAdminQueue', Type__c = 'Queue', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'TestAdminGroup', Type__c = 'Group', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'Test_Fake_PS', Type__c = 'PermissionSet', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'TestFakeGroup', Type__c = 'Group', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'Standard Platform User', Type__c = 'Profile', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Admin'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'Test_Viewer_PS', Type__c = 'PermissionSet', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'TestViewerQueue', Type__c = 'Queue', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'TestViewerGroup', Type__c = 'Group', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'Test_Fake_PS', Type__c = 'PermissionSet', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'TestFakeQueue', Type__c = 'Queue', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'Standard Platform User', Type__c = 'Profile', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            testBusinessRoleAccessesList.add(new Business_Role_Access__c(Name = 'MarketingTeam', Type__c = 'UserRole', 
                                                                         Business_Role__c = [Select Id, Name from Business_Role__c where Name = 'Test Viewer'].Id));
            Database.insert(testBusinessRoleAccessesList);
        }
    }
}