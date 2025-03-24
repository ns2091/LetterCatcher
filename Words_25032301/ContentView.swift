//
//  ContentView.swift
//  Words_25032301
//
//  Created by やきそば on 2025/03/23.
//

import SwiftUI
import RealityKit
import RealityKitContent


struct ContentView: View {
    /// The environment value to get the instance of the `OpenImmersiveSpaceAction` instance.
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
//     回収した文字を格納する変数
    @State private var text: String = ""
    @State private var isSpaceActive: Bool = false
    
    var body: some View {
        // Display a line of text and
        // open a new immersive space environment.
            VStack {
                Text("Letter Catcher").font(.system(size: 80, weight: .bold))
            }.padding(-30)
            HStack(spacing: -125) {
                Model3D(named: "A_alphabet_lore", bundle: realityKitContentBundle).scaleEffect(0.3).rotation3DEffect(.degrees(10), axis: (x: 0, y: 1, z: 1)).padding(30)
                Model3D(named: "B_albhabet_lore", bundle: realityKitContentBundle).scaleEffect(0.3).rotation3DEffect(.degrees(-10), axis: (x: 0, y: 1, z: 0)).padding(-100)
                Model3D(named: "C_Alphabet_Lore", bundle: realityKitContentBundle).scaleEffect(10).rotation3DEffect(.degrees(10), axis: (x: 1, y: 0, z: 0)).padding(150)
                Model3D(named: "D_Alphabet_Lore", bundle: realityKitContentBundle).scaleEffect(10).rotation3DEffect(.degrees(-10), axis: (x: 0, y: 0, z: 1)).padding(150)
                Model3D(named: "E_Alphabet_Lore", bundle: realityKitContentBundle).scaleEffect(10).rotation3DEffect(.degrees(10), axis: (x: 0, y: 1, z: 0)).padding(150)
            }
            VStack {
                Text("指令：潜んだABCモンスターを捕まえて単語を作れ").font(.system(size: 30, weight: .bold))
            }.padding(-30)
        VStack {
                        if !isSpaceActive {
                            Text("\n")
                            Button("はじめる") {
                                isSpaceActive = true
                                Task {
                                    await openImmersiveSpace(id: "CarView")
                                }
                            }.font(.system(size: 30, weight: .bold)).frame(maxWidth: 400, minHeight: 50).background(Color.white.opacity(0.2)).cornerRadius(10)
                        }
                    }

            
            .onReceive(NotificationCenter.default.publisher(for: .tappedBall)) { notification in
                if let message = notification.object as? String {
                    text = message
                }
            
        }
        
//        Text("Use gestures to move the car")
//            .onAppear {
//                Task {
//                    await openImmersiveSpace(id: "CarView")
//                }
//            }
    }
}

//#Preview(windowStyle: .automatic) {
//    ContentView()
//}

//
////
////  ContentView.swift
////  Words_25032301
////
////  Created by やきそば on 2025/03/23.
////
//
//import SwiftUI
//import RealityKit
//import RealityKitContent
//
//struct ContentView: View {
//
//    var body: some View {
//        VStack {
//            Model3D(named: "Scene", bundle: realityKitContentBundle)
//                .padding(.bottom, 50)
//
//            Text("Hello, world!")
//
//            ToggleImmersiveSpaceButton()
//        }
//        .padding()
//    }
//}
//
#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
