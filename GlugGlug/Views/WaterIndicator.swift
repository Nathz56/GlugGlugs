//
//  WaterIndicator.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 26/03/25.
//

import SwiftUI

struct WaterIndicator: View {
    
    @Binding var progress: CGFloat
    @Binding var startAnimation: CGFloat
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Image(systemName: "drop.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.blue.opacity(0.1))
                    .scaleEffect(x:1.1, y:1)
                    .offset(y:-1)
                
                WaterWave(progress: progress, waveHeight: 0.1, offset: startAnimation)
                    .fill(Color.blue)
                    .overlay(content: {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 15, height: 15)
                                .offset(x:-20)
                            
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 15, height: 15)
                                .offset(x: 40, y: 30)
                            
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 25, height: 25)
                                .offset(x: -30, y: 80)
                            
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 25, height: 25)
                                .offset(x: 50, y: 70)
                            
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 10, height: 10)
                                .offset(x: 40, y: 100)
                            
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 10, height: 10)
                                .offset(x: -40, y: 50)
                            
                        }
                    })
                    .mask {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                
            }
            .frame(width: size.width, height: size.height, alignment: .center)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    startAnimation = size.width
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height/3)
    }
}

struct WaterWave : Shape {
    
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
        
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: .zero)
            
            let progressHeight = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            
            for value in stride( from: 0, to: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}
