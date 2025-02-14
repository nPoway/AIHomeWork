import RealmSwift

protocol ChatSessionRepository {
    func create(session: RealmChatSession) throws
    
    func fetchAll() -> Results<RealmChatSession>
    
    func fetch(byID id: String) -> RealmChatSession?
    
    func updateFirstQuestion(for session: RealmChatSession, newQuestion: String) throws
    
    func delete(session: RealmChatSession) throws
}
