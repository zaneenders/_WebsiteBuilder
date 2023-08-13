import HTMLBuilder
import WebServer

@main
struct Test: WebsiteProtocol {
    var name: String = "sample-website"
    var pages: [Page] {
        Page(
            "index",
            HTML(Head(js: false)) {
                Body {
                    Heading(.one, "Zane Enders")
                        .style(background: .yellow)
                    Heading(.three, "Welcome to my website")
                        .style(foreground: .hex("696969"))
                    Paragraph("I don't like the color red")
                        .style(foreground: .hex("ffffff"))
                        .style(background: .red)
                    Paragraph("Zane Was here ->")
                        .style(foreground: .yellow)
                        .style(background: .blue)
                }
            }
        )
    }
}
