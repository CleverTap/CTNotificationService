
import UIKit
import CleverTapSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        CleverTap.autoIntegrate()
        self.registerPush()
        return true
    }
    
    private func registerPush() {
        // request permissions
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
            (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("APPDELEGATE: open url \(url)")
        DispatchQueue.main.async {
            self.showAlert(message: "APPDELEGATE: open url \(url)")
        }
        return true
    }
    
    func open(_ url: URL, options: [String : Any] = [:],
              completionHandler completion: ((Bool) -> Swift.Void)? = nil){
        print("APPDELEGATE: open url \(url) with completionHandler")
        DispatchQueue.main.async {
            self.showAlert(message: "APPDELEGATE: open url \(url) with completionHandler")
        }
        
        completion?(false)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did receive remote notification \(response.notification.request.content.userInfo)")
    }
    
    func showAlert(message:String) {
        let alertController = UIAlertController(title: "Deeplink", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        // Under the scene lifecycle the app delegate's `window` is always nil, so the
        // presenting controller has to come from the connected window scene.
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(alertController, animated: true, completion: nil)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// MARK: - UIScene lifecycle
//
// iOS 26 (Xcode 27 SDK) makes the UIScene lifecycle mandatory. Without a scene manifest
// + delegate the app crashes at launch, so the window is created here instead of relying
// on the legacy app-delegate `window`. See Info.plist > UIApplicationSceneManifest.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()

        connectionOptions.urlContexts.forEach { forwardDeepLink($0.url) }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Warm deep links reach the scene delegate instead of application(_:open:options:).
        URLContexts.forEach { forwardDeepLink($0.url) }
    }

    private func forwardDeepLink(_ url: URL) {
        _ = (UIApplication.shared.delegate as? AppDelegate)?
            .application(UIApplication.shared, open: url, options: [:])
    }
}

