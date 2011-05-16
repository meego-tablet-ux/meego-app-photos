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

Item {
    id: container
    property int labelHeight: 20
    property color cellBackgroundColor: "black"
    property color cellTextColor: theme_fontColorHighlight
    property int cellTextPointSize: theme_fontPixelSizeNormal

    property alias model: view.model
    property alias currentItem: view.currentItem
    property alias view: view
    property alias currentIndex: view.currentIndex
    property alias noContentText: noContent.text
    property alias noContentButtonText: noContent.buttonText
    property alias noContentVisible: view.visible

    property string labelOpen: qsTr("Open")
    property string labelPlay: qsTr("Play slideshow")
    property string labelShare: qsTr("Share")
    property string labelDelete: qsTr("Delete")

    signal openAlbum(variant elementid, string title, bool isvirtual, bool fullscreen)
    signal playSlideshow(variant elementid, string title)
    signal shareAlbum(variant albumid, string title, int mouseX, int mouseY)
    signal noContentAction()

    function indexAt(x,y) {
        return view.indexAt(x,y);
    }

    ConfirmDelete {
        id: confirmer
        model: container.model

        onConfirmed: {
            allPhotosModel.clearSelected()
        }
    }

    ContextMenu {
        id: albumsContextMenu
        property alias payload: albumsActionMenu.payload
        property alias model: albumsActionMenu.model
        content: ActionMenu {
            id: albumsActionMenu
            property variant payload: undefined
            onTriggered: {
                var target = container.anchors
                if (model[index] == labelOpen) {
                    // Open the photo
                    openAlbum(payload.mitemid, payload.mtitle, payload.misvirtual, false)
                }
                else if (model[index] == labelPlay) {
                    // TODO: this is currently disabled below
                    // Play slideshow
                    playSlideshow(payload.mitemid, payload.mtitle)
                }
                else if (model[index] == labelShare) {
                    // Share
                    shareAlbum(payload.mitemid, payload.mtitle,
                               contextInstance.menuX, contextInstance.menuY)
                }
                else if (model[index] == labelDelete) {
                    // Delete
                    confirmer.text = labelDeleteAlbumText
                    confirmer.items = [ payload.mitemid ]
                    confirmer.show()
                }
                albumsContextMenu.hide()
            }
        }
    }

    NoContent {
        id: noContent

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        visible: !view.visible
    }

    MediaGridView {
        id: view
        type: photoalbumtype
        defaultThumbnail: "image://theme/media/photo_thumb_default"
        showHeader: true

        anchors.fill: parent
        anchors.topMargin: 5
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        visible: count != 0

        spacing: 2
        cellWidth: {
            // for now, prefer portrait - later pull from platform setting
            var preferLandscape = false
            var preferPortrait = true

            // find cell size for at least six wide in landscape, three in portrait
            var sizeL = Math.floor(Math.max(scene.width, scene.height) / 6)
            var sizeP = Math.floor(Math.min(scene.width, scene.height) / 4)

            // work around bug in MediaGridView
            sizeP -= 1

            if (preferPortrait)
                return sizeP
            else if (preferLandscape)
                return sizeL
            else return Math.min(sizeP, sizeL)
        }
        cellHeight: cellWidth

        function setMargins() {
            var columns = Math.floor(parent.width / cellWidth)
            var gridWidth = columns * cellWidth
            var remain = parent.width - gridWidth
            // workaound MediaGridView miscalculation with +1 below
            anchors.leftMargin = Math.floor(remain / 2) + 1
        }
        Component.onCompleted: setMargins()

        property int parentWidth: -1

        Connections {
            target: parent

            onWidthChanged: {
                // adjust margin during orientation change
                if (width < 0) {
                    view.parentWidth = -1
                }
                else if (width != view.parentWidth) {
                    view.parentWidth = width
                    view.setMargins()
                }
            }
        }

        onClicked: {
            view.currentIndex = payload.mindex;
            openAlbum(payload.mitemid, payload.mtitle, payload.misvirtual, false);
        }

        onLongPressAndHold: {
            var map = payload.mapToItem(scene, mouseX, mouseY);

            // TODO: implement this play slideshow feature here, a little tricky
            //   Nick wants it to slide just the one page in, but later you
            //     go _back_ to the album detail view
            var options = [labelOpen, labelShare]   // labelPlay removed for now

            // only add delete option if the album is not virtual
            if (!payload.misvirtual) {
                options.push(labelDelete)
            }

            albumsContextMenu.model = options
            albumsContextMenu.payload = payload;
            albumsContextMenu.setPosition(map.x, map.y)
            albumsContextMenu.show()
        }
    }
}
