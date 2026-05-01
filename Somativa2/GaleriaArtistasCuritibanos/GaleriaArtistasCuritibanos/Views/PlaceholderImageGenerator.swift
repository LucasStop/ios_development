import UIKit

enum PlaceholderImageGenerator {

    static func image(for obra: ObraDeArte, size: CGSize) -> UIImage {
        let cores = coresPara(estilo: obra.estilo)
        let symbolName = simboloPara(estilo: obra.estilo)
        return render(size: size, cores: cores, symbolName: symbolName, seed: obra.titulo.hashValue)
    }

    private static func coresPara(estilo: String) -> (UIColor, UIColor) {
        switch estilo.lowercased() {
        case "gravura":
            return (UIColor(red: 0.30, green: 0.25, blue: 0.20, alpha: 1.0),
                    UIColor(red: 0.65, green: 0.55, blue: 0.45, alpha: 1.0))
        case "pintura":
            return (UIColor(red: 0.85, green: 0.45, blue: 0.30, alpha: 1.0),
                    UIColor(red: 0.95, green: 0.75, blue: 0.45, alpha: 1.0))
        case "escultura":
            return (UIColor(red: 0.30, green: 0.40, blue: 0.55, alpha: 1.0),
                    UIColor(red: 0.55, green: 0.70, blue: 0.85, alpha: 1.0))
        default:
            return (UIColor.systemGray, UIColor.systemGray3)
        }
    }

    private static func simboloPara(estilo: String) -> String {
        switch estilo.lowercased() {
        case "gravura": return "pencil.tip"
        case "pintura": return "paintbrush.fill"
        case "escultura": return "cube.fill"
        default: return "photo.artframe"
        }
    }

    private static func render(size: CGSize,
                               cores: (UIColor, UIColor),
                               symbolName: String,
                               seed: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradientColors = [cores.0.cgColor, cores.1.cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0.0, 1.0])!

            let angle = CGFloat((abs(seed) % 360)) * .pi / 180
            let startPoint = CGPoint(x: size.width * 0.5 - cos(angle) * size.width * 0.5,
                                     y: size.height * 0.5 - sin(angle) * size.height * 0.5)
            let endPoint = CGPoint(x: size.width * 0.5 + cos(angle) * size.width * 0.5,
                                   y: size.height * 0.5 + sin(angle) * size.height * 0.5)

            cgContext.drawLinearGradient(gradient,
                                         start: startPoint,
                                         end: endPoint,
                                         options: [])

            let symbolSize = min(size.width, size.height) * 0.35
            let config = UIImage.SymbolConfiguration(pointSize: symbolSize, weight: .regular)
            if let symbol = UIImage(systemName: symbolName, withConfiguration: config) {
                let tinted = symbol.withTintColor(.white.withAlphaComponent(0.85), renderingMode: .alwaysOriginal)
                let rect = CGRect(
                    x: (size.width - tinted.size.width) / 2,
                    y: (size.height - tinted.size.height) / 2,
                    width: tinted.size.width,
                    height: tinted.size.height
                )
                tinted.draw(in: rect)
            }
        }
    }
}
