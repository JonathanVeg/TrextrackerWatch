//
//  FiatService.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Silva on 10/11/20.
//

import Foundation

protocol FiatService {
    func getData(completion: @escaping (Result<FiatData, Error>) -> Void)
    func parseCoinData(fromData data: Data) -> FiatData
}

struct FiatData: Codable {
    let name: String;
    var last: Double = 0.0;
    var high: Double = 0.0;
    var low: Double = 0.0;
}

class USDService: FiatService {
    let name = "USD"
    struct Usd: Codable {
      let success: Bool
      let message: String
      let result: [Results]
    }

    struct Results: Codable {
        var Last: Double;
        var High: Double;
        var Low: Double;
    }

    func getData(completion: @escaping (Result<FiatData, Error>) -> Void) {
        let url = URL(string: "https://api.bittrex.com/api/v1.1/public/getmarketsummary?market=usd-btc")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                
                return
            }
            
            let ret = self.parseCoinData(fromData: data!)
            
            completion(.success(ret))
        }.resume()
    }
    
    func parseCoinData(fromData data: Data) -> FiatData {
        do {
            let result = try JSONDecoder().decode(Usd.self, from: data)
            
            let ticker = result.result[0]
            
            return FiatData(name: "USD", last: ticker.Last, high: ticker.High, low: ticker.Low)
            
        } catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
            
            return FiatData(name: "USD")
        }
    }
}

class BRLService: FiatService {
    let name = "BRL"
    struct Brl: Codable {
        let ticker: Ticker
    }
    
    struct Ticker: Codable {
        let high, low, vol, last: String
        let buy, sell, open: String
        let date: Int
    }
    
    func getData(completion: @escaping (Result<FiatData, Error>) -> Void) {
        let url = URL(string: "https://www.mercadobitcoin.net/api/BTC/ticker/")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                
                return
            }
            
            let ret = self.parseCoinData(fromData: data!)
            
            completion(.success(ret))
        }.resume()
    }
    
    func parseCoinData(fromData data: Data) -> FiatData {
        do {
            let result = try JSONDecoder().decode(Brl.self, from: data)
            
            let ticker = result.ticker
            
            return FiatData(name: "BRL", last: Double(ticker.last) ?? 0.0, high: Double(ticker.high) ?? 0.0, low: Double(ticker.low) ?? 0.0)
            
        } catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
            
            return FiatData(name: "BRL")
        }
    }
}
