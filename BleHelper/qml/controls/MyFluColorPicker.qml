import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Window

import FluentUI

Button {
    id: control
    width: 36
    height: 36
    implicitWidth: width
    implicitHeight: height
    property real dialogWidth: 335
    property real dialogHeight: 475
    property bool isMoreButtonVisible: true
    property bool isColorSliderVisible: true
    property bool isColorChannelTextInputVisible: true
    property bool isHexInputVisible: true
    property bool isAlphaEnabled: true
    property bool isAlphaSliderVisible: true
    property bool isAlphaTextInputVisible: true
    property color current: Qt.rgba(1, 1, 1, 1)
    signal accepted
    property int colorHandleRadius: 8
    property string cancelText: qsTr("Cancel")
    property string okText: qsTr("OK")
    property string titleText: qsTr("Color Picker")
    property string redText: qsTr("Red")
    property string greenText: qsTr("Green")
    property string blueText: qsTr("Blue")
    property string hueText: qsTr("Hue")
    property string saturationText: qsTr("Saturation")
    property string valueText: qsTr("Value")
    property string opacityText: qsTr("Opacity")
    property string moreText: qsTr("More")
    property string lessText: qsTr("Less")
    background: Rectangle {
        id: layout_color
        radius: 5
        color: "#00000000"
        border.color: {
            if (hovered) {
                return FluTheme.primaryColor;
            }
            if (FluTheme.dark) {
                return Qt.rgba(100 / 255, 100 / 255, 100 / 255, 1);
            }
            return Qt.rgba(200 / 255, 200 / 255, 200 / 255, 1);
        }
        border.width: 1
        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 5
            color: control.current
        }
    }
    contentItem: Item {}
    onClicked: {
        color_dialog.open();
    }
    FluPopup {
        id: color_dialog
        implicitWidth: control.dialogWidth
        implicitHeight: control.dialogHeight
        closePolicy: Popup.CloseOnEscape
        onOpened: {
            layout_color_hue.updateColorText(current);
            if (!control.isAlphaEnabled) {
                text_box_alpha.text = 100;
            }
            text_box_red_hue.textEdited();
            text_box_green_saturation.textEdited();
            text_box_blue_value.textEdited();
            text_box_alpha.textEdited();
        }
        onClosed: {
            combo_box_color_spec.currentIndex = 0;
            more_button.checked = false;
            text_box_hex.focus = false;
        }

        Rectangle {
            id: layout_actions
            width: parent.width
            height: 60
            radius: 5
            z: 999
            anchors.bottom: parent.bottom
            color: {
                if (FluTheme.dark) {
                    return Qt.rgba(32 / 255, 32 / 255, 32 / 255, 1);
                }
                return Qt.rgba(243 / 255, 243 / 255, 243 / 255, 1);
            }
            RowLayout {
                anchors {
                    centerIn: parent
                    margins: spacing
                    fill: parent
                }
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    FluButton {
                        text: control.cancelText
                        width: parent.width
                        anchors.centerIn: parent
                        onClicked: {
                            color_dialog.close();
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    FluFilledButton {
                        text: control.okText
                        width: parent.width
                        anchors.centerIn: parent
                        onClicked: {
                            current = layout_color_hue.colorValue;
                            control.accepted();
                            color_dialog.close();
                        }
                    }
                }
            }
        }
        contentItem: Flickable {
            implicitWidth: parent.width
            implicitHeight: Math.min(layout_content.height, 560, color_dialog.height)
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: layout_content.height + 70
            contentWidth: width
            clip: true
            ScrollBar.vertical: FluScrollBar {}
            Item {
                id: layout_content
                width: parent.width
                height: childrenRect.height

                FluText {
                    id: text_titile
                    font: FluTextStyle.Subtitle
                    text: control.titleText
                    anchors {
                        left: parent.left
                        top: parent.top
                        leftMargin: 20
                        topMargin: 20
                    }
                }

                Item {
                    id: layout_sb
                    width: 256
                    height: 256
                    anchors {
                        left: parent.left
                        top: text_titile.bottom
                        leftMargin: 12
                    }

                    FluClip {
                        id: layout_color_hue
                        property color colorValue
                        property real xPercent: pickerCursor.x / width
                        property real yPercent: pickerCursor.y / height
                        property real blackPercent: blackCursor.x / (layout_black.width - 12)
                        property real opacityPercent: opacityCursor.x / (layout_opacity.width - 12)
                        property color opacityColor: {
                            var c = blackColor;
                            c = Qt.rgba(c.r, c.g, c.b, opacityPercent);
                            return c;
                        }
                        onOpacityColorChanged: {
                            layout_color_hue.colorValue = opacityColor;
                            updateColorText(opacityColor);
                        }
                        function updateColorText(color) {
                            if (combo_box_color_spec.currentValue === "RGB") {
                                text_box_red_hue.text = String(Math.round(color.r * 255));
                                text_box_green_saturation.text = String(Math.round(color.g * 255));
                                text_box_blue_value.text = String(Math.round(color.b * 255));
                            } else if (combo_box_color_spec.currentValue === "HSV") {
                                text_box_red_hue.text = String(Math.round(Math.abs(color.hsvHue * 359)));
                                text_box_green_saturation.text = String(Math.round(color.hsvSaturation * 100));
                                text_box_blue_value.text = String(Math.round(color.hsvValue * 100));
                            }
                            text_box_alpha.text = String(Math.round(color.a * 100));
                            var colorString = color.toString().slice(1);
                            if (control.isAlphaEnabled && color.a === 1) {
                                colorString = "FF" + colorString;
                            }
                            if (!text_box_hex.activeFocus) {
                                text_box_hex.text = colorString.toUpperCase();
                            }
                        }
                        property color blackColor: {
                            var c = whiteColor;
                            c = Qt.rgba(c.r * blackPercent, c.g * blackPercent, c.b * blackPercent, 1);
                            return c;
                        }
                        property color hueColor: {
                            var v = 1.0 - xPercent;
                            var c;
                            if (0.0 <= v && v < 0.16) {
                                c = Qt.rgba(1.0, 0.0, v / 0.16, 1.0);
                            } else if (0.16 <= v && v < 0.33) {
                                c = Qt.rgba(1.0 - (v - 0.16) / 0.17, 0.0, 1.0, 1.0);
                            } else if (0.33 <= v && v < 0.5) {
                                c = Qt.rgba(0.0, ((v - 0.33) / 0.17), 1.0, 1.0);
                            } else if (0.5 <= v && v < 0.76) {
                                c = Qt.rgba(0.0, 1.0, 1.0 - (v - 0.5) / 0.26, 1.0);
                            } else if (0.76 <= v && v < 0.85) {
                                c = Qt.rgba((v - 0.76) / 0.09, 1.0, 0.0, 1.0);
                            } else if (0.85 <= v && v <= 1.0) {
                                c = Qt.rgba(1.0, 1.0 - (v - 0.85) / 0.15, 0.0, 1.0);
                            } else {
                                c = Qt.rgba(1.0, 0.0, 0.0, 1.0);
                            }
                            return c;
                        }
                        property color whiteColor: {
                            var c = hueColor;
                            c = Qt.rgba((1 - c.r) * yPercent + c.r, (1 - c.g) * yPercent + c.g, (1 - c.b) * yPercent + c.b, 1.0);
                            return c;
                        }
                        function updateColor() {
                            var r;
                            var g;
                            var b;
                            var opacityPercent = Number(text_box_alpha.text) / 100;
                            if (combo_box_color_spec.currentValue === "RGB") {
                                r = Number(text_box_red_hue.text) / 255;
                                g = Number(text_box_green_saturation.text) / 255;
                                b = Number(text_box_blue_value.text) / 255;
                            } else if (combo_box_color_spec.currentValue === "HSV") {
                                // hsv2rgb
                                var h = Number(text_box_red_hue.text) / 359;
                                var s = Number(text_box_green_saturation.text) / 100;
                                var v = Number(text_box_blue_value.text) / 100;
                                var c = Qt.hsva(h, s, v, opacityPercent);
                                r = c.r;
                                g = c.g;
                                b = c.b;
                            }
                            var blackPercent = Math.max(r, g, b);
                            r = r / blackPercent;
                            g = g / blackPercent;
                            b = b / blackPercent;
                            var yPercent = Math.min(r, g, b);
                            if (r === g && r === b) {
                                r = 1;
                                b = 1;
                                g = 1;
                            } else {
                                r = (yPercent - r) / (yPercent - 1);
                                g = (yPercent - g) / (yPercent - 1);
                                b = (yPercent - b) / (yPercent - 1);
                            }
                            var xPercent;
                            if (r === 1.0 && g === 0.0 && b <= 1.0) {
                                if (b === 0.0) {
                                    xPercent = 0;
                                } else {
                                    xPercent = 1.0 - b * 0.16;
                                }
                            } else if (r <= 1.0 && g === 0.0 && b === 1.0) {
                                xPercent = 1.0 - (1.0 - r) * 0.17 - 0.16;
                            } else if (r === 0.0 && g <= 1.0 && b === 1.0) {
                                xPercent = 1.0 - (g * 0.17 + 0.33);
                            } else if (r === 0.0 && g === 1.0 && b <= 1.0) {
                                xPercent = 1.0 - (1.0 - b) * 0.26 - 0.5;
                            } else if (r <= 1.0 && g === 1.0 && b === 0.0) {
                                xPercent = 1.0 - (r * 0.09 + 0.76);
                            } else if (r === 1.0 && g <= 1.0 && b === 0.0) {
                                xPercent = 1.0 - (1.0 - g) * 0.15 - 0.85;
                            } else {
                                xPercent = 0;
                            }
                            pickerCursor.x = xPercent * width;
                            pickerCursor.y = yPercent * height;
                            blackCursor.x = blackPercent * (layout_black.width - 12);
                            opacityCursor.x = opacityPercent * (layout_opacity.width - 12);
                        }
                        radius: [4, 4, 4, 4]
                        x: colorHandleRadius
                        y: colorHandleRadius
                        width: parent.width - 2 * colorHandleRadius
                        height: parent.height - 2 * colorHandleRadius

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop {
                                    position: 0.0
                                    color: "#FF0000"
                                }
                                GradientStop {
                                    position: 0.16
                                    color: "#FFFF00"
                                }
                                GradientStop {
                                    position: 0.33
                                    color: "#00FF00"
                                }
                                GradientStop {
                                    position: 0.5
                                    color: "#00FFFF"
                                }
                                GradientStop {
                                    position: 0.76
                                    color: "#0000FF"
                                }
                                GradientStop {
                                    position: 0.85
                                    color: "#FF00FF"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#FF0000"
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop {
                                    position: 1.0
                                    color: "#FFFFFFFF"
                                }
                                GradientStop {
                                    position: 0.0
                                    color: "#00000000"
                                }
                            }
                        }

                        Rectangle {
                            radius: 4
                            anchors.fill: parent
                            border.width: 1
                            border.color: FluTheme.dividerColor
                            color: "#00000000"
                        }
                    }

                    Item {
                        id: pickerCursor
                        Rectangle {
                            width: colorHandleRadius * 2
                            height: colorHandleRadius * 2
                            radius: colorHandleRadius
                            border.color: "black"
                            border.width: 2
                            color: "transparent"
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                border.color: "white"
                                border.width: 2
                                radius: width / 2
                                color: "transparent"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        x: colorHandleRadius
                        y: colorHandleRadius
                        preventStealing: true
                        function handleMouse(mouse) {
                            if (mouse.buttons & Qt.LeftButton) {
                                text_box_red_hue.focus = false;
                                text_box_green_saturation.focus = false;
                                text_box_blue_value.focus = false;
                                text_box_alpha.focus = false;
                                text_box_hex.focus = false;
                                pickerCursor.x = Math.max(0, Math.min(mouse.x - colorHandleRadius, width - 2 * colorHandleRadius));
                                pickerCursor.y = Math.max(0, Math.min(mouse.y - colorHandleRadius, height - 2 * colorHandleRadius));
                            }
                        }
                        onPositionChanged: mouse => handleMouse(mouse)
                        onPressed: mouse => handleMouse(mouse)
                    }
                }
                FluClip {
                    width: 44
                    anchors {
                        top: layout_sb.top
                        bottom: layout_sb.bottom
                        left: layout_sb.right
                        topMargin: colorHandleRadius
                        bottomMargin: colorHandleRadius
                        leftMargin: 4
                    }
                    radius: [4, 4, 4, 4]
                    Grid {
                        id: target_grid_color
                        padding: 0
                        anchors.fill: parent
                        rows: height / 5 + 1
                        columns: width / 5 + 1
                        Repeater {
                            model: (target_grid_color.columns - 1) * (target_grid_color.rows - 1)
                            Rectangle {
                                width: 6
                                height: 6
                                color: (model.index % 2 == 0) ? "gray" : "white"
                            }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        color: layout_color_hue.colorValue
                        radius: 4
                        border.width: 1
                        border.color: FluTheme.dividerColor
                    }
                }

                ColumnLayout {
                    anchors {
                        left: parent.left
                        leftMargin: 18
                        right: parent.right
                        rightMargin: 18
                        top: layout_sb.bottom
                        topMargin: 10
                    }
                    spacing: 20

                    Column {
                        id: layout_slider_bar
                        Layout.fillWidth: true
                        visible: control.isColorSliderVisible || (control.isAlphaEnabled && control.isAlphaSliderVisible)
                        spacing: 8

                        Rectangle {
                            id: layout_black
                            visible: control.isColorSliderVisible
                            radius: 6
                            height: 12
                            width: parent.width
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop {
                                    position: 0.0
                                    color: "#FF000000"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: layout_color_hue.hueColor
                                }
                            }
                            Item {
                                id: blackCursor
                                x: layout_black.width - 12
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    border.color: "black"
                                    border.width: 2
                                    color: "transparent"
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        border.color: "white"
                                        border.width: 2
                                        radius: width / 2
                                        color: "transparent"
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                preventStealing: true
                                function handleMouse(mouse) {
                                    if (mouse.buttons & Qt.LeftButton) {
                                        text_box_red_hue.focus = false;
                                        text_box_green_saturation.focus = false;
                                        text_box_blue_value.focus = false;
                                        text_box_alpha.focus = false;
                                        text_box_hex.focus = false;
                                        blackCursor.x = Math.max(0, Math.min(mouse.x - 6, width - 2 * 6));
                                        blackCursor.y = 0;
                                    }
                                }
                                onPositionChanged: mouse => handleMouse(mouse)
                                onPressed: mouse => handleMouse(mouse)
                            }
                        }
                        FluClip {
                            id: layout_opacity
                            visible: control.isAlphaEnabled && control.isAlphaSliderVisible
                            height: 12
                            width: parent.width
                            radius: [6, 6, 6, 6]

                            Grid {
                                id: grid_opacity
                                anchors.fill: parent
                                rows: height / 4
                                columns: width / 4 + 1
                                clip: true
                                Repeater {
                                    model: grid_opacity.columns * grid_opacity.rows
                                    Rectangle {
                                        width: 4
                                        height: 4
                                        color: (model.index % 2 == 0) ? "gray" : "white"
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0.0
                                        color: "#00000000"
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: layout_color_hue.blackColor
                                    }
                                }
                            }

                            Item {
                                id: opacityCursor
                                x: layout_opacity.width - 12
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    border.color: "black"
                                    border.width: 2
                                    color: "transparent"
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        border.color: "white"
                                        border.width: 2
                                        radius: width / 2
                                        color: "transparent"
                                    }
                                }
                            }

                            MouseArea {
                                id: mouse_opacity
                                anchors.fill: parent
                                preventStealing: true
                                function handleMouse(mouse) {
                                    if (mouse.buttons & Qt.LeftButton) {
                                        text_box_red_hue.focus = false;
                                        text_box_green_saturation.focus = false;
                                        text_box_blue_value.focus = false;
                                        text_box_alpha.focus = false;
                                        text_box_hex.focus = false;
                                        opacityCursor.x = Math.max(0, Math.min(mouse.x - 6, width - 2 * 6));
                                        opacityCursor.y = 0;
                                    }
                                }
                                onPositionChanged: mouse => handleMouse(mouse)
                                onPressed: mouse => handleMouse(mouse)
                            }
                        }
                    }

                    Row {
                        id: more_button_container
                        Layout.alignment: Qt.AlignRight
                        visible: control.isMoreButtonVisible
                        spacing: 0
                        FluButton {
                            id: more_button
                            checkable: true
                            anchors.verticalCenter: parent.verticalCenter
                            text: checked ? control.lessText : control.moreText
                            background: Item {}
                            textColor: {
                                if (FluTheme.dark) {
                                    if (pressed) {
                                        return Qt.color("#969696");
                                    }
                                    if (hovered) {
                                        return Qt.color("#CCCCCC");
                                    }
                                    return Qt.rgba(1, 1, 1, 1);
                                } else {
                                    if (pressed) {
                                        return Qt.color("#868686");
                                    }
                                    if (hovered) {
                                        return Qt.color("#5C5C5C");
                                    }
                                    return Qt.rgba(0, 0, 0, 1);
                                }
                            }
                        }

                        FluIcon {
                            iconColor: more_button.textColor
                            anchors.verticalCenter: parent.verticalCenter
                            rotation: more_button.expand ? 0 : 180
                            iconSource: FluentIcons.ChevronUp
                            iconSize: 12
                            Behavior on rotation {
                                enabled: FluTheme.animationEnabled
                                NumberAnimation {
                                    duration: 167
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 5

                        RowLayout {
                            width: parent.width

                            MyFluComboBox {
                                id: combo_box_color_spec
                                visible: {
                                    if (!control.isMoreButtonVisible) {
                                        return control.isColorChannelTextInputVisible;
                                    }
                                    return control.isColorChannelTextInputVisible && more_button.checked;
                                }
                                model: ["RGB", "HSV"]
                                Layout.preferredWidth: 120
                                onCurrentValueChanged: {
                                    layout_color_hue.updateColorText(layout_color_hue.colorValue);
                                }
                            }

                            Item {
                                visible: combo_box_color_spec.visible
                                Layout.fillWidth: true
                            }

                            FluTextBox {
                                id: text_box_hex
                                Layout.preferredWidth: 136
                                visible: {
                                    if (!control.isMoreButtonVisible) {
                                        return control.isHexInputVisible;
                                    }
                                    return control.isHexInputVisible && more_button.checked;
                                }
                                validator: RegularExpressionValidator {
                                    regularExpression: /^[0-9A-Fa-f]{8}$/
                                }
                                leftPadding: 20
                                FluText {
                                    text: "#"
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left
                                        leftMargin: 5
                                    }
                                }
                                onTextEdited: {
                                    if (text !== "") {
                                        var colorString = text_box_hex.text.padStart(8, "0");
                                        var red = parseInt(colorString.substring(2, 4), 16) / 255;
                                        var green = parseInt(colorString.substring(4, 6), 16) / 255;
                                        var blue = parseInt(colorString.substring(6, 8), 16) / 255;
                                        var alpha = 1;
                                        if (control.isAlphaEnabled) {
                                            alpha = parseInt(colorString.substring(0, 2), 16) / 255;
                                        }
                                        var c = Qt.rgba(red, green, blue, alpha);
                                        layout_color_hue.colorValue = c;
                                        layout_color_hue.updateColorText(c);
                                        text_box_red_hue.textEdited();
                                        text_box_green_saturation.textEdited();
                                        text_box_blue_value.textEdited();
                                        text_box_alpha.textEdited();
                                    }
                                }
                            }
                        }

                        Row {
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isColorChannelTextInputVisible;
                                }
                                return control.isColorChannelTextInputVisible && more_button.checked;
                            }
                            spacing: 10
                            FluTextBox {
                                id: text_box_red_hue
                                width: 120
                                validator: RegularExpressionValidator {
                                    regularExpression: {
                                        if (combo_box_color_spec.currentValue === "RGB") {
                                            return /^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$/;
                                        } else if (combo_box_color_spec.currentValue === "HSV") {
                                            return /^(?:[0-9]?[0-9]|[1-2][0-9]{2}|3[0-5][0-9]|359)$/;
                                        }
                                    }
                                }
                                onTextEdited: {
                                    if (text !== "") {
                                        layout_color_hue.updateColor();
                                    }
                                }
                            }
                            FluText {
                                text: {
                                    if (combo_box_color_spec.currentValue === "RGB") {
                                        return control.redText;
                                    } else if (combo_box_color_spec.currentValue === "HSV") {
                                        return control.hueText;
                                    }
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isColorChannelTextInputVisible;
                                }
                                return control.isColorChannelTextInputVisible && more_button.checked;
                            }
                            spacing: 10
                            FluTextBox {
                                id: text_box_green_saturation
                                width: 120
                                validator: RegularExpressionValidator {
                                    regularExpression: {
                                        if (combo_box_color_spec.currentValue === "RGB") {
                                            return /^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$/;
                                        } else if (combo_box_color_spec.currentValue === "HSV") {
                                            return /^(100|[1-9]?\d)$/;
                                        }
                                    }
                                }
                                onTextEdited: {
                                    if (text !== "") {
                                        layout_color_hue.updateColor();
                                    }
                                }
                            }
                            FluText {
                                text: {
                                    if (combo_box_color_spec.currentValue === "RGB") {
                                        return control.greenText;
                                    } else if (combo_box_color_spec.currentValue === "HSV") {
                                        return control.saturationText;
                                    }
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isColorChannelTextInputVisible;
                                }
                                return control.isColorChannelTextInputVisible && more_button.checked;
                            }
                            spacing: 10
                            FluTextBox {
                                id: text_box_blue_value
                                width: 120
                                validator: RegularExpressionValidator {
                                    regularExpression: {
                                        if (combo_box_color_spec.currentValue === "RGB") {
                                            return /^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$/;
                                        } else if (combo_box_color_spec.currentValue === "HSV") {
                                            return /^(100|[1-9]?\d)$/;
                                        }
                                    }
                                }
                                onTextEdited: {
                                    if (text !== "") {
                                        layout_color_hue.updateColor();
                                    }
                                }
                            }
                            FluText {
                                text: {
                                    if (combo_box_color_spec.currentValue === "RGB") {
                                        return control.blueText;
                                    } else if (combo_box_color_spec.currentValue === "HSV") {
                                        return control.valueText;
                                    }
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isAlphaEnabled && control.isAlphaTextInputVisible;
                                }
                                return control.isAlphaEnabled && control.isAlphaTextInputVisible && more_button.checked;
                            }
                            spacing: 10

                            FluTextBox {
                                id: text_box_alpha
                                width: 120
                                validator: RegularExpressionValidator {
                                    regularExpression: /^(100|[1-9]?\d)$/
                                }
                                FluText {
                                    id: text_opacity
                                    text: "%"
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Math.min(text_box_alpha.implicitWidth, text_box_alpha.width) - 38
                                }
                                onTextEdited: {
                                    if (text !== "") {
                                        opacityCursor.x = Number(text) / 100 * (layout_opacity.width - 12);
                                    }
                                }
                            }
                            FluText {
                                text: control.opacityText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
