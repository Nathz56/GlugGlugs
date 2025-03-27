//
//  HealthKitManager.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import Foundation
import HealthKit
import WidgetKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let volumeUnit = HKUnit.literUnit(with: .milli)
    private let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
    
    private var healthStore = HKHealthStore()
     
    
    var thisWeekRecord: [Int: Int] = [1: 0,
                                      2: 0,
                                      3: 0,
                                      4: 0,
                                      5: 0,
                                      6: 0,
                                      7: 0]
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let toReads = Set([
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
        ])
        
        var typesToShare : Set<HKSampleType> {
            let waterType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!
            return [waterType]
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("health data not available!")
            return
        }
        
        healthStore.requestAuthorization(toShare: typesToShare, read: toReads) {
            success, error in
            if success {
                print("Success authorization")
            } else {
                print("\(String(describing: error))")
            }
        }
    }
    
    func addWaterAmount(volume : Double) {
        guard let quantityType = self.waterType else {
            print("Error: dietaryWater quantity type is nil")
            return
        }
        
        let drinkAmount = HKQuantity(unit: volumeUnit, doubleValue: volume)
        let now = Date()
        
        let data = HKQuantitySample(type: quantityType, quantity: drinkAmount, start: now, end: now)
        self.healthStore.save(data) { success, error in
            if let error = error {
                print("Error saving water data: \(error.localizedDescription)")
            } else {
                print("Successfully saved water intake: \(volume) mL")
            }
        }
    }
    
    func getConsumedWaterToday(completion: @escaping (Int?) -> Void) {
        guard let quantityType = self.waterType else {
            print("Error: Unable to get dietaryWater type")
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read water volume: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                completion(nil)
                return
            }
            
            let waterVolume = sum.doubleValue(for: self.volumeUnit)
            DispatchQueue.main.async {
                completion(Int(waterVolume))
            }
        }
        healthStore.execute(query)
    }
    
    func getThisWeekStatistic(completion: @escaping ([(date: String, volume: Int)]) -> Void){
        guard let quantityType = self.waterType else {
            print("Error: Unable to get dietaryWater type")
            completion([])
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let weekday = calendar.component(.weekday, from: now)
        let daysSinceMonday = (weekday == 1 ? 6 : weekday - 2)
        let startOfWeek = calendar.date(byAdding: .day, value: -daysSinceMonday, to: now)!
        let startOfWeekMidnight = calendar.startOfDay(for: startOfWeek)
        
        let endOfWeek = calendar.date(byAdding: .day, value: 6 - daysSinceMonday, to: now)!
        let endOfWeekMidnight = calendar.startOfDay(for: endOfWeek)

        let predicate = HKQuery.predicateForSamples(withStart: startOfWeekMidnight, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfWeekMidnight,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { _, results, error in
            guard let statsCollection = results else {
                print("Error fetching statistics: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            var drinkData: [(date: String, volume: Int)] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
                    
            statsCollection.enumerateStatistics(from: startOfWeekMidnight, to: endOfWeekMidnight) { statistics, _ in
                let date = statistics.startDate
                let dateString = dateFormatter.string(from: date)
                let drinkVolume = statistics.sumQuantity()?.doubleValue(for: self.volumeUnit) ?? 0
                drinkData.append((dateString, Int(drinkVolume)))
            }
            
            DispatchQueue.main.async {
                completion(drinkData)
            }
        }
        healthStore.execute(query)
    }
    
    func getThisMonthStatistic(completion: @escaping ([(date: String, volume: Int)]) -> Void){
        guard let quantityType = self.waterType else {
            print("Error: Unable to get dietaryWater type")
            completion([])
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfMonth,
            intervalComponents: DateComponents(day: 7)
        )
        
        query.initialResultsHandler = { _, results, error in
            guard let statsCollection = results else {
                print("Error fetching statistics: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            var drinkData: [(date: String, volume: Int)] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
                    
            statsCollection.enumerateStatistics(from: startOfMonth, to: endOfMonth) { statistics, _ in
                let date = statistics.startDate
                let dateString = dateFormatter.string(from: date)
                let drinkVolume = statistics.sumQuantity()?.doubleValue(for: self.volumeUnit) ?? 0
                drinkData.append((dateString, Int(drinkVolume)))
            }
            
            DispatchQueue.main.async {
                completion(drinkData)
            }
        }
        healthStore.execute(query)
    }
    
    func getThisYearStatistic(completion: @escaping ([(date: String, volume: Int)]) -> Void){
        guard let quantityType = self.waterType else {
            print("Error: Unable to get dietaryWater type")
            completion([])
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
        let endOfYear = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfYear, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfYear,
            intervalComponents: DateComponents(month: 1)
        )
        
        query.initialResultsHandler = { _, results, error in
            guard let statsCollection = results else {
                print("Error fetching statistics: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            var drinkData: [(date: String, volume: Int)] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
                    
            statsCollection.enumerateStatistics(from: startOfYear, to: endOfYear) { statistics, _ in
                let date = statistics.startDate
                let dateString = dateFormatter.string(from: date)
                let drinkVolume = statistics.sumQuantity()?.doubleValue(for: self.volumeUnit) ?? 0
                drinkData.append((dateString, Int(drinkVolume)))
            }
            
            DispatchQueue.main.async {
                completion(drinkData)
            }
        }
        healthStore.execute(query)
    }
    
    
}
