/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A model Item for displaying images.
*/
import UIKit

public class Item: Hashable {
    var image: UIImage!
    let url: URL!
    let identifier = UUID()

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public init(image: UIImage, url: URL) {
        self.image = image
        self.url = url
    }
}
