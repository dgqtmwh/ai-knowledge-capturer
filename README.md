# 知识捕手 (AI Knowledge Capturer) 🧠

AI 驱动的个人知识管理助手 — 你的第二大脑。

## 功能

- **一键保存**：在其他 App 中点「分享」→「保存到知识捕手」，自动保存网页/截图/文本
- **AI 摘要**：自动生成内容摘要，快速回顾
- **智能分类**：自动识别内容类别（技术/设计/商业/生活/学习）
- **语义搜索**：自然语言搜索已保存内容
- **端侧隐私**：所有数据在设备本地处理，不上传云端

## 快速开始

### 前置条件

- macOS 15+ + Xcode 16+
- iOS 18+（开发部署目标）
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)（可选，用于自动生成 .xcodeproj）

### 生成并打开项目

```bash
# 安装 XcodeGen（如果没有）
brew install xcodegen

# 生成 Xcode 项目
cd AIKnowledgeCapturer
xcodegen generate

# 打开项目
open AIKnowledgeCapturer.xcodeproj
```

### 配置 App Group

1. 在 Xcode 中打开项目
2. 主 Target → Signing & Capabilities → + Capability → App Groups
3. 添加 `group.com.yourname.aiknowledgecapturer`
4. Share Extension Target 同样操作

### 配置开发者账号

在 `project.yml` 中修改：

```yaml
settings:
  base:
    DEVELOPMENT_TEAM: "你的TeamID"  # ← 改成你的 Apple Developer Team ID
```

以及 `Sources/Utilities/AppGroup.swift` 中的：

```swift
static let identifier = "group.com.yourname.aiknowledgecapturer"
```

## 项目结构

```
AIKnowledgeCapturer/
├── Sources/
│   ├── App/                    # App 入口
│   │   └── AIKnowledgeCapturerApp.swift
│   ├── Models/                 # 数据模型
│   │   ├── SavedItem.swift
│   │   └── SourceType.swift
│   ├── Views/                  # 界面
│   │   ├── ContentView.swift
│   │   ├── ContentListView.swift
│   │   ├── DetailView.swift
│   │   ├── SearchView.swift
│   │   └── SettingsView.swift
│   ├── Services/               # 服务层
│   │   ├── StorageService.swift
│   │   ├── AIService.swift
│   │   └── SubscriptionService.swift
│   └── Utilities/              # 工具
│       └── AppGroup.swift
├── ShareExtension/             # Share Extension
│   ├── ShareViewController.swift
│   └── Info.plist
├── Resources/                  # 资源文件
│   ├── Info.plist
│   └── Assets.xcassets/
├── project.yml                 # XcodeGen 配置
└── README.md
```

## 免费 vs Pro

| 功能 | 免费 | Pro |
|------|------|-----|
| 保存条数 | 50 条 | 无限 |
| AI 摘要 | ✅ | ✅ |
| 智能分类 | ✅ | ✅ |
| 语义搜索 | ✅ | ✅ |
| 标签系统 | ✅ | ✅ |
| 年订阅 | — | $29.99 |
| 月订阅 | — | $4.99 |
| 终身 | — | $79.99 |

## 开发计划

- [x] MVP：保存 + AI 处理 + 搜索
- [ ] v1.1：iCloud 同步
- [ ] v1.2：知识关联图（跨源连接）
- [ ] v1.3：间隔复习
- [ ] v1.4：Shortcuts 深度集成
- [ ] v1.5：团队协作
