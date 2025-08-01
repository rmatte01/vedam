//
//  Meditation.swift
//  vedam
//
//  Created by Ravinder Matte on 7/31/25.
//

import Foundation

/// Represents a single, completed meditation session.
struct Meditation: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let duration: Int // in minutes
    
    init(id: UUID = UUID(), date: Date, duration: Int) {
        self.id = id
        self.date = date
        self.duration = duration
    }
}