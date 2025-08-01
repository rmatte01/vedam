//
//  MeditationView.swift
//  vedam
//
//  Created by Ravinder Matte on 7/31/25.
//

import SwiftUI
import AVFoundation

struct MeditationView: View {
    // Environment and state variables
    @Environment(\.dismiss) private var dismiss
    @State var duration: Int
    let healthKitManager: HealthKitManager
    let onSessionComplete: (Int) -> Void
    
    // Timer and playback state
    @State private var remainingTime: Int
    @State private var timer: Timer?
    @State private var isRunning = false
    
    // Music state
    @State private var playMusic = false
    @State private var audioPlayer: AVAudioPlayer?

    init(duration: Int, healthKitManager: HealthKitManager, onSessionComplete: @escaping (Int) -> Void) {
        self._duration = State(initialValue: duration)
        self.healthKitManager = healthKitManager
        self.onSessionComplete = onSessionComplete
        self._remainingTime = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Meditation")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Timer Progress Line and Display
            ZStack {
                VStack {
                    Text(timeString(time: remainingTime))
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .padding(.bottom, 10) // Add some space below the text

                    ZStack(alignment: .leading) { // Use ZStack for layering capsules, align to leading
                        Capsule()
                            .fill(Color.gray.opacity(0.3)) // Background for the progress line
                            .frame(height: 10) // Thin line

                        Capsule()
                            .fill(Color.blue)
                            .frame(width: CGFloat(1.0 - Double(remainingTime) / Double(duration)) * 300, height: 10) // Progress line
                            .animation(.linear, value: remainingTime)
                    }
                    .frame(width: 300) // Ensure the progress bar has a defined width
                }
            }
            .frame(width: 300) // Keep width fixed for the overall ZStack
            .padding()
            
            // Breathing Animation
            BreathingAnimationView()
                .padding(.vertical, 40) // Add vertical padding to center it

            // Music Toggle
            Toggle(isOn: $playMusic) {
                Text("Play Instrumental Music")
            }
            .padding(.horizontal, 40)
            .onChange(of: playMusic) { _, newValue in
                if newValue {
                    setupAudio()
                    if isRunning {
                        audioPlayer?.play()
                    }
                } else {
                    audioPlayer?.stop()
                    audioPlayer = nil
                }
            }

            // Action Buttons
            HStack(spacing: 20) {
                Button(action: toggleTimer) {
                    Text(isRunning ? "Pause" : "Start")
                        .font(.title)
                        .padding()
                        .frame(width: 150)
                        .background(isRunning ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: stopMeditation) {
                    Text("Stop")
                        .font(.title)
                        .padding()
                        .frame(width: 150)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudio() {
        guard playMusic, let audioPath = Bundle.main.path(forResource: "instrumental", ofType: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            audioPlayer?.pause()
        } else {
            triggerHapticFeedback() // Vibrate on start
            if playMusic {
                audioPlayer?.play()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    // Dispatch all state changes to the main thread to avoid conflicts
                    DispatchQueue.main.async {
                        completeSession()
                    }
                }
            }
        }
        isRunning.toggle()
    }
    
    private func stopMeditation() {
        timer?.invalidate()
        audioPlayer?.stop()
        isRunning = false
        dismiss()
    }
    
    private func completeSession() {
        timer?.invalidate()
        isRunning = false
        audioPlayer?.stop()
        triggerHapticFeedback() // Vibrate on end
        saveMeditationSession()
        dismiss()
    }
    
    private func saveMeditationSession() {
        let minutes = duration / 60
        onSessionComplete(minutes)
        healthKitManager.saveMeditation(minutes: minutes) { success, error in
            if success {
                print("Meditation session saved to HealthKit.")
            } else {
                print("Failed to save meditation session: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

// MARK: - Breathing Animation View

struct BreathingAnimationView: View {
    @State private var scale: CGFloat = 1.0
    @State private var text: String = "Inhale"
    @State private var textOpacity: Double = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 200, height: 200) // Increased size
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: scale)
            
            Text(text)
                .font(.largeTitle) // Increased font size
                .opacity(textOpacity)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: textOpacity)
        }
        .onAppear {
            // Start the animation cycle
            scale = 1.5
            
            // Timer to switch text
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                if text == "Inhale" {
                    text = "Exhale"
                } else {
                    text = "Inhale"
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Meditation View") {
    MeditationView(
        duration: 120,
        healthKitManager: HealthKitManager(),
        onSessionComplete: { _ in }
    )
}
