/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Testing
import Plot

func assertEqualHTMLContent(
    _ document: HTML,
    _ content: String,
    fileId: String = #fileID,
    file: String = #filePath,
    line: Int = #line,
    column: Int = #column
) {
    let html = document.render()
    let expectedPrefix = "<!DOCTYPE html><html>"
    let expectedSuffix = "</html>"

    #expect(
        html.hasPrefix(expectedPrefix),
        """
        Invalid HTML prefix.
        Expected '\(expectedPrefix)'.
        Found '\(html.prefix(expectedPrefix.count))'.
        """,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )

    #expect(
        html.hasSuffix(expectedSuffix),
        """
        Invalid HTML suffix.
        Expected '\(expectedSuffix)'.
        Found '\(html.suffix(expectedSuffix.count))'.
        """,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )

    let expectedContent = html
        .dropFirst(expectedPrefix.count)
        .dropLast(expectedSuffix.count)

    #expect(
        String(expectedContent) == content,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )
}

func assertEqualSiteMapContent(
    _ document: SiteMap,
    _ content: String,
    fileId: String = #fileID,
    file: String = #filePath,
    line: Int = #line,
    column: Int = #column
) {
    let map = document.render()

    let expectedPrefix = XML().render() + """
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" \
    xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
    """

    let expectedSuffix = "</urlset>"

    #expect(
        map.hasPrefix(expectedPrefix),
        """
        Invalid SiteMap prefix.
        Expected '\(expectedPrefix)'.
        Found '\(map.prefix(expectedPrefix.count))'.
        """,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )

    #expect(
        map.hasSuffix(expectedSuffix),
        """
        Invalid SiteMap suffix.
        Expected '\(expectedSuffix)'.
        Found '\(map.suffix(expectedSuffix.count))'.
        """,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )

    let expectedContent = map
        .dropFirst(expectedPrefix.count)
        .dropLast(expectedSuffix.count)

    #expect(
        String(expectedContent) == content,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )
}

func assertEqualXMLContent(
    _ document: XML,
    _ content: String,
    fileId: String = #fileID,
    file: String = #filePath,
    line: Int = #line,
    column: Int = #column
) {
    let xml = document.render()
    let declaration = #"<?xml version="1.0" encoding="UTF-8"?>"#

    #expect(
        xml.hasPrefix(declaration),
        """
        Invalid XML declaration.
        Expected '\(declaration)'.
        Found '\(xml.prefix(declaration.count))'.
        """,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )

    #expect(
        String(xml.dropFirst(declaration.count)) == content,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )
}

func assertEqualPodcastFeedContent(
    _ feed: PodcastFeed,
    _ content: String,
    fileId: String = #fileID,
    file: String = #filePath,
    line: Int = #line,
    column: Int = #column
) {
    assertEqualRSSFeedContent(
        feed,
        content,
        type: "podcast",
        namespaces: [
            ("atom", "http://www.w3.org/2005/Atom"),
            ("content", "http://purl.org/rss/1.0/modules/content/"),
            ("itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd"),
            ("media", "http://www.rssboard.org/media-rss")
        ],
        fileId: fileId,
        file: file,
        line: line,
        column: column
    )
}

func assertEqualRSSFeedContent(
    _ feed: RSS,
    _ content: String,
    fileId: String = #fileID,
    file: String = #filePath,
    line: Int = #line,
    column: Int = #column
) {
    assertEqualRSSFeedContent(
        feed,
        content,
        type: "RSS",
        namespaces: [
            ("atom", "http://www.w3.org/2005/Atom"),
            ("content", "http://purl.org/rss/1.0/modules/content/")
        ],
        fileId: fileId,
        file: file,
        line: line,
        column: column
    )
}

private func assertEqualRSSFeedContent<R: Renderable>(
    _ feed: R,
    _ content: String,
    type: String,
    namespaces: [(name: String, url: String)],
    fileId: String,
    file: String,
    line: Int,
    column: Int
) {
    let xmlDeclaration = XML().render()

    let namespaces = namespaces.map({ name, url in
        "xmlns:\(name)=\"\(url)\""
    }).joined(separator: " ")

    let expectedPrefix = "\(xmlDeclaration)<rss version=\"2.0\" \(namespaces)><channel>"
    let expectedSuffix = "</channel></rss>"

    let xml = feed.render()

    #expect(
        xml.hasPrefix(expectedPrefix),
        """
        Invalid \(type) feed prefix.
        Expected '\(expectedPrefix)'.
        Found '\(xml.prefix(expectedPrefix.count))'.
        """,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )

    #expect(
        xml.hasSuffix(expectedSuffix),
        """
        \(type.capitalized) feed is not closed with '\(expectedSuffix)'.
        Feed: '\(xml)'
        """,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )

    let expectedContent = xml
        .dropFirst(expectedPrefix.count)
        .dropLast(expectedSuffix.count)

    #expect(
        String(expectedContent) == content,
        sourceLocation: .init(fileID: fileId, filePath: file, line: line, column: column)
    )
}
