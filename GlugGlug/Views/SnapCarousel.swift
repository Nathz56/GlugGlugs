//
//  SnapCarousel.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 07/04/25.
//

import SwiftUI

struct SnapCarousel: View {
    let items: [GlassOption]
    @Binding var selectedIndex: Int
    
    let itemWidth: CGFloat = 60
    let spacing: CGFloat = 16
    
    @State private var scrollViewWidth: CGFloat = 0
    @State private var itemPositions: [CGFloat] = []
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            VStack (spacing: 8) {
                                Image(systemName: item.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .background(selectedIndex == index ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                                    .scaleEffect(selectedIndex == index ? 1.2 : 1.0)
                                
                                Text("\(item.amount) ml")
                                    .font(.caption)
                                    .foregroundColor(selectedIndex == index ? .blue : .gray)
                            }
                            .frame(width: itemWidth, height: 90)
                            .id(index)
                            .onTapGesture {
                                withAnimation {
                                    proxy.scrollTo(index, anchor: .center)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                            withAnimation {
                                                selectedIndex = index
                                            }
                                        }
                                }
                            }
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        let globalCenter = geometry.frame(in: .global).midX
                                        let itemCenter = geo.frame(in: .global).midX
                                        let distance = abs(itemCenter - globalCenter)
                                        
                                        if itemPositions.count == items.count {
                                            itemPositions[index] = distance
                                        } else {
                                            itemPositions.append(distance)
                                        }
                                        
                                        if let min = itemPositions.min(), let i = itemPositions.firstIndex(of: min), i != selectedIndex {
                                            selectedIndex = i
                                        }
                                    }
                                    return Color.clear
                                }
                            )
                        }
                    }
                    .padding(.horizontal, (geometry.size.width - itemWidth) / 2)
                }
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            withAnimation {
                                proxy.scrollTo(selectedIndex, anchor: .center)
                            }
                        }
                )
            }
            .onAppear {
                itemPositions = Array(repeating: .infinity, count: items.count)
                scrollViewWidth = geometry.size.width
            }
        }
        .frame(height: 100)
    }
}
