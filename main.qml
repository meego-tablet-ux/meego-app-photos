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

    Component.onCompleted: {
        openBook(timelineComponent)
        loadingTimer.start()
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
                showFullscreen = false
                showSlideshow = false
                addPage(photoDetailComponent)
            }
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
            anchors.fill: parent
            pageTitle: labelAllPhotos
            fullScreen: false

            onSearch: {
                allPhotosModel.search = needle;
            }

            enableCustomActionMenu: true
            actionMenuOpen: allPhotosActions.visible
            onActionMenuIconClicked: {
                allPhotosActions.setPosition(mouseX, mouseY)
                allPhotosActions.show()
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
            anchors.fill: parent
            pageTitle: labelAlbums
            fullScreen: false

            onSearch: {
                allAlbumsModel.search = needle;
            }

            enableCustomActionMenu: true
            actionMenuOpen: allAlbumsActions.visible
            onActionMenuIconClicked: {
                allAlbumsActions.setPosition(mouseX, mouseY)
                allAlbumsActions.show()
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
            anchors.fill: parent
            pageTitle: labelTimeline
            fullScreen: false

            onSearch: {
                allVirtualAlbumsModel.search = needle;
            }

            enableCustomActionMenu: true
            actionMenuOpen: timelineActions.visible
            onActionMenuIconClicked: {
                timelineActions.setPosition(mouseX, mouseY)
                timelineActions.show()
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

            Component.onCompleted: {
                albumModel.album = labelSingleAlbum;
            }
        }
    }

    Component {
        id: photoDetailComponent

        AppPage {
            id: photoDetailPage
            anchors.fill: parent
            pageTitle: window.toolBarTitle
            disableSearch: true

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
