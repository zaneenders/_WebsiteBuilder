import HTMLBuilder
import WebServer

let log =
    "<script type=\"text/javascript\" charset=\"utf-8\">console.log(\"hello from type hole\")</script>"

@main
struct SampleWebsite: WebsiteProtocol {
    var name: String = "sample-website"
    var pages: [Page] {
        Page(
            "index",
            HTML(Head(title: "Zane was here", js: false).rawJSString(log)) {
                Body {
                    Heading(.one, "Zane was here")
                        .style(background: .yellow)
                    Heading(.three, "Welcome to my website")
                        .style(foreground: .hex("696969"))
                    Paragraph("I don't like the color red")
                        .style(foreground: .hex("ffffff"))
                        .style(background: .red)
                    Paragraph("Math here \(Latex("e^{i\\pi} + 1 = 0"))")
                    RawHTML(
                        "<details><summary>Summary Here</summary>Other Here</details>"
                    )
                }
            }
        )
    }
}
