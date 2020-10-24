//
//  CustomShareNavigationController.swift
//  HiberFile Input
//
//  Created by PlugN on 24/10/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import Foundation
import UIKit

// 1: Set the `objc` annotation
@objc(CustomShareNavigationController)
class CustomShareNavigationController: UINavigationController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // 2: set the ViewControllers
        self.setViewControllers([CustomShareViewController()], animated: false)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
