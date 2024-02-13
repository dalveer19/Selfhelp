import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import HELP_SUPPORT from '@salesforce/label/c.Help_and_support';
import PEARSON from '@salesforce/label/c.pearsonvue_com';
import SKIP from '@salesforce/label/c.skip_to_main_content';
import LANG_SELECTOR from '@salesforce/label/c.Language_Selector_Icon';
import PEARSON_LOGO from '@salesforce/label/c.Pearson_Logo';
export default class Header_SH extends NavigationMixin(LightningElement) {


    helpSupport = HELP_SUPPORT
    skipContent = SKIP
    languageSelector = LANG_SELECTOR
    pearsonLogo = PEARSON_LOGO
    @track showLang
    language


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.language = currentPageReference.state?.language
        }
    }

    connectedCallback() {
    }

    renderedCallback() {
        if(!document.body.classList.contains('arabic-class') && this.language == 'ar_AE'){
            document.body.className += ' arabic-class';
            document.body.style.direction  = 'rtl';
        }
    }

    skipToMainContent(event) {
        if (event.type === 'click' || (event.type === 'keydown' && event.keyCode === 13)) {
            window.dispatchEvent(new CustomEvent('skipLink'));
        }

    }

    handleLang() {
        this.showLang = true
        document.body.style.overflow = 'hidden'
    }

    handleGlobeLogoKeyDown(event) {
        if (event.keyCode == 13) {
            this.handleLang();
        }
    }

    homeHandler() {
        window.location.href = PEARSON;
    }

    handlePearsonLogoKeyDown(event) {
        if (event.keyCode === 13) {
            this.homeHandler();
        }
    }

    //handle language modal close
    handleCloseLang() {
        this.showLang = false
        document.body.style.overflow = 'auto'
        //To focus on header icon
        let langSelectorIcon = this.template.querySelector('.g_icon')
        langSelectorIcon.focus()
    }

}