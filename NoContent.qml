/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Media 0.1

Item {
    id: noContentElement

    property alias text: noContentLabel.text
    property alias buttonText: actionButton.text

    signal clicked()

    width: childrenRect.width
    height: childrenRect.height

    Rectangle {
        id: separator1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4
        height: 1
        color: "lightgrey"
    }

    Text {
        id: noContentLabel
        anchors.top: separator1.bottom
        anchors.margins: 4
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Button {
        id: actionButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: noContentLabel.bottom
        anchors.margins: 4

        onClicked: noContentElement.clicked()
    }

    Rectangle {
        id: separator2
        anchors.top: actionButton.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 4
        height: 1
        color: "lightgrey"
    }
}
