import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

import "../controls"

FluPage {
    id: page
    padding: 0
    header: Item {
        implicitHeight: 50
        FluText {
            text: qsTr("Details")
            font: FluTextStyle.Title
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 16
            }
        }
    }

    FluText {
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        text: qsTr("Details")
        font: FluTextStyle.Title
    }
}
