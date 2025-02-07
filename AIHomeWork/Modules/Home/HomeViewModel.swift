import UIKit

final class HomeViewModel {
    
    private var subjects: [Subject] = []
    
    var sections: [Section] {
        return Section.allCases
    }
   
    func getItems(for section: Section) -> [Subject] {
        return Subject.allCases.filter { $0.section == section }
    }
}
