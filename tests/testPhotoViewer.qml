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
    id: scene
    width: 1024
    height: 768

    property bool landscape: true

    Rectangle {
        anchors.fill:parent
        color:"gray"
    }

    Rectangle {
        id: next
        width: 40
        height:40
        x: 0; y:0
        color:"green"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                viewer.showNextPhoto();
            }
        }
    }
    Rectangle {
        id: prev
        width: 40
        height:40
        x: 0; y:40
        color:"red"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                viewer.showPrevPhoto();
            }
        }
    }
    Rectangle {
        id: rotateR
        width: 40
        height:40
        x: 0; y:80
        color:"blue"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                viewer.rotateRightward();
            }
        }
    }
    Rectangle {
        id: rotateL
        width: 40
        height:40
        x: 0; y:120
        color:"yellow"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                viewer.rotateLeftward();
            }
        }
    }
    Rectangle {
        id: changeSize
        width: 40
        height:40
        x: 0; y:160
        color:"black"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                scene.landscape = !scene.landscape;
            }
        }
    }
    Rectangle {
        id : viewerRect
        width: 800
        height: 600
        anchors.centerIn: parent


        PhotoViewer {
            id: viewer
            z: 100
            anchors.fill: parent
            model:PhotoListModel {
                type: PhotoListModel.ListofPhotos
                limit:0
                sort:PhotoListModel.SortByDefault
            }
        }
    }

    states: [
        State {
            name: "portrait"
            when: landscape == false
            PropertyChanges {
                target: viewerRect
                width: 600
                height:800

            }
        }
    ]

}



