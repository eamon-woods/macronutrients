//
//  SearchService.swift
//  Food
//
//  Created by Eamon Woods on 7/30/17.
//
//

import Foundation

class SearchService {
    
    let urlSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    let apiUrl = "https://api.nal.usda.gov/ndb/search/"
    
    func getFoodsMatchingSearch(search: String, completion: @escaping ([Food]) -> Void) {
        dataTask?.cancel()
        guard var urlComponents = URLComponents(string: apiUrl) else { return }
        let maxReturned = "100"
        urlComponents.query = "format=JSON&q=\(search)&max=\(maxReturned)&ds=Standard Reference&api_key=oCHvjrL6ZNqKf42mosy3ngoWj2o4U7SGhTF8puBp"
        guard let url = urlComponents.url else { return }
        dataTask = urlSession.dataTask(with: url, completionHandler: { (data, urlResponse, error) in
            if let error = error {
                print(error.localizedDescription)
                completion([])
            } else if let data = data,
                let foods = self.getFoodsFromData(data: data) {
                completion(foods)
            } else {
                completion([])
            }
        })
        dataTask?.resume()
    }
    
    func getFoodsFromData(data: Data) -> [Food]? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
        let list = json?["list"] as? [String: Any],
            let items = list["item"] as? [[String: Any]] else {
                return nil
        }
        var foods: [Food] = []
        for food in items {
            if let name = food["name"] as? String,
                let ndbno = food["ndbno"] as? String {
                var formattedName = name
                if let index = name.range(of: ", UPC:", options: .literal, range: nil, locale: nil)?.lowerBound {
                    formattedName = name.substring(to: index)
                }
                foods.append(Food(ndbno: ndbno, name: formattedName))
            }
        }
        return foods
    }
    
}
