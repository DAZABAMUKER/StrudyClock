//
//  Home.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import AVKit


struct Home: View {
    
    //MARK: - 변수
    @State var timeSet = false
    @State var TimeHour: Int = 0
    @State var TimeMin: Int = 0
    @State var TimeSec: Int = 0
    
    @State var SelSubject = false
    @State var subjects: [String] = []
    @Binding var selectedSub: String
    @State var makeSub = false
    @State var addedSub = ""
    
    @State var AOD = true
    
    @State var sujectAlert = false
    
    @Binding var degree: Double
    @State var scWidth = 0.0
    @State var scHeight = 0.0
    @State var clockSize = 0.0
    @Binding var over: Bool
    @Binding var pauses: Bool
    @State var overClock = false
    @Binding var settingAngle: Double
    @State var oldLocation: CGPoint = CGPoint.zero
    @State var colorNumber = ClockColor.count - 1
    @State var settingHour = 1.0
    
    @ObservedObject var timers: Timers
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var player: AVAudioPlayer?
    @AppStorage("KEY") var selectedBell: String = "cow-bells"
    
    private let adCoordinator = AdCoordinator()
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    
    
    //MARK: - 바디 뷰
    var body: some View {
        ZStack{
            self.functions
            GeometryReader{ geometry in
                ZStack{Spacer()}.onAppear() {
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    self.clockSize = scWidth > scHeight ? self.scHeight : self.scWidth
                    self.clockSize = self.clockSize/6
                    self.loadSubjectArray()
                    self.saveSubjectArray()
                }
                .onChange(of: geometry.size) { _ in
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    self.clockSize = scWidth > scHeight ? self.scHeight : self.scWidth
                    self.clockSize = self.clockSize/6
                }
            }
            HStack{
                if self.scWidth > self.scHeight {
                    self.clockView
                }
                VStack{
                    Toggle("화면 항상 켜기", isOn: $AOD)
                    //.foregroundStyle(Color(red: 216.0/255.0, green: 63.0/255.0, blue: 49.0/255.0))
                        .tint(Color(red: 216.0/255.0, green: 63.0/255.0, blue: 49.0/255.0))
                        .padding()
                    Spacer()
                    Button(action: {
                        self.SelSubject.toggle()
                    }, label: {
                        HStack{
                            Text(self.selectedSub)
                                .fontDesign(.rounded)
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(self.selectedSub == "과목을 선택하세요" ? .gray : self.colorScheme == .dark ? Color.white : Color.black)
                            if !self.pauses {
                                Button{
                                    TimeOver()
                                } label: {
                                    Image(systemName: "stop.fill")
                                        .font(.title)
                                        .foregroundStyle(ClockColor[0])
                                }
                            }
                        }
                    })
                    Spacer()
                        .sheet(isPresented: self.$SelSubject, content: {
                            self.subSelView
                        })
                        .onAppear(){
                            if self.subjects == [] {
                                self.loadSubjectArray()
                            }
                        }
                    //MARK: 시계
                    if self.scWidth < self.scHeight {
                        self.clockView
                    } else {
                        
                    }
                    Spacer()
                    self.timeSelection
                    Spacer()
                }
            }
        }
        .background {
            // Add the adViewControllerRepresentable to the background so it
            // doesn't influence the placement of other views in the view hierarchy.
            adViewControllerRepresentable
                .frame(width: .zero, height: .zero)
        }
    }
    
}

//MARK: 뷰 집합
extension Home {
    
