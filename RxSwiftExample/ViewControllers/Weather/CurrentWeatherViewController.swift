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

class CurrentWeatherViewController: BaseViewController, Storyboarded {

    private let disposeBag = DisposeBag()
    var viewModel = CurrentWeatherViewModel<LocationService, APIService>()

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!

    @IBOutlet weak var refreshLocationBarItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.currentLocation
            .bind(to: locationLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.currentTemp
            .bind(to: currentTempLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.weatherDesc
            .bind(to: weatherDescriptionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.tempMin
            .bind(to: tempMinLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.tempMax
            .bind(to: tempMaxLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.tempFeelsLike
            .bind(to: feelsLikeLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.showError
            .subscribe(onNext: { [weak self] in self?.showError(message: $0) })
            .disposed(by: disposeBag)

        refreshLocationBarItem.rx.tap
            .bind(to: viewModel.refreshLocation)
            .disposed(by: disposeBag)
    }
}
