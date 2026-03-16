import Foundation
#if !DEMO_MODE
import FirebaseFirestore
#endif

@Observable
final class FirestoreService {
    static let shared = FirestoreService()

    #if !DEMO_MODE
    private let db = Firestore.firestore()
    #else
    private var demoSlots: [TimeSlot] = DemoData.generateTimeSlots()
    private var demoAppointments: [Appointment] = DemoData.allAppointments
    private let demoServices: [DetailService] = DemoData.services
    #endif

    var errorMessage: String?

    private init() {}

    // MARK: - Services

    func fetchServices() async -> [DetailService] {
        #if DEMO_MODE
        return demoServices
        #else
        do {
            let snapshot = try await db.collection("services")
                .order(by: "sortOrder")
                .getDocuments()
            return snapshot.documents.compactMap { DetailService(from: $0.data(), id: $0.documentID) }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
        #endif
    }

    func seedDefaultServices() async {
        #if DEMO_MODE
        // No-op — services are pre-loaded in demo mode
        #else
        let snapshot = try? await db.collection("services").limit(to: 1).getDocuments()
        guard snapshot?.documents.isEmpty ?? true else { return }

        for service in DetailService.predefined {
            do {
                try await db.collection("services").addDocument(data: service.toDictionary())
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        #endif
    }

    // MARK: - Time Slots

    func fetchAvailableDates(from startDate: String, to endDate: String) async -> [String] {
        #if DEMO_MODE
        let dates = Set(
            demoSlots
                .filter { !$0.isBooked && $0.date >= startDate && $0.date <= endDate }
                .map(\.date)
        )
        return dates.sorted()
        #else
        do {
            let snapshot = try await db.collection("timeSlots")
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .whereField("date", isLessThanOrEqualTo: endDate)
                .whereField("isBooked", isEqualTo: false)
                .getDocuments()
            let dates = Set(snapshot.documents.compactMap { $0.data()["date"] as? String })
            return dates.sorted()
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
        #endif
    }

    func fetchAvailableSlots(for date: String) async -> [TimeSlot] {
        #if DEMO_MODE
        return demoSlots
            .filter { $0.date == date && !$0.isBooked }
            .sorted { $0.time < $1.time }
        #else
        do {
            let snapshot = try await db.collection("timeSlots")
                .whereField("date", isEqualTo: date)
                .whereField("isBooked", isEqualTo: false)
                .order(by: "time")
                .getDocuments()
            return snapshot.documents.compactMap { TimeSlot(from: $0.data(), id: $0.documentID) }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
        #endif
    }

    func fetchAllSlots(for date: String) async -> [TimeSlot] {
        #if DEMO_MODE
        return demoSlots
            .filter { $0.date == date }
            .sorted { $0.time < $1.time }
        #else
        do {
            let snapshot = try await db.collection("timeSlots")
                .whereField("date", isEqualTo: date)
                .order(by: "time")
                .getDocuments()
            return snapshot.documents.compactMap { TimeSlot(from: $0.data(), id: $0.documentID) }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
        #endif
    }

    func addTimeSlot(date: String, time: String) async -> TimeSlot? {
        #if DEMO_MODE
        let slot = TimeSlot(id: "demo-slot-\(date)-\(time)-\(UUID().uuidString.prefix(4))", date: date, time: time)
        demoSlots.append(slot)
        return slot
        #else
        let slot = TimeSlot(date: date, time: time)
        do {
            let ref = try await db.collection("timeSlots").addDocument(data: slot.toDictionary())
            return TimeSlot(id: ref.documentID, date: date, time: time)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
        #endif
    }

    func removeTimeSlot(_ slotId: String) async {
        #if DEMO_MODE
        demoSlots.removeAll { $0.id == slotId }
        #else
        do {
            try await db.collection("timeSlots").document(slotId).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
        #endif
    }

    // MARK: - Booking (Transactional)

    func bookAppointment(slotId: String, userId: String, userName: String, userPhone: String,
                         date: String, time: String, services: [String],
                         customRequest: String?, vehicle: VehicleInfo) async -> Appointment? {
        #if DEMO_MODE
        guard let slotIndex = demoSlots.firstIndex(where: { $0.id == slotId && !$0.isBooked }) else {
            errorMessage = "This time slot was just taken. Please choose another."
            return nil
        }
        let apptId = "demo-appt-\(UUID().uuidString.prefix(8))"
        let appointment = Appointment(
            id: apptId,
            userId: userId, userName: userName, userPhone: userPhone,
            date: date, timeSlot: time, timeSlotId: slotId,
            services: services, customRequest: customRequest,
            vehicle: vehicle
        )
        demoSlots[slotIndex].isBooked = true
        demoSlots[slotIndex].appointmentId = apptId
        demoAppointments.append(appointment)
        return appointment
        #else
        do {
            let slotRef = db.collection("timeSlots").document(slotId)
            let appointmentRef = db.collection("appointments").document()

            let result = try await db.runTransaction { transaction, errorPointer -> Appointment? in
                let slotDoc: DocumentSnapshot
                do {
                    slotDoc = try transaction.getDocument(slotRef)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }

                guard let isBooked = slotDoc.data()?["isBooked"] as? Bool, !isBooked else {
                    let err = NSError(domain: "detailsMatter", code: 409,
                                      userInfo: [NSLocalizedDescriptionKey: "This time slot was just taken. Please choose another."])
                    errorPointer?.pointee = err
                    return nil
                }

                let appt = Appointment(
                    id: appointmentRef.documentID,
                    userId: userId, userName: userName, userPhone: userPhone,
                    date: date, timeSlot: time, timeSlotId: slotId,
                    services: services, customRequest: customRequest,
                    vehicle: vehicle
                )

                transaction.updateData([
                    "isBooked": true,
                    "appointmentId": appointmentRef.documentID
                ], forDocument: slotRef)

                transaction.setData(appt.toDictionary(), forDocument: appointmentRef)

                return appt
            }
            return result as? Appointment
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
        #endif
    }

    // MARK: - Cancel Appointment (Transactional)

    func cancelAppointment(_ appointment: Appointment) async -> Bool {
        #if DEMO_MODE
        if let apptIndex = demoAppointments.firstIndex(where: { $0.id == appointment.id }) {
            demoAppointments[apptIndex].status = .cancelled
        }
        if let slotIndex = demoSlots.firstIndex(where: { $0.id == appointment.timeSlotId }) {
            demoSlots[slotIndex].isBooked = false
            demoSlots[slotIndex].appointmentId = nil
        }
        return true
        #else
        do {
            let apptRef = db.collection("appointments").document(appointment.id)
            let slotRef = db.collection("timeSlots").document(appointment.timeSlotId)

            _ = try await db.runTransaction { transaction, _ in
                transaction.updateData([
                    "status": AppointmentStatus.cancelled.rawValue
                ], forDocument: apptRef)

                transaction.updateData([
                    "isBooked": false,
                    "appointmentId": FieldValue.delete()
                ], forDocument: slotRef)

                return nil
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        #endif
    }

    // MARK: - Complete Appointment

    func completeAppointment(_ appointmentId: String) async -> Bool {
        #if DEMO_MODE
        if let index = demoAppointments.firstIndex(where: { $0.id == appointmentId }) {
            demoAppointments[index].status = .completed
        }
        return true
        #else
        do {
            try await db.collection("appointments").document(appointmentId).updateData([
                "status": AppointmentStatus.completed.rawValue
            ])
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        #endif
    }

    // MARK: - Fetch Appointments

    func fetchAppointments(for userId: String) async -> [Appointment] {
        #if DEMO_MODE
        return demoAppointments
            .filter { $0.userId == userId }
            .sorted { $0.date > $1.date }
        #else
        do {
            let snapshot = try await db.collection("appointments")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()
            return snapshot.documents.compactMap { Appointment(from: $0.data(), id: $0.documentID) }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
        #endif
    }

    func fetchAllAppointments() async -> [Appointment] {
        #if DEMO_MODE
        return demoAppointments.sorted { $0.date > $1.date }
        #else
        do {
            let snapshot = try await db.collection("appointments")
                .order(by: "date", descending: true)
                .getDocuments()
            return snapshot.documents.compactMap { Appointment(from: $0.data(), id: $0.documentID) }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
        #endif
    }
}
