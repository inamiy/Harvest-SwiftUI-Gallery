import SwiftUI

#if canImport(UIKit)

struct ActivityIndicatorView: UIViewRepresentable
{
    @Binding
    private(set) var isAnimating: Bool

    let style: UIActivityIndicatorView.Style

    init(isAnimating: Binding<Bool> = .constant(true), style: UIActivityIndicatorView.Style = .medium)
    {
        self._isAnimating = isAnimating
        self.style = style
    }

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView
    {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>)
    {
        self.isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ActivityIndicatorView_Previews: PreviewProvider
{
    static var previews: some View
    {
        Group {
            ActivityIndicatorView(isAnimating: .constant(true), style: .medium)
                .previewLayout(.fixed(width: 100, height: 100))

            ActivityIndicatorView(isAnimating: .constant(false), style: .medium)
                .previewLayout(.fixed(width: 100, height: 100))

            ActivityIndicatorView(isAnimating: .constant(true), style: .large)
                .previewLayout(.fixed(width: 100, height: 100))
        }
    }
}

#endif
