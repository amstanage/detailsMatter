import Foundation

struct TimeSlot: Identifiable {
    let id: String
    var date: String       // "2026-03-20"
    var time: String       // "09:00"
    var isBooked: Bool
    var appointmentId: String?

    init(id: String = UUID().uuidString, date: String, time: String, isBooked: Bool = false, appointmentId: String? = nil) {
        self.id = id
        self.date = date
        self.time = time
        self.isBooked = isBooked
        self.appointmentId = appointmentId
    }

    init?(from data: [String: Any], id: String) {
        guard let date = data["date"] as? String,
              let time = data["time"] as? String else { return nil }
        self.id = id
        self.date = date
        self.time = time
        self.isBooked = data["isBooked"] as? Bool ?? false
        self.appointmentId = data["appointmentId"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "date": date,
            "time": time,
            "isBooked": isBooked
        ]
        if let appointmentId { dict["appointmentId"] = appointmentId }
        return dict
    }

    var displayTime: String {
        let parts = time.split(separator: ":")
        guard parts.count == 2, let hour = Int(parts[0]) else { return time }
        let minute = String(parts[1])
        if hour == 0 { return "12:\(minute) AM" }
        if hour < 12 { return "\(hour):\(minute) AM" }
        if hour == 12 { return "12:\(minute) PM" }
        return "\(hour - 12):\(minute) PM"
    }
}
