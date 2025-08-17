import Foundation

struct Event: Codable {
    let identifier: String?
    let title: String
    let startDate: Date
    let endDate: Date
}
