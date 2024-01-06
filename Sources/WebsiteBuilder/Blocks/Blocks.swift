public protocol Block {
    associatedtype Component: Block
    @BlockParser var component: Component { get }
}

public struct Button: Block, BaseBlock {
    let type: BlockType = .button
    let label: String
    let action: () -> Void

    public init(_ label: String, _ action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
}

public struct Text: Block, BaseBlock {
    let type: BlockType = .text
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

struct Nothing: Block, BaseBlock {
    var type: BlockType {
        fatalError("not a valid block")
    }
}

enum BlockType {
    case button
    case text
    case tuple
}

protocol BaseBlock: Block {
    var type: BlockType { get }
}
extension BaseBlock {
    public var component: some Block {
        Nothing()
    }
}

struct TupleBlock: Block, BaseBlock {
    let value: (acc: any Block, n: any Block)
    let type: BlockType = .tuple
}
