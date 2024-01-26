//
//  BesserSprechenApp.swift
//  BesserSprechen
//
//  Created by Zachary Linehan on 23.11.23.
//
/*
import SwiftUI
import MarketingCloudSDK
*/
import SwiftUI
import UIKit
import MarketingCloudSDK
import SafariServices


class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // The appID, accessToken and appEndpoint are required values for MobilePush SDK configuration.
    // See https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/get-started/apple.html for more information.
    
    let appId = "3a75c277-22eb-4476-9e94-ad911e313082"
    let accessToken = "QrcZ9S91fquGXiBXqV9nVpxC"
    let appEndpoint = "https://mc-gkd31nkc0wzj1hn5b8k0fpww4.device.marketingcloudapis.com/"
    let mid = "510008419"

    // Define features of MobilePush your app will use.
    let inbox = true
    let location = true
    let pushAnalytics = true

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    @discardableResult
    func configureMarketingCloudSDK() -> Bool {
        // Use the builder method to configure the SDK for usage. This gives you the maximum flexibility in SDK configuration.
        // The builder lets you configure the SDK parameters at runtime.
        let builder = MarketingCloudSDKConfigBuilder()
            .sfmc_setApplicationId(appId)
            .sfmc_setAccessToken(accessToken)
            .sfmc_setMarketingCloudServerUrl(appEndpoint)
            .sfmc_setMid(mid)
            .sfmc_setInboxEnabled(inbox as NSNumber)
            .sfmc_setLocationEnabled(location as NSNumber)
            .sfmc_setAnalyticsEnabled(pushAnalytics as NSNumber)
            .sfmc_build()!
        
        var success = false
        
        // Once you've created the builder, pass it to the sfmc_configure method.
        do {
            try MarketingCloudSDK.sharedInstance().sfmc_configure(with:builder)
            success = true
        } catch let error as NSError {
            // Errors returned from configuration will be in the NSError parameter and can be used to determine
            // if you've implemented the SDK correctly.
            
            let configErrorString = String(format: "MarketingCloudSDK sfmc_configure failed with error = %@", error)
            print(configErrorString)
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Configuration Error", message: configErrorString, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                //self.window?.topMostViewController()?.present(alert, animated: true)
            }
        }
        
        if success == true {
            // The SDK has been fully configured and is ready for use!
            
            // Enable logging for debugging. Not recommended for production apps, as significant data
            // about MobilePush will be logged to the console.
            #if DEBUG
            MarketingCloudSDK.sharedInstance().sfmc_setDebugLoggingEnabled(true)
            #endif
            
            // Set the MarketingCloudSDKURLHandlingDelegate to a class adhering to the protocol.
            // In this example, the AppDelegate class adheres to the protocol (see below)
            // and handles URLs passed back from the SDK.
            // For more information, see https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/sdk-implementation/implementation-urlhandling.html
            MarketingCloudSDK.sharedInstance().sfmc_setURLHandlingDelegate(self)
            
            // Set the MarketingCloudSDKEventDelegate to a class adhering to the protocol.
            // In this example, the AppDelegate class adheres to the protocol (see below)
            // and handles In-App Message delegate methods from the SDK.
            MarketingCloudSDK.sharedInstance().sfmc_setEventDelegate(self)
            
            // To instruct the SDK to start managing and watching location (for purposes of MobilePush
            // location messaging). This will enable geofence and beacon region monitoring, background location monitoring
            // and local notifications when a geofence or beacon is engaged.
            
            // Note: the first time this method is called, iOS will prompt the user for location permissions.
            // A choice other than "Always Allow" will lead to a degraded or ineffective MobilePush Location Messaging experience.
            // Additional app and project setup must be complete in order for Location Messaging to work correctly.
            // See https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/location/geolocation-overview.html
            MarketingCloudSDK.sharedInstance().sfmc_startWatchingLocation()
            
            // Make sure to dispatch this to the main thread, as UNUserNotificationCenter will present UI.
            DispatchQueue.main.async {
                // Set the UNUserNotificationCenterDelegate to a class adhering to thie protocol.
                // In this exmple, the AppDelegate class adheres to the protocol (see below)
                // and handles Notification Center delegate methods from iOS.
                UNUserNotificationCenter.current().delegate = self
                
                // Request authorization from the user for push notification alerts.
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
                    if error == nil {
                        if granted == true {
                            // Your application may want to do something specific if the user has granted authorization
                            // for the notification types specified; it would be done here.
                        }
                    }
                })
                
                // In any case, your application should register for remote notifications *each time* your application
                // launches to ensure that the push token used by MobilePush (for silent push) is updated if necessary.
                
                // Registering in this manner does *not* mean that a user will see a notification - it only means
                // that the application will receive a unique push token from iOS.
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        return success
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return self.configureMarketingCloudSDK()
    }
    
    // MobilePush SDK: OPTIONAL IMPLEMENTATION (if using Data Protection)
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        if(MarketingCloudSDK.sharedInstance().sfmc_isReady() == false)
        {
            self.configureMarketingCloudSDK()
        }
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MarketingCloudSDK.sharedInstance().sfmc_setDeviceToken(deviceToken)
        MarketingCloudSDK.sharedInstance().sfmc_setContactKey("test@volkswagen-groupservices.com")
    }
    
    
    // MobilePush SDK: REQUIRED IMPLEMENTATION
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    // MobilePush SDK: REQUIRED IMPLEMENTATION

    /** This delegate method offers an opportunity for applications with the "remote-notification" background mode to fetch appropriate new data in response to an incoming remote notification. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
     
     This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. **/
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationUserInfo(userInfo)
        
        completionHandler(.newData)
    }
}

