@propertyWrapper
public struct State<Value> {
    private let _storage: Storage<Value>

    public init(wrappedValue: Value) {
        self._storage = Storage(wrappedValue)
    }

    public var wrappedValue: Value {
        get {
            _storage.value
        }
        nonmutating set {
            _storage.value = newValue
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

final class Storage<Value> {

    var value: Value

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
