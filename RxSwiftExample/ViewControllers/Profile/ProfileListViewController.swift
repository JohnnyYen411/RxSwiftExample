//
//  ProfileListViewController.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/5/8.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileListViewController: BaseViewController, Storyboarded {

    private var disposeBag = DisposeBag()
    let viewModel = ProfileListViewModel()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addProfileBarButton: UIBarButtonItem!
    @IBOutlet weak var clearAllBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile List"

        addProfileBarButton.rx.tap
            .bind(to: viewModel.toAddProfile)
            .disposed(by: disposeBag)

        clearAllBarButton.rx.tap
            .bind(to: viewModel.clearTap)
            .disposed(by: disposeBag)

        viewModel.didUpdateList
            .subscribe()
            .disposed(by: disposeBag)
        viewModel.didClear
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.showError
            .subscribe(onNext: { [weak self] in
                self?.showError(message: $0)
            })
            .disposed(by: disposeBag)

        viewModel.profileList
            .bind(to: tableView.rx.items(cellIdentifier: "ProfileCell", cellType: ProfileListTableViewCell.self)) { (row, element, cell) in
                element.name
                    .bind(to: cell.name.rx.text)
                    .disposed(by: cell.disposeBag)
                element.birthday
                    .bind(to: cell.birthday.rx.text)
                    .disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)

        viewModel.hasItems
            .bind(to: clearAllBarButton.rx.isEnabled)
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(ProfileProvider.self)
            .bind(to: viewModel.toProfile)
            .disposed(by: disposeBag)
    }

}

class ProfileListTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var birthday: UILabel!

    var disposeBag = DisposeBag()
}
