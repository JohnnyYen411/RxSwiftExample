//
//  AddProfileViewController.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/8.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddProfileViewController: UIViewController, Storyboarded {

    private var disposeBag = DisposeBag()
    let viewModel = AddProfileViewModel(StorageServices())

    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Profile"

        saveBarButton.isEnabled = false

        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)

        birthdayTextField.rx.text.orEmpty
            .bind(to: viewModel.birthday)
            .disposed(by: disposeBag)

        saveBarButton.rx.tap
            .bind(to: viewModel.saveTap)
            .disposed(by: disposeBag)

        viewModel.isValid
            .bind(to: saveBarButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.showError
            .subscribe(onNext: { [weak self] in
                self?.showError(message: $0)
            })
            .disposed(by: disposeBag)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
