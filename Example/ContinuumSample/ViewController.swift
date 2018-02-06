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

    private let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.observe(\.count, bindTo: countLabel, \.text)
        viewModel.observe(\.decrementAlpha, bindTo: decrementButton, \.alpha)
        viewModel.observe(\.isDecrementEnabled, bindTo: decrementButton, \.isEnabled)
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        viewModel.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        viewModel.decrement()
    }
}

final class ViewModel {
    private(set) var isDecrementEnabled = false {
        didSet { center.continuum.post(keyPath: \ViewModel.isDecrementEnabled) }
    }

    private(set) var decrementAlpha: CGFloat = 0.5 {
        didSet { center.continuum.post(keyPath: \ViewModel.decrementAlpha) }
    }

    private(set) var count: String = "" {
        didSet { center.continuum.post(keyPath: \ViewModel.count) }
    }

    private var _count: Int = 0 {
        didSet {
            count = String(describing: _count)
            isDecrementEnabled = _count > 0
            decrementAlpha = isDecrementEnabled ? 1 : 0.5
        }
    }
    private let center = NotificationCenter()
    private let bag = ContinuumBag()

    init() {
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
