//
//  Strudy_ClockApp.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import GoogleMobileAds

@main
struct Strudy_ClockApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}
