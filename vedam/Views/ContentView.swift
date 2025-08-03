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
    @State private var showHealthKitAuthError = false
    
    // Managers
    private let healthKitManager = HealthKitManager()
    
    // Constants
    let meditationTimes = [2, 4, 10, 20]

    private var gridColumns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        } else {
            return [GridItem(.flexible()), GridItem(.flexible())]
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                // Header
                Text(NSLocalizedString("Vedam", comment: "App Title"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(NSLocalizedString("Select your meditation time", comment: "Subtitle"))
                    .font(.title2)
                    .padding(.bottom, 40)
                    .foregroundColor(.white)

                // Duration buttons
                LazyVGrid(columns: gridColumns, spacing: 20) {
                    ForEach(meditationTimes, id: \.self) { time in
                        GeometryReader { geometry in
                            Button(action: {
                                selectedDuration = time
                                isMeditationViewPresented = true
                            }) {
                                Text(String(format: NSLocalizedString("%d min", comment: "Duration button"), time))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: geometry.size.width, height: geometry.size.width)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.all, 20)
                    }
                }
                if !meditationHistory.isEmpty {
                    Text(NSLocalizedString("Recent Meditations", comment: "History section title"))
                        .font(.headline)
                        .padding(.top)
                        .foregroundColor(.white)
                    
                    List {
                        ForEach(meditationHistory.prefix(5)) { meditation in
                            HistoryRow(meditation: meditation)
                        }
                        .listRowBackground(Color.black)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(NSLocalizedString("Home", comment: "Navigation bar title"))
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
        .fullScreenCover(isPresented: $isMeditationViewPresented) {
            MeditationView(
                duration: selectedDuration * 60,
                healthKitManager: healthKitManager,
                onSessionComplete: addMeditationToHistory
            )
        }
        .alert(isPresented: $showHealthKitAuthError) {
            Alert(
                title: Text(NSLocalizedString("HealthKit Authorization Failed", comment: "Alert title")),
                message: Text(NSLocalizedString("Could not get permission to save meditations to HealthKit. Please check your settings.", comment: "Alert message")),
                dismissButton: .default(Text(NSLocalizedString("OK", comment: "Alert button")))
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
                showHealthKitAuthError = true
            }
        }
    }
}

struct HistoryRow: View {
    let meditation: Meditation
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String(format: NSLocalizedString("%d min", comment: "Duration in history"), meditation.duration))
                    .font(isIpad ? .title2 : .headline)
                    .foregroundColor(.white)
                Text(meditation.date, style: .date)
                    .font(isIpad ? .title3 : .caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "leaf.arrow.triangle.circlepath")
                .font(isIpad ? .title : .body)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview("Content View") {
    ContentView()
}
