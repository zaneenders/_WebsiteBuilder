public struct Latex: BodyComponent {
    let text: String
    public var html: String {
        """
        $\(text)$
        """
    }

    public init(_ text: String) {
        self.text = text
    }
}

extension Latex: CustomStringConvertible {
    public var description: String {
        html
    }
}
