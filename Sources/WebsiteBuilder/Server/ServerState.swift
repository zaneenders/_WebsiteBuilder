import Foundation

struct ServerResult: Codable {
    let html: String
    let javascript: String
}

var oldBox: Box<Int>!
var newBox: Box<Int>!

// a setup function
func setup(_ block: some Block) -> [(String, HTMLElement)] {
    let mirror = Mirror(reflecting: block)
    for (label, value) in mirror.children {
        let l = "\(label == nil ? "" : label!)"
        // If there is a state property create a new box to swap out with the orignal
        if let state = value as? any StateProperty {
            let bp = state.value as! any BoxProperty
            // TODO save box somewhere?
            #warning("Start here!!!")
            /*
            TODO move to UserState
            create a muating node tree to match the BlockGraph.
            Store the boxes in that graph and use a similar dirty equal to invlaid nodes
            Create new boxes as nessary
            keep starting boxes at starting state
            */
            oldBox = state.value as! Box<Int>
            print(
                Unmanaged.passUnretained(state.value as! AnyObject).toOpaque())
            let nb = bp.clone()
            newBox = nb as! Box<Int>
            print(Unmanaged.passUnretained(nb as! AnyObject).toOpaque())
            // swap box out
            state.value = nb
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

struct UserState {
    let userID: String
    let block: any Block

    // DOM State
    var actions: [String: () -> Void] = [:]
    var elements: [String: HTMLElement]
    var order: [Int: String] = [:]

    init(_ id: String, _ root: some Block) {
        let copy = root
        let page = setup(copy)
        self.block = copy
        var initHtml = ""
        var pageComponents: [HTMLElement] = []
        for (h, c) in page {
            // c = inital page components
            pageComponents += [c]
            initHtml += h
        }
        var e: [String: HTMLElement] = [:]
        var o: [Int: String] = [:]
        for (i, el) in pageComponents.enumerated() {
            o[i] = el.id
            e[el.id] = el
        }
        self.order = o
        self.elements = e
        // Setup session
        // - build html
        self.userID = id
    }

    mutating func drawBody() -> String {
        actions = [:]
        return draw(self.block)
    }

    mutating func draw(_ block: some Block) -> String {
        let mirror = Mirror(reflecting: block)
        for (label, value) in mirror.children {
            let l = "\(label == nil ? "" : label!)"
            if let state = value as? any StateProperty {
                let b = state.value as! any BoxProperty
            }
        }
        if let base = block as? any BaseBlock {
            switch base.type {
            case .text:
                let text = block as! Text
                return div { text.text }
            case .button:
                let button = block as! Button
                let id = "\(UUID())"
                let copy = userID
                actions[id] = {
                    // print("\(copy): \(id)")
                    button.action()
                }
                return """
                    <div id=\(id) class="button" >\(button.label)</div>
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

func printBlock(_ block: some Block) {
    let mirror = Mirror(reflecting: block)
    for (label, value) in mirror.children {
        let l = "\(label == nil ? "" : label!) : \(value)"
        if var state = value as? any StateProperty {
            var b = state.value as! any BoxProperty
        }
    }

    if let base = block as? any BaseBlock {
        switch base.type {
        case .text:
            let text = block as! Text
        case .button:
            let button = block as! Button
        case .tuple:
            let tuple = block as! TupleBlock
            printBlock(tuple.value.acc)
            printBlock(tuple.value.n)
        }
    } else {
        printBlock(block.component)
    }
}

actor ServerState {

    init(_ root: some Block) {
        self.root = root
    }

    let root: any Block
    var content: String = ""
    var connections: [String: UserState] = [:]

    func remove(_ id: String) {
        // TODO clean up Client State, Client has disconnected.
    }

    /// Called when the user hits a button or request a state change to the page
    func update(_ id: String, _ input: String) -> String {
        let out: String
        // Current connection
        if var userState = connections[id] {
            /*
            Maybe we swap out the boxes before and after applying the action and drawing the body.
            I do wonder how to keep track of which session needs which boxes.
            Might have to do a Node tree:while condition
            */
            print(oldBox?.value)
            print(newBox?.value)
            if let a = userState.actions[input] {
                a()
            }
            print(oldBox?.value)
            print(newBox?.value)
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
            // Create new state
            var state = UserState(id, root)
            printBlock(state.block)
            print("new connection \(id)")
            // If it's a new connection will there ever be input?
            /*
            if let a = state.actions[input] {
                a()
            }
            */
            // TODO handle logic from input
            let data = try? JSONEncoder().encode(
                ServerResult(html: state.drawBody(), javascript: serverJS))
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
