//
//  ReactivePresentationControler.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/3.
//  Copyright © 2020 Test. All rights reserved.
//

import UIKit.UIPresentationController
import RxSwift
import RxCocoa

extension UIPresentationController: HasDelegate {
    public typealias Delegate = UIAdaptivePresentationControllerDelegate
}

class PresentationDelegateProxy: DelegateProxy<UIPresentationController, UIAdaptivePresentationControllerDelegate>, DelegateProxyType, UIAdaptivePresentationControllerDelegate {

    //#MARK: DelegateProxy
    init(parentObject: UIPresentationController) {
        super.init(parentObject: parentObject, delegateProxy: PresentationDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { PresentationDelegateProxy(parentObject: $0) }
    }

    deinit {
        didAttemptToDismiss.onCompleted()
        didDismiss.onCompleted()
        shouldDismiss.onCompleted()
        willDismiss.onCompleted()
    }

    lazy internal var didAttemptToDismiss: PublishSubject<UIPresentationController> = PublishSubject()
    lazy internal var didDismiss: PublishSubject<UIPresentationController> = PublishSubject()
    lazy internal var shouldDismiss: PublishSubject<UIPresentationController> = PublishSubject()
    lazy internal var willDismiss: PublishSubject<UIPresentationController> = PublishSubject()

    //MARK: UIAdaptivePresentationControllerDelegate
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        didAttemptToDismiss.onNext(presentationController)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        didDismiss.onNext(presentationController)
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        shouldDismiss.onNext(presentationController)
        return true
    }

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        willDismiss.onNext(presentationController)
    }
}

extension Reactive where Base: UIPresentationController {
    var delegate: PresentationDelegateProxy {
        return PresentationDelegateProxy.proxy(for: base)
    }

    var didAttemptToDismiss: Observable<UIPresentationController> {
        return PresentationDelegateProxy.proxy(for: base)
            .didAttemptToDismiss.asObservable()
    }

    var didDismiss: Observable<UIPresentationController> {
        return PresentationDelegateProxy.proxy(for: base)
            .didDismiss.asObservable()
    }

    var shouldDismiss: Observable<UIPresentationController> {
        return PresentationDelegateProxy.proxy(for: base)
            .shouldDismiss.asObservable()
    }

    var willDismiss: Observable<UIPresentationController> {
        return PresentationDelegateProxy.proxy(for: base)
            .willDismiss.asObservable()
    }
}
