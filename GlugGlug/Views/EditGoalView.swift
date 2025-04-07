//
//  EditGoalView.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 27/03/25.
//

import SwiftUI


struct EditGoalView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            VStack () {
                Picker("Options", selection: $selectedSegment) {
                    Text("Recommendation").tag(0)
                    Text("Custom").tag(1)
                }
                .pickerStyle(.segmented)
                
                Spacer()
                
                if selectedSegment == 0 {
                    RecommendationView()
                } else {
                    CustomView()
                }
                Spacer()
            }
            .padding(.horizontal)
            .presentationDetents([.fraction(0.56)])
            .toolbar {
                ToolbarItem(placement: .principal) { // Title di tengah
                    Text("Edit Goal")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct RecommendationView: View {
    @State private var selectedWeight: Int = 50
    
    var body: some View {
        VStack {
            Spacer()
            AlertBanner(message: "💦 Just enter your weight, and we’ll tell you how much water you need daily! 😊", iconName: "lightbulb.fill", backgroundColor: Color.blue.opacity(0.1), foregroundColor: Color.blue, textColor: Color.black)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Picker(selection: $selectedWeight, label: Text("")) {
                    ForEach(30...150, id: \.self) { weight in
                        Text("\(weight)") // Hanya angka di Wheel
                            .font(.title2)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 200)
                .clipped()
                
                Text("Kg")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Text("Set your target: \(selectedWeight) Kg")
            }
            .buttonStyle(.borderedProminent)
            
            
            
        }
    }
}

struct CustomView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var inputValue: String = "0"
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["00", "0", "⌫"]
    ]
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(inputValue)")
                .font(.largeTitle)
            +
            Text(" ml")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(numbers, id: \.self) { row in
                    ForEach(row, id: \.self) { item in
                        Button(action: {
                            handleInput(item)
                        }) {
                            Text(item)
                                .font(.title)
                                .frame(width: 100, height: 40)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                homeViewModel.editGoal(Int(inputValue) ?? 2500)
                dismiss()
            } label: {
                Text("Set your target")
            }
            .buttonStyle(.borderedProminent)
        }
        
    }
    
    func handleInput(_ value: String) {
        if value == "⌫" {
            if inputValue.count == 1 {
                inputValue = "0"  // Kalau tinggal 1 angka, reset ke "0"
            } else {
                inputValue.removeLast()
            }
        } else if value == "00" && inputValue == "0" {
            return  // Jika input "0" lalu tekan "00", tetap jadi "0"
        } else {
            if inputValue == "0" || inputValue == "00"{
                inputValue = value // Ganti langsung kalau masih "0"
            }
            else {
                inputValue.append(value)
            }
        }
    }
    
}


#Preview {
    EditGoalView()
}

