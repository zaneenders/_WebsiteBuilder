final class Node {

    var states: [String: Any]

    init(_ name: String) {

        self.states = [:]
        print("Node: [[\(name)]]")
    }
}
