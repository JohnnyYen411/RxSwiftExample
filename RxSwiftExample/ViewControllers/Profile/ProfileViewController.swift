//
//  ProfileViewController.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/8.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ProfileViewController: UIViewController, Storyboarded {

    private var disposeBag = DisposeBag()
    var viewModel: ProfileViewModel!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var editBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        
        viewModel.name
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.birthday
            .bind(to: birthdayLabel.rx.text)
            .disposed(by: disposeBag)

        editBarButton.rx.tap
            .bind(to: viewModel.tapEdit)
            .disposed(by: disposeBag)
    }
}
