//
//  ContentView.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Gonçalves Da Silva on 01/11/20.
//

import SwiftUI

struct MyData {
    var value: Double
}

struct ContentView: View {
    var item: CoinData = CoinData(MarketName: "DCR-BTC", High: 0.0, Low: 0.0, Volume: 0.0, Last: 0.0, BaseVolume: 0.0, Bid: 0.0, Ask: 0.0);
    
    @State private var data: CoinData = CoinData(MarketName: "DCR-BTC", High: 0.0, Low: 0.0, Volume: 0.0, Last: 0.0, BaseVolume: 0.0, Bid: 0.0, Ask: 0.0)
    @State private var lastUpdate: String = ""
    @State private var updateMessage: String = "updating..."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack {
                    Text("\(lastUpdate) \(updateMessage)").foregroundColor(.gray).font(.footnote).onTapGesture(perform: loadData)
                }
                HStack {
                    Text("$").bold()
                    Text("\((data.Last ?? 0.0).idealDecimalPlaces()) (\(String(format: "%.1f", data.changes()))%)")
                }
                HStack {
                    Text("Bid").bold()
                    Text("\((data.Bid ?? 0.0).idealDecimalPlaces())")
                }
                HStack {
                    Text("Ask").bold()
                    Text("\((data.Ask ?? 0.0).idealDecimalPlaces())")
                }
                HStack {
                    Text("Spread").bold()
                    Text("\(String(format: "%.2f", data.spread()))%")
                }
                HStack {
                    Text("↑").bold()
                    Text("\((data.High ?? 0.0).idealDecimalPlaces())")
                }
                HStack {
                    Text("↓").bold()
                    Text("\((data.Low ?? 0.0).idealDecimalPlaces())")
                }
                HStack {
                    Text("V").bold()
                    Text("\((data.BaseVolume ?? 0.0).idealDecimalPlaces())")
                }
            }
            
        }.navigationBarTitle(data.MarketName).onAppear(perform: loadData)
    }
    
    func loadData() {
        self.updateMessage = "(updating...)"
        BittrexService.init(coin: item.coin(), market: item.market()).getData { (result) in
            let data: CoinData
    
            if case .success(let fetchedData) = result {
              data = fetchedData
            } else {
              data = CoinData(High: 0.0, Low: 0.0, Volume: 0.0, Last: 0.0, BaseVolume: 0.0, Bid: 0.0, Ask: 0.0)
            }
            
            self.data = data
            self.lastUpdate = Date().asString()
            self.updateMessage = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

