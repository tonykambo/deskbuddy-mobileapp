//
//  TemperatureService.swift
//  Desk Buddy
//
//  Created by Tony Kambourakis on 14/4/17.
//  Copyright © 2017 Kamboville. All rights reserved.
//

import Foundation

class TemperatureService {
    
    let endpoint = "http://127.0.0.1:1880/climate"
    
    func requestTemperature(completion: @escaping ([Climate]?)->Void) {
        print("GET \(endpoint)")
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["deviceid":"nodemcu1001"];
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            var climateReadings: [Climate] = []
            
            guard error == nil else {
                print("Error calling \(self.endpoint) with errorMessg=\(error)")
                return;
            }
            
            guard let responseData = data else {
                print("Error did not receive data")
                return
            }
            
            do {
                
                guard let weather = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: Any]] else {
                    print("error tryign to de-serialize json")
                    return
                }
                
                print("Weather = \(weather.description)")
                
                for case let result in weather {
                    if let climateReading = Climate(json: result) {
                        climateReadings.append(climateReading)
                    }
                    
                }
                
                completion(climateReadings)
//                
//                if let tempValue = weather[0]["humidity"] as? Double {
//                    
//                        print("Climate temperature = \(tempValue)")
//                    
//                    //print("Climate temperature=\(tempStructure["humidity"])")
//                } else {
//                    print("not a decimal")
//                }
//                
//                if let dateValue = weather[0]["dateMeasured"] as? String {
//                    print("dateValue = \(dateValue)")
//                } else {
//                    print("date is not a string")
//                }
                
 
            } catch {
                print("error trying to convert data to json")
                return
            }
            
        }
        task.resume()

    }
    
}
