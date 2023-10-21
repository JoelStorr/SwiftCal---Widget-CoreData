//
//  SwiftCalApp.swift
//  SwiftCal
//
//  Created by Joel Storr on 20.10.23.
//

import SwiftUI

@main
struct SwiftCalApp: App {
    let persistenceController = PersistenceController.shared

    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            
            TabView(selection: $selectedTab ){
                CalendarView()
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                    .tag(0)
                StreakView()
                    .tabItem { Label("Streak", systemImage: "swift") }
                    .tag(1)
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .onOpenURL(perform: { url in
                selectedTab = url.absoluteString == "calendar" ? 0 : 1
            })
        }
    }
}
