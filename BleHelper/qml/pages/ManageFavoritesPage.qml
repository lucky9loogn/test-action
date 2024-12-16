import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"

FluPage {
    id: page
    padding: 0
    header: Item {
        implicitHeight: 50

        FluText {
            text: qsTr("Manage Favorites")
            font: FluTextStyle.Title
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 16
            }
        }

        FluIconButton {
            id: more_options_button
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 16
            }
            iconSource: FluentIcons.More
            iconSize: 16
            text: qsTr("More Options")
            onClicked: {
                more_options_menu.open();
            }
        }
    }

    FluMenu {
        id: more_options_menu
        parent: more_options_button
        x: parent.width - width
        y: parent.height

        FluMenuItem {
            text: qsTr("Unfavorite All")
            onClicked: {
                alarm_aialog.open();
            }
        }
    }

    FluContentDialog {
        id: alarm_aialog
        title: qsTr("Tip")
        message: qsTr("Are you sure to remove all devices from the favorites?")
        negativeText: qsTr("Cancel")
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        positiveText: qsTr("OK")
        onPositiveClicked: {
            ClientManager.deleteAllDevicesFromFavorites();
        }
    }

    FluText {
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        text: qsTr("No favorite devices found")
        font: FluTextStyle.Title
        visible: ClientManager.favoriteDevices.length === 0
    }

    ListView {
        anchors {
            fill: parent
            topMargin: 16
            bottomMargin: 16
        }
        spacing: 4
        clip: true
        ScrollBar.vertical: FluScrollBar {
            policy: ScrollBar.AsNeeded
        }
        focus: true
        model: ClientManager.favoriteDevices
        delegate: Item {
            required property int index
            required property var modelData

            width: ListView.view.width
            height: 70

            FluFrame {
                padding: 16
                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                }

                RowLayout {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                    }
                    spacing: 16

                    FluIcon {
                        iconSource: FluentIcons.Bluetooth
                        iconSize: 20
                        padding: 4
                    }

                    ColumnLayout {
                        spacing: 2

                        FluText {
                            text: modelData.name
                        }

                        FluText {
                            Layout.alignment: Qt.AlignVCenter
                            text: modelData.address
                            color: FluColors.Grey120
                        }
                    }
                }

                FluIconButton {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }
                    iconDelegate: MyFluIcon {
                        iconSource: MyFluIcon.Unfavorite
                        iconSize: 16
                    }
                    text: qsTr("Unfavorite")
                    onClicked: {
                        ClientManager.deleteDeviceFromFavorites(modelData.address);
                    }
                }
            }
        }
    }
}
