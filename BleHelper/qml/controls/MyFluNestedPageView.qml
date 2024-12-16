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
    property real headerSpacing: 16
    property real subtitleSpacing: control.title !== "" ? headerSpacing / 2 : headerSpacing
    property real headerHeight: 50
    property real headerLeftPadding: 16
    property real headerRightPadding: 16
    property Item commandBar: null
    padding: 5
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
            model: d.pages
            clip: true
            spacing: control.subtitleSpacing
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            orientation: ListView.Horizontal
            currentIndex: swipe.currentIndex
            header: FluText {
                // 仅用于基线参考, 故设置 text: "", visible: false, width: 0
                text: ""
                visible: true
                font: FluTextStyle.Title
                width: 0
            }
            delegate: Row {
                anchors.baseline: nav_list.headerItem.baseline
                spacing: nav_list.spacing
                FluText {
                    id: subtitle_text
                    anchors.baseline: parent.baseline
                    text: modelData.title
                    font: control.title !== "" ? FluTextStyle.Subtitle : FluTextStyle.Title
                    visible: index <= nav_list.currentIndex
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
                            swipe.currentIndex = index;
                        }
                    }
                    FluFocusRectangle {
                        visible: item_mouse.activeFocus
                        radius: 4
                    }
                }
                FluIcon {
                    anchors.verticalCenter: subtitle_text.verticalCenter
                    iconSize: subtitle_text.font.pixelSize * 0.5
                    iconSource: FluentIcons.ChevronRightMed
                    visible: index <= swipe.currentIndex - 1
                    color: {
                        if (swipe.currentIndex === index) {
                            return textHighlightColor;
                        }
                        return textNormalColor;
                    }
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
        property var pages: d.children.filter(function (item) {
            return item instanceof Page;
        })
    }

    SwipeView {
        id: swipe
        clip: true
        interactive: false
        orientation: Qt.Horizontal
        anchors.fill: parent

        Component.onCompleted: {
            // reference: https://programmersought.com/article/53604958500/
            contentItem.highlightMoveDuration = FluTheme.animationEnabled ? 167 : 0;
            for (var i = 0; i < d.pages.length; i++) {
                var item = d.pages[i];
                item.header = null;
                swipe.addItem(item);
            }
        }
    }

    function nextPage() {
        if (swipe.currentIndex + 1 < d.pages.length) {
            swipe.currentIndex++;
        }
    }

    function previousPage() {
        if (swipe.currentIndex - 1 >= 0) {
            swipe.currentIndex--;
        }
    }

    function setCurrentIndex(index) {
        if (index >= 0 && index < d.pages.length) {
            swipe.currentIndex = index;
        }
    }
}
