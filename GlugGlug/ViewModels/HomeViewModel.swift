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
    
    @Published var glassOptions: [GlassOption] = []
    
    init() {
        let savedGoal = UserDefaults.standard.object(forKey: "goal") as? Int

        self.goal = savedGoal ?? 2500
        self.glassOptions = self.loadGlassOptions()
    }
    
    func editGoal(_ newGoal: Int) {
        goal = newGoal
    }
    
    func addGlass(icon: String, amount: Int) {
        let newGlass = GlassOption(icon: icon, amount: amount)
        glassOptions.append(newGlass)
    }
    
    func removeGlass(at index: Int) {
        guard glassOptions.indices.contains(index) else { return }
        glassOptions.remove(at: index)
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
            GlassOption(icon: "wineglass.fill", amount: 400),
            GlassOption(icon: "trophy.fill", amount: 500)
        ]
    }
}
