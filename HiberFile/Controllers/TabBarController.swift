/*
Copyright (C) 2020 Groupe MINASTE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
//
//  TabBarController.swift
//  HiberLink
//
//  Created by Nathan FALLET on 19/04/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let upload = UploadViewController()
    let history = HistoryTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Give delegates
        upload.delegate = history
        
        // Init upload
        let uploadNav = UINavigationController(rootViewController: upload)
        uploadNav.tabBarItem = UITabBarItem(title: "upload_title".localized(), image: UIImage(named: "Upload"), tag: 0)
        
        // Init history
        let historyNav = UINavigationController(rootViewController: history)
        historyNav.tabBarItem = UITabBarItem(title: "history_title".localized(), image: UIImage(named: "History"), tag: 0)

        // Add everything to tab bar
        viewControllers = [uploadNav, historyNav]
        
        // Load views
        for viewController in viewControllers ?? [] {
            if let navigationController = viewController as? UINavigationController, let rootVC = navigationController.viewControllers.first {
                let _ = rootVC.view
            } else {
                let _ = viewController.view
            }
        }
    }

}
