//
//  CoreDataService.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/19.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

struct StorageService {

    enum Errors: Error {
        case fetchAll
        case deleteAll

        case insert(uuid: String)
        case entityNotFound(uuid: String)
        case fetch(uuid: String)
        case write(uuid: String)
    }

    private let backgroundContext: NSManagedObjectContext

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.init(container: appDelegate.persistentContainer, context: appDelegate.backgroundContext)
    }

    init(container: NSPersistentContainer, context: NSManagedObjectContext) {
        container.viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = context
    }

    func fetchAll() -> Observable<[Profile]> {
        let context = backgroundContext
        let fetchRequest = ProfileEntity.profileEntityFetchRequest()
        return Observable<[Profile]>.create { observer -> Disposable in
            context.performAndWait {
                do {
                    let entities = try context.fetch(fetchRequest)
                    var result = [Profile]()
                    for entity in entities {
                        result.append(entity.profile)
                    }
                    observer.onNext(result)
                } catch {
                    observer.onError(Errors.fetchAll)
                }
            }

            return Disposables.create()
        }
        .observeOn(MainScheduler.instance)
    }

    func deleteAll() -> Observable<Void> {
        let context = backgroundContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileEntity")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)

        return Observable<Void>.create { observer -> Disposable in
            context.performAndWait {
                do {
                    try context.execute(batchDelete)

                    observer.onNext(())
                } catch {
                    observer.onError(Errors.deleteAll)
                }
            }

            return Disposables.create()
        }
        .observeOn(MainScheduler.instance)
    }

    func insert(profile: Profile) -> Observable<Profile> {
        let context = backgroundContext
        let profileEntity = NSEntityDescription.insertNewObject(forEntityName: "ProfileEntity", into: context) as! ProfileEntity

        profileEntity.uuid = profile.getUuid()
        profileEntity.name = profile.name
        profileEntity.birthday = profile.birthday

        return Observable<Profile>.create { observer -> Disposable in
            context.performAndWait {
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    observer.onNext(profile)
                } catch {
                    observer.onError(Errors.insert(uuid: profile.getUuid()))
                }
            }

            return Disposables.create()
        }
        .observeOn(MainScheduler.instance)
    }

    func write(uuid: String, name: String, birthday: String) -> Observable<String> {
        let context = backgroundContext
        let request = ProfileEntity.profileEntityFetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", uuid)

        return Observable<String>.create { observer -> Disposable in
            context.performAndWait {
                do {
                    let entities = try context.fetch(request)
                    if let firstEntity = entities.first {
                        firstEntity.name = name
                        firstEntity.birthday = birthday

                        if context.hasChanges {
                            try context.save()
                        }

                        observer.onNext(uuid)
                    } else {
                        observer.onError(Errors.entityNotFound(uuid: uuid))
                    }
                } catch {
                    observer.onError(Errors.write(uuid: uuid))
                }
            }

            return Disposables.create()
        }
        .observeOn(MainScheduler.instance)
    }

    func fetch(uuid: String) -> Observable<Profile> {
        let context = backgroundContext
        let request = ProfileEntity.profileEntityFetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", uuid)

        return Observable<Profile>.create { observer -> Disposable in
            context.performAndWait {
                do {
                    let entities = try context.fetch(request)
                    if let firstEntity = entities.first {
                        observer.onNext(firstEntity.profile)
                    } else {
                        observer.onError(Errors.entityNotFound(uuid: uuid))
                    }
                } catch {
                    observer.onError(Errors.fetch(uuid: uuid))
                }
            }

            return Disposables.create()
        }
        .observeOn(MainScheduler.instance)
    }
}

extension StorageService.Errors: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .fetchAll: return "Unable to load data."
        case .deleteAll: return "Unable to clear data."

        case .insert(_): return "Unable to add profile"
        case .entityNotFound(_): return "Entity not found"
        case .fetch(_): return "Unable to fetch data"
        case .write(_): return "Unable to write data"
        }
    }
}
