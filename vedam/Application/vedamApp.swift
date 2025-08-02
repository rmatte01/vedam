//
//  vedamApp.swift
//  vedam
//
//  Created by Ravinder Matte on 7/27/25.
//

import SwiftUI

@main
struct vedamApp: App {
    @State private var isShowingLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            if isShowingLaunchScreen {
                LaunchScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isShowingLaunchScreen = false
                            }
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
