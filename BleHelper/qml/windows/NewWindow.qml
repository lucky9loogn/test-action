import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import BleHelper
import FluentUI

import "../controls"

FluWindow {
    id: window
    width: 800
    height: 600
    minimumWidth: 768
    minimumHeight: 576
    launchMode: FluWindowType.SingleInstance
    autoDestroy: true
    showStayTop: true
    onInitArgument: arg => {
        window.title = arg.title;
        loader.setSource(arg.url, {
            "animationEnabled": false
        });
    }
    FluLoader {
        id: loader
        anchors.fill: parent
    }
}
