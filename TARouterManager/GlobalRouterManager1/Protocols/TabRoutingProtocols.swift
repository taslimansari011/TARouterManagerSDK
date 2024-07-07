//
//  TabRoutingProtocols.swift
//  NavigationRouterDemo
//
//  Created by Taslim Ansari on 22/03/24.
//

import Foundation

protocol TabRoutingProtocols {
    associatedtype Destination: Routable
    /// Each item in the array is a router for each tab item
    var navigationRouters: [Router<Destination>] { get set }
    /// It will keep track of the selected tab item
    var selectedTab: Int { get set }
    /// Handle the deep link navigation
    /// - Parameters:
    ///   - routes: routes to be handled description
    ///   - pathString: pathString of the deeplink description
    func handleDeeplink(routes: [Destination], pathString: String)
    /// Route to home screen i.e the first tab's root screen
    func routeToHome()
}
