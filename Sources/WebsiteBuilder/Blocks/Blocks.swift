public protocol Block {
    associatedtype Component: Block
    @BlockParser var component: Component { get }
}

public struct Text: Block, BaseBlock {
    let text: String

    public init(_ text: String) {
        self.text = text
    }
}

@resultBuilder
public enum BlockParser {

    public static func buildPartialBlock(first content: some Block)
        -> some Block
    {
        return content

    }

    public static func buildPartialBlock(
        accumulated: some Block, next: some Block
    )
        -> some Block
    {
        return TupleBlock(value: (accumulated, next))
    }

}

struct Nothing: Block, BaseBlock {}

protocol BaseBlock: Block {
}
extension BaseBlock {
    public var component: some Block {
        Nothing()
    }
}

struct TupleBlock: Block {
    let value: (acc: any Block, n: any Block)

    var component: some Block {
        Nothing()
    }
}
