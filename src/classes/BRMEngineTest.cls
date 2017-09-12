@isTest
private class BRMEngineTest {
    private static testMethod void insertDeleteMemberTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMTestUtil.createMembers(new List<String> {
                'Test One|Test Admin', 
                'Test Two|Test Viewer'
            });
            BRMTestUtil.removeMembers(false, new List<String> {
                'Test Two|Test Viewer'
            });
            Test.stopTest();
            
            System.assertEquals(1, [Select Id from Business_Role_Member__c].size(), 'Invalid number of test members');
            BRMTestUtil.assertMembers(new List<String> {
                'true|Test One|Test Admin|true', 
                'false|Test Two|Test Viewer|true'
            });
            
            System.assertEquals(7, [Select Id from Business_Role_Member_Access__c].size(), 'Invalid number of test member accesses');
            BRMTestUtil.assertMemberAccesses(new List<String> {
                'true|PermissionSet|Test_Admin_PS|Test One|Test Admin',
                'true|Queue|BRMTestAdminQueue|Test One|Test Admin', 
                'true|Group|BRMTestAdminGroup|Test One|Test Admin', 
                'true|PermissionSet|Test_Fake_PS|Test One|Test Admin', 
                'true|Group|TestFakeGroup|Test One|Test Admin', 
                'true|Profile|Standard Platform User|Test One|Test Admin', 
                'true|UserRole|CEO|Test One|Test Admin', 
                'false|PermissionSet|Test_Viewer_PS|Test Two|Test Viewer', 
                'false|Queue|BRMTestViewerQueue|Test Two|Test Viewer', 
                'false|Group|BRMTestViewerGroup|Test Two|Test Viewer', 
                'false|PermissionSet|Test_Fake_PS|Test Two|Test Viewer', 
                'false|Queue|TestFakeQueue|Test Two|Test Viewer', 
                'false|Profile|Standard Platform User|Test Two|Test Viewer', 
                'false|UserRole|MarketingTeam|Test Two|Test Viewer'
            });
            
            BRMTestUtil.assertPermissionSets(new List<String> {
                'true|Test_Admin_PS|Test One', 
                'false|Test_Fake_PS|Test One', 
                'false|Test_Viewer_PS|Test Two', 
                'false|Test_Fake_PS|Test Two'
            });
            
            BRMTestUtil.assertGroups(new List<String> {
                'true|Queue|BRMTestAdminQueue|Test One', 
                'true|Regular|BRMTestAdminGroup|Test One', 
                'false|Regular|TestFakeGroup|Test One', 
                'false|Queue|BRMTestViewerQueue|Test Two', 
                'false|Regular|BRMTestViewerGroup|Test Two', 
                'false|Queue|TestFakeQueue|Test Two'
            });
            
            BRMTestUtil.assertUserRoles(new List<String> {
                'Test One|CEO', 
                'Test Two|null'
            });
            