// MobilePush SDK: REQUIRED IMPLEMENTATION
extension AppDelegate: MarketingCloudSDKURLHandlingDelegate {
    /**
     This method, if implemented, can be called when a Alert+CloudPage, Alert+OpenDirect, Alert+Inbox or Inbox message is processed by the SDK.
     Implementing this method allows the application to handle the URL from Marketing Cloud data.
     
     Prior to the MobilePush SDK version 6.0.0, the SDK would automatically handle these URLs and present them using a SFSafariViewController.
     
     Given security risks inherent in URLs and web pages (Open Redirect vulnerabilities, especially), the responsibility of processing the URL shall be held by the application implementing the MobilePush SDK. This reduces risk to the application by affording full control over processing, presentation and security to the application code itself.
     
     @param url value NSURL sent with the Location, CloudPage, OpenDirect or Inbox message
     @param type value NSInteger enumeration of the MobilePush source type of this URL
     */
    func sfmc_handle(_ url: URL, type: String) {
        
        // Very simply, send the URL returned from the MobilePush SDK to UIApplication to handle correctly.
        UIApplication.shared.open(url, options: [:],
                                  completionHandler: {
                                    (success) in
                                    print("Open \(url): \(success)")
        })
    }
}

// MobilePush SDK: REQUIRED IMPLEMENTATION
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Required: tell the MarketingCloudSDK about the notification. This will collect MobilePush analytics
        // and process the notification on behalf of your application.
        MarketingCloudSDK.sharedInstance().sfmc_setNotificationRequest(response.notification.request)
        
        completionHandler()
    }
    
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
    
}



// MobilePush SDK: OPTIONAL IMPLEMENTATION (if using In-App Messaging)
extension AppDelegate: MarketingCloudSDKEventDelegate {

    /**
     Method called by the SDK when an In-App Message is ready to be shown. The delegate implementing this method returns YES or NO.
     
     YES indicates to the SDK that this message is able to be shown (allowed by the application).
     
     NO indicates that the SDK should not show this message. An application may return NO if its visual hierarchy or user flow is such that an interruption would not be acceptable to the usability or functionality of the application.
     
     If NO is returned, the application may capture the message's identifier (via sfmc_messageIdForMessage:) and attempt to show that message later via sfmc_showInAppMessage:.
     
     @param message NSDictionary representing an In-App Message
     
     @return value reflecting application's behavior
     */
    func sfmc_shouldShow(inAppMessage message: [AnyHashable : Any]) -> Bool {
        print("message should show")
        return true
    }

