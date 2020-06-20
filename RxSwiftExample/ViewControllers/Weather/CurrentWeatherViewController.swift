//
//  CurrentWeatherViewController.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/8.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CurrentWeatherViewController: UIViewController, Storyboarded {

    private let disposeBag = DisposeBag()
    var viewModel = CurrentWeatherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()


    }
}
