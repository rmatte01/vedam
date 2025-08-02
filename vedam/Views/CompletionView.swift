//
//  CompletionView.swift
//  vedam
//
//  Created by Ravinder Matte on 8/01/25.
//

import SwiftUI

struct CompletionView: View {
    @State private var checkmarkTrim: CGFloat = 0
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("Congratulations!", comment: "Completion message"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            ZStack {
                Circle()
                    .stroke(lineWidth: 5)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 50))
                    path.addLine(to: CGPoint(x: 45, y: 65))
                    path.addLine(to: CGPoint(x: 70, y: 40))
                }
                .trim(from: 0, to: checkmarkTrim)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    checkmarkTrim = 1.0
                }
            }

            Button(action: onDismiss) {
                Text(NSLocalizedString("Done", comment: "Done button"))
                    .font(.title2)
                    .padding()
                    .frame(width: 150)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75))
        .edgesIgnoringSafeArea(.all)
    }
}
