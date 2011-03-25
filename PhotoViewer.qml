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

Item {
    id: photoViewer
    anchors.centerIn: parent
    property variant window
    property variant appPage
    property alias model: photoListView.model
    property alias currentIndex: photoListView.currentIndex
    property alias currentItem: photoListView.currentItem
    property alias count: photoListView.count

    property bool fullscreen: false
    property variant slideshow

    signal slideshowStopped()

    function startSlideshow() {
        if (!slideshow)
            slideshow = slideshowComponent.createObject(photoViewer)
    }

    signal clickedOnPhoto()
    signal currentIndexChanged()
    signal pressAndHoldOnPhoto(variant mouse, variant instance)

    function showPhotoAtIndex(index) {
        if (index < photoListView.count) {
            photoThumbnailView.positionViewAtIndex(index,ListView.Center);
            photoListView.positionViewAtIndex(index,ListView.Center);
            photoListView.currentIndex = index;
        }
    }

    function showNextPhoto() {
        photoListView.incrementCurrentIndex();
    }

    function showPrevPhoto() {
        photoListView.decrementCurrentIndex();
    }

    function rotateRightward() {
        photoListView.currentItem.photoRotate = (photoListView.currentItem.photoRotate + 1)%4;
    }

    function rotateLeftward() {
        photoListView.currentItem.photoRotate = (photoListView.currentItem.photoRotate + 3) %4;
    }

    function determineUsrOrientation(originalOrientation, rotation)
    {
        var index = rotationCombination1.indexOf(originalOrientation);
        if (index != -1) {
            return rotationCombination1[(index + rotation) % rotationCombination1.length];
        } else {
            index = rotationCombination2.indexOf(originalOrientation);
            if (index != -1) {
                return rotationCombination2[(index + rotation) % rotationCombination2.length];
            }
        }
        // give a default value;
        return 1;
    }

    property variant rotationCombination1: [1, 6, 3, 8]
    property variant rotationCombination2: [2, 5, 4, 7]

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
    }
    ListView {
        id: photoListView
        cacheBuffer: photoViewer.width
        anchors.fill: parent
        clip: true
        snapMode:ListView.SnapOneItem
        orientation: ListView.Horizontal
        highlightFollowsCurrentItem: true
        spacing: 30
        focus: true
        pressDelay: 0
        highlightMoveDuration: 300
        property bool initialPhoto: true

        signal startingSlideshow()

        delegate: Flickable {
            id: dinstance
            width: photoViewer.width
            height: photoViewer.height
            property alias imageExtension: extension
            property variant centerPoint

            function updateImage() {
                fullImage.source = uri
            }

            onWidthChanged: {
                restorePhoto();
            }
            onHeightChanged: {
                restorePhoto();
            }

            contentWidth: {
                if (photoRotate == 0 || photoRotate == 2) {
                    image.width * image.scale > width ? image.width * image.scale : width
                } else {
                    image.height * image.scale > width ? image.height * image.scale : width
                }
            }

            contentHeight:{
                if (photoRotate == 0 || photoRotate == 2) {
                    image.height * image.scale > height ? image.height * image.scale : height
                } else {
                    image.width * image.scale > height ? image.width * image.scale : height
                }
            }

            clip: true
            property string ptitle: title
            property bool pfavorite: favorite
            property string pitemid: itemid
            property string pthumburi: thumburi
            property string pcreation: creationtime
            property string pcamera: camera
            property string puri: uri

            property int photoRotate:0

            // thumbnail image
            Image {
                id: image
                source: thumburi
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                width: dinstance.width
                height: dinstance.height
                transformOrigin: Item.Center
                visible: fullImage.opacity != 1
                asynchronous: true

                function zoomIn(mouse) {
                    image.sourceSize.width = image.sourceSize.width * 1.5;
                    image.width = image.width * 1.5;
                    image.height = image.height * 1.5;
                }
                transform: [
                    Rotation {
                        id: mirror
                        origin.x: image.width/2;
                        origin.y: image.height/2;
                        axis { x: 0; y: 0; z: 0 }
                    },
                    Rotation {
                        id: rotation
                        origin.x: image.width/2;
                        origin.y: image.height/2;
                        axis { x: 0; y: 0; z: 1 }
                    }
                ]
            }

            // full res image
            Image {
                id: fullImage
                anchors.centerIn: parent
                fillMode:Image.PreserveAspectFit
                sourceSize.width: scene.width
                width: dinstance.width
                height: dinstance.height
                transformOrigin: Item.Center
                opacity: 0
                property bool show: false
                property bool load: false
                asynchronous: true

                onStatusChanged: {
                    if (status == Image.Ready) {
                        show = true
                    }
                }

                states: [
                    State {
                        name: "showFull"
                        when: fullImage.show
                        PropertyChanges {
                            target: fullImage
                            opacity: 1
                        }
                    }
                ]

                transitions: [
                    Transition {
                        reversible: true
                        PropertyAnimation {
                            properties: "opacity"
                            duration: 500
                        }
                    }
                ]

                Component.onCompleted: {
                    if (index == currentIndex) {
                        if (photoListView.moving) {
                            load = true
                        }
                        else {
                            source = uri
                        }
                    }
                }

                function zoomIn(mouse) {
                    fullImage.sourceSize.width = fullImage.sourceSize.width * 1.5;
                    fullImage.width = fullImage.width * 1.5;
                    fullImage.height = fullImage.height * 1.5;
                }
                transform: [
                    Rotation {
                        id: mirror2
                        origin.x: fullImage.width/2;
                        origin.y: fullImage.height/2;
                        axis { x: 0; y: 0; z: 0 }
                    },
                    Rotation {
                        id: rotation2
                        origin.x: fullImage.width/2;
                        origin.y: fullImage.height/2;
                        axis { x: 0; y: 0; z: 1 }
                    }
                ]

                Connections {
                    target: photoListView
                    onMovementEnded: {
                        if (fullImage.load) {
                            fullImage.source = uri
                            fullImage.load = false
                        }
                    }

                    onStartingSlideshow: {
                        fullImage.source = uri
                    }

                    onCurrentIndexChanged: {
                        if (index == currentIndex) {
                            if (photoListView.moving) {
                                fullImage.load = true
                            }
                            else {
                                fullImage.source = uri
                            }
                        }
                    }
                }
            }

            ImageExtension {
                id: extension
                source: uri
                usrOrientation: determineUsrOrientation(orientation, photoRotate)
                onOrientationChanged:{
                    switch(orientation) {
                    case 1:{
                            mirror.angle = 0;
                            rotation.angle = 0;
                        }
                        break;
                    case 2:{
                            mirror.axis.x = 0;
                            mirror.axis.y = 1;
                            mirror.axis.z = 0;
                            mirror.angle = 180;

                            rotation.angle = 0;
                        }
                        break;
                    case 3:{
                            mirror.angle = 0;

                            rotation.angle = 180;
                        }
                        break;
                    case 4:{
                            mirror.angle = 180;
                            mirror.axis.x = 1;
                            mirror.axis.y = 0;
                            mirror.axis.z = 0;

                            rotation.angle = 0;
                        }
                        break;
                    case 5:{
                            mirror = 180;
                            mirror.axis.x = 0;
                            mirror.axis.y = 1;
                            mirror.axis.z = 0;

                            rotation.angle = 90;
                        }
                        break;
                    case 6: {
                            mirror.angle = 0;
                            rotation.angle = 90;
                        }
                        break;
                    case 7:{
                            mirror.angle = 180;

                            mirror.axis.x = 0;
                            mirror.axis.y = 1;
                            mirror.axis.z = 0;

                            rotation.angle = 270;
                        }
                        break;
                    case 8:{
                            mirror.angle = 0;
                            rotation.angle = 270;
                        }
                        break;
                    default:
                            break;
                    }
                }
            }

            Connections {
                target: photoListView
                onCurrentItemChanged: {
                   // image.width = dinstance.width;
                   // image.height = dinstance.height;
                   //  image.rotation = 0;
                   //  photoRotate = 0;
                    if (currentItem == dinstance)
                    {
                        photoViewer.model.setViewed(pitemid)
                    }
                }
            }

            states: [
                State {
                    name: "upright"
                    when: photoRotate == 0
                    PropertyChanges {
                        target: image
                        rotation: 0
                        width:dinstance.width
                        height:dinstance.height
                    }

                },
                State {
                    name: "rightward"
                    when: photoRotate == 1
                    PropertyChanges {
                        target: image
                        rotation: 90
                        width:dinstance.height
                        height:dinstance.width
                    }
                },
                State {
                    name: "upsidedown"
                    when: photoRotate == 2
                    PropertyChanges {
                        target: image
                        rotation: 180
                        width:dinstance.width
                        height:dinstance.height
                    }
                },
                State {
                    name: "leftward"
                    when: photoRotate == 3
                    PropertyChanges {
                        target: image
                        rotation: 270
                        width:dinstance.height
                        height:dinstance.width
                    }
                }
            ]

            transitions: [
                Transition {
                    reversible: true
                    ParallelAnimation {
                        PropertyAnimation {
                            properties:"width,height"
                            duration:300
                        }

                        RotationAnimation {
                            id:rotateAnimation
                            direction:RotationAnimation.Shortest
                            duration:300
                        }
                    }
                }
            ]
            function restorePhoto() {
                //   image.sourceSize.width = 1024;
                //   image.scale = 1;
                if (photoRotate == 0 || photoRotate == 2) {
                    image.width = dinstance.width;
                    image.height = dinstance.height;
                } else {
                    image.width = dinstance.height;
                    image.height = dinstance.width;
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                property bool inGesture: false

                onClicked: {
                    photoViewer.clickedOnPhoto();
                }
                onPressAndHold:
                {
                    if (!inGesture)
                        photoViewer.pressAndHoldOnPhoto(mouse, dinstance);
                }
            }

            GestureArea {
                anchors.fill: parent
                onPinchGesture: {
                    var cw = dinstance.contentWidth;
                    var ch = dinstance.contentHeight;
                    image.scale *= gesture.scaleFactor;
                    fullImage.scale *= gesture.scaleFactor;
                    dinstance.contentX =  (dinstance.centerPoint.x + dinstance.contentX )/ cw * dinstance.contentWidth - dinstance.centerPoint.x;
                    dinstance.contentY = (dinstance.centerPoint.y + dinstance.contentY)/ ch * dinstance.contentHeight - dinstance.centerPoint.y;

                }
                onGestureStarted: {
                    mouseArea.inGesture = true
                    dinstance.interactive = false;
                    photoListView.interactive = false;
                    dinstance.centerPoint = scene.mapToItem(dinstance, gesture.centerPoint.x, gesture.centerPoint.y);
                }
                onGestureEnded: {
                    mouseArea.inGesture = false
                    dinstance.interactive = true;
                    photoListView.interactive = true;
                }
            }

        }
        Component.onCompleted: {
            // start the timer the first time.
            hideThumbnailTimer.start();
        }

        property variant previousTimestamp
        property int flickCount: 0
        property bool movementCausedByFlick: false
        onMovementStarted: {
            currentItem.imageExtension.saveInfo();
        }

        onFlickStarted: {
            var t = (new Date()).getTime();
            if (t - previousTimestamp < 1000) {
                flickCount++;
                if (flickCount > 2)
                    photoThumbnailView.show = true;
            }
            else flickCount = 1

            previousTimestamp = t;
            movementCausedByFlick = true;
            if (photoThumbnailView.show)
                hideThumbnailTimer.restart();
        }

        onMovementEnded: {
            if (!movementCausedByFlick) {
                currentIndex = indexAt(contentX + width/2, contentY + height/2);
            } else {
                var i = indexAt(contentX + width/2, contentY + height/2);
                if (currentIndex != i)
                {
                    currentIndex = i;
                }
            }
            movementCausedByFlick = false;

            photoListView.currentItem.updateImage();
        }

        onCurrentIndexChanged: {
            photoViewer.currentIndexChanged();
        }
    }

    Component {
        id: slideshowComponent

        SlideshowViewer {
            id: slideshow
            model: photoViewer.model
            currentIndex: photoListView.currentIndex

            onSlideshowStopped: {
                photoListView.currentIndex = aFinalIndex
                sstimer.start()
                photoViewer.slideshowStopped()
            }

            Timer {
                id: sstimer
                interval: 500
                onTriggered: {
                    slideshow.destroy()
                    photoViewer.slideshow = undefined
                }
            }
        }
    }

    ListView {
        id: photoThumbnailView
        cacheBuffer: photoViewer.width / 3

        width: Math.min(120 * count, photoViewer.width)
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        orientation: ListView.Horizontal
        height: 100

        focus: true
        clip: true
        currentIndex: photoListView.currentIndex
        model: photoViewer.model
        property bool show: false
        spacing: 2
        opacity: 0
        highlightMoveDuration: 200
        onShowChanged: {
            // start the timer
            if (show == true) {
                hideThumbnailTimer.start();
            } else {
                hideThumbnailTimer.stop();
            }
        }

        delegate: Image {
            id: thumbnail
            width: 100
            height: 100
            source: thumburi
            fillMode: Image.PreserveAspectCrop
            clip: true

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    photoListView.positionViewAtIndex(index, ListView.Center)
                    photoListView.currentIndex = index
                    hideThumbnailTimer.restart()
                }
                onPositionChanged: {
                    hideThumbnailTimer.restart()
                }
            }
        }

        onFlickStarted: {
            hideThumbnailTimer.restart();
        }

        states: [
            State {
                name: "fullscreen-mode"
                when: photoViewer.fullscreen
                PropertyChanges {
                    target: photoThumbnailView
                    anchors.topMargin: 5
                }
            },
            State {
                name: "toolbar-mode"
                when: !photoViewer.fullscreen
                PropertyChanges {
                    target: photoThumbnailView
                    anchors.topMargin: 5 + window.statusBar.height + appPage.toolbarHeight
                }
            }
        ]

        transitions: [
            Transition {
                from: "fullscreen-mode"
                to: "toolbar-mode"
                reversible: true
                PropertyAnimation {
                    property: "anchors.topMargin"
                    duration: 250
                    easing.type: "OutSine"
                }
            }
        ]
    }

    Timer {
        id: hideThumbnailTimer;
        interval: 3000; running: false; repeat: false
        onTriggered: {
            photoThumbnailView.show = false;
        }
    }

    states: [
        State {
            name: "showThumbnail"
            when: photoThumbnailView.show
            PropertyChanges { target: photoThumbnailView; opacity: 1.0 }
        },
        State {
            name: "hideThumbnail"
            when: photoThumbnailView.show == false
            PropertyChanges { target: photoThumbnailView; opacity: 0}
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                property:"opacity"
                duration: 400
            }
        }
    ]
}
