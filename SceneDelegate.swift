//
//  SceneDelegate.swift
//  BesserSprechen
//
//  Created by Zachary Linehan on 26.11.23.
//

import Foundation
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let homeView = VWMEHomeView() // Set HomeView as the initial view
            window.rootViewController = UIHostingController(rootView: homeView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
