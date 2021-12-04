//
//  apiBrain.swift
//  Swift_login
//
//  Created by Umaiz Khan on 17/11/2021.
//

import Foundation
import Alamofire
struct LoginData : Decodable {
    let message : String
    let data : LoginUserDataToken
    
}
struct LoginUserDataToken : Decodable { let token : String }



struct ApiBrain {
    
    func LoginApi(userEmail: String, userPassword: String) -> Bool {
        
        print(userEmail)
        print(userPassword)
        let parameters = ["identity": userEmail, "password": userPassword]
        
        let session = URLSession.shared
        let url = URL(string: "http://40.86.255.119/api/Authentication")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let json = ["identity": userEmail, "password": userPassword]
                
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            
            if let safeData = data{
                self.parseJSON(loginData: safeData)
            }
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
        }
        
        task.resume()
        
        
        return true;
        
    }
    func parseJSON(loginData: Data){
        let decoder = JSONDecoder()
        do{
            let decodedData =  try decoder.decode(LoginData.self, from: loginData)
            print(decodedData)
            print(decodedData.message)
            print(decodedData.data.token)
        }
        catch{
            print(error)
        }
        
    }
    
}
