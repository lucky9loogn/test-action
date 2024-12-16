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
    title: qsTr("Scanner")

    Connections {
        target: ClientManager

        function onRequestPairingSucceeded(devInfo) {
            if (devInfo.isPaired) {
                showSuccess(qsTr("Successfully paired with \"%1\".").arg(devInfo.name));
            } else {
                showSuccess(qsTr("Successfully unpaired with \"%1\".").arg(devInfo.name));
            }
        }

        function onIsDeviceConnectedChanged() {
            if (ClientManager.isDeviceConnected === true) {
                connecting_dialog.close();
            }
        }
    }

    Timer {
        id: start_scan_delay_timer
        interval: 500
        onTriggered: {
            if (ClientManager.isBluetoothOn && !ClientManager.isScanning) {
                ClientManager.startScan();
            }
        }
    }

    Component.onCompleted: {
        if (ClientManager.filteredDevices.length === 0) {
            start_scan_delay_timer.restart();
        }
    }

    FluContentDialog {
        id: bluetooth_disabled_dialog
        title: qsTr("Tip")
        message: qsTr("This application cannot be used without Bluetooth. Please switch Bluetooth ON to continue.")
        buttonFlags: FluContentDialogType.PositiveButton | FluContentDialogType.NegativeButton
        positiveText: qsTr("Turn on Bluetooth")
        negativeText: qsTr("Cancel")
        onPositiveClicked: {
            ClientManager.enableBluetooth();
            start_scan_delay_timer.restart();
        }
    }

    FluContentDialog {
        id: connecting_dialog
        property string device_name: ""
        buttonFlags: FluContentDialogType.NegativeButton
        title: qsTr("Connecting")
        message: qsTr("Connecting to \"%1\"...").arg(device_name)
        negativeText: qsTr("Cancel")
        contentDelegate: Component {
            Item {
                implicitWidth: parent.width
                implicitHeight: 36
                MyFluProgressBar {
                    width: parent.width - 40
                    strokeWidth: 3
                    anchors.centerIn: parent
                }
            }
        }
        onNegativeClicked: {
            ClientManager.disconnectFromDevice();
        }

        function show(name, address) {
            connecting_dialog.device_name = name;
            connecting_dialog.open();
        }
    }

    FluMenu {
        id: device_item_more_menu
        property string address: ""
        property string name: ""
        property bool isFavorite: false
        property bool isPaired: false
        width: implicitWidth
        height: implicitHeight

        FluMenuItem {
            text: device_item_more_menu.isFavorite ? qsTr("Unfavorite") : qsTr("Favorite")
            iconDelegate: MyFluIcon {
                iconSize: 12
                iconSource: device_item_more_menu.isFavorite ? MyFluIcon.Unfavorite : MyFluIcon.Favorite
            }
            iconSpacing: 8
            onTriggered: {
                if (device_item_more_menu.isFavorite) {
                    ClientManager.deleteDeviceFromFavorites(device_item_more_menu.address);
                    showSuccess(qsTr("\"%1\" has been deleted from the favorites.").arg(device_item_more_menu.name));
                } else {
                    ClientManager.insertDeviceToFavorites(device_item_more_menu.address, device_item_more_menu.name);
                    showSuccess(qsTr("\"%1\" has been inserted to the favorites.").arg(device_item_more_menu.name));
                }
            }
        }

        FluMenuItem {
            text: device_item_more_menu.isPaired ? qsTr("Unpair") : qsTr("Pair")
            iconDelegate: MyFluIcon {
                iconSize: 12
                iconSource: device_item_more_menu.isPaired ? MyFluIcon.Unpair : MyFluIcon.Pair
            }
            iconSpacing: 8
            onTriggered: {
                device_item_more_menu.close();
                if (device_item_more_menu.isPaired) {
                    ClientManager.unpairWithDevice(device_item_more_menu.address);
                } else {
                    ClientManager.pairWithDevice(device_item_more_menu.address);
                }
            }
        }

        function show(address, name, isFavorite, isPaired) {
            device_item_more_menu.address = address;
            device_item_more_menu.name = name;
            device_item_more_menu.isFavorite = isFavorite;
            device_item_more_menu.isPaired = isPaired;
            device_item_more_menu.popup();
        }
    }

    MyFluPopup {
        id: filter_popup
        height: implicitHeight
        width: implicitWidth
        spacing: 0
        parent: filter_button
        x: parent.width - width
        y: parent.height + 5

        onOpened: {
            // Popup 不会每次都重新实例化（即不会重新创建其内容）
            filter_by_name_text_box.text = ClientManager.filterParams.name;
            filter_by_address_text_box.text = ClientManager.filterParams.address;
            filter_by_rssi_slider.value = ClientManager.filterParams.rssiValue;
            filter_is_only_favourite_check_box.checked = ClientManager.filterParams.isOnlyFavourite;
            filter_is_only_connected_check_box.checked = ClientManager.filterParams.isOnlyConnected;
            filter_is_only_paired_check_box.checked = ClientManager.filterParams.isOnlyPaired;
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            /* 标题 清除按钮 */
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8

                FluText {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Filter")
                }

                Item {
                    Layout.fillWidth: true // 占位符，用于推开两侧的元素
                }

                FluTextButton {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Clear")
                    onClicked: {
                        filter_by_name_text_box.text = "";
                        filter_by_address_text_box.text = "";
                        filter_by_rssi_slider.value = filter_by_rssi_slider.from;
                        filter_is_only_favourite_check_box.checked = false;
                        filter_is_only_connected_check_box.checked = false;
                        filter_is_only_paired_check_box.checked = false;
                    }
                }
            }

            FluDivider {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }

            /* 过滤项目 */
            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8

                columns: 4
                rows: 4
                rowSpacing: 8
                columnSpacing: 16

                MyFluIcon {
                    iconSize: 16
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    iconSource: MyFluIcon.DeviceName
                }

                FluTextBox {
                    id: filter_by_name_text_box
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.columnSpan: 3
                    placeholderText: qsTr("Filter by name")
                }

                MyFluIcon {
                    iconSize: 16
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    iconSource: MyFluIcon.DeviceAddress
                }

                FluTextBox {
                    id: filter_by_address_text_box
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.columnSpan: 3
                    placeholderText: qsTr("Filter by address")
                }

                MyFluIcon {
                    iconSize: 16
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    iconSource: MyFluIcon.DeviceRssi
                }

                FluSlider {
                    id: filter_by_rssi_slider
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.columnSpan: 2
                    tooltipEnabled: false
                    from: -130
                    to: 0
                    padding: 0
                }

                Item {
                    Layout.fillHeight: true
                    Layout.leftMargin: 4
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    width: 72

                    FluText {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                        }
                        text: qsTr("≥")
                    }

                    FluText {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                        }
                        text: filter_by_rssi_slider.value + qsTr("dBm")
                    }
                }

                MyFluIcon {
                    iconSize: 16
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    iconSource: MyFluIcon.State
                }

                FluCheckBox {
                    id: filter_is_only_favourite_check_box
                    checked: ClientManager.filterParams.isOnlyFavourite
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.fillWidth: true
                    text: qsTr("Favorites")
                }

                FluCheckBox {
                    id: filter_is_only_connected_check_box
                    checked: ClientManager.filterParams.isOnlyConnected
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    text: qsTr("Connected")
                }

                FluCheckBox {
                    id: filter_is_only_paired_check_box
                    checked: ClientManager.filterParams.isOnlyPaired
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.fillWidth: true
                    text: qsTr("Paired")
                }
            }

            /* 取消 应用按钮 */
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                spacing: 24

                Item {
                    Layout.fillWidth: true // 占位符推送按钮到右边
                }

                FluTextButton {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Cancel")
                    onClicked: {
                        filter_popup.close();
                    }
                }

                FluFilledButton {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Apply")
                    onClicked: {
                        filter_popup.close();
                        ClientManager.filterParams.name = filter_by_name_text_box.text;
                        ClientManager.filterParams.address = filter_by_address_text_box.text;
                        ClientManager.filterParams.rssiValue = filter_by_rssi_slider.value;
                        ClientManager.filterParams.isOnlyFavourite = filter_is_only_favourite_check_box.checked;
                        ClientManager.filterParams.isOnlyConnected = filter_is_only_connected_check_box.checked;
                        ClientManager.filterParams.isOnlyPaired = filter_is_only_paired_check_box.checked;
                        ClientManager.updateFilteredDevices();
                    }
                }
            }
        }
    }

    FluFrame {
        id: bluetooth_control_container
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

        FluIcon {
            id: bluetooth_icon
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            iconSource: FluentIcons.Bluetooth
            iconSize: 20
            padding: 4
        }

        FluText {
            anchors {
                left: bluetooth_icon.right
                verticalCenter: parent.verticalCenter
                leftMargin: 16
            }
            text: qsTr("Bluetooth")
        }

        FluToggleSwitch {
            property bool isBluetoothOn: ClientManager.isBluetoothOn
            onIsBluetoothOnChanged: {
                checked = isBluetoothOn;
            }
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            checked: isBluetoothOn
            onClicked: {
                if (checked) {
                    ClientManager.enableBluetooth();
                } else {
                    ClientManager.disableBluetooth();
                }
            }
            text: isBluetoothOn ? qsTr("On") : qsTr("Off")
            textRight: false
        }
    }

    FluFrame {
        id: find_device_container
        anchors {
            left: parent.left
            right: parent.right
            top: bluetooth_control_container.bottom
            leftMargin: 16
            rightMargin: 16
            topMargin: 4
        }
        height: 70
        padding: 16

        FluIcon {
            id: search_icon
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            iconSource: FluentIcons.Search
            iconSize: 20
            padding: 4
        }

        FluText {
            id: find_device_text
            anchors {
                left: search_icon.right
                verticalCenter: parent.verticalCenter
                leftMargin: 16
            }
            text: qsTr("Find devices")
        }

        FluProgressRing {
            anchors {
                left: find_device_text.right
                verticalCenter: parent.verticalCenter
                leftMargin: 8
            }
            width: 14
            height: 14
            strokeWidth: 2.5
            visible: ClientManager.isScanning
        }

        FluFilledButton {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            text: {
                if (ClientManager.isScanning) {
                    qsTr("Stop Scanning");
                } else {
                    qsTr("Start Scanning");
                }
            }
            onClicked: {
                if (ClientManager.isBluetoothOn === false) {
                    bluetooth_disabled_dialog.open();
                    return;
                }
                if (ClientManager.isScanning) {
                    ClientManager.stopScan();
                } else {
                    ClientManager.startScan();
                }
            }
        }
    }

    RowLayout {
        id: subtitle_filter_sort_container
        anchors {
            top: find_device_container.bottom
            left: parent.left
            right: parent.right
            topMargin: 30
            rightMargin: 16
            leftMargin: 16
        }

        FluText {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            text: qsTr("Devices")
            font: FluTextStyle.BodyStrong
        }

        Row {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 4

            MyFluIconButton {
                id: filter_button
                verticalPadding: 4
                horizontalPadding: 4
                iconSize: 12
                iconSource: MyFluIcon.Filter
                text: qsTr("Filter")
                display: Button.TextBesideIcon
                onClicked: {
                    filter_popup.open();
                }
            }

            MyFluIconButton {
                verticalPadding: 4
                horizontalPadding: 4
                iconSize: 12
                iconSource: MyFluIcon.DescendingSort
                text: qsTr("Sort by RSSI")
                display: Button.TextBesideIcon
                onClicked: {
                    ClientManager.sortByRssi();
                    showSuccess(qsTr("Sort by RSSI in descending order."));
                }
            }
        }
    }

    ListView {
        anchors {
            left: parent.left
            right: parent.right
            top: subtitle_filter_sort_container.bottom
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
        model: ClientManager.filteredDevices
        delegate: Item {
            required property int index
            required property var modelData

            width: ListView.view.width
            height: 70

            FluFrame {
                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: {
                        if (device_item_mouse_area.containsMouse) {
                            return FluTheme.itemHoverColor;
                        }
                        return FluTheme.itemNormalColor;
                    }
                    Behavior on color {
                        enabled: FluTheme.animationEnabled
                        ColorAnimation {
                            duration: 167
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    id: device_item_mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: modelData.isConnected
                    onClicked: {
                        ClientManager.isDeviceConnectedChanged();
                    }
                }

                RowLayout {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 16
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

                        RowLayout {
                            spacing: 4

                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                text: modelData.address
                                color: FluColors.Grey120
                            }

                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 8
                                orientation: Qt.Vertical
                            }

                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                text: modelData.rssi + qsTr(" dBm")
                                color: FluColors.Grey120
                            }

                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 8
                                orientation: Qt.Vertical
                                visible: modelData.isFavorite
                            }

                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                text: qsTr("Favorited")
                                color: FluColors.Grey120
                                visible: modelData.isFavorite
                            }

                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 8
                                orientation: Qt.Vertical
                                visible: modelData.isConnected
                            }

                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                text: qsTr("Connected")
                                color: FluColors.Grey120
                                visible: modelData.isConnected
                            }

                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 8
                                orientation: Qt.Vertical
                                visible: modelData.isPaired
                            }

                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                text: qsTr("Paired")
                                color: FluColors.Grey120
                                visible: modelData.isPaired
                            }
                        }
                    }
                }

                RowLayout {
                    spacing: 4
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 16
                    }

                    FluButton {
                        text: modelData.isConnected ? qsTr("Disconnect") : qsTr("Connect")
                        onClicked: {
                            if (modelData.isConnected) {
                                ClientManager.disconnectFromDevice();
                                showSuccess(qsTr("Disconnect"));
                            } else {
                                connecting_dialog.show(modelData.name, modelData.address);
                                ClientManager.connectToDevice(modelData.address);
                            }
                        }
                    }

                    FluIconButton {
                        iconSource: FluentIcons.More
                        iconSize: 16
                        text: qsTr("More Options")
                        onClicked: {
                            device_item_more_menu.show(modelData.address, modelData.name, modelData.isFavorite, modelData.isPaired);
                        }
                    }
                }
            }
        }
    }
}
