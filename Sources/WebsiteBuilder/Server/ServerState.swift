import Foundation  // used for UUID

var oldBox: Box<Int>!
var newBox: Box<Int>!

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
        connections.removeValue(forKey: id)
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
            // TODO find boxes to swap
            print(oldBox?.value)
            print(newBox?.value)
            clientState.swapBoxes()
            print(oldBox?.value)
            print(newBox?.value)
            if let a = clientState.actions[input] {
                a()
            }
            // TODO handle logic from input
            let data = try? JSONEncoder().encode(
                ServerResult(html: clientState.drawBody(), javascript: serverJS)
            )
            // Swap boxes back for next action
            // This is a bottle neck but idk, gotta try something
            clientState.swapBoxes()
            print(oldBox?.value)
            print(newBox?.value)
            if data != nil {
                out = String(data: data!, encoding: .utf8)!
            } else {
                out = "server error"
            }
            connections[id] = clientState
        } else {
            // Create new state
            var state = createClientState(id)
            state.block.printBlock()
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
