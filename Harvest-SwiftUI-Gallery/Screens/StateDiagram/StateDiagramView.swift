import SwiftUI
import HarvestStore

struct StateDiagramView: View
{
    private let store: Store<StateDiagram.Input, StateDiagram.State>.Proxy

    init(store: Store<StateDiagram.Input, StateDiagram.State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        VStack(spacing: 20) {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    Image("login-diagram")
                        .resizable()

                    Rectangle()
                        .stroke(focusColor(state: self.store.state), lineWidth: 4)
                        .frame(
                            width: focusSize(imageWidth: geometry.size.width).width,
                            height: focusSize(imageWidth: geometry.size.width).height
                        )
                        .animation(.easeInOut(duration: 0.3))
                        .offset(
                            focusOffsets(imageSize: geometry.size, state: self.store.state)
                        )
                }
            }
            .aspectRatio(actualImageSize, contentMode: .fit)
            .padding()

            HStack(spacing: 20) {
                Button("Login", action: { self.store.send(.login) })
                Button("Logout", action: { self.store.send(.logout) })
                Button("ForceLogout", action: { self.store.send(.forceLogout) })
            }
            .font(.title)
        }
    }
}

// MARK: - Handmade focus position calculation

/// Image size of `login-diagram.png`.
private let actualImageSize = CGSize(width: 896, height: 480)

private func focusSize(imageWidth: CGFloat) -> CGSize
{
    let rate = imageWidth / 375
    return CGSize(width: 80 * rate, height: 50 * rate)
}

private func focusOffsets(imageSize: CGSize, state: StateDiagram.State) -> CGSize
{
    let focusSize_ = focusSize(imageWidth: imageSize.width)

    let left: CGFloat = 0
    let centerX: CGFloat = imageSize.width / 2 - focusSize_.width / 2
    let right: CGFloat = imageSize.width - focusSize_.width
    let bottom: CGFloat = 0
    let centerY: CGFloat = -imageSize.height / 2 + focusSize_.height / 2
    let top: CGFloat = -imageSize.height + focusSize_.height

    switch state {
    case .loggedOut:
        return CGSize(width: left, height: centerY)
    case .loggingIn:
        return CGSize(width: centerX, height: top)
    case .loggedIn:
        return CGSize(width: right, height: centerY)
    case .loggingOut:
        return CGSize(width: centerX, height: bottom)
    }
}

private func focusColor(state: StateDiagram.State) -> Color
{
    switch state {
    case .loggedOut:
        return .blue
    case .loggingIn:
        return .orange
    case .loggedIn:
        return .green
    case .loggingOut:
        return .purple
    }
}

struct StateDiagramView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let stateDiagramView = StateDiagramView(
            store: .init(
                state: .constant(.loggedOut),
                send: { _ in }
            )
        )

        return Group {
            stateDiagramView.previewLayout(.sizeThatFits)
                .previewDisplayName("Portrait")

            stateDiagramView.previewLayout(.fixed(width: 568, height: 320))
                .previewDisplayName("Landscape")
        }
    }
}
