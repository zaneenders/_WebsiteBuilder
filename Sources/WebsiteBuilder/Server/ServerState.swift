import Foundation

struct ServerResult: Codable {
    let html: String
    let javascript: String
}

struct UserState {
    let userID: String
    let root: any Block
    var actions: [String: () -> Void] = [:]

    init(_ id: String, _ root: some Block) {
        self.userID = id
        self.root = root
    }

    mutating func draw() -> String {
        draw(root)
    }

    private mutating func draw(_ block: some Block) -> String {
        if let base = block as? any BaseBlock {
            switch base.type {
            case .text:
                let text = block as! Text
                return div { text.text }
            case .button:
                let button = block as! Button
                let buttonID = UUID()
                let action = button.action
                actions["\(buttonID)"] = action
                // mark button with a hash and save button for that hash
                return """
                    <div id=\(buttonID) class="button" >\(button.label)</div>
                    """
            case .tuple:
                let tuple = block as! TupleBlock
                return draw(tuple.value.acc) + draw(tuple.value.n)
            }
        } else {
            return draw(block.component)
        }
    }
}

actor ServerState {

    init(_ root: some Block) {
        self.root = root
    }

    let root: any Block
    var content: String = ""
    var connections: [String: UserState] = [:]

    func update(_ id: String, _ input: String) -> String {
        print(input)
        let out: String
        if var userState = connections[id] {
            if let a = userState.actions[input] {
                a()
            }
            // TODO handle logic from input
            let data = try? JSONEncoder().encode(
                ServerResult(html: userState.draw(), javascript: serverJS))
            if data != nil {
                out = String(data: data!, encoding: .utf8)!
            } else {
                out = "server error"
            }
            connections[id] = userState
        } else {
            var state = UserState(id, root)
            if let a = state.actions[input] {
                a()
            }
            // TODO handle logic from input
            let data = try? JSONEncoder().encode(
                ServerResult(html: state.draw(), javascript: serverJS))
            if data != nil {
                out = String(data: data!, encoding: .utf8)!
            } else {
                out = "server error"
            }
            connections[id] = state
        }
        return out
    }

    func view(_ id: String) -> String {
        update(id, "")
    }

    var serverJS: String {
        """
        document.title = "Zane Enders"
        let btns = document.querySelectorAll(".button")
        for (let btn of btns) {
            btn.addEventListener(`click`, function (e) {
                console.log(btn.id)
                wsconnection.send(btn.id)
            })
        }
        """
    }
}
