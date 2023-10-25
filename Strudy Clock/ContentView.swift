//
//  ContentView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI

enum TabIndex {
    case Honw
    case Setting
    case Statistic
}

struct ContentView: View {
    
    @State var tabIndex: TabIndex = .Honw
    
    var body: some View {
        TabView(selection: $tabIndex,
                content:  {
            StatisticView().tag(TabIndex.Statistic)
            Home().tag(TabIndex.Honw)
            SettingView().tag(TabIndex.Setting)
        })
        .tabViewStyle(.page)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
