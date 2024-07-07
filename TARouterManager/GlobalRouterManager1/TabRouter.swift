//
//  TabRouter.swift
//  NavigationRouterDemo
//
//  Created by Taslim Ansari on 22/03/24.
//

import Foundation

/// Tab Router
public class TabRouter<Destination: Routable>: ObservableObject, TabRoutingProtocols {
    @Published public var navigationRouters: [Router<Destination>] = []
    @Published public var selectedTab: Int = 0
    
    private var router: Router<Destination>? {
        if selectedTab < navigationRouters.count {
            return navigationRouters[selectedTab]
        }
        return nil
    }
    
    public init(_ navigationRouters: [Router<Destination>]) {
        self.navigationRouters = navigationRouters
    }
    
    private func select(_ tab: Int) {
        selectedTab = tab
    }
    
    /// Handle the deep link navigation
    /// - Parameters:
    ///   - routes: routes to be handled description
    ///   - pathString: pathString of the deeplink description
    public func handleDeeplink(routes: [Destination] = [], pathString: String = "") {
        var internalPath = routes
        if let tab = routes.first?.routeInfo.tabIndex {
            selectedTab = tab
            internalPath.removeFirst()
            router?.pushReplacement(internalPath)
        } else {
            /// Find the first router which already have the path opened
            for (tab, routerHavingPath) in navigationRouters.enumerated() where routerHavingPath.isPathPresent(path: pathString) {
                select(tab)
                routerHavingPath.handleDeeplink(routes: routes, isPathPresentInThisStack: true)
                return
            }
            router?.handleDeeplink(routes: routes, isPathPresentInThisStack: false)
        }
    }
    
    /// Route to home screen i.e the first tab's root screen
    public func routeToHome() {
        selectedTab = 0
        router?.popToRoot()
    }
}
