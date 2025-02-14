import Foundation

enum Subject: CaseIterable {
    case math
    case programming
    case economics
    case chemistry
    case biology
    case physics
    case geography
    case history
    case grammar
    case writeEssay
    case translate
    
    var title: String {
        switch self {
        case .math: return "Math"
        case .programming: return "Programming"
        case .economics: return "Economics"
        case .chemistry: return "Chemistry"
        case .biology: return "Biology"
        case .physics: return "Physics"
        case .geography: return "Geography"
        case .history: return "History"
        case .grammar: return "Grammar"
        case .writeEssay: return "Write Essay"
        case .translate: return "Translate"
        }
    }
    
    var description: String {
        switch self {
        case .math: return "Help with algebra, geometry, calculus"
        case .programming: return "Programming and computer science help"
        case .economics: return "Help with data analytics and finance"
        case .chemistry: return "Help with organic and inorganic chemistry"
        case .biology: return "Anatomy, genetics and microbiology help"
        case .physics: return "Assisting with all aspects of physics"
        case .geography: return "Learn climate research and cartography"
        case .history: return "Help with historical events, dates, figures"
        case .grammar: return "Find grammar and style mistakes"
        case .writeEssay: return "Easily write all types of essays"
        case .translate: return "Translating any text into various languages"
        }
    }
    var imageName: String {
        switch self {
        case .math: return "mathLogo"
        case .programming: return "programmingLogo"
        case .economics: return "economicsLogo"
        case .chemistry: return "chemistryLogo"
        case .biology: return "biologyLogo"
        case .physics: return "physicsLogo"
        case .geography: return "geographyLogo"
        case .history: return "historyLogo"
        case .grammar: return "grammarLogo"
        case .writeEssay: return "writeEssayLogo"
        case .translate: return "translateLogo"
        }
    }
    
    var section: Section {
        switch self {
        case .math, .programming, .economics:
            return .technical
        case .chemistry, .biology, .physics, .geography, .history:
            return .popular
        case .grammar, .writeEssay, .translate:
            return .text
        }
    }
}
    
enum Section: Int, CaseIterable {
    case technical
    case popular
    case text
    
    var title: String {
        switch self {
        case .technical: return "Technical Sciences"
        case .popular: return "Popular Subjects"
        case .text: return "Work with Text"
        }
    }
}

extension Subject {
    init?(title: String) {
        switch title {
        case "Math": self = .math
        case "Programming": self = .programming
        case "Economics": self = .economics
        case "Chemistry": self = .chemistry
        case "Biology": self = .biology
        case "Physics": self = .physics
        case "Geography": self = .geography
        case "History": self = .history
        case "Grammar": self = .grammar
        case "Write Essay": self = .writeEssay
        case "Translate": self = .translate
        default:
            return nil
        }
    }
}
