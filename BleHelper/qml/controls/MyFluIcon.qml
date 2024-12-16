import QtQuick
import QtQuick.Controls

import FluentUI

Text {
    id: control
    enum Icon {
        Scan = 65,
        Details,
        Filter,
        DescendingSort,
        AscendingSort,
        Pair,
        Unpair,
        DeviceName,
        DeviceAddress,
        DeviceRssi,
        State,
        Client,
        Server,
        Read,
        Write,
        Notify,
        Indicate,
        Favorite,
        Unfavorite
    }

    property int iconSource
    property int iconSize: 24
    property color iconColor: {
        if (FluTheme.dark) {
            if (!enabled) {
                return Qt.rgba(130 / 255, 130 / 255, 130 / 255, 1);
            }
            return Qt.rgba(1, 1, 1, 1);
        } else {
            if (!enabled) {
                return Qt.rgba(161 / 255, 161 / 255, 161 / 255, 1);
            }
            return Qt.rgba(0, 0, 0, 1);
        }
    }
    font.family: font_loader.name
    font.pixelSize: iconSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: iconColor
    text: (String.fromCharCode(iconSource).toString(16))
    opacity: iconSource > 0
    FontLoader {
        id: font_loader
        source: "qrc:/resources/fonts/BleHelperIcons.ttf"
    }
}
