import Foundation

@Observable
final class AppointmentDetailViewModel {
    var appointment: Appointment
    var isCancelling = false
    var didCancel = false
    var errorMessage: String?

    private let firestore = FirestoreService.shared

    init(appointment: Appointment) {
        self.appointment = appointment
    }

    var canCancel: Bool {
        appointment.status == .confirmed && appointment.isFuture
    }

    func cancelAppointment() async {
        isCancelling = true
        errorMessage = nil
        let success = await firestore.cancelAppointment(appointment)
        if success {
            appointment.status = .cancelled
            didCancel = true
        } else {
            errorMessage = firestore.errorMessage ?? "Failed to cancel appointment."
        }
        isCancelling = false
    }
}
