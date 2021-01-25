import SwiftUI
import Harvest
import HarvestStore

struct DebugRootView: View
{
    private let store: Store<DebugRoot.Input, DebugRoot.State>.Proxy
    private let usesTimeTravel: Bool

    init(store: Store<DebugRoot.Input, DebugRoot.State>.Proxy, usesTimeTravel: Bool = true)
    {
        self.store = store
        self.usesTimeTravel = usesTimeTravel
    }

    var body: some View
    {
        let rootView = RootView(
            store: self.store.timeTravel.inner
                .contramapInput { DebugRoot.Input.timeTravel(.inner($0)) }
        )

        return If(self.store.state.usesTimeTravel) {
            VStack {
                rootView
                Divider()
                self.debugBottomView()
            }
        }
        .else {
            rootView
        }
    }

    private func debugBottomView() -> some View
    {
        VStack(alignment: .leading) {
//            HStack {
//                Toggle("Debug", isOn: store.$state.isDebug)
//            }
//
//            Divider()

            timeTravelHeader()

            HStack {
                timeTravelSlider()
                timeTravelStepper()
            }
        }
        .padding()
    }

    private func timeTravelHeader() -> some View
    {
        HStack {
            Text("⏱ TIME TRAVEL ⌛").bold()
            Spacer()
            Button("Reset", action: { self.store.send(.timeTravel(.resetHistories)) })
        }
    }

    private func timeTravelSlider() -> some View
    {
        HStack {
            Slider(
                value: self.store.timeTravel.timeTravellingSliderValue
                    .stateBinding(onChange: {
                        DebugRoot.Input.timeTravel(.timeTravelSlider(sliderValue: $0))
                    }),
                in: self.store.state.timeTravel.timeTravellingSliderRange,
                step: 1
            )
                .disabled(!self.store.state.timeTravel.canTimeTravel)

            Text("\(self.store.state.timeTravel.timeTravellingIndex) / \(Int(self.store.state.timeTravel.timeTravellingSliderRange.upperBound))")
                .font(Font.body.monospacedDigit())
                .frame(minWidth: 80, alignment: .center)
        }
    }

    private func timeTravelStepper() -> some View
    {
        Stepper(
            onIncrement: { self.store.send(.timeTravel(.timeTravelStepper(diff: 1))) },
            onDecrement: { self.store.send(.timeTravel(.timeTravelStepper(diff: -1))) }
        ) {
            EmptyView()
        }
        .frame(width: 100)
    }
}

struct DebugRootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        return Group {
            DebugRootView(
                store: .init(
                    state: .constant(DebugRoot.State(inner: Root.State(), usesTimeTravel: true)),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Root")
        }
    }
}
