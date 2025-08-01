//
//  HealthKitManager.swift
//  vedam
//
//  Created by Ravinder Matte on 7/31/25.
//

import Foundation
import HealthKit

/// A manager for all HealthKit-related operations.
final class HealthKitManager {
    
    private let healthStore = HKHealthStore()
    
    /// Requests authorization to access HealthKit data.
    /// - Parameter completion: A closure that is called after the request is complete.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            // You can create a custom error enum to be more specific.
            completion(false, nil)
            return
        }

        // We only need to write mindful session data.
        let typesToShare: Set = [
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: nil) { success, error in
            completion(success, error)
        }
    }

    /// Saves a meditation session to the Health app.
    /// - Parameters:
    ///   - minutes: The duration of the meditation in minutes.
    ///   - completion: A closure that is called after the save operation is complete.
    func saveMeditation(minutes: Int, completion: @escaping (Bool, Error?) -> Void) {
        let mindfulSessionType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .minute, value: minutes, to: startDate)!
        
        let mindfulSession = HKCategorySample(
            type: mindfulSessionType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )
        
        healthStore.save(mindfulSession) { success, error in
            completion(success, error)
        }
    }
}