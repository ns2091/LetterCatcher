//
//  Words_25032301App.swift
//  Words_25032301
//
//  Created by やきそば on 2025/03/23.
//

//import SwiftUI
//
//@main
//struct Words_25032301App: App {
//
//    @State private var appModel = AppModel()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(appModel)
//        }
//
//        ImmersiveSpace(id: appModel.immersiveSpaceID) {
//            ImmersiveView()
//                .environment(appModel)
//                .onAppear {
//                    appModel.immersiveSpaceState = .open
//                }
//                .onDisappear {
//                    appModel.immersiveSpaceState = .closed
//                }
//        }
//        .immersionStyle(selection: .constant(.full), in: .full)
//    }
//}

import SwiftUI

@main
struct Words_25032301App: App {
    var body : some Scene {
        WindowGroup {
            ContentView()
        }
        
        ImmersiveSpace(id: "CarView") {
            CarView()
        }
        
        ImmersiveSpace(id: "HeadTrackingScene") {
            HeadPositionView()
        }
    }
}
