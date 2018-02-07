//
//  ViewController.swift
//  ContinuumSample
//
//  Created by marty-suzuki on 2018/02/07.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import Continuum

final class ViewController: UIViewController {

    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!

    private lazy var viewModel = ViewModel(center: self.center, bag: bag)

    private let center = NotificationCenter()
    private let bag = ContinuumBag()


    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.observe(\.count, bindTo: countLabel, \.text)

        center.continuum
            .observe(viewModel.decrementAlpha, bindTo: decrementButton, \.alpha)
            .disposed(by: bag)

        center.continuum
            .observe(viewModel.isDecrementEnabled, bindTo: decrementButton, \.isEnabled)
            .disposed(by: bag)
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        viewModel.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        viewModel.decrement()
    }
}

final class ViewModel {
    let isDecrementEnabled: Constant<Bool>
    private let _isDecrementEnabled = Variable(value: false)

    let decrementAlpha: Constant<CGFloat>
    private let _decrementAlpha = Variable<CGFloat>(value: 0.5)

    private(set) var count: String = "" {
        didSet { center.continuum.post(keyPath: \ViewModel.count) }
    }

    private var _count: Int = 0 {
        didSet {
            count = String(describing: _count)
            _isDecrementEnabled.value = _count > 0
            _decrementAlpha.value = _isDecrementEnabled.value ? 1 : 0.5
        }
    }

    let center: NotificationCenter
    let bag: ContinuumBag

    init(center: NotificationCenter, bag: ContinuumBag) {
        self.center = center
        self.bag = bag
        self.isDecrementEnabled = Constant(variable: _isDecrementEnabled)
        self.decrementAlpha = Constant(variable: _decrementAlpha)
        setInitialValue()
    }

    private func setInitialValue() {
        _count = 0
    }

    func increment() {
        _count += 1
    }

    func decrement() {
        _count -= 1
    }

    func observe<T: AnyObject, V>(_ keyPath1: KeyPath<ViewModel, V>,
                                bindTo target: T,
                                _ keyPath2: ReferenceWritableKeyPath<T, V>) {
        center.continuum
            .observe(self, keyPath1, on: .main, bindTo: target, keyPath2)
            .disposed(by: bag)
    }

    func observe<V1, T: AnyObject, V2: Wrappable>(_ keyPath1: KeyPath<ViewModel, V1>,
                                                  bindTo target: T,
                                                  _ keyPath2: ReferenceWritableKeyPath<T, V2>) where V1 == V2.Wrapped {
        center.continuum
            .observe(self, keyPath1, on: .main, bindTo: target, keyPath2)
            .disposed(by: bag)
    }

    func observe<V1: Wrappable, T: AnyObject, V2>(_ keyPath1: KeyPath<ViewModel, V1>,
                                                  bindTo target: T,
                                                  _ keyPath2: ReferenceWritableKeyPath<T, V2>) where V1.Wrapped == V2 {
        center.continuum
            .observe(self, keyPath1, on: .main, bindTo: target, keyPath2)
            .disposed(by: bag)
    }
}
