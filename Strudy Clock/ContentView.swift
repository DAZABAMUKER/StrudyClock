//
//  ContentView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import AVFoundation

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
    @State var selectedSub = "과목을 선택하세요"
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
        do {
            let asset = NSDataAsset(name: self.selectedBell)
            guard let sound = asset?.data else
            {
                return
            }
            player = try AVAudioPlayer(data:sound, fileTypeHint:"wav")
            player?.play()
        } catch {
            print(error.localizedDescription)
        }
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
            .preferredColorScheme(self.darkMode == "다크모드" ? .dark : self.darkMode == "라이트모드" ? .light : self.colorscheme)
            .onChange(of: phase) { phaseStatus in
                if phaseStatus == .background {
                    timers.backProcess()
                } else {
                    timers.backgroundTime()
                }
            }
            if self.muteModeSwitch {
                ZStack{}.onAppear(){
                    do {
                        try self.session.setCategory(.playback)
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                }
            } else {
                ZStack{}.onAppear(){
                    do {
                        try self.session.setCategory(.soloAmbient)
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                }
            }
            if self.degree - timers.value < 0 {
                VStack{}.onAppear(){
                    TimeOver()
                }
            } else {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
