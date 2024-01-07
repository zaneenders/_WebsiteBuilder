import Foundation

struct ServerResult: Codable {
    let html: String
    let javascript: String
}

private func clone(_ block: some Block) -> any Block {
    return block
    /*
    well I'm not really sure what to do as I need to make a clone of this nested block structure so that the functions mutate the right
    state and not a nested combined state
    ["[IPv6]::1/::1:46950":
        WebsiteBuilder.UserState(userID:
            "[IPv6]::1/::1:46950",
        view: Public.HomeBlock(
            _count: WebsiteBuilder.State<Swift.Int>(_storage: WebsiteBuilder.Storage<Swift.Int>),
            _count2: WebsiteBuilder.State<Swift.Int>(_storage: WebsiteBuilder.Storage<Swift.Int>)),
        actions: [
            "5207ACE3-69C4-4223-92EA-069B40BF7756": (Function),
            "AB9FD655-A0C7-48CF-A64C-58C969C81D2D": (Function),
            "B2FF86DE-0BC9-4ACB-81C8-C194B0F4514E": (Function),
            "C2CA4CB4-C88B-4D39-933B-D74EA444CD59": (Function),
            "7125626F-3C44-4C70-A2C6-D05EB3993A39": (Function),
            "44528E32-4EBF-4000-854D-FE896634B599": (Function)]),
     "[IPv6]::1/::1:46938":
        WebsiteBuilder.UserState(userID:
            "[IPv6]::1/::1:46938",
        view: Public.HomeBlock(
            _count: WebsiteBuilder.State<Swift.Int>(_storage: WebsiteBuilder.Storage<Swift.Int>),
            _count2: WebsiteBuilder.State<Swift.Int>(_storage: WebsiteBuilder.Storage<Swift.Int>)),
        actions: [
            "3F36630D-7877-412C-B39A-52B83FE2C073": (Function),
            "DBF77CDA-1266-4994-938C-1C484C6981C7": (Function),
            "AC223714-7D52-4168-BA36-4282F091E27D": (Function),
            "7C3AA256-D24E-4544-BAD9-E56E8DA1B059": (Function)
        ])
    ]
    */
    if let base = block as? any BaseBlock {
        switch base.type {
        case .text:
            let text = block as! Text
            return Text(text.text)
        case .button:
            let button = block as! Button
            return Button(button.label, button.action)
        case .tuple:
            let tuple = block as! TupleBlock
            return TupleBlock(
                value: (clone(tuple.value.acc), clone(tuple.value.n)))
        }
    } else {
        return clone(block.component)
    }
}

struct UserState {
    let userID: String
    let view: any Block
    var actions: [String: () -> Void] = [:]

    init(_ id: String, _ root: some Block) {
        let b = clone(root)
        self.userID = id
        self.view = b
    }

    mutating func draw() -> String {
        draw(view)
    }

    // BUG need to only add actions once not every draw
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
        let out: String
        if var userState = connections[id] {
            // TODO
            print(userState.actions.count)
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
