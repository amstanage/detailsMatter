import Foundation
import FirebaseFirestore

@Observable
final class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()
    var errorMessage: String?

    private init() {}

    // MARK: - Services

    func fetchServices() async -> [DetailService] {
        do {
            let snapshot = try await db.collection("services")
                .order(by: "sortOrder")
                .getDocuments()
            return snapshot.documents.compactMap { DetailService(from: $0.data(), id: $0.documentID) }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }

    func seedDefaultServices() async {
        let snapshot = try? await db.collection("services").limit(to: 1).getDocuments()
        guard snapshot?.documents.isEmpty ?? true else { return }

        for service in DetailService.predefined {
            do {
                try await db.collection("services").addDocument(data: service.toDictionary())
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Time Slots

    func fetchAvailableDates(from startDate: String, to endDate: String) async -> [String] {
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
    }

    func fetchAvailableSlots(for date: String) async -> [TimeSlot] {
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
    }

    func fetchAllSlots(for date: String) async -> [TimeSlot] {
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
    }

    func addTimeSlot(date: String, time: String) async -> TimeSlot? {
        let slot = TimeSlot(date: date, time: time)
        do {
            let ref = try await db.collection("timeSlots").addDocument(data: slot.toDictionary())
            return TimeSlot(id: ref.documentID, date: date, time: time)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func removeTimeSlot(_ slotId: String) async {
        do {
            try await db.collection("timeSlots").document(slotId).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Booking (Transactional)

    func bookAppointment(slotId: String, userId: String, userName: String, userPhone: String,
                         date: String, time: String, services: [String],
                         customRequest: String?, vehicle: VehicleInfo) async -> Appointment? {
        do {
            let slotRef = db.collection("timeSlots").document(slotId)
            let appointmentRef = db.collection("appointments").document()

            let appointment = try await db.runTransaction { transaction, errorPointer -> Appointment? in
                let slotDoc: DocumentSnapshot
                do {
                    slotDoc = try transaction.getDocument(slotRef)
                } catch let error as NSError {
                    errorPointer.pointee = error
                    return nil
                }

                guard let isBooked = slotDoc.data()?["isBooked"] as? Bool, !isBooked else {
                    let err = NSError(domain: "detailsMatter", code: 409,
                                      userInfo: [NSLocalizedDescriptionKey: "This time slot was just taken. Please choose another."])
                    errorPointer.pointee = err
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
            return appointment
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Cancel Appointment (Transactional)

    func cancelAppointment(_ appointment: Appointment) async -> Bool {
        do {
            let apptRef = db.collection("appointments").document(appointment.id)
            let slotRef = db.collection("timeSlots").document(appointment.timeSlotId)

            try await db.runTransaction { transaction, errorPointer in
                transaction.updateData([
                    "status": AppointmentStatus.cancelled.rawValue
                ], forDocument: apptRef)

                transaction.updateData([
                    "isBooked": false,
                    "appointmentId": FieldValue.delete()
                ], forDocument: slotRef)

                return nil
            } as Void
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Complete Appointment

    func completeAppointment(_ appointmentId: String) async -> Bool {
        do {
            try await db.collection("appointments").document(appointmentId).updateData([
                "status": AppointmentStatus.completed.rawValue
            ])
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Fetch Appointments

    func fetchAppointments(for userId: String) async -> [Appointment] {
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
    }

    func fetchAllAppointments() async -> [Appointment] {
        do {
            let snapshot = try await db.collection("appointments")
                .order(by: "date", descending: true)
                .getDocuments()
            return snapshot.documents.compactMap { Appointment(from: $0.data(), id: $0.documentID) }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
}
