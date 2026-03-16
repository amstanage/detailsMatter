import Foundation

@Observable
final class AdminSlotsViewModel {
    var selectedDate: Date = Date()
    var slots: [TimeSlot] = []
    var newTime: String = "09:00"
    var isLoading = false

    private let firestore = FirestoreService.shared
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var dateString: String {
        dateFormatter.string(from: selectedDate)
    }

    var bookedSlots: [TimeSlot] {
        slots.filter { $0.isBooked }
    }

    var availableSlots: [TimeSlot] {
        slots.filter { !$0.isBooked }
    }

    func loadSlots() async {
        isLoading = true
        slots = await firestore.fetchAllSlots(for: dateString)
        isLoading = false
    }

    func addSlot() async {
        guard !slots.contains(where: { $0.time == newTime }) else { return }
        if let slot = await firestore.addTimeSlot(date: dateString, time: newTime) {
            slots.append(slot)
            slots.sort { $0.time < $1.time }
        }
    }

    func removeSlot(_ slot: TimeSlot) async {
        guard !slot.isBooked else { return }
        await firestore.removeTimeSlot(slot.id)
        slots.removeAll { $0.id == slot.id }
    }

    func addMorningSet() async {
        for time in ["09:00", "10:00", "11:00"] {
            if !slots.contains(where: { $0.time == time }) {
                if let slot = await firestore.addTimeSlot(date: dateString, time: time) {
                    slots.append(slot)
                }
            }
        }
        slots.sort { $0.time < $1.time }
    }

    func addAfternoonSet() async {
        for time in ["13:00", "14:00", "15:00"] {
            if !slots.contains(where: { $0.time == time }) {
                if let slot = await firestore.addTimeSlot(date: dateString, time: time) {
                    slots.append(slot)
                }
            }
        }
        slots.sort { $0.time < $1.time }
    }
}
