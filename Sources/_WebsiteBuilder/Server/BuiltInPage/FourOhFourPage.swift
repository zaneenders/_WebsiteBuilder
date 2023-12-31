// TODO make a protocol for user to override
struct FourOhFourPage: WebPage {
    var contents: String {
        h2("Not the Type, I mean page you are looking for.")
    }
}
