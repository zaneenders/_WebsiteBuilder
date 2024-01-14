final class Node: CustomStringConvertible {
    let name: String
    var states: [String: Any]
    var children: [Node]

    init(_ name: String) {
        self.name = name
        self.states = [:]
        self.children = []
    }

    var description: String {
        """

        ((\(name)
            states:[[\(statesDescption)]]
            children(\(children.count)):{{\(childrenDescption)}}
        ))

        """
    }

    var statesDescption: String {
        var out = ""
        // for (id,s) in states {
        //     out.append("\(id):\(s)\n")
        // }
        out = "\(states.count)"
        return out
    }

    var childrenDescption: String {
        var out = "\n"
        for c in children {
            out.append("{$$$\(c)$$$}\n\n")
        }
        return out
    }
}
