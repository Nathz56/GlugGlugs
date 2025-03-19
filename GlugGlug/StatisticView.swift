//
//  StatisticView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI
import Charts

struct ToyShape: Identifiable {
    var type: String
    var count: Float
    var id = UUID()
}

struct StatisticView: View {
    @State private var animatedData: [ToyShape] = []
    @State private var scale: CGFloat = 0 // Mulai dari 0 agar tidak terlihat

    var originalData: [ToyShape] = [
        .init(type: "Sunday", count: 1.5),
        .init(type: "Monday", count: 1.75),
        .init(type: "Tuesday", count: 2.1),
        .init(type: "Wednesday", count: 1.5),
        .init(type: "Thursday", count: 1.75),
        .init(type: "Friday", count: 2.1),
        .init(type: "Saturday", count: 2.75),
    ]
    
    var body: some View {
        VStack{
            Chart {
                ForEach(animatedData) { shape in
                    BarMark(
                        x: .value("Shape Type", shape.type),
                        y: .value("Total Count", shape.count)
                    )
                    
                }
                
                RuleMark(y: .value("Break Even Threshold", 2))
                    .foregroundStyle(.red)
                
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2)) {
                    animateBars()
                }
            }
            
            .chartYScale(domain: 0...2.5)
            .chartYAxis {
                AxisMarks(
                    values: stride(from: 0, to: 3, by: 0.25).map { $0 } // Custom tick values
                ) { value in
                    AxisValueLabel() // Menampilkan label angka
                    AxisTick() // Menampilkan garis kecil pada tick
                    AxisGridLine() // Menampilkan garis grid (opsional)
                }
            }
            Spacer()
            Spacer()
            HStack{
                Spacer()
                VStack {
                    HStack{
                        VStack{
                            Text("Streak")
                            Text("7 Days")

                        }
                        Text("💧")

                    }
                }
                .backgroundStyle(.red)
                .padding(8)
                .border(.blue, width: 2)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.blue, lineWidth: 2)
                )
                
                Spacer()
                VStack {
                    Text("Goal Achieved")
                    Text("3")
                }
                Spacer()
            }
        }.padding(8)
            .frame(height: 300)
        
    }
    func animateBars() {
        animatedData = originalData.map { ToyShape(type: $0.type, count: 0) } // Semua dimulai dari 0
        
        for (index, shape) in originalData.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.2)) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animatedData[index] = shape
                }
            }
        }
        
        // Aktifkan efek pop-up setelah semua bar muncul
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1 // Munculkan Chart dengan efek pop-up
            }
        }
    }
}

#Preview {
    StatisticView()
}
