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
                width: Math.max(180, implicitWidth)
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
                width: Math.max(180, implicitWidth)
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
            content: ColumnLayout {
                id: accent_color_expander_content_container
                anchors.fill: parent

                ColumnLayout {
                    Layout.topMargin: 16
                    Layout.bottomMargin: 16

                    spacing: 16

                    RowLayout {
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.fillWidth: true

                        FluText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillWidth: true
                            text: qsTr("Preset Colors")
                        }

                        Row {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            spacing: 4
                            Repeater {
                                model: GlobalModel.presetColors
                                delegate: Rectangle {
                                    width: 30
                                    height: 30
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

                    FluDivider {
                        Layout.fillWidth: true
                        orientation: Qt.Horizontal
                    }

                    RowLayout {
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.fillWidth: true
                        spacing: 12

                        FluText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillWidth: true
                            text: qsTr("Custom Colors")
                        }

                        MyFluColorPicker {
                            id: theme_color_picker
                            Layout.alignment: Qt.AlignVCenter
                            width: 30
                            height: 30
                            enabled: false
                            isAlphaEnabled: false
                            dialogHeight: 465
                            current: FluTheme.accentColor.normal
                            background: Rectangle {
                                radius: 5
                                color: theme_color_picker.current
                                border.color: FluTheme.dividerColor
                            }
                            visible: !GlobalModel.presetColors.includes(FluTheme.accentColor)
                            onAccepted: {
                                FluTheme.accentColor = GlobalModel.createAccentColor(current);
                                SettingsManager.saveAccentNormalColor(current);
                            }
                            FluIcon {
                                anchors.centerIn: parent
                                iconSource: FluentIcons.AcceptMedium
                                iconSize: 16
                                color: FluTheme.dark ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
                            }
                        }

                        FluButton {
                            text: qsTr("View Colors")
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            onClicked: theme_color_picker.clicked()
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
                width: Math.max(180, implicitWidth)
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
                        spacing: 12
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }

                        FluImage {
                            sourceSize.width: 30
                            sourceSize.height: 30
                            source: "qrc:/resources/images/icons/logo.svg"
                        }

                        Column {
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
                        onTriggered: function (arg) {
                            if (arg.status === "success") {
                                check_for_update_success_icon.visible = true;
                            } else {
                                check_for_update_button.enabled = true;
                            }
                            check_for_update_progress_ring.visible = false;
                        }
                    }

                    Item {
                        width: 24
                        height: 24
                        anchors {
                            right: check_for_update_button.left
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }

                        FluProgressRing {
                            id: check_for_update_progress_ring
                            anchors.fill: parent
                            anchors.centerIn: parent
                            strokeWidth: 3
                            visible: false
                            background: Item {}
                        }

                        FluIcon {
                            id: check_for_update_success_icon
                            visible: false
                            anchors.centerIn: parent
                            iconSource: FluentIcons.CheckMark
                        }
                    }

                    FluButton {
                        id: check_for_update_button
                        text: qsTr("Check for Updates")
                        anchors {
                            right: parent.right
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                            check_for_update_button.enabled = false;
                            check_for_update_success_icon.visible = false;
                            check_for_update_progress_ring.visible = true;
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

                    FluDivider {
                        Layout.topMargin: 16
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
