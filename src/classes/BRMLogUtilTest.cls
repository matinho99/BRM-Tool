@isTest
private class BRMLogUtilTest {
    private static testMethod void testErrorLog() {
        User u = [Select Id, Profile.Name, IsActive from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(u) {
            Test.startTest();
            BRMTestUtil.createMembers(new List<String> {
                'Test One|Test Admin', 
                'Test Two|Test Admin'
            });
            BRMTestUtil.createAccesses(new List<String> {
                'Chatter Free User|Profile|Test Admin'
            });
            BRMTestUtil.removeAccesses(false, new List<String> {
                'TestFakeGroup|Group|Test Admin'
            });
            BRMTestUtil.removeMembers(false, new List<String> {
                'Test Two|Test Admin'
            });
            Test.stopTest();
            
            BRMTestUtil.assertErrorLogs(new List<String> {
                'true|Test Admin|Test_Fake_PS|PermissionSet|Test One', 
                'true|Test Admin|Chatter Free User|Profile|Test One', 
                'true|Test Admin|null|null|Test One', 
                'true|Test Admin|Test_Fake_PS|PermissionSet|null', 
                'true|Test Admin|null|null|null'
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
                'Test Admin PS|Test_Admin_PS'
            });
            BRMTestUtil.createGroups(new List<String>{
                'Queue|BRMTestAdminQueue|BRM Test Admin Queue', 
                'Regular|BRMTestAdminGroup|BRM Test Admin Group'
            });
            BRMTestUtil.createBusinessRoles(new List<String>{
                'Test Admin'
            });
            BRMTestUtil.createAccesses(new List<String>{
                'CEO|UserRole|Test Admin', 
                'Test_Admin_PS|PermissionSet|Test Admin', 
                'BRMTestAdminQueue|Queue|Test Admin', 
                'BRMTestAdminGroup|Group|Test Admin', 
                'Test_Fake_PS|PermissionSet|Test Admin', 
                'TestFakeGroup|Group|Test Admin', 
                'Standard Platform User|Profile|Test Admin'
            });
        }
    }
}