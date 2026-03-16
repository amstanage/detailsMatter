import Foundation

enum AppointmentFilter: String, CaseIterable {
    case all = "All"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

@Observable
final class AdminDashboardViewModel {
    var appointments: [Appointment] = []
    var filter: AppointmentFilter = .all
    var filterDate: String = ""
    var isLoading = false

    private let firestore = FirestoreService.shared

    var filteredAppointments: [Appointment] {
        var result = appointments

        switch filter {
        case .all: break
        case .confirmed: result = result.filter { $0.status == .confirmed }
        case .completed: result = result.filter { $0.status == .completed }
        case .cancelled: result = result.filter { $0.status == .cancelled }
        }

        if !filterDate.isEmpty {
            result = result.filter { $0.date == filterDate }
        }

        return result
    }

    var groupedByDate: [(String, [Appointment])] {
        let grouped = Dictionary(grouping: filteredAppointments) { $0.date }
        return grouped.sorted { $0.key > $1.key }
    }

    func loadAppointments() async {
        isLoading = true
        appointments = await firestore.fetchAllAppointments()
        isLoading = false
    }

    func completeAppointment(_ appointment: Appointment) async {
        let success = await firestore.completeAppointment(appointment.id)
        if success {
            if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
                appointments[index].status = .completed
            }
        }
    }

    func seedServicesIfNeeded() async {
        await firestore.seedDefaultServices()
    }

    func clearDateFilter() {
        filterDate = ""
    }
}
