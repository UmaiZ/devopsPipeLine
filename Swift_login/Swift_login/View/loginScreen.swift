import Foundation

import SwiftUI

struct LoginScreenView: View {
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    let screenSize = UIScreen.main.bounds.size
    var apiBrain = ApiBrain()
    
    @State var isEmailConfig:Bool = false
    @State var isPasswordConfig:Bool = false
    
    @State private var givenEmail: String = ""
    @State private var givenPassword: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack{
            Color("GreyColor").ignoresSafeArea()
            VStack{
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        Image(systemName: "xmark").font(.system(size: 20)).foregroundColor(.gray)
                    }
                    
                    Spacer()
                    Text("").foregroundColor(Color.gray)
                    
                }.padding(EdgeInsets(top: screenHeight * 0.0272, leading: screenWidth * 0.06, bottom: 0, trailing: screenWidth * 0.06))
                
                Text("Login an account")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black).padding(EdgeInsets(top: screenHeight * 0.022, leading: 0, bottom: screenHeight * 0.035, trailing: 0))
                
                TextField("Email Address", text: $givenEmail)
                    .foregroundColor(Color.gray).offset(x:10, y: 0)
                    .frame(height: screenHeight * 0.0625)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding([.horizontal], 4)
                    .onChange(of: givenEmail, perform: { value in
                        
                        print(givenEmail)
                        if(givenEmail == "" || givenEmail.contains("@")){
                            self.isEmailConfig = false;
                        }
                        else{
                            self.isEmailConfig = true;
                        }
                        
                    })
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .padding(EdgeInsets(top: 0, leading: screenWidth * 0.06, bottom: screenHeight * 0.01, trailing: screenWidth * 0.06))
                
                if self.isEmailConfig {
                    Text("Email is not valid")
                        .fontWeight(.medium)
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: screenWidth * 0.075, bottom: 0, trailing: 0))
                }
                TextField("Password", text: $givenPassword)
                    .foregroundColor(Color.gray).offset(x:10, y: 0)
                    .frame(height: screenHeight * 0.0625)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding([.horizontal], 4)
                    .onChange(of: givenPassword, perform: { value in
                        
                        print(givenPassword)
                        if(givenPassword == "" || givenPassword.count > 2){
                            self.isPasswordConfig = false;
                        }
                        else{
                            self.isPasswordConfig = true;
                        }
                        
                    })
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .padding(EdgeInsets(top: 0, leading: screenWidth * 0.06, bottom: screenHeight * 0.01, trailing: screenWidth * 0.06))
                
                if self.isPasswordConfig {
                    Text("Password is not valid")
                        .fontWeight(.medium)
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: screenWidth * 0.075, bottom: screenHeight * 0.01, trailing: 0))
                }
                Button(action: {
                    if(self.isEmailConfig || self.isPasswordConfig || givenPassword == "" || givenEmail == ""){
                        print("not valid")
                        
                    }
                    else{
                        let verifyLogin =  apiBrain.LoginApi(userEmail: givenEmail, userPassword: givenPassword)
                        print(verifyLogin)
                        
                    }
                    
                }) {
                    Text("Login").foregroundColor(Color.black).fontWeight(.medium).frame(maxWidth: screenWidth * 0.875, maxHeight: screenHeight * 0.0625)
                }
                
                .background(Color("MainColor"))
                
                .cornerRadius(12)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: screenHeight * 0.007, trailing: 0))
                
                
                Spacer()
                
                
            }
        }
    }
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
            .previewDevice("iPhone 11")
            .previewInterfaceOrientation(.portrait)
    }
}
