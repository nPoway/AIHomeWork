import UIKit

extension UIFont {
    
    enum PlusJakartaSansWeight: String {
        case regular = "PlusJakartaSans-Regular"
        case medium = "PlusJakartaSans-Medium"
        case semiBold = "PlusJakartaSans-SemiBold"
        case bold = "PlusJakartaSans-Bold"
    }
    
    static func plusJakartaSans(_ weight: PlusJakartaSansWeight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
   
    static var title1: UIFont {
        return plusJakartaSans(.semiBold, size: 24)
    }
    
    static var title2: UIFont {
        return plusJakartaSans(.semiBold, size: 18)
    }
    
    static var title3: UIFont {
        return plusJakartaSans(.semiBold, size: 16)
    }
    
    static var subheadline: UIFont {
        return plusJakartaSans(.regular, size: 15)
    }
    
    static var caption1: UIFont {
        return plusJakartaSans(.medium, size: 12)
    }
}
