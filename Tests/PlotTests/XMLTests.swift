/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Testing
import Plot
import Foundation

@Suite("XML") struct XMLTests {
    @Test func testEmptyXML() {
        assertEqualXMLContent(XML(), "")
    }

    @Test func testSingleElement() {
        let xml = XML(.element(named: "hello", text: "world!"))
        assertEqualXMLContent(xml, "<hello>world!</hello>")
    }

    @Test func testSelfClosingElement() {
        let xml = XML(.selfClosedElement(named: "element"))
        assertEqualXMLContent(xml, "<element/>")
    }

    @Test func testElementWithAttribute() {
        let xml = XML(.element(
            named: "element",
            nodes: [
                .attribute(named: "attribute", value: "value")
            ]
        ))

        assertEqualXMLContent(xml, #"<element attribute="value"></element>"#)
    }

    @Test func testElementWithChildren() {
        let xml = XML(
            .element(named: "parent", nodes: [
                .selfClosedElement(named: "a"),
                .selfClosedElement(named: "b")
            ])
        )

        assertEqualXMLContent(xml, "<parent><a/><b/></parent>")
    }
}
