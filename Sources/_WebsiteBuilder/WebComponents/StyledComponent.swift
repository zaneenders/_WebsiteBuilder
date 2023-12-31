/*
Ok what im thinking is using protocols as a sort of composable CSS/ Style
application. I want to be able to use this on any type of element so im
thinking these protocols compile and output a style string which is then passed
into the element constructor. I think these should all be static as at compile
time we should known what type everything is. I don't know if this is how swift
actually works but I bet we can find out.
*/

public protocol StyledDiv: PageComponent {
    var content: String { get }
}

public protocol RedTextDiv: StyledDiv {}
public protocol BlueTextDiv: StyledDiv {}

extension StyledDiv {
    public var contents: String {
        styledContent
    }

    var styledContent: String {
        """
        <div style=\" \(Self.style) \" >\(content)</div>
        """
    }

    static var style: String {
        compile()
    }

    static func compile() -> String {
        let t = type(of: self)
        if Self.self is any RedTextDiv.Type {
            return "color:red;"
        } else {
            return "color:blue;"
        }
    }
}

@available(*, deprecated, message: "Testing out composed style protocols")
public struct RedDiv: RedTextDiv {
    public init(_ txt: String) {
        self.content = txt
    }
    public let content: String
}

/*
Maybe we have a `Style` struct that all the protocols can be applied to and that is passed into the elements.

can you restrict protocols to only being used on one type
*/
struct Style: StyleProtocol {
    typealias Style = Self

}

protocol StyleProtocol {
    associatedtype Style
}
/*
hmm not sure how that will work. The other Idea is to do protocols and apply the styles with Macros.
*/
