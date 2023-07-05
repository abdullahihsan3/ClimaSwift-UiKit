//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation


class WeatherViewController: UIViewController {

    
    var weatherManager = WeatherManager()
    let coreLocation = CLLocationManager()
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBAction func locationPressed(_ sender: UIButton) {
        
        coreLocation.requestLocation()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        coreLocation.delegate = self
        coreLocation.requestWhenInUseAuthorization()
        coreLocation.requestLocation()
        searchTextField.delegate = self
    }
    
}
//MARK: -- WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate{
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        print("Weather Temperature In VC: " + String(weather.temperature))
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
        }
       
        
    }
}

//MARK: -- UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate{
    
    @IBAction func onSearchPressed(_ sender: UIButton) {
        weatherManager.delegate = self
        print(searchTextField.text!)
        searchTextField.endEditing(true)
        
    }
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text!)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Use searchTextField.text
        if let city = searchTextField.text {
            weatherManager.fetchWeather(city: city)
        }
        
        textField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(textField.text != ""){
            return true
        }
        else{
            textField.placeholder = "Type something"
            return false
        }
    }
}

extension WeatherViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location Data \(locations.description)")
        if let location = locations.last{
            coreLocation.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(lat: lat,lon:lon)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error Is: \(error)")
    }
}
