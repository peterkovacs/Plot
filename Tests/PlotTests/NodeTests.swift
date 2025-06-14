/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Testing
import Plot

@Suite("Node") struct NodeTests {
    @Test func testEscapingText() {
        let node = Node<Any>.text("Hello & welcome to <Plot>!;")
        #expect(node.render() == "Hello &amp; welcome to &lt;Plot&gt;!;")
    }

    @Test func testEscapingDoubleAmpersands() {
        let node = Node<Any>.text("&&")
        #expect(node.render() == "&amp;&amp;")
    }

    @Test func testEscapingAmpersandFollowedByComparisonSymbols() {
        let node = Node<Any>.text("&< &>")
        #expect(node.render() == "&amp;&lt; &amp;&gt;")
    }

    @Test func testNotDoubleEscapingText() {
        let node = Node<Any>.text("Hello &amp; welcome&#160;to &lt;Plot&gt;!&text")
        #expect(node.render() == "Hello &amp; welcome&#160;to &lt;Plot&gt;!&amp;text")
    }

    @Test func testNotEscapingRawString() {
        let node = Node<Any>.raw("Hello & welcome to <Plot>!")
        #expect(node.render() == "Hello & welcome to <Plot>!")
    }

    @Test func testGroup() {
        let node = Node<Any>.group(.text("Hello"), .text("World"))
        #expect(node.render() == "HelloWorld")
    }

    @Test func testCustomElement() {
        let node = Node<Any>.element(named: "custom")
        #expect(node.render() == "<custom></custom>")
    }

    @Test func testCustomAttribute() {
        let node = Node<Any>.attribute(named: "key", value: "value")
        #expect(node.render() == #"key="value""#)
    }

    @Test func testCustomElementWithCustomAttribute() {
        let node = Node<Any>.element(named: "custom", attributes: [
            Attribute(name: "key", value: "value")
        ])

        #expect(node.render() == #"<custom key="value"></custom>"#)
    }

    @Test func testCustomElementWithCustomAttributeWithSpecificContext() {
        let node = Node<Any>.element(named: "custom", attributes: [
            Attribute<String>(name: "key", value: "value")
        ])

        #expect(node.render() == #"<custom key="value"></custom>"#)
    }

    @Test func testCustomSelfClosedElementWithCustomAttribute() {
        let node = Node<Any>.selfClosedElement(named: "custom", attributes: [
            Attribute(name: "key", value: "value")
        ])

        #expect(node.render() == #"<custom key="value"/>"#)
    }

    @Test func testComponents() {
        let node = Node<Any>.components {
            Paragraph("One")
            Paragraph("Two")
        }

        #expect(node.render() == "<p>One</p><p>Two</p>")
    }

    @Test func testNodeComponentBodyIsEqualToSelf() {
        let node = Node.p("Text")
        #expect(node.render() == node.body.render())
    }
}
