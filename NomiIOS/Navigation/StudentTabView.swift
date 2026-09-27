import SwiftUI

/// Barra de pestañas: Inicio, Buscar, Pedidos y Perfil.
struct StudentTabView: View {
    let container: AppContainer
    @Binding var path: NavigationPath

    private enum Tab { case home, search, orders, profile }
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // Estos `ViewModel` se construyen de nuevo cada vez que cambia la pestaña; cada pantalla los
            // guarda en `@State`, así que solo se usa la primera instancia y el estado se conserva.
            HomeView(viewModel: HomeViewModel(productsAPI: container.productsAPI, aiAPI: container.aiAPI), path: $path)
                .tabItem { tabLabel("Inicio", filled: NMIcon.homeFilled, outline: NMIcon.homeOutline, isSelected: selectedTab == .home) }
                .tag(Tab.home)

            SearchView(viewModel: SearchViewModel(productsAPI: container.productsAPI), path: $path)
                .tabItem { tabLabel("Buscar", filled: NMIcon.searchFilled, outline: NMIcon.searchOutline, isSelected: selectedTab == .search) }
                .tag(Tab.search)

            OrdersListView(viewModel: OrdersListViewModel(ordersAPI: container.ordersAPI), path: $path)
                .tabItem { tabLabel("Pedidos", filled: NMIcon.receiptFilled, outline: NMIcon.receiptOutline, isSelected: selectedTab == .orders) }
                .tag(Tab.orders)

            ProfileView(path: $path)
                .tabItem { tabLabel("Perfil", filled: NMIcon.personFilled, outline: NMIcon.personOutline, isSelected: selectedTab == .profile) }
                .tag(Tab.profile)
        }
        .tint(NMColors.accent)
        .onAppear(perform: configureTabBarAppearance)
    }

    private func tabLabel(_ title: String, filled: String, outline: String, isSelected: Bool) -> some View {
        Label(title, systemImage: isSelected ? filled : outline)
    }

    /// Barra opaca con color de superficie, acento para la pestaña activa y neutro para el resto.
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(NMColors.surface)
        appearance.shadowColor = UIColor(NMColors.line)

        let inactive = UIColor(NMColors.neutral)
        let active = UIColor(NMColors.accent)
        for itemAppearance in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            itemAppearance.normal.iconColor = inactive
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: inactive]
            itemAppearance.selected.iconColor = active
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: active]
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
