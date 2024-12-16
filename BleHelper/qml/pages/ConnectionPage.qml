import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../components"
import "../controls"

FluPage {
    id: page
    padding: 0
    title: qsTr("Connection")

    RenameAttributePopup {
        id: attribute_rename_popup
        onSaveButtonClicked: function (attributeUuid, newName, attributeType, attributeInfo) {
            ClientManager.renameAttribute(attributeInfo, newName);
        }
    }

    FluFrame {
        id: connected_device_info_container
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 16
            rightMargin: 16
            topMargin: 16
        }
        height: 70
        padding: 16

        ColumnLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            spacing: 2

            FluText {
                text: {
                    if (ClientManager.connectedDeviceInfo) {
                        return ClientManager.connectedDeviceInfo.name;
                    }
                    return "";
                }
                color: FluTheme.primaryColor
            }

            FluText {
                text: {
                    if (ClientManager.connectedDeviceInfo) {
                        return ClientManager.connectedDeviceInfo.address;
                    }
                    return "";
                }
                color: FluColors.Grey120
            }
        }

        FluButton {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            text: qsTr("Disconnect")
            onClicked: {
                showSuccess(qsTr("Disconnect"));
                ClientManager.disconnectFromDevice();
            }
        }
    }

    FluText {
        id: subtitle_text
        anchors {
            left: connected_device_info_container.left
            top: connected_device_info_container.bottom
            topMargin: 35
        }
        text: qsTr("Services & Characteristics & Descriptors")
        font: FluTextStyle.BodyStrong
    }

    ListView {
        anchors {
            left: parent.left
            right: parent.right
            top: subtitle_text.bottom
            bottom: parent.bottom
            topMargin: 5
            bottomMargin: 16
        }
        spacing: 4
        clip: true
        ScrollBar.vertical: FluScrollBar {
            policy: ScrollBar.AsNeeded
        }
        focus: true
        model: ClientManager.services
        delegate: Item {
            required property int index
            required property var modelData

            width: ListView.view.width
            height: service_item.implicitHeight

            MyFluExpander {
                id: service_item

                property ServiceInfo info: modelData
                property string uuid: info ? info.uuid : ""
                property string name: info ? info.name : ""
                property string type: info ? info.type : ""
                property bool canRename: info ? info.canRename && ClientManager.isUuidNameMappingEnabled : false

                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                }
                headerHeight: 70
                headerDelegate: Component {
                    Item {
                        /* Service Layout */
                        ColumnLayout {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                            }
                            spacing: 0

                            MyFluTextButton {
                                Layout.margins: -4
                                verticalPadding: 4
                                horizontalPadding: 4
                                text: service_item.name
                                clickable: service_item.canRename
                                onClicked: {
                                    attribute_rename_popup.showWithInfo(this, service_item.info);
                                }
                            }

                            FluText {
                                text: service_item.uuid
                                color: FluColors.Grey120
                            }

                            FluText {
                                text: service_item.type
                                color: FluColors.Grey120
                            }
                        }
                    }
                }
                contentHeight: characteristics_container.implicitHeight
                content: ColumnLayout {
                    id: characteristics_container
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        id: characteristics_repeater
                        model: ClientManager.characteristics[service_item.uuid]

                        /* Characteristic Layout */
                        ColumnLayout {
                            required property int index
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.leftMargin: 24
                            Layout.rightMargin: 24
                            Layout.topMargin: index === 0 ? 16 : 0
                            Layout.bottomMargin: index === characteristics_repeater.count - 1 ? 16 : 0
                            spacing: 0

                            ColumnLayout {
                                id: characteristic_item

                                property CharacteristicInfo info: modelData
                                property string uuid: info ? info.uuid : ""
                                property string name: info ? info.name : ""
                                property bool canIndicate: info ? info.canIndicate : false
                                property bool canNotify: info ? info.canNotify : false
                                property bool canRead: info ? info.canRead : false
                                property bool canWrite: info ? info.canWrite : false
                                property bool canWriteNoResponse: info ? info.canWriteNoResponse : false
                                property string properties: info ? info.properties : ""
                                property bool canRename: info ? info.canRename && ClientManager.isUuidNameMappingEnabled : false

                                Layout.fillWidth: true
                                spacing: 0

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MyFluTextButton {
                                        Layout.margins: -4
                                        Layout.alignment: Qt.AlignVCenter
                                        verticalPadding: 4
                                        horizontalPadding: 4
                                        text: characteristic_item.name
                                        textColor: FluTheme.fontPrimaryColor
                                        clickable: characteristic_item.canRename
                                        onClicked: {
                                            attribute_rename_popup.showWithInfo(this, characteristic_item.info);
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true // 占位符 将元素推到两侧
                                    }

                                    MyFluIconButton {
                                        Layout.margins: -4
                                        Layout.alignment: Qt.AlignVCenter
                                        display: Button.TextBesideIcon
                                        iconSize: 10
                                        iconSource: MyFluIcon.Indicate
                                        text: qsTr("Indicate")
                                        visible: characteristic_item.canIndicate
                                        onClicked: {
                                            // TODO
                                            console.log("Indicate Characteristic: " + characteristic_item.uuid);
                                        }
                                    }

                                    MyFluIconButton {
                                        Layout.margins: -4
                                        Layout.alignment: Qt.AlignVCenter
                                        display: Button.TextBesideIcon
                                        iconSize: 10
                                        iconSource: MyFluIcon.Notify
                                        text: qsTr("Notify")
                                        visible: characteristic_item.canNotify
                                        onClicked: {
                                            // TODO
                                            console.log("Notify Characteristic: " + characteristic_item.uuid);
                                        }
                                    }

                                    MyFluIconButton {
                                        Layout.margins: -4
                                        Layout.alignment: Qt.AlignVCenter
                                        display: Button.TextBesideIcon
                                        iconSize: 10
                                        iconSource: MyFluIcon.Read
                                        text: qsTr("Read")
                                        visible: characteristic_item.canRead
                                        onClicked: {
                                            // TODO
                                            console.log("Read Characteristic: " + characteristic_item.uuid);
                                        }
                                    }

                                    MyFluIconButton {
                                        Layout.margins: -4
                                        Layout.alignment: Qt.AlignVCenter
                                        display: Button.TextBesideIcon
                                        iconSize: 10
                                        iconSource: MyFluIcon.Write
                                        text: qsTr("Write")
                                        visible: characteristic_item.canWrite || characteristic_item.canWriteNoResponse
                                        onClicked: {
                                            // TODO
                                            console.log("Write Characteristic: " + characteristic_item.uuid);
                                        }
                                    }
                                }

                                FluText {
                                    text: qsTr("UUID: ") + characteristic_item.uuid
                                    color: FluColors.Grey120
                                }

                                FluText {
                                    text: qsTr("Properties: ") + characteristic_item.properties
                                    color: FluColors.Grey120
                                }

                                FluText {
                                    text: "Descriptors: "
                                    color: FluColors.Grey120
                                    visible: descriptors_repeater.count > 0
                                }

                                Repeater {
                                    id: descriptors_repeater
                                    model: ClientManager.descriptors[characteristic_item.uuid]

                                    /* Descriptor Layout */
                                    ColumnLayout {
                                        required property int index
                                        required property var modelData

                                        Layout.fillWidth: true
                                        Layout.topMargin: 4
                                        Layout.leftMargin: 8
                                        spacing: 0

                                        RowLayout {
                                            id: descriptor_item

                                            property DescriptorInfo info: modelData
                                            property string uuid: info ? info.uuid : ""
                                            property string name: info ? info.name : ""

                                            Layout.fillWidth: true
                                            spacing: 8

                                            FluText {
                                                Layout.alignment: Qt.AlignVCenter
                                                text: descriptor_item.name
                                            }

                                            Item {
                                                Layout.fillWidth: true // 占位符 将元素推到两侧
                                            }

                                            MyFluIconButton {
                                                Layout.margins: -4
                                                Layout.alignment: Qt.AlignVCenter
                                                display: Button.TextBesideIcon
                                                iconSize: 10
                                                iconSource: MyFluIcon.Read
                                                text: qsTr("Read")
                                                onClicked: {
                                                    // TODO
                                                    console.log("Read Descriptor: " + descriptor_item.uuid);
                                                }
                                            }
                                        }

                                        FluText {
                                            text: qsTr("UUID: ") + descriptor_item.uuid
                                            color: FluColors.Grey120
                                        }
                                    }
                                }
                            }

                            FluDivider {
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                                Layout.leftMargin: -4
                                Layout.rightMargin: -4
                                orientation: Qt.Horizontal
                                visible: index < characteristics_repeater.count - 1
                            }
                        }
                    }
                }
            }
        }
    }
}
