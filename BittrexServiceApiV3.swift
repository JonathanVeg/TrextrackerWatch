//
//  BittrexServiceApiV3.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Silva on 28/11/20.
//

import Foundation

struct BittrexV3Result: Codable {
    let currencies: [Currency]
}

struct Currency: Codable {
    let symbol, high, low, volume: String
    let quoteVolume: String
    let percentChange: String?
    let updatedAt: String
    
    func coin() -> String {
        return String(symbol.split(separator: "-")[0])
    }
    
    func market() -> String {
        return String(symbol.split(separator: "-")[1])
    }
    
    func changes() -> Double {
        return Double(percentChange ?? "0.0")!
    }
    
    func spread() -> Double {
        return 0.0
        // return (ask != nil && Bid != nil && Ask != 0.0 && Bid != 0.0) ? (Ask! / Bid! - 1) * 100 : 0.0
    }
}

class BittrexV3Service {
    let coin: String;
    let market: String;
    
    init(coin: String, market: String) {
        self.coin = coin;
        self.market = market;
    }
    
    static func emptyCurrency() -> Currency {
        return Currency(symbol: "error", high: "0.0", low: "0.0", volume: "0.0", quoteVolume: "0.0", percentChange: "0.0", updatedAt: "0.0")
    }
    
    func getMarketSummaries(completion: @escaping (Result<[Currency], Error>) -> Void) {
        let url = URL(string: "https://api.bittrex.com/v3/markets/summaries")!
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
    
    private func parseSummaries(fromData data: Data) -> [Currency] {
        let result = try? JSONDecoder().decode(BittrexV3Result.self, from: data)
        
        if let resultD = result {
            return resultD.currencies
        }
        
        let empty = BittrexV3Service.emptyCurrency()
        
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

