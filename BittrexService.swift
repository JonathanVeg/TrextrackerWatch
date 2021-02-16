//
//  BittrexService.swift
//  extracker
//
//  Created by Jonathan Gonçalves Da Silva on 26/09/20.
//

import SwiftUI

struct ChartData: Codable {
  let success: Bool
  let message: String
  let result: [ChartResult]
}

struct ChartResult: Codable {
  let o, h, l, c: Double
  let v: Double
  let t: String
  let bv: Double
}

struct BittrexResult: Codable {
    var success: Bool
    var message: String
    var result: [CoinData]
}

struct CoinData: Codable {
    var MarketName: String = " - ";
    var High: Double?;
    var Low: Double?;
    var Volume: Double?;
    var Last: Double?;
    var BaseVolume: Double?;
    var TimeStamp: String?;
    var Bid: Double?;
    var Ask: Double?;
    var OpenBuyOrders: Int?;
    var OpenSellOrders: Int?;
    var PrevDay: Double?;
    var Created: String?;
    
    func coin() -> String {
        return String(MarketName.split(separator: "-")[1])
    }
    
    func market() -> String {
        return String(MarketName.split(separator: "-")[0])
    }
    
    func changes() -> Double {
        return (PrevDay != nil && Last != nil && PrevDay != 0.0) ? ((PrevDay! - Last!) / PrevDay!) * -100 : 0.0
    }
    
    func spread() -> Double {
        return (Ask != nil && Bid != nil && Ask != 0.0 && Bid != 0.0) ? (Ask! / Bid! - 1) * 100 : 0.0
    }
}

class BittrexService {
    let coin: String;
    let market: String;
    
    init(coin: String, market: String) {
        self.coin = coin;
        self.market = market;
    }
    
    func getMarketSummaries(completion: @escaping (Result<[CoinData], Error>) -> Void) {
        let url = URL(string: "https://api.bittrex.com/api/v1.1/public/getmarketsummaries?market=btc-dcr")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(self.parseSummaries(fromData: data!)))
        }.resume()
    }
    
    func getData(completion: @escaping (Result<CoinData, Error>) -> Void) {
        let url = URL(string: "https://api.bittrex.com/api/v1.1/public/getmarketsummary?market=\(market.lowercased())-\(coin.lowercased())")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            let ret = self.parseCoinData(fromData: data!)
            
            completion(.success(ret))
        }.resume()
    }
    
    func getChartData(completion: @escaping (Result<[ChartResult], Error>) -> Void) {
        let url = URL(string: "https://bittrex.com/Api/v2.0/pub/market/GetTicks?marketName=BTC-DCR&tickInterval=ThirtyMin")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                let ret = self.parseChartData(fromData: data!)
                
                completion(.success(ret))
            }.resume()
    }
    
    private func parseSummaries(fromData data: Data) -> [CoinData] {
        let result = try? JSONDecoder().decode(BittrexResult.self, from: data)
        
        if let resultD = result {
            return resultD.result
        }
        
        var empty = CoinData(High: 0.0, Low: 0.0, Volume: 0.0, Last: 0.0, BaseVolume: 0.0, Bid: 0.0, Ask: 0.0)
        
        empty.MarketName = "error"
        
        return [empty]
    }
    
    private func parseCoinData(fromData data: Data) -> CoinData {
        let result = try? JSONDecoder().decode(BittrexResult.self, from: data)
        
        if let resultD = result {
            return resultD.result[0]
        }
        
        return CoinData(High: 0.0, Low: 0.0, Volume: 0.0, Last: 0.0, BaseVolume: 0.0, Bid: 0.0, Ask: 0.0)
    }
    
    private func parseChartData(fromData data: Data) -> [ChartResult] {
        let result = try? JSONDecoder().decode(ChartData.self, from: data)
        
        if let resultD = result {
            return resultD.result
        }
        
        return [ChartResult(o: 1, h: 1, l: 1, c: 1, v: 1, t: "", bv: 1)]
    }
}

