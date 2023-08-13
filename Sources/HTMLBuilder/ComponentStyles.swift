enum ComponentStyleType {
    case link
    case other
}

public struct ComponentStyles {
    var styles: Set<Style>
    let type: ComponentStyleType

    init(_ type: ComponentStyleType = .other) {
        self.styles = []
        self.type = type
    }

    func html() -> String {
        guard styles.count > 0 else {
            return ""
        }
        switch type {
        case .other:
            var styleString = "style=\""
            for style in styles.sorted(by: { $0 < $1 }) {
                switch style {
                case .foreground(let c):
                    styleString += "color: \(c);"
                case .background(let c):
                    styleString += "background-color: \(c);"
                case .alignment(let a):
                    styleString += "text-align: \(a);"
                }
                styleString += " "
            }
            return styleString + "\""
        case .link:
            return ""
        }
    }
}
