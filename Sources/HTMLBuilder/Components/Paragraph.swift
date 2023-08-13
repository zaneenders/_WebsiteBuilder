public struct Paragraph: StyledComponent, BodyComponent {
    let text: String

    /*
    Maybe this needs to be a dictionary or a Set of Style because you can
    really only apply one of each style to each component.
    */
    public var styles = ComponentStyles()

    public var html: String {
        "<p \(styles.html())>\(text)</p>"
    }

    public init(_ text: String) {
        self.text = text
    }

    public init(@HTMLBuilder p: () -> Paragraph) {
        self = p()
    }
}

extension HTMLBuilder {
    public static func buildBlock(_ text: String) -> Paragraph {
        Paragraph(text)
    }
}
