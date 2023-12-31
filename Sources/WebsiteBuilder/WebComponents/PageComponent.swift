public protocol PageComponent {
    var contents: String { get }
}

extension String: PageComponent {
    public var contents: String {
        self
    }
}
