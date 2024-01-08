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

// still not sure how I wanna do my Box type

final class Box<Value>: BoxProperty {

    func clone() -> Box<Value> {
        // print("clone")
        return Box(value)
    }

    var __value: Value

    var value: Value {
        get {
            // print("getting")
            // print(__value)
            // print(Unmanaged.passUnretained(__value as! AnyObject).toOpaque())
            return __value
        }

        set {
            // print("setting")
            // print(__value)
            // print(Unmanaged.passUnretained(__value as! AnyObject).toOpaque())
            __value = newValue
        }
    }

    var _value: Value {
        value
    }

    init(_ value: Value) {
        self.__value = value
    }
}

@propertyWrapper
public struct State<Value>: StateProperty {
    /*
    So switching the boxes does work. But because we can't change the outter most box
    becase it is nonmutating all copies have to route through that one pointer.
    That seems like a problem and a bottle neck

    I think I can fake it be wrapping it in an actor and updating and viewing the boxes
    per request
    */
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