    /**
     Method called by the SDK when an In-App Message has been shown.
     
     @param message NSDictionary representing an In-App Message
     */
    func sfmc_didShow(inAppMessage message: [AnyHashable : Any]) {
        // message shown
        print("message was shown")
    }
    
    /**
     Method called by the SDK when an In-App Message has been closed.
     
     @param message NSDictionary representing an In-App Message
     */
    func sfmc_didClose(inAppMessage message: [AnyHashable : Any]) {
        // message closed
        print("message was closed")
    }
}

/*
 // Define a traditional AppDelegate class for UIKit lifecycle handling
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
        
        // SDK: REQUIRED IMPLEMENTATION
        
        // The appID, accessToken and appEndpoint are required values for MobilePush SDK Module configuration and are obtained from your MobilePush app.
        // See https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/get-started/get-started-setupapps.html for more information.
        #if DEBUG
        let appId = "3a75c277-22eb-4476-9e94-ad911e313082"
        let accessToken = "QrcZ9S91fquGXiBXqV9nVpxC"
        let appEndpoint = "https://mc-gkd31nkc0wzj1hn5b8k0fpww4.device.marketingcloudapis.com/"
        let mid = "510008419"
        #else
        let appId = "[PROD-APNS appId value from MobilePush app admin]"
        let accessToken = "[PROD-APNS accessToken value from MobilePush app admin]"
        let appEndpoint = "[PROD-APNS app endpoint value from MobilePush app admin]"
        let mid = "[PROD-APNS account MID value from MobilePush app admin]"
        #endif
        
        
        // Define features of MobilePush your app will use.
        let inbox = false
        let location = false
        let analytics = true
        
        // SDK: REQUIRED IMPLEMENTATION
        func configureSDK() {
            // Enable logging for debugging early on. Debug level is not recommended for production apps, as significant data
            // about the MobilePush will be logged to the console.
            #if DEBUG
            SFMCSdk.setLogger(logLevel: .debug)
            #endif
            
            // Use the Mobile Push Config Builder to configure the Mobile Push Module. This gives you the maximum flexibility in SDK configuration.
            // The builder lets you configure the module parameters at runtime.
            let mobilePushConfiguration = PushConfigBuilder(appId: appId)
                .setAccessToken(accessToken)
                .setMarketingCloudServerUrl(appEndpoint)
                .setMid(mid)
                .setInboxEnabled(inbox)
                .setLocationEnabled(location)
                .setAnalyticsEnabled(analytics)
                .build()
            
            // Set the completion handler to take action when module initialization is completed. The result indicates if initialization was sucesfull or not.
            // Seting the completion handler is optional.
            let completionHandler: (OperationResult) -> () = { result in
                if result == .success {
                    // module is fully configured and ready for use
                } else if result == .error {
                    // module failed to initialize, check logs for more details
                } else if result == .cancelled {
                    // module initialization was cancelled (for example due to re-confirguration triggered before init was completed)
                } else if result == .timeout {
                    // module failed to initialize due to timeout, check logs for more details
                }
            }
                    
            // Once you've created the mobile push configuration, intialize the SDK.
            SFMCSdk.initializeSdk(ConfigBuilder().setPush(config: mobilePushConfiguration, onCompletion: completionHandler).build())
        }
        
        // SDK: REQUIRED IMPLEMENTATION
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            self.configureSDK()
            
            return true
        }
        
        // SDK: OPTIONAL IMPLEMENTATION (if using Data Protection)
        func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
            if (SFMCSdk.mp.getStatus() != .operational) {
                self.configureSFMCSdk()
            }
        }
    }
 */

@main
struct BesserSprechenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            VWMEHomeView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
