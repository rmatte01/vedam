//
//  LaunchScreen.swift
//  vedam
//
//  Created by Ravinder Matte on 8/02/25.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Image("AppIcon-Launch")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("Vedam")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
