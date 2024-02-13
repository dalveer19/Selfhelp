@isTest
public class DataCategoryControllerTest {
    
    @isTest
    public static void getTopCategories1() {
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Account_Login';
        dummySetting.size__c = 10;
        insert dummySetting; 
        
        knowledge__kav article = new Knowledge__kav(
                    title = 'Test 1',
                    UrlName = 'tester-1',
                    Language = 'en_US',
                    Article_visiblity_for_candidate__c = true,
                    Applicable_to_all_clients__c = true
                );
            insert article;
                article.Approval_status__c='Approved';
              //  updKAV.add(article);
             	ID kavID = article.id;
            	update article;
            
            knowledge__kav pubKAV = [select id, knowledgeArticleId from knowledge__kav where id =: kavID];
           		ID kaID = pubKAV.knowledgeArticleId;
                KbManagement.PublishingService.publishArticle(pubKAV.KnowledgeArticleId, false);
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = article.Id;
        insert dataCategory;
        
        Map<String, String> result = DataCategoryController.getTopCategories('All');
        System.assertNotEquals(0, result.size());
    }
    
    @isTest
    public static void getTopCategories2() {
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Account_Login';
        dummySetting.size__c = 10;
        insert dummySetting; 
        
        knowledge__kav article = new Knowledge__kav(
                    title = 'Test 1',
                    UrlName = 'tester-1',
                    Language = 'en_US',
                    Article_visiblity_for_candidate__c = true,
                    Applicable_to_all_clients__c = false
                );
            insert article;
        
            article.Approval_status__c='Approved';
          	ID kavID = article.id;
           	update article;
            
            knowledge__kav pubKAV = [select id, knowledgeArticleId from knowledge__kav where id =: kavID];
             	Id kaID = pubKAV.knowledgeArticleId;
                KbManagement.PublishingService.publishArticle(pubKAV.KnowledgeArticleId, false);
        
        Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
        Account acc = new Account(name='TestAccount', recordtypeId = recordType, Client_code__c = '111',Displays_in_Self_Help__c = true, Active__c = true);
        insert acc;
        
        Account_Info__c accInfo = new Account_Info__c();
        accInfo.Name = 'Test Account Info';
        accInfo.client__c = acc.Id;
        accInfo.ar_AE__c = 'demo.com';
        accInfo.Top_categories__c = 'Account_Login';
        insert accInfo;
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.DataCategoryGroupName = 'Candidate';
        dataCategory.DataCategoryName = dcList[0];
        dataCategory.parentId = article.Id;
        insert dataCategory;
        
        Map<String, String> result = DataCategoryController.getTopCategories('111');
        System.assertNotEquals(0, result.size());
    }
    
    @isTest
    public static void getDataCategoryLabelTest() {
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
        
        String result = DataCategoryController.getDataCategoryLabel(dcList[0]);
        System.assertEquals('Account & Login', result);
    }

}