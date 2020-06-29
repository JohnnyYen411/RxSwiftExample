//
//  ProfileListProvider.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/3.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class ProfileListProvider {
    private var list: [ProfileProvider] = []
    private let storageService: StorageService

    //Outputs
    let providers = BehaviorSubject<[ProfileProvider]>(value: [])

    init(_ storageService: StorageService) {
        self.storageService = storageService
    }

    deinit {
        providers.onCompleted()
    }

    func update() -> Observable<Void> {
        let storServ = storageService
        return storServ.fetchAll()
            .map { [ProfileProvider]($0, storServ) }
            .map { [weak self] in
                self?.list = $0
                self?.providers.onNext($0)
            }
    }

    func clearAll() -> Observable<Void> {
        let storServ = storageService
        return storServ.deleteAll()
            .flatMap { storServ.fetchAll() }
            .map { [ProfileProvider]($0, storServ) }
            .map { [weak self] in
                self?.list = $0
                self?.providers.onNext($0)
            }
    }
}
