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
    @State private var elapsedTime: Int = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isBreathingAnimationRunning = false
    @State private var showCompletionView = false
    
    // Music state
    @State private var playMusic = false
    @State private var audioPlayer: AVAudioPlayer?

    init(duration: Int, healthKitManager: HealthKitManager, onSessionComplete: @escaping (Int) -> Void) {
        self.duration = duration
        self.healthKitManager = healthKitManager
        self.onSessionComplete = onSessionComplete
        self._remainingTime = State(initialValue: duration)
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                // Header
    //            Text("Breath")
    //                .font(.largeTitle)
    //                .fontWeight(.heavy)
                

                // Timer Progress Line and Display
                VStack {
                    Text(timeString(time: remainingTime))
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .padding(.bottom, 20) // Add some space below the text
                        .fontWeight(.heavy)
                        .foregroundColor(.white)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) { // Use ZStack for layering capsules, align to leading
                            Capsule()
                                .fill(Color.gray.opacity(0.3)) // Background for the progress line
                                .frame(height: 10) // Thin line

                            Capsule()
                                .fill(Color.blue)
                                .frame(width: CGFloat(1.0 - Double(remainingTime) / Double(duration)) * geometry.size.width, height: 10) // Progress line
                                .animation(.linear, value: remainingTime)
                        }
                    }
                    .frame(height: 10) // Give GeometryReader a fixed height
                }
                .frame(maxWidth: .infinity) // Allow VStack to take full width
                
                
                // Breathing Animation
                BreathingAnimationView(isAnimating: $isBreathingAnimationRunning)
                    .padding(.vertical, 100) // Add vertical padding to center it

                // Music Toggle
                Toggle(isOn: $playMusic) {
                    Text("Play Instrumental Music")
                        .foregroundColor(.white)
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
                        Text(buttonText())
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

            if showCompletionView {
                CompletionView {
                    saveMeditationSession()
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func buttonText() -> String {
        if isRunning {
            return "Pause"
        } else {
            return isPaused ? "Resume" : "Start"
        }
    }
    
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
        isRunning.toggle()
        isBreathingAnimationRunning = isRunning
        
        if isRunning {
            isPaused = false
            triggerHapticFeedback() // Vibrate on start
            if playMusic {
                audioPlayer?.play()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                    elapsedTime += 1
                } else {
                    // Dispatch all state changes to the main thread to avoid conflicts
                    DispatchQueue.main.async {
                        completeSession()
                    }
                }
            }
        } else {
            isPaused = true
            timer?.invalidate()
            audioPlayer?.pause()
        }
    }
    
    private func stopMeditation() {
        timer?.invalidate()
        audioPlayer?.stop()
        isRunning = false
        isPaused = false
        isBreathingAnimationRunning = false
        
        if elapsedTime > 0 {
            saveMeditationSession()
        }
        dismiss()
    }
    
    private func completeSession() {
        timer?.invalidate()
        isRunning = false
        isPaused = false
        isBreathingAnimationRunning = false
        audioPlayer?.stop()
        triggerHapticFeedback() // Vibrate on end
        showCompletionView = true
    }
    
    private func saveMeditationSession() {
        let minutes = elapsedTime / 60
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
    @Binding var isAnimating: Bool
    @State private var scale: CGFloat = 1.0
    @State private var text: String = "INHALE"
    @State private var textOpacity: Double = 1.0
    @State private var currentBreathingPhase: BreathingPhase = .inhale
    @State private var animationTimer: Timer?
    @State private var phaseProgress: Double = 0.0
    let breathingPhaseDuration: Double = 4.0

    enum BreathingPhase: CaseIterable {
        case inhale, hold1, exhale, hold2
        
        var displayText: String {
            switch self {
            case .inhale: return "INHALE"
            case .hold1: return "HOLD"
            case .exhale: return "EXHALE"
            case .hold2: return "HOLD"
            }
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 200, height: 200)
                .scaleEffect(scale)

            Text(text)
                .font(.largeTitle)
                .opacity(textOpacity)
                .foregroundColor(.white)
        }
        .onAppear(perform: resetAnimation)
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startOrResumeAnimation()
            } else {
                pauseAnimation()
            }
        }
    }
    
    private func startOrResumeAnimation() {
        if animationTimer == nil {
            updateViewForPhase(phase: currentBreathingPhase)
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                phaseProgress += 0.05
                
                if phaseProgress >= breathingPhaseDuration {
                    phaseProgress = 0
                    let allPhases = BreathingPhase.allCases
                    let currentIndex = allPhases.firstIndex(of: currentBreathingPhase) ?? 0
                    let nextIndex = (currentIndex + 1) % allPhases.count
                    currentBreathingPhase = allPhases[nextIndex]
                    updateViewForPhase(phase: currentBreathingPhase)
                }
            }
        }
    }
    
    private func pauseAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }

    private func updateViewForPhase(phase: BreathingPhase) {
        withAnimation(.easeOut(duration: 0.25)) {
            textOpacity = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            text = phase.displayText
            withAnimation(.easeIn(duration: 0.25)) {
                textOpacity = 1.0
            }
        }

        withAnimation(.easeInOut(duration: breathingPhaseDuration)) {
            switch phase {
            case .inhale, .hold1:
                scale = 1.5
            case .exhale, .hold2:
                scale = 1.0
            }
        }
    }

    private func resetAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        scale = 1.0
        text = "Inhale"
        textOpacity = 1.0
        currentBreathingPhase = .inhale
        phaseProgress = 0
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
