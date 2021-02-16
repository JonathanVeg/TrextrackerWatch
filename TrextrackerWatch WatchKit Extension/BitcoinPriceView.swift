//
//  BitcoinPriceView.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Silva on 04/11/20.
//

import SwiftUI

struct BitcoinPriceView: View {
    private let favoriteRepository = FavoriteRepository.init()
    
    @State private var lastUpdate: String = FavoriteRepository().readLastUpdate()
   
    @State private var usdData: FiatData = FiatData(name: "USD")
    @State private var brlData: FiatData = FiatData(name: "BRL")
    
    func rowHeader() -> some View {
        return VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("BTC")
                }
                
                Spacer()
                
                Image(systemName: "arrow.clockwise.circle")
                    .resizable().frame(width: 30, height: 30)
                    .onTapGesture(perform: loadData)
            }
            
            Text("\(lastUpdate)").font(.footnote).foregroundColor(.gray)
        }
    }
    
    var body: some View {
        Group {
            List {
                rowHeader()
                
                rowUSD()
                rowBRL()
            }.navigationBarTitle("Trextracker").onAppear(perform: loadData)
        }
    }
    
    func row(data: FiatData) -> some View {
        VStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("\(data.name)").bold().font(.footnote)
                }
                HStack {
                    Text("$").bold().font(.footnote)
                    Text("\((data.last).idealDecimalPlaces())").font(.footnote)
                }.font(.footnote)
                HStack {
                    Text("↑").bold()
                    Text("\((data.high ).idealDecimalPlaces())")
                }.font(.footnote)
                HStack {
                    Text("↓").bold()
                    Text("\((data.low ).idealDecimalPlaces())")
                }.font(.footnote)
            }.padding([.vertical])
        }
    }
    
    func rowUSD() -> some View {
        return row(data: usdData)
    }
    
    func rowBRL() -> some View {
        return row(data: brlData)
    }
    
   
    
    func loadData() {
        self.lastUpdate = "loading..."
        
        let usdService: FiatService = USDService()
        
        usdService.getData { result in
            var data: FiatData = self.usdData;
            
            if case .success(let fetchedData) = result {
                data = fetchedData
                
                FavoriteRepository().saveFiatData(fiat: data.name, fiatData: data)
            }
            
            self.usdData = data
            self.lastUpdate = Date().asString()
        }
        
        let brlService: FiatService = BRLService()
        
        brlService.getData { result in
            var data: FiatData = self.usdData;
            
            if case .success(let fetchedData) = result {
                data = fetchedData
                
                FavoriteRepository().saveFiatData(fiat: data.name, fiatData: data)
            }
            
            self.brlData = data
            self.lastUpdate = Date().asString()
        }
    }
}

struct BitcoinPriceView_Previews: PreviewProvider {
    static var previews: some View {
        BitcoinPriceView()
    }
}
