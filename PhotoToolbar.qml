/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Sharing 0.1
import MeeGo.Sharing.UI 0.1
import Qt.labs.gestures 2.0

Item {
    id: container
    height: playButton.height

    // View Modes:
    // 0 - single photo view toolbar
    // 1 - grid view toolbar
    // 2 - grid view toolbar with cancel multiple select
    property int mode: 2

    property bool isFavorite: true
    property alias sharing: shareObj

    signal play()
    signal prev()
    signal next()
    signal favorite()
    signal rotateLeft()
    signal rotateRight()
    signal cancel()
    signal deleteSelected()
    signal addToAlbum()

    ShareObj {
        id: shareObj
    }

    // block all gestures from falling through
    GestureArea {
        anchors.fill: parent

        Tap {}
        TapAndHold {}
        Pan {}
        Swipe {}
        Pinch {}
    }

    BorderImage {
        anchors.fill: parent
        source: "image://themedimage/images/media/nextbox_landscape"
        border.top: 10
        border.bottom:10
        border.left: 10
        border.right: 10
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        IconButton {
            opacity: mode == 0 ? 1.0 : 0.0
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/icons/actionbar/media-backward"
            iconDown: "image://themedimage/icons/actionbar/media-backward-active"
            hasBackground: false
            onClicked: container.prev()
        }
        IconButton {
            id: playButton
            opacity: mode == 0 || mode == 1 ? 1.0 : 0.0
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/icons/actionbar/media-play"
            iconDown: "image://themedimage/icons/actionbar/media-play-active"
            hasBackground: false
            onClicked: container.play()
        }
        IconButton {
            opacity: mode == 0 ? 1.0 : 0.0
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/icons/actionbar/media-forward"
            iconDown: "image://themedimage/icons/actionbar/media-forward-active"
            hasBackground: false
            onClicked: container.next()
        }
    }
    Row {
        id: mode2Buttons
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: (width - 200)/3
        visible: mode == 2
        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/icons/actionbar/edit-delete"
            iconDown: "image://themedimage/icons/actionbar/edit-delete-active"
            hasBackground: false
            onClicked: container.deleteSelected()
        }
        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/icons/actionbar/media-addtoalbum"
            iconDown: "image://themedimage/icons/actionbar/media-addtoalbum-active"
            hasBackground: false
            onClicked: container.addToAlbum()
        }
        IconButton {
            id: shareButton
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/icons/actionbar/media-share"
            iconDown: "image://themedimage/icons/actionbar/media-share-active"
            hasBackground: false
            onClicked: {
                var map = mapToItem(topItem.topItem, width / 2, 0);
                shareObj.showContextTypes(map.x, map.y)
            }
        }
        IconButton {
            icon: "image://themedimage/icons/actionbar/media_multiselectcancel"
            iconDown: "image://themedimage/icons/actionbar/media_multiselectcancel-active"
            hasBackground: false
            onClicked: container.cancel()
        }
    }

    IconButton {
        opacity: mode == 0 ? 1.0 : 0.0
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        icon: "image://themedimage/icons/actionbar/media-repeat"
        iconDown: "image://themedimage/icons/actionbar/media-repeat-active"
        hasBackground: false
        onClicked: container.rotateRight()
    }
    IconButton {
        opacity: mode == 0 ? 1.0 : 0.0
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon: container.isFavorite ? "image://themedimage/icons/actionbar/favorite-active" : "image://themedimage/icons/actionbar/favorite"
        iconDown: "image://themedimage/icons/actionbar/favorite-selected"
        hasBackground: false
        onClicked: {
            container.isFavorite = !container.isFavorite;
            container.favorite();
        }
    }

    states: [
        State {
            name: "multisel"
            when: mode == 2
        },
        State {
            name: "normal"
            when: mode != 2
        }
    ]

    transitions: [
        Transition {
            from: "normal"
            to: "multisel"
            ScriptAction {
                script: sharing.clearItems();
            }
        }
    ]
}

