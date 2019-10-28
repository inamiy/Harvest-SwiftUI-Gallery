import SwiftUI
import Harvest
import HarvestStore

/// Topmost container view of the app which holds `Store` as a single source of truth.
/// For the child views, pass `Store.Proxy` instead, so that we don't duplicate multiple `Store`s
/// but `Binding` and `Store.proxy.send` (sending message to `Store`) functionalities are still available.
struct AppView: View
{
    @ObservedObject
    private var store: Store<DebugRoot.Input, DebugRoot.State>

    init(store: Store<DebugRoot.Input, DebugRoot.State>)
    {
        self.store = store
    }

    var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        DebugRootView(store: self.store.proxy)
    }
}
