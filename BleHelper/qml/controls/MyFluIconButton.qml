import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts

import FluentUI

Button {
    id: control
    display: Button.TextBesideIcon
    property int iconSize: 20
    property int iconSource
    property bool disabled: false
    property int radius: 4
    property string contentDescription: ""
    property color hoverColor: FluTheme.itemHoverColor
    property color pressedColor: FluTheme.itemPressColor
    property color normalColor: FluTheme.itemNormalColor
    property color disableColor: FluTheme.itemNormalColor
    property Component iconDelegate: {
        if (iconSource >= FluIcon.GlobalNavButton && iconSource <= FluIcon.ClickedOutLoudSolidBold) {
            return com_icon;
        }
        return com_my_icon;
    }
    property color color: {
        if (!enabled) {
            return disableColor;
        }
        if (pressed) {
            return pressedColor;
        }
        return hovered ? hoverColor : normalColor;
    }
    property color iconColor: {
        if (FluTheme.dark) {
            if (!enabled) {
                return Qt.rgba(130 / 255, 130 / 255, 130 / 255, 1);
            }
            return Qt.rgba(1, 1, 1, 1);
        } else {
            if (!enabled) {
                return Qt.rgba(161 / 255, 161 / 255, 161 / 255, 1);
            }
            return Qt.rgba(0, 0, 0, 1);
        }
    }
    property color textColor: FluTheme.fontPrimaryColor
    Accessible.role: Accessible.Button
    Accessible.name: control.text
    Accessible.description: contentDescription
    Accessible.onPressAction: control.clicked()
    focusPolicy: Qt.TabFocus
    verticalPadding: 6
    horizontalPadding: 6
    enabled: !disabled
    font: FluTextStyle.Caption
    background: Rectangle {
        radius: control.radius
        color: control.color
        FluFocusRectangle {
            visible: control.activeFocus
        }
    }
    Component {
        id: com_icon
        FluIcon {
            id: text_icon
            font.pixelSize: iconSize
            iconSize: control.iconSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconColor: control.iconColor
            iconSource: control.iconSource
        }
    }
    Component {
        id: com_my_icon
        MyFluIcon {
            id: text_icon
            font.pixelSize: iconSize
            iconSize: control.iconSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconColor: control.iconColor
            iconSource: control.iconSource
        }
    }
    Component {
        id: com_row
        RowLayout {
            FluLoader {
                sourceComponent: iconDelegate
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.TextOnly
            }
            FluText {
                text: control.text
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.IconOnly
                color: control.textColor
                font: control.font
            }
        }
    }
    Component {
        id: com_column
        ColumnLayout {
            FluLoader {
                sourceComponent: iconDelegate
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.TextOnly
            }
            FluText {
                text: control.text
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.IconOnly
                color: control.textColor
                font: control.font
            }
        }
    }
    contentItem: FluLoader {
        sourceComponent: {
            if (display === Button.TextUnderIcon) {
                return com_column;
            }
            return com_row;
        }
    }
    FluTooltip {
        id: tool_tip
        visible: {
            if (control.text === "") {
                return false;
            }
            if (control.display !== Button.IconOnly) {
                return false;
            }
            return hovered;
        }
        text: control.text
        delay: 1000
    }
}
