//
//  CoinListView.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Silva on 04/11/20.
//

import SwiftUI

struct CoinListView: View {
    private let favoriteRepository = FavoriteRepository.init()
    
    @State private var data: [CoinData] = FavoriteRepository().readCoinList()
    @State private var homeOptions = FavoriteRepository().readHomeScreenOptions()
    
    @State private var sortingBy = "Name"
    @State private var market = "BTC"
    @State private var markets: [String] = []
    @State private var marketInBtc: Double = 0.0
    
    @State private var fiat = FavoriteRepository().readFiat()
    @State private var fiatData: FiatData = FavoriteRepository().readFiatData(fiat: FavoriteRepository().readFiat())
    
    @State private var lastUpdate: String = FavoriteRepository().readLastUpdate()
    
    var bgColorDown: UIColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
    var bgColorUp: UIColor = UIColor(red: 0/255, green: 60/255, blue: 0/255, alpha: 1.0)
    
    func sortedData() -> [CoinData] {
        let favorites = favoriteRepository.readFavorites()
        
        var ret = self.data.filter { it in it.market().uppercased() == market }
        
        if sortingBy == "Name" {
            ret = ret.sorted { (a, b) in a.coin() < b.coin() }
        } else if (sortingBy == "Volume") {
            ret = ret.sorted { (a, b) in a.BaseVolume ?? 0 > b.BaseVolume ?? 0 }
        } else if (sortingBy == "Changes +-") {
            ret = ret.sorted { (a, b) in a.changes() > b.changes() }
        } else {
            ret = ret.sorted { (a, b) in a.changes() < b.changes() }
        }
        
        let favs = ret.filter { it in favorites.contains(String(it.coin())) }
        let nonFavs = ret.filter { it in !favorites.contains(String(it.coin())) }
        
        return favs + nonFavs
    }
    
    func favoriteItem(item: CoinData) {
        favoriteRepository.addFavorite(coin: item.coin())
        data = [] + data
    }
    
    func rowHeader() -> some View {
        return VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Market").font(.footnote)
                    Spacer()
                    Text(market)
                }.onTapGesture {
                    let index = (markets.firstIndex(of: market) ?? 0)
                    market = markets[(index + 1) % markets.count]
                    
                    setMarketInBtc()
                    
                    favoriteRepository.saveMarket(market: market)
                }
                
                Spacer()
                Spacer()
                
                Image(systemName: "arrow.clockwise.circle")
                    .resizable().frame(width: 30, height: 30)
                    .onTapGesture(perform: loadData)
                
                Spacer()
                
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .resizable().frame(width: 30, height: 30)
                }
            }
            
            Text("\(lastUpdate)").font(.footnote).foregroundColor(.gray)
        }
    }
    
    func rowCoin(item: CoinData) -> some View {
        let bgColor = item.changes() >= 0 ? bgColorUp : bgColorDown
        
        return
            NavigationLink(destination: ContentView(item: item)) {
                HStack {
                    Image(systemName: favoriteRepository.readFavorites().contains(String(item.coin())) ? "suit.heart.fill" : "suit.heart")
                        .resizable().frame(width: 26, height: 26)
                        .onTapGesture { favoriteItem(item: item) }
                    
                    Spacer()
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        VStack {
                            Text("\(item.MarketName)").bold().font(.footnote)
                        }
                        HStack {
                            Text("$").bold().font(.footnote)
                            Text("\((item.Last ?? 0.0).idealDecimalPlaces())").font(.footnote)
                        }.font(.footnote)
                        HStack {
                            Text("\(fiat)").bold().font(.footnote)
                            Text("\(String(format: "%.3f", fiatData.last * (item.Last ?? 0.0) * marketInBtc))").font(.footnote)
                        }.font(.footnote)
                        Text("\(String(format: "%.1f", item.changes()))%").font(.footnote).foregroundColor(.gray)
                    }
                }.padding([.vertical])
            }.listRowBackground(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(bgColor)))
    }
    
    var body: some View {
        Group {
            List {
                rowHeader()
                ForEach(sortedData(), id: \.MarketName) { item in
                    rowCoin(item: item)
                }
            }.navigationBarTitle("Trextracker").onAppear(perform: loadData)
        }
    }
    
    func setMarketInBtc() {
        if self.market == "BTC" {
            self.marketInBtc = 1.0
            
            return
        }
           
        var marketInBtcData = self.data.filter { it in it.market() == "BTC" && it.coin() == self.market}
            
        if marketInBtcData.count > 0 {
            self.marketInBtc = marketInBtcData[0].Last!
        } else {
            marketInBtcData = self.data.filter { it in it.market() == self.market && it.coin() == "BTC"}
            
            if marketInBtcData.count > 0 {
                self.marketInBtc = 1.0 / marketInBtcData[0].Last!
            }
        }
    }
    
    func loadData() {
        self.sortingBy = favoriteRepository.readSort()
        self.fiat = FavoriteRepository().readFiat()
        
        let lastLastUpdate = self.lastUpdate
        
        self.lastUpdate = "loading..."
        BittrexService.init(coin: "", market: "").getMarketSummaries { (result) in
            var data: [CoinData] = self.data
            
            if case .success(let fetchedData) = result {
                data = fetchedData
                
                FavoriteRepository().saveCoinList(coinList: data)
                
                self.lastUpdate = Date().asString()
                
                FavoriteRepository().saveLastUpdate(lastUpdate: lastUpdate)
            } else {
                self.lastUpdate = lastLastUpdate
            }
            
            self.markets = Array(Set(data.map { item in
                item.market()
            }))
            
            self.market = favoriteRepository.readMarket()
            
            self.data = data

            setMarketInBtc()
            
            let service: FiatService = fiat == "USD" ? USDService() : BRLService()
            
            service.getData { result in
                var data: FiatData = self.fiatData;
                
                if case .success(let fetchedData) = result {
                    data = fetchedData
                    
                    FavoriteRepository().saveFiatData(fiat: fiat, fiatData: data)
                } 
                
                self.fiatData = data
                
                setMarketInBtc()
            }
        }
    }
}

struct CoinListView_Previews: PreviewProvider {
    static var previews: some View {
        CoinListView()
    }
}
