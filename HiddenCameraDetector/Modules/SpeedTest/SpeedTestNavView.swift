import UIKit

class SpeedTestNavigationView: BaseNavigationView {
    init() {
        super.init(isBackButtonHidden: false, titleText: "Speed Tester")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
