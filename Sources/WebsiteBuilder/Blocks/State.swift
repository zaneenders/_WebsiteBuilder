@propertyWrapper
public struct State<Value>: StateProperty {
    private var box: Box<Box<Value>>

    public init(wrappedValue: Value) {
        self.box = Box(Box(wrappedValue))
    }

    public var wrappedValue: Value {
        get { box.value.value }
        nonmutating set { box.value.value = newValue }
    }

    var value: Any {
        get { box.value }
        nonmutating set {
            box.value = newValue as! Box<Value>
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                self.wrappedValue = newValue
            })
    }
}

// protocols uses to swap boxes

protocol StateProperty {
    var value: Any { get nonmutating set }
}

protocol BoxProperty<T> {
    associatedtype T
    associatedtype B = Box<T>

    var _value: T { get }
    /// Creates a new box and places the current value in the new box
    func clone() -> B
}

final class Box<Value>: BoxProperty {

    func clone() -> Box<Value> {
        return Box(value)
    }

    var value: Value

    var _value: Value {
        value
    }

    init(_ value: Value) {
        self.value = value
    }
}

@propertyWrapper
public struct Binding<Value> {

    var get: () -> Value
    var set: (Value) -> Void

    public var wrappedValue: Value {
        get {
            return get()
        }
        nonmutating set {
            return set(newValue)
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: get,
            set: set)
    }
}
