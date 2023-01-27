//
//  WeatherManager.swift
//  Clima
//
//  Created by Shaik Afroz on 12/01/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager,  weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=cf27dba08b6bb4d8ee53798b679ebfb7&units=metric"

    var delegate : WeatherManagerDelegate?

    func fetchWEather(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performNetworkReq(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
           let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performNetworkReq(with: urlString)
       }
    
    
    func performNetworkReq(with urlString : String){
        // Create a URL
        if let url = URL(string: urlString){
       //session Object
            
            
            let session = URLSession(configuration: .default)
            
            //sesion task
            let task  = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self ,weather: weather)

                    }
                    
                }
            }

            
            
            //Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
           let decodedData = try  decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            return weather
        }catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func getConditionName (weatherId: Int) -> String {
        switch weatherId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }}
    
    
    
}
