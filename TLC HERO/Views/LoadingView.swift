import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading TLC Hero...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
    }
}
