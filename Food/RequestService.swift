//
//  RequestService.swift
//  Food
//
//  Created by Eamon Woods on 7/31/17.
//
//

import Foundation

class RequestService {
    
    let urlSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let apiUrl = "https://api.nal.usda.gov/ndb/reports/"
    
    func getFoodReport(ndbno: String, cb: @escaping (String, [String: [String: Double]], [String]) -> ()) {
        dataTask?.cancel()
        guard var urlComponents = URLComponents(string: apiUrl) else { return }
        urlComponents.query = "ndbno=\(ndbno)&type=f&api_key=oCHvjrL6ZNqKf42mosy3ngoWj2o4U7SGhTF8puBp"
        guard let url = urlComponents.url else { return }
        dataTask = urlSession.dataTask(with: url, completionHandler: { (data, urlResponse, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let (type,nutrients, acceptableMeasurements) = self.getInfoFromFoodRequest(data: data)
                if let type = type,
                let nutrients = nutrients,
                    let acceptableMeasurements = acceptableMeasurements {
                    cb(type,nutrients, acceptableMeasurements)
                } else {
                    print("Could not get type, nutrients, acceptablemeasurements from food report data")
                }
            } else {
                print("Could not get food report data form url")
            }
        })
        dataTask?.resume()
    }
    
    func getInfoFromFoodRequest(data: Data) -> (String?, [String: [String: Double]]?, [String]?) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
        let report = json?["report"] as? [String: Any],
        let food = report["food"] as? [String: Any],
            let type = food["fg"] as? String else {
                print("Could not get type of food")
                return (nil, nil, nil)
        }
        guard let nutrients = food["nutrients"] as? [[String: Any]] else { return (nil, nil, nil) }
        var nutrientsAndTheirValues: [String: [String: Double]] = [:]
        var measurements: [String: Int] = [:]
        for nutrient in nutrients {
            guard let name = nutrient["name"] as? String,
                let unit = nutrient["unit"] as? String else { return (nil, nil, nil) }
            if name == "Water" || (name == "Energy" && unit == "kcal") || name == "Protein" || name == "Total lipid (fat)" || name == "Carbohydrate, by difference" || name == "Fiber, total dietary" || name == "Sugars, total" {
                    guard let value100g = nutrient["value"] as? Double,
                        let measures = nutrient["measures"] as? [[String: Any]] else { return (nil, nil, nil) }
                    nutrientsAndTheirValues[name] = [:]
                    nutrientsAndTheirValues[name]?["100g"] = value100g
                    for measure in measures {
                        guard let label = measure["label"] as? String,
                        let value = measure["value"] as? Double,
                            let quantity = measure["qty"] as? Double else { return (nil, nil, nil) }
                        if measurements[label] == nil {
                           measurements[label] = 1
                        } else {
                           measurements[label] = measurements[label]! + 1
                        }
                        nutrientsAndTheirValues[name]?[label] = value / quantity
                    }
                }
        }
        var acceptableMeasurements: [String] = ["grams"] //For all nutrients, always have value for a 100gmeasurement of the food
        for (measurement, frequency) in measurements {
            if frequency == 7 {
                //i.e. every nutrient is measured in terms of thismeasurement
                acceptableMeasurements.append(measurement)
            }
        }
        return (type,nutrientsAndTheirValues,acceptableMeasurements)
    }
}
