import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.9) // Slight transparency if overlaying content
            
            VStack {
                ZStack {
                    // Outer rotating ring
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [.yellow, .orange]), center: .center),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Inner pulsing circle
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.yellow)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.5)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                }
                .onAppear {
                    isAnimating = true
                }
                
                Text("TLC HERO")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
    }
    
    @State private var isAnimating = false
}
