/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

Item {
    id: container

    property variant window
    property variant appPage
    property variant model
    property variant elementid

    // view modes
    // 0 - photo viewer with side bar and tool bar
    // 1 - photo viewer only
    property int viewMode: 0

    property bool startInFullscreen: false
    property bool startInSlideshow: false

    property alias currentIndex: photoViewer.currentIndex
    property alias currentItem: photoViewer.currentItem
    property alias toolbar: toolbar

    signal currentIndexChanged(int index)
    signal pressAndHoldOnPhoto(variant mouse, variant instance)
    signal enterSingleSelectionMode()

    function showPhotoAtIndex(index) {
        photoViewer.showPhotoAtIndex(index);
    }

    function activate() {
        viewMode = 0;
    }

    function startSlideshow() {
        viewMode = 1
        photoViewer.startSlideshow()
    }

    function toggleFavorite() {
        model.setFavorite(elementid, toolbar.isFavorite);
    }

    Timer {
        id: delayedComplete
        interval: 50
        repeat: false
        onTriggered: {
            if (startInFullscreen)
                viewMode = 1
            if (startInSlideshow)
                startSlideshow()
        }
    }

    Component.onCompleted: {
        delayedComplete.start()
    }

    PhotoViewer {
        id: photoViewer
        anchors.fill: parent
        model: container.model
        window: container.window
        appPage: container.appPage

        onClickedOnPhoto: {
            viewMode = viewMode ? 0 : 1
        }

        onPressAndHoldOnPhoto: {
            container.pressAndHoldOnPhoto(mouse,instance);
        }

        onCurrentIndexChanged:{
            elementid = currentItem.pitemid;
            toolbar.isFavorite = currentItem.pfavorite;
         //   container.singleSelectionMode = false;
            container.currentIndexChanged(photoViewer.currentIndex);
        }

        onSlideshowStopped: {
            viewMode = 0
        }
    }

    PhotoToolbar {
        id: toolbar
        anchors.bottom: parent.bottom
        width: parent.width
     //   mode: container.singleSelectionMode ? 2:0
        isFavorite: false
        opacity:   1
        mode: 0
        onPrev: photoViewer.showPrevPhoto();
        onNext: photoViewer.showNextPhoto();
        onPlay: container.startSlideshow()
        onRotateRight: photoViewer.rotateRightward();
        onRotateLeft: photoViewer.rotateLeftward();
        onFavorite: container.toggleFavorite();
    }

    state:"origin"
    states: [
        State {
            name: "origin"
            when: viewMode == 0
            PropertyChanges {
                target: window
                //topicsOffset: 0
                showtoolbar: true
                fullscreen: false
            }
            PropertyChanges {
                target: photoViewer
                fullscreen: false
            }
            PropertyChanges {
                target: toolbar
                anchors.bottomMargin: 0
                opacity: 1
            }
        },
        State {
            name: "fullscreenMode"
            when: viewMode == 1
            PropertyChanges {
                target: window
                // topicsOffset: -topicsWidth
                showtoolbar: false
                fullscreen: true
            }
            PropertyChanges {
                target: photoViewer
                fullscreen: true
            }
            PropertyChanges {
                target: toolbar
                anchors.bottomMargin: -toolbar.height
                opacity: 0.5
            }
        }
    ]

    transitions: [
        Transition {
            reversible: true
            ParallelAnimation{
                PropertyAnimation {
                    target:toolbar
                    property: "anchors.bottomMargin"
                    duration: 250

                }

                PropertyAnimation {
                    target: toolbar
                    property: "opacity"
                    duration: 250
                }
            }
        }
    ]
}
