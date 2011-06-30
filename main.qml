/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Components 0.1
import MeeGo.Media 0.1
import MeeGo.Sharing 0.1
import MeeGo.Sharing.UI 0.1
import Qt.labs.gestures 2.0

Window {
    id: window

    toolBarTitle: labelPhotoApp
    bookMenuModel: [labelTimeline, labelAllPhotos, labelAlbums]
    bookMenuPayload: [timelineComponent, allPhotosComponent, allAlbumsComponent]

    //the following properies are used for save/restore purposes
    property string firstPageObjectName: ""
    property string lastAlbumTitle: ""
    property bool okToRestoreAllAlbumsPage: true
    property bool okToRestoreAllPhotosPage: true
    property bool okToRestoreTimelinePage: true
    property bool okToRestoreAlbum: true
    property bool okToRestorePhoto: false
    property bool okToRestorePhotoSelection: true
    //These are needed in order to track whether the filter menu selection or a text search is the active filter.
    //The filter menu selection and a text search are mutually exclusive, they do not get combined
    property bool allAlbumsModelSearchActive: false
    property bool allVirtualAlbumsModelSearchActive: false
    property bool allPhotosModelSearchActive: false
    property bool allAlbumsFilterMenuActive: true
    property bool allVirtualAlbumsFilterMenuActive: true
    property bool allPhotosFilterMenuActive: true

    Component.onCompleted: {
        //check for restore
        if (windowState.restoreRequired) {
            //load our restore values
            var firstPage = windowState.value("firstPageObjectName", "allAlbumsPage")
            var lastPage = windowState.value("lastPageObjectName", "allAlbumsPage")
            lastAlbumTitle = windowState.value("lastAlbumTitle", "")
            allAlbumsModelSearchActive = windowState.value("allAlbumsModelSearchActive", false)
            allVirtualAlbumsModelSearchActive = windowState.value("allVirtualAlbumsModelSearchActive", false)
            allPhotosModelSearchActive = windowState.value("allPhotosModelSearchActive", false)
            allAlbumsFilterMenuActive = windowState.value("allAlbumsFilterMenuActive", false)
            allVirtualAlbumsFilterMenuActive = windowState.value("allVirtualAlbumsFilterMenuActive", false)
            allPhotosFilterMenuActive = windowState.value("allPhotosFilterMenuActive", false)
            //switch the the correct book and add the appropriate pages
            if (lastPage == "allPhotosPage") {
                openBook(allPhotosComponent)
                bookMenuSelectedIndex = 1
            }
            else if (lastPage == "timelinePage") {
                openBook(timelineComponent)
                bookMenuSelectedIndex = 0
            }
            else if (lastPage == "photoDetailPage") {
                if(firstPage == "allPhotosPage") {
                    openBook(allPhotosComponent)
                    bookMenuSelectedIndex = 1
                    photoDetailModel = allPhotosModel
                    okToRestorePhoto = true
                    addPage(photoDetailComponent)
                }
                else {
                    if(firstPage == "timelinePage") {
                        openBook(timelineComponent)
                        bookMenuSelectedIndex = 0
                    }
                    else {  //handle allAlbumsPage and invalid
                        openBook(allAlbumsComponent)
                        bookMenuSelectedIndex = 2
                    }
                    if(lastAlbumTitle != "") {
                        labelSingleAlbum = lastAlbumTitle
                        addPage(albumDetailComponent)
                        photoDetailModel = albumModel
                        okToRestorePhoto = true
                        addPage(photoDetailComponent)
                    }
                }
            }
            else if (lastPage == "albumDetailPage") {
                if(firstPage == "timelinePage") {
                    openBook(timelineComponent)
                    bookMenuSelectedIndex = 0
                }
                else {  //handle allAlbumsPage and invalid
                    openBook(allAlbumsComponent)
                    bookMenuSelectedIndex = 2
                }
                if(lastAlbumTitle != "") {
                    labelSingleAlbum = lastAlbumTitle
                    addPage(albumDetailComponent)
                }
            }
            else {  //handle allAlbumsPage and invalid
                openBook(allAlbumsComponent)
                bookMenuSelectedIndex = 2
            }
            //load this restore value last
            showToolBarSearch = windowState.value("showToolBarSearch", false)
        }
        else {
            openBook(timelineComponent)
        }

        loadingTimer.start()
    }

    SaveRestoreState {
        id: windowState
        onSaveRequired: {
            var lastPageObjectName = ""
            if(pageStack.depth > 0) {
                lastPageObjectName = pageStack.currentPage.objectName
            }
            setValue("lastPageObjectName", lastPageObjectName)
            setValue("firstPageObjectName", firstPageObjectName)
            setValue("lastAlbumTitle", albumModel.album)
            setValue("showToolBarSearch", showToolBarSearch)
            setValue("allAlbumsModelSearchActive", allAlbumsModelSearchActive)
            setValue("allVirtualAlbumsModelSearchActive", allVirtualAlbumsModelSearchActive)
            setValue("allPhotosModelSearchActive", allPhotosModelSearchActive)
            setValue("allAlbumsFilterMenuActive", allAlbumsFilterMenuActive)
            setValue("allVirtualAlbumsFilterMenuActive", allVirtualAlbumsFilterMenuActive)
            setValue("allPhotosFilterMenuActive", allPhotosFilterMenuActive)
            sync()
        }
    }

    //: This is a filter menu title
    property string labelFilters: qsTr("Show only:")
    //: This is a filter menu option for showing everything in the data model (photos/albums)
    property string labelAll: qsTr("All")
    //: This is a filter menu option for showing recently added items in the data model (photos/albums)
    property string labelNewest: qsTr("Newest")
    //: This is a filter menu option for showing items with favorite mark in the data model (photos/albums)
    property string labelFavorites: qsTr("Favorites")
    //: This is a filter menu option for showing items recently viewed in the data model (photos/albums)
    property string labelRecentlyViewed: qsTr("Recently viewed")
    //: This is a context menu option for sharing items (photos/albums)
    property string labelShare: qsTr("Share")
    //: This is the title of the application
    property string labelPhotoApp: qsTr("Photos")
    //: This is the title for the photos view
    property string labelAllPhotos: qsTr("Photos")
    //: This is the title for the albums view
    property string labelAlbums: qsTr("Albums")
    //: This is the title for the timeline view (Show by date)
    property string labelTimeline: qsTr("Timeline")
    //: This is the action menu button label for creating a new album
    property string labelNewAlbum : qsTr("New album")
    //: This is a context menu option for opening items (photos/albums)
    property string labelOpen: qsTr("Open")
    //: This is a context menu option for starting a slideshow of items (photos/album)
    property string labelPlay: qsTr("Play slideshow")
    //: This is a context menu option for changing to the fullscreen mode
    property string labelFullScreen: qsTr("Full screen")
    //: This is a context menu option for changing back from the fullscreen mode
    property string labelLeaveFullScreen: qsTr("Leave full screen")
    //: This is a context menu option for marking items (photos) as favorite
    property string labelFavorite: qsTr("Favorite", "Verb");
    //: This is a context menu option for removing favorite markings from items (photos)
    property string labelUnfavorite: qsTr("Unfavorite");
    //: This is a context menu option for adding items (photos) to albums
    property string labelAddToAlbum: qsTr("Add to album");
    //: This is a context menu option for removing items (photos) from album
    property string labelRemoveFromAlbum: qsTr("Remove from album")
    //: This is a title for the deletion confirmation modal dialog
    property string labelConfirmDelete: qsTr("Delete?")
    //: This is a context menu option for deleting items (photos/albums)
    property string labelDelete: qsTr("Delete")
    //: This is an action menu button label for deleting the current album
    property string labelDeleteAlbum: qsTr("Delete album")
    //: This is an action menu button label for deleting the current photo
    property string labelDeletePhoto: qsTr("Delete photo")
    //: This is an action menu button label for renaming the current album
    property string labelRenamePhoto: qsTr("Rename photo")
    //: This is a generic modal dialog reject button label
    property string labelCancel: qsTr("Cancel");
    //: This is a title for the new album creation modal dialog
    property string labelCreateNewAlbum: qsTr("Create new album")
    //: This is a create album modal dialog accept button label
    property string labelCreate: qsTr("Create")
    //: This is a create album modal dialog default text
    property string labelDefaultAlbumName: qsTr("Album name")
    //: This is a context menu option for setting a photo as the background image
    property string labelSetAsBackground: qsTr("Set as background")
    //: This is an action menu rename photo text entry area's default text
    property string labelDefaultNewPhotoName: qsTr("Type in a new name")

    //: This is a label for the photo deletion confirmation modal dialog when removing a photo
    property string labelDeletePhotoText: qsTr("Are you sure you want to delete this photo?")
    //: This is a label for the photo deletion confirmation modal dialog when removing an album
    property string labelDeleteAlbumText: qsTr("Are you sure you want to delete this album?")

    //: This is an information label telling the user that there are no photos
    property string labelNoPhotosText: qsTr("You have no photos")
    //: This is an information label telling the user that there are no recently added photos
    property string labelNoNewestPhotosText: qsTr("You haven't added any photos recently")
    //: This is an information label telling the user that none of the photos are marked as favorite
    property string labelNoFavoritePhotosText: qsTr("You don't have any favorite photos")
    //: This is an information label telling the user that none of the photos have been viewed for a while
    property string labelNoRecentlyViewedPhotosText: qsTr("You haven't viewed any photos recently")
    //: This is an information label telling the user that there are no albums
    property string labelNoAlbumsText: qsTr("You have no albums")
    //: This is an information label telling the user that there are no recently added albums
    property string labelNoNewestAlbumsText: qsTr("You haven't added any albums recently")
    //: This is an information label telling the user that none of the albums have been viewed recently
    property string labelNoRecentlyViewedAlbumsText: qsTr("You haven't viewed any albums recently")
    //: This is an information label telling the user that the current album is empty
    property string labelNoPhotosInAlbumText: qsTr("You don't have any photos in this album")

    //: This is an action button label launching the camera application
    property string labelNoContentTakePhotoButtonText: qsTr("Take a photo")
    //: This is an action button label for going to the photos view with all filter used
    property string labelNoContentViewPhotosButtonText: qsTr("View all photos")
    //: This is an action button label for creating a new album
    property string labelNoContentCreateAlbumButtonText: qsTr("Create an album")

    //: This is a label text for the photo details dialog. The %1 is a fuzzy date/time string, e.g. "1/31/11 - a few months ago"
    property string labelPhotoTakenOnText: qsTr("This photo was taken on\n%1")
    //: This is a label text for the photo details dialog. The %1 is a fuzzy date/time string, e.g. "1/31/11 - a few months ago"
    property string labelAlbumAddedOnText: qsTr("This album was added on\n%1")

    property string variableAllPhotosNoContentText: labelNoPhotosText
    property string variableAllPhotosNoContentButtonText: labelNoContentTakePhotoButtonText
    property string variableAllAlbumsNoContentText: labelNoAlbumsText
    property string variableAllAlbumsNoContentButtonText: labelNoContentCreateAlbumButtonText
    property string variableTimelineNoContentText: labelNoPhotosText
    property string variableTimelineNoContentButtonText: labelNoContentTakePhotoButtonText

    //: This is the default title for albums in album details view
    property string labelSingleAlbum: qsTr("Album title")
    onLabelSingleAlbumChanged: {
        albumModel.search = "";
    }

    property string albumId
    property bool albumIsVirtual

    property string currentAlbumAddedTime: ""

    //: This is the default title for photos in photo details view
    property string labelSinglePhoto: qsTr("Photo title")

    property string currentPhotoCreationTime: ""
    property string currentPhotoCamera: ""
    property string currentPhotoItemId: ""
    property string currentPhotoURI: ""

    property variant photoDetailModel
    property int detailViewIndex: 0
    property bool showFullscreen: false
    property bool showSlideshow: false
    property int detailModelCount: 0

    property bool modelConnectionReady: false

    property variant widgetPhotoDetailsView
    property variant widgetAlbumDetailsView

    overlayItem: Item {
        ShareObj {
            id: shareObj
            shareType: MeeGoUXSharingClientQmlObj.ShareTypeImage
        }

        TopItem {
            id: topItem
        }
    }

    function openBook(component) {
        if (component == allPhotosComponent) {
            allPhotosModel.filter = 0
            variableAllPhotosNoContentText = labelNoPhotosText
            variableAllPhotosNoContentButtonText = labelNoContentTakePhotoButtonText
        }
        else if (component == allAlbumsComponent) {
            allAlbumsModel.filter = 0
            variableAllAlbumsNoContentText = labelNoAlbumsText
            variableAllAlbumsNoContentButtonText = labelNoContentCreateAlbumButtonText
        }
        else if (component == timelineComponent) {
            allVirtualAlbumsModel.filter = 0
            variableTimelineNoContentText = labelNoPhotosText
            variableTimelineNoContentButtonText = labelNoContentTakePhotoButtonText
        }
        else {
            console.log("Unexpected component in openBook")
        }
        switchBook(component)
    }

    PhotoWidgetInterface {
    }

    Labs.BackgroundModel {
        id: backgroundModel
    }

    Labs.ApplicationsModel {
        id: appsModel
        directories: [ "/usr/share/meego-ux-appgrid/applications", "/usr/share/applications", "~/.local/share/applications" ]
    }

    PhotoListModel {
        id: allPhotosModel
        type: PhotoListModel.ListofPhotos
        limit: 0
        sort: PhotoListModel.SortByCreationTime
        onItemAvailable: {
            var itemtype
            var title
            var index
            var id

            if (allPhotosModel.isURN(identifier)) {
                itemtype = allPhotosModel.getTypefromURN(identifier)
                title = allPhotosModel.getTitlefromURN(identifier)
                index = allPhotosModel.getIndexfromURN(identifier)
                id = allPhotosModel.getIDfromURN(identifier)
            }
            else {
                itemtype = allPhotosModel.getTypefromID(identifier)
                title = allPhotosModel.getTitlefromID(identifier)
                index = allPhotosModel.itemIndex(identifier)
                id = identifier
            }

            if (index == -1) {
                console.log("available item has invalid index")
                return
            }

            if (itemtype == MediaItem.PhotoItem) {
                // load a photo passed on cmdline
                singlePhotoModel.clear()
                singlePhotoModel.addItems(id)
                photoDetailModel = singlePhotoModel
                detailViewIndex = 0
                labelSinglePhoto = title
                showFullscreen = true
                showSlideshow = false
                addPage(photoDetailComponent)
            }
        }

        onCountChanged: {
            detailModelCount = count
        }
    }

    PhotoListModel {
        id: singlePhotoModel
        type: PhotoListModel.Editor
        limit: 0
        sort: PhotoListModel.SortByDefault
    }

    PhotoListModel {
        id: albumModel
        type: PhotoListModel.PhotoAlbum
        limit: 0
        album: labelSingleAlbum
        sort: PhotoListModel.SortByDefault

        onCountChanged: {
            detailModelCount = count
        }
    }

    PhotoListModel {
        id: albumEditorModel
        type: PhotoListModel.PhotoAlbum
        limit: 1
        sort: PhotoListModel.SortByDefault
    }

    PhotoListModel {
        id: albumShareModel
        type: PhotoListModel.PhotoAlbum
        limit: 1
    }

    PhotoListModel {
        id: allAlbumsModel
        type: PhotoListModel.ListofUserAlbums
        limit: 0
        sort: PhotoListModel.SortByCreationTime
        onItemAvailable: {
            var itemtype = allAlbumsModel.getTypefromURN(identifier);
            var itemid = allAlbumsModel.getIDfromURN(identifier)
            var title = allAlbumsModel.getTitlefromURN(identifier);
            var index = allAlbumsModel.getIndexfromURN(identifier);
            if (itemtype == 1) {
                labelSingleAlbum = title;
                albumId = itemid;
                addPage(albumDetailComponent)
            }
        }
    }

    PhotoListModel {
        id: allVirtualAlbumsModel
        type: PhotoListModel.ListofVirtualAlbums
        limit: 0
        sort: PhotoListModel.SortByCreationTime
        onItemAvailable: {
            var itemtype = allVirtualAlbumsModel.getTypefromURN(identifier);
            var itemid = allVirtualAlbumsModel.getIDfromURN(identifier)
            var title = allVirtualAlbumsModel.getTitlefromURN(identifier);
            var index = allVirtualAlbumsModel.getIndexfromURN(identifier);
            if (itemtype == 1) {
                labelSingleAlbum = title;
                albumId = itemid;
                addPage(albumDetailComponent)
            }
        }
    }

    Timer {
        id: loadingTimer
        interval: 2000
        repeat: false
        onTriggered: {
            modelConnectionReady = true
        }
    }

    Connections {
         target: mainWindow
         onCall: {
             var cmd = parameters[0];
             var cdata = parameters[1];
             if (cmd == "showPhoto") {
                 allPhotosModel.requestItem(0, cdata);
             }
             else if (cmd == "showAlbum") {
                 allAlbumsModel.requestItem(1, cdata);
             }
             else if (cmd == "showTimeline") {
             }
             else {
                 console.log("Got unknown cmd "+ cmd)
             }
         }
     }

    Component {
        id: allPhotosComponent
        AppPage {
            id: allPhotosPage
            objectName: "allPhotosPage"
            anchors.fill: parent
            pageTitle: labelAllPhotos
            fullScreen: false

            property int modelCount: window.detailModelCount
            onModelCountChanged: {
                //our model has finished loading, restore the selected photos
                if (allPhotosPageState.restoreRequired && okToRestorePhotoSelection) {
                    //set our global flag to false so we don't try to restore again
                    okToRestorePhotoSelection = false
                    if(allPhotosView.selectionMode) {
                        allPhotosView.model.clearSelected()
                        var selectedIndexes = allPhotosPageState.value("allPhotosView.selectedIndexes", "")
                        for(var i in selectedIndexes) {
                            allPhotosView.currentIndex = selectedIndexes[i]
                            allPhotosView.model.setSelected(allPhotosView.currentItem.mitemid, true)
                            allPhotosToolbar.sharing.addItem(allPhotosView.currentItem.muri);
                        }
                        allPhotosView.selected = allPhotosView.model.getSelectedIDs();
                        allPhotosView.thumburis = allPhotosView.model.getSelectedURIs();
                    }
                }
            }

            onSearch: {
                allPhotosModelSearchActive = needle == "" ? false : true
                allPhotosFilterMenuActive = false
                allPhotosModel.search = needle;
            }

            enableCustomActionMenu: true
            actionMenuOpen: allPhotosActions.visible
            onActionMenuIconClicked: {
                allPhotosActions.setPosition(mouseX, mouseY)
                allPhotosActions.show()
            }

            SaveRestoreState {
                id: allPhotosPageState
                onSaveRequired: {
                    save()
                }

                function save() {
                    setValue("allPhotosActions.filterMenu.selectedIndex", filterMenu.selectedIndex)
                    setValue("allPhotosModel.search", allPhotosModel.search)
                    setValue("allPhotosView.selectionMode", allPhotosView.selectionMode)
                    setValue("allPhotosView.selectedIndexes", allPhotosView.selectedIndexes)
                    sync()
                }
            }

            Component.onCompleted: {
                firstPageObjectName = objectName
                if (allPhotosPageState.restoreRequired) {
                    if(okToRestoreAllPhotosPage) {
                        //set our global flag to false so we don't try to restore again when this page is loaded
                        okToRestoreAllPhotosPage = false
                        filterMenu.selectedIndex = allPhotosPageState.value("allPhotosActions.filterMenu.selectedIndex", 0)
                        if(allPhotosFilterMenuActive) {
                            filterMenu.setFilter(filterMenu.model[filterMenu.selectedIndex])
                        }
                        else if(allPhotosModelSearchActive) {
                            allPhotosModel.search = allPhotosPageState.value("allPhotosModel.search", "")
                        }
                        allPhotosView.selectionMode = allPhotosPageState.value("allPhotosView.selectionMode", false)
                    }
                }
            }

            Component.onDestruction: {
                //Save here so that this page is able to be restored properly.
                //onSaveRequired is not called when this is not the active book.
                allPhotosPageState.save()
            }

            ContextMenu {
                id: allPhotosActions
                forceFingerMode: 2

                content: Column {
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: labelFilters
                        font.pixelSize: theme_fontPixelSizeNormal
                        color: theme_fontColorHighlight
                    }

                    Item { width: 1; height: 10 } // spacer

                    Image {
                        width: parent.width
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    ActionMenu {
                        id: filterMenu
                        model: [ labelAll, labelNewest, labelFavorites, labelRecentlyViewed ]
                        selectedIndex: getIndexFromFilter(allPhotosModel.filter)
                        highlightSelectedItem: true

                        function getIndexFromFilter(filter) {
                            switch (filter) {
                            case PhotoListModel.FilterAll: return 0
                            case PhotoListModel.FilterAdded: return 1
                            case PhotoListModel.FilterFavorite: return 2
                            case PhotoListModel.FilterViewed: return 3
                            default:
                                console.log("Unexpected filter in action menu: " + allPhotosModel.filter)
                                return 0
                            }
                        }

                        function setFilter(label) {
                            allPhotosFilterMenuActive = true
                            if (label == labelAll) {
                                allPhotosModel.filter = PhotoListModel.FilterAll
                                variableAllPhotosNoContentText = labelNoPhotosText
                                variableAllPhotosNoContentButtonText = labelNoContentTakePhotoButtonText
                            }
                            else if (label == labelNewest) {
                                allPhotosModel.filter = PhotoListModel.FilterAdded
                                variableAllPhotosNoContentText = labelNoNewestPhotosText
                                variableAllPhotosNoContentButtonText = labelNoContentViewPhotosButtonText
                            }
                            else if (label == labelFavorites) {
                                allPhotosModel.filter = PhotoListModel.FilterFavorite
                                variableAllPhotosNoContentText = labelNoFavoritePhotosText
                                variableAllPhotosNoContentButtonText = labelNoContentViewPhotosButtonText
                            }
                            else if (label == labelRecentlyViewed) {
                                allPhotosModel.filter = PhotoListModel.FilterViewed
                                variableAllPhotosNoContentText = labelNoRecentlyViewedPhotosText
                                variableAllPhotosNoContentButtonText = labelNoContentViewPhotosButtonText
                            }
                            else {
                                console.log("Unexpected label in action menu: " + label)
                            }
                        }

                        onTriggered: {
                            setFilter(model[index])
                            allPhotosActions.hide()
                        }
                    }
                }
            }

            PhotoPicker {
                id: photopicker
                albumSelectionMode: true
                property variant payload: []
                onAlbumSelected: {
                    albumEditorModel.album = title;
                    albumEditorModel.addItems(photopicker.payload)
                }
            }

            ConfirmDelete {
                id: confirmer
                model: allPhotosModel

                onConfirmed: {
                    allPhotosModel.clearSelected()
                }
            }

            PhotosView {
                id: allPhotosView
                anchors.fill: parent
                anchors.bottom: parent.bottom
                model: allPhotosModel
                footerHeight: allPhotosToolbar.height
                noContentText: variableAllPhotosNoContentText
                noContentButtonText: variableAllPhotosNoContentButtonText
                modelConnectionReady: window.modelConnectionReady
                onOpenPhoto: {
                    photoDetailModel = allPhotosModel
                    detailViewIndex = mediaItem.mindex
                    labelSinglePhoto = mediaItem.mtitle
                    model.setViewed(mediaItem.elementid)
                    showFullscreen = fullscreen
                    showSlideshow = startSlideshow
                    addPage(photoDetailComponent)
                }
                onToggleSelectedPhoto: {
                    if (selected)
                        allPhotosToolbar.sharing.addItem(uri);
                    else
                        allPhotosToolbar.sharing.delItem(uri)
                }
                onPressAndHold : {
                    var map = payload.mapToItem(topItem.topItem, x, y);
                    allPhotosContextMenu.model = [labelOpen, labelPlay,
                                                  payload.mfavorite ? labelUnfavorite : labelFavorite,
                                                  labelShare, labelAddToAlbum,
                                                  labelMultiSelMode, labelSetAsBackground, labelDelete];
                    allPhotosContextMenu.payload = payload
                    allPhotosContextMenu.mouseX = map.x
                    allPhotosContextMenu.mouseY = map.y
                    allPhotosContextMenu.setPosition(map.x, map.y)
                    allPhotosContextMenu.show()
                }
                onNoContentAction: {
                    if ( allPhotosModel.filter == 0) {
                        appsModel.launchDesktopByName("/usr/share/meego-ux-appgrid/applications/meego-app-camera.desktop")
                    }
                    else {
                        window.openBook(allPhotosComponent)
                    }
                }
            }

            ContextMenu {
                id: allPhotosContextMenu
                property alias payload: allPhotosActionMenu.payload
                property alias model: allPhotosActionMenu.model
                property int mouseX
                property int mouseY

                content: ActionMenu {
                    id: allPhotosActionMenu
                    property variant payload: undefined

                    onTriggered: {
                        // context menu handler for all photos page
                        if (model[index] == labelOpen)
                        {
                            // Open the photo
                            allPhotosView.openPhoto(payload, false, false)
                        }
                        else if (model[index] == labelPlay)
                        {
                            // Kick off slide show starting with this photo
                            allPhotosView.openPhoto(payload, true, true)
                        }
                        else if (model[index] == labelFavorite || model[index] == labelUnfavorite)
                        {
                            // Mark as a favorite
                            allPhotosView.model.setFavorite(payload.mitemid, !payload.mfavorite)
                        }
                        else if (model[index] == labelShare)
                        {
                            // Share
                            shareObj.clearItems();
                            shareObj.addItem(payload.muri) // URI
                            shareObj.showContextTypes(allPhotosContextMenu.mouseX, allPhotosContextMenu.mouseY)
                        }
                        else if (model[index] == labelAddToAlbum)
                        {
                            allPhotosView.selected =  [payload.mitemid]
                            allPhotosView.thumburis =  [payload.mthumburi]
                            allPhotosView.currentIndex = payload.mindex
                            photopicker.payload = [payload.mitemid]
                            photopicker.show()
                        }
                        else if (model[index] == allPhotosView.labelMultiSelMode)
                        {
                            allPhotosView.selectionMode = !allPhotosView.selectionMode;
                        }
                        else if (model[index] == labelSetAsBackground) {
                            backgroundModel.activeWallpaper = payload.muri;
                        }
                        else if (model[index] == labelDelete)
                        {
                            confirmer.text = labelDeletePhotoText
                            confirmer.items = [ payload.mitemid ]
                            confirmer.show()
                        }
                        allPhotosContextMenu.hide()
                    }
                }
            }

            PhotoToolbar {
                id: allPhotosToolbar
                visible: allPhotosView.noContentVisible
                anchors.bottom: parent.bottom
                width: parent.width
                mode:  allPhotosView.selectionMode ? 2 : 1
                onPlay: {
                    // play button clicked in all photo view
                    allPhotosView.currentIndex = 0;
                    var item = allPhotosView.currentItem;

                    allPhotosModel.setViewed(item.elementid);
                    labelSinglePhoto = item.mtitle;
                    detailViewIndex = 0;
                    photoDetailModel = allPhotosModel;
                    showFullscreen = true
                    showSlideshow = true
                    addPage(photoDetailComponent)
                }
                onAddToAlbum : {
                    // TODO: don't display the item if there are no albums?
                    // if (allPhotosModel.getSelectedURIs().length > 0)
                    photopicker.payload = allPhotosView.selected
                    photopicker.show()
                }
                onDeleteSelected: {
                    if (allPhotosView.selected.length == 0) {
                        return
                    }

                    var text = labelDeletePhotoText
                    if (allPhotosView.selected.length != 1) {
                        //: This is a label for the photo deletion confirmation modal dialog when removing photos
                        text = qsTr("Are you sure you want to delete the %n selected photos?", "", allPhotosView.selected.length)
                    }

                    confirmer.text = text
                    confirmer.items = allPhotosView.selected
                    confirmer.show()
                }

                onCancel: {
                    allPhotosView.selectionMode = false;
                }
            }
        }
    }

    Component {
        id: allAlbumsComponent
        AppPage {
            id: allAlbumsPage
            objectName: "allAlbumsPage"
            anchors.fill: parent
            pageTitle: labelAlbums
            fullScreen: false

            onSearch: {
                allAlbumsModelSearchActive = needle == "" ? false : true
                allAlbumsFilterMenuActive = false
                allAlbumsModel.search = needle;
            }

            enableCustomActionMenu: true
            actionMenuOpen: allAlbumsActions.visible
            onActionMenuIconClicked: {
                allAlbumsActions.setPosition(mouseX, mouseY)
                allAlbumsActions.show()
            }

            SaveRestoreState {
                id: allAlbumsPageState
                onSaveRequired: {
                    save()
                }

                function save() {
                    setValue("allAlbumsActions.filterMenu.selectedIndex", filterMenu.selectedIndex)
                    setValue("allAlbumsModel.search", allAlbumsModel.search)
                    sync()
                }
            }

            Component.onCompleted: {
                firstPageObjectName = objectName
                if (allAlbumsPageState.restoreRequired) {
                    if(okToRestoreAllAlbumsPage) {
                        //set our global flag to false so we don't try to restore again when this page is loaded
                        okToRestoreAllAlbumsPage = false
                        filterMenu.selectedIndex = allAlbumsPageState.value("allAlbumsActions.filterMenu.selectedIndex", 0)
                        if(allAlbumsFilterMenuActive) {
                            filterMenu.setFilter(filterMenu.model[filterMenu.selectedIndex])
                        }
                        else if(allAlbumsModelSearchActive) {
                            allAlbumsModel.search = allAlbumsPageState.value("allAlbumsModel.search", "")
                        }
                    }
                }
            }

            Component.onDestruction: {
                //Save here so that this page is able to be restored properly.
                //onSaveRequired is not called when this is not the active book.
                allAlbumsPageState.save()
            }

            ContextMenu {
                id: allAlbumsActions
                forceFingerMode: 2

                content: Column {
                    property int margin: 10
                    width: Math.max(filterMenu.width, newAlbumButton.width + 2 * margin)

                    Button {
                        id: newAlbumButton
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: labelNewAlbum
                        onClicked: {
                            createAlbumDialog.show()
                            allAlbumsActions.hide()
                        }
                    }

                    Item { width: 1; height: parent.margin } // spacer

                    Image {
                        width: parent.width
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    Item { width: 1; height: parent.margin } // spacer

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: parent.margin
                        text: labelFilters
                        font.pixelSize: theme_fontPixelSizeNormal
                        color: theme_fontColorHighlight
                    }

                    Item { width: 1; height: parent.margin } // spacer

                    Image {
                        width: parent.width
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    ActionMenu {
                        id: filterMenu

                        // FIXME: removed favorites from this list since there is no UI for favorite albums
                        model: [ labelAll, labelNewest, labelRecentlyViewed ]
                        selectedIndex: getIndexFromFilter(allAlbumsModel.filter)
                        highlightSelectedItem: true

                        function getIndexFromFilter(filter) {
                            switch (filter) {
                            case PhotoListModel.FilterAll: return 0
                            case PhotoListModel.FilterAdded: return 1
                            case PhotoListModel.FilterViewed: return 2
                            default:
                                console.log("Unexpected filter in action menu: " + allAlbumsModel.filter)
                                return 0
                            }
                        }

                        function setFilter(label) {
                            allAlbumsFilterMenuActive = true
                            if (label == labelAll) {
                                allAlbumsModel.filter = PhotoListModel.FilterAll
                                variableAllAlbumsNoContentText = labelNoAlbumsText
                                variableAllAlbumsNoContentButtonText = labelNoContentCreateAlbumButtonText
                            }
                            else if (label == labelNewest) {
                                allAlbumsModel.filter = PhotoListModel.FilterAdded
                                variableAllAlbumsNoContentText = labelNoNewestAlbumsText
                                variableAllAlbumsNoContentButtonText = labelNoContentCreateAlbumButtonText
                            }
                            else if (label == labelRecentlyViewed) {
                                allAlbumsModel.filter = PhotoListModel.FilterViewed
                                variableAllAlbumsNoContentText = labelNoRecentlyViewedAlbumsText
                                variableAllAlbumsNoContentButtonText = labelNoContentCreateAlbumButtonText
                            }
                            else {
                                console.log("Unexpected label in action menu: " + label)
                            }
                        }

                        onTriggered: {
                            setFilter(model[index])
                            allAlbumsActions.hide()
                        }
                    }
                }
            }

            ModalDialog {
                id: createAlbumDialog
                title: labelCreateNewAlbum
                acceptButtonText: labelCreate

                content: Item {
                    property alias text: albumEntry.text
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.topMargin: 20
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 20

                    TextEntry {
                        id: albumEntry
                        defaultText: labelDefaultAlbumName
                        anchors.centerIn: parent
                        width: parent.width
                    }
                }

                onAccepted: {
                    albumEditorModel.album = albumEntry.text
                    albumEditorModel.saveAlbum()
                    albumEntry.text = ""
                }

                onRejected: {
                    albumEntry.text = ""
                }
            }

            AlbumsView {
                id: albumsView
                anchors.fill: parent
                noContentText: variableAllAlbumsNoContentText
                noContentButtonText: variableAllAlbumsNoContentButtonText
                modelConnectionReady: window.modelConnectionReady

                clip: true
                model:  allAlbumsModel
                onOpenAlbum: {
                    labelSingleAlbum = title;
                    currentAlbumAddedTime = addedtime;
                    albumId = elementid;
                    albumIsVirtual = isvirtual;
                    addPage(albumDetailComponent);
                    model.setViewed(albumId)
                }
                onPlaySlideshow: {
                    labelSingleAlbum = title;
                    albumId = elementid;
                    addPage(albumDetailComponent);
                    // TODO: this will require more thinking
                }
                onShareAlbum: {
                    shareObj.clearItems()
                    albumShareModel.album = title
                    var uris = albumShareModel.getAllURIs()
                    for (var i in uris) {
                        shareObj.addItem(uris[i])
                    }
                    shareObj.showContextTypes(mouseX, mouseY)
                }
                onNoContentAction: {
                    createAlbumDialog.show()
                }
            }
        }
    }


    Component {
        id: timelineComponent
        AppPage {
            id: timelinePage
            objectName: "timelinePage"
            anchors.fill: parent
            pageTitle: labelTimeline
            fullScreen: false

            onSearch: {
                allVirtualAlbumsModelSearchActive = needle == "" ? false : true
                allVirtualAlbumsFilterMenuActive = false
                allVirtualAlbumsModel.search = needle;
            }

            enableCustomActionMenu: true
            actionMenuOpen: timelineActions.visible
            onActionMenuIconClicked: {
                timelineActions.setPosition(mouseX, mouseY)
                timelineActions.show()
            }

            SaveRestoreState {
                id: timelinePageState
                onSaveRequired: {
                    save()
                }

                function save() {
                    setValue("timelineActions.filterMenu.selectedIndex", filterMenu.selectedIndex)
                    setValue("allVirtualAlbumsModel.search", allVirtualAlbumsModel.search)
                    sync()
                }
            }

            Component.onCompleted: {
                firstPageObjectName = objectName
                if (timelinePageState.restoreRequired) {
                    if(okToRestoreTimelinePage) {
                        //set our global flag to false so we don't try to restore again when this page is loaded
                        okToRestoreTimelinePage = false
                        filterMenu.selectedIndex = timelinePageState.value("timelineActions.filterMenu.selectedIndex", 0)
                        if(allVirtualAlbumsFilterMenuActive) {
                            filterMenu.setFilter(filterMenu.model[filterMenu.selectedIndex])
                        }
                        else if(allVirtualAlbumsModelSearchActive) {
                            allVirtualAlbumsModel.search = timelinePageState.value("allVirtualAlbumsModel.search", "")
                        }
                    }
                }
            }

            Component.onDestruction: {
                //Save here so that this page is able to be restored properly.
                //onSaveRequired is not called when this is not the active book.
                timelinePageState.save()
            }

            ContextMenu {
                id: timelineActions
                forceFingerMode: 2

                content: Column {
                    property int margin: 10
                    width: filterMenu.width

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: parent.margin
                        text: labelFilters
                        font.pixelSize: theme_fontPixelSizeNormal
                        color: theme_fontColorHighlight
                    }

                    Item { width: 1; height: parent.margin } // spacer

                    Image {
                        width: parent.width
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    ActionMenu {
                        id: filterMenu

                        model: [ labelAll, labelRecentlyViewed ]
                        selectedIndex: getIndexFromFilter(allAlbumsModel.filter)
                        highlightSelectedItem: true

                        function getIndexFromFilter(filter) {
                            switch (filter) {
                            case PhotoListModel.FilterAll: return 0
                            case PhotoListModel.FilterViewed: return 2
                            default:
                                console.log("Unexpected filter in action menu: " + allVirtualAlbumsModel.filter)
                                return 0
                            }
                        }

                        function setFilter(label) {
                            allVirtualAlbumsFilterMenuActive = true
                            if (label == labelAll) {
                                allVirtualAlbumsModel.filter = PhotoListModel.FilterAll
                                variableAllAlbumsNoContentText = labelNoAlbumsText
                                variableAllAlbumsNoContentButtonText = labelNoContentCreateAlbumButtonText
                            }
                            else if (label == labelRecentlyViewed) {
                                allVirtualAlbumsModel.filter = PhotoListModel.FilterViewed
                                variableAllAlbumsNoContentText = labelNoRecentlyViewedAlbumsText
                                variableAllAlbumsNoContentButtonText = labelNoContentCreateAlbumButtonText
                            }
                            else {
                                console.log("Unexpected label in action menu: " + label)
                            }
                        }

                        onTriggered: {
                            setFilter(model[index])
                            timelineActions.hide()
                        }
                    }
                }
            }

            AlbumsView {
                id: timelineView
                anchors.fill: parent
                noContentText: variableTimelineNoContentText
                noContentButtonText: variableTimelineNoContentButtonText
                modelConnectionReady: window.modelConnectionReady

                clip: true
                model:  allVirtualAlbumsModel
                onOpenAlbum: {
                    labelSingleAlbum = title;
                    currentAlbumAddedTime = addedtime;
                    albumId = elementid;
                    albumIsVirtual = isvirtual;
                    addPage(albumDetailComponent);
                    model.setViewed(albumId)
                }
                onPlaySlideshow: {
                    labelSingleAlbum = title;
                    albumId = elementid;
                    addPage(albumDetailComponent);
                }
                onShareAlbum: {
                    shareObj.clearItems()
                    albumShareModel.album = title
                    var uris = albumShareModel.getAllURIs()
                    for (var i in uris) {
                        shareObj.addItem(uris[i])
                    }
                    shareObj.showContextTypes(mouseX, mouseY)
                }
                onNoContentAction: {
                    appsModel.launchDesktopByName("/usr/share/meego-ux-appgrid/applications/meego-app-camera.desktop")
                }
            }
        }
    }

    Component {
        id: albumDetailComponent
        AppPage {
            id: albumDetailPage
            objectName: "albumDetailPage"
            anchors.fill: parent
            pageTitle: labelAlbums
            fullScreen: false

            onSearch:  {
                albumModel.search = needle;
            }

            enableCustomActionMenu: true
            actionMenuOpen: albumDetailActions.visible
            onActionMenuIconClicked: {
                albumDetailActions.setPosition(mouseX, mouseY)
                albumDetailActions.show()
            }

            resources: [
                FuzzyDateTime {
                    id: fuzzy
                }
            ]

            SaveRestoreState {
                id: albumDetailPageState
                onSaveRequired: {
                    save()
                }

                function save() {
                    setValue("albumModel.search", albumModel.search)
                    sync()
                }
            }

            Component.onCompleted: {
                firstPageObjectName = objectName
                if (albumDetailPageState.restoreRequired) {
                    if(okToRestoreAlbum) {
                        //set our global flag to false so we don't try to restore again when this page is loaded
                        okToRestoreAlbum = false
                        //check if this was the last album we were looking at and set the search appropriately
                        if(lastAlbumTitle == labelSingleAlbum) {
                            albumModel.search = albumDetailPageState.value("albumModel.search", "")
                        }
                    }
                }
            }

            Component.onDestruction: {
                //Save here so that this page is able to be restored properly.
                //onSaveRequired is not called when this is not the active page.
                albumDetailPageState.save()
            }

            ContextMenu {
                id: albumDetailActions
                forceFingerMode: 2

                content: Column {
                    id: albumDetailActionsContent
                    property int textMargin: 16
                    width: childrenRect.width

                    Text {
                        id: albumName
                        text: labelSingleAlbum
                        font.bold: true
                        font.pixelSize: theme_fontPixelSizeLarge
                        width: paintedWidth + 2 * parent.textMargin
                        height: paintedHeight + 2 * parent.textMargin
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: theme_contextMenuFontColor
                    }

                    Text {
                        id: albumCount
                        //: This is a metadata label for indicating the number of photos in the album
                        text: qsTr("%n photo(s)", "", albumModel.count)
                        font.pixelSize: theme_fontPixelSizeLarge
                        width: paintedWidth + 2 * parent.textMargin
                        height: paintedHeight + 2 * parent.textMargin
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: theme_contextMenuFontColor
                    }

                    Text {
                        id: albumAdded
                        text: labelAlbumAddedOnText.arg(fuzzy.getFuzzy(currentAlbumAddedTime))
                        font.pixelSize: theme_fontPixelSizeLarge
                        width: paintedWidth + 2 * parent.textMargin
                        height: paintedHeight + 2 * parent.textMargin
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: theme_contextMenuFontColor
                    }

                    Image {
                        id: alwaysVisibleSeparator
                        width: parent.width
                        visible: !albumIsVirtual
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    Item {
                        width: parent.width
                        height: button.height + parent.textMargin
                        anchors.horizontalCenter: parent.horizontalCenter
                        Button {
                            id: button
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            visible: !albumIsVirtual
                            text: labelDeleteAlbum
                            onClicked: {
                                albumDetailActions.hide()
                                confirmer.model = allAlbumsModel
                                confirmer.previousPage = true
                                confirmer.text = labelDeleteAlbumText
                                confirmer.items = [ albumId ]
                                confirmer.show()
                            }
                        }
                    }
                }
            }

            PhotoPicker {
                id: photopicker
                albumSelectionMode: true
                property variant payload: []
                onAlbumSelected: {
                    albumEditorModel.album = title;
                    albumEditorModel.addItems(photopicker.payload)
                }
            }

            ConfirmDelete {
                id: confirmer

                property bool previousPage: false

                onConfirmed: {
                    if (previousPage) {
                        window.popPage()
                    }
                }
            }

            PhotosView {
                id: albumDetailsView
                anchors.fill: parent
                anchors.bottom: parent.bottom
                footerHeight: albumDetailsToolbar.height
                model: albumModel
                cellBackgroundColor: "black"
                noContentText: labelNoPhotosInAlbumText
                noContentButtonText: labelNoContentViewPhotosButtonText
                modelConnectionReady: window.modelConnectionReady
                onOpenPhoto: {
                    // opening a photo from album detail view
                    photoDetailModel = albumModel
                    detailViewIndex = mediaItem.mindex
                    labelSinglePhoto = mediaItem.mtitle
                    model.setViewed(mediaItem.elementid)
                    showFullscreen = fullscreen
                    showSlideshow = startSlideshow
                    addPage(photoDetailComponent)
                }
                onPressAndHold : {
                    var map = payload.mapToItem(topItem.topItem, x, y);
                    albumDetailContextMenu.model = [labelOpen, labelPlay,
                                                    payload.mfavorite ? labelUnfavorite : labelFavorite,
                                                    labelShare, labelAddToAlbum,
                                                    // labelMultiSelMode,
                                                    labelRemoveFromAlbum, labelSetAsBackground, labelDelete]
                    albumDetailContextMenu.payload = payload
                    albumDetailContextMenu.mouseX = map.x
                    albumDetailContextMenu.mouseY = map.y
                    albumDetailContextMenu.setPosition(map.x, map.y)
                    albumDetailContextMenu.show()
                }
                onNoContentAction: {
                    window.openBook(allPhotosComponent)
                }
                Component.onCompleted: {
                    widgetAlbumDetailsView = albumDetailsView
                }
            }

            ContextMenu {
                id: albumDetailContextMenu
                property alias payload: albumDetailActionMenu.payload
                property alias model: albumDetailActionMenu.model
                property int mouseX
                property int mouseY

                content: ActionMenu {
                    id: albumDetailActionMenu
                    property variant payload: undefined

                    onTriggered: {
                        // context menu handler for all photos page
                        if (model[index] == labelOpen)
                        {
                            // Open the photo
                            albumDetailsView.openPhoto(payload, false, false)
                        }
                        else if (model[index] == labelPlay)
                        {
                            // Kick off slide show starting with this photo
                            albumDetailsView.openPhoto(payload, true, true)
                        }
                        else if (model[index] == labelFavorite || model[index] == labelUnfavorite)
                        {
                            // Mark as a favorite
                            albumDetailsView.model.setFavorite(payload.mitemid, !payload.mfavorite)
                        }
                        else if (model[index] == labelShare)
                        {
                            // Share
                            shareObj.clearItems();
                            shareObj.addItem(payload.muri) // URI
                            shareObj.showContextTypes(albumDetailContextMenu.mouseX, albumDetailContextMenu.mouseY)
                        }
                        else if (model[index] == labelAddToAlbum)
                        {
                            albumDetailsView.selected = [payload.mitemid]
                            albumDetailsView.thumburis = [payload.mthumburi]
                            albumDetailsView.currentIndex = payload.mindex;
                            photopicker.payload = [payload.mitemid];
                            photopicker.show();
                        }
                        else if (model[index] == labelRemoveFromAlbum)
                        {
                            albumModel.removeItems([payload.mitemid])
                        }
                        else if (model[index] == labelDelete)
                        {
                            confirmer.model = albumModel
                            confirmer.previousPage = false
                            confirmer.text = labelDeletePhotoText
                            confirmer.items = [ payload.mitemid ]
                            confirmer.show()
                        }
                        else if(model[index] == labelSetAsBackground) {
                            backgroundModel.activeWallpaper = payload.muri
                        }
                        albumDetailContextMenu.hide()
                    }
                }
            }

            PhotoToolbar {
                id: albumDetailsToolbar
                visible: albumDetailsView.noContentVisible
                anchors.bottom: parent.bottom
                width: parent.width
                mode: 1
                onPlay: {
                    // starting slideshow from album detail toolbar
                    albumDetailsView.currentIndex = 0;
                    var item = albumDetailsView.currentItem;

                    albumModel.setViewed(item.elementid);
                    labelSinglePhoto = item.mtitle;
                    detailViewIndex = 0;
                    photoDetailModel = albumModel;
                    showFullscreen = true
                    showSlideshow = true
                    addPage(photoDetailComponent)
                }
            }
        }
    }

    Component {
        id: photoDetailComponent

        AppPage {
            id: photoDetailPage
            objectName: "photoDetailPage"
            anchors.fill: parent
            pageTitle: window.toolBarTitle
            disableSearch: true

            property int modelCount: window.detailModelCount
            onModelCountChanged: {
                restorePhotoAtIndex(detailViewIndex)
            }

            function restorePhotoAtIndex(index) {
                if (photoDetailPageState.restoreRequired && okToRestorePhoto) {
                    //check if our desired photo has been loaded yet
                    if(photodtview.count > index) {
                        //set this global flag to false so we don't try to restore again
                        okToRestorePhoto = false
                        photodtview.currentIndex = index
                        photodtview.showPhotoAtIndex(index)
                        showSlideshow = photoDetailPageState.value("photodtview.startInSlideshow", 0)
                        if(showSlideshow) {
                            photodtview.startSlideshow()
                        }
                    }
                }
            }

            enableCustomActionMenu: true
            actionMenuOpen: photoDetailActions.visible
            onActionMenuIconClicked: {
                photoDetailActions.setPosition(mouseX, mouseY)
                photoDetailActions.show()
                entry.visible = false
            }

            resources: [
                FuzzyDateTime {
                    id: fuzzy
                }
            ]

            SaveRestoreState {
                id: photoDetailPageState
                onSaveRequired: {
                    setValue("photodtview.currentIndex", photodtview.currentIndex)
                    setValue("photodtview.startInFullscreen", photodtview.startInFullscreen)
                    setValue("photodtview.startInSlideshow", photodtview.startInSlideshow)
                    sync()
                }
            }

            Component.onCompleted: {
                //check the global flag
                if (photoDetailPageState.restoreRequired && okToRestorePhoto) {
                    detailViewIndex = photoDetailPageState.value("photodtview.currentIndex", 0)
                    showFullscreen = photoDetailPageState.value("photodtview.startInFullscreen", 0)
                    //try restoring the photo right away
                    restorePhotoAtIndex(detailViewIndex);
                }
                else {
                    photodtview.showPhotoAtIndex(detailViewIndex);
                }
            }

            ContextMenu {
                id: photoDetailActions
                forceFingerMode: 2

                content: Item {
                    GestureArea {
                        anchors.fill: parent

                        Tap {}
                        TapAndHold {}
                        Pan {}
                        Swipe {}
                        Pinch {}
                    }

                    property int margin: 10
                    property int textMargin: 16
                    width: Math.max(photoName.width, creation.width, camera.width, entry.width,
                                    renameButton.width, deleteButton.width) + 2 * textMargin
                    height: deleteButton.y + deleteButton.height - photoName.y + 2 * margin

                    onWidthChanged: {
                        console.log("FULL WIDTH: ", width, "height", height)
                    }

                    Text {
                        id: photoName
                        anchors.left: parent.left
                        anchors.leftMargin: parent.textMargin
                        anchors.top: parent.top
                        anchors.topMargin: parent.margin

                        onWidthChanged: {
                            console.log("photo name width", width)
                        }

                        text: labelSinglePhoto
                        visible: (text == "") ? 0 : 1
                        font.pixelSize: theme_contextMenuFontPixelSize
                        verticalAlignment: Text.AlignVCenter
                        color: theme_contextMenuFontColor
                    }

                    Text {
                        id: creation
                        anchors.top: photoName.bottom
                        anchors.topMargin: parent.margin
                        anchors.left: photoName.left

                        text: labelPhotoTakenOnText.arg(fuzzy.getFuzzy(currentPhotoCreationTime))
                        visible: (text == "") ? 0 : 1
                        font.pixelSize: theme_contextMenuFontPixelSize
                        verticalAlignment: Text.AlignVCenter
                        color: theme_contextMenuFontColor
                    }

                    Text {
                        id: camera
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: creation.bottom
                        anchors.topMargin: parent.margin

                        text: currentPhotoCamera
                        visible: (text == "") ? 0 : 1
                        height: (text == "") ? 0 : creation.height
                        font.bold: true
                        font.pixelSize: theme_fontPixelSizeLarge
                        verticalAlignment: Text.Top
                        color: theme_contextMenuFontColor
                    }

                    Image {
                        id: alwaysVisibleSeparator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: camera.visible ? camera.bottom : creation.bottom
                        anchors.margins: parent.textMargin
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    TextEntry {
                        id: entry
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: alwaysVisibleSeparator.bottom
                        anchors.margins: parent.textMargin
                        visible: false
                        opacity: visible ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation { duration: 600 }
                        }

                        defaultText: labelDefaultNewPhotoName
                    }

                    Image {
                        id: entrySeparator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: entry.bottom
                        anchors.margins: parent.textMargin
                        visible: entry.visible
                        opacity: visible ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation { duration: 600 }
                        }
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    Button {
                        id: renameButton
                        anchors.top: entrySeparator.visible ? entrySeparator.bottom : alwaysVisibleSeparator.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: parent.margin
                        bgSourceUp: "image://themedimage/widgets/common/button/button-default"
                        bgSourceDn: "image://themedimage/widgets/common/button/button-default-pressed"

                        Behavior on x {
                            NumberAnimation { duration: 500 }
                        }

                        text: labelRenamePhoto
                        onClicked: {
                            if (entry.visible != true) {
                                entry.visible = true
                            }
                            else if (entry.text != "") {
                                photoDetailModel.changeTitle(currentPhotoURI, entry.text)
                                labelSinglePhoto = entry.text
                                photoDetailActions.hide()
                            }
                        }
                    }

                    Button {
                        id: deleteButton
                        anchors.top: renameButton.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: parent.margin
                        bgSourceUp: "image://themedimage/widgets/common/button/button-negative"
                        bgSourceDn: "image://themedimage/widgets/common/button/button-negative-pressed"

                        text: labelDeletePhoto
                        onClicked: {
                            photoDetailActions.hide()
                            confirmer.text = labelDeletePhotoText
                            confirmer.items = [ currentPhotoItemId ]
                            confirmer.show()
                        }
                    }
                }
            }

            PhotoPicker {
                id: photopicker
                albumSelectionMode: true
                property variant payload: []
                onAlbumSelected: {
                    albumEditorModel.album = title;
                    albumEditorModel.addItems(photopicker.payload)
                }
            }

            ConfirmDelete {
                id: confirmer
                model: photoDetailModel

                onConfirmed: {
                    window.popPage()
                }
            }

            PhotoDetailsView {
                id: photodtview
                anchors.fill: parent
                model: photoDetailModel
                appPage: photoDetailPage
                initialIndex: detailViewIndex

                startInFullscreen: showFullscreen
                startInSlideshow: showSlideshow

                onPressAndHoldOnPhoto: {
                    var map = mapToItem(topItem.topItem, mouse.x, mouse.y)
                    photoDetailContextMenu.model = [photodtview.viewMode ? labelLeaveFullScreen : labelFullScreen,
                                             labelPlay, labelShare,
                                             instance.pfavorite ? labelUnfavorite : labelFavorite,
                                             labelAddToAlbum, labelSetAsBackground, labelDelete];
                    photoDetailContextMenu.payload = instance
                    photoDetailContextMenu.mouseX = map.x
                    photoDetailContextMenu.mouseY = map.y
                    photoDetailContextMenu.setPosition(map.x, map.y)
                    photoDetailContextMenu.show()
                }
                onCurrentItemChanged: {
                    labelSinglePhoto = currentItem.ptitle
                    currentPhotoCreationTime = currentItem.pcreation
                    currentPhotoCamera = currentItem.pcamera
                    currentPhotoItemId = currentItem.pitemid
                    currentPhotoURI = currentItem.puri
                }

                Component.onCompleted: {
                    showPhotoAtIndex(detailViewIndex);
                    widgetPhotoDetailsView = photodtview;
                }
            }

            ContextMenu {
                id: photoDetailContextMenu
                property alias payload: photoDetailActionMenu.payload
                property alias model: photoDetailActionMenu.model
                property int mouseX
                property int mouseY

                content: ActionMenu {
                    id: photoDetailActionMenu
                    property variant payload: undefined

                    onTriggered: {
                        // context menu handler for photo details page
                        if (model[index] == labelLeaveFullScreen || model[index] == labelFullScreen) {
                            // toggle full screen
                            photodtview.viewMode = photodtview.viewMode ? 0 : 1;
                        }
                        else if (model[index] == labelPlay) {
                            // Kick off slide show starting with this photo
                            photodtview.startSlideshow();
                        }
                        else if (model[index] == labelShare) {
                            // Share
                            shareObj.clearItems();
                            shareObj.addItem(payload.puri) // URI
                            shareObj.showContextTypes(photoDetailContextMenu.mouseX, photoDetailContextMenu.mouseY)
                        }
                        else if (model[index] == labelFavorite || model[index] == labelUnfavorite) {
                            // Mark as a favorite
                            photodtview.toolbar.isFavorite = !payload.pfavorite;
                            photodtview.model.setFavorite(payload.pitemid, !payload.pfavorite);
                        }
                        else if (model[index] == labelAddToAlbum) {
                            // Add to album
                            photopicker.payload = [payload.pitemid]
                            photopicker.show()
                        }
                        else if (model[index] == labelSetAsBackground) {
                            backgroundModel.activeWallpaper = payload.puri;
                        }
                        else if (model[index] == labelDelete) {
                            // Delete
                            confirmer.text = labelDeletePhotoText
                            confirmer.items = [ payload.pitemid ]
                            confirmer.show()
                        }
                        photoDetailContextMenu.hide()
                    }
                }
            }
        }
    }
}
