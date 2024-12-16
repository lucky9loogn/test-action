import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Templates as T

import FluentUI

FluPage {
    id: control
    default property alias content: d.children
    readonly property alias currentIndex: swipe.currentIndex
    property color textHighlightColor: FluTheme.dark ? FluColors.Grey10 : FluColors.Black
    property color textNormalColor: FluTheme.dark ? FluColors.Grey120 : FluColors.Grey120
    property color textHoverColor: FluTheme.dark ? FluColors.Grey90 : FluColors.Grey140
    property real headerSpacing: control.title !== "" ? 16 : 24
    property real subtitleSpacing: headerSpacing
    property real headerHeight: 50
    property real headerLeftPadding: 16
    property real headerRightPadding: 16
    property Item commandBar: null
    padding: 5
    background: Item {}
    header: Item {
        implicitHeight: control.headerHeight

        FluLoader {
            id: title_text_loader
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: control.headerLeftPadding
            }
            active: control.title !== ""
            sourceComponent: Component {
                FluText {
                    text: control.title
                    font: FluTextStyle.Title
                }
            }
        }

        ListView {
            id: nav_list
            anchors {
                verticalCenter: parent.verticalCenter
                left: title_text_loader.right
                right: command_bar_loader.left
                leftMargin: control.title !== "" ? control.headerSpacing : 0
                rightMargin: control.commandBar ? control.headerSpacing : 0
            }
            implicitHeight: headerItem.implicitHeight
            model: d.pivotItems
            clip: true
            spacing: control.subtitleSpacing
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            orientation: ListView.Horizontal
            highlight: Item {
                anchors.baseline: nav_list.headerItem.baseline
                clip: true
                Rectangle {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        baseline: parent.baseline
                        baselineOffset: 4
                    }
                    height: 3
                    width: parent.width
                    radius: 1.5
                    color: FluTheme.primaryColor
                }
            }
            highlightMoveDuration: FluTheme.animationEnabled ? 167 : 0
            highlightResizeDuration: FluTheme.animationEnabled ? 167 : 0
            header: FluText {
                // 仅用于基线参考, 故设置 text: "", visible: false, width: 0
                text: ""
                visible: true
                font: FluTextStyle.Title
                width: 0
            }
            delegate: FluText {
                anchors.baseline: nav_list.headerItem.baseline
                text: modelData.title
                font: control.title !== "" ? FluTextStyle.Subtitle : FluTextStyle.Title
                color: {
                    if (nav_list.currentIndex === index) {
                        return textHighlightColor;
                    }
                    if (item_mouse.containsMouse) {
                        return textHoverColor;
                    }
                    return textNormalColor;
                }
                MouseArea {
                    id: item_mouse
                    focusPolicy: Qt.TabFocus
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        nav_list.currentIndex = index;
                    }
                }
                FluFocusRectangle {
                    visible: item_mouse.activeFocus
                    radius: 4
                }
            }
        }

        FluLoader {
            id: command_bar_loader
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: control.headerRightPadding
            }
            active: control.commandBar !== null
            sourceComponent: Component {
                Item {
                    data: control.commandBar
                    implicitWidth: control.commandBar ? control.commandBar.implicitWidth : 0
                }
            }
        }
    }

    FluObject {
        id: d
        property var pivotItems: d.children.filter(function (item) {
            return item instanceof FluPivotItem;
        })
    }

    T.SwipeView {
        id: swipe
        clip: true
        interactive: false
        orientation: Qt.Horizontal
        anchors.fill: parent
        currentIndex: nav_list.currentIndex

        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)

        contentItem: ListView {
            model: swipe.contentModel
            interactive: swipe.interactive
            currentIndex: swipe.currentIndex
            focus: swipe.focus

            spacing: swipe.spacing
            orientation: swipe.orientation
            snapMode: ListView.SnapOneItem
            boundsBehavior: Flickable.StopAtBounds

            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: 0
            highlightMoveDuration: FluTheme.animationEnabled ? 167 : 0
            maximumFlickVelocity: 4 * (swipe.orientation === Qt.Horizontal ? width : height)
        }

        Repeater {
            model: d.pivotItems
            FluLoader {
                active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                property var argument: modelData.argument
                sourceComponent: modelData.contentItem
            }
        }
    }
}
