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

Labs.Window {
    id: scene

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
    property string labelNoFavouritePhotosText: qsTr("You don't have any favourite photos")
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

    Labs.ShareObj {
        id: shareObj
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

            if(allPhotosModel.isURN(identifier))
            {
                itemtype = allPhotosModel.getTypefromURN(identifier);
                title = allPhotosModel.getTitlefromURN(identifier);
                index = allPhotosModel.getIndexfromURN(identifier);
            }
            else
            {
                itemtype = allPhotosModel.getTypefromID(identifier);
                title = allPhotosModel.getTitlefromID(identifier);
                index = allPhotosModel.itemIndex(identifier);
            }

            console.log("Photo Name: " + title);
            if (index == -1)
                return;
            if (itemtype == 0) {
                // load a photo passed on cmdline
                previousApplicationPage();
                photoDetailModel = allPhotosModel;
                detailViewIndex = index;
                labelSinglePhoto = title;
                showFullscreen = false;
                showSlideshow = false;
                addApplicationPage(photoDetailComponent);
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
            console.log("Album Name: " + title);
            if (itemtype == 1) {
                labelSingleAlbum = title;
                albumId = itemid;
                addApplicationPage(albumDetailComponent)
            }
        }
    }
    title: labelPhotoApp

    showsearch: true
    filterModel: [labelAllPhotos,labelAlbums]

    Component.onCompleted: {
        // workaround because setting it initially doesn't work atm
        applicationPage = allPhotosComponent
    }

    // when a selection is made in the filter menu, you will get a signal here:
    onFilterTriggered: {
        if (index == 0)
            scene.applicationPage = allPhotosComponent;
        else if (index == 1)
            scene.applicationPage = allAlbumsComponent;
    }

    Connections {
         target: mainWindow
         onCall: {
             var cmd = parameters[0];
             var cdata = parameters[1];
             if (cmd == "showPhoto") {
                 scene.applicationPage = allPhotosComponent
                 allPhotosModel.requestItem(0, cdata);
             } else if(cmd == "showAlbum") {
                 scene.applicationPage = allAlbumsComponent
                 allAlbumsModel.requestItem(1, cdata);
             } else {
                 console.log("Got unknown cmd "+ cmd)
             }
         }
     }

    onStatusBarTriggered: {
        orientation = (orientation +1)%4;
    }

    Loader {
        id: contextLoader
    }

    Component {
        id: allPhotosComponent
        Labs.ApplicationPage {
            id: allPhotosPage
            anchors.fill: parent
            title: labelAllPhotos
            onSearch: {
                allPhotosModel.search = needle;
            }

            menuContent: Labs.ActionMenu {
                id: filterMenu
                title: labelViewBy
                highlightIndex: getIndexFromFilter(allPhotosModel.filter)
                model: [ labelAll, labelRecentlyAdded, labelFavorites, labelRecentlyViewed ]

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
                        allPhotosView.noContentText = labelNoFavouritePhotosText
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
                    allPhotosPage.closeMenu();
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
                parent: allPhotosPage.content
                anchors.fill: parent
                anchors.bottom: parent.bottom
                model: allPhotosModel
                footerHeight: allPhotosToolbar.height
                noContentText: labelNoPhotosText
                noContentButtonText: labelNoContentTakePhotoButtonText
                onOpenPhoto: {
                    photoDetailModel = allPhotosModel;
                    detailViewIndex = currentIndex;
                    labelSinglePhoto = item.mtitle
                    model.setViewed(item.elementid);
                    showFullscreen = fullscreen
                    showSlideshow = startSlideshow
                    allPhotosPage.addApplicationPage(photoDetailComponent)
                }
                onEnteredSingleSelectMode: {
                }
                onToggleSelectedPhoto: {
                    if (selected)
                        allPhotosToolbar.sharing.addItem(uri);
                    else
                        allPhotosToolbar.sharing.delItem(uri);
                }
                onPressAndHold : {
                    var map = payload.mapToItem(scene, x, y);
                    allPhotosContextMenu.model = [labelOpen, labelPlay,
                                                  payload.mfavorite ? labelUnfavorite : labelFavorite,
                                                  labelShare, labelAddToAlbum,
                                                  labelMultiSelMode, labelSetAsBackground, labelDelete];
                    allPhotosContextMenu.payload = payload;
                    allPhotosContextMenu.menuX = map.x;
                    allPhotosContextMenu.menuY = map.y;
                    allPhotosContextMenu.visible = true;
                }
                onNoContentAction: {
                    if ( allPhotosModel.filter == 0) {
                        appsModel.launchDesktopByName("/usr/share/meego-ux-appgrid/applications/meego-app-camera.desktop")
                    } else {
                        scene.applicationPage = allPhotosComponent;
                    }
                }
            }

            Labs.ContextMenu {
                id: allPhotosContextMenu
                onClose: contextLoader.sourceComponent = undefined
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
                        shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeImage
                        shareObj.showContextTypes(mouseX, mouseY)
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
                        allPhotosView.selectionMode = !container.selectionMode;
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
                }
            }

            PhotoToolbar {
                id: allPhotosToolbar
                visible: allPhotosView.noContentVisible
                parent: allPhotosPage.content
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
                    allPhotosPage.addApplicationPage(photoDetailComponent)
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

            Component.onCompleted: {
                scene.fullscreen = false;
                scene.showsearch = true;
            }
        }
    }

    Component {
        id: allAlbumsComponent
        Labs.ApplicationPage {
            id: allAlbumsPage
            anchors.fill: parent
            title: labelAlbums

            onSearch: {
                allAlbumsModel.search = needle;
            }

            menuContent: Item {
                width: filterMenu.width
                height: filterMenu.height + actionsMenu.height

                Labs.ActionMenu {
                    id: actionsMenu
                    model: [ labelNewAlbum ]
                    onTriggered: {
                        createAlbumDialog.show()
                        allAlbumsPage.closeMenu();
                    }
                }

                Image {
                    id: separator
                    anchors.top: actionsMenu.bottom
                    width: parent.width
                    source: "image://theme/menu_item_separator"
                }

                Labs.ActionMenu {
                    id: filterMenu
                    anchors.top: separator.bottom
                    anchors.topMargin: 5
                    title: labelViewBy
                    highlightIndex: allAlbumsModel.filter ? 1:0

                    // FIXME: removed favorites from this list since there is no UI for favorite albums
                    // FIXME: removed recently viewed from this list since it's not clear when
                    //        to tag an album as "viewed" - consult UX team
                    model: [ labelAll, labelRecentlyAdded ]

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
                        allAlbumsPage.closeMenu();
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
                parent:allAlbumsPage.content
                anchors.fill: parent
                noContentText: labelNoAlbumsText
                noContentButtonText: labelNoContentCreateAlbumButtonText

                clip: true
                model:  allAlbumsModel
                onOpenAlbum: {
                    labelSingleAlbum = title;
                    albumId = elementid;
                    albumIsVirtual = isvirtual;
                    allAlbumsPage.addApplicationPage(albumDetailComponent);
                }
                onPlaySlideshow: {
                    labelSingleAlbum = title;
                    albumId = elementid;
                    allAlbumsPage.addApplicationPage(albumDetailComponent);
                    // TODO: this will require more thinking
                }
                onShareAlbum: {
                    shareObj.clearItems()
                    albumShareModel.album = title
                    var uris = albumShareModel.getAllURIs()
                    for (var i in uris) {
                        shareObj.addItem(uris[i])
                    }
                    shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeImage
                    shareObj.showContextTypes(mouseX, mouseY)
                }
                onNoContentAction: {
                    createAlbumDialog.show()
                }
            }
            Component.onCompleted: {
                scene.fullscreen = false;
                scene.showsearch = true;
            }
        }
    }

    Component {
        id: albumDetailComponent
        Labs.ApplicationPage {
            id: albumDetailPage
            anchors.fill: parent
            title: labelSingleAlbum
            onSearch:  {
                albumModel.search = needle;
            }

            menuContent: Column {
                id: menucolumn
                width: childrenRect.width

                property int textMargin: 16

                Text {
                    id: albumName
                    text: labelSingleAlbum
                    font.bold: true
                    font.pixelSize: theme_fontPixelSizeLarge
                    width: paintedWidth + 2 * textMargin
                    height: paintedHeight + 2 * textMargin
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: theme_contextMenuFontColor
                }

                Text {
                    id: albumCount
                    text: albumModel.count == 1 ? label1Photo : labelNPhotos.arg(albumModel.count)
                    font.pixelSize: theme_fontPixelSizeLarge
                    width: paintedWidth + 2 * textMargin
                    height: paintedHeight + 2 * textMargin
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: theme_contextMenuFontColor
                }

                Item {
                    width: button.width + 2 * textMargin
                    height: button.height + 2 * textMargin - 8

                    visible: !albumIsVirtual;

                    BlueButton {
                        id: button
                        anchors.centerIn: parent
                        text: labelDeleteAlbum
                        onClicked: {
                            albumDetailPage.closeMenu()
                            confirmer.model = allAlbumsModel
                            confirmer.previousPage = true
                            confirmer.text = labelDeleteAlbumText
                            confirmer.items = [ albumId ]
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

                property bool previousPage: false

                onConfirmed: {
                    if (previousPage) {
                        scene.previousApplicationPage()
                    }
                }
            }

            PhotosView {
                id: albumDetailsView
                parent: albumDetailPage.content
                anchors.fill: parent
                anchors.bottom: parent.bottom
                footerHeight: albumDetailsToolbar.height
                model: albumModel
                cellBackgroundColor: "black"
                noContentText: labelNoPhotosInAlbumText
                noContentButtonText: labelNoContentViewPhotosButtonText
                onOpenPhoto: {
                    // opening a photo from album detail view
                    photoDetailModel = albumModel;
                    detailViewIndex = currentIndex;
                    labelSinglePhoto = item.mtitle
                    model.setViewed(item.elementid);
                    showFullscreen = fullscreen
                    showSlideshow = startSlideshow
                    albumDetailPage.addApplicationPage(photoDetailComponent)
                }
                onPressAndHold : {
                    var map = payload.mapToItem(scene, x, y);
                    albumDetailContextMenu.model = [labelOpen, labelPlay,
                                                    payload.mfavorite ? labelUnfavorite : labelFavorite,
                                                    labelShare, labelAddToAlbum,
                                                    // labelMultiSelMode,
                                                    labelRemoveFromAlbum, labelSetAsBackground, labelDelete]
                    albumDetailContextMenu.payload = payload;
                    albumDetailContextMenu.menuX = map.x;
                    albumDetailContextMenu.menuY = map.y;
                    albumDetailContextMenu.visible = true;
                }
                onNoContentAction: {
                    scene.applicationPage = allPhotosComponent;
                }
            }

            Labs.ContextMenu {
                id: albumDetailContextMenu
                onClose: contextLoader.sourceComponent = undefined
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
                        shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeImage
                        shareObj.showContextTypes(mouseX, mouseY)
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

                }
            }

            PhotoToolbar {
                id: albumDetailsToolbar
                visible: albumDetailsView.noContentVisible
                parent: albumDetailPage.content
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
                    albumDetailPage.addApplicationPage(photoDetailComponent)
                }
            }

            Component.onCompleted: {
                albumModel.album = labelSingleAlbum;
                scene.fullscreen = false;
                scene.showsearch =true;
            }
        }
    }

    Component {
        id: photoDetailComponent

        Labs.ApplicationPage {
            id: photoDetailPage
            anchors.fill: parent
            title: labelSinglePhoto
            fullContent: true

            resources: [
                Labs.FuzzyDateTime {
                    id: fuzzy
                }
            ]

            menuContent: Item {
                property int textMargin: 16
                width: 300 + 2 * textMargin
                height: childrenRect.height + 2 * textMargin

                TextEntry {
                    id: entry
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: textMargin

                    text: labelSinglePhoto
                }

                BlueButton {
                    id: renameButton
                    anchors.top: entry.bottom
                    anchors.right: entry.right
                    anchors.topMargin: textMargin

                    text: labelRenamePhoto
                    onClicked: {
                        photoDetailPage.closeMenu()
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
                    anchors.topMargin: textMargin

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
                    anchors.topMargin: textMargin

                    text: currentPhotoCamera
                    visible: (text == "")? 0 : 1
                    height: (text == "")? 0 : creation.height
                    font.bold: true
                    font.pixelSize: theme_fontPixelSizeLarge
                    verticalAlignment: Text.Top
                    color: theme_contextMenuFontColor
                }

                BlueButton {
                    id: button
                    anchors.top: (camera.height > 0)? camera.bottom : creation.bottom
                    anchors.topMargin: textMargin
                    anchors.left: entry.left
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: labelDeletePhoto
                    onClicked: {
                        photoDetailPage.closeMenu()
                        confirmer.text = labelDeletePhotoText
                        confirmer.items = [ currentPhotoItemId ]
                        confirmer.show()
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
                    scene.previousApplicationPage()
                }
            }

            PhotoDetailsView {
                id: photodtview
                parent: photoDetailPage.content
                anchors.fill: parent
                model: photoDetailModel
                window: scene
                appPage: photoDetailPage
                currentIndex: detailViewIndex

                startInFullscreen: showFullscreen
                startInSlideshow: showSlideshow

                onPressAndHoldOnPhoto: {
                    var map = mapToItem(scene, mouse.x , mouse.y)
                    contextInstance.model = [photodtview.viewMode ? labelLeaveFullScreen : labelFullScreen,
                                             labelPlay, labelShare,
                                             instance.pfavorite ? labelUnfavorite : labelFavorite,
                                             labelAddToAlbum, labelSetAsBackground, labelDelete];
                    contextInstance.payload = instance;
                    contextInstance.menuX = map.x;
                    contextInstance.menuY = map.y;
                    contextInstance.visible = true;

                }
                onCurrentIndexChanged: {
                    labelSinglePhoto = currentItem.ptitle
                    currentPhotoCreationTime = currentItem.pcreation
                    currentPhotoCamera = currentItem.pcamera
                    currentPhotoItemId = currentItem.pitemid
                    currentPhotoURI = currentItem.puri
                }

                onEnterSingleSelectionMode: {
                }
                Component.onCompleted: {
                    showPhotoAtIndex(detailViewIndex);
                    scene.showsearch = false;
                }
            }

            Labs.ContextMenu {
                id: contextInstance
                // onClose: contextLoader.sourceComponent = undefined


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
                        shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeImage
                        shareObj.showContextTypes(mouseX, mouseY)
                    }

                    else if (model[index] == labelFavorite || model[index] == labelUnfavorite) {
                        // Mark as a favorite
                        photodtview.toolbar.isFavorite = !payload.pfavorite;
                        photodtview.model.setFavorite(payload.pitemid, !payload.pfavorite);
                    }
                    else if (model[index] == labelAddToAlbum) {
                        // Add to album
                        //photodtview.singleSelectionMode = true;
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
                }
            }
        }
    }
}
