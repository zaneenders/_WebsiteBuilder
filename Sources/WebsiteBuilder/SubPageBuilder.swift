@resultBuilder
public enum SubPageBuilder {
    public static func buildBlock(_ components: any WebPage.Type...)
        -> [any WebPage.Type]
    {
        return components
    }
}
