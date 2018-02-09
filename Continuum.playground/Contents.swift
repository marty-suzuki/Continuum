//: Playground - noun: a place where people can play

import UIKit
import Continuum
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// KeyPath
do {
    class ViewModel {
        var text = ""
    }

    let center = NotificationCenter()
    let viewModel = ViewModel()
    let label = UILabel()

    _ = center.continuum.observe(viewModel, \.text, bindTo: label, \.text)
    print("After observe: label.text = \(String(describing: label.text))")

    viewModel.text = "Great Scott!"
    center.continuum.post(keyPath: \ViewModel.text)
    print("After post: label.text = \(String(describing: label.text))")
}

// Constant<Element> and Variable<Element>
do {
    let center = NotificationCenter()

    let variable = Variable(value: "")
    let label = UILabel()

    let constant = Constant(variable: variable)
    let label2 = UILabel()

    _ = center.continuum.observe(variable, bindTo: label, \.text)
    _ = center.continuum.observe(constant, bindTo: label2, \.text)
    print("After observe: label.text = \(String(describing: label.text))")
    print("After observe: label2.text = \(String(describing: label2.text))")

    variable.value = "Nobody calls me chicken!"
    print("After post: label.text = \(String(describing: label.text))")
    print("After post: label2.text = \(String(describing: label2.text))")

    let v2 = Variable<String?>(value: "")
    _ = center.continuum.observe(constant, bindTo: v2, \Variable<String?>.value)
    print("After observe: v2.value = \(v2.value)")

    variable.value = "Back to the future!"
    print("After post: label.text = \(String(describing: label.text))")
    print("After post: label2.text = \(String(describing: label2.text))")
    print("After post: v2.value = \(v2.value)")
}
