//
//  SettingView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
//import Charts
import AVFoundation

struct SettingView: View {
    
    //@Binding var selectedBell: String
    //@Environment(\.colorScheme) var colorScheme
    @AppStorage("KEY") var selectedBell: String = "cow-bells"
    @AppStorage("darkMode") var darkMode: String = "자동"
    var bells = ["cow-bells", "alarm", "uprising2", "없음"]
    var mode = ["다크모드", "라이트모드", "자동"]
    
    @State var muteModeSwitch = false
    
    
    var body: some View {
        VStack(spacing: 0){
            ZStack{
                if self.muteModeSwitch {
                    ZStack{}.onAppear(){
                        do {
                            try AVAudioSession.sharedInstance().setCategory(.playback)
                        } catch(let error) {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    ZStack{}.onAppear(){
                        do {
                            try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
                        } catch(let error) {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
            Text("설정")
                .font(.title)
                .bold()
            Spacer()
                .frame(height: 50)
            HStack{
                Text("벨 소리 선택")
                    .padding(5)
                    //.font(.title3)
                    //.padding(.horizontal)
                Spacer()
                Picker(selection: $selectedBell) {
                    ForEach(self.bells, id: \.self) {
                        Text($0).tag($0)
                    }
                } label: {
                    Text("벨소리 선택")
                }
                .pickerStyle(.menu)
                .tint(ClockColor[0])
                .background{
                  RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(ClockColor[0])
                }
                .padding(5)
            }
            HStack{
                Text("다크모드 설정")
                    .padding(5)
                    //.font(.title3)
                    //.padding(.horizontal)
                Spacer()
                Picker(selection: $darkMode) {
                    ForEach(self.mode, id: \.self) {
                        Text($0).tag($0)
                    }
                } label: {
                    Text("다크모드")
                }
                .pickerStyle(.menu)
                .tint(ClockColor[0])
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(ClockColor[0])
                }
                .padding(5)
            }
//            Toggle(isOn: $muteModeSwitch, label: {
//                Text("무음 모드에서 소리 내기")
//            })
            HStack{
                Text("무음 모드에서 소리 내기")
                Spacer()
            Button{
                self.muteModeSwitch.toggle()
            } label: {
                    ZStack{
                        HStack{
                            Spacer()
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.white)
                                    .frame(width: 25, height: 30)
//                                Image(systemName: "checkmark")
//                                    .bold()
//                                    .foregroundStyle(ClockColor[0])
                            }
                        }
                        .frame(width: 60, height: 30)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(self.muteModeSwitch ? ClockColor[0] : Color.gray)
                        }
                        .offset(x: self.muteModeSwitch ? 0 : -35, y: 0)
                        .animation(.easeInOut(duration: 0.2), value: self.muteModeSwitch)
                    }
                    .frame(width: 60, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .background{
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.gray)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 3)
                                .foregroundStyle(self.muteModeSwitch ? ClockColor[0] : Color.gray)
                        }
                    }
                }
            }
            .padding(5)
            Text("uprising2 sound is shared from JFRecords")
                .font(.footnote)
                .padding()
            Spacer()
        }
    }
}



#Preview {
    SettingView()
}
