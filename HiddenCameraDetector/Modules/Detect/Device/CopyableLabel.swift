import UIKit

class CopyableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCopyInteraction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCopyInteraction()
    }
    
    private func setupCopyInteraction() {
        isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showCopyMenu(_:)))
        addGestureRecognizer(longPress)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc private func showCopyMenu(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            becomeFirstResponder()
            
            let copyMenuItem = UIMenuItem(title: "Copy", action: #selector(copyText))
            UIMenuController.shared.menuItems = [copyMenuItem]
            
            UIMenuController.shared.showMenu(from: self, rect: bounds)
        }
    }
    
    @objc private func copyText() {
        UIPasteboard.general.string = text
    }
}
