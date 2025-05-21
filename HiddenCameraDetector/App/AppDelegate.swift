import UIKit
import RevenueCat
import AppsFlyerLib


@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {}
    
    func onConversionDataFail(_ error: any Error) {}
    
    let appsFlyerDevKey = "qjqM4ww9Ve6zyWJpqtQqVn"
    let appleAppID = "6743766457"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: "appl_iKsTuaTkgJoXKKcfJJxYOXfxUoX")
        
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false
        InternetAlertService.shared.startMonitoring()
        Purchases.shared.attribution.collectDeviceIdentifiers()
        Purchases.shared.attribution.setAppsflyerID(AppsFlyerLib.shared().getAppsFlyerUID())
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
}
