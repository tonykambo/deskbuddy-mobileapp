//
//  StatusService.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 16/4/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation

class StatusService {
    
    let localEndpoint = "http://127.0.0.1:1880/status"
    let remoteEndpoint = "https://deskbuddy.mybluemix.net/status"
    
    func requestStatus(completion: @escaping (String?)->Void) {
        let useLocal = UserDefaults.standard.bool(forKey: "localtarget_preference")
        
        let endpoint: String
        
        if useLocal {
            endpoint = localEndpoint
        } else {
            endpoint = remoteEndpoint
        }
        print("GET \(endpoint)")
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                print("Error calling \(endpoint) with errorMessg=\(error ?? "no error" as! Error)")
                return;
            }
            
            guard let responseData = data else {
                print("Error did not receive data")
                return
            }
            
            do {
                
                guard let deviceStatus = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error trying to de-serialize device status json");
                    return;
                }
                
                print("Device status = \(deviceStatus.description)")
                
                guard let status = deviceStatus["status"] as? Int else {
                    print("couldn't find status in return payload of device status request\n")
                    completion(nil)
                    return
                }
                var statusText = ""
                
                switch status {
                case 1:
                    statusText = "here"
                case 2:
                    statusText = "away"
                case 3:
                    statusText = "message"
                default:
                    statusText = "none"
                }
                print("returning device status=\(status)\n")
                completion(statusText)
                
            } catch {
                print("error trying to convert data to json")
                return
            }
            
        }
        task.resume()
    }
    
    func changeStatus(status: String, completion: @escaping (String)->Void) {
        let useLocal = UserDefaults.standard.bool(forKey: "localtarget_preference")
        
        let endpoint: String
        
        if useLocal {
            endpoint = localEndpoint + "/"+status
        } else {
            endpoint = remoteEndpoint + "/"+status
        }
        print("GET \(endpoint)")
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                print("Error calling \(endpoint) with errorMessg=\(error ?? "no error" as! Error)")
                return;
            }
        
            guard data != nil else {
                print("Error did not receive data ")
                return
            }
        
            
         
            
            completion("OK")
        }
        task.resume()
    }
}


