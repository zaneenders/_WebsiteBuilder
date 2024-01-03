public protocol PageComponent {
    @available(*, renamed: "htmlView", message: "Refactor System")
    var contents: String { get }
}

extension PageComponent {
    var htmlView: String {
        contents
    }
}

extension String: PageComponent {
    public var contents: String {
        self
    }
}
