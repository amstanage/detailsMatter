import Foundation

@Observable
final class ClientHomeViewModel {
    var upcomingAppointments: [Appointment] = []
    var pastAppointments: [Appointment] = []
    var isLoading = false

    private let firestore = FirestoreService.shared

    func loadAppointments(for userId: String) async {
        isLoading = true
        let all = await firestore.fetchAppointments(for: userId)

        let today = Self.todayString
        upcomingAppointments = all.filter { $0.date >= today && $0.status == .confirmed }
            .sorted { $0.date < $1.date }
        pastAppointments = all.filter { $0.date < today || $0.status != .confirmed }
            .sorted { $0.date > $1.date }
        isLoading = false
    }

    private static var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
