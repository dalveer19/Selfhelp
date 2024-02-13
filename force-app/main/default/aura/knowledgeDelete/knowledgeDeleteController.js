({
    doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.deleteKA");

        action.setParams({ "recordId": recordId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            $A.get("e.force:closeQuickAction").fire();

            if (state === "SUCCESS") {

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: 'Draft is Deleted successfully',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();

                var urlrecordid = response.getReturnValue();
                console.log('result--------' + urlrecordid);

                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({ tabId: focusedTabId });
                })
                    .catch(function (error) {
                        console.log(error);
                    });

                if (urlrecordid.toUpperCase().startsWith('KA')) {
                    //Navigate to published article detail page      
                    workspaceAPI.openTab({
                        recordId: urlrecordid,
                        focus: true
                    }).then(function (response) {
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function (tabInfo) {
                            console.log("The url for this tab is: " + tabInfo.url);
                        });
                    })
                        .catch(function (error) {
                            console.log(error);
                        });

                }
                else if (urlrecordid.toUpperCase().startsWith('00B')) {
                    //Navigate to list view  
                    var navEvent = $A.get("e.force:navigateToList");
                    navEvent.setParams({
                        "listViewId": urlrecordid,
                        "listViewName": null,
                        "scope": "Knowledge__kav"
                    });
                    navEvent.fire();

                }
            }
            else if (state === "ERROR") {
                console.log('There was a problem : ' + response.getError());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'You cannot delete as you are not the owner (or) article is not a draft',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})