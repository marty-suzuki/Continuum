//: Playground - noun: a place where people can play

import UIKit
import Continuum
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

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
