public typealias HTMLString = String

public func h1(_ str: String, _ properties: PropertiesString = "") -> HTMLString
{
    " <h1 \(properties)>\(str)</h1> "
}
public func h2(_ str: String, _ properties: PropertiesString = "") -> HTMLString
{
    " <h2 \(properties)>\(str)</h2> "
}
public func h3(_ str: String, _ properties: PropertiesString = "") -> HTMLString
{
    " <h3 \(properties)>\(str)</h3> "
}
public func h4(_ str: String, _ properties: PropertiesString = "") -> HTMLString
{
    " <h4 \(properties)>\(str)</h4> "
}

public func imgTag(_ src: String, _ alt: String? = nil) -> String {
    "<img src=\"\(src)\" \(alt != nil ? "alt=\"\(alt!)\"" : "")>"
}

// TODO style this better
public func _strikethroughTag(
    _ str: String, _ properties: PropertiesString = ""
)
    -> HTMLString
{
    " <s \(properties)>\(str)</s> "
}

// TODO move to this
enum _HTML {

}

public func head(_ title: String, _ js: String? = nil) -> HTMLString {
    """
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" type="image/x-icon" href="/favicon.ico">
        <title>\(title)</title>\(js != nil ? "\n"+js! : "")
    </head>
    """
}

public func html(
    _ js: Bool = true, _ head: String, @BodyBuilder components: () -> HTMLString
) -> HTMLString {
    return """
        <!DOCTYPE html>
        <html lang="en">
        \(js ? """
            <script>console.log("I don't like Javascript or Web Development - Zane")</script>
            <script>
                MathJax = {
                    tex: {
                        inlineMath: [['$', '$']]
                    },
                    svg: {
                        fontCache: 'global'
                    }
                }
            </script>
            <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
            </script>
            """ : "")
        \(head.description)
        \(components())
        </html>
        """
}

public typealias StyleString = String

// TODO how should I handle styling
public enum Properties {
    public static func styles(_ str: StyleString) -> HTMLString {
        " style=\"\(str) \" "
    }
}

public typealias PropertiesString = String

public func newTabLink(
    _ text: String, to: String, _ properties: PropertiesString = ""
)
    -> HTMLString
{
    """
     <a href="\(to)" \(properties) target="_blank"> \(text)</a> 
    """
}

public func aTag(
    _ text: String, to: String, _ properties: PropertiesString = ""
)
    -> HTMLString
{
    " <a href=\(to) \(properties)> \(text)</a> "
}

public func pTag(_ text: String, _ properties: PropertiesString = "")
    -> HTMLString
{
    " <p \(properties)>\(text)</p> "
}

public func js(_ js: String) -> HTMLString {
    " <script> \(js) </script> "
}

/*
- Note putting list in p tags is invalid, and the browser changes it
*/
public func div(@DivBuilder components: () -> String) -> HTMLString {
    components()
}

public func paragraphs(@ParagraphBuilder components: () -> String) -> HTMLString
{
    components()
}

public func orderedList(@OrderedListBuilder components: () -> String)
    -> HTMLString
{
    components()
}

public func unorderedList(@UnorderedListBuilder components: () -> String)
    -> HTMLString
{
    components()
}

public func body(@BodyBuilder components: () -> String) -> HTMLString {
    components()
}

public func spacer() -> String {
    "<br>"
}

@resultBuilder
public enum DivBuilder {  // lol
    public static func buildBlock(_ components: any PageComponent...)
        -> HTMLString
    {
        var output = " <div> "
        for c in components {
            output += c.contents
        }
        return output + " </div> "
    }
}

@resultBuilder
public enum BodyBuilder {  // lol
    public static func buildBlock(_ components: any PageComponent...)
        -> HTMLString
    {
        #warning("This is a hack well I figure out Styling")
        var output = " <body style=\"text-align:center;\"> "
        for c in components {
            output += c.contents
        }
        return output + " </body> "
    }
}

@resultBuilder
public enum ParagraphBuilder {
    public static func buildBlock(_ components: any PageComponent...)
        -> HTMLString
    {
        var output = ""
        for p in components {
            output += pTag(p.contents)
        }
        return output
    }
}

@resultBuilder
public enum OrderedListBuilder {
    public static func buildBlock(_ components: any PageComponent...)
        -> HTMLString
    {
        var output = " <ol> "
        for p in components {
            output += " <li> " + p.contents + " </li> "
        }
        return output + " </ol> "
    }
}

@resultBuilder
public enum UnorderedListBuilder {
    public static func buildBlock(_ components: any PageComponent...)
        -> HTMLString
    {
        var output = " <ul> "
        for p in components {
            output += " <li> " + p.contents + " </li> "
        }
        return output + " </ul> "
    }
}
