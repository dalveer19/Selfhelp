@isTest
public class shp_FooterLinksControllerTest {
	@isTest
    public static void footerLinksTest1(){
        String langTest = 'en_US';
        Test.startTest();
        List<shp_FooterLinksController.footerWrapper> linksMetadataListTest = shp_FooterLinksController.getFooterLinks(langTest);
        Test.stopTest();
        System.assertNotEquals(null,linksMetadataListTest);
        System.assertEquals(null,linksMetadataListTest[0].errorMsg);
    }
    
    @isTest(SeeAllData=false)
    public static void footerLinksTest2(){
        String langTest = 'en_USA';
        Test.startTest();
        List<shp_FooterLinksController.footerWrapper> linksMetadataListTest = shp_FooterLinksController.getFooterLinks(langTest);
        Test.stopTest();
        System.assertNotEquals(null,linksMetadataListTest[0].errorMsg);
    }
}