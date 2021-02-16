//
//  FavoriteRepository.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Silva on 07/11/20.
//

import Foundation

class FavoriteRepository {
    let defaults = UserDefaults.standard
    
    func saveCoinList(coinList: [CoinData]) {
        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(coinList) {
            defaults.set(encoded, forKey: "CoinList")
        }
        
    }
    
    func readCoinList() -> [CoinData] {
        if let savedData = defaults.object(forKey: "CoinList") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(Array.self, from: savedData) as [CoinData]{
                return loadedData
            }
        }
        
        return []
    }
    
    func saveFiatData(fiat: String, fiatData: FiatData) {
        let encoder = JSONEncoder()
                
        if let encoded = try? encoder.encode(fiatData) {
            defaults.set(encoded, forKey: "FiatData\(fiat)")
        }
    }
    
    func readFiatData(fiat: String) -> FiatData {
        if let savedData = defaults.object(forKey: "FiatData\(fiat)") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(FiatData.self, from: savedData) {
                return loadedData
            }
        }
        
        return FiatData(name: fiat)
    }
    
    func saveLastUpdate(lastUpdate: String) {
        defaults.set(lastUpdate, forKey: "LastUpdate")
    }
    
    func readLastUpdate() -> String {
        return defaults.object(forKey: "LastUpdate") as? String ?? ""
    }
    
    func saveSort(sortBy: String) {
        defaults.set(sortBy, forKey: "SortBy")
    }
    
    func readSort() -> String {
        return defaults.object(forKey: "SortBy") as? String ?? "Name"
    }
    
    func saveMarket(market: String) {
        defaults.set(market, forKey: "Market")
    }
    
    func readMarket() -> String {
        return defaults.object(forKey: "Market") as? String ?? "BTC"
    }
    
    func saveFiat(fiat: String) {
        defaults.set(fiat, forKey: "Fiat")
    }
    
    func readFiat() -> String {
        return defaults.object(forKey: "Fiat") as? String ?? "USD"
    }
    
    func saveHomeScreenOptions(showOnHomeScreen: [String]) {
        defaults.set(showOnHomeScreen, forKey: "ShowOnHomeScreen")
    }
    
    func readHomeScreenOptions() -> [String] {
        return defaults.object(forKey: "ShowOnHomeScreen") as? [String] ?? ["Last", "High", "Low"]
    }
    
    func addFavorite(coin: String) {
        var currentFavorites = readFavorites()
        
        if (currentFavorites.contains(String(coin))) {
            currentFavorites = currentFavorites.filter { $0 != coin }
        } else {
            currentFavorites.append(coin)
        }
        
        defaults.set(currentFavorites, forKey: "Favorites")
    }
    
    func readFavorites() -> [String?] {
        let favorites: [String] = defaults.object(forKey: "Favorites") as? [String] ?? []
        
        return favorites
    }
}
