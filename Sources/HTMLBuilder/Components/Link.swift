public struct Link: BodyComponent, StyledComponent {
    let styles: ComponentStyles = ComponentStyles(.link)
    let text: String
    let pathTo: String
    public var html: String {
        """
        <a href=\"\(pathTo)\" \(styles.html())>\(text)</a>
        """
    }

    public init(_ text: String, to: String) {
        self.pathTo = to
        self.text = text
    }
}
