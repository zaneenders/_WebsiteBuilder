import Foundation

struct ServerResult: Codable {
    let html: String
    let javascript: String
}

var oldBox: Box<Int>!
var newBox: Box<Int>!

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
    var connections: [String: ClientState] = [:]

    func createClientState(_ id: String) -> ClientState {
        ClientState(id, root)
    }

    func remove(_ id: String) {
        // TODO clean up Client State, Client has disconnected.
    }

    /// Called when the client hits a button or request a state change to the page
    func update(_ id: String, _ input: String) -> String {
        let out: String
        // Current connection
        if var clientState = connections[id] {
            /*
            Maybe we swap out the boxes before and after applying the action and drawing the body.
            I do wonder how to keep track of which session needs which boxes.
            Might have to do a Node tree:while condition
            */
            print(oldBox?.value)
            print(newBox?.value)
            if let a = clientState.actions[input] {
                a()
            }
            print(oldBox?.value)
            print(newBox?.value)
            // TODO handle logic from input
            let data = try? JSONEncoder().encode(
                ServerResult(html: clientState.drawBody(), javascript: serverJS)
            )
            if data != nil {
                out = String(data: data!, encoding: .utf8)!
            } else {
                out = "server error"
            }
            connections[id] = clientState
        } else {
            // Create new state
            var state = createClientState(id)
            printBlock(state.block)
            print("new connection \(id)")
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
