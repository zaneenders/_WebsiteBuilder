public func seoURL(_ str: String) -> String {
    let copy = str.replacing(" ", with: "-")
    return copy.lowercased()
}
