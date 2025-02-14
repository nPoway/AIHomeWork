import Foundation
import RealmSwift

final class RealmChatSessionRepository: ChatSessionRepository {
    private let realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }
    
    func create(session: RealmChatSession) throws {
        try realm.write {
            realm.add(session)
        }
    }
    
    func fetchAll() -> Results<RealmChatSession> {
        return realm.objects(RealmChatSession.self).sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func fetch(byID id: String) -> RealmChatSession? {
        return realm.object(ofType: RealmChatSession.self, forPrimaryKey: id)
    }
    
    func updateFirstQuestion(for session: RealmChatSession, newQuestion: String) throws {
        try realm.write {
            session.firstQuestion = newQuestion
        }
    }
    
    func delete(session: RealmChatSession) throws {
        try realm.write {
            realm.delete(session)
        }
    }
}
