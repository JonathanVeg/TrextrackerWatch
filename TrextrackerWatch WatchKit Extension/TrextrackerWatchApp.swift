//
//  TrextrackerWatchApp.swift
//  TrextrackerWatch WatchKit Extension
//
//  Created by Jonathan Gonçalves Da Silva on 01/11/20.
//

import SwiftUI

@main
struct TrextrackerWatchApp: App {
    @State private var currentPage = 0
    
    @SceneBuilder var body: some Scene {
        WindowGroup {

            NavigationView {
                PagerManager(pageCount: 2, currentIndex: $currentPage) {
                    CoinListView()
                    // BitcoinPriceView()
                }
            }
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
