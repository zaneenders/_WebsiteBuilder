public struct Heading: StyledComponent, BodyComponent {
    let text: String

    public var styles = ComponentStyles()

    let rank: Rank

    public enum Rank: Int {
        case one = 1
        case two
        case three
        case four
        case five
        case six
    }

    public var html: String {
        "<h\(rank.rawValue) \(styles.html())>\(text)</h\(rank.rawValue)>"
    }

    public init(_ rank: Rank, _ title: String) {
        self.text = title
        self.rank = rank
    }
}
