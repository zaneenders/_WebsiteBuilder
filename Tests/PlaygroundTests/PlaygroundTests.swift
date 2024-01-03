import XCTest

@testable import WebsiteBuilder

final class PlaygroundTests: XCTestCase {

    func testHomePage() async throws {
        struct H: RootPage {
            var contents: String {
                "Home"
            }

            var subPages: [WebPage.Type] {
                D.self
                P.self
            }
        }

        struct P: WebPage {
            var contents: String {
                D.url
            }

            var subPages: [WebPage.Type] {
                J.self
            }
        }

        struct D: WebPage {
            var contents: String {
                P.url
            }

            var subPages: [WebPage.Type] {
                K.self
            }
        }

        struct J: WebPage {
            var contents: String {
                links()
            }
        }

        struct K: WebPage {
            var contents: String {
                links()
            }

            var subPages: [WebPage.Type] {
                V.self
            }
        }

        struct V: WebPage {
            var contents: String {
                "V"
            }
        }

        struct W: WebSite {
            var root: RootPage = H()
        }

        func links() -> String {
            H.url + P.url + D.url + J.url + K.url
        }

        W.setup()
        XCTAssertEqual(H.url, "/")
        XCTAssertEqual(P.url, "/P")
        XCTAssertEqual(D.url, "/D")
        XCTAssertEqual(K.url, "/D/K")
        XCTAssertEqual(J.url, "/P/J")
        XCTAssertEqual(V.url, "/D/K/V")
        XCTAssertEqual(Routes.routes.count, 6)
        XCTAssertEqual(Routes.pages[H.url]!.contents, "Home")
        XCTAssertEqual(Routes.pages[P.url]!.contents, "/D")
        XCTAssertEqual(Routes.pages[D.url]!.contents, "/P")
        XCTAssertEqual(Routes.pages[K.url]!.contents, links())
        XCTAssertEqual(Routes.pages[J.url]!.contents, links())
        XCTAssertEqual(Routes.pages[V.url]!.contents, "V")
    }
}
