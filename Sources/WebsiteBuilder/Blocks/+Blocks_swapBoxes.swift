extension Block {

    func restoreState(_ node: Node) {
        let mirror = Mirror(reflecting: self)
        for (label, value) in mirror.children {
            let l = "\(label == nil ? "" : label!) : \(value)"
            if var state = value as? any StateProperty {
                var b = state.value as! any BoxProperty
                if let name = label {
                    if let v = node.states[node.name + " : " + name] {
                        node.states.removeValue(
                            forKey: node.name + " : " + name)
                        state.value = v
                    }
                }
            }
        }

        if let base = self as? any BaseBlock {
            switch base.type {
            case .array:
                let _ = self as! ArrayBlock
            case .text:
                let _ = self as! Text
            case .button:
                let _ = self as! Button
            case .tuple:
                let tuple = self as! TupleBlock
                let first = Node("acc: \(self) -> TupleBlock")
                tuple.value.acc.restoreState(first)
                let secound = Node("n: \(self) -> TupleBlock")
                tuple.value.n.restoreState(secound)
                node.children = [first, secound]
            }
        } else {
            let child = Node("\(self)")
            self.component.restoreState(child)
            node.children = [child]
        }
    }
    /*
    I think I need to make this a method on Block and pass a node in that contains the Boxes
    that I will swap in

    When do I create new Nodes vs use old ones?
    How do I handle ordering?
    */
    func saveState(_ node: Node) {
        let mirror = Mirror(reflecting: self)
        for (label, value) in mirror.children {
            let l = "\(label == nil ? "" : label!) : \(value)"
            if var state = value as? any StateProperty {
                var b = state.value as! any BoxProperty
                if let name = label {
                    let c = b.clone()
                    state.value = c
                    node.states[node.name + " : " + name] = b
                }
            }
        }

        if let base = self as? any BaseBlock {
            switch base.type {
            case .array:
                let _ = self as! ArrayBlock
            case .text:
                let _ = self as! Text
            case .button:
                let _ = self as! Button
            case .tuple:
                let tuple = self as! TupleBlock
                tuple.value.acc.saveState(Node("acc: \(self) -> TupleBlock"))
                tuple.value.n.saveState(Node("n: \(self) -> TupleBlock"))
            }
        } else {
            self.component.saveState(Node("\(self)"))
        }
    }

    func printBlock() {
        let mirror = Mirror(reflecting: self)
        for (label, value) in mirror.children {
            let l = "\(label == nil ? "" : label!) : \(value)"
            if var state = value as? any StateProperty {
                var b = state.value as! any BoxProperty
                print("@State [[\(b)]] ")
            }
        }

        if let base = self as? any BaseBlock {
            switch base.type {
            case .array:
                let array = self as! ArrayBlock
                print("ARRAY: ||")
                for a in array.blocks {
                    a.printBlock()
                }
                print("||")

            case .text:
                let text = self as! Text
                print("TEXT [[\(text.text)]]")
            case .button:
                let button = self as! Button
                print("Button ((\(button.label)))")
            case .tuple:
                let tuple = self as! TupleBlock
                print("{", terminator: "")
                tuple.value.acc.printBlock()
                tuple.value.n.printBlock()
                print("}", terminator: "\n")
            }
        } else {
            self.component.printBlock()
        }
    }
}
