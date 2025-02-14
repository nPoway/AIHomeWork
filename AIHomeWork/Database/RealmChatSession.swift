import Foundation
import RealmSwift

final class RealmChatSession: Object {
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var subject: String = ""
    @objc dynamic var firstQuestion: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(subject: String, firstQuestion: String) {
        self.init()
        self.subject = subject
        self.firstQuestion = firstQuestion
    }
}
