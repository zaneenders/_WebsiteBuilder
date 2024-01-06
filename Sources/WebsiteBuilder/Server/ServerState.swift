import Foundation

struct ServerResult: Codable {
    let html: String
    let javascript: String
}

actor ServerState {

    init(_ root: some Block) {
        self.root = root
        self.content = self.draw(root)
    }

    let root: any Block
    var content: String = ""
    var connections: [String: Int] = [:]
    var actions: [String: () -> Void] = [:]

    private func draw(_ block: some Block) -> String {
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
    func update(_ id: String, _ input: String) -> String {
        print(input)
        if let a = actions[input] {
            a()
        }
        // TODO handle logic from input
        let data = try? JSONEncoder().encode(
            ServerResult(html: draw(root), javascript: serverJS))
        if data != nil {
            return String(data: data!, encoding: .utf8)!
        } else {
            return "server error"
        }
    }

    func view(_ id: String) -> String {
        let data = try? JSONEncoder().encode(
            ServerResult(html: draw(root), javascript: serverJS))
        if data != nil {
            return String(data: data!, encoding: .utf8)!
        } else {
            return "server error"
        }
    }

    func increment(_ id: String) -> Int {
        if connections[id] == nil {
            connections[id] = 1
            return 1
        } else {
            let r = connections[id]! + 1
            connections[id] = r
            return r
        }
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
