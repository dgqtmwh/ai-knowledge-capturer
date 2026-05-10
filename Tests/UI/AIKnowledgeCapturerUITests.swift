import XCTest

/// UI 交互测试 — 知识捕手主界面
final class AIKnowledgeCapturerUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - 启动

    /// App 启动后进入主界面
    func testAppLaunches() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "TabBar 应存在")
    }

    // MARK: - Tab 导航

    /// 收藏 tab 存在
    func testFavoritesTabExists() {
        let tab = app.tabBars.buttons["收藏"]
        XCTAssertTrue(tab.exists, "收藏 tab 应存在")
    }

    /// 搜索 tab 存在
    func testSearchTabExists() {
        let tab = app.tabBars.buttons["搜索"]
        XCTAssertTrue(tab.exists, "搜索 tab 应存在")
    }

    /// 设置 tab 存在
    func testSettingsTabExists() {
        let tab = app.tabBars.buttons["设置"]
        XCTAssertTrue(tab.exists, "设置 tab 应存在")
    }

    // MARK: - 导航交互

    /// 切换到搜索 tab
    func testSwitchToSearchTab() {
        let searchTab = app.tabBars.buttons["搜索"]
        searchTab.tap()
        // 搜索页面应有搜索栏或标题
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.exists || app.navigationBars.firstMatch.exists,
                      "搜索 tab 应展示内容")
    }

    /// 切换到设置 tab
    func testSwitchToSettingsTab() {
        app.tabBars.buttons["设置"].tap()
        // 设置页面应有内容
        let settingsExist = app.navigationBars.firstMatch.exists
        XCTAssertTrue(settingsExist, "设置页面应展示")
    }

    /// 从设置返回收藏 tab
    func testBackToFavorites() {
        app.tabBars.buttons["设置"].tap()
        app.tabBars.buttons["收藏"].tap()
        let nav = app.navigationBars.firstMatch
        XCTAssertTrue(nav.exists, "返回收藏 tab 后导航栏应存在")
    }
}
