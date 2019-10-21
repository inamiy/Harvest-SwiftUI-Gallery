import SwiftUI

struct IntroView: View
{
    var body: some View
    {
        VStack(spacing: 20) {
            Text("Hello 🌾 Harvest!")
                .font(.largeTitle)

            Text("""
This demo app uses the following techniques to build a new SwiftUI Composable Architecture.

1. Harvest (Elm-like Architecture)
2. Optics (Lenses and Prisms)
3. Store.Proxy (easy 2-way-binding with SwiftUI)

Please check that this whole app is based on `Store` as a single source of truth, and Optics helps decoupling of each screen's `State`, `Input` (Action), and `EffectMapping` (Reducer) in a elegant way.

If you are not familiar with "Elm" or "Lenses and Prisms", go google these words to start diving into Functional Programming!
""")
                .padding(.horizontal, 40)
        }
    }
}

struct IntroView_Previews: PreviewProvider
{
    static var previews: some View
    {
        IntroView()
            .previewLayout(.sizeThatFits)
    }
}
