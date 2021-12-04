

import Foundation

import SwiftUI

struct WelcomeScreenView: View {
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    let screenSize = UIScreen.main.bounds.size
    @State private var showingSheet = false
    
    var body: some View {
        
        
        NavigationView {
            
            ZStack{
                Color("GreyColor").ignoresSafeArea()

                VStack{
                    
                    
                    Text("Hey! Welcome")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    VStack{
                        Text("We deliver on-demand fresh fruits directly from your nearby farms.")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center).padding(EdgeInsets(top:1, leading: 0, bottom: 0, trailing: 0))
                        
                    }.frame(maxWidth: screenWidth * 0.875)
                    Button(action: {
                        
                    }) {
                        Text("Get Started").foregroundColor(Color.black).fontWeight(.medium)
                    }
                    .frame(maxWidth: screenWidth * 0.875, maxHeight: screenHeight * 0.0625)
                    .background(Color("MainColor"))
                    
                    .cornerRadius(12)
                    .padding(EdgeInsets(top: screenHeight * 0.0275, leading: 0, bottom: screenHeight * 0.007, trailing: 0))
                    
                    
                    
                    Button(action: {
                        showingSheet.toggle()
                        
                    }) {
                        Text("I already have an account").foregroundColor(Color.black).fontWeight(.medium).padding(15)
                    }
                    .frame(maxWidth: screenWidth * 0.875)
                    .background(Color.white)
                    .cornerRadius(12).sheet(isPresented: $showingSheet) {
                        LoginScreenView()
                    }
                    
                    //                    NavigationLink(destination: LoginScreenView()) {
                    //                        Text("Go To Next Step")
                    //                    }
                    
                }
                
                
            }
        }
    }
}

struct WelcomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreenView()
            .previewDevice("iPhone 11")
            .previewInterfaceOrientation(.portrait)
    }
}


