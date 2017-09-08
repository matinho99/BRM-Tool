@isTest
private class BRMEngineTest {
    private static testMethod void insertDeleteMemberTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMEngineTestUtil.createMembers(new List<String> {
                'Test One|Test Admin', 
                'Test Two|Test Viewer'
            });
            BRMEngineTestUtil.removeMembers(false, new List<String> {
                'Test Two|Test Viewer'
            });
			Test.stopTest();
            
            System.assertEquals(1, [Select Id from Business_Role_Member__c].size(), 'Invalid number of test members');
            BRMEngineTestUtil.assertMembers(new List<String> {
                'true|Test One|Test Admin|true|{Test Admin business role - Test One user} member should exist', 
                'false|Test Two|Test Viewer|true|{Test Viewer business role - Test Two user} member should not exist'
            });
            
            System.assertEquals(7, [Select Id from Business_Role_Member_Access__c].size(), 'Invalid number of test member accesses');
            BRMEngineTestUtil.assertMemberAccesses(new List<String> {
                'true|PermissionSet|Test_Admin_PS|Test One|Test Admin|{Test Admin business role - Test One user - Test_Admin_PS of type PermissionSet access} member access should exist',
                'true|Queue|BRMTestAdminQueue|Test One|Test Admin|{Test Admin business role - Test One user - BRMTestAdminQueue of type Queue access} member access should exist', 
                'true|Group|BRMTestAdminGroup|Test One|Test Admin|{Test Admin business role - Test One user - BRMTestAdminGroup of type Group access} member access should exist', 
                'true|PermissionSet|Test_Fake_PS|Test One|Test Admin|{Test Admin business role - Test One user - Test_Fake_PS of type PermissionSet access} member access should exist', 
                'true|Group|TestFakeGroup|Test One|Test Admin|{Test Admin business role - Test One user - TestFakeGroup of type Group access} member access should exist', 
                'true|Profile|Standard Platform User|Test One|Test Admin|{Test Admin business role - Test One user - Standard Platform User of type Profile access} member access should exist', 
                'true|UserRole|CEO|Test One|Test Admin|{Test Admin business role - Test One user - CEO of type UserRole access} member access should exist', 
                'false|PermissionSet|Test_Viewer_PS|Test Two|Test Viewer|{Test Viewer business role - Test Two user - Test_Viewer_PS of type PermissionSet access} member access should not exist', 
                'false|Queue|BRMTestViewerQueue|Test Two|Test Viewer|{Test Viewer business role - Test Two user - BRMTestViewerQueue of type Queue access} member access should not exist', 
                'false|Group|BRMTestViewerGroup|Test Two|Test Viewer|{Test Viewer business role - Test Two user - BRMTestViewerGroup of type Group access} member access should not exist', 
                'false|PermissionSet|Test_Fake_PS|Test Two|Test Viewer|{Test Viewer business role - Test Two user - Test_Fake_PS of type PermissionSet access} member access should not exist', 
                'false|Queue|TestFakeQueue|Test Two|Test Viewer|{Test Viewer business role - Test Two user - TestFakeQueue of type Queue access} member access should not exist', 
                'false|Profile|Standard Platform User|Test Two|Test Viewer|{Test Viewer business role - Test Two user - Standard Platform User of type Profile access} member access should not exist', 
                'false|UserRole|MarketingTeam|Test Two|Test Viewer|{Test Viewer business role - Test Two user - MarketingTeam of type UserRole access} member access should not exist'
            });
            
            BRMEngineTestUtil.assertPermissionSets(new List<String> {
                'true|Test_Admin_PS|Test One|{Test_Admin_PS permission set - Test One user} assignment should exist', 
                'false|Test_Fake_PS|Test One|{Test_Fake_PS permission set - Test One user} assignment should not exist', 
                'false|Test_Viewer_PS|Test Two|{Test_Viewer_PS permission set - Test Two user} assignment should not exist', 
                'false|Test_Fake_PS|Test Two|{Test_Fake_PS permission set - Test Two user} assignment should not exist'
            });
            
            BRMEngineTestUtil.assertGroups(new List<String> {
                'true|Queue|BRMTestAdminQueue|Test One|{BRMTestAdminQueue of type Queue group - Test One user} assignment should exist', 
                'true|Regular|BRMTestAdminGroup|Test One|{BRMTestAdminGroup of type Regular group - Test One user} assignment should exist', 
                'false|Regular|TestFakeGroup|Test One|{TestFakeGroup of type Regular group - Test One user} assignment should not exist', 
                'false|Queue|BRMTestViewerQueue|Test Two|{BRMTestViewerQueue of type Queue group - Test Two user} assignment should not exist', 
                'false|Regular|BRMTestViewerGroup|Test Two|{BRMTestViewerGroup of type Regular group - Test Two user} assignment should not exist', 
                'false|Queue|TestFakeQueue|Test Two|{TestFakeQueue of type Queue group - Test Two user} assignment should not exist'
            });
            
