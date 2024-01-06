public protocol WebPage: HasURL, HasContent, HasSubPages {
    // TODO maybe rename with an underscore so this is harder to overwrite?
    var contents: String { get }
    init()  // Thing I will want to change this.
    // So that things can be composed and you pass in one initialized tree
}

extension WebPage {
    public static var url: String {
        fatalError("broken")
    }

    public static var link: HTMLString {
        makeLink(self)
    }

    public static var linkInNewTab: HTMLString {
        aTag("\(Self.self)", to: self.url)
    }
}
