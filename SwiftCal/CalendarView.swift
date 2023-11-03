//
//  ContentView.swift
//  SwiftCal
//
//  Created by Joel Storr on 20.10.23.
//

import SwiftUI
import CoreData
import WidgetKit

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(
            format: "(date >= %@) AND (date <= %@)",
            Date().startOfCalanderWithPrefixDays as CVarArg,
            Date().endOfMonth as CVarArg
        ))
    private var days: FetchedResults<Day>

    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationView {
            VStack {
                CalendarHeaderView()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days) { day in
                        if day.date!.monthInt != Date().monthInt {
                            Text(" ")
                        } else {
                            Text(day.date!.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(day.didStudy ? .orange : .secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(.orange.opacity( day.didStudy ? 0.3 : 0))
                                )
                                .onTapGesture {
                                    if day.date!.dayInt <= Date().dayInt {
                                        day.didStudy.toggle()
                                        do {
                                            try viewContext.save()
                                            WidgetCenter.shared.reloadTimelines(ofKind: "SwiftCalWidget")
                                            print("👆 \(day.date!.dayInt) now studied.")
                                        } catch {
                                            print("Failed to save context")
                                        }
                                    } else {
                                        print("You can't study in the future")
                                    }
                                }
                        }
                    }
                }
                Spacer()
            }
                .navigationTitle(Date().formatted(.dateTime.month(.wide)))
                .padding()
                .onAppear {
                    if days.isEmpty {
                        createMonthDays(for: .now.startOfPreviousMonth)
                        createMonthDays(for: .now)
                    } else if days.count < 10 {
                        createMonthDays(for: .now)
                    }
                }
            }
    }

    func createMonthDays(for date: Date) {
        for daysOffset in 0..<date.numberOfDaysInMonth {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: daysOffset, to: date.startOfMonth)
            newDay.didStudy = false
        }

        do {
            try viewContext.save()
            print("✅ \(date.monthFullName) days Created")
        } catch {
            print("Faild to save")
        }
    }
}

#Preview {
    CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
