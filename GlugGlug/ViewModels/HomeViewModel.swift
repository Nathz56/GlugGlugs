//
//  HomeViewModel.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 27/03/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var goal: Int {
        didSet { UserDefaults.standard.set(goal, forKey: "goal") }
    }
    
    @Published var glassOptions: [GlassOption] = [] {
        didSet {
            saveGlassOptions()
        }
    }
    
    @Published var weight: Int {
        didSet { UserDefaults.standard.set(weight, forKey: "weight") }
    }
    
    init() {
        let savedGoal = UserDefaults.standard.object(forKey: "goal") as? Int
        let savedWeight = UserDefaults.standard.object(forKey: "weight") as? Int

        self.goal = savedGoal ?? 2500
        self.weight = savedGoal ?? 70
        self.glassOptions = self.loadGlassOptions()
    }
    
    func editWeight(_ newWeight: Int) {
        weight = newWeight
    }
    
    func editGoal(_ newGoal: Int) {
        goal = newGoal
    }
    
    func addGlass(icon: String, amount: Int) {
        let newGlass = GlassOption(icon: icon, amount: amount)
        glassOptions.append(newGlass)
        saveGlassOptions()
    }
    
    func removeGlass(at index: Int) {
        guard glassOptions.indices.contains(index) else { return }
        glassOptions.remove(at: index)
        saveGlassOptions()
    }
    
    private func saveGlassOptions() {
        if let encoded = try? JSONEncoder().encode(glassOptions) {
            UserDefaults.standard.set(encoded, forKey: "glassOptions")
        }
    }
    
    private func loadGlassOptions() -> [GlassOption] {
        if let data = UserDefaults.standard.data(forKey: "glassOptions"),
           let decoded = try? JSONDecoder().decode([GlassOption].self, from: data) {
            return decoded
        }
        return [
            GlassOption(icon: "cup.and.saucer.fill", amount: 100),
            GlassOption(icon: "mug.fill", amount: 200),
            GlassOption(icon: "takeoutbag.and.cup.and.straw.fill", amount: 300),
        ]
    }
}
