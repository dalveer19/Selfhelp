@isTest
public class FeatureArticleClassTest {
	
    @testSetup static void setup() {
            
            //For knowlegde articles with visibility to all clients*************************************
            list<knowledge__kav> articleList = new list<knowledge__kav>();                       
            list<id> kavIDs = new list<id> ();
            list<id> kaIDs = new list<id> ();
            list<knowledge__kav> updKAV = new list<knowledge__kav>();
            
            Id krecordType = [Select Name, Id, developerName From RecordType where sObjectType='Knowledge__kav' and isActive=true and developerName = 'Candidate' limit 1].id;
            for(integer i = 0; i < 3; i++){
            articleList.add(new Knowledge__kav(title='test'+i,UrlName='tester--'+i,
            Language = 'en_US',
            Feature_Article__c = true,
            Article_visiblity_for_candidate__c = true,
            Applicable_to_all_clients__c = true, recordtypeId = krecordType));
            System.debug(articleList);
            }
            
        	insert articleList;
	            
            for(knowledge__kav k : articleList){
                k.Approval_status__c='Approved';
                updKAV.add(k);
                kavIDs.add(k.id);
            }
            update updKAV;
            
            list<knowledge__kav> pubKAV = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDs]);
            
            for(Knowledge__kav article: pubKAV) {
                kaIDs.add(article.knowledgeArticleId);
                KbManagement.PublishingService.submitForTranslation(article.KnowledgeArticleId,'ar_AE',UserInfo.getUserId(),Datetime.newInstanceGmt(2023,12,12));
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
                        
            list<Knowledge__kav> translKAVs = new list<Knowledge__kav>([select id,knowledgearticleid from knowledge__kav where knowledgearticleid in: kaIDs and language = 'ar_AE' and publishStatus = 'Draft']);
                for(Knowledge__kav transl : translKAVs){
                    KbManagement.PublishingService.completeTranslation(transl.id);
                } 

            //For knowlegde articles with linked clients*************************************
            list<knowledge__kav> articleListClient = new list<knowledge__kav>();
            list<id> kavIDsClient = new list<id> ();
            list<id> kaIDsClient = new list<id> ();
            list<knowledge__kav> updKAVClient = new list<knowledge__kav>();
            
			Id recordType = [Select Name, Id, developerName From RecordType where sObjectType='Account' and isActive=true and developerName = 'Client' limit 1].id;
            Account acc = new Account(name='TestkaAccount', recordtypeId = recordType, Displays_in_Self_Help__c = true, Active__c = true, Is_external__c = true,client_code__c='2344');
          	insert acc;
			
			list<Linked_Client__c > clients =  new list<Linked_Client__c>();
            for(integer i = 0; i < 3; i++){
            articleListClient.add(new Knowledge__kav(title='test'+i,UrlName='tester---'+i,
            Language = 'en_US',
            Feature_Article__c = true,
            Article_visiblity_for_candidate__c = true, recordtypeId = krecordType));
            }
        	insert articleListClient;
            
            for(knowledge__kav k : articleListClient){
                k.Approval_status__c='Approved';
                updKAVClient.add(k);
                kavIDsClient.add(k.id);
				clients.add(new Linked_Client__c(Knowledge_Article__c = k.id, Client__c = acc.id));
            }
			insert clients;
            update updKAVClient;
            
            list<knowledge__kav> pubKAVClient = new list<knowledge__kav>([select id, knowledgeArticleId from knowledge__kav where id in : kavIDsClient]);   
            for(Knowledge__kav article: pubKAVClient) {
                kaIDsClient.add(article.knowledgeArticleId);
                KbManagement.PublishingService.submitForTranslation(article.KnowledgeArticleId,'ar_AE',UserInfo.getUserId(),Datetime.newInstanceGmt(2023,12,12));
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, false);
            }
                        
            list<Knowledge__kav> translKAVsClient = new list<Knowledge__kav>([select id,knowledgearticleid from knowledge__kav where knowledgearticleid in: kaIDsClient and language = 'ar_AE' and publishStatus = 'Draft']);
                for(Knowledge__kav transl : translKAVsClient){
                    KbManagement.PublishingService.completeTranslation(transl.id);
                } 

        }
    
    @isTest
    static void getFeaturedArticlesTest(){
        try{
        // Call the method with 'All' and 'en_US' parameters
        List<FeatureArticleClass.articleWrapper> result = FeatureArticleClass.getFeaturedArticles('All', 'en_US');
        System.assertEquals(3, result.size());
        
        // Call the method with 'All' and 'ar_AE' parameters
        List<FeatureArticleClass.articleWrapper> resultTransl = FeatureArticleClass.getFeaturedArticles('All', 'ar_AE');
        System.assertEquals(3, resultTransl.size());
        
        //Call the method with '' and 'en_US' parameters
        List<FeatureArticleClass.articleWrapper> resultTranslNull = FeatureArticleClass.getFeaturedArticles('', 'en_US');
        System.assertEquals(3 , resultTranslNull.size());
        }
        catch(exception e){
            
        }
    }
    
    @isTest
    static void getFeaturedArticlesTest2(){
        
        try{
        String accClientCode = [select Client_code__c from account where name = 'TestkaAccount' limit 1].Client_code__c;
        
        List<FeatureArticleClass.articleWrapper> result = FeatureArticleClass.getFeaturedArticles(accClientCode, 'en_US');
        System.assertEquals(6, result.size());
        
        List<FeatureArticleClass.articleWrapper> resultTransl = FeatureArticleClass.getFeaturedArticles(accClientCode, 'ar_AE');
        System.assertEquals(6, resultTransl.size());
        
       // Call the method with '' and 'en_US' parameters
        List<FeatureArticleClass.articleWrapper> resultTranslNull = FeatureArticleClass.getFeaturedArticles('', 'en_US');
        System.assertEquals(3 , resultTranslNull.size());
        }
        catch(exception e){
            
        }
    }
}