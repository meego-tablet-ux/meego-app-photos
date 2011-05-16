/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Media 0.1

Item {
    id: container

    property alias cellWidth: view.cellWidth
    property alias cellHeight: view.cellHeight
    property color cellBackgroundColor: selectionMode ? "#5f5f5f" : "black"
    property color cellTextColor: "white"

    property bool selectionMode: false

    property bool modelConnectionReady: false

    property bool selectAll: false
    property variant selected: []
    property variant thumburis: []

    property alias model: view.model
    property alias currentItem: view.currentItem
    property alias currentIndex: view.currentIndex
    property alias noContentText: noContent.text
    property alias noContentButtonText: noContent.buttonText
    property alias noContentVisible: view.visible

    property alias footerHeight: view.footerHeight

    property string labelOpen: qsTr("Open")
    property string labelPlay: qsTr("Play slideshow")
    property string labelShare: qsTr("Share")
    property string labelFavorite: qsTr("Favorite");
    property string labelUnfavorite: qsTr("Unfavorite");
    property string labelAddToAlbum: qsTr("Add to album");
    property string labelDelete: qsTr("Delete")
    property string labelMultiSelMode: qsTr("Select multiple photos")

    signal toggleSelectedPhoto(string uri, bool selected)
    signal noContentAction()

    onSelectionModeChanged: {
        selected = [];
        thumburis = [];
        model.clearSelected();
    }

    signal openPhoto(variant item, bool fullscreen, bool startSlideshow)
    signal pressAndHold(int x, int y, variant payload)

    NoContent {
        id: noContent

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        visible: !view.visible

        onClicked: {
            container.noContentAction();
        }
    }

    MediaGridView {
        id: view
        type: phototype
        selectionMode: container.selectionMode
        defaultThumbnail: "image://themedimage/images/media/photo_thumb_default"
        showHeader: true

        anchors.fill: parent
        anchors.topMargin: 5
        anchors.leftMargin: 0
        anchors.rightMargin: 0

        visible: count != 0 || !modelConnectionReady

        spacing: 3
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
            if (container.selectionMode) {
                view.currentIndex = payload.mindex;
                var itemSelected = !view.model.isSelected(payload.mitemid)
                view.model.setSelected(payload.mitemid, itemSelected);
                container.toggleSelectedPhoto(payload.muri, itemSelected)
                selected = view.model.getSelectedIDs();
                thumburis = view.model.getSelectedURIs();
            }
            else {
                view.currentIndex = payload.mindex;
                container.openPhoto(payload, false, false);
            }
        }

        onLongPressAndHold: {
            if (!container.selectionMode) {
                container.pressAndHold(mouseX, mouseY, payload);
            }
        }
    }
}

