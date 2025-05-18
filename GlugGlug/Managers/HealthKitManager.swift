//
//  HealthKitManager.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let volumeUnit = HKUnit.literUnit(with: .milli)
    private let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
    
    private var healthStore = HKHealthStore()
    
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
    
    func addWaterAmount(volume : Double, date: Date = Date()) {
        guard let quantityType = self.waterType else {
            print("Error: dietaryWater quantity type is nil")
            return
        }
        
        let drinkAmount = HKQuantity(unit: volumeUnit, doubleValue: volume)
        
        let data = HKQuantitySample(type: quantityType, quantity: drinkAmount, start: date, end: date)
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
            if let error = error {
                print("Error querying water volume: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let sum = result?.sumQuantity()
            let waterVolume = sum?.doubleValue(for: self.volumeUnit) ?? 0.0
            
            DispatchQueue.main.async {
                completion(Int(waterVolume))
            }
        }
        healthStore.execute(query)
    }
    
    func startObservingWaterIntake(updateHandler: @escaping (Int) -> Void) {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }

        let observerQuery = HKObserverQuery(sampleType: waterType, predicate: nil) { _, _, error in
            if let error = error {
                print("Observer error: \(error.localizedDescription)")
                return
            }

            self.getConsumedWaterToday { total in
                DispatchQueue.main.async {
                    updateHandler(total ?? 0)
                }
            }
        }

        healthStore.execute(observerQuery)

        // Background delivery
        healthStore.enableBackgroundDelivery(for: waterType, frequency: .immediate) { success, error in
            if !success {
                print("Background delivery failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    
    func fetchLatestWaterIntake() {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: waterType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], let latestSample = samples.first else {
                print("No water data found")
                return
            }

            let intakeInLiters = latestSample.quantity.doubleValue(for: HKUnit.literUnit(with: .milli))
            print("Latest water intake: \(intakeInLiters) mL")
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
    
    func getStreak(completion: @escaping (Int) -> Void) {
        let goal = (UserDefaults.standard.object(forKey: "goal") as? Int) ?? 2500
        let calendar = Calendar.current
        let now = Date()
        let anchorDate = calendar.startOfDay(for: now)
        
        guard let quantityType = self.waterType else {
            print("Error: Unable to get dietaryWater type")
            completion(0)
            return
        }
                
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { _, results, error in
            guard let statsCollection = results else {
                print("Error fetching water intake: \(error?.localizedDescription ?? "Unknown error")")
                completion(0)
                return
            }
            
            var streak = 0
            var encounteredToday = false
            
            let statisticsArray = statsCollection.statistics().reversed()
            
            for statistics in statisticsArray {
                let localDate = calendar.startOfDay(for: statistics.startDate.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT())))
                let waterConsumption = statistics.sumQuantity()?.doubleValue(for: self.volumeUnit) ?? 0.0
                
                if calendar.isDate(localDate, inSameDayAs: anchorDate) {
                    encounteredToday = true
                    if waterConsumption >= Double(goal) {
                        streak += 1
                    }
                    continue
                }
                
                if waterConsumption >= Double(goal) {
                    streak += 1
                } else if encounteredToday {
                    break
                }
            }
            
            DispatchQueue.main.async {
                completion(streak)
            }
        }
        
        healthStore.execute(query)
    }
    
    func getGoalAchieved(completion: @escaping (Int) -> Void) {
        let goal = (UserDefaults.standard.object(forKey: "goal") as? Int) ?? 2500
        let calendar = Calendar.current
        let now = Date()
        let anchorDate = calendar.startOfDay(for: now)
        
        guard let quantityType = self.waterType else {
            print("Error: Unable to get dietaryWater type")
            completion(0)
            return
        }
                
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { _, results, error in
            guard let statsCollection = results else {
                print("Error fetching water intake: \(error?.localizedDescription ?? "Unknown error")")
                completion(0)
                return
            }
            
            var goalAchieved = 0
            
            for statistics in statsCollection.statistics() {
                let waterConsumption = statistics.sumQuantity()?.doubleValue(for: self.volumeUnit) ?? 0.0
                if waterConsumption >= Double(goal) {
                    goalAchieved += 1
                }
            }

            DispatchQueue.main.async {
                completion(goalAchieved)
            }
        }
        
        healthStore.execute(query)
    }
}
