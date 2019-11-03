import SwiftUI
import HarvestStore

struct GitHubView: View
{
    private let store: Store<GitHub.Input, GitHub.State>.Proxy

    init(store: Store<GitHub.Input, GitHub.State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        VStack {
            searchBar()

            Divider()

            List {
                ForEach(self.store.state.items.indices, id: \.self) { index in
                    self.itemRow(at: index)
                        .onTapGesture {
                            self.store.send(.tapRow(at: index))
                        }
                        .onAppear {
                            self.store.send(.requestImage(at: index))
                        }
                        .onDisappear {
                            self.store.send(.cancelImage(at: index))
                        }
                }
            }
            .sheet(isPresented: self.store.$state.isWebViewPresented) {
                WebView(url: self.store.state.selectedWebURL!)
            }
        }
        .navigationBarItems(
            trailing: If(self.store.state.isLoading) {
                ActivityIndicatorView()
            }.else {
                EmptyView()
            }
        )
        .onAppear { self.store.send(.onAppear) }
        .alert(item: self.store.$state.errorMessage) {
            Alert(
                title: Text("Network Error"),
                message: Text("\($0.message)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func searchBar() -> some View
    {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(
                "Search",
                // IMPORTANT:
                // Requires indirect state-to-input conversion binding here because
                // `Input.updateSearchText` will trigger side-effect
                // which is not possible via direct state binding.
                text: self.store.stateBinding(
                    get: { $0.searchText },
                    onChange: GitHub.Input.updateSearchText
                )
                // text: self.store.$state.searchText
            )

            Button(action: {
                self.store.send(.updateSearchText(""))
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .opacity(self.store.state.searchText == "" ? 0 : 1)
            }
        }
        .padding(10)
    }

    private func itemRow(at visibleIndex: Int) -> some View
    {
        let item = self.store.state.items[visibleIndex]
        let image = self.store.state.imageLoader.images[item.owner.avatarUrl]

        return HStack(alignment: .top) {
            IfLet(image) { image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
            }
            .else {
                // FIXME: Improve this emptiness, where `EmptyView` or `Spacer` results differently.
                Text("")
            }
            .frame(width: 80)

            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "doc.text")
                    Text(item.fullName)
                        .bold()
                }

                // Show text if description exists
                item.description
                    .map(Text.init)?
                    .lineLimit(nil)

                HStack {
                    Image(systemName: "star")
                    Text("\(item.stargazersCount)")
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct GitHubView_Previews: PreviewProvider
{
    static var previews: some View
    {
        GitHubView(
            store: .init(
                state: .constant(.init()),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
