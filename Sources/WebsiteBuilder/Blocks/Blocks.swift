public protocol Block {
    associatedtype Component: Block
    @BlockParser var component: Component { get }
}

public struct Button: Block, BaseBlock, CustomStringConvertible {
    let type: BlockType = .button
    let label: String
    let action: () -> Void

    public init(_ label: String, _ action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    public var description: String {
        "BUTTON:[[\(label)]]"
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

    public static func buildEither(first: some Block) -> ArrayBlock {
        ArrayBlock(blocks: [first])
    }

    public static func buildEither(second: some Block) -> ArrayBlock {
        ArrayBlock(blocks: [second])
    }

    public static func buildArray(_ components: [some Block]) -> ArrayBlock {
        return ArrayBlock(blocks: components)
    }

    public static func buildOptional(_ component: (any Block)?) -> ArrayBlock {
        switch component {
        case .none:
            return ArrayBlock(blocks: [])
        case .some(let b):
            return ArrayBlock(blocks: [b])
        }
    }
}

public struct ArrayBlock: Block, BaseBlock, CustomStringConvertible {
    let type: BlockType = .array
    let blocks: [any Block]

    public var description: String {
        "ARRAY[\(blocks)]"
    }
}

struct Nothing: Block, BaseBlock {
    var type: BlockType {
        fatalError("not a valid block")
    }
}

enum BlockType {
    case array
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

struct TupleBlock: Block, BaseBlock, CustomStringConvertible {
    let value: (acc: any Block, n: any Block)
    let type: BlockType = .tuple

    var description: String {
        "\(value.acc), \(value.n)"
    }
}
