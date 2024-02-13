@istest
public class fetchArticleDataCategoriesTest {
	@istest
    static void fetchArticleDataCategoriesTest(){
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        knowledge__kav kavarticle = new Knowledge__kav(
                title = 'test123',
                UrlName = 'tester123',
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true,
                Applicable_to_all_clients__c = true, recordtypeId = krecordType);
        insert kavarticle;
        
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        kavarticle.Approval_status__c='Approved';
        updKAV.add(kavarticle);
        kavIDs.add(kavarticle.id);
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
        List<Knowledge__DataCategorySelection> knowledgedataCategories = new List<Knowledge__DataCategorySelection>();
        for (Integer i = 0; i < dcList.size(); i++) {
            knowledgedataCategories.add(new Knowledge__DataCategorySelection(
                DataCategoryGroupName = 'Candidate',
            	DataCategoryName = dcList[i],
            	parentId = kavarticle.Id
            ));
        }
        insert knowledgedataCategories;
        
        fetchArticleDataCategories.resultsWrapper rw = new fetchArticleDataCategories.resultsWrapper();
        Test.startTest();
        rw = fetchArticleDataCategories.getKnowledgeDataCategories(kavarticle.Id);
        Test.stopTest();
       
        System.assertNotEquals(null,rw.dataCategoriesList);
        
    }
    
    @istest
    static void fetchArticleDataCategoriesTest1(){
        Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
        knowledge__kav kavarticle = new Knowledge__kav(
                title = 'test123',
                UrlName = 'tester123',
                Language = 'en_US',
                Article_visiblity_for_candidate__c = true,
                Applicable_to_all_clients__c = true, recordtypeId = krecordType);
        insert kavarticle;
        
        List<knowledge__kav> updKAV = new List<knowledge__kav>();
        List<id> kavIDs = new List<id>();
        List<id> kaIDs = new List<id>();
        kavarticle.Approval_status__c='Approved';
        updKAV.add(kavarticle);
        kavIDs.add(kavarticle.id);
        update updKAV;
        
        list<knowledge__kav> pubKAV = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDs]);   
        for(Knowledge__kav article: pubKAV) {
            kaIDs.add(article.knowledgeArticleId);
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
        }
        
        list<string> dcList = new list<string>();       
		/*for(Schema.DataCategory sc: SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName)){
			dcList.add(sc.getName());
        }*/
        List<Knowledge__DataCategorySelection> knowledgedataCategories = new List<Knowledge__DataCategorySelection>();
        for (Integer i = 0; i < dcList.size(); i++) {
            knowledgedataCategories.add(new Knowledge__DataCategorySelection(
                DataCategoryGroupName = 'Candidate',
            	DataCategoryName = dcList[i],
            	parentId = kavarticle.Id
            ));
        }
        insert knowledgedataCategories;
        
        fetchArticleDataCategories.resultsWrapper rw1 = new fetchArticleDataCategories.resultsWrapper();
        Test.startTest();
        rw1 = fetchArticleDataCategories.getKnowledgeDataCategories(kavarticle.Id);
        Test.stopTest();
       
        System.assertEquals(0,rw1.dataCategoriesList.size());
        
    }
}