//
//  WebViewController.swift
//  SpriteKitApp
//
//  Created by NikoS on 26.05.2023.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView: WKWebView?
    var webSceneDelegate: WebSceneDelegate?
    
    override func loadView() {
        if let webView = webView {
            view = webView
        }
        
        setupNavigationBar()
    }
    
    @objc
    private func backButtonTapped() {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.rootViewController?.dismiss(animated: true, completion: nil)
                webSceneDelegate?.didTapBackButton()
            }
        }
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(title: Constants.backButtonTitleText, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
}

