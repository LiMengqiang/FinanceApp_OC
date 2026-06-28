# FinanceApp_OC

Objective-C + UIKit 实现的期货期权行情 App 学习 Demo，用于验证传统 iOS 技术栈下金融行情类页面的基础架构、列表展示、自选管理和网络数据解析能力。

## 功能

- 行情页：展示期货连续合约行情，支持刷新最新价、涨跌、涨跌幅、成交量、结算价等字段。
- 自选页：支持添加、移除自选合约，并通过本地存储保留自选列表。
- 数据源页：展示新浪实时行情与交易所公开数据入口。
- 基础架构：使用 Model、Service、ViewController 分层组织代码。

## 技术栈

- Objective-C
- UIKit
- UITableView
- NSURLSession
- NSUserDefaults

## 运行方式

1. 使用 Xcode 打开 `FuturesOptionsApp.xcodeproj`。
2. 选择 iOS Simulator 或真机运行。
3. 项目最低支持 iOS 12.0。

## 学习重点

- Objective-C 项目结构与 UIKit 页面搭建。
- 行情列表、自选列表和基础本地存储实现。
- 金融行情接口返回数据的解析与页面刷新。

## 说明

本项目仅用于移动端技术学习和 Demo 展示，行情数据来自公开网络数据源，不保证实时性、完整性和可用性，不构成任何投资建议。
