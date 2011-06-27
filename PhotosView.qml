/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Media 0.1 as Media

Item {
    id: container

    property color cellBackgroundColor: selectionMode ? "#5f5f5f" : "black"
    property color cellTextColor: "white"

    property bool selectionMode: false
    property bool modelConnectionReady: false

    property bool selectAll: false
    property variant selected: []
    property variant thumburis: []
    property variant selectedIndexes: []

    property alias model: view.model
    property alias currentItem: view.currentItem
    property alias currentIndex: view.currentIndex
    property alias noContentText: noContent.text
    property alias noContentButtonText: noContent.buttonText
    property alias noContentVisible: view.visible

    property alias footerHeight: view.footerHeight

    //: This is a context menu command for opening photos
    property string labelOpen: qsTr("Open")
    //: This is a context menu command for showing a slide show of photos
    property string labelPlay: qsTr("Play slideshow")
    //: This is a context menu command for sharing photos over services
    property string labelShare: qsTr("Share")
    //: This is a context menu command for marking photos as favorite
    property string labelFavorite: qsTr("Favorite", "Verb");
    //: This is a context menu command for removing favorite mark from photos
    property string labelUnfavorite: qsTr("Unfavorite");
    //: This is a context menu command for adding photos to albums
    property string labelAddToAlbum: qsTr("Add to album");
    //: This is a context menu command for deleting photos
    property string labelDelete: qsTr("Delete")
    //: This is a context menu command for starting the multiselect mode
    property string labelMultiSelMode: qsTr("Select multiple photos")

    signal toggleSelectedPhoto(string uri, bool selected)
    signal noContentAction()

    onSelectionModeChanged: {
        selected = [];
        thumburis = [];
        selectedIndexes = []
        model.clearSelected();
    }

    signal openPhoto(variant mediaItem, bool fullscreen, bool startSlideshow)
    signal pressAndHold(int x, int y, variant payload)

    Rectangle {
        id: globalbgsolid
        anchors.fill: parent
        color: "black"
    }

    BorderImage {
        id: panel
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.bottomMargin: 5
        source: "image://themedimage/widgets/apps/media/content-background"
        border.left:   8
        border.top:    8
        border.bottom: 8
        border.right:  8
    }

    NoContent {
        id: noContent

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        visible: !view.visible

        onClicked: {
            container.noContentAction();
        }
    }

    Media.MediaGridView {
        id: view

        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: (parent.width - Math.floor(parent.width / cellWidth)*cellWidth) / 2
        anchors.rightMargin: anchors.leftMargin

        visible: count != 0 || !modelConnectionReady

        type: phototype
        selectionMode: container.selectionMode
        defaultThumbnail: "image://themedimage/images/media/photo_thumb_default"

        borderImageSource: "image://themedimage/widgets/apps/media/photo-border"
        borderImageTop: 3
        borderImageBottom: borderImageTop
        borderImageLeft: borderImageTop
        borderImageRight: borderImageTop

        onClicked: {
            if (container.selectionMode) {
                view.currentIndex = payload.mindex;
                var itemSelected = !view.model.isSelected(payload.mitemid)
                view.model.setSelected(payload.mitemid, itemSelected);
                container.toggleSelectedPhoto(payload.muri, itemSelected)
                selected = view.model.getSelectedIDs();
                thumburis = view.model.getSelectedURIs();
                var list = selectedIndexes
                list.push(payload.mindex)
                selectedIndexes = list
            }
            else {
                container.openPhoto(payload, true, false);
            }
        }

        onLongPressAndHold: {
            if (!container.selectionMode) {
                container.pressAndHold(mouseX, mouseY, payload);
            }
        }
    }
}

