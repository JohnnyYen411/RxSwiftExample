//
//  Storyboarded.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/31.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit

enum AppStoryboards: String {
    case main = "Main"
    case profile = "Profile"
    case weather = "Weather"
}

protocol Storyboarded {
    static func instantiate(from storyboardOption: AppStoryboards) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(from storyboardOption: AppStoryboards) -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".").last
        let sb = UIStoryboard(name: storyboardOption.rawValue, bundle: Bundle.main)

        return sb.instantiateViewController(identifier: className!) as! Self
    }
}
