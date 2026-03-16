import Foundation

enum DemoData {

    // MARK: - Users

    static let clientUser = DMUser(
        id: "demo-client-001",
        phone: "+1 (555) 123-4567",
        name: "Alex Demo",
        role: "client"
    )

    static let adminUser = DMUser(
        id: "demo-admin-001",
        phone: "+1 (555) 999-0000",
        name: "Admin Demo",
        role: "admin"
    )

    // MARK: - Services

    static let services: [DetailService] = DetailService.predefined

    // MARK: - Time Slots

    static func generateTimeSlots(startingFrom date: Date = Date()) -> [TimeSlot] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        var slots: [TimeSlot] = []

        for dayOffset in 1...21 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: date) else { continue }
            let dateStr = formatter.string(from: day)
            let weekday = calendar.component(.weekday, from: day)

            // Skip Sundays (weekday == 1)
            guard weekday != 1 else { continue }

            let times: [String]
            if weekday == 7 {
                // Saturday: morning only
                times = ["09:00", "10:00", "11:00"]
            } else {
                // Weekdays: morning and afternoon
                times = ["09:00", "10:00", "11:00", "13:00", "14:00", "15:00"]
            }

            for time in times {
                slots.append(TimeSlot(
                    id: "demo-slot-\(dateStr)-\(time)",
                    date: dateStr,
                    time: time
                ))
            }
        }
        return slots
    }

    // MARK: - Appointments

    static func sampleAppointments(userId: String, userName: String, userPhone: String) -> [Appointment] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = Date()
        var appointments: [Appointment] = []

        // Future confirmed appointment
        if let futureDate = calendar.date(byAdding: .day, value: 4, to: today) {
            appointments.append(Appointment(
                id: "demo-appt-001",
                userId: userId, userName: userName, userPhone: userPhone,
                date: formatter.string(from: futureDate),
                timeSlot: "10:00", timeSlotId: "demo-slot-future",
                services: ["Full Detail"],
                vehicle: VehicleInfo(year: "2024", make: "Tesla", model: "Model 3", color: "White")
            ))
        }

        // Past completed appointment
        if let pastDate = calendar.date(byAdding: .day, value: -5, to: today) {
            appointments.append(Appointment(
                id: "demo-appt-002",
                userId: userId, userName: userName, userPhone: userPhone,
                date: formatter.string(from: pastDate),
                timeSlot: "09:00", timeSlotId: "demo-slot-past",
                services: ["Exterior Wash", "Interior Detail"],
                vehicle: VehicleInfo(year: "2023", make: "BMW", model: "X5", color: "Black"),
                status: .completed
            ))
        }

        // Past cancelled appointment
        if let cancelDate = calendar.date(byAdding: .day, value: -12, to: today) {
            appointments.append(Appointment(
                id: "demo-appt-003",
                userId: userId, userName: userName, userPhone: userPhone,
                date: formatter.string(from: cancelDate),
                timeSlot: "14:00", timeSlotId: "demo-slot-cancel",
                services: ["Ceramic Coating"],
                vehicle: VehicleInfo(year: "2022", make: "Porsche", model: "911", color: "Silver"),
                status: .cancelled
            ))
        }

        return appointments
    }

    // All appointments (admin view — includes multiple clients)
    static var allAppointments: [Appointment] {
        var all = sampleAppointments(
            userId: clientUser.id,
            userName: clientUser.name,
            userPhone: clientUser.phone
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = Date()

        if let date = calendar.date(byAdding: .day, value: 2, to: today) {
            all.append(Appointment(
                id: "demo-appt-004",
                userId: "demo-client-002",
                userName: "Jordan Smith",
                userPhone: "+1 (555) 987-6543",
                date: formatter.string(from: date),
                timeSlot: "13:00",
                timeSlotId: "demo-slot-other",
                services: ["Paint Correction", "Ceramic Coating"],
                vehicle: VehicleInfo(year: "2025", make: "Mercedes", model: "C300", color: "Blue")
            ))
        }

        return all
    }
}
