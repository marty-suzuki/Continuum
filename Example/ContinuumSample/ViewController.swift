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
    private let center = NotificationCenter()
    private let bag = ContinuumBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        incrementButton.addTarget(viewModel, action: #selector(ViewModel.increment), for: .touchUpInside)
        decrementButton.addTarget(viewModel, action: #selector(ViewModel.decrement), for: .touchUpInside)

        center.continuum
            .observe(viewModel.count, bindTo: countLabel, \.text)
            .disposed(by: bag)

        center.continuum
            .observe(viewModel.decrementAlpha, bindTo: decrementButton, \.alpha)
            .disposed(by: bag)

        center.continuum
            .observe(viewModel.isDecrementEnabled, bindTo: decrementButton, \.isEnabled)
            .disposed(by: bag)
    }
}

final class ViewModel {
    let isDecrementEnabled: Constant<Bool>
    private let _isDecrementEnabled = Variable(value: false)

    let decrementAlpha: Constant<CGFloat>
    private let _decrementAlpha = Variable<CGFloat>(value: 0.5)

    let count: Constant<String>
    private let _count = Variable<String>(value: "")

    private var rawCount: Int = 0 {
        didSet {
            _count.value = String(describing: rawCount)
            _isDecrementEnabled.value = rawCount > 0
            _decrementAlpha.value = _isDecrementEnabled.value ? 1 : 0.5
        }
    }

    init() {
        self.isDecrementEnabled = Constant(variable: _isDecrementEnabled)
        self.decrementAlpha = Constant(variable: _decrementAlpha)
        self.count = Constant(variable: _count)
        setInitialValue()
    }

    private func setInitialValue() {
        rawCount = 0
    }

    @objc func increment() {
        rawCount += 1
    }

    @objc func decrement() {
        rawCount -= 1
    }
}
