import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            // Background Color
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                Spacer()
                
                // App Name
                Text("NeatNote")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black) // Use a specific color to ensure visibility
                
                // Loading Indicator
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(0.75) // Adjust the scale to make the icon smaller
                
                Spacer()
            }
            .padding()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
