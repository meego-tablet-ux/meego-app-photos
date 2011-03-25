/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

Window {
    id: scene
    width: 1024
    height: 600
    showsearch: false
    onStatusBarTriggered: orientation = !orientation


    ModalSurface {
        anchors.fill: parent
        visible: true
    }
}
