//
//  HomeView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case editGoal
    case editGlass

    var id: String {
        switch self {
        case .editGoal: return "editGoal"
        case .editGlass: return "editGlass"
        }
    }
}


struct HomeView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State var startAnimation: CGFloat = 0.0
    @State var progressPercentage: CGFloat = 0.0
    @State private var activeSheet: ActiveSheet?
    
    @State private var selectedGlassAmount: Int = 100
    
    @State private var selectedIndex: Int = 0
    
    @State private var progress: Int = 0
    
    @State private var streak: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack () {
//                Text("⏰ No reminders set! Add one to stay on track! 💧")
//                    .font(.subheadline)
//                    .padding(.vertical, 8)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal)
                
//                AlertBanner(message: "Welcome! 🚀 Set your reminder, target, and tumbler size to stay hydrated! 💧", iconName: "lightbulb.fill", backgroundColor: .yellow.opacity(0.2), foregroundColor: .yellow, textColor: .primary)
//                    .padding(.bottom, 8)
//                    .padding(.horizontal)
                HStack () {
                    StreakView(streakCount: streak)
                }
                .padding()
                
                
                
                Spacer()
                
                Text("\(progress) ml")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 2)
                
                HStack{
                    Text("\(Int(progressPercentage * 100))% of your ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    +
                    Text("\(homeViewModel.goal) ml ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .bold()
                    +
                    Text("goal")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button {
                        activeSheet = .editGoal
                    } label: {
                        Image(systemName: "square.and.pencil")
                        
                    }
                }
                .padding(.bottom)
                Spacer()
                
                WaterIndicator(progress: $progressPercentage, startAnimation: $startAnimation)
                    .padding(.bottom, 8)
                Spacer()
                
                GlassPicker(items: homeViewModel.glassOptions, selectedIndex: $selectedIndex,
                            onTap: {
                    activeSheet = .editGlass
                })
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    AudioManager.shared.playSound(named: "liquid-bubble.wav")
                    HealthKitManager.shared.addWaterAmount(volume: Double(homeViewModel.glassOptions[selectedIndex].amount))
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add \(homeViewModel.glassOptions[selectedIndex].amount) ml")
                            .font(.headline)
                    }
                }
                .buttonStyle(CustomButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom)
                Spacer()
                
            }
            
        }
        .onAppear {
            if homeViewModel.goal > 0 {
                progressPercentage = CGFloat(progress) / CGFloat(homeViewModel.goal)
            } else {
                progressPercentage = 0.0
            }
            
            HealthKitManager.shared.getConsumedWaterToday { data in DispatchQueue.main.async {
                self.progress = data ?? 0
            }}
            
            HealthKitManager.shared.startObservingWaterIntake { newProgress in
                self.progress = newProgress
            }
            
            HealthKitManager.shared.getStreak { streak in
                self.streak = streak
            }
            
        }
        .onChange(of: progress) {
            if homeViewModel.goal > 0 {
                progressPercentage = CGFloat(progress) / CGFloat(homeViewModel.goal)
            } else {
                progressPercentage = 0.0
            }
        }
        .onChange(of: homeViewModel.goal) {
            if homeViewModel.goal > 0 {
                progressPercentage = CGFloat(progress) / CGFloat(homeViewModel.goal)
            } else {
                progressPercentage = 0.0
            }
        }
        .tabItem {
            Image(systemName: "chart.line.uptrend.xyaxis")
            Text("Tracker")
        }
        .sheet(item: $activeSheet) { item in
            sheetView(for: item)
        }

        
    }
    
    @ViewBuilder
    func sheetView(for item: ActiveSheet) -> some View {
        switch item {
        case .editGoal:
            EditGoalView()
        case .editGlass:
            EditGlassView(selectedIndex: $selectedIndex)
        }
    }
    
    func didDismiss() {
        // Handle the dismissing action.
    }
    
    func getClosestIndex(to center: CGFloat, in geo: GeometryProxy) -> Int {
        var closestIndex = 0
        var minDistance = CGFloat.infinity
        for (i, _) in homeViewModel.glassOptions.enumerated() {
            let itemMid = geo.frame(in: .global).midX
            let distance = abs(itemMid - center)
            if distance < minDistance {
                minDistance = distance
                closestIndex = i
            }
        }
        return closestIndex
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
}


