//
//  RoutingView.swift
//  NavigationRouterDemo
//
//  Created by Taslim Ansari on 14/03/24.
//

import SwiftUI

/// Base Routing view which contains the Navigation View and manages the routing through itself using the router this struct contains.
public struct RoutingView<Content: View, Destination: Routable>: View {
    @ObservedObject private var router: Router<Destination>
    private let rootContent: () -> Content
    
    /// RoutingView initializer
    /// - Parameters:
    ///   - router: router to manage the routing
    ///   - routeType: routeType description
    ///   - content: block which will be called to get the root content
    public init(router: Router<Destination>, _ routeType: Destination.Type, @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.rootContent = content
    }
    
    public var body: some View {
        NavigationStack(path: $router.stack) {
            rootContent()
                .navigationDestination(for: Destination.self) { route in
                    router.view(for: route)
                }
        }
        .sheet(item: $router.presentingSheet) { route in
            router.view(for: route)
        }
        .fullScreenCover(item: $router.presentingFullScreenCover) { route in
            router.view(for: route)
        }
    }
}
