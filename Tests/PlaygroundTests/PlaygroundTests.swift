import XCTest

@testable import WebsiteBuilder

struct Test: Block, CustomStringConvertible {
    @State var count: Int = 0
    var component: some Block {
        Button("\(count)") {
            count += 1
        }
        if count.isMultiple(of: 2) {
            NestedState()
        }
        // else {
        //     Text("idk")
        // }
    }

    var description: String {
        "Test(\(count)):\(component)"
    }
}

struct NestedState: Block, CustomStringConvertible {
    @State var innerCount: Int = 0
    var component: some Block {
        Button("\(innerCount)") {
            innerCount += 1
            print("here \(innerCount)")
        }
    }

    var description: String {
        "Nested(\(innerCount)): \(component)"
    }
}
#warning("Test Nested State")
// TODO test nested State

final class PlaygroundTests: XCTestCase {

    func testCopy() {
        var t = Test()
        let d = Node("default")
        var tn = Node("t")
        t.saveState(d)
        t.saveState(tn)
        var c = t
        var cn = Node("c")
        c.saveState(cn)
        var tTup: TupleBlock {
            t.component as! TupleBlock
        }
        var tb: Button {
            tTup.value.acc as! Button
        }
        var cTup: TupleBlock {
            c.component as! TupleBlock
        }
        var cb: Button {
            cTup.value.acc as! Button
        }
        var carr: ArrayBlock {
            cTup.value.n as! ArrayBlock
        }
        var cnested: NestedState {
            carr.blocks[0] as! NestedState
        }
        var cinnerbutton: Button {
            cnested.component as! Button
        }

        // t.restoreState(tn)
        // tb.action()
        // t.saveState(tn)
        //
        c.restoreState(cn)
        cb.action()
        c.saveState(cn)
        c.restoreState(cn)
        cb.action()
        c.saveState(cn)
        print(cn)
        c.restoreState(cn)
        cinnerbutton.action()
        c.saveState(cn)
        // print(cn)
        // c.printBlock()
        //
        // let a = t
        // let an = Node("an")
        // a.restoreState(d)
        //
        // a.saveState(an)
        // print("t")
        // t.restoreState(tn)
        // //print(tn)
        // t.printBlock()
        // print("c")
        // c.restoreState(cn)
        // // print(cn)
        // c.printBlock()
        // print("a")
        // a.restoreState(an)
        // //print(an)
        // a.printBlock()
    }
}
