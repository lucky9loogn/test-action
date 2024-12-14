import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import FluentUI

import "../controls"
import "../models"

FluScrollablePage {
    id: page
    padding: 0
    header: Item {
        implicitHeight: 50
        FluText {
            text: qsTr("Settings")
            font: FluTextStyle.Title
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 16
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        Layout.topMargin: 16
        Layout.bottomMargin: 16
        spacing: 4

        /* Appearance */
        FluText {
            text: qsTr("Appearance")
            font: FluTextStyle.BodyStrong
            Layout.topMargin: 10
            Layout.bottomMargin: 5
        }

        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Application Theme")
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            MyFluComboBox {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: Math.max(200, implicitWidth)
                textRole: "text"
                valueRole: "value"
                onActivated: {
                    if (FluTheme.darkMode !== currentValue) {
                        FluTheme.darkMode = currentValue;
                        SettingsManager.saveDarkMode(FluTheme.darkMode);
                    }
                }
                Component.onCompleted: {
                    currentIndex = indexOfValue(FluTheme.darkMode);
                }
                model: ListModel {
                    ListElement {
                        text: qsTr("Use System Setting")
                        value: FluThemeType.System
                    }
                    ListElement {
                        text: qsTr("Light")
                        value: FluThemeType.Light
                    }
                    ListElement {
                        text: qsTr("Dark")
                        value: FluThemeType.Dark
                    }
                }
            }
        }

        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Navigation Pane Display Mode")
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            MyFluComboBox {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: Math.max(200, implicitWidth)
                textRole: "text"
                valueRole: "value"
                onActivated: {
                    if (GlobalModel.navigationViewType !== currentValue) {
                        GlobalModel.navigationViewType = currentValue;
                        SettingsManager.saveNavigationViewType(GlobalModel.navigationViewType);
                    }
                }
                Component.onCompleted: {
                    currentIndex = indexOfValue(GlobalModel.navigationViewType);
                }
                model: ListModel {
                    ListElement {
                        text: qsTr("Open")
                        value: FluNavigationViewType.Open
                    }
                    ListElement {
                        text: qsTr("Compact")
                        value: FluNavigationViewType.Compact
                    }
                    ListElement {
                        text: qsTr("Minimal")
                        value: FluNavigationViewType.Minimal
                    }
                    ListElement {
                        text: qsTr("Auto")
                        value: FluNavigationViewType.Auto
                    }
                }
            }
        }

        MyFluExpander {
            Layout.fillWidth: true
            headerHeight: 70
            contentHeight: accent_color_expander_content_container.implicitHeight
            expand: true
            headerText: qsTr("Accent Color")
            content: Item {
                anchors.fill: parent

                ColumnLayout {
                    id: accent_color_expander_content_container
                    anchors.fill: parent
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 16
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16

                        FluText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillWidth: true
                            text: qsTr("Preset Colors")
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            spacing: 4
                            Repeater {
                                model: GlobalModel.presetColors
                                delegate: Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 4
                                    color: accent_color_item_mouse_area.containsMouse ? Qt.lighter(modelData.normal, 1.1) : modelData.normal
                                    border.color: modelData.darker
                                    FluIcon {
                                        anchors.centerIn: parent
                                        iconSource: FluentIcons.AcceptMedium
                                        iconSize: 16
                                        visible: modelData === FluTheme.accentColor
                                        color: FluTheme.dark ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
                                    }
                                    MouseArea {
                                        id: accent_color_item_mouse_area
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            FluTheme.accentColor = modelData;
                                            SettingsManager.saveAccentNormalColor(FluTheme.accentColor.normal);
                                            theme_color_picker.current = FluTheme.accentColor.normal;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 16
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16

                        FluText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillWidth: true
                            text: qsTr("Custom Colors")
                        }

                        FluColorPicker {
                            id: theme_color_picker
                            Layout.rightMargin: -4
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            width: 42
                            height: 42
                            current: FluTheme.accentColor.normal
                            onAccepted: {
                                FluTheme.accentColor = GlobalModel.createAccentColor(current);
                                SettingsManager.saveAccentNormalColor(current);
                            }
                            FluIcon {
                                anchors.centerIn: parent
                                iconSource: FluentIcons.AcceptMedium
                                iconSize: 16
                                visible: {
                                    for (var i = 0; i < GlobalModel.presetColors.length; i++) {
                                        if (GlobalModel.presetColors[i] === FluTheme.accentColor) {
                                            return false;
                                        }
                                    }
                                    return true;
                                }
                                color: FluTheme.dark ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
                            }
                        }
                    }
                }
            }
        }

        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Animation Effects")
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            FluToggleSwitch {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                checked: FluTheme.animationEnabled
                text: checked ? qsTr("On") : qsTr("Off")
                textRight: false
                onClicked: {
                    FluTheme.animationEnabled = checked;
                    SettingsManager.saveAnimationEnabled(FluTheme.animationEnabled);
                }
            }
        }

        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Transparency Effects")
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            FluToggleSwitch {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                checked: FluTheme.blurBehindWindowEnabled
                text: checked ? qsTr("On") : qsTr("Off")
                textRight: false
                onClicked: {
                    FluTheme.blurBehindWindowEnabled = checked;
                    SettingsManager.saveBlurBehindWindowEnabled(FluTheme.blurBehindWindowEnabled);
                }
            }
        }

        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Use Native Text Rendering")
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            FluToggleSwitch {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                checked: FluTheme.nativeText
                text: checked ? qsTr("On") : qsTr("Off")
                textRight: false
                onClicked: {
                    FluTheme.nativeText = checked;
                    SettingsManager.saveNativeTextEnabled(FluTheme.nativeText);
                }
            }
        }

        /* Localization */
        FluText {
            text: qsTr("Localization")
            font: FluTextStyle.BodyStrong
            Layout.topMargin: 15
            Layout.bottomMargin: 5
        }

        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Language")
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            MyFluComboBox {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: Math.max(200, implicitWidth)
                valueRole: "code"
                textRole: "name"
                onActivated: {
                    if (GlobalModel.language !== currentValue) {
                        GlobalModel.language = currentValue;
                        SettingsManager.saveLanguage(GlobalModel.language);
                    }
                }
                Component.onCompleted: {
                    currentIndex = indexOfValue(GlobalModel.language);
                }
                model: SettingsManager.supportedLanguages
            }
        }

        /* About */
        FluText {
            text: qsTr("About")
            font: FluTextStyle.BodyStrong
            Layout.topMargin: 15
            Layout.bottomMargin: 5
        }

        MyFluExpander {
            Layout.fillWidth: true
            headerHeight: 70
            contentHeight: about_expander_content_container.implicitHeight
            expand: false
            headerDelegate: Component {
                Item {
                    RowLayout {
                        spacing: 16
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }

                        FluImage {
                            width: 36
                            height: 36
                            sourceSize.width: 36
                            sourceSize.height: 36
                            source: "qrc:/resources/images/icons/logo.svg"
                        }

                        ColumnLayout {
                            spacing: 4
                            FluText {
                                text: qsTr("BLE Helper")
                            }
                            FluText {
                                text: ApplicationInfo.versionName
                                font.pixelSize: 12
                                textColor: FluTheme.fontSecondaryColor
                            }
                        }
                    }

                    FluEvent {
                        name: "checkUpdateFinish"
                        onTriggered: {
                            check_update_button.loading = false;
                        }
                    }

                    FluLoadingButton {
                        id: check_update_button
                        text: qsTr("Check for Updates")
                        anchors {
                            right: parent.right
                            rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                            loading = true;
                            FluEventBus.post("checkForUpdates");
                        }
                    }
                }
            }

            content: Item {
                anchors.fill: parent

                ColumnLayout {
                    id: about_expander_content_container
                    spacing: 0
                    anchors.fill: parent

                    FluText {
                        Layout.topMargin: 16
                        Layout.leftMargin: 16
                        text: qsTr("Author: ") + ApplicationInfo.author
                        font.pixelSize: 12
                    }

                    FluText {
                        Layout.topMargin: 8
                        Layout.leftMargin: 16
                        text: qsTr("Built on: ") + ApplicationInfo.buildDateTime
                        font.pixelSize: 12
                    }

                    RowLayout {
                        Layout.leftMargin: 16

                        FluText {
                            text: qsTr("From revision: ")
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignVCenter
                        }

                        MyFluTextButton {
                            Layout.leftMargin: -10
                            Layout.alignment: Qt.AlignVCenter
                            text: ApplicationInfo.versionHash
                            font.pixelSize: 12
                            onClicked: {
                                Qt.openUrlExternally("https://github.com/lucky9loogn/BleHelper/commit/" + ApplicationInfo.versionHash);
                            }
                        }
                    }

                    FluDivider {
                        Layout.topMargin: 5
                        Layout.fillWidth: true
                        orientation: Qt.Horizontal
                    }

                    MyFluTextButton {
                        Layout.topMargin: 5
                        Layout.leftMargin: 10
                        text: qsTr("Check out this project on GitHub")
                        font.pixelSize: 12
                        onClicked: {
                            Qt.openUrlExternally("https://github.com/lucky9loogn/BleHelper");
                        }
                    }

                    FluDivider {
                        Layout.topMargin: 5
                        Layout.fillWidth: true
                        orientation: Qt.Horizontal
                    }

                    FluText {
                        Layout.topMargin: 16
                        Layout.leftMargin: 16
                        text: qsTr("Dependencies & References")
                        font.pixelSize: 12
                    }

                    MyFluTextButton {
                        Layout.topMargin: 5
                        Layout.bottomMargin: 10
                        Layout.leftMargin: 10
                        text: "FluentUI"
                        font.pixelSize: 12
                        onClicked: {
                            Qt.openUrlExternally("https://github.com/zhuzichu520/FluentUI");
                        }
                    }
                }
            }
        }
    }
}
