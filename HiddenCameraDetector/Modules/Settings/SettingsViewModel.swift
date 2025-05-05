import UIKit
import StoreKit

final class SettingsViewModel {
    
    var openURL: ((URL) -> Void)?
    var presentActivity: ((UIActivityViewController) -> Void)?
    var requestReview: (() -> Void)?
    
    lazy var settingsOptions: [SettingsCard] = {
        return [
            SettingsCard(titleText: "Terms & Conditions", iconImage: UIImage.termsIcon, action: { [weak self] in self?.openURL(from: "https://docs.google.com/document/d/17cMDICt0pCpTtXEhZL-QdKP6s_qVGYpubk_SoEGB4ss/edit?usp=sharing") }),
            SettingsCard(titleText: "Privacy Policy", iconImage: UIImage.privacyIcon, action: { [weak self] in self?.openURL(from: "https://docs.google.com/document/d/1ckGSlpTpTRicDp3LiS7_ZxrC1uZyuRQu1CKzTqT92sQ/edit?usp=sharing") }),
            SettingsCard(titleText: "Rate This App", iconImage: UIImage.rateUsIcon, action: { [weak self] in self?.requestReview?() }),
            SettingsCard(titleText: "Share with Friends", iconImage: UIImage.shareIcon, action: { [weak self] in self?.shareApp() })
        ]
    }()
    
    private func openURL(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL?(url)
    }
    
    private func shareApp() {
        let appLink = "https://apps.apple.com/app/id6743766457"
        let message = "🚀 Check out this awesome app! Download it here: \(appLink)"
        
        guard let url = URL(string: appLink) else { return }
        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        
        presentActivity?(activityVC)
    }
}
