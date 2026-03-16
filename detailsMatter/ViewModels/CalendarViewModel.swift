import Foundation

@Observable
final class CalendarViewModel {
    var currentMonth: Date = Date()
    var availableDates: Set<String> = []
    var isLoading = false

    private let firestore = FirestoreService.shared
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: currentMonth)
    }

    var daysInMonth: [DayItem] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1
        var items: [DayItem] = Array(repeating: DayItem(day: 0, dateString: "", isPlaceholder: true), count: weekdayOfFirst)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                let str = dateFormatter.string(from: date)
                let isAvailable = availableDates.contains(str)
                let isPast = str < Self.todayString
                items.append(DayItem(day: day, dateString: str, isAvailable: isAvailable, isPast: isPast))
            }
        }
        return items
    }

    func loadAvailableDates() async {
        isLoading = true
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let lastOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth) else {
            isLoading = false
            return
        }
        let start = dateFormatter.string(from: firstOfMonth)
        let end = dateFormatter.string(from: lastOfMonth)
        let dates = await firestore.fetchAvailableDates(from: start, to: end)
        availableDates = Set(dates)
        isLoading = false
    }

    func goToPreviousMonth() {
        if let prev = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = prev
        }
    }

    func goToNextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = next
        }
    }

    private static var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}

struct DayItem: Identifiable {
    let id = UUID()
    let day: Int
    let dateString: String
    var isPlaceholder: Bool = false
    var isAvailable: Bool = false
    var isPast: Bool = false
}
