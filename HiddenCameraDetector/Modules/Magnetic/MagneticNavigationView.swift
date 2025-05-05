import UIKit

class MagneticNavigationView: BaseNavigationView {
    init() {
        super.init(isBackButtonHidden: false, titleText: "Magnetic")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