            BRMEngineTestUtil.assertUserRoles(new List<String> {
                'true|Test One|CEO|Test One user should have CEO user role', 
                'true|Test Two|null|Test Two user should have no user role'
            });
            
            BRMEngineTestUtil.assertProfiles(new List<String> {
                'true|Test One|Standard Platform User|Test One user should have Standard Platform User profile', 
                'true|Test Two|Standard Platform User|Test Two user should have Standard Platform User profile'
            });
        }
    }
    
    private static testMethod void deactivateMemberTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMEngineTestUtil.createMembers(new List<String> {
                'Test One|Test Admin'
            });
            BRMEngineTestUtil.removeMembers(true, new List<String> {
                'Test One|Test Admin'
            });
            Test.stopTest();
            
            System.assertEquals(1, [Select Id from Business_Role_Member__c].size(), 'Invalid number of test members');
            BRMEngineTestUtil.assertMembers(new List<String> {
                'true|Test One|Test Admin|false|{Test Admin business role - Test One user} member should exist and be deactivated'
            });
            
            System.assertEquals(0, [Select Id from Business_Role_Member_Access__c].size(), 'Invalid number of test member accesses');
            
            BRMEngineTestUtil.assertPermissionSets(new List<String> {
                'false|Test_Admin_PS|Test One|{Test_Admin_PS permission set - Test One user} assignment should not exist'
            });
            
            BRMEngineTestUtil.assertGroups(new List<String> {
                'false|Queue|BRMTestAdminQueue|Test One|{BRMTestAdminQueue of type Queue group - Test One user} assignment should not exist', 
                'false|Regular|BRMTestAdminGroup|Test One|{BRMTestAdminGroup of type Regular group - Test One user} assignment should not exist'
            });
            
            BRMEngineTestUtil.assertUserRoles(new List<String> {
                'true|Test One|null|Test One user should have no user role'
            });
            
            BRMEngineTestUtil.assertProfiles(new List<String> {
                'true|Test One|Standard Platform User|Test One user should have Standard Platform User profile'
            });
        }
    }
    
    private static testMethod void insertDeleteAccessTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMEngineTestUtil.createMembers(new List<String> {
                'Test One|Test Admin'
            });
            BRMEngineTestUtil.removeAccesses(false, new List<String> {
                'Test_Admin_PS|PermissionSet|Test Admin', 
                'Test_Fake_PS|PermissionSet|Test Admin', 
                'BRMTestAdminGroup|Group|Test Admin'
            });
            BRMEngineTestUtil.createAccesses(new List<String> {
                'BRM_Admin|PermissionSet|Test Admin'
            });
            Test.stopTest();
            
            System.assertEquals(5, [Select Id, Business_Role__r.Name from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin'].size(), 
                                'Invalid number of Test Admin accesses');
            BRMEngineTestUtil.assertAccesses(new List<String> {
                'true|BRM_Admin|PermissionSet|Test Admin|true|{Test Admin business role - BRM_Admin of type PermissionSet access} access should exist', 
                'false|Test_Admin_PS|PermissionSet|Test Admin|true|{Test Admin business role - Test_Admin_PS of type PermissionSet access} access should not exist', 
                'false|Test_Fake_PS|PermissionSet|Test Admin|true|{Test Admin business role - Test_Fake_PS of type PermissionSet access} access should not exist', 
                'false|BRMTestAdminGroup|Group|Test Admin|true|{Test Admin business role - BRMTestAdminGroup of type Group access} access should not exist'
            });
            
            BRMEngineTestUtil.assertMemberAccesses(new List<String> {
                'true|PermissionSet|BRM_Admin|Test One|Test Admin|{Test Admin business role - Test One user - BRM_Admin of type PermissionSet access} member access should exist', 
                'false|PermissionSet|Test_Admin_PS|Test One|Test Admin|{Test Admin business role - Test One user - Test_Admin_PS of type PermissionSet access} member access should not exist', 
                'false|PermissionSet|Test_Fake_PS|Test One|Test Admin|{Test Admin business role - Test One user - Test_Fake_PS of type PermissionSet access} member access should not exist', 
                'false|Group|BRMTestAdminGroup|Test One|Test Admin|{Test Admin business role - Test One user - BRMTestAdminGroup of type Group access} member access should not exist'
            });
            
            BRMEngineTestUtil.assertPermissionSets(new List<String> {
                'true|BRM_Admin|Test One|{BRM_Admin permission set - Test One user} assignment should exist', 
                'false|Test_Admin_PS|Test One|{Test_Admin_PS permission set - Test One user} assignment should not exist'
            });
            
            BRMEngineTestUtil.assertGroups(new List<String> {
                'false|Regular|BRMTestAdminGroup|Test One|{BRMTestAdminGroup of type Regular group - Test One user} assignment should not exist'
            });
        }
    }
    
    private static testMethod void deactivateAccessTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMEngineTestUtil.createMembers(new List<String> {
                'Test One|Test Admin'
            });
            BRMEngineTestUtil.removeAccesses(true, new List<String> {
                'BRMTestAdminGroup|Group|Test Admin', 
                'TestFakeGroup|Group|Test Admin', 
                'CEO|UserRole|Test Admin'
            });
            Test.stopTest();
            
            System.assertEquals(7, [Select Id, Business_Role__r.Name from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin'].size(), 
                                'Invalid number of Test Admin accesses');
            System.assertEquals(4, [Select Id, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin' 
                                    and Is_Active__c = true].size(), 'Invalid number of active Test Admin accesses');
            BRMEngineTestUtil.assertAccesses(new List<String> {
                'true|BRMTestAdminGroup|Group|Test Admin|false|{Test Admin business role - BRMTestAdminGroup of type Group access} access should exist and be deactivated', 
                'true|TestFakeGroup|Group|Test Admin|false|{Test Admin business role - TestFakeGroup of type Group access} access should exist and be deactivated', 
                'true|CEO|UserRole|Test Admin|false|{Test Admin business role - CEO of type UserRole access} access should exist and be deactivated'
            });
            
            BRMEngineTestUtil.assertMemberAccesses(new List<String> {
                'false|Group|BRMTestAdminGroup|Test One|Test Admin|{Test Admin business role - Test One user - BRMTestAdminGroup of type Group access} member access should not exist', 
                'false|Group|TestFakeGroup|Test One|Test Admin|{Test Admin business role - Test One user - TestFakeGroup of type Group access} member access should not exist', 
                'false|UserRole|CEO|Test One|Test Admin|{Test Admin business role - Test One user - CEO of type UserRole access} member access should not exist'
            });
            
            BRMEngineTestUtil.assertGroups(new List<String> {
                'false|Regular|BRMTestAdminGroup|Test One|{BRMTestAdminGroup of type Regular group - Test One user} assignment should not exist'
            });
            
            BRMEngineTestUtil.assertUserRoles(new List<String> {
                'true|Test One|null|Test One user should have no user role'
            });
        }
    }
    
	@testSetup
    private static void initData() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            BRMEngineTestUtil.createUsers(new List<String>{
                'Test|One|test1@test.com|test1|testOne@abcdef.com|tOne|en_US|GMT|Standard Platform User|UTF-8|en_US', 
                'Test|Two|test2@test.com|test2|testTwo@abcdef.com|tTwo|en_US|GMT|Standard Platform User|UTF-8|en_US'
            });
            BRMEngineTestUtil.createPermissionSets(new List<String>{
                'Test Admin PS|Test_Admin_PS',
                'Test Viewer PS|Test_Viewer_PS'
            });
            BRMEngineTestUtil.createGroups(new List<String>{
                'Queue|BRMTestAdminQueue|BRM Test Admin Queue', 
                'Queue|BRMTestViewerQueue|BRM Test Viewer Queue', 
                'Regular|BRMTestAdminGroup|BRM Test Admin Group', 
                'Regular|BRMTestViewerGroup|BRM Test Viewer Group'
            });
            BRMEngineTestUtil.createBusinessRoles(new List<String>{
                'Test Admin', 
                'Test Viewer'
            });
            BRMEngineTestUtil.createAccesses(new List<String>{
                'CEO|UserRole|Test Admin', 
                'Test_Admin_PS|PermissionSet|Test Admin', 
                'BRMTestAdminQueue|Queue|Test Admin', 
                'BRMTestAdminGroup|Group|Test Admin', 
                'Test_Fake_PS|PermissionSet|Test Admin', 
                'TestFakeGroup|Group|Test Admin', 
                'Standard Platform User|Profile|Test Admin', 
                'Test_Viewer_PS|PermissionSet|Test Viewer', 
                'BRMTestViewerQueue|Queue|Test Viewer', 
                'BRMTestViewerGroup|Group|Test Viewer', 
                'Test_Fake_PS|PermissionSet|Test Viewer', 
                'TestFakeQueue|Queue|Test Viewer', 
                'Standard Platform User|Profile|Test Viewer', 
                'MarketingTeam|UserRole|Test Viewer'
            });
        }
    }
}