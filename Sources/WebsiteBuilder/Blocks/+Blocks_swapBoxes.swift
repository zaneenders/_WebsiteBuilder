extension Block {
    /*
    I think I need to make this a method on Block and pass a node in that contains the Boxes
    that I will swap in

    When do I create new Nodes vs use old ones?
    How do I handle ordering?
    */
    func swapBoxes(_ node: Node) {
        let mirror = Mirror(reflecting: self)
        for (label, value) in mirror.children {
            let l = "\(label == nil ? "" : label!) : \(value)"
            if var state = value as? any StateProperty {
                var b = state.value as! any BoxProperty
                print("Swapping \(self)")
                // TODO swap
            }
        }

        if let base = self as? any BaseBlock {
            switch base.type {
            case .text:
                let _ = self as! Text
            case .button:
                let _ = self as! Button
            case .tuple:
                let tuple = self as! TupleBlock
                tuple.value.acc.swapBoxes(Node("acc: \(self) -> TupleBlock"))
                tuple.value.n.swapBoxes(Node("n: \(self) -> TupleBlock"))
            }
        } else {
            self.component.swapBoxes(Node("\(self)"))
        }
    }
}
