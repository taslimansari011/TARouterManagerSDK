//
//  Routable.swift
//  NavigationRouterDemo
//
//  Created by Taslim Ansari on 14/03/24.
//

import SwiftUI

public enum NavigationType {
    case push
    case sheet
    case fullScreenCover
}

public protocol RouteInfo: Hashable {
    var tabIndex: Int? { get }
    var path: String { get }
}

extension RouteInfo {
    var tabIndex: Int? { nil }
}

public typealias Callback = (Bool) -> Void

public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    associatedtype T: RouteInfo
    var routeInfo: T { get set }
    var navigationType: NavigationType { get set }
    var queryData: Any? { get set }
    /// Callback used to get call after succesfully dismissing a view
    var onDismiss: Callback? { get set }
    /// Gives access to the user to perform validations on the current route
    /// - Parameter onDismiss: onDismiss description
    /// - Returns: Returns a `ValidationRoute (eg. LoginRoute)` or nil
    /*  Case:
        1 - If the current view requires any validation the user will be redirected to the given `ValidationRoute` and
            pause the routing till the user do the validations.
        
        2 - If the current is valid and requires no validation or the required validations are already there then pass nil.
     */
    func isRouteValid(onDismiss: Callback?) -> (any Routable)?
    /// This method will be called when the stack required the view to display based on the route
    /// - Parameters:
    ///   - router: router description
    ///   - navigtionType: navigtionType description
    /// - Returns: View
    func viewToDisplay(router: Router<Self>, _ navigtionType: NavigationType) -> ViewType
    /// Route initialization
    init(routeInfo: T, navigationType: NavigationType, queryData: Any, onDismiss: Callback?)
}

// MARK: - Default values

extension Routable {
    public var id: Self { self }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
