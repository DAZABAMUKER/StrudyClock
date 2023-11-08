//
//  AppIntent.swift
//  StrudyWidget
//
//  Created by 안병욱 on 11/7/23.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Happy", default: "😃")
    var favoriteEmoji: String
}
