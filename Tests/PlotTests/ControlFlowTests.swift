/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Testing
import Plot

@Suite("Control Flow")
struct ControlFlowTests {
    @Test func testIfCondition() {
        #expect(Node<Any>.if(true, .text("True")).render() == "True")
        #expect(Node<Any>.if(false, .text("True")).render() == "")
    }

    @Test func testIfElseCondition() {
        #expect(
            Node<Any>.if(true, .text("If"), else: .text("Else")).render() == "If"
        )

        #expect(
            Node<Any>.if(false, .text("If"), else: .text("Else")).render() == "Else"
        )
    }

    @Test func testUnwrappingOptional() {
        var optional: String? = "Hello"
        #expect(Node<Any>.unwrap(optional, Node.text).render() == "Hello")

        optional = nil
        #expect(Node<Any>.unwrap(optional, Node.text).render() == "")
        #expect(Node<Any>.unwrap(optional, Node.text, else: .text("Is nil") ).render() == "Is nil")
    }

    @Test func testForEach() {
        let array = ["A", "B", "C"]
        #expect(Node<Any>.forEach(array, Node.text).render() == "ABC")
        #expect(Node<Any>.forEach([], Node.text).render() == "")
    }
}
