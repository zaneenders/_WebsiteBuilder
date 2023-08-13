public struct Body: HTMLView {

    var bodyComponents: [BodyComponent]

    public var html: String {
        let h = bodyComponents.reduce("") { r, c in
            r + c.html
        }
        return "\(h)"
    }

    init(_ bodyComponents: [BodyComponent]) {
        self.bodyComponents = bodyComponents
    }

    public init(@HTMLBuilder components: () -> Body) {
        self = components()
    }
}

extension HTMLBuilder {
    public static func buildBlock(_ components: BodyComponent...) -> Body {
        Body(components)
    }
}
