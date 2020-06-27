//
//  MainViewController.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/8.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: BaseViewController, Storyboarded {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var weatherButton: UIButton!

    private let disposeBag = DisposeBag()
    var viewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Main"

        profileButton.rx.tap
            .bind(to: viewModel.toProfile)
            .disposed(by: disposeBag)

        weatherButton.rx.tap
            .bind(to: viewModel.toWeather)
        .disposed(by: disposeBag)
    }
}
