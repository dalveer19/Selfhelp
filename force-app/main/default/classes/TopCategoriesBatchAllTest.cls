@isTest
public class TopCategoriesBatchAllTest {

    @isTest
    static void TopCategoriesBatchAllTest() {
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Brazil;Austria;Argentina';
        dummySetting.size__c = 10;
        insert dummySetting;            
   		
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        List<knowledge__kav> articles = new List<knowledge__kav>();
            for (Integer i = 0; i < 3; i++) {
                articles.add(new Knowledge__kav(
                    title = 'test' + i,
                    UrlName = 'tester---' + i,
                    Language = 'en_US',
                    Article_visiblity_for_candidate__c = true,
                    Applicable_to_all_clients__c = true, recordtypeId = krecordType
                ));
            }
            insert articles;
        
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        for(knowledge__kav k : articles){
                k.Approval_status__c='Approved';
                updKAV.add(k);
                kavIDs.add(k.id);
            }
            update updKAV;
            
            list<knowledge__kav> pubKAV = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDs]);   
            for(Knowledge__kav article: pubKAV) {
                kaIDs.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
        
        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        List<Knowledge__DataCategorySelection> knowledgedataCategories = new List<Knowledge__DataCategorySelection>();
        for (Integer i = 0; i < articles.size(); i++) {
            knowledgedataCategories.add(new Knowledge__DataCategorySelection(
                DataCategoryGroupName = 'Candidate',
            	DataCategoryName = dcList[0],
            	parentId = articles[i].Id
            ));
        }
        insert knowledgedataCategories;
        
        Test.startTest();
        Database.executeBatch(new TopCategoriesBatchAll());
        Test.stopTest();

        Top_categories__c setting = Top_categories__c.getOrgDefaults();
        System.assertEquals('Account_Login', setting.Categories_List__c);
    }
    
    @IsTest
    static void testBatchWithException() {
        
        TopCategoriesBatchAll.isTestRunning = true;
        System.debug(TopCategoriesBatchAll.isTestRunning);
        
        top_categories__c dummySetting = new top_categories__c();
        dummySetting.Name = 'TopCategories';
        dummySetting.Categories_List__c = 'Brazil;Austria;Argentina';
        dummySetting.size__c = 10;
        insert dummySetting; 
        
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        List<knowledge__kav> articles = new List<knowledge__kav>();
            for (Integer i = 0; i < 3; i++) {
                articles.add(new Knowledge__kav(
                    title = 'test' + i,
                    UrlName = 'tester---' + i,
                    Language = 'en_US',
                    Article_visiblity_for_candidate__c = true,
                    Applicable_to_all_clients__c = true, recordtypeId = krecordType
                ));
            }
            insert articles;
        
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        for(knowledge__kav k : articles){
                k.Approval_status__c='Approved';
                updKAV.add(k);
                kavIDs.add(k.id);
            }
            update updKAV;
            
            list<knowledge__kav> pubKAV = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDs]);   
            for(Knowledge__kav article: pubKAV) {
                kaIDs.add(article.knowledgeArticleId);
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }

        list<string> dcList = new list<string>();       
		for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }
		System.debug(dcList);
        
        List<Knowledge__DataCategorySelection> knowledgedataCategories = new List<Knowledge__DataCategorySelection>();
        for (Integer i = 0; i < articles.size(); i++) {
            knowledgedataCategories.add(new Knowledge__DataCategorySelection(
                DataCategoryGroupName = 'Candidate',
            	DataCategoryName = dcList[0],
            	parentId = articles[i].Id
            ));
        }
        insert knowledgedataCategories;
        
        Test.startTest();
        try {
            Database.executeBatch(new TopCategoriesBatchAll());
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

}