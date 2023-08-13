protocol StyledComponent {
    var styles: ComponentStyles { get }
}

extension Paragraph {

    public func style(foreground color: Color) -> Self {
        var copy = self
        copy.styles.styles.insert(.foreground(color))
        return copy
    }

    public func style(background color: Color) -> Self {
        var copy = self
        copy.styles.styles.insert(.background(color))
        return copy
    }
}

extension Heading {

    public func style(foreground color: Color) -> Self {
        var copy = self
        copy.styles.styles.insert(.foreground(color))
        return copy
    }

    public func style(background color: Color) -> Self {
        var copy = self
        copy.styles.styles.insert(.background(color))
        return copy
    }
}
