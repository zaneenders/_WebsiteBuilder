extension Block {
    /*
    I think I need to make this a method on Block and pass a node in that contains the Boxes
    that I will swap in
    */
    func swapBoxes() {
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
                tuple.value.acc.swapBoxes()
                tuple.value.n.swapBoxes()
            }
        } else {
            self.component.swapBoxes()
        }
    }
}
