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

Rectangle {
    id: slideshowViewer

    // public properties
    property variant model
    property int currentIndex: 0
    property alias delayMS: timer.interval
    property bool loop: false

    function stop() {
        timer.stop()
        slideshowStopped(currentIndex)
    }

    anchors.fill: parent
    color: "black"
    opacity: 0

    // "private" properties
    property bool init: true
    property bool first: true
    property bool halt: false
    property bool loopOnce: false

    signal slideshowStopped(int aFinalIndex)

    function loadImage(imageElement) {
        var newIndex = currentIndex + 1

        if (newIndex >= model.count) {
            if (loop || loopOnce) {
                newIndex = 0
                currentIndex = -1
                loopOnce = false
            }
            else {
                halt = true
                return
            }
        }

        imageElement.source = model.getURIfromIndex(newIndex)
    }

    Component.onCompleted: {
        timer.start()
        firstImage.source = model.getURIfromIndex(currentIndex)
        if (currentIndex + 1 >= model.count) {
            // if we start on the last image, loop to first once
            loopOnce = true
        }
    }

    Connections {
        target: scene
        onForegroundChanged: {
            if (!scene.foreground) {
                if (timer.running) {
                    timer.stop()
                    timer.paused = true
                }
            }
            else {
                if (timer.paused) {
                    timer.start()
                    timer.paused = false
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 3000
        repeat: true
        property bool paused: false

        onTriggered: {
            var count = model.count
            if (halt) {
                stop();
                slideshowStopped(currentIndex)
                return
            }

            if (init) {
                slideshowViewer.opacity = 1
                init = false
            }

            currentIndex++
            first = !first
            // ignoring for now possibility of image still not being ready
        }
    }

    Image {
        id: firstImage
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        width: parent.width
        height: parent.height
        asynchronous: true
    }

    Image {
        id: secondImage
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        width: parent.width
        height: parent.height
        asynchronous: true
    }

    MouseArea {
        anchors.fill: parent
        onPressed: stop()
    }

    states: [
        State {
            name: "showFirst"
            when: first
            PropertyChanges { target: firstImage; opacity: 1 }
            PropertyChanges { target: secondImage; opacity: 0 }
        },
        State {
            name: "showSecond"
            when: !first
            PropertyChanges { target: firstImage; opacity: 0 }
            PropertyChanges { target: secondImage; opacity: 1 }
        }
    ]

    transitions: [
        Transition {
            to: "showFirst"
            SequentialAnimation {
                PropertyAnimation { property: "opacity"; duration: 500 }
                ScriptAction { script: { loadImage(secondImage) } }
            }
        },
        Transition {
            to: "showSecond"
            SequentialAnimation {
                PropertyAnimation { property: "opacity"; duration: 500 }
                ScriptAction { script: { loadImage(firstImage) } }
            }
        }
    ]
}
