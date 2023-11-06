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
    @AppStorage("darkMode") var darkMode: String = "자동"
    //private let adViewControllerRepresentable = AdViewControllerRepresentable()
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        ZStack{
            if darkMode == "다크모드" {
                VStack{}
                    .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
            } else if darkMode == "라이트 모드" {
                VStack{}
                    .preferredColorScheme(.light)
            } else {}
            TabView(selection: $tabIndex,
                    content:  {
                StatisticView().tag(TabIndex.Statistic)
                Home().tag(TabIndex.Honw)
                SettingView().tag(TabIndex.Setting)
            })
            .tabViewStyle(.page)
        }
        
    }
}

#Preview {
    ContentView()
}
