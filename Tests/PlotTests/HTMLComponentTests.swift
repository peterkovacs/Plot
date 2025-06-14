/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Testing
import Plot

@Suite("HTMLComponent") struct HTMLComponentTests {
    @Test func testControlFlow() {
        let string: String? = "String"
        let nilString: String? = nil
        let bool = true
        let int = 3

        let html = Div {
            if let string = string {
                Paragraph(string)
            }

            if let string = nilString {
                Paragraph("Should not be rendered: \(string)")
            }

            if let string = nilString {
                Paragraph("Should not be rendered: \(string)")
            } else {
                Paragraph("Nil")
            }

            string.map { Paragraph($0) }
            nilString.map { Paragraph($0) }

            for string in ["One", "Two"] {
                Paragraph(string)
            }

            if bool {
                Paragraph("True")
            }

            switch int {
            case 3:
                Paragraph("Switch")
            default:
                Paragraph("Should not be rendered")
            }
        }
        .render()

        #expect(html == """
        <div><p>String</p><p>Nil</p><p>String</p><p>One</p><p>Two</p><p>True</p><p>Switch</p></div>
        """)
    }

    @Test func testNodeInteroperability() {
        let html = Div {
            Node.p("One")
            Node<Any>.component(Paragraph("Two"))
            Paragraph("Three")
        }
        .render()

        #expect(html == "<div><p>One</p><p>Two</p><p>Three</p></div>")
    }

    @Test func testIDAndClassModifiers() {
        let html = Link("Swift by Sundell",
            url: "https://swiftbysundell.com"
        )
        .id("sxs-link")
        .class("link")
        .render()

        #expect(html == """
        <a href="https://swiftbysundell.com" id="sxs-link" class="link">Swift by Sundell</a>
        """)
    }

    @Test func testAssigningDirectionalityToElement() {
        let html = Paragraph("Hello")
            .directionality(.leftToRight)
            .render()

        #expect(html == #"<p dir="ltr">Hello</p>"#)
    }

    @Test func testAppendingClasses() {
        let html = Paragraph("Hello")
            .class("one")
            .class("two")
            .class("three")
            .render()

        #expect(html == #"<p class="one two three">Hello</p>"#)
    }

    @Test func testNotAppendingEmptyClasses() {
        let html = Paragraph("Hello")
            .class("")
            .class("one")
            .class("")
            .class("two")
            .render()

        #expect(html == #"<p class="one two">Hello</p>"#)
    }

    @Test func testAppendingClassesToWrappingComponents() {
        struct InnerWrapper: Component {
            var body: Component {
                Paragraph("Hello").class("one")
            }
        }

        struct OuterWrapper: Component {
            var body: Component {
                InnerWrapper().class("two")
            }
        }

        let html = OuterWrapper().class("three").render()
        #expect(html == #"<p class="one two three">Hello</p>"#)
    }

    @Test func testAppendingClassToWrappingComponentContainingGroup() {
        struct Wrapper: Component {
            var body: Component {
                ComponentGroup {
                    Paragraph("One")
                    Paragraph("Two")
                }
                .class("one")
            }
        }

        let html = Wrapper().class("two").render()
        #expect(html == #"<p class="one two">One</p><p class="one two">Two</p>"#)
    }

    @Test func testReplacingClass() {
        let html = Paragraph("Hello")
            .class("one")
            .class("two")
            .class("three", replaceExisting: true)
            .render()

        #expect(html == #"<p class="three">Hello</p>"#)
    }

    @Test func testAddingClassToMultipleComponents() {
        let html = ComponentGroup {
            Div()
            Div()
        }
        .class("hello")
        .render()

        #expect(html == #"<div class="hello"></div><div class="hello"></div>"#)
    }

    @Test func testAddingClassToNode() {
        let html = Node.div(.p()).class("hello").render()
        #expect(html == #"<div class="hello"><p></p></div>"#)
    }

    @Test func testEnvironmentValuesDoNotApplyToSiblings() {
        let html = Div {
            Link("One", url: "/one")
                .linkTarget(.blank)
            Link("Two", url: "/two")
                .linkRelationship(.nofollow)
            Link("Three", url: "/three")
        }
        .render()

        #expect(html == """
        <div>\
        <a href="/one" target="_blank">One</a>\
        <a href="/two" rel="nofollow">Two</a>\
        <a href="/three">Three</a>\
        </div>
        """)
    }

    @Test func testApplyingEnvironmentValuesToTopLevelHTML() {
        let html = HTML(
            .body {
                Link("One", url: "/one")
                Link("Two", url: "/two")
            }
        )
        .environmentValue(.nofollow, key: .linkRelationship)

        assertEqualHTMLContent(html, """
        <body>\
        <a href="/one" rel="nofollow">One</a>\
        <a href="/two" rel="nofollow">Two</a>\
        </body>
        """)
    }

    @Test func testUsingCustomEnvironmentKey() {
        struct TestComponent: Component {
            @EnvironmentValue(.init(identifier: "key")) var value: String?

            var body: Component {
                Paragraph(value ?? "No value")
            }
        }

        let html = TestComponent()
            .environmentValue("Value", key: .init(identifier: "key"))
            .render()

        #expect(html == "<p>Value</p>")
    }

    @Test func testApplyingTextStyles() {
        let html = Div {
            Text("Bold")
                .bold()
                .addLineBreak()
            Text("Italic")
                .italic()
                .addLineBreak()
            Text("Underlined")
                .underlined()
                .addLineBreak()
            Text("Strikethrough")
                .strikethrough()
                .addLineBreak()
        }
        .render()

        #expect(html == """
        <div>\
        <b>Bold</b><br/>\
        <em>Italic</em><br/>\
        <u>Underlined</u><br/>\
        <s>Strikethrough</s><br/>\
        </div>
        """)
    }

    @Test func testTextConcatenation() {
        let text = Text("One") + Text(" ") + Text("Two").bold()
        #expect(text.render() == "One <b>Two</b>")
    }

    @Test func testApplyingAccessibilityLabel() {
        let html = Paragraph("Text")
            .accessibilityLabel("Label")
            .render()

        #expect(html == #"<p aria-label="Label">Text</p>"#)
    }

    @Test func testApplyingDataAttribute() {
        let html = Paragraph("Text")
            .data(named: "test", value: "value")
            .render()

        #expect(html == #"<p data-test="value">Text</p>"#)
    }

    @Test func testApplyingStyleAttribute() {
        let html = Paragraph("Text")
            .style("color: #000;")
            .render()

        #expect(html == #"<p style="color: #000;">Text</p>"#)
    }

    @Test func testElementBasedComponents() {
        let html = HTML {
            Article("Article")
            Button("Button")
            Details("Details")
            Div("Div")
            FieldSet("FieldSet")
            Footer("Footer")
            H1("H1")
            H2("H2")
            H3("H3")
            H4("H4")
            H5("H5")
            H6("H6")
            Header("Header")
            ListItem("ListItem")
            Main("Main")
            Navigation("Navigation")
            Paragraph("Paragraph")
            Span("Span")
            Summary("Summary")
            TableCaption("TableCaption")
            TableCell("TableCell")
            TableHeaderCell("TableHeaderCell")
        }

        assertEqualHTMLContent(html, """
        <body>\
        <article>Article</article>\
        <button>Button</button>\
        <details>Details</details>\
        <div>Div</div>\
        <fieldset>FieldSet</fieldset>\
        <footer>Footer</footer>\
        <h1>H1</h1>\
        <h2>H2</h2>\
        <h3>H3</h3>\
        <h4>H4</h4>\
        <h5>H5</h5>\
        <h6>H6</h6>\
        <header>Header</header>\
        <li>ListItem</li>\
        <main>Main</main>\
        <nav>Navigation</nav>\
        <p>Paragraph</p>\
        <span>Span</span>\
        <summary>Summary</summary>\
        <caption>TableCaption</caption>\
        <td>TableCell</td>\
        <th>TableHeaderCell</th>\
        </body>
        """)
    }

    @Test func testAudioPlayer() {
        let html = HTML {
            AudioPlayer(source: .mp3(at: "a.mp3"), showControls: false)
            AudioPlayer(source: .wav(at: "b.wav"), showControls: true)
            AudioPlayer(source: .ogg(at: "c.ogg"), showControls: false)
        }

        assertEqualHTMLContent(html, """
        <body>\
        <audio><source type="audio/mpeg" src="a.mp3"/></audio>\
        <audio controls><source type="audio/wav" src="b.wav"/></audio>\
        <audio><source type="audio/ogg" src="c.ogg"/></audio>\
        </body>
        """)
    }

    @Test func testForm() {
        let html = Form(
            url: "url.com",
            method: .post,
            content: {
                FieldSet {
                    Label("Username") {
                        TextField(name: "username", isRequired: true)
                            .autoFocused()
                            .autoComplete(false)
                    }
                    Label("Password") {
                        Input(
                            type: .password,
                            name: "password"
                        )
                        .class("password-input")
                    }
                    .class("password-label")
                }
                TextArea(
                    text: "Enter a description",
                    name: "description",
                    numberOfRows: 3,
                    numberOfColumns: 2
                )
                SubmitButton("Submit")
            }
        )
        .render()

        #expect(html == """
        <form action="url.com" method="post">\
        <fieldset>\
        <label>Username\
        <input type="text" name="username" required autofocus autocomplete="off"/>\
        </label>\
        <label class="password-label">Password\
        <input type="password" name="password" class="password-input"/>\
        </label>\
        </fieldset>\
        <textarea name="description" rows="3" cols="2">Enter a description</textarea>\
        <input type="submit" value="Submit"/>\
        </form>
        """)
    }

    @Test func testIFrame() {
        let html = IFrame(
            url: "url.com",
            addBorder: false,
            allowFullScreen: true,
            enabledFeatureNames: ["gyroscope"]
        )
        .render()

        #expect(html == """
        <iframe src="url.com" frameborder="0" allowfullscreen allow="gyroscope"></iframe>
        """)
    }

    @Test func testImageWithDescription() {
        let html = Image(url: "image.png", description: "My image").render()
        #expect(html == #"<img src="image.png" alt="My image"/>"#)
    }

    @Test func testImageWithoutDescription() {
        let html = Image("image.png").render()
        #expect(html == #"<img src="image.png"/>"#)
    }

    @Test func testLinkRelationshipAndTarget() {
        let html = Div {
            Link("First", url: "/first")
            Link("Second", url: "/second")
                .linkRelationship(.noreferrer)
                .linkTarget(nil)
        }
        .linkRelationship(.nofollow)
        .linkTarget(.blank)
        .render()

        #expect(html == """
        <div>\
        <a href="/first" rel="nofollow" target="_blank">First</a>\
        <a href="/second" rel="noreferrer">Second</a>\
        </div>
        """)
    }

    @Test func testOrderedList() {
        let html = List(["One", "Two"])
            .listStyle(.ordered)
            .render()

        #expect(html == "<ol><li>One</li><li>Two</li></ol>")
    }
    
    @Test func testTime() {
        let html = Time(datetime: "2011-11-18T14:54:39Z") {
            Paragraph("Hello World")
        }
        .render()
        
        #expect(html == #"<time datetime="2011-11-18T14:54:39Z"><p>Hello World</p></time>"#)
    }

    @Test func testOrderedListWithExplicitItems() {
        struct SeventhComponent: Component {
            var body: Component { ListItem("Seven") }
        }

        let bool = true

        let html = List {
            ListItem("One").number(1)
            Text("Two")

            if bool {
                Paragraph("Three").class("three")
            }

            ListItem("Four").class("four")

            for string in ["Five", "Six"] {
                ListItem(string)
            }

            SeventhComponent()

            Node.li("Eight")

            Node.group(
                .li("Nine"),
                .li("Ten", .class("ten"))
            )
        }
        .listStyle(.ordered)
        .render()

        #expect(html == """
        <ol>\
        <li value="1">One</li>\
        <li>Two</li>\
        <li><p class="three">Three</p></li>\
        <li class="four">Four</li>\
        <li>Five</li>\
        <li>Six</li>\
        <li>Seven</li>\
        <li>Eight</li>\
        <li>Nine</li>\
        <li class="ten">Ten</li>\
        </ol>
        """)
    }

    @Test func testOrderedListWithEmptyComponent() {
        let html = List {
            Text("Hello")
            EmptyComponent()
        }
        .listStyle(.ordered)
        .render()

        #expect(html == "<ol><li>Hello</li></ol>")
    }

    @Test func testUnorderedList() {
        let html = List(["One", "Two"]).render()
        #expect(html == "<ul><li>One</li><li>Two</li></ul>")
    }

    @Test func testUnorderedListWithCustomItemClass() {
        let html = List([1, 2]) { number in
            Paragraph(String(number))
        }
        .listStyle(.unordered.withItemClass("item"))
        .render()

        #expect(html == """
        <ul>\
        <li class="item"><p>1</p></li>\
        <li class="item"><p>2</p></li>\
        </ul>
        """)
    }

    @Test func testUngroupedTable() {
        let html = Table {
            Text("Row one")
            TableRow {
                TableCell("Row two, cell one")
                TableCell("Row two, cell two")
            }

            ComponentGroup {
                TableRow {
                    Text("Row three, cell one")
                    Text("Row three, cell two")
                }
                TableCell("Row four")
            }
        }
        .render()

        #expect(html == """
        <table>\
        <tr><td>Row one</td></tr>\
        <tr><td>Row two, cell one</td><td>Row two, cell two</td></tr>\
        <tr><td>Row three, cell one</td><td>Row three, cell two</td></tr>\
        <tr><td>Row four</td></tr>\
        </table>
        """)
    }

    @Test func testGroupedTable() {
        let html = Table(
            caption: TableCaption("Caption"),
            header: TableRow { Text("Header") },
            footer: TableRow { Text("Footer") },
            rows: {
                Text("Row one")
                TableRow {
                    TableCell("Row two, cell one")
                    TableCell("Row two, cell two")
                }

                ComponentGroup {
                    TableRow {
                        Text("Row three, cell one")
                        Text("Row three, cell two")
                    }
                    TableCell("Row four")
                }
            }
        )
        .render()

        #expect(html == """
        <table>\
        <caption>Caption</caption>\
        <thead><tr><th>Header</th></tr></thead>\
        <tbody>\
        <tr><td>Row one</td></tr>\
        <tr><td>Row two, cell one</td><td>Row two, cell two</td></tr>\
        <tr><td>Row three, cell one</td><td>Row three, cell two</td></tr>\
        <tr><td>Row four</td></tr>\
        </tbody>\
        <tfoot><tr><td>Footer</td></tr></tfoot>\
        </table>
        """)
    }
}
