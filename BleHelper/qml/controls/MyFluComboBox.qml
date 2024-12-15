import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Templates as T

import FluentUI

T.ComboBox {
    id: control
    signal commit(string text)
    property bool disabled: false
    property color normalColor: FluTheme.dark ? Qt.rgba(62 / 255, 62 / 255, 62 / 255, 1) : Qt.rgba(254 / 255, 254 / 255, 254 / 255, 1)
    property color hoverColor: FluTheme.dark ? Qt.rgba(68 / 255, 68 / 255, 68 / 255, 1) : Qt.rgba(251 / 255, 251 / 255, 251 / 255, 1)
    property color disableColor: FluTheme.dark ? Qt.rgba(59 / 255, 59 / 255, 59 / 255, 1) : Qt.rgba(252 / 255, 252 / 255, 252 / 255, 1)
    property alias textBox: text_field
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding, implicitIndicatorHeight + topPadding + bottomPadding)
    font: FluTextStyle.Body
    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    enabled: !disabled
    delegate: FluItemDelegate {
        id: item_delegate
        required property var model
        required property int index

        horizontalPadding: 16
        verticalPadding: 8
        width: ListView.view.width
        text: model[control.textRole]
        palette.text: control.palette.text
        font: control.font
        palette.highlightedText: control.palette.highlightedText
        highlighted: control.highlightedIndex === item_delegate.index
        hoverEnabled: control.hoverEnabled
        contentItem: FluText {
            text: item_delegate.text
            font: item_delegate.font
            elide: Text.ElideRight
            color: {
                if (item_delegate.down) {
                    return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120;
                }
                return FluTheme.dark ? FluColors.White : FluColors.Grey220;
            }
        }
        background: Rectangle {
            radius: 4
            anchors {
                fill: parent
                leftMargin: 6
                rightMargin: 6
            }

            color: {
                if (FluTheme.dark) {
                    return Qt.rgba(1, 1, 1, 0.05);
                } else {
                    return Qt.rgba(0, 0, 0, 0.05);
                }
            }
            visible: item_delegate.down || item_delegate.highlighted || item_delegate.visualFocus
        }
    }
    focusPolicy: Qt.TabFocus
    indicator: Item {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 30

        Button {
            id: indicator_button
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            enabled: control.enabled && control.editable
            background: Item {
                Rectangle {
                    anchors.centerIn: parent
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 4
                    color: {
                        if (!indicator_button.enabled) {
                            return FluTheme.itemNormalColor;
                        }
                        if (indicator_button.pressed) {
                            return FluTheme.itemPressColor;
                        }
                        return indicator_button.hovered ? FluTheme.itemHoverColor : FluTheme.itemNormalColor;
                    }
                }
            }
            contentItem: Item {
                FluIcon {
                    anchors.fill: parent
                    anchors.topMargin: control.pressed || indicator_button.pressed ? 2 : 0
                    Behavior on anchors.topMargin {
                        enabled: FluTheme.animationEnabled
                        NumberAnimation {
                            easing.type: Easing.InOutBounce
                            duration: 167
                        }
                    }
                    iconSource: FluentIcons.ChevronDown
                    iconSize: 8
                    opacity: control.enabled ? 1 : 0.3
                }
            }
            onClicked: {
                control.popup.visible = true;
            }
        }
    }

    contentItem: T.TextField {
        id: text_field
        leftPadding: !control.mirrored ? 10 : control.editable && activeFocus ? 3 : 1
        rightPadding: control.mirrored ? 10 : control.editable && activeFocus ? 3 : 1
        topPadding: 6 - control.padding
        bottomPadding: 6 - control.padding
        renderType: FluTheme.nativeText ? Text.NativeRendering : Text.QtRendering
        selectionColor: FluTools.withOpacity(FluTheme.primaryColor, 0.5)
        selectedTextColor: color
        text: control.editable ? control.editText : control.displayText
        enabled: control.editable
        autoScroll: control.editable
        font: control.font
        readOnly: control.down
        color: {
            if (!control.enabled) {
                return FluTheme.dark ? Qt.rgba(131 / 255, 131 / 255, 131 / 255, 1) : Qt.rgba(160 / 255, 160 / 255, 160 / 255, 1);
            }
            return FluTheme.dark ? Qt.rgba(255 / 255, 255 / 255, 255 / 255, 1) : Qt.rgba(27 / 255, 27 / 255, 27 / 255, 1);
        }
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: true
        verticalAlignment: Text.AlignVCenter
        Component.onCompleted: {
            forceActiveFocus();
        }
        Keys.onEnterPressed: event => handleCommit(event)
        Keys.onReturnPressed: event => handleCommit(event)
        function handleCommit(event) {
            control.commit(control.editText);
            accepted();
        }
        onActiveFocusChanged: {
            if (text_field.activeFocus) {
                selectAll();
            } else {
                deselect();
            }
        }
    }
    background: Rectangle {
        implicitWidth: 140
        implicitHeight: 32
        border.color: FluTheme.dark ? "#505050" : "#DFDFDF"
        border.width: 1
        visible: !control.flat || control.down
        radius: 4
        color: {
            if (!control.enabled) {
                return disableColor;
            }
            return hovered ? hoverColor : normalColor;
        }

        FluFocusRectangle {
            visible: !control.editable && control.visualFocus
            radius: 4
            anchors.margins: -2
        }

        FluClip {
            anchors.fill: parent
            radius: [4, 4, 4, 4]
            visible: control.editable && contentItem && contentItem.activeFocus
            Rectangle {
                width: parent.width
                height: 2
                anchors.bottom: parent.bottom
                color: FluTheme.primaryColor
            }
        }
    }
    popup: T.Popup {
        id: popup
        y: 0
        width: control.width
        height: getHeight()
        topMargin: 6
        bottomMargin: 6
        modal: true
        topPadding: 6
        bottomPadding: 6
        contentItem: ListView {
            id: content_list
            spacing: 4
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.currentIndex
            highlightMoveDuration: FluTheme.animationEnabled ? 167 : 0
            highlight: Item {
                clip: true
                Rectangle {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 6
                    }
                    height: content_list.currentItem && content_list.currentItem.pressed ? 10 : 16
                    width: 3
                    radius: 1.5
                    color: FluTheme.primaryColor
                    Behavior on height {
                        enabled: FluTheme.animationEnabled
                        NumberAnimation {
                            duration: 167
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Rectangle {
                    radius: 4
                    anchors {
                        fill: parent
                        leftMargin: 6
                        rightMargin: 6
                    }

                    color: {
                        if (FluTheme.dark) {
                            return Qt.rgba(1, 1, 1, 0.05);
                        } else {
                            return Qt.rgba(0, 0, 0, 0.05);
                        }
                    }
                    visible: control.highlightedIndex !== control.currentIndex
                }
            }
            boundsMovement: Flickable.StopAtBounds
            T.ScrollIndicator.vertical: ScrollIndicator {}
        }
        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "height"
                from: 0
                to: popup.getHeight()
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "y"
                from: 0
                to: control.height / 2 - (content_list.currentItem ? content_list.currentItem.y + content_list.currentItem.height / 2 : 0)
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
            }
        }

        background: Rectangle {
            radius: 5
            color: FluTheme.dark ? Qt.rgba(43 / 255, 43 / 255, 43 / 255, 1) : Qt.rgba(1, 1, 1, 1)
            border.color: FluTheme.dark ? Qt.rgba(26 / 255, 26 / 255, 26 / 255, 1) : Qt.rgba(191 / 255, 191 / 255, 191 / 255, 1)
            FluShadow {
                elevation: 5
                radius: 5
            }
        }

        function getHeight() {
            return Math.min(contentItem.implicitHeight + topPadding + bottomPadding, control.Window.height - topMargin - bottomMargin);
        }
    }
}
