import Foundation

enum AppointmentStatus: String {
    case confirmed
    case cancelled
    case completed
}

struct Appointment: Identifiable {
    let id: String
    var userId: String
    var userName: String
    var userPhone: String
    var date: String       // "2026-03-20"
    var timeSlot: String   // "09:00"
    var timeSlotId: String
    var services: [String] // service names
    var customRequest: String?
    var vehicleYear: String
    var vehicleMake: String
    var vehicleModel: String
    var vehicleColor: String
    var status: AppointmentStatus
    var createdAt: Date

    init(id: String = UUID().uuidString, userId: String, userName: String, userPhone: String,
         date: String, timeSlot: String, timeSlotId: String, services: [String],
         customRequest: String? = nil, vehicle: VehicleInfo,
         status: AppointmentStatus = .confirmed, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userPhone = userPhone
        self.date = date
        self.timeSlot = timeSlot
        self.timeSlotId = timeSlotId
        self.services = services
        self.customRequest = customRequest
        self.vehicleYear = vehicle.year
        self.vehicleMake = vehicle.make
        self.vehicleModel = vehicle.model
        self.vehicleColor = vehicle.color
        self.status = status
        self.createdAt = createdAt
    }

    init?(from data: [String: Any], id: String) {
        guard let userId = data["userId"] as? String,
              let userName = data["userName"] as? String,
              let userPhone = data["userPhone"] as? String,
              let date = data["date"] as? String,
              let timeSlot = data["timeSlot"] as? String,
              let timeSlotId = data["timeSlotId"] as? String,
              let services = data["services"] as? [String],
              let statusStr = data["status"] as? String,
              let status = AppointmentStatus(rawValue: statusStr) else { return nil }
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userPhone = userPhone
        self.date = date
        self.timeSlot = timeSlot
        self.timeSlotId = timeSlotId
        self.services = services
        self.customRequest = data["customRequest"] as? String
        self.vehicleYear = data["vehicleYear"] as? String ?? ""
        self.vehicleMake = data["vehicleMake"] as? String ?? ""
        self.vehicleModel = data["vehicleModel"] as? String ?? ""
        self.vehicleColor = data["vehicleColor"] as? String ?? ""
        self.status = status
        if let ts = data["createdAt"] as? Double {
            self.createdAt = Date(timeIntervalSince1970: ts)
        } else {
            self.createdAt = Date()
        }
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "userId": userId,
            "userName": userName,
            "userPhone": userPhone,
            "date": date,
            "timeSlot": timeSlot,
            "timeSlotId": timeSlotId,
            "services": services,
            "vehicleYear": vehicleYear,
            "vehicleMake": vehicleMake,
            "vehicleModel": vehicleModel,
            "vehicleColor": vehicleColor,
            "status": status.rawValue,
            "createdAt": createdAt.timeIntervalSince1970
        ]
        if let customRequest, !customRequest.isEmpty {
            dict["customRequest"] = customRequest
        }
        return dict
    }

    var vehicleInfo: VehicleInfo {
        VehicleInfo(year: vehicleYear, make: vehicleMake, model: vehicleModel, color: vehicleColor)
    }

    var vehicleDisplayString: String {
        vehicleInfo.displayString
    }

    var displayTime: String {
        let parts = timeSlot.split(separator: ":")
        guard parts.count == 2, let hour = Int(parts[0]) else { return timeSlot }
        let minute = String(parts[1])
        if hour == 0 { return "12:\(minute) AM" }
        if hour < 12 { return "\(hour):\(minute) AM" }
        if hour == 12 { return "12:\(minute) PM" }
        return "\(hour - 12):\(minute) PM"
    }

    var isFuture: Bool {
        date >= Self.todayString
    }

    private static var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
