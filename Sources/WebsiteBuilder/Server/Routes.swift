typealias RouteString = String
enum Routes {
    private(set) static var pages: [RouteString: any HasContent] = [:]
    private(set) static var routes: [String: RouteString] = [:]

    // TODO make urls and links lowercase
    static func indexHome(_ copy: any RootPage) {
        let url = "/"
        Routes.pages[url] = copy
        Routes.routes["\(copy.self)"] = url
        for p in copy.subPages {
            let name = "\(p.self)"
            let page = p.init()
            if let r = Routes.routes[name] {
                print("\(name) already has a route \(r) ignoring")
            } else {
                let pageUrl = url + "\(name)"
                Routes.routes[name] = pageUrl
                Routes.pages[pageUrl] = page
            }
        }
        for p in copy.subPages {
            indexSubPages(s: p)
        }
    }

    private static func indexSubPages(s: any WebPage.Type) {
        let cur = s.init()
        if let ourRoute = Routes.routes["\(s.self)"] {
            for p in cur.subPages {
                let name = "\(p.self)"
                let page = p.init()
                if let r = Routes.routes[name] {
                    print("\(name) already has a route \(r) ignoring")
                } else {
                    let pageUrl = ourRoute + "/\(name)"
                    Routes.routes[name] = pageUrl
                    Routes.pages[pageUrl] = page
                }
            }
            for p in cur.subPages {
                indexSubPages(s: p)
            }
        } else {
            print(
                "\("\(s.self)") must have a route in order to have sub routes")
        }
    }
}