    var clockView: some View {
        Group{
            //MARK: Clock
            ZStack{
                Circle()
                    .frame(width: self.clockSize*4)
                    .foregroundColor(ClockColor[self.colorNumber])
                Image("clock_num")
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.clockSize * 5.2, height: self.clockSize * 5.2)
                    .foregroundColor(self.colorScheme == .dark ? .white : .black)
                
                TimerView(degrees: (degree.truncatingRemainder(dividingBy: 3600)-timers.value)/10)
                    .stroke(lineWidth: self.clockSize*2)
                    .frame(width: self.clockSize, height: self.clockSize)
                    .rotationEffect(.degrees(270))
                    .foregroundStyle(ClockColor[self.colorNumber-1])
                    .shadow(radius: 5)
                    
                knob
                //MARK: 시작 버튼
                ZStack{
                    Circle()
                        .foregroundStyle(.white)
                        .frame(width: self.clockSize)
                        .shadow(radius: 7)
                    Triangle()
                        .frame(width: self.clockSize/3, height: self.clockSize/3)
                        .padding(.bottom , self.clockSize*1.2)
                        .foregroundColor(.white)
                        .rotationEffect(Angle(degrees: -(degree-timers.value)/10))
                        .shadow(radius: 7)
                    Circle()
                        .foregroundStyle(.white)
                        .frame(width: self.clockSize)
                    Button{
                        if self.selectedSub == "과목을 선택하세요" {
                            self.sujectAlert = true
                            return
                        }
                        if self.pauses {
                            adCoordinator.loadAd()
                            timers.SettingDegree = self.degree
                            timers.start()
                            self.over = false
                            adCoordinator.loadAd()
                        } else {
                            adCoordinator.presentAd(from: adViewControllerRepresentable.viewController)
                            timers.Pause()
                            adCoordinator.presentAd(from: adViewControllerRepresentable.viewController)
                        }
                        self.pauses.toggle()
                    } label: {
                        Image(systemName: self.pauses ? "play.fill" :"pause.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: self.clockSize*0.5, height: self.clockSize*0.5)
                            .padding(.leading, self.pauses ? self.clockSize/14 : 0)
                            .foregroundColor(Color(red: 216.0/255.0, green: 63.0/255.0, blue: 49.0/255.0))
                    }
                    .alert("과목윽 선택하세요!", isPresented: $sujectAlert) {
                        Text("확인")
                            .tint(ClockColor[0])
                    } message: {
                        Text("과목을 선택하지 않으면 타이머가 작동하지 않습니다.")
                    }
                }
            }
//            Spacer()
//            self.timeSelection
//            Spacer()
        }
    }
    
