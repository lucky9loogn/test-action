import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

Item {
    id: control
    property bool disabled: false
    property int radius: 4
    property string headerText: ""
    property int headerHeight: 70
    property var headerDelegate: com_header
    property int headerLeftPadding: 16
    property int headerRightPadding: 16
    property bool expand: false
    property int contentHeight: 300
    default property alias content: container.data
    property color normalColor: Window.active ? FluTheme.frameActiveColor : FluTheme.frameColor
    property color hoverColor: FluTheme.dark ? Qt.rgba(50 / 255, 50 / 255, 50 / 255, 1) : Qt.rgba(246 / 255, 246 / 255, 246 / 255, 1)
    property color disableColor: FluTheme.dark ? Qt.rgba(59 / 255, 59 / 255, 59 / 255, 1) : Qt.rgba(251 / 255, 251 / 255, 251 / 255, 1)
    property color dividerColor: FluTheme.dark ? Qt.rgba(80 / 255, 80 / 255, 80 / 255, 1) : Qt.rgba(233 / 255, 233 / 255, 233 / 255, 1)
    property color textColor: {
        if (FluTheme.dark) {
            if (!control.enabled) {
                return Qt.rgba(131 / 255, 131 / 255, 131 / 255, 1);
            }
            if (control_mouse.pressed) {
                return Qt.rgba(162 / 255, 162 / 255, 162 / 255, 1);
            }
            return Qt.rgba(1, 1, 1, 1);
        } else {
            if (!control.enabled) {
                return Qt.rgba(160 / 255, 160 / 255, 160 / 255, 1);
            }
            if (control_mouse.pressed) {
                return Qt.rgba(96 / 255, 96 / 255, 96 / 255, 1);
            }
            return Qt.rgba(0, 0, 0, 1);
        }
    }
    enabled: !disabled
    implicitHeight: Math.max((layout_header.height + layout_container.height), layout_header.height)
    implicitWidth: 400
    QtObject {
        id: d
        property bool flag: false
        function toggle() {
            d.flag = true;
            expand = !expand;
            d.flag = false;
        }
    }
    clip: true
    Component {
        id: com_header
        Item {
            FluText {
                text: control.headerText
                anchors.verticalCenter: parent.verticalCenter
                color: control.textColor
            }
        }
    }
    Rectangle {
        id: layout_header
        width: parent.width
        height: control.headerHeight
        radius: control.radius
        border.color: FluTheme.dividerColor
        color: control.normalColor
        ColorAnimation on color {
            id: color_animation
            duration: FluTheme.animationEnabled ? 167 : 0
            easing.type: Easing.OutCubic
            from: layout_header.color
            to: control_mouse.containsMouse ? control.normalColor : control.hoverColor
            running: false
        }
        MouseArea {
            id: control_mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: control.enabled
            onClicked: {
                d.toggle();
            }
            onContainsMouseChanged: {
                if (Window.active) {
                    color_animation.restart();
                }
            }
        }
        RowLayout {
            anchors {
                fill: parent
                leftMargin: control.headerLeftPadding
                rightMargin: control.headerRightPadding
            }

            FluLoader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                sourceComponent: control.headerDelegate
            }

            FluIcon {
                id: icon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                rotation: control.expand ? 0 : 180
                iconSource: FluentIcons.ChevronUp
                iconSize: 15
                Behavior on rotation {
                    enabled: FluTheme.animationEnabled
                    NumberAnimation {
                        duration: 167
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
    Item {
        id: layout_container
        anchors {
            top: layout_header.bottom
            topMargin: -1
            left: layout_header.left
        }
        visible: contentHeight + container.anchors.topMargin !== 0
        height: contentHeight + container.anchors.topMargin
        width: parent.width
        z: -999
        clip: true
        Rectangle {
            id: container
            anchors.fill: parent
            radius: control.radius
            clip: true
            color: {
                if (Window.active) {
                    return FluTheme.frameActiveColor;
                }
                return FluTheme.frameColor;
            }
            border.color: FluTheme.dividerColor
            anchors.topMargin: -contentHeight
            states: [
                State {
                    name: "expand"
                    when: control.expand
                    PropertyChanges {
                        target: container
                        anchors.topMargin: 0
                    }
                },
                State {
                    name: "collapsed"
                    when: !control.expand
                    PropertyChanges {
                        target: container
                        anchors.topMargin: -contentHeight
                    }
                }
            ]
            transitions: [
                Transition {
                    to: "expand"
                    NumberAnimation {
                        properties: "anchors.topMargin"
                        duration: FluTheme.animationEnabled && d.flag ? 167 : 0
                        easing.type: Easing.OutCubic
                    }
                },
                Transition {
                    to: "collapsed"
                    NumberAnimation {
                        properties: "anchors.topMargin"
                        duration: FluTheme.animationEnabled && d.flag ? 167 : 0
                        easing.type: Easing.OutCubic
                    }
                }
            ]
        }
    }
}
