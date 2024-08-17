@testable import CanProceed
import XCTest

final class CanProceedTests: XCTestCase {
    private let text =
        """
        # Comments should be ignored.
        # Short bot test part 1.
        User-agent: Longbot
        Allow: /cheese
        Allow: /swiss
        Allow: /swissywissy
        Disallow: /swissy
        Crawl-delay: 3
        Sitemap: http://www.bbc.co.uk/news_sitemap.xml
        Sitemap: http://www.bbc.co.uk/video_sitemap.xml
        Sitemap: http://www.bbc.co.uk/sitemap.xml

        User-agent: MoreBot
        Allow: /
        Disallow: /search
        Disallow: /news
        Crawl-delay: 89
        Sitemap: http://www.bbc.co.uk/sitemap.xml

        User-agent: *
        Allow: /news
        Allow: /Testytest
        Allow: /Test/small-test
        Disallow: /
        Disallow: /spec
        Crawl-delay: 64
        Sitemap: http://www.bbc.co.uk/mobile_sitemap.xml

        Sitemap: http://www.bbc.co.uk/test.xml
        host: http://www.bbc.co.uk
        """

    func testPaths() throws {
        let check = CanProceed.parse(text)

        testChecker(check)

        let generated = check.asRobotsTxt()

        let checkGenerated = CanProceed.parse(generated)
        testChecker(checkGenerated)
    }

    private func testChecker(_ check: CanProceed) {
        // Check duplicate was discarded
        XCTAssertEqual(check.sitemaps.count, 5)

        XCTAssertTrue(check.agent("Longbot", canProceedTo: "/cheese"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/cheeses"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swis"))
        XCTAssertTrue(check.agent("Longbot", canProceedTo: "/swiss"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swissy"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swissyw"))
        XCTAssertTrue(check.agent("Longbot", canProceedTo: "/swissywissy"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swissywissyssss"))

        XCTAssertTrue(check.agent("Longbot", canProceedTo: "/cheese/a"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/cheeses/a"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swis/a"))
        XCTAssertTrue(check.agent("Longbot", canProceedTo: "/swiss/a"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swissy/a"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swissyw/a"))
        XCTAssertTrue(check.agent("Longbot", canProceedTo: "/swissywissy/a"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/swissywissys/a"))

        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "/test"))
        XCTAssertFalse(check.agent("Longbot", canProceedTo: "/test"))
        XCTAssertFalse(check.agent("MoreBot", canProceedTo: "/news"))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "/newss"))
        XCTAssertFalse(check.agent("MoreBot", canProceedTo: "/news/s"))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "/new/s"))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "/new-s"))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "/new.s"))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "/ news"))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: " /news "))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "/news "))
        XCTAssertTrue(check.agent("MoreBot", canProceedTo: "news"))

        XCTAssertTrue(check.some(agentsNamed: ["MoreBot", "LongBot"], canProceedTo: "/test"))
        XCTAssertFalse(check.all(agentsNamed: ["MoreBot", "LongBot"], canProceedTo: "/test"))

        XCTAssertFalse(check.agent("Nonexistent", canProceedTo: "/test"))
        XCTAssertTrue(check.some(agentsNamed: ["MoreBot", "Nonexistent"], canProceedTo: "/test"))
        XCTAssertTrue(check.some(agentsNamed: ["MoreBot", "LongBot", "Nonexistent"], canProceedTo: "/test"))
        XCTAssertFalse(check.all(agentsNamed: ["MoreBot", "LongBot", "Nonexistent"], canProceedTo: "/test"))
        XCTAssertFalse(check.all(agentsNamed: ["MoreBot", "Nonexistent"], canProceedTo: "/test"))
    }
}
