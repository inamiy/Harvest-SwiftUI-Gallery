import SafariServices
import SwiftUI

struct WebView: UIViewControllerRepresentable
{
    let url: URL

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<WebView>
    ) -> SFSafariViewController
    {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<WebView>
    )
    {
    }
}

struct WebView_Previews: PreviewProvider
{
    static var previews: some View
    {
        Group {
            WebView(url: URL(string: "https://github.com/inamiy/Harvest")!)
        }
    }
}
