//
//  ContentView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import AVFoundation
import UserNotifications

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
    @StateObject var timers = Timers()
    @Environment(\.scenePhase) var phase
    @State var degree = 3599.0
    @State var selectedSub = String(localized: "과목을 선택하세요")
    @State var over = true
    @State var pauses = true
    @State var settingAngle = 0.0
    @AppStorage("KEY") var selectedBell: String = "cow-bells"
    @AppStorage("mute") var muteModeSwitch: Bool = false
    @State var player: AVAudioPlayer?
    @State var session: AVAudioSession = AVAudioSession.sharedInstance()
    
    func TimeOver() {
        timers.SaveData(subjectOfTimer: self.selectedSub)
        self.over = true
        timers.stop()
        timers.value = 0.0
        
        self.pauses = true
        self.degree = 0.0
        self.settingAngle = 0.0
        self.notify()
        do {
            let asset = NSDataAsset(name: self.selectedBell)
            guard let sound = asset?.data else
            {
                return
            }
            if self.muteModeSwitch {
                self.session = AVAudioSession.sharedInstance()
                try self.session.setCategory(.playback)
            } else {
                self.session = AVAudioSession.sharedInstance()
                try self.session.setCategory(.soloAmbient)
            }
            player = try AVAudioPlayer(data:sound, fileTypeHint:"wav")
            player?.play()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func notify() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "타이머 종료!")
        content.body = String(localized: "타이머가 종료 되었습니다. \n오늘도 열심히 공부하셨군요! 멋져요!")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: "timerOver", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
    
    var body: some View {
        ZStack{

            TabView(selection: $tabIndex,
                    content:  {
                StatisticView().tag(TabIndex.Statistic)
                Home(selectedSub: self.$selectedSub, degree: self.$degree, over: self.$over, pauses: self.$pauses, settingAngle: self.$settingAngle, timers: self.timers, player: self.$player).tag(TabIndex.Honw)
                //Home(degree: self.$degree).tag(TabIndex.Honw)
                SettingView().tag(TabIndex.Setting)
            })
            .tabViewStyle(.page)
            .preferredColorScheme(self.darkMode == String(localized: "다크모드") ? .dark : self.darkMode == String(localized: "라이트모드") ? .light : self.colorscheme)
            .onAppear(){
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (_, _) in
                    
                }
            }
//            .onChange(of: phase) { phaseStatus in
//                if phaseStatus == .background {
//                    timers.backProcess()
//                } else {
//                    timers.backgroundTime()
//                }
//            }
//            if self.muteModeSwitch {
//                ZStack{}.onAppear(){
//                    do {
//                        try self.session.setCategory(.playback)
//                    } catch(let error) {
//                        print(error.localizedDescription)
//                    }
//                }
//            } else {
//                ZStack{}.onAppear(){
//                    do {
//                        try self.session.setCategory(.soloAmbient)
//                    } catch(let error) {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
            if self.degree - timers.value < 0 {
                VStack{}.onAppear(){
                    TimeOver()
                    //self.notify()
                }
            } else {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
