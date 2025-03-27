//
//  HomeViewModel.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 27/03/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var progress: Int {
        didSet { UserDefaults.standard.set(progress, forKey: "progress") }
    }
    
    @Published var goal: Int {
        didSet { UserDefaults.standard.set(goal, forKey: "goal") }
    }
    
    init() {
        let savedProgress = UserDefaults.standard.object(forKey: "progress") as? Int
        let savedGoal = UserDefaults.standard.object(forKey: "goal") as? Int
        
        self.progress = savedProgress ?? 0
        self.goal = savedGoal ?? 2500
    }
    
    func addProgress(_ amount: Int) {
        progress += amount
    }
    
    func resetProgress() {
        progress = 0
    }
    
    func editGoal(_ newGoal: Int) {
        goal = newGoal
    }
    
    
}


