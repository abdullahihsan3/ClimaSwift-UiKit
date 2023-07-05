//
//  WeatherManager.swift
//  Clima
//
//  Created by Abdullah Ihsan on 22/06/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//
import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=0a40d97ddd537ab849c800cee0695bf0&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(lat:CLLocationDegrees,lon:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(city: String){
        let urlString = "\(weatherURL)&q=\(city)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String){
    
        let session = URLSession(configuration: .default)
        if let url = URL(string: urlString) {
            let task = session.dataTask(with: url, completionHandler:  {(data: Data? , response: URLResponse?, error: Error?) in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = parseJSON(safeData){
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                }
            })
            task.resume()
        } else {
            print("could not open url, it was nil")
        }
      
    }
    
    func parseJSON(_ weatherData:Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp =  decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            print("Temperature Is: \(weather.temperatureString)")
            return weather
        } catch{
            print("Error Is: \(error)")
            delegate?.didFailWithError(error: error)
            return nil
        }
       }
}
