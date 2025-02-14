import Foundation
import RealmSwift

final class HistoryViewModel {
    private let repository: ChatSessionRepository
    private(set) var sessions: [RealmChatSession] = []
    
    var onDataUpdated: (() -> Void)?
    
    init(repository: ChatSessionRepository = RealmChatSessionRepository()) {
        self.repository = repository
    }
    
    func loadHistory() {
        let results = repository.fetchAll()
        sessions = Array(results)
        onDataUpdated?()
    }
    
    func deleteSession(at index: Int) {
        let session = sessions[index]
        do {
            try repository.delete(session: session)
            sessions.remove(at: index)
            onDataUpdated?()
        } catch {
            print("Ошибка при удалении сессии: \(error)")
        }
    }
}
