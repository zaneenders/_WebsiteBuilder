struct RobotsTxt: HasContent, HasURL {

    static let url: String = "/robots.txt"

    var contents: String =
        """
        User-agent: *
        Disallow: /
        """
}
