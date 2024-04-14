//
//  SceneDelegate.swift
//  AvitoTechChallenge
//
//  Created by Denis on 08.04.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        // инжектим зависимости через инициализатор
        let searchScreen = SearchScreenView(viewModel: SearchScreenVM(model: iTunesApi()))
        let navigationController = UINavigationController(rootViewController: searchScreen)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}

