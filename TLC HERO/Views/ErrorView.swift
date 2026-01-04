import SwiftUI

struct ErrorView: View {
    var retryAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text("No Internet Connection")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Please check your connection and try again.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: retryAction) {
                    Text("Try Again")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(25)
                }
            }
        }
    }
}
