import Foundation

struct VehicleInfo {
    var year: String
    var make: String
    var model: String
    var color: String

    init(year: String = "", make: String = "", model: String = "", color: String = "") {
        self.year = year
        self.make = make
        self.model = model
        self.color = color
    }

    init?(from data: [String: Any]) {
        guard let year = data["vehicleYear"] as? String,
              let make = data["vehicleMake"] as? String,
              let model = data["vehicleModel"] as? String,
              let color = data["vehicleColor"] as? String else { return nil }
        self.year = year
        self.make = make
        self.model = model
        self.color = color
    }

    func toDictionary() -> [String: Any] {
        [
            "vehicleYear": year,
            "vehicleMake": make,
            "vehicleModel": model,
            "vehicleColor": color
        ]
    }

    var displayString: String {
        [year, color, make, model].filter { !$0.isEmpty }.joined(separator: " ")
    }

    var isComplete: Bool {
        !year.isEmpty && !make.isEmpty && !model.isEmpty && !color.isEmpty
    }
}
