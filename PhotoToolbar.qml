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

    // Content Modes:
    // 0 - all photos
    // 1 - album details
    // 2 - timeline
    // 3 - all albums
    // 4 - single photo
    property int contentMode: 0

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
    signal selectMultiple()
    signal addToAlbum()
    signal createAlbum()
    signal showInfo()
    signal showFilter()
    signal showSort()
    //signal share()
    signal setAsBg()
    signal launchCamera()

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

    Rectangle {
        anchors.fill: parent
        color: theme_mediaGridTitleBackgroundColor
        opacity: theme_mediaGridTitleBackgroundAlpha
    }


    IconButton {
        id: rotateButton
        visible: mode == 0 && contentMode == 4 ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        icon: "image://theme/media/icn_rotate_cw_up"
        iconDown: "image://theme/media/icn_rotate_cw_dn"
        hasBackground: false
        onClicked: container.rotateRight()
    }

    IconButton {
        id: cameraButton
        visible: mode == 1 ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        icon: "image://meegotheme/icons/toolbar/camera-photo"
        iconDown: "image://meegotheme/icons/toolbar/camera-photo-active"
        hasBackground: false
        onClicked: container.launchCamera()
    }

    IconButton {
        id: multiSelectButton
        visible: mode == 1 && contentMode == 0 ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: cameraButton.right
        anchors.leftMargin: 10
        icon: "image://meegotheme/icons/toolbar/document-attach"
        iconDown: "image://meegotheme/icons/toolbar/document-attach-active"
        hasBackground: false
        onClicked: container.selectMultiple()
    }

    IconButton {
        id: newAlbumButton
        visible: mode == 1 && contentMode == 3 ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: cameraButton.right
        anchors.leftMargin: 10
        icon: "image://meegotheme/icons/toolbar/view-change"
        iconDown: "image://meegotheme/icons/toolbar/view-change-active"
        hasBackground: false
        onClicked: container.createAlbum()
    }

    IconButton {
        id: shareSingleSelectButton
        visible: mode != 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: {
            switch(contentMode) {
                case 0: return multiSelectButton.right
                case 1: return cameraButton.right
                case 2: return cameraButton.right
                case 3: return newAlbumButton.right
                case 4: return rotateButton.right
                default: return cameraButton.right
            }
        }
        anchors.leftMargin: 10
        icon: "image://themedimage/images/media/icn_share_up"
        iconDown: "image://themedimage/images/media/icn_share_dn"
        hasBackground: false
        onClicked: {
            var map = mapToItem(scene, width / 2, 0);
            shareObj.showContextTypes(map.x, map.y)
        }
    }

    Row {
        id: allPhotosRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        visible: contentMode == 0 || contentMode == 1 || contentMode == 4

        IconButton {
            visible: mode == 0 && contentMode == 4 ? true : false
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/images/media/icn_back_up"
            iconDown: "image://themedimage/images/media/icn_back_dn"
            hasBackground: false
            onClicked: container.prev()
        }
        IconButton {
            id: playButton
            visible: mode != 2 && (contentMode == 0 || contentMode == 1 || contentMode == 4) ? true : false
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/images/icn_play_up"
            iconDown: "image://themedimage/images/icn_play_dn"
            hasBackground: false
            onClicked: container.play()
        }
        IconButton {
            visible: mode == 0 && contentMode == 4 ? true : false
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/images/media/icn_forward_up"
            iconDown: "image://themedimage/images/media/icn_forward_dn"
            hasBackground: false
            onClicked: container.next()
        }
    }

    IconButton {
        id: filterButton
        visible: mode == 1 && ( contentMode == 0 || contentMode == 3) ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon: "image://meegotheme/icons/toolbar/view-actions"
        iconDown: "image://meegotheme/icons/toolbar/view-actions-active"
        hasBackground: false
        onClicked: container.showFilter()
    }

    IconButton {
        id: sortByButton
        visible: mode == 1 && contentMode == 2 ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon: "image://meegotheme/icons/toolbar/dev-exit"
        iconDown: "image://meegotheme/icons/toolbar/dev-exit-active"
        hasBackground: false
        onClicked: container.showSort();
    }

    IconButton {
        id: favouriteButton
        visible: mode == 0 && contentMode == 4 ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        icon: container.isFavorite ? "image://theme/media/icn_favourite_active" : "image://theme/media/icn_favourite_up"
        iconDown: "image://theme/media/icn_favourite_dn"
        hasBackground: false
        onClicked: {
            container.isFavorite = !container.isFavorite;
            container.favorite();
        }
    }

    IconButton {
        id: infoButton
        visible: contentMode != 0 && contentMode != 3 ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: mode == 0? favouriteButton.left : (contentMode == 3? filterButton.left : (contentMode == 1? parent.right : sortByButton.left))
        anchors.rightMargin: 10
        icon: "image://meegotheme/icons/toolbar/page-favorite"
        iconDown: "image://meegotheme/icons/toolbar/page-favorite-active"
        hasBackground: false
        onClicked: container.showInfo()
    }

    IconButton {
        id: setAsBgButton
        visible: mode != 2 && (contentMode == 0 || contentMode == 4)? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: contentMode == 4? infoButton.left : filterButton.left
        anchors.rightMargin: 10
        icon: "image://meegotheme/icons/toolbar/dev-home"
        iconDown: "image://meegotheme/icons/toolbar/dev-home-active"
        hasBackground: false
        onClicked: container.setAsBg()
    }

    Row {
        id: mode2Buttons
        anchors.left: parent.left
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: (width - 400)/3
        visible: mode == 2
        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/images/media/icn_trash_up"
            iconDown: "image://themedimage/images/media/icn_trash_dn"
            hasBackground: false
            onClicked: container.deleteSelected()
        }
        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/images/media/icn_addtoalbum_up"
            iconDown: "image://themedimage/images/media/icn_addtoalbum_dn"
            hasBackground: false
            onClicked: container.addToAlbum()
        }
        IconButton {
            id: shareButton
            anchors.verticalCenter: parent.verticalCenter
            icon: "image://themedimage/images/media/icn_share_up"
            iconDown: "image://themedimage/images/media/icn_share_dn"
            hasBackground: false
            onClicked: {
                var map = mapToItem(topItem.topItem, width / 2, 0);
                shareObj.showContextTypes(map.x, map.y)
            }
        }
        IconButton {
            icon: "image://themedimage/images/media/icn_cancel_ms_up"
            iconDown: "image://themedimage/images/media/icn_cancel_ms_dn"
            hasBackground: false
            onClicked: container.cancel()
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

