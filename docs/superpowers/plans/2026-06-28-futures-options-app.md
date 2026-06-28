# Futures Options App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal Objective-C iOS futures/options market app with Market, Watchlist, and Profile tabs.

**Architecture:** UIKit app with a tab bar root controller. Sina provides realtime futures quotes; exchange public data links and URL builders are isolated in a separate service for contract, settlement, and historical daily data expansion.

**Tech Stack:** Objective-C, UIKit, Foundation, NSURLSession, NSUserDefaults.

---

### Task 1: Project Shell

**Files:**
- Create: `FuturesOptionsApp.xcodeproj/project.pbxproj`
- Create: `FuturesOptionsApp/Info.plist`
- Create: `FuturesOptionsApp/LaunchScreen.storyboard`
- Create: `FuturesOptionsApp/main.m`
- Create: `FuturesOptionsApp/AppDelegate.h`
- Create: `FuturesOptionsApp/AppDelegate.m`

- [x] Create an Objective-C UIKit app target with no storyboard main interface.
- [x] Set the AppDelegate to create the tab bar root in code.

### Task 2: Data Layer

**Files:**
- Create: `FuturesOptionsApp/Models/FOContract.h`
- Create: `FuturesOptionsApp/Models/FOContract.m`
- Create: `FuturesOptionsApp/Services/FOQuoteService.h`
- Create: `FuturesOptionsApp/Services/FOQuoteService.m`
- Create: `FuturesOptionsApp/Services/FOWatchlistStore.h`
- Create: `FuturesOptionsApp/Services/FOWatchlistStore.m`
- Create: `FuturesOptionsApp/Services/FOExchangeDataService.h`
- Create: `FuturesOptionsApp/Services/FOExchangeDataService.m`

- [x] Add contract model and default futures list.
- [x] Add Sina quote fetch and parser.
- [x] Add local watchlist storage.
- [x] Add exchange public data links and SHFE daily URL builder.

### Task 3: UI Layer

**Files:**
- Create: `FuturesOptionsApp/ViewControllers/FOTabBarController.h`
- Create: `FuturesOptionsApp/ViewControllers/FOTabBarController.m`
- Create: `FuturesOptionsApp/ViewControllers/FOMarketViewController.h`
- Create: `FuturesOptionsApp/ViewControllers/FOMarketViewController.m`
- Create: `FuturesOptionsApp/ViewControllers/FOWatchlistViewController.h`
- Create: `FuturesOptionsApp/ViewControllers/FOWatchlistViewController.m`
- Create: `FuturesOptionsApp/ViewControllers/FOProfileViewController.h`
- Create: `FuturesOptionsApp/ViewControllers/FOProfileViewController.m`

- [x] Add three tabs: 行情, 自选, 我的。
- [x] Add market refresh and watchlist toggle.
- [x] Add watchlist refresh and delete.
- [x] Add profile data-source notes and exchange links.

### Task 4: Verification Scope

- [x] Per user instruction, do not compile or run build verification after code changes.
