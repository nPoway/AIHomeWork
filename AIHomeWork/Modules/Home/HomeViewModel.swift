final class HomeViewModel {
    
    // Observables or callbacks to update the view
    private(set) var subjects: [SubjectItem] = []
    
    init() {
        fetchSubjects()
    }
    
    private func fetchSubjects() {
        // For a real app, you could fetch from a service or Realm
        subjects = [
            SubjectItem(title: "Math", description: "Help with algebra, geometry, calculus"),
            SubjectItem(title: "Programming", description: "Programming and computer science help"),
            // ... and so on
        ]
    }
}
