//
//  Router.swift
//  NavigationRouterDemo
//
//  Created by Taslim Ansari on 14/03/24.
//

import SwiftUI

public class Router<Destination: Routable>: ObservableObject, RoutingProtocols {
    /// Used to programatically control a navigation stack
    /// Each router will have its own stack and will be managed separately
    @Published public var stack: [Destination] = [] {
        didSet {
            currentPath = stack.map({ route in return route.routeInfo.path }).joined()
        }
    }
    /// Holds the path of reaching the current screen
    public var currentPath: String = ""
    /// Holds the pending routes that maybe because of some validation is still pending.
    private var pendingRoutes: [Destination] = []
    /// Selected tab value if any tab is also there
    @Published public var selectedTab: Int?
    /// Used to present a view using a sheet
    @Published public var presentingSheet: Destination?
    /// Used to present a view using a full screen cover
    @Published public var presentingFullScreenCover: Destination?
    /// Used by presented Router instances to dismiss themselves
    @Published public var isPresented: Binding<Destination?>?
    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreenCover != nil
    }
    
    public init(isPresented: Binding<Destination?> = .constant(nil)) {
        self.isPresented = isPresented
    }
    
    /// Returns the view associated with the specified `Routable`
    public func view(for route: Destination) -> some View {
        let router = router(routeType: route.navigationType)
        return route.viewToDisplay(router: router, route.navigationType)
    }
    
    /// Routes to the specified `Routable`.
    public func routeTo(_ route: Destination) {
        if let validationRoute = route.isRouteValid(onDismiss: { success in
            /// It is the value returned by the valudator
            /// It this route require validation than the route will be dependent on  this value to proceed further
            /// - Parameter success:
                /// true: Proceed with the remaining path
                /// false: Halt the path
            if success {
                if self.pendingRoutes.isEmpty {
                    self.routeTo(route)
                } else {
                    self.pushMultiple(self.pendingRoutes)
                }
            }
        }) as? Destination {
            routeTo(validationRoute)
            return
        }
        switch route.navigationType {
        case .push:
            push(route)
            updatePendingRoutesWithPushed(route)
        case .sheet:
            presentSheet(route)
        case .fullScreenCover:
            presentFullScreen(route)
        }
    }
    
    /// Navigate to a series of views at once
    /// - Parameter routes: routes description
    public func pushMultiple(_ routes: [Destination]) {
        pendingRoutes = routes
        routes.forEach { route in
            routeTo(route)
        }
    }
    
    /// Replace the stack with the given array of routes
    /// - Parameter routes: routes description
    public func pushReplacement(_ routes: [Destination]) {
        if routes.isEmpty {
            popToRoot()
        } else {
            stack = []
            pushMultiple(routes)
        }
    }
    
    /// Pop to the root screen in our hierarchy
    public func popToRoot() {
        stack.removeLast(stack.count)
    }
    
    /// If stack have pushed routes pop the top route else dismiss the presented route.
    public func dismiss() {
        if !stack.isEmpty {
            stack.removeLast()
        } else {
            isPresented?.wrappedValue = nil
        }
    }
    
    /// Dismisses presented screen and call the validation callback if there is any
    public func dismissValidator(_ isValidationSuccessful: Bool = false) {
        if let sheet = isPresented?.wrappedValue {
            sheet.onDismiss?(isValidationSuccessful)
            isPresented?.wrappedValue = nil
        } else {
            presentingSheet?.onDismiss?(isValidationSuccessful)
            isPresented?.wrappedValue = nil
        }
    }
    
    /// Dismiss the full sheet
    public func dismissSheet() {
        isPresented?.wrappedValue = nil
    }
    
    /// Check if stack can pop a view
    /// - Returns: can pop
    public func canPop() -> Bool {
        !stack.isEmpty
    }
    
    /// Pop till the given route
    /// - Parameter route: route description
    public func popUntil(_ route: Destination) {
        for pathRoute in stack {
            if pathRoute == route {
                break
            } else {
                stack.removeLast()
            }
        }
    }
    
    /// Pop the top screen if possible then Push to the given route.
    /// - Parameter route: route to be pushed
    public func popAndPush(_ route: Destination) {
        if canPop() {
            dismiss()
        }
        routeTo(route)
    }
    
    /// Handle any deeplinks from here
    /// - Parameters:
    ///   - routes: routes description
    ///   - isPathPresentInThisStack: isPathPresentInThisStack states if the given route is already present on the stack or not.
    public func handleDeeplink(routes: [Destination], isPathPresentInThisStack: Bool) {
        if isPathPresentInThisStack {
            if let index = stack.lastIndexOfContiguous(routes) {
                while stack.count > index + 1 {
                    stack.removeLast()
                }
            }
        } else {
            pushMultiple(routes)
        }
    }
    
    /// Checks if the given path is present on this stack or not and return the corresponding Bool value
    /// - Parameter path: path description
    /// - Returns: Bool
    public func isPathPresent(path: String) -> Bool {
        currentPath.contains(path)
    }
}

// MARK: - Private methods

extension Router {
    /// After successful routing remove the provided route from the pending routes
    /// - Parameter route: route description
    fileprivate func updatePendingRoutesWithPushed(_ route: Destination) {
        if let index = pendingRoutes.firstIndex(of: route) {
            pendingRoutes.remove(at: index)
        }
    }
    
    /// Push the given route on the current stack.
    /// - Parameter route: route description
    fileprivate func push(_ route: Destination) {
        stack.append(route)
        currentPath.append(route.routeInfo.path)
    }
    
    /// Present the given route.
    /// - Parameter route: route description
    fileprivate func presentSheet(_ route: Destination) {
        self.presentingSheet = route
    }
    
    /// Present the full screen sheet with given route.
    /// - Parameter route: route description
    fileprivate func presentFullScreen(_ route: Destination) {
        self.presentingFullScreenCover = route
    }
    
    /// Return the appropriate Router instance based on the `NavigationType`
    /// For a new sheet pass a new router so that each presented sheet should have its own route.
    fileprivate func router(routeType: NavigationType) -> Router {
        switch routeType {
        case .push:
            return self
        case .sheet:
            return Router(
                isPresented: Binding(
                    get: { self.presentingSheet },
                    set: { self.presentingSheet = $0 }
                )
            )
        case .fullScreenCover:
            return Router(
                isPresented: Binding(
                    get: { self.presentingFullScreenCover },
                    set: { self.presentingFullScreenCover = $0 }
                )
            )
        }
    }
}
