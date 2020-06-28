//
//  BaseViewController.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/25.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
