public enum ListStyle {
    case unordered
    case ordered

    func html() -> String {
        switch self {
        case .ordered:
            return "ol"
        case .unordered:
            return "ul"
        }
    }
}

public struct List: BodyComponent, StyledComponent {

    let styles: ComponentStyles = ComponentStyles(.link)
    let style: ListStyle
    let listItems: [ListItem]
    public var html: String {
        """
        <\(style.html()) \(styles.html())>
        \(toHTML(listItems))
        </\(style.html())>
        """
    }

    // TODO @resultBuilder
    public init(_ listItems: [ListItem], _ style: ListStyle = .unordered) {
        self.style = style
        self.listItems = listItems
    }

    private func toHTML(_ listItems: [ListItem]) -> String {
        listItems.reduce(
            "",
            { one, two in
                return one + two.html
            })
    }
}
