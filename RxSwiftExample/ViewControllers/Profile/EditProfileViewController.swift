//
//  EditProfileViewController.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/21.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileViewController: UIViewController, Storyboarded {

    private let disposeBag = DisposeBag()
    var viewModel: EditProfileViewModel!

    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Profile"

//        (viewModel.name.asObservable() <-> nameTextField.rx.text.orEmpty.asObservable()).disposed(by: disposeBag)
//        (viewModel.birthday.asObservable() <-> birthdayTextField.rx.text.orEmpty.asObservable()).disposed(by: disposeBag)

        viewModel.name
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.birthday
            .bind(to: birthdayTextField.rx.text)
            .disposed(by: disposeBag)

        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.inputName)
            .disposed(by: disposeBag)

        birthdayTextField.rx.text.orEmpty
            .bind(to: viewModel.inputBirthday)
            .disposed(by: disposeBag)

        viewModel.isModified
            .bind(to: saveBarButton.rx.isEnabled)
            .disposed(by: disposeBag)

        saveBarButton.rx.tap
            .bind(to: viewModel.saveTap)
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
