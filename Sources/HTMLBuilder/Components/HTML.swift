public struct HTML: CustomStringConvertible {
    let body: Body
    let head: Head

    public var description: String {
        html()
    }

    private func html() -> String {
        return """
            <!DOCTYPE html>
            <html lang="en">
            \(head.description)
            \(bodyString())
            </html>
            """
    }

    private func bodyString() -> String {
        "<body>\(body.html)</body>"
    }

    public init(_ head: Head, @HTMLBuilder body: () -> Body) {
        self.head = head
        self.body = body()
        // TODO get and build a CSS struct from components
        /*
        - do we compile the referenced css from head?
        - How do we pass down a CSS object
        */
    }

    public func css() -> CSS {
        CSS()
    }
}

extension HTMLBuilder {
    public static func buildBlock(_ body: Body) -> Body {
        body
    }
}
