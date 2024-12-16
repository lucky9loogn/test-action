import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../components"
import "../controls"
import "../models"

MyFluPivot {
    id: pivot
    padding: 0
    headerLeftPadding: 16
    headerRightPadding: 16
    title: qsTr("Manage UUID Dictionary")
    commandBar: FluIconButton {
        id: more_options_button
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        iconSource: FluentIcons.More
        iconSize: 16
        text: qsTr("More Options")
        onClicked: {
            more_options_menu.open();
        }
    }

    FluMenu {
        id: more_options_menu
        parent: pivot.commandBar
        x: parent.width - width
        y: parent.height

        FluMenuItem {
            text: qsTr("Import")
            onClicked: {
                file_dialog.show(FileDialog.OpenFile, function (fileName) {
                    if (ClientManager.importUuidDictionary(fileName)) {
                        ClientManager.refreshAllAttributesName();
                        showSuccess(qsTr("Import succeeded."));
                    } else {
                        showError(qsTr("Import failed."));
                    }
                });
            }
        }

        FluMenuItem {
            text: qsTr("Export")
            onClicked: {
                file_dialog.show(FileDialog.SaveFile, function (fileName) {
                    if (ClientManager.exportUuidDictionary(fileName)) {
                        showSuccess(qsTr("Export succeeded."));
                    } else {
                        showError(qsTr("Export failed."));
                    }
                });
            }
        }

        FluMenuItem {
            text: qsTr("Delete All")
            onClicked: {
                delete_all_alarm_aialog.open();
            }
        }
    }

    FluContentDialog {
        id: delete_all_alarm_aialog
        title: qsTr("Delete")
        message: qsTr("Are you sure to delete all?")
        negativeText: qsTr("Cancel")
        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        positiveText: qsTr("OK")
        onPositiveClicked: {
            ClientManager.deleteAllAttributesFromUuidDictionary(ClientManager.Service | ClientManager.Characteristic);
            ClientManager.refreshAllAttributesName();
        }
    }

    FileDialog {
        id: file_dialog
        property var callback
        property string fileName: ""
        currentFolder: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
        nameFilters: ["Json files (*.json)"]
        fileMode: FileDialog.SaveFile
        onAccepted: {
            file_dialog.callback(FluTools.toLocalPath(selectedFile));
        }
        function show(fileMode, callback) {
            file_dialog.fileMode = fileMode;
            if (fileMode === FileDialog.SaveFile) {
                var date = new Date();
                var locale = Qt.locale(GlobalModel.language.replace('_', '-'));
                var fileName = "uuid_dictionary_" + date.toLocaleString(locale, "yyyyMMddhhmmss");
                file_dialog.selectedFile = currentFolder + "/" + fileName + ".json";
            }
            file_dialog.callback = callback;
            file_dialog.open();
        }
    }

    FluPivotItem {
        title: qsTr("Services")
        contentItem: uuid_dictionary_component
        argument: {
            "model": ClientManager.serviceUuidDictionary,
            "attributeType": ClientManager.Service
        }
    }

    FluPivotItem {
        title: qsTr("Characteristics")
        contentItem: uuid_dictionary_component
        argument: {
            "model": ClientManager.characteristicUuidDictionary,
            "attributeType": ClientManager.Characteristic
        }
    }

    Component {
        id: uuid_dictionary_component
        Item {
            RenameAttributePopup {
                id: attribute_rename_popup
                onSaveButtonClicked: function (attributeUuid, newName, attributeType, attributeInfo) {
                    ClientManager.upsertAttributeToUuidDictionary(attributeUuid, newName, attributeType);
                    ClientManager.refreshAttributeName(attributeUuid, attributeType);
                }
            }

            FluText {
                anchors.centerIn: parent
                text: qsTr("Empty")
                font: FluTextStyle.Title
                visible: argument.model.length === 0
            }

            ListView {
                anchors {
                    fill: parent
                    topMargin: 16
                    bottomMargin: 16
                }
                model: argument.model
                spacing: 4
                clip: true
                ScrollBar.vertical: FluScrollBar {}
                focus: true
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

                        Column {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                            }
                            spacing: 2

                            FluText {
                                text: modelData.name
                            }

                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                text: modelData.uuid
                                color: FluColors.Grey120
                            }
                        }

                        Row {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                            }
                            spacing: 8

                            FluIconButton {
                                iconSource: FluentIcons.Rename
                                iconSize: 16
                                text: qsTr("Rename")
                                onClicked: {
                                    attribute_rename_popup.show(this, modelData.uuid, modelData.name, argument.attributeType);
                                }
                            }

                            FluIconButton {
                                iconSource: FluentIcons.Delete
                                iconSize: 16
                                text: qsTr("Delete")
                                onClicked: {
                                    var uuid = modelData.uuid;
                                    var type = argument.attributeType;
                                    ClientManager.deleteAttributeFromUuidDictionary(uuid, type);
                                    ClientManager.refreshAttributeName(uuid, type);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
