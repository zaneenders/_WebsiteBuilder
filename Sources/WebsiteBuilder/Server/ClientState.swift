import Foundation

extension ServerState {
    struct ClientState {
        let userID: String
        let block: any Block
        let rootNode: Node 
        // DOM State
        var actions: [String: () -> Void] = [:]
        var elements: [String: HTMLElement]
        var order: [Int: String] = [:]

        init(_ id: String, _ root: some Block) {
            let copy = root
            let page = setup(copy)
            self.block = copy
            self.rootNode = Node("\(block)")
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

        mutating func swapBoxes() {
            self.block.swapBoxes(rootNode)
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
}

// a setup function
private func setup(_ block: some Block) -> [(String, HTMLElement)] {
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
