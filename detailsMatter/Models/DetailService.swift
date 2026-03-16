import Foundation

struct DetailService: Identifiable {
    let id: String
    var name: String
    var description: String
    var estimatedDuration: Int // minutes
    var price: Double
    var isActive: Bool
    var sortOrder: Int

    init(id: String = UUID().uuidString, name: String, description: String, estimatedDuration: Int, price: Double, isActive: Bool = true, sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.estimatedDuration = estimatedDuration
        self.price = price
        self.isActive = isActive
        self.sortOrder = sortOrder
    }

    init?(from data: [String: Any], id: String) {
        guard let name = data["name"] as? String,
              let description = data["description"] as? String,
              let duration = data["estimatedDuration"] as? Int,
              let price = data["price"] as? Double else { return nil }
        self.id = id
        self.name = name
        self.description = description
        self.estimatedDuration = duration
        self.price = price
        self.isActive = data["isActive"] as? Bool ?? true
        self.sortOrder = data["sortOrder"] as? Int ?? 0
    }

    func toDictionary() -> [String: Any] {
        [
            "name": name,
            "description": description,
            "estimatedDuration": estimatedDuration,
            "price": price,
            "isActive": isActive,
            "sortOrder": sortOrder
        ]
    }

    var formattedPrice: String {
        String(format: "$%.0f", price)
    }

    var formattedDuration: String {
        if estimatedDuration >= 60 {
            let hours = estimatedDuration / 60
            let mins = estimatedDuration % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(estimatedDuration)m"
    }

    static let predefined: [DetailService] = [
        DetailService(name: "Exterior Wash", description: "Hand wash, dry, and tire shine", estimatedDuration: 60, price: 50, sortOrder: 0),
        DetailService(name: "Interior Detail", description: "Vacuum, wipe down, glass cleaning, and air freshener", estimatedDuration: 90, price: 85, sortOrder: 1),
        DetailService(name: "Full Detail", description: "Complete interior and exterior detail package", estimatedDuration: 180, price: 200, sortOrder: 2),
        DetailService(name: "Ceramic Coating", description: "Professional ceramic coating application for long-lasting protection", estimatedDuration: 240, price: 500, sortOrder: 3),
        DetailService(name: "Paint Correction", description: "Multi-stage paint correction to remove swirls and scratches", estimatedDuration: 300, price: 400, sortOrder: 4),
    ]
}