            BRMTestUtil.assertProfiles(new List<String> {
                'Test One|Standard Platform User', 
                'Test Two|Standard Platform User'
            });
        }
    }
    
    private static testMethod void deactivateMemberTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMTestUtil.createMembers(new List<String> {
                'Test One|Test Admin'
            });
            BRMTestUtil.removeMembers(true, new List<String> {
                'Test One|Test Admin'
            });
            Test.stopTest();
            
            System.assertEquals(1, [Select Id from Business_Role_Member__c].size(), 'Invalid number of test members');
            BRMTestUtil.assertMembers(new List<String> {
                'true|Test One|Test Admin|false'
            });
            
            System.assertEquals(0, [Select Id from Business_Role_Member_Access__c].size(), 'Invalid number of test member accesses');
            
            BRMTestUtil.assertPermissionSets(new List<String> {
                'false|Test_Admin_PS|Test One'
            });
            
            BRMTestUtil.assertGroups(new List<String> {
                'false|Queue|BRMTestAdminQueue|Test One', 
                'false|Regular|BRMTestAdminGroup|Test One'
            });
            
            BRMTestUtil.assertUserRoles(new List<String> {
                'Test One|null'
            });
            
            BRMTestUtil.assertProfiles(new List<String> {
                'Test One|Standard Platform User'
            });
        }
    }
    
    private static testMethod void insertDeleteAccessTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMTestUtil.createMembers(new List<String> {
                'Test One|Test Admin'
            });
            BRMTestUtil.removeAccesses(false, new List<String> {
                'Test_Admin_PS|PermissionSet|Test Admin', 
                'Test_Fake_PS|PermissionSet|Test Admin', 
                'BRMTestAdminGroup|Group|Test Admin'
            });
            BRMTestUtil.createAccesses(new List<String> {
                'BRM_Admin|PermissionSet|Test Admin'
            });
            Test.stopTest();
            
            System.assertEquals(5, [Select Id, Business_Role__r.Name from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin'].size(), 
                                'Invalid number of Test Admin accesses');
            BRMTestUtil.assertAccesses(new List<String> {
                'true|BRM_Admin|PermissionSet|Test Admin|true', 
                'false|Test_Admin_PS|PermissionSet|Test Admin|true', 
                'false|Test_Fake_PS|PermissionSet|Test Admin|true', 
                'false|BRMTestAdminGroup|Group|Test Admin|true'
            });
            
            BRMTestUtil.assertMemberAccesses(new List<String> {
                'true|PermissionSet|BRM_Admin|Test One|Test Admin', 
                'false|PermissionSet|Test_Admin_PS|Test One|Test Admin', 
                'false|PermissionSet|Test_Fake_PS|Test One|Test Admin', 
                'false|Group|BRMTestAdminGroup|Test One|Test Admin'
            });
            
            BRMTestUtil.assertPermissionSets(new List<String> {
                'true|BRM_Admin|Test One', 
                'false|Test_Admin_PS|Test One'
            });
            
            BRMTestUtil.assertGroups(new List<String> {
                'false|Regular|BRMTestAdminGroup|Test One'
            });
        }
    }
    
    private static testMethod void deactivateAccessTest() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMTestUtil.createMembers(new List<String> {
                'Test One|Test Admin'
            });
            BRMTestUtil.removeAccesses(true, new List<String> {
                'BRMTestAdminGroup|Group|Test Admin', 
                'TestFakeGroup|Group|Test Admin', 
                'CEO|UserRole|Test Admin'
            });
            Test.stopTest();
            
            System.assertEquals(7, [Select Id, Business_Role__r.Name from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin'].size(), 
                                'Invalid number of Test Admin accesses');
            System.assertEquals(4, [Select Id, Business_Role__r.Name, Is_Active__c from Business_Role_Access__c where Business_Role__r.Name = 'Test Admin' 
                                    and Is_Active__c = true].size(), 'Invalid number of active Test Admin accesses');
            BRMTestUtil.assertAccesses(new List<String> {
                'true|BRMTestAdminGroup|Group|Test Admin|false', 
                'true|TestFakeGroup|Group|Test Admin|false', 
                'true|CEO|UserRole|Test Admin|false'
            });
            
            BRMTestUtil.assertMemberAccesses(new List<String> {
                'false|Group|BRMTestAdminGroup|Test One|Test Admin', 
                'false|Group|TestFakeGroup|Test One|Test Admin', 
                'false|UserRole|CEO|Test One|Test Admin'
            });
            
            BRMTestUtil.assertGroups(new List<String> {
                'false|Regular|BRMTestAdminGroup|Test One'
            });
            
            BRMTestUtil.assertUserRoles(new List<String> {
                'Test One|null'
            });
        }
    }
    
	@testSetup
    private static void initData() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            BRMTestUtil.createUsers(new List<String>{
                'Test|One|test1@test.com|test1|testOne@abcdef.com|tOne|en_US|GMT|Standard Platform User|UTF-8|en_US', 
                'Test|Two|test2@test.com|test2|testTwo@abcdef.com|tTwo|en_US|GMT|Standard Platform User|UTF-8|en_US'
            });
            BRMTestUtil.createPermissionSets(new List<String>{
                'Test Admin PS|Test_Admin_PS',
                'Test Viewer PS|Test_Viewer_PS'
            });
            BRMTestUtil.createGroups(new List<String>{
                'Queue|BRMTestAdminQueue|BRM Test Admin Queue', 
                'Queue|BRMTestViewerQueue|BRM Test Viewer Queue', 
                'Regular|BRMTestAdminGroup|BRM Test Admin Group', 
                'Regular|BRMTestViewerGroup|BRM Test Viewer Group'
            });
            BRMTestUtil.createBusinessRoles(new List<String>{
                'Test Admin', 
                'Test Viewer'
            });
            BRMTestUtil.createAccesses(new List<String>{
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