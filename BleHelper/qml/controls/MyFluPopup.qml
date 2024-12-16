import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import FluentUI

Popup {
    id: control
    padding: 0
    margins: 0
    spacing: 0
    modal: false
    dim: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    height: Math.min(implicitHeight, d.parentHeight)
    x: Math.round((d.parentWidth - width) / 2)
    y: Math.round((d.parentHeight - height) / 2)
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: FluTheme.animationEnabled && control.animationEnabled ? 167 : 0
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: FluTheme.animationEnabled && control.animationEnabled ? 167 : 0
        }
    }
    background: Rectangle {
        implicitWidth: 150
        implicitHeight: 36
        color: FluTheme.dark ? Qt.rgba(45 / 255, 45 / 255, 45 / 255, 1) : Qt.rgba(252 / 255, 252 / 255, 252 / 255, 1)
        border.color: FluTheme.dark ? Qt.rgba(26 / 255, 26 / 255, 26 / 255, 1) : Qt.rgba(191 / 255, 191 / 255, 191 / 255, 1)
        border.width: 1
        radius: 5
        FluShadow {}
    }
    Overlay.modal: Rectangle {
        color: FluTools.withOpacity(control.palette.shadow, 0.5)
    }
    Overlay.modeless: Rectangle {
        color: FluTools.withOpacity(control.palette.shadow, 0.12)
    }
    QtObject {
        id: d
        property int parentHeight: {
            if (control.parent) {
                return control.parent.height;
            }
            return control.height;
        }
        property int parentWidth: {
            if (control.parent) {
                return control.parent.width;
            }
            return control.width;
        }
    }
}
