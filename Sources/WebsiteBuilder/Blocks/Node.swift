final class Node: CustomStringConvertible {
    let name: String
    var states: [String: Any]

    init(_ name: String) {
        self.name = name
        self.states = [:]
        // print("Node: [[\(name)]]")
    }

    var description: String {
        """
        \(name): [[
        \(states)
        ]]
        """
    }
}
