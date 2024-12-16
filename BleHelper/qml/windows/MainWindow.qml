import Qt.labs.platform
import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"
import "../models"

FluWindow {
    id: window
    title: qsTr("BLE Helper")
    width: 1024
    height: 768
    minimumWidth: 768
    minimumHeight: 576
    launchMode: FluWindowType.SingleTask
    fitsAppBarWindows: true
    appBar: FluAppBar {
        showDark: false
        closeClickListener: function () {
            close_dialog.open();
        }
        z: 8
    }

    onWidthChanged: {
        save_window_state_delay_timer.restart();
    }

    onHeightChanged: {
        save_window_state_delay_timer.restart();
    }

    onVisibilityChanged: function (v) {
        save_window_state_delay_timer.restart();
    }

    Timer {
        id: save_window_state_delay_timer
        interval: 300
        onTriggered: {
            if (visibility === Window.Maximized || visibility === Window.FullScreen) {
                SettingsManager.saveWindowMaximized(true);
                return;
            } else {
                SettingsManager.saveWindowMaximized(false);
                SettingsManager.saveWindowWidth(width);
                SettingsManager.saveWindowHeight(height);
            }
        }
    }

    Component.onCompleted: {
        var w = SettingsManager.windowWidth();
        var h = SettingsManager.windowHeight();
        width = w > minimumWidth ? w : minimumWidth;
        height = h > minimumHeight ? h : minimumHeight;
        moveWindowToDesktopCenter();
        if (SettingsManager.isWindowMaximized()) {
            showMaximized();
        }
    }

    Component.onDestruction: {
        FluRouter.exit();
    }

    SystemTrayIcon {
        id: system_tray
        visible: true
        icon.source: "qrc:/resources/images/icons/logo_64x64.png"
        tooltip: qsTr("BLE Helper")
        menu: Menu {
            MenuItem {
                text: qsTr("Quit")
                onTriggered: {
                    FluRouter.exit();
                }
            }
        }
        onActivated: function (reason) {
            if (reason === SystemTrayIcon.Trigger) {
                window.show();
                window.raise();
                window.requestActivate();
            }
        }
    }

    Timer {
        id: window_hide_delay_timer
        interval: 150
        onTriggered: {
            window.hide();
        }
    }

    FluContentDialog {
        id: close_dialog
        title: qsTr("Quit")
        message: qsTr("Do you want to quit the application?")
        negativeText: qsTr("Minimize")
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.NeutralButton | FluContentDialogType.PositiveButton
        onNegativeClicked: {
            system_tray.showMessage(qsTr("Tip"), qsTr("BLE Helper") + qsTr(" is now hidden from the tray. Click the tray icon to bring the window back."));
            window_hide_delay_timer.restart();
        }
        positiveText: qsTr("Quit")
        neutralText: qsTr("Cancel")
        onPositiveClicked: {
            FluRouter.exit(0);
        }
    }

    Component {
        id: nav_item_right_button_menu_component
        FluMenu {
            width: 192
            FluMenuItem {
                text: qsTr("Move to new Window")
                font: FluTextStyle.Caption
                onClicked: {
                    var key = "/newWindow" + modelData.url;
                    FluRouter.routes[key] = "qrc:/qml/windows/NewWindow.qml";
                    FluRouter.navigate(key, {
                        "title": modelData.title,
                        "url": modelData.url
                    });
                }
            }
        }
    }

    Component {
        id: easter_eggs_component
        Item {
            property int hours: 0
            property int minutes: 0
            property int seconds: 0
            property string currentDate: ""
            property string currentDay: ""
            property var weekDays: [qsTr("Sunday"), qsTr("Monday"), qsTr("Tuesday"), qsTr("Wednesday"), qsTr("Thursday"), qsTr("Friday"), qsTr("Saturday")]
            property int clockFontPixelSize: 70
            property int dateDayFontPixelSize: 20
            property string clockFontColor: Qt.rgba(1, 1, 1, 1)
            property string dateDayFontColor: Qt.rgba(1, 1, 1, 1)

            Timer {
                id: clock_timer
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    var date = new Date();
                    hours = date.getHours();
                    minutes = date.getMinutes();
                    seconds = date.getSeconds();
                    if (GlobalModel.language.startsWith("zh")) {
                        currentDate = date.toLocaleDateString();
                    } else {
                        currentDate = date.toLocaleDateString(GlobalModel.language.replace('_', '-'));
                    }
                    currentDay = weekDays[date.getDay()];
                }
            }

            Image {
                id: background_image
                asynchronous: true
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
            }

            Rectangle {
                color: Qt.rgba(0, 0, 0, 0.25)
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.centerIn: parent
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 5
                    Text {
                        font.pixelSize: clockFontPixelSize
                        color: clockFontColor
                        text: hours < 10 ? "0" + hours : hours
                    }
                    Text {
                        Layout.bottomMargin: 10
                        font.pixelSize: clockFontPixelSize
                        color: clockFontColor
                        text: ":"
                    }
                    Text {
                        font.pixelSize: clockFontPixelSize
                        color: clockFontColor
                        text: minutes < 10 ? "0" + minutes : minutes
                    }
                    Text {
                        Layout.bottomMargin: 10
                        font.pixelSize: clockFontPixelSize
                        color: clockFontColor
                        text: ":"
                    }
                    Text {
                        font.pixelSize: clockFontPixelSize
                        color: clockFontColor
                        text: seconds < 10 ? "0" + seconds : seconds
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 30
                    FluText {
                        font.pixelSize: dateDayFontPixelSize
                        color: dateDayFontColor
                        text: currentDate
                    }
                    FluText {
                        font.pixelSize: dateDayFontPixelSize
                        color: dateDayFontColor
                        text: currentDay
                    }
                }
            }

            Component.onCompleted: {
                var url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN";
                var xhr = new XMLHttpRequest();
                xhr.open("GET", url, true);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200 && xhr.responseText !== "") {
                            var data = JSON.parse(xhr.responseText);
                            if (data && data.images && data.images.length > 0) {
                                var imageUrl = "https://www.bing.com" + data.images[0].url;
                                background_image.source = imageUrl;
                            }
                        }
                    }
                };
                xhr.send();
            }

            Component.onDestruction: {
                clock_timer.running = false;
            }
        }
    }

    Flipable {
        id: flipable
        anchors.fill: parent
        property bool flipped: false
        property real flipAngle: 0
        transform: Rotation {
            id: rotation
            origin.x: flipable.width / 2
            origin.y: flipable.height / 2
            axis {
                x: 0
                y: 1
                z: 0
            }
            angle: flipable.flipAngle
        }
        states: State {
            PropertyChanges {
                target: flipable
                flipAngle: 180
            }
            when: flipable.flipped
        }
        transitions: Transition {
            NumberAnimation {
                target: flipable
                property: "flipAngle"
                duration: 1000
                easing.type: Easing.OutCubic
            }
        }
        back: Item {
            anchors.fill: flipable
            visible: flipable.flipAngle !== 0
            Row {
                id: back_buttons_layout
                z: 8
                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: FluTools.isMacos() ? 20 : 5
                    leftMargin: 5
                }
                FluIconButton {
                    iconColor: Qt.rgba(1, 1, 1, 1)
                    iconSource: FluentIcons.ChromeBack
                    width: 30
                    height: 30
                    iconSize: 13
                    onClicked: {
                        flipable.flipped = false;
                    }
                }
                Component.onCompleted: {
                    window.setHitTestVisible(back_buttons_layout);
                }
            }
            FluLoader {
                active: flipable.flipped
                anchors.fill: parent
                sourceComponent: easter_eggs_component
            }
        }
        front: Item {
            visible: flipable.flipAngle !== 180
            anchors.fill: flipable
            FluNavigationView {
                id: nav_view
                property int clickCount: 0
                width: parent.width
                height: parent.height
                z: 999
                pageMode: FluNavigationViewType.NoStack
                items: FluObject {
                    FluPaneItem {
                        title: qsTr("Bluetooth Client")
                        menuDelegate: nav_item_right_button_menu_component
                        iconDelegate: MyFluIcon {
                            iconSize: 15
                            iconSource: MyFluIcon.Client
                        }
                        url: "qrc:/qml/pages/ClientPage.qml"
                        onTap: {
                            nav_view.push(url);
                        }
                    }

                    FluPaneItem {
                        title: qsTr("Manage Favorites")
                        menuDelegate: nav_item_right_button_menu_component
                        iconDelegate: FluIcon {
                            iconSize: 15
                            iconSource: FluentIcons.FavoriteStar
                        }
                        url: "qrc:/qml/pages/ManageFavoritesPage.qml"
                        onTap: {
                            nav_view.push(url);
                        }
                    }

                    FluPaneItem {
                        title: qsTr("Manage UUID Dictionary")
                        menuDelegate: nav_item_right_button_menu_component
                        iconDelegate: FluIcon {
                            iconSize: 15
                            iconSource: FluentIcons.Dictionary
                        }
                        url: "qrc:/qml/pages/ManageUuidDictionaryPage.qml"
                        onTap: {
                            nav_view.push(url);
                        }
                    }
                }
                footerItems: FluObject {
                    FluPaneItemSeparator {}

                    FluPaneItem {
                        title: qsTr("Settings")
                        iconDelegate: FluIcon {
                            iconSize: 15
                            iconSource: FluentIcons.Settings
                        }
                        url: "qrc:/qml/pages/SettingsPage.qml"
                        onTap: {
                            nav_view.push(url);
                        }
                    }
                }

                topPadding: {
                    if (window.useSystemAppBar) {
                        return 0;
                    }
                    return FluTools.isMacos() ? 20 : 0;
                }
                displayMode: GlobalModel.navigationViewType
                logo: "qrc:/resources/images/icons/logo_32x32.png"
                title: qsTr("BLE Helper")
                Timer {
                    id: click_count_reset_timer
                    interval: 500
                    onTriggered: {
                        nav_view.clickCount = 0;
                    }
                }
                onLogoClicked: {
                    clickCount += 1;
                    showSuccess(qsTr("Click Time: ") + clickCount);
                    click_count_reset_timer.restart();
                    if (clickCount === 5) {
                        flipable.flipped = true;
                        clickCount = 0;
                    }
                }

                Component.onCompleted: {
                    window.setHitTestVisible(nav_view.buttonMenu);
                    window.setHitTestVisible(nav_view.buttonBack);
                    window.setHitTestVisible(nav_view.imageLogo);
                    setCurrentIndex(0);
                }
            }
        }
    }

    Shortcut {
        sequence: "F1"
        context: Qt.WindowShortcut
        onActivated: {
            tour.open();
        }
    }

    FluTour {
        id: tour
        finishText: qsTr("Finish")
        nextText: qsTr("Next")
        previousText: qsTr("Back")
        steps: {
            var data = [];
            data.push({
                "title": qsTr("Hide Easter eggs"),
                "description": qsTr("Try a few more clicks!"),
                "target": () => nav_view.imageLogo
            });
            return data;
        }
    }
}
