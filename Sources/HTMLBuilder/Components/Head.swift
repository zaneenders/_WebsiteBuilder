public struct Head: CustomStringConvertible {
    let sendJS: Bool
    let title: String
    let jsString = """
        <script src="/script.js" type="text/javascript" charset="utf-8"></script>
        """
    public var description: String {
        """
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(title)</title>\(sendJS ? jsString : "")
        </head>
        """
    }

    public init(title: String, js: Bool = false) {
        self.title = title
        self.sendJS = js
    }
}
