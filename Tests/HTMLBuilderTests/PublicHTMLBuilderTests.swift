import HTMLBuilder
import XCTest

final class PublicHTMLBuilderTests: XCTestCase {

    func testColorStyle() throws {
        let p = Paragraph {
            "zane"
        }.style(foreground: .blue)

        XCTAssertEqual("<p style=\"color:blue;\">zane</p>", p.html)
    }

    func testPage() throws {
        let lorem = """
            Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit
            """

        let page = HTML(Head(title: "Hello World", js: false)) {
            Body {
                Paragraph("hello")
                Paragraph("world")
                Paragraph {
                    lorem
                }
            }
        }

        let output = """
            <body><p>hello</p><p>world</p><p>\(lorem)</p></body>
            """

        XCTAssertEqual(output, page.description)
    }
}
