/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import Qt.labs.gestures 2.0

// roll our own button for the moment

BorderImage {
    id: button
    property bool pressed: false
    property alias text: label.text

    signal clicked

    border { left: 4; right: 4 }
    horizontalTileMode: BorderImage.Stretch
    width: label.paintedWidth + 40
    height: 40

    source: "image://theme/btn_blue_up"
    states: [
        State {
            name: "pressed"
            when: button.pressed
            PropertyChanges {
                target: button
                source: "image://theme/btn_blue_dn"
            }
        }
    ]

    Text {
        id: label
        anchors.fill: parent
        anchors.margins: 10
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: theme_fontPixelSizeLarge
        color: theme_buttonFontColor
        text: ""
    }

    GestureArea {
        anchors.fill: parent
        Tap {
            onFinished: button.clicked()
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: parent.pressed = true
        onReleased: {
            parent.pressed = false;
            button.clicked();
        }
    }
}
