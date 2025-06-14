/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Testing
import Plot

@Suite("Document") struct DocumentTests {
    @Test func testEmptyDocument() {
        let document = Document<FormatStub>.custom()
        #expect(document.render() == "")
    }

    @Test func testEmptyIndentedDocument() {
        let document = Document<FormatStub>.custom()
        #expect(document.render(indentedBy: .spaces(4)) == "")
    }

    @Test func testIndentationWithSpaces() {
        let document = Document.custom(
            withFormat: FormatStub.self,
            elements: [
                .named("one", nodes: [
                    .element(named: "two", nodes: [
                        .selfClosedElement(named: "three")
                    ]),
                    .text("four "),
                    .component(Text("five")),
                    .component(Element.named("six", nodes: [
                        .text("seven")
                    ])),
                    .element(named: "eight", nodes: [
                        .text("nine")
                    ])
                ]),
                .selfClosed(named: "ten", attributes: [
                    Attribute(name: "key", value: "value")
                ])
            ]
        )

        #expect(document.render(indentedBy: .spaces(4)) == """
        <one>
            <two>
                <three/>
            </two>four five
            <six>seven</six>
            <eight>nine</eight>
        </one>
        <ten key="value"/>
        """)
    }

    @Test func testIndentationWithTabs() {
        let document = Document.custom(
            withFormat: FormatStub.self,
            elements: [
                .named("one", nodes: [
                    .element(named: "two", nodes: [
                        .selfClosedElement(named: "three")
                    ]),
                    .element(named: "four")
                ]),
                .selfClosed(named: "five", attributes: [
                    Attribute(name: "key", value: "value")
                ])
            ]
        )

        #expect(document.render(indentedBy: .tabs(1)) == """
        <one>
        \t<two>
        \t\t<three/>
        \t</two>
        \t<four></four>
        </one>
        <five key="value"/>
        """)
    }
}

private extension DocumentTests {
    struct FormatStub: DocumentFormat {
        enum RootContext {}
    }
}