    var subSelView: some View {
        Group{
            if !makeSub {
                Picker(selection: $selectedSub) {
                    ForEach(self.subjects, id: \.self) {
                        Text($0).tag($0)
                    }
                    
                } label: {
                    Text("과목선택")
                }
                .pickerStyle(.wheel)
                .presentationDetents([.fraction(0.4)])
                .onAppear() {
                    // 과목 선택 sheet 올라올 때 과목 선택 바로 반영
                    if self.selectedSub == "과목을 선택하세요" {
                        if self.subjects.count != 0 {
                            self.selectedSub = self.subjects.first! //과목 목록이 있으면 첫 요소로 선택
                            //timers.subject = self.selectedSub
                        } else {
                            self.selectedSub = "토익" // 없으면 토익으로
                            //timers.subject = self.selectedSub
                        }
                    }
                }
                Button {
                    self.makeSub = true
                } label: {
                    HStack{
                        Spacer()
                        Text("과목 추가하기")
                            .foregroundStyle(ClockColor[0])
                            .padding(8)
                        Spacer()
                    }
                    
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2.0)
                            .foregroundStyle(ClockColor[0])
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical,5)
                Button {
                    self.SelSubject = false
                } label: {
                    HStack{
                        Spacer()
                        Text("확인")
                            .foregroundStyle(.white)
                            .padding(10)
                        Spacer()
                    }
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(ClockColor[0])
                    }
                    .padding(.horizontal)
                }
            } else {
                VStack{
                    Text("추가하실 과목을 입력해주세요.")
                        .padding()
                        .font(.title2)
                        .frame(height: 50)
                        .foregroundStyle(ClockColor[0])
                        .presentationDetents([.fraction(0.2)])
                    TextField("과목 입력", text: $addedSub)
                        .padding(6)
                        .background(.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    Button{
                        self.subjects.append(self.addedSub)
                        self.makeSub = false
                        saveSubjectArray()
                        self.selectedSub = self.addedSub
                        self.addedSub = ""
                    } label: {
                        HStack{
                            Spacer()
                            Text("확인")
                                .foregroundStyle(.white)
                                .padding(10)
                            Spacer()
                        }
                        .background() {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(ClockColor[0])
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
        }
    }
    
    var knob: some View {
        Circle()
            .foregroundStyle(.white)
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            .frame(width: clockSize*0.4, height: clockSize*0.4)
            .offset(y: -clockSize*2)
            .rotationEffect(.degrees(self.settingAngle))
            .gesture(DragGesture().onChanged({ dot in
                if degree >= 0 {
                    change(location: dot.location)
                    checkHour(location: dot.location)
                } else {
                    degree = 0.0
                }
            }))
            .opacity(self.over ? 1.0 : 0.0)
    }
    
    var timeSelection: some View {
        VStack{
            if !self.pauses {
                
            } else {
                Button(action: {
                    self.timeSet.toggle()
                }, label: {
                    Text("시간 설정")
                        .foregroundStyle(Color(red: 216.0/255.0, green: 63.0/255.0, blue: 49.0/255.0))
                        .padding(.horizontal, 20)
                })
                .sheet(isPresented: $timeSet, content: {
                    VStack{
                        HStack{
                            Button(action: {
                                self.timeSet = false
                            }, label: {
                                Image(systemName: "x.square")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .foregroundStyle(ClockColor[0])
                            })
                            Spacer()
                            Text("시간 선택")
                                .fontDesign(.rounded)
                                .bold()
                                .foregroundStyle(ClockColor[0])
                                .font(.title3)
                            Spacer()
                            Button(action: {
                                self.timeSet = false
                                self.degree = Double(self.TimeHour * 3600 + self.TimeMin * 60 + self.TimeSec)
                                var results = ""
                                if self.degree < 3600 {
                                    results = "\(String(format:"%02d", self.TimeMin)) : \(String(format:"%02d", self.TimeSec))"
                                } else {
                                    results = "\(String(format:"%02d",self.TimeHour)) : \(String(format:"%02d",self.TimeMin)) : \(String(format:"%02d",self.TimeSec))"
                                }
                                //self.degree = 3600 * self.settingHour - angle * 10
                                self.settingAngle = -(self.degree - self.settingHour * 3600) / 10
                                timers.timeString = results
                            }, label: {
                                Text("확인")
                                //.frame(width: 30, height: 20)
                                    .padding(7)
                                    .foregroundStyle(ClockColor[0])
                            })
                            //.buttonStyle(.borderedProminent)
                            .tint(.clear)
                            //.frame(width: 40, height: 25)
                            //.padding(.horizontal)
                            .border(ClockColor[0], width: 2.5)
                            .padding()
                        }
                        HStack{
                            Picker(selection: $TimeHour) {
                                ForEach(0..<24){ i in
                                    Text("\(i)")
                                }
                                .foregroundStyle(ClockColor[0])
                            } label: {
                                Text("사간 선택")
                            }
                            .pickerStyle(.wheel)
                            .presentationDetents([.fraction(0.4)])
                            Text(":")
                            Picker(selection: $TimeMin) {
                                ForEach(0..<60){ i in
                                    Text("\(i)")
                                }
                                .foregroundStyle(ClockColor[0])
                            } label: {
                                Text("사간 선택")
                            }
                            .pickerStyle(.wheel)
                            Text(":")
                            Picker(selection: $TimeSec) {
                                ForEach(0..<60){ i in
                                    Text("\(i)")
                                }
                                .foregroundStyle(ClockColor[0])
                            } label: {
                                Text("사간 선택")
                            }
                            .pickerStyle(.wheel)
                        }
                    }
                })
            }
            Text(timers.timeString)
                .font(.largeTitle)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .fontDesign(.rounded)
                .foregroundStyle(ClockColor[0])
        }
        
    }
    
}

//MARK: Fuctions 집합
extension Home {
    
    private func loadSubjectArray() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let subjectJson = url.appendingPathComponent("subject_array", conformingTo: .json)
        if FileManager.default.fileExists(atPath: subjectJson.path()) {
            guard let js = NSData(contentsOf: subjectJson) else {print("json not found!"); return}
            let decoder = JSONDecoder()
            guard let myData = try? decoder.decode([String].self, from: js as Data) else {print("subject Data not found!"); return}
            self.subjects = myData
        } else {
            self.subjects = ["토익", "오픽"]
        }
    }
    
    private func saveSubjectArray() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let subjectJson = url.appendingPathComponent("subject_array", conformingTo: .json)
        if FileManager.default.fileExists(atPath: subjectJson.path()) {
            try? FileManager.default.removeItem(atPath: subjectJson.path)
            let myData = try? JSONEncoder().encode(self.subjects)
            FileManager.default.createFile(atPath: subjectJson.path(), contents: myData)
        } else {
            let myData = try? JSONEncoder().encode(self.subjects)
            FileManager.default.createFile(atPath: subjectJson.path(), contents: myData)
        }
    }
    
    private func change(location: CGPoint) {
        
        if self.degree >= 0 && !self.overClock {
            let vector = CGVector(dx: location.x, dy: location.y)
            let radian = atan2(vector.dy , vector.dx)
            self.settingAngle = radian * 180 / .pi + 90
            //print(self.settingAngle)
            if self.over {
                timers.value = 0.0
                var angle = self.settingAngle
                //print(angle)
                if self.settingAngle < 0 {
                    angle = 360 + self.settingAngle
                }
                self.degree = 3600 * self.settingHour - angle * 10
                timers.timeString = secondsToHoursMinutesSeconds(Int(self.degree))
            }
        }
    }
    
    private func checkHour(location: CGPoint) {
        if self.pauses {
            if location.x < 0 && self.oldLocation.x > 0 && location.y < 0 {
                if colorNumber != 1 {
                    if overClock {
                        
                    } else {
                        colorNumber -= 1
                        self.settingHour += 1
                    }
                    self.overClock = false
                }
                self.overClock = false
                //self.degree += 3600
            } else if location.x > 0 && self.oldLocation.x < 0 && location.y < 0 {
                if colorNumber != ClockColor.count - 1 {
                    colorNumber += 1
                    self.settingHour -= 1
                }
                if self.degree < 3600 {
                    self.overClock = true
                    self.degree = 0.0
                    self.settingAngle = 0.0
                    timers.stop()
                    self.oldLocation = CGPoint.zero
                }
                //self.degree -= 3600
            } else {
                
            }
            self.oldLocation = location
        }
    }
    
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
    
    func TimePause() {
        timers.SaveData(subjectOfTimer: self.selectedSub)
        self.over = true
        timers.Pause()
        self.pauses = true
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int = 0) -> String {
        let timeDict: [Times : Int] = [.Hour : seconds / 3600, .Minute : (seconds % 3600) / 60, .Second : (seconds % 3600) % 60 ]
        var results = ""
        if seconds < 3600 {
            results = "\(String(format:"%02d",(timeDict[.Minute] ?? 0) + 60 * (timeDict[.Hour] ?? 0))) : \(String(format:"%02d",timeDict[.Second] ?? 0))"
        } else {
            results = "\(String(format:"%02d",timeDict[.Hour] ?? 0)) : \(String(format:"%02d",timeDict[.Minute] ?? 0)) : \(String(format:"%02d",timeDict[.Second] ?? 0))"
        }
        
        return results
    }
    
    private var functions: some View {
        ZStack{
//            if self.degree - timers.value < 0 {
//                VStack{}.onAppear(){
//                    TimeOver()
//                }
//            } else {
//                
//            }
            if self.AOD {
                VStack{}.onAppear() {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            } else {
                VStack{}.onAppear() {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
            if self.degree == self.timers.value {
                VStack{}.onAppear() {
                    self.over = true
                }
            } else {
            }
            if self.pauses {
                VStack{}.onAppear() {
                    timers.pauses = true
                    self.settingAngle = -(self.degree - timers.value)/10
                }
            } else {
                VStack{}.onAppear() {
                    timers.pauses = false
                    //print(timers.pauses)
                }
            }
            
            if degree.truncatingRemainder(dividingBy: 3600)-timers.value < 1.0 && degree - timers.value > 1 {
                VStack{}.onAppear() {
                    if !self.pauses {
                        self.colorNumber += 1
                    }
                }
            }
        }
    }
}



var ClockColor = [
    Color(red: 216/255, green: 63/255, blue: 49/255),
    Color.gray,
    Color(red: 255/255, green: 183/255, blue: 183/255),
    Color(red: 150/255, green: 194/255, blue: 145/255),
    Color(red: 30/255, green: 178/255, blue: 166/255),
    Color(red: 212/255, green: 248/255, blue: 232/255),
    Color(red: 255/255, green: 163/255, blue: 77/255),
    Color(red: 246/255, green: 117/255, blue: 117/255),
    Color(red: 255/255, green: 235/255, blue: 235/255),
    Color(red: 173/255, green: 228/255, blue: 219/255),
    Color(red: 109/255, green: 169/255, blue: 228/255),
    Color(red: 246/255, green: 186/255, blue: 111/255),
    Color(red: 24/255, green: 111/255, blue: 101/255),
    Color(red: 181/255, green: 203/255, blue: 153/255),
    Color(red: 252/255, green: 224/255, blue: 155/255),
    Color(red: 178/255, green: 83/255, blue: 62/255),
    Color(red: 255/255, green: 245/255, blue: 224/255),
    Color(red: 255/255, green: 105/255, blue: 105/255),
    Color(red: 199/255, green: 0/255, blue: 57/255),
    Color(red: 20/255, green: 30/255, blue: 70/255),
    Color(red: 33/255, green: 156/255, blue: 144/255),
    Color(red: 233/255, green: 184/255, blue: 36/255),
    Color(red: 238/255, green: 147/255, blue: 34/255),
    Color(red: 216/255, green: 63/255, blue: 49/255),
    Color.clear
]

enum Times {
    case Hour
    case Minute
    case Second
}

