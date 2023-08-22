import HTMLBuilder
import WebServer

@main
struct SampleWebsite: WebsiteProtocol {
    var name: String = "sample-website"
    var pages: [Page] {
        Page(
            "index",
            HTML(Head(title: "Zane was here", js: false)) {
                Body {
                    Heading(.one, "Zane was here")
                        .style(background: .yellow)
                    Heading(.three, "Welcome to my website")
                        .style(foreground: .hex("696969"))
                    Paragraph("I don't like the color red")
                        .style(foreground: .hex("ffffff"))
                        .style(background: .red)
                }
            }
        )
    }
}
