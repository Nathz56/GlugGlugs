import SwiftUI

struct GlassPicker: View {
    let items: [GlassOption]
    @Binding var selectedIndex: Int
    let onTap: () -> Void

    let itemWidth: CGFloat = 60
    let spacing: CGFloat = 16

    @State private var scrollOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let totalItemWidth = itemWidth + spacing
            let screenMidX = geometry.size.width / 2

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(items.indices, id: \.self) { index in
                        GeometryReader { geo in
                            let itemMidX = geo.frame(in: .global).midX
                            let distance = abs(itemMidX - screenMidX)
                            let scale = max(0.8, 1 - distance / screenMidX)
                            let opacity = max(0.5, 1 - distance / screenMidX * 1.2)

                            VStack(spacing: 8) {
                                Image(systemName: items[index].icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .background(selectedIndex == index ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .clipShape(Circle())

                                Text("\(items[index].amount) ml")
                                    .font(.caption)
                                    .foregroundColor(selectedIndex == index ? .blue : .gray)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    scrollOffset = -CGFloat(index) * totalItemWidth
                                    selectedIndex = index
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }
                        }
                        .frame(width: itemWidth, height: 100)
                    }
                    GeometryReader { geo in
                        let itemMidX = geo.frame(in: .global).midX
                        let distance = abs(itemMidX - screenMidX)
                        let scale = max(0.8, 1 - distance / screenMidX)
                        let opacity = max(0.5, 1 - distance / screenMidX * 1.2)

                        Button {
                            onTap()
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())

                                Text("Add")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                        }
                    }
                    .frame(width: itemWidth, height: 100)

                }
                
                .padding(.horizontal, (geometry.size.width - itemWidth) / 2)
                .offset(x: scrollOffset + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { value, state, _ in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            scrollOffset += value.translation.width
                            dragOffset = 0

                            // Snap to nearest
                            _ = totalItemWidth * CGFloat(items.count)
                            let rawIndex = -scrollOffset / totalItemWidth
                            let nearestIndex = max(0, min(items.count - 1, Int(round(rawIndex))))

                            withAnimation(.easeOut) {
                                scrollOffset = -CGFloat(nearestIndex) * totalItemWidth
                                if selectedIndex != nearestIndex {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                                selectedIndex = nearestIndex
                            }
                        }
                )
            }
        }
        .frame(height: 90)
    }
}
