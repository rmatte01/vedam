//
//  ContentView.swift
//  vedam
//
//  Created by Ravinder Matte on 7/27/25.
//

import SwiftUI

struct ContentView: View {
    // App state
    @State private var isMeditationViewPresented = false
    @State private var selectedDuration: Int = 2 // Default duration
    @State private var meditationHistory: [Meditation] = []
    
    // Managers
    private let healthKitManager = HealthKitManager()
    
    // Constants
    let meditationTimes = [2, 4, 10, 20]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                // Header
                Text("Vedam")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Select your meditation time")
                    .font(.title2)
                    .padding(.bottom, 40)
                    .foregroundColor(.white)

                // Duration buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(meditationTimes, id: \.self) { time in
                        Button(action: {
                            selectedDuration = time
                            isMeditationViewPresented = true
                        }) {
                            Text("\(time) min")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(width: 120, height: 120)
                        .background(Color.blue)
                .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.all, 20)
                    }
                }
                if !meditationHistory.isEmpty {
                    Text("Recent Meditations")
                        .font(.headline)
                        .padding(.top)
                        .foregroundColor(.white)
                    
                    List(meditationHistory.prefix(5)) { meditation in
                        HStack {
                            Text("\(meditation.duration) min")
                                .foregroundColor(.white)
                            Spacer()
                            Text(meditation.date, style: .date)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.black)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarHidden(true)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            loadHistory()
            requestHealthKitAuthorization()
        }
        .onChange(of: meditationHistory) { _, newValue in
            saveHistory(newValue)
        }
        .sheet(isPresented: $isMeditationViewPresented) {
            MeditationView(
                duration: selectedDuration * 60,
                healthKitManager: healthKitManager,
                onSessionComplete: addMeditationToHistory
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func addMeditationToHistory(durationInMinutes: Int) {
        let newMeditation = Meditation(date: Date(), duration: durationInMinutes)
        meditationHistory.insert(newMeditation, at: 0)
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "meditationHistory") {
            if let decoded = try? JSONDecoder().decode([Meditation].self, from: data) {
                meditationHistory = decoded
            }
        }
    }
    
    private func saveHistory(_ history: [Meditation]) {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "meditationHistory")
        }
    }
    
    private func requestHealthKitAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            if !success {
                // Handle error or inform user
                print("HealthKit authorization failed.")
            }
        }
    }
}

// MARK: - Preview

#Preview("Content View") {
    ContentView()
}
