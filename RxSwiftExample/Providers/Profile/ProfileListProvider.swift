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
    private let storageServices: StorageServices

    //Outputs
    let providers = BehaviorSubject<[ProfileProvider]>(value: [])

    init(_ storageServices: StorageServices) {
        self.storageServices = storageServices
    }

    deinit {
        providers.onCompleted()
    }

    func update() -> Observable<Void> {
        let storServ = storageServices
        return storServ.fetchAll()
            .map { [ProfileProvider]($0, storServ) }
            .map { [weak self] in
                self?.list = $0
                self?.providers.onNext($0)
            }
    }

    func clearAll() -> Observable<Void> {
        let storServ = storageServices
//        return storServ.deleteAll()
        return Observable.error(StorageServices.Errors.deleteAll)
            .flatMap { storServ.fetchAll() }
            .map { [ProfileProvider]($0, storServ) }
            .map { [weak self] in
                self?.list = $0
                self?.providers.onNext($0)
            }
    }
}

extension Array where Element == ProfileProvider {

    init(_ profiles: [Profile], _ storageServices: StorageServices) {
        self = profiles.map{ ProfileProvider(storageServices, $0) }
    }
}
