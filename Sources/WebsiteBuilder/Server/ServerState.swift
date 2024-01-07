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

private func setup(_ block: some Block) -> [(String, HTMLElement)] {
    let mirror = Mirror(reflecting: block)
    for (label, value) in mirror.children {
        let l = "\(label == nil ? "" : label!)"
        if let state = value as? any StateProperty {
            let b = state.value as! any BoxProperty
            // TODO save box somewhere?
            let newBox = b.clone()
            // print(type(of: state.value))
            // print(type(of: newBox))
            // print("@State: \(l) has state: \(state.value)")
            state.value = newBox
        }
    }

    if let base = block as? any BaseBlock {
        switch base.type {
        case .text:
            let text = block as! Text
            let textDiv = textDiv(text)
            return [(textDiv.rebuild(text.text), textDiv)]
        case .button:
            let button = block as! Button
            let btnInfo = setupButton(button)
            return [(btnInfo.rebuild(button.label), btnInfo)]
        case .tuple:
            let tuple = block as! TupleBlock
            // TODO flatten heigharchy correctly
            return setup(tuple.value.acc) + setup(tuple.value.n)
        }
    } else {
        return setup(block.component)
    }
}

func textDiv(_ text: Text) -> DivInfo {
    let buttonID = "\(UUID())"
    func rebuild(_ txt: String) -> String {
        return "<div id=\(buttonID)>\(txt)</div>"
    }
    return DivInfo(id: buttonID, rebuild: rebuild)
}

enum ElementType {
    case div
    case btn
}

protocol HTMLElement {
    var type: ElementType { get }
    var id: String { get }
}

struct DivInfo: HTMLElement {
    let type: ElementType = .div
    let id: String
    let rebuild: (String) -> String
}

struct ButtonInfo: HTMLElement {
    let type: ElementType = .btn
    let id: String
    let rebuild: (String) -> String
    let action: () -> Void
}

func setupButton(_ btn: Button) -> ButtonInfo {
    let buttonID = "\(UUID())"
    func buildDiv(_ label: String) -> String {
        return """
            <div id=\(buttonID) class="button" >\(label)</div>
            """
    }
    return ButtonInfo(id: buttonID, rebuild: buildDiv, action: btn.action)
}

struct UserState {
    let userID: String
    var actions: [String: () -> Void] = [:]
    var elements: [String: HTMLElement]
    var order: [Int: String] = [:]

    init(_ id: String, _ initElements: [HTMLElement]) {
        var e: [String: HTMLElement] = [:]
        var o: [Int: String] = [:]
        for (i, el) in initElements.enumerated() {
            print(i)
            o[i] = el.id
            e[el.id] = el
        }
        self.order = o
        self.elements = e
        // Setup session
        // - build html
        self.userID = id
    }

    func drawBody() -> String {
        print(order.count)
        var output = ""
        for i in 0..<order.count {
            let id = order[i]!
            let el = elements[id]!
            switch el.type {
            case .div:
                ()
            case .btn:
                let b = el as! ButtonInfo
                ()
            }
        }
        return "<div>\(userID)</div>"
    }
}

actor ServerState {

    init(_ root: some Block) {
        self.root = root
        let page = setup(root)
        var initHtml = ""
        var pageComponents: [HTMLElement] = []
        for (h, c) in page {
            // c = inital page components
            pageComponents += [c]
            print(c)
            initHtml += h
        }
        self.initialPage = initHtml
        self.pageComp = pageComponents
    }
    let pageComp: [HTMLElement]
    let initialPage: String
    let root: any Block
    var content: String = ""
    var connections: [String: UserState] = [:]

    /// Called when the user hits a button or request a state change to the page
    func update(_ id: String, _ input: String) -> String {
        let out: String
        if var userState = connections[id] {
            // Current connection
            print(userState.actions.count)
            if let a = userState.actions[input] {
                a()
            }
            // TODO handle logic from input
            let data = try? JSONEncoder().encode(
                ServerResult(html: userState.drawBody(), javascript: serverJS))
            if data != nil {
                out = String(data: data!, encoding: .utf8)!
            } else {
                out = "server error"
            }
            connections[id] = userState
        } else {
            var state = UserState(id, pageComp)
            print("new connection \(id)")
            // If it's a new connection will there ever be input?
            /*
            if let a = state.actions[input] {
                a()
            }
            */
            // TODO handle logic from input
            let data = try? JSONEncoder().encode(
                ServerResult(html: initialPage, javascript: serverJS))
            if data != nil {
                out = String(data: data!, encoding: .utf8)!
            } else {
                out = "server error"
            }
            connections[id] = state
        }
        return out
    }

    // Called every so oftent just to refresh the page and add a heart beat.
    // I don't know if I really need this but here for now.
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
