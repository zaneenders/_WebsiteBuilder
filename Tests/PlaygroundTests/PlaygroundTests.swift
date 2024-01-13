import XCTest

@testable import WebsiteBuilder
struct Test: Block {
    @State var count: Int = 0
    var component: some Block {
        Button("\(count)"){
            count += 1
        }
        if count.isMultiple(of: 2) {
            Text("hello")
        }
        // else {
        //     Text("idk")
        // }
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
        t.restoreState(tn)
        print("tn: \(tn)")
        print("t\(t)")
        print("c\(c)")
        tb.action()
        print("t\(t)")
        print("c\(c)")
        t.saveState(tn)
        print("tn: \(tn)")
        print("cn: \(cn)")
        c.restoreState(cn)
        print("t\(t)")
        print("c\(c)")
        cb.action()
        cb.action()
        print("t\(t)")
        print("c\(c)")
        c.saveState(cn)
        print("tn: \(tn)")
        print("cn: \(cn)")
        let a = t
        let an = Node("an")
        a.restoreState(d)
        a.saveState(an)
        print("tn: \(tn)")
        print("cn: \(cn)")
        print("an: \(an)")

        t.restoreState(tn)
        t.printBlock()
        c.restoreState(cn)
        c.printBlock()
        a.restoreState(an)
        a.printBlock()
    } 
}
