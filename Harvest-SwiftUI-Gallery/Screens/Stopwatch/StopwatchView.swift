import SwiftUI
import HarvestStore

struct StopwatchView: View
{
    private let store: Store<Stopwatch.Input, Stopwatch.State>.Proxy

    init(store: Store<Stopwatch.Input, Stopwatch.State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        VStack {
            largeTime()
            buttons()
            Divider()
            lapList()
        }
    }

    private func largeTime() -> some View
    {
        Text("\(self.store.state.status.timeString)")
            //.font(.system(size: 64, design: .monospaced))
            .font(Font.system(size: 64).monospacedDigit())
            .padding(.horizontal)
            .padding(.vertical, 60)
    }

    private func buttons() -> some View
    {
        HStack {
            if self.store.state.status.isRunning {
                Button(action: { self.store.send(.lap) }) {
                    Text("Lap").font(.title)
                }

                Spacer()

                Button(action: { self.store.send(.stop) }) {
                    Text("Stop").font(.title)
                }
            }
            else {
                if self.store.state.status.isPaused {
                    Button(action: { self.store.send(.reset) }) {
                        Text("Reset").font(.title)
                    }
                }
                else { // isIdle
                    Button(action: {}) {
                        Text("Lap").font(.title).disabled(true)
                    }
                }

                Spacer()

                Button(action: { self.store.send(.start) }) {
                    Text("Start") // or Stop
                        .font(.title)
                }
            }
        }
        .padding(.horizontal)
    }

    private func lapList() -> some View
    {
        List(self.store.state.laps.reversed()) { lap in
            HStack {
                Text("Lap \(lap.id)")
                    .font(Font.body.monospacedDigit())
                Spacer()
                Text("\(lap.timeString)")
                    .font(Font.body.monospacedDigit())
            }
            .if(lap.id == self.store.state.fastestLapID) {
                $0.foregroundColor(Color.green)
            }
            .if(lap.id == self.store.state.slowestLapID) {
                $0.foregroundColor(Color.red)
            }
        }
    }
}

struct StopwatchView_Previews: PreviewProvider
{
    static var previews: some View
    {
        StopwatchView(
            store: .init(
                state: .constant(.init(
                    status: .idle,
                    laps: [
                        .init(id: 0, time: 0.01),
                        .init(id: 1, time: 0.5),
                        .init(id: 2, time: 1.0),
                    ]
                )),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}

// MARK: - Private

extension Stopwatch.State.Status
{
    var timeString: String
    {
        switch self {
        case .idle, .preparing:
            return DateUtil.timeString(time: 0)

        case let .running(time, start, current):
            return DateUtil.timeString(time: time + current.timeIntervalSince1970 - start.timeIntervalSince1970)

        case let .paused(time):
            return DateUtil.timeString(time: time)
        }
    }
}

extension Stopwatch.State.Lap
{
    var timeString: String
    {
        DateUtil.timeString(time: self.time)
    }
}
