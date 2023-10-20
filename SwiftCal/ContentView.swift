//
//  ContentView.swift
//  SwiftCal
//
//  Created by Joel Storr on 20.10.23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        animation: .default)
    private var days: FetchedResults<Day>

    var body: some View {
        NavigationView {
            List {
                ForEach(days) { day in
                    Text(day.date!.formatted())
                }
            }
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
