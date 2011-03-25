/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Media 0.1
import MeeGo.Sharing 0.1

Window {
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

    property string labelDeletePhotoText: qsTr("Are you sure you want to delete this photo?")
    property string labelDeletePhotosText: qsTr("Are you sure you want to delete the %1 selected photos?")
    property string labelDeleteAlbumText: qsTr("Are you sure you want to delete this album?")

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

    function deleteItems(page, model, text, itemids, func) {
        // requires: func is either 'false' or a function to call after
        //             deleting the items
        //           itemids is an array - for a single item, place in [ brackets ]
        dialogLoader.sourceComponent = confirmDeleteDialog
        dialogLoader.item.confirmText = text
        dialogLoader.item.parent = page.content;

        var object = new Object()
        object.model = model
        object.items = itemids
        dialogLoader.item.object = object

        function deleteItemsSlot(object) {
            object.model.destroyItemsByID(object.items)
            if (func) {
                func()
            }
        }
        dialogLoader.item.confirm.connect(deleteItemsSlot)
    }

    function updateHeader(model, view) {
        view.showHeader = true
        if (model.filter == 0) {
            view.showHeader = false
            view.headerText = ""
        }
        else if (model.filter == 1) {
            view.headerText = labelFavorites
        }
        else if (model.filter == 2) {
            view.headerText = labelRecentlyViewed
        }
        else if (model.filter == 3) {
            view.headerText = labelRecentlyAdded
        }
    }

    ShareObj {
        id: shareObj
    }

    BackgroundModel {
        id: backgroundModel
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

    Loader {
        id: dialogLoader
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

    Component {
        id: allPhotosComponent
        ApplicationPage {
            id: allPhotosPage
            anchors.fill: parent
            title: labelAllPhotos
            onSearch: {
                allPhotosModel.search = needle;
            }

            menuContent: Column {
                width: childrenRect.width

                ActionMenu {
                    model: [ labelAll, labelRecentlyAdded, labelFavorites, labelRecentlyViewed ]

                    onTriggered: {
                        if (model[index] == labelAll) {
                            allPhotosModel.filter = 0
                        }
                        else if (model[index] == labelRecentlyAdded) {
                            allPhotosModel.filter = 3
                        }
                        else if (model[index] == labelFavorites) {
                            allPhotosModel.filter = 1
                        }
                        else if (model[index] == labelRecentlyViewed) {
                            allPhotosModel.filter = 2
                        }
                        else {
                            console.log("Unexpected index triggered from action menu")
                        }
                        updateHeader(allPhotosModel, allPhotosView);
                        allPhotosPage.closeMenu();
                    }
                }
            }

            PhotosView {
                id: allPhotosView
                parent: allPhotosPage.content
                anchors.fill: parent
                anchors.bottom: parent.bottom
                model: allPhotosModel
                Connections{
                    target:scene
                    onOrientationChanged: {
                        allPhotosView.contentX = 0;
                        allPhotosView.contentY = 0;
                    }
                }
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
            }

            ContextMenu {
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
                        allPhotosView.selected =  [payload.mitemid] ;
                        allPhotosView.thumburis =  [payload.mthumburi] ;
                        allPhotosView.currentIndex = payload.mindex;
                        photopicker.payload = [payload.mitemid];
                        photopicker.visible = true;
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
                        // Delete
                        deleteItems(allPhotosPage, allPhotosModel, labelDeletePhotoText,
                                    [ payload.mitemid ], false)
                    }

                }
            }

            PhotoToolbar {
                id: allPhotosToolbar
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
                   // if (allPhotosModel.getSelectedURIs().length > 0)
                        photopicker.payload = allPhotosView.selected;
                        photopicker.visible = true;
                }
                onDeleteSelected: {
                    if (allPhotosView.selected.length == 0) {
                        return
                    }

                    var text = labelDeletePhotoText
                    if (allPhotosView.selected.length != 1) {
                        text = labelDeletePhotosText.arg(allPhotosView.selected.length)
                    }
                    deleteItems(allPhotosPage, allPhotosModel, text,
                                allPhotosView.selected, allPhotosModel.clearSelected)
                }

                onCancel: {
                    allPhotosView.selectionMode = false;
                }
            }

            Component.onCompleted: {
                scene.fullscreen = false;
                scene.showsearch = true;
                updateHeader(allPhotosModel, allPhotosView)
            }
        }
    }

    Component {
        id: confirmDeleteDialog
        ModalDialog {
            property variant object
            property string confirmText

            signal confirm(variant object)

            leftButtonText: qsTr("Delete")
            rightButtonText: qsTr("Cancel")
            dialogTitle: labelConfirmDelete
            contentLoader.sourceComponent: DialogText { text: confirmText; }

            onDialogClicked: {
                if (button == 1)
                    confirm(object)
                dialogLoader.sourceComponent = undefined
            }
        }
    }

    Component {
        id: createAlbumDialog
        ModalDialog {
            leftButtonText: qsTr("Create")
            rightButtonText: qsTr("Cancel")
            dialogTitle: labelCreateNewAlbum

            property string albumTitle: ""

            contentLoader.sourceComponent: Item {
                anchors.fill: parent

                BorderImage {
                    id: entryBorder
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/email/frm_textfield_l"
                    border.left: 10; border.top: 10
                    border.right: 10; border.bottom: 10
                    width: parent.width

                    TextInput {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        onTextChanged: {
                            albumTitle = text
                        }
                    }
                }
            }
            onDialogClicked: {
                if (button == 1) {
                    albumEditorModel.album = albumTitle
                    albumEditorModel.saveAlbum()
                }
                contextLoader.sourceComponent = undefined
            }
        }
    }

    Component {
        id: allAlbumsComponent
        ApplicationPage {
            id: allAlbumsPage
            anchors.fill: parent
            title: labelAlbums

            onSearch: {
                allAlbumsModel.search = needle;
            }

            menuContent: Column {
                id: menucolumn
                width: childrenRect.width

                property int textMargin: 16

                Item {
                    width: button.width + 2 * textMargin
                    height: button.height + 2 * textMargin - 8

                    BlueButton {
                        id: button
                        anchors.centerIn: parent
                        text: labelNewAlbum
                        onClicked: {
                            contextLoader.sourceComponent = createAlbumDialog
                            contextLoader.item.parent = allAlbumsPage.content;
                            allAlbumsPage.closeMenu();
                        }
                    }
                }

                Image {
                    id: separator
                    source: "image://theme/menu_item_separator"
                    width: menucolumn.width
                }

                Repeater {
                    id: repeater
                    // FIXME: removed favorites from this list since there is no UI for favorite albums
                    // FIXME: removed recently viewed from this list since it's not clear when
                    //        to tag an album as "viewed" - consult UX team
                    model: [ labelAll, labelRecentlyAdded ]
                    delegate: Item {
                        width: Math.max(parent.width, text.width + 2 * textMargin)
                        height: text.paintedHeight + 2 * textMargin

                        Text {
                            id: text
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: textMargin
                            text: modelData;
                            color: theme_contextMenuFontColor
                            font.pixelSize: theme_contextMenuFontPixelSize
                        }

                        Image {
                            anchors.bottom: parent.bottom
                            source: "image://theme/menu_item_separator"
                            width: parent.width
                            visible: index < repeater.count - 1
                        }

                        MouseArea {
                            anchors.fill: parent;
                            onClicked: {
                                if (repeater.model[index] == labelAll) {
                                    allAlbumsModel.filter = 0
                                }
                                else if (repeater.model[index] == labelRecentlyAdded) {
                                    allAlbumsModel.filter = 3
                                }
                                else if (repeater.model[index] == labelRecentlyViewed) {
                                    allAlbumsModel.filter = 2
                                }
                                updateHeader(allAlbumsModel, albumsView)
                                allAlbumsPage.closeMenu();
                            }
                        }
                    }
                }
            }
            AlbumsView {
                id: albumsView
                parent:allAlbumsPage.content
                anchors.fill: parent

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
            }
            Component.onCompleted: {
                scene.fullscreen = false;
                scene.showsearch = true;
                updateHeader(allAlbumsModel, albumsView)
            }
        }
    }

    Component {
        id: albumDetailComponent
        ApplicationPage {
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
                            deleteItems(albumDetailPage, allAlbumsModel,
                                        labelDeleteAlbumText, [ albumId ],
                                        scene.previousApplicationPage)
                        }
                    }
                }
            }

            PhotosView {
                id: albumDetailsView
                parent: albumDetailPage.content
                anchors.fill: parent
                anchors.bottom: parent.bottom
                model: albumModel
                cellBackgroundColor: "black"
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
            }

            ContextMenu {
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
                        photopicker.visible = true;
                    }
                    else if (model[index] == labelRemoveFromAlbum)
                    {
                        albumModel.removeItems([payload.mitemid])
                    }
                    else if (model[index] == labelDelete)
                    {
                        // Delete
                        deleteItems(albumDetailPage, albumModel, labelDeletePhotoText,
                                    [ payload.mitemid ], false)
                    }
                    else if(model[index] == labelSetAsBackground) {
                        backgroundModel.activeWallpaper = payload.muri
                    }

                }
            }

            PhotoToolbar {
                id: albumDetailsToolbar
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

        ApplicationPage {
            id: photoDetailPage
            anchors.fill: parent
            title: labelSinglePhoto
            fullContent: true

            resources: [
                FuzzyDateTime {
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
                    anchors.margins: textMargin

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
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: renameButton.bottom
                    anchors.margins: textMargin

                    text: fuzzy.getFuzzy(currentPhotoCreationTime)
                    font.pixelSize: theme_contextMenuFontPixelSize
                    verticalAlignment: Text.AlignVCenter
                    color: theme_contextMenuFontColor
                }

                Text {
                    id: camera
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: creation.bottom
                    anchors.margins: textMargin

                    text: currentPhotoCamera
                    font.bold: true
                    font.pixelSize: theme_fontPixelSizeLarge
                    verticalAlignment: Text.Top
                    color: theme_contextMenuFontColor
                }

                BlueButton {
                    id: button
                    anchors.top: camera.bottom

                    text: labelDeletePhoto
                    onClicked: {
                        photoDetailPage.closeMenu()
                        deleteItems(photoDetailPage, photoDetailModel, labelDeletePhotoText,
                                    [ currentPhotoItemId ], scene.previousApplicationPage)
                    }
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
            ContextMenu {
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
                        photopicker.visible = true;
                    }
                    else if (model[index] == labelSetAsBackground) {
                        backgroundModel.activeWallpaper = payload.puri;
                    }
                    else if (model[index] == labelDelete) {
                        // Delete
                        deleteItems(photoDetailPage, photoDetailModel, labelDeletePhotoText,
                                    [ payload.pitemid ], scene.previousApplicationPage)
                   }
                }
            }
        }
    }
}
