import Foundation

struct DMUser {
    let id: String
    var phone: String
    var name: String
    var role: String // "client" or "admin"
    var createdAt: Date

    init(id: String, phone: String, name: String, role: String = "client", createdAt: Date = Date()) {
        self.id = id
        self.phone = phone
        self.name = name
        self.role = role
        self.createdAt = createdAt
    }

    init?(from data: [String: Any], id: String) {
        guard let phone = data["phone"] as? String,
              let name = data["name"] as? String,
              let role = data["role"] as? String else { return nil }
        self.id = id
        self.phone = phone
        self.name = name
        self.role = role
        if let ts = data["createdAt"] as? Double {
            self.createdAt = Date(timeIntervalSince1970: ts)
        } else {
            self.createdAt = Date()
        }
    }

    func toDictionary() -> [String: Any] {
        [
            "phone": phone,
            "name": name,
            "role": role,
            "createdAt": createdAt.timeIntervalSince1970
        ]
    }

    var isAdmin: Bool { role == "admin" }
}
