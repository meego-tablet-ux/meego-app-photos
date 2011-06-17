import Qt 4.7
import MeeGo.Media 0.1
import AcerWidgetsDaemonInterface 0.1   //lib from meego-ux-media as awdapi

Item {
    id: photoAwdInterface

    //Other control bool
    property bool allPhotosModelUpdating: true
    property int inDetailPage: 0    //0 for in all photos
                                    //1 for in Albums or Timeline
                                    //2 for in awdPhotoDetailsView
                                    //3 for in awdAlbumDetailsView
    property string currentUrn

    AwdClient {
        id: awdclient
        name: "photo"
        type: "app"        
    }

    Connections {
        target: window
        onDetailViewIndexChanged: {
            console.log("------------- detailViewIndex "+detailViewIndex)
        }
    }

    onInDetailPageChanged: {
        console.log("------------- inDetailPage "+inDetailPage)
        if(inDetailPage == 2) {
            currentUrn = allPhotosModel.datafromIndex(detailViewIndex, MediaItem.URN);
            if(awdclient.getData("urn") != currentUrn) {
                awdclient.setData("urn", currentUrn);
                awdclient.shootData();
            }
        }
        else if(inDetailPage == 3) {
            currentUrn = allPhotosModel.datafromIndex(allPhotosModel.itemIndex(currentPhotoItemId), MediaItem.URN);
            if(awdclient.getData("urn") != currentUrn) {
                awdclient.setData("urn", currentUrn);
                awdclient.shootData();
            }
        }
    }

    //sned init data for application
    function startup()
    {
        setDefaultData();
        awdclient.startup();
    }

    function pageHandler(component) {
        switch (inDetailPage) {        
        case 2: awdPhotoDetailsView.showPhotoAtIndex(detailViewIndex);break;
        case 3:
        case 1:
            openBook(allPhotosComponent);
        case 0:
            //Fix me. Wrong detailViewIndex when 3 -> 2
            detailViewIndex = allPhotosModel.getIndexfromURN(awdclient.getData("urn"));
            addPage(photoDetailComponent);
            break;
        default:
            return;
        }
    }

    function setDefaultData() {
        //data to be transmitted
        //[widget] for data needed by widget only
        //[widget-current] for real-time data needed by widget which need to be transmitted all the time
        //[application] for data needed by application only
        //[application-start] for data needed by application only when application starts
        //[application-current] for real-time data needed by application which need to be transmitted all the time
        //[other] for other data which may be needed by both widget and application or for some special occasion
        var photoAwdData =
        {
            "urn"   : "",   //[application-widget-current]: set the current urn to sync photo detail view
        }
        awdclient.setCurrentData(photoAwdData);
    }

    //handle data from daemon
    function startUpControlHandle() {
        var identifier = awdclient.getData("urn")
        if(allPhotosModel.isURN(identifier)) {
            var itemtype = allPhotosModel.getTypefromURN(identifier);
            var title = allPhotosModel.getTitlefromURN(identifier);
            var index = allPhotosModel.getIndexfromURN(identifier);
            popPage()
            photoDetailModel = allPhotosModel;
            detailViewIndex = index;
            labelSinglePhoto = title;
            showFullscreen = false;
            showSlideshow = false;
            if(window.toolBarTitle == "Albums" || window.toolBarTitle == "Timeline") {
                openBook(allPhotosComponent)
            }
            addPage(photoDetailComponent);
        }
    }

    //handle control signal from widget
    function controlHandle() {
        var identifier = awdclient.getData("urn")
        if(allPhotosModel.isURN(identifier)) {
            var itemtype = allPhotosModel.getTypefromURN(identifier);
            var title = allPhotosModel.getTitlefromURN(identifier);
            var index = allPhotosModel.getIndexfromURN(identifier);
            photoDetailModel = allPhotosModel;
            detailViewIndex = index;
            labelSinglePhoto = title;
            showFullscreen = false;
            showSlideshow = false;
            pageHandler(photoDetailComponent);
        }
    }

    //init data when there is no photo at all
    function initNoPhotoData()
    {
        awdclient.setData("urn", "");
    }

    Connections {
        target: window.pageStack
        onCurrentPageChanged: {
            if(window.pageStack.depth == 3) {
                inDetailPage = 3
            }
            else if(window.toolBarTitle == "Photos" && window.pageStack.depth == 2) {
                inDetailPage = 2
            }
            else if((window.toolBarTitle == "Albums" || window.toolBarTitle == "Timeline") &&
                    (window.pageStack.depth == 2 || window.pageStack.depth == 1)) {
                inDetailPage = 1
            }
            else {
                inDetailPage = 0
            }
        }
    }

    Connections {
        target: awdPhotoDetailsView
        onCurrentItemChanged: {
            currentUrn = allPhotosModel.datafromIndex(allPhotosModel.itemIndex(currentPhotoItemId), MediaItem.URN);
            if(inDetailPage > 1) {
                if(awdclient.getData("urn") != currentUrn) {
                    awdclient.setData("urn", currentUrn);
                    awdclient.shootData();
                }
            }
        }
    }

    Timer {
        id: requestTest
        interval: 1000; running: true; repeat: false

        onTriggered: {
            startup();  //should use Component.onCompleted: {} to startup?
        }
    }
}


