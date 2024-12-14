pragma Singleton

import QtQuick
import FluentUI

QtObject {
    property int navigationViewType: SettingsManager.navigationViewType()
    property string language: SettingsManager.language()
    property var presetColors: [FluColors.Yellow, FluColors.Orange, FluColors.Red, FluColors.Magenta, FluColors.Purple, FluColors.Blue, FluColors.Teal, FluColors.Green]

    function createAccentColor(color) {
        for (var i = 0; i < GlobalModel.presetColors.length; i++) {
            if (GlobalModel.presetColors[i].normal === color) {
                return GlobalModel.presetColors[i];
            }
        }
        return FluColors.createAccentColor(color);
    }
}
