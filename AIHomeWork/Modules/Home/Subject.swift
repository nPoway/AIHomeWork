import Foundation

struct SubjectItem {
    let title: String
    let description: String
}

enum SubjectType: String, CaseIterable {
    case technical = "Technical Sciences"
    case popular = "Popular Subjects"
    
}
