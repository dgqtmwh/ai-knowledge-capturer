import XCTest
@testable import AIKnowledgeCapturer

/// Service 层测试 — 数据存储服务
@MainActor
final class StorageServiceTests: XCTestCase {

    private var storage: StorageService!

    override func setUp() {
        storage = StorageService.shared
        storage.setup()
        // 清空测试数据
        for item in storage.fetchAll() {
            storage.delete(item)
        }
    }

    override func tearDown() {
        for item in storage.fetchAll() {
            storage.delete(item)
        }
    }

    // MARK: - CRUD

    /// 保存后 fetchAll 返回包含新项目
    func testSaveAndFetch() {
        let item = SavedItem(title: "测试文章", originalText: "测试内容", sourceType: .text)
        storage.save(item)
        let all = storage.fetchAll()
        XCTAssertTrue(all.contains(where: { $0.id == item.id }))
    }

    /// 删除后不应再出现
    func testDeleteRemovesItem() {
        let item = SavedItem(title: "待删除", sourceType: .text)
        storage.save(item)
        storage.delete(item)
        let all = storage.fetchAll()
        XCTAssertFalse(all.contains(where: { $0.id == item.id }))
    }

    /// 按时间倒序排列
    func testFetchAllOrderedDesc() {
        let early = SavedItem(title: "早", sourceType: .text)
        let late = SavedItem(title: "晚", sourceType: .text)
        storage.save(early)
        storage.save(late)

        let all = storage.fetchAll()
        if let i1 = all.firstIndex(where: { $0.id == early.id }),
           let i2 = all.firstIndex(where: { $0.id == late.id }) {
            XCTAssertLessThan(i2, i1, "后保存的排前面")
        }
    }

    // MARK: - 搜索

    /// 按标题搜索可找到匹配项
    func testSearchByTitle() {
        let item = SavedItem(title: "SwiftUI 教程", originalText: "SwiftUI 是 Apple 的框架", sourceType: .text)
        storage.save(item)

        let results = storage.search(query: "SwiftUI")
        XCTAssertTrue(results.contains(where: { $0.id == item.id }))
    }

    /// 按摘要搜索可找到匹配项
    func testSearchBySummary() async {
        let text = "这是一篇关于深度学习的文章"
        let item = SavedItem(title: "深度学习", originalText: text, sourceType: .text)
        storage.save(item)

        let ai = AIService.shared
        let summary = await ai.generateSummary(for: text)
        item.summary = summary
        storage.update()

        let results = storage.search(query: "深度学习")
        XCTAssertTrue(results.contains(where: { $0.id == item.id }),
                      "摘要匹配也应搜到")
    }

    /// 搜索不存在的关键词返回空
    func testSearchNoMatch() {
        let results = storage.search(query: "ZZZZ_NOT_EXIST_12345")
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - 分类查询

    /// 按分类筛选
    func testFetchByCategory() async {
        let item = SavedItem(title: "技术文章", originalText: "Xcode 开发技巧", sourceType: .text)
        storage.save(item)
        let ai = AIService.shared
        item.category = await ai.categorize(item.originalText ?? "", title: item.title)
        storage.update()

        let results = storage.fetchByCategory("技术")
        XCTAssertTrue(results.contains(where: { $0.id == item.id }))
    }

    /// 不存在的分类返回空
    func testFetchByNonExistentCategory() {
        let results = storage.fetchByCategory("__NON_EXISTENT__")
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - 导入

    /// 无共享内容时返回 0
    func testImportSharedContentEmpty() {
        AppGroup.clearSharedContents()
        let count = storage.importSharedContent()
        XCTAssertEqual(count, 0)
    }

    // MARK: - 模型

    /// SavedItem 初始化默认值
    func testSavedItemDefaults() {
        let item = SavedItem(title: "测试", sourceType: .text)
        XCTAssertNotNil(item.id, "id 应自动生成")
        XCTAssertEqual(item.title, "测试")
        XCTAssertNil(item.url)
        XCTAssertNil(item.originalText)
        XCTAssertNil(item.summary)
        XCTAssertNil(item.category)
        XCTAssertNil(item.tagsData)
        XCTAssertEqual(item.sourceType, .text)
        XCTAssertFalse(item.isFavorited)
    }
}
