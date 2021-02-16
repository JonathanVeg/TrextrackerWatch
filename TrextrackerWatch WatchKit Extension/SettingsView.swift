//
//  ContentView.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Gonçalves Da Silva on 01/11/20.
//

import SwiftUI

struct SettingsView: View {
    @State private var homeOptions = ["Last", "High", "Low", "Bid", "Ask", "Fiat"]
    @State private var homeSelectedOptions = FavoriteRepository().readHomeScreenOptions()
    
    @State private var sortOptions = ["Name", "Volume", "Changes +-", "Changes -+"]
    @State private var sort = FavoriteRepository().readSort()
    
    @State private var fiats = ["USD", "BRL"]
    @State private var fiat = FavoriteRepository().readFiat()
    var body: some View {
        List {
            HStack(alignment: .center) {
                Text("Fiat")
            }
            
            ForEach(fiats, id: \.self) { item in
                rowFiat(item: item)
            }
            
            HStack(alignment: .center) {
                Text("Sort by")
            }
            
            ForEach(sortOptions, id: \.self) { item in
                rowSort(item: item)
            }

        }.navigationBarTitle("Settings").onAppear(perform: loadData)
    }
    
    func rowFiat(item: String) -> some View {
        return HStack {
            Image(systemName: fiat == item ? "circle.fill" : "circle")
                .resizable().frame(width: 23, height: 23)
                .onTapGesture {
                    fiat = item
                    
                    FavoriteRepository().saveFiat(fiat: item)
                }
            
            Text("\(item)")
        }
    }
    
    func rowHome(item: String) -> some View {
        return HStack {
            Image(systemName: homeSelectedOptions.contains(item) ? "circle.fill" : "circle")
                .resizable().frame(width: 23, height: 23)
                .onTapGesture {
                    if homeSelectedOptions.contains(item) {
                        homeSelectedOptions.remove(at: homeSelectedOptions.firstIndex(of: item)!)
                    } else {
                        homeSelectedOptions.append(item)
                    }
                    
                    FavoriteRepository().saveHomeScreenOptions(showOnHomeScreen: homeSelectedOptions)
                }
            
            Text("\(item)")
        }
    }
    
    func rowSort(item: String) -> some View {
        return HStack {
            Image(systemName: sort == item ? "circle.fill" : "circle")
                .resizable().frame(width: 23, height: 23)
                .onTapGesture {
                    sort = item
                    
                    FavoriteRepository().saveSort(sortBy: sort)
                }
            
            Text("\(item)")
        }
    }
    
    func loadData() {
        print("Load settings here")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

