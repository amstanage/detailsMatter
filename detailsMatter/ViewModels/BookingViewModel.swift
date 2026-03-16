import Foundation

enum BookingStep: Int, CaseIterable {
    case selectDate
    case selectTime
    case details
    case confirm
}

@Observable
final class BookingViewModel {
    var step: BookingStep = .selectDate
    var selectedDate: String = ""
    var selectedSlot: TimeSlot?
    var availableSlots: [TimeSlot] = []
    var services: [DetailService] = []
    var selectedServiceNames: Set<String> = []
    var customRequest: String = ""
    var vehicle = VehicleInfo()
    var isLoading = false
    var isBooking = false
    var bookingError: String?
    var bookedAppointment: Appointment?

    private let firestore = FirestoreService.shared

    var selectedServices: [DetailService] {
        services.filter { selectedServiceNames.contains($0.name) }
    }

    var totalPrice: Double {
        selectedServices.reduce(0) { $0 + $1.price }
    }

    var totalDuration: Int {
        selectedServices.reduce(0) { $0 + $1.estimatedDuration }
    }

    var canProceedToConfirm: Bool {
        !selectedServiceNames.isEmpty && vehicle.isComplete
    }

    func loadServices() async {
        services = await firestore.fetchServices()
    }

    func selectDate(_ date: String) {
        selectedDate = date
        step = .selectTime
        Task { await loadSlots() }
    }

    func loadSlots() async {
        isLoading = true
        availableSlots = await firestore.fetchAvailableSlots(for: selectedDate)
        isLoading = false
    }

    func selectSlot(_ slot: TimeSlot) {
        selectedSlot = slot
        step = .details
    }

    func proceedToConfirm() {
        guard canProceedToConfirm else { return }
        step = .confirm
    }

    func book(userId: String, userName: String, userPhone: String) async {
        guard let slot = selectedSlot else { return }
        isBooking = true
        bookingError = nil

        let result = await firestore.bookAppointment(
            slotId: slot.id,
            userId: userId,
            userName: userName,
            userPhone: userPhone,
            date: selectedDate,
            time: slot.time,
            services: Array(selectedServiceNames),
            customRequest: customRequest.isEmpty ? nil : customRequest,
            vehicle: vehicle
        )

        if let appointment = result {
            bookedAppointment = appointment
        } else {
            bookingError = firestore.errorMessage ?? "Booking failed. Please try again."
        }
        isBooking = false
    }

    func goBack() {
        switch step {
        case .selectDate: break
        case .selectTime:
            step = .selectDate
            selectedSlot = nil
        case .details:
            step = .selectTime
        case .confirm:
            step = .details
        }
    }

    func reset() {
        step = .selectDate
        selectedDate = ""
        selectedSlot = nil
        availableSlots = []
        selectedServiceNames = []
        customRequest = ""
        vehicle = VehicleInfo()
        bookingError = nil
        bookedAppointment = nil
    }

    func toggleService(_ name: String) {
        if selectedServiceNames.contains(name) {
            selectedServiceNames.remove(name)
        } else {
            selectedServiceNames.insert(name)
        }
    }
}
