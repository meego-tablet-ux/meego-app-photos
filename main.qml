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

Window {
    id: window

    toolBarTitle: labelPhotoApp
    bookMenuModel: [labelAllPhotos, labelAlbums]
    bookMenuPayload: [allPhotosComponent, allAlbumsComponent]

    Component.onCompleted: {
        switchBook(allPhotosComponent)
        loadingTimer.start()
    }

    property string labelAll: qsTr("All")
    property string labelRecentlyAdded: qsTr("Recently added")
    property string labelRecentlyViewed: qsTr("Last viewed")
    property string labelFavorites: qsTr("Favorites")
    property string labelShare: qsTr("Share")
    property string labelPhotoApp: qsTr("Photos")
    property string labelAllPhotos: qsTr("All photos")
    property string labelAlbums: qsTr("Albums")
    property string labelNewAlbum : qsTr("New album")
    property string labelOpen: qsTr("Open")
    property string labelPlay: qsTr("Play slideshow")
    property string labelFullScreen: qsTr("Full screen")
    property string labelLeaveFullScreen: qsTr("Leave full screen")
    property string labelFavorite: qsTr("Favorite");
    property string labelUnfavorite: qsTr("Unfavorite");
    property string labelAddToAlbum: qsTr("Add to album");
    property string labelRemoveFromAlbum: qsTr("Remove from album")
    property string labelConfirmDelete: qsTr("Delete?")
    property string labelDelete: qsTr("Delete")
    property string labelDeleteAlbum: qsTr("Delete album")
    property string labelDeletePhoto: qsTr("Delete photo")
    property string labelRenamePhoto: qsTr("Rename photo")
    property string label1Photo: qsTr("1 photo")
    property string labelNPhotos: qsTr("%1 photos")
    property string labelCreateNewAlbum: qsTr("Create new album")
    property string labelCancel: qsTr("Cancel");
    property string labelSetAsBackground: qsTr("Set as background")
    property string labelViewBy: qsTr("View by:")

    property string labelDeletePhotoText: qsTr("Are you sure you want to delete this photo?")
    property string labelDeletePhotosText: qsTr("Are you sure you want to delete the %1 selected photos?")
    property string labelDeleteAlbumText: qsTr("Are you sure you want to delete this album?")

    property string labelNoPhotosText: qsTr("You have no photos")
    property string labelNoRecentlyAddedPhotosText: qsTr("You haven't added any photos recently")
    property string labelNoFavoritePhotosText: qsTr("You don't have any favorite photos")
    property string labelNoRecentlyViewedPhotosText: qsTr("You haven't viewed any photos recently")
    property string labelNoAlbumsText: qsTr("You have no albums")
    property string labelNoRecentlyAddedAlbumsText: qsTr("You haven't added any albums recently")
    property string labelNoPhotosInAlbumText: qsTr("You don't have any photos in this album")

    property string labelNoContentTakePhotoButtonText: qsTr("Take a photo")
    property string labelNoContentViewPhotosButtonText: qsTr("View all photos")
    property string labelNoContentCreateAlbumButtonText: qsTr("Create an album")

    property string labelSingleAlbum: qsTr("Album title")
    onLabelSingleAlbumChanged: {
        albumModel.search = "";
    }

    property string albumId
    property bool albumIsVirtual

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

    overlayItem: Item {
        ShareObj {
            id: shareObj
            shareType: MeeGoUXSharingClientQmlObj.ShareTypeImage
        }

        TopItem {
            id: topItem
        }
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
        sort:PhotoListModel.SortByDefault
        onItemAvailable: {
            var itemtype;
            var title;
            var index;

            if(allPhotosModel.isURN(identifier)) {
                itemtype = allPhotosModel.getTypefromURN(identifier);
                title = allPhotosModel.getTitlefromURN(identifier);
                index = allPhotosModel.getIndexfromURN(identifier);
            }
            else {
                itemtype = allPhotosModel.getTypefromID(identifier);
                title = allPhotosModel.getTitlefromID(identifier);
                index = allPhotosModel.itemIndex(identifier);
            }

            if (index == -1)
                return;
            if (itemtype == 0) {
                // load a photo passed on cmdline
                popPage()
                photoDetailModel = allPhotosModel;
                detailViewIndex = index;
                labelSinglePhoto = title;
                showFullscreen = false;
                showSlideshow = false;
                addPage(photoDetailComponent);
            }
        }
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
        type: PhotoListModel.ListofAlbums
        limit: 0
        sort:PhotoListModel.SortByDefault
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
                 switchBook(allPhotosComponent)
                 allPhotosModel.requestItem(0, cdata);
             }
             else if (cmd == "showAlbum") {
                 switchBook(allAlbumsComponent)
                 allAlbumsModel.requestItem(1, cdata);
             }
             else {
                 console.log("Got unknown cmd "+ cmd)
             }
         }
     }

    Loader {
        id: contextLoader
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
                        text: qsTr("Show only:")
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
                        model: [ labelAll, labelRecentlyAdded, labelFavorites, labelRecentlyViewed ]
                        selectedIndex: getIndexFromFilter(allPhotosModel.filter)
                        highlightSelectedItem: true

                        function getIndexFromFilter(filter) {
                            switch (filter) {
                            case 0: return 0
                            case 1: return 2
                            case 2: return 3
                            case 3: return 1
                            default:
                                    console.log("Unexpected filter in action menu: " + allPhotosModel.filter)
                                return 0
                            }
                        }

                        function setFilter(label) {
                            if (label == labelAll) {
                                allPhotosModel.filter = 0
                                allPhotosView.noContentText = labelNoPhotosText
                                allPhotosView.noContentButtonText = labelNoContentTakePhotoButtonText
                            }
                            else if (label == labelRecentlyAdded) {
                                allPhotosModel.filter = 3
                                allPhotosView.noContentText = labelNoRecentlyAddedPhotosText
                                allPhotosView.noContentButtonText = labelNoContentViewPhotosButtonText
                            }
                            else if (label == labelFavorites) {
                                allPhotosModel.filter = 1
                                allPhotosView.noContentText = labelNoFavoritePhotosText
                                allPhotosView.noContentButtonText = labelNoContentViewPhotosButtonText
                            }
                            else if (label == labelRecentlyViewed) {
                                allPhotosModel.filter = 2
                                allPhotosView.noContentText = labelNoRecentlyViewedPhotosText
                                allPhotosView.noContentButtonText = labelNoContentViewPhotosButtonText
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
                noContentText: labelNoPhotosText
                noContentButtonText: labelNoContentTakePhotoButtonText
                modelConnectionReady: window.modelConnectionReady
                onOpenPhoto: {
                    photoDetailModel = allPhotosModel;
                    detailViewIndex = currentIndex;
                    labelSinglePhoto = item.mtitle
                    model.setViewed(item.elementid);
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
                        window.switchBook(allPhotosComponent)
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
                            allPhotosView.currentIndex = payload.mindex;
                            allPhotosView.openPhoto(payload, false, false);
                        }
                        else if (model[index] == labelPlay)
                        {
                            // Kick off slide show starting with this photo
                            allPhotosView.currentIndex = payload.mindex;
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
                        text = labelDeletePhotosText.arg(allPhotosView.selected.length)
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
                    width: Math.max(filterMenu.width, newAlbumButton.width)

                    Button {
                        id: newAlbumButton
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: labelNewAlbum
                        onClicked: {
                            createAlbumDialog.show()
                            allAlbumsActions.hide()
                        }
                    }

                    Item { width: 1; height: 10 } // spacer

                    Image {
                        width: parent.width
                        source: "image://themedimage/images/menu_item_separator"
                    }

                    Item { width: 1; height: 10 } // spacer

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: qsTr("Show only:")
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

                        // FIXME: removed favorites from this list since there is no UI for favorite albums
                        // FIXME: removed recently viewed from this list since it's not clear when
                        //        to tag an album as "viewed" - consult UX team
                        model: [ labelAll, labelRecentlyAdded ]
                        selectedIndex: allAlbumsModel.filter ? 1:0

                        function setFilter(label) {
                            if (label == labelAll) {
                                allAlbumsModel.filter = 0
                                albumsView.noContentText = labelNoAlbumsText
                                albumsView.noContentButtonText = labelNoContentCreateAlbumButtonText
                            }
                            else if (label == labelRecentlyAdded) {
                                allAlbumsModel.filter = 3
                                albumsView.noContentText = labelNoRecentlyAddedAlbumsText
                                albumsView.noContentButtonText = labelNoContentCreateAlbumButtonText
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
                acceptButtonText: qsTr("Create")

                content: Item {
                    property alias text: albumEntry.text
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.topMargin: 20
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 20

                    TextEntry {
                        id: albumEntry
                        defaultText: qsTr("Album name")
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
                noContentText: labelNoAlbumsText
                noContentButtonText: labelNoContentCreateAlbumButtonText

                clip: true
                model:  allAlbumsModel
                onOpenAlbum: {
                    labelSingleAlbum = title;
                    albumId = elementid;
                    albumIsVirtual = isvirtual;
                    addPage(albumDetailComponent);
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

            ContextMenu {
                id: albumDetailActions
                forceFingerMode: 2

                content: Column {
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
                        text: albumModel.count == 1 ? label1Photo : labelNPhotos.arg(albumModel.count)
                        font.pixelSize: theme_fontPixelSizeLarge
                        width: paintedWidth + 2 * parent.textMargin
                        height: paintedHeight + 2 * parent.textMargin
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: theme_contextMenuFontColor
                    }

                    Item {
                        width: button.width + 2 * parent.textMargin
                        height: button.height + 2 * parent.textMargin - 8

                        visible: !albumIsVirtual;

                        Button {
                            id: button
                            anchors.centerIn: parent
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
                    photoDetailModel = albumModel;
                    detailViewIndex = currentIndex;
                    labelSinglePhoto = item.mtitle
                    model.setViewed(item.elementid);
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
                    window.switchBook(allPhotosComponent)
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
                            albumDetailsView.currentIndex = payload.mindex;
                            albumDetailsView.openPhoto(payload, false, false);
                        }
                        else if (model[index] == labelPlay)
                        {
                            // Kick off slide show starting with this photo
                            albumDetailsView.currentIndex = payload.mindex;
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
            }

            resources: [
                Labs.FuzzyDateTime {
                    id: fuzzy
                }
            ]

            ContextMenu {
                id: photoDetailActions
                forceFingerMode: 2

                content: Item {
                    property int textMargin: 16
                    width: Math.max(renameButton.width, creation.width, 300) + 2 * textMargin
                    height: childrenRect.height + 2 * textMargin

                    TextEntry {
                        id: entry
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: parent.textMargin

                        text: labelSinglePhoto
                    }

                    Button {
                        id: renameButton
                        anchors.top: entry.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: parent.textMargin

                        text: labelRenamePhoto
                        onClicked: {
                            photoDetailActions.hide()
                            if (entry.text != "") {
                                photoDetailModel.changeTitle(currentPhotoURI, entry.text)
                                labelSinglePhoto = entry.text
                            }
                        }
                    }

                    Text {
                        id: creation
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: renameButton.bottom
                        anchors.topMargin: parent.textMargin

                        text: fuzzy.getFuzzy(currentPhotoCreationTime)
                        visible: (text == "")? 0 : 1
                        font.pixelSize: theme_contextMenuFontPixelSize
                        verticalAlignment: Text.AlignVCenter
                        color: theme_contextMenuFontColor
                    }

                    Text {
                        id: camera
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: creation.bottom
                        anchors.topMargin: parent.textMargin

                        text: currentPhotoCamera
                        visible: (text == "")? 0 : 1
                        height: (text == "")? 0 : creation.height
                        font.bold: true
                        font.pixelSize: theme_fontPixelSizeLarge
                        verticalAlignment: Text.Top
                        color: theme_contextMenuFontColor
                    }

                    Button {
                        id: button
                        anchors.top: (camera.height > 0)? camera.bottom : creation.bottom
                        anchors.topMargin: parent.textMargin
                        anchors.horizontalCenter: parent.horizontalCenter

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
                currentIndex: detailViewIndex

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
