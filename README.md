# Continuum

[![CI Status](http://img.shields.io/travis/marty-suzuki/Continuum.svg?style=flat)](https://travis-ci.org/marty-suzuki/Continuum)
[![Version](https://img.shields.io/cocoapods/v/Continuum.svg?style=flat)](http://cocoapods.org/pods/Continuum)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Continuum.svg?style=flat)](http://cocoapods.org/pods/Continuum)
[![Platform](https://img.shields.io/cocoapods/p/Continuum.svg?style=flat)](http://cocoapods.org/pods/Continuum)

NotificationCenter based Lightweight UI / AnyObject binder.

```swift
final class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!

    private let viewModel: ViewModel = ViewModel()
    private let center = NotificationCenter()
    private let bag = ContinuumBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        center.continuum
            .observe(viewModel.text, on: .main, bindTo: label, \.text)
            .disposed(by: bag)

        viewModel.text.value = "Binding this text to label.text!"
    }
}

final class ViewModel {
    let text: Variable<String>

    init() {
        self.text = Variable(value: "")
    }
}
```

## Usage

### 1. Observe object KeyPath and bind it to target KeyPath

NotificationCenter's instance has `continuum` property. You can access Continuum functions from it.

```swift
let center = NotificationCenter()
let observer = center.continuum.observe(viewModel, \.text, on: .main, bindTo: label, \.text)
```

Above source code means `observe viewModel's text propety and bind that value to label's text property on main thread`.
If property is observed, current value comes immediately.

#### Notify changes with `func post(keyPath:)`

If value changed, notify changes like this.

```swift
viewModel.text = "Changed"
center.continuum.post(keyPath: \ViewModel.text)
print(label.text) // Changed
```

### 2. Observe Constant / Variable and bind it to target KeyPath

Constant / Variable are value wrapper. Variable has getter / setter. Constant has only getter.

```swift
let center = NotificationCenter()
let text = Variable<String>(value: "")
let observer = center.continuum.observe(text, on: .main, bindTo: label, \.text)
```

If property is observed, current value comes immediately.

#### Notify changes with setter of value at Variable

If Variable's value is changed, `func post(name:object:)` is automatically executed.

```swift
text.value = "Changed"
print(label.text) // Changed
```

In addition, if Variable's value is changed, related Constant value is automatically changed.

```swift
let center = NotificationCenter()
let variable = Variable<String>(value: "")
let constant = Constant<String>(variable: variable)
let observer = center.continuum.observe(constant, on: .main, bindTo: label, \.text)
variable.value = "Changed"
print(label.text) // Changed
```

### Lifecycle of ContinuumObserver

`func observe(_:,_:,on:,bindTo:,_:)` returns `ContinuumObserver`.
If `func cancel()` of `ContinuumObserver` called, observation is cancelled.

```swift
let observer = center.continuum.observe(viewModel, \.text, on: .main, bindTo: label, \.text)
observer.cancel()
```

If adding observer to `ContinumeBag`, observation is cancelled by lifecycle of `ContinumeBag`.

```swift
var bag = ContinumeBag()
center.continuum
    .observe(viewModel, \.text, on: .main, bindTo: label, \.text)
    .disposed(by: bag)

bag = ContinumeBag() // previous instance of ContinumeBag is released and observation is cancelled.
```

## Example

### Playground

You can try **Continuum** with Playground.
Open Continuum.xcworkspace and run build.
You can try like this.

![](./Images/playground.png)

### Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Open ContinuumSample.xcworkspace and run build.
You can try a simple counter app like this.

![](./Images/example.png)

## Requirements

- Xcode 9.2 or later
- Swift 4.0.3 or later
- iOS 10.0 or later

## Installation

### CocoaPods

Continuum is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Continuum'
```

### Carthage

If you’re using [Carthage](https://github.com/Carthage/Carthage), simply add Continuum to your `Cartfile`:

```ruby
github "marty-suzuki/Continuum"
```

## Author

marty-suzuki, s1180183@gmail.com

## License

Continuum is available under the MIT license. See the LICENSE file for more info.
