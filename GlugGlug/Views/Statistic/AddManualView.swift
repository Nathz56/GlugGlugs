//
//  EditGoalView.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 27/03/25.
//

import SwiftUI


struct AddManualView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var inputValue: String = "0"
    @State private var selectedDate = Date()
    
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
        NavigationStack {
            VStack {
                Spacer()
                Text("\(inputValue)")
                    .font(.largeTitle)
                +
                Text(" ml")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                DatePicker("Select time", selection: $selectedDate, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(.bottom)
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(numbers, id: \.self) { row in
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                    HealthKitManager.shared.addWaterAmount(volume: Double(inputValue) ?? 0, date: selectedDate)
                    dismiss()
                } label: {
                    Text("ADD")
                }
                .buttonStyle(CustomButtonStyle())
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .presentationDetents([.fraction(0.6)])
            .toolbar {
                ToolbarItem(placement: .principal) { // Title di tengah
                    Text("Add Manual")
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
    AddManualView()
}

