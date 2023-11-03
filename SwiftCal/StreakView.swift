//
//  StreakView.swift
//  SwiftCal
//
//  Created by Joel Storr on 21.10.23.
//

import SwiftUI
import CoreData

struct StreakView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(
            format: "(date >= %@) AND (date <= %@)",
            Date().startOfMonth as CVarArg,
            Date().endOfMonth as CVarArg
        ))
    private var days: FetchedResults<Day>

    @State private var streakValue = 0

    var body: some View {
        VStack {
            Text("\(streakValue)")
                .font(.system(size: 200, weight: .semibold, design: .rounded))
                .foregroundStyle(streakValue > 0 ? .orange : .pink)

            Text("Current Streak")
                .font(.title2)
                .bold()
                .foregroundStyle(.secondary)
        }
        .offset(y: -50)
        .onAppear { streakValue = calculateStreakValue() }
    }

    func calculateStreakValue() -> Int {
        guard !days.isEmpty else { return 0 }

        let noneFutureDays = days.filter { $0.date!.dayInt <= Date().dayInt }

        var streakCount = 0

        for day in noneFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                if day.date!.dayInt != Date().dayInt {
                    break
                }
            }
        }
        return streakCount
    }
}

#Preview {
    StreakView()
}
