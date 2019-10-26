import Cocoa
import SwiftUI
import HarvestStore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        self.window = window

        let store = Store<Root.Input, Root.State>(
            state: Root.State(current: nil),
            mapping: Root.effectMapping(scheduler: DispatchQueue.main)
        )

        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(
            rootView: AppView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        window.makeKeyAndOrderFront(nil)
    }

}

