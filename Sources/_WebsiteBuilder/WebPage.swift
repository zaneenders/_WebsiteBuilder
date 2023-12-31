public protocol WebPage: HasURL, HasContent, HasSubPages {
    var contents: String { get }
    init()  // Thing I will want to change this.
    // So that things can be composed and you pass in one initialized tree
}

extension WebPage {
    public static var url: String {
        if let u = Routes.routes["\(Self.self)"] {
            return u
        } else {
            print("Page:[\(Self.self)] not registered unable to link")
            print(
                "Make sure \(Self.self) is added to the proper subPages array.")
            return "/404"
        }
    }

    public static var link: HTMLString {
        makeLink(self)
    }

    public static var linkInNewTab: HTMLString {
        aTag("\(Self.self)", to: self.url)
    }
}
