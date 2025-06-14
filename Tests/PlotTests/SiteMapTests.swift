/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Testing
import Plot
import Foundation

@Suite("SiteMap") struct SiteMapTests {
    @Test func testEmptyMap() {
        let map = SiteMap()
        assertEqualSiteMapContent(map, "")
    }

    @Test func testDailyUpdatedLocation() throws {
        let dateStubs = try Date.makeStubs(withFormattingStyle: .siteMap)

        let map = SiteMap(.url(
            .loc("url.com"),
            .changefreq(.daily),
            .priority(1.0),
            .lastmod(dateStubs.date, timeZone: dateStubs.timeZone)
        ))

        assertEqualSiteMapContent(map, """
        <url>\
        <loc>url.com</loc>\
        <changefreq>daily</changefreq>\
        <priority>1.0</priority>\
        <lastmod>\(dateStubs.expectedString)</lastmod>\
        </url>
        """)
    }

    @Test func testMonthlyUpdatedLocation() throws {
        let dateStubs = try Date.makeStubs(withFormattingStyle: .siteMap)

        let map = SiteMap(.url(
            .loc("url.com"),
            .changefreq(.monthly),
            .priority(1.0),
            .lastmod(dateStubs.date, timeZone: dateStubs.timeZone)
        ))

        assertEqualSiteMapContent(map, """
        <url>\
        <loc>url.com</loc>\
        <changefreq>monthly</changefreq>\
        <priority>1.0</priority>\
        <lastmod>\(dateStubs.expectedString)</lastmod>\
        </url>
        """)
    }
}
