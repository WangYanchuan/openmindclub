import Cocoa

let size = 1024
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

let ctx = NSGraphicsContext.current!.cgContext
let rect = CGRect(x: 0, y: 0, width: size, height: size)

// 圆角矩形（macOS Big Sur 风格圆角约 22.5%）
let radius: CGFloat = CGFloat(size) * 0.2237
let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
path.addClip()

// 渐变背景（深蓝紫 -> 亮蓝）
let colors = [
    NSColor(calibratedRed: 0.29, green: 0.24, blue: 0.72, alpha: 1).cgColor,
    NSColor(calibratedRed: 0.16, green: 0.47, blue: 0.96, alpha: 1).cgColor
]
let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                      colors: colors as CFArray,
                      locations: [0, 1])!
ctx.drawLinearGradient(grad,
                       start: CGPoint(x: 0, y: size),
                       end: CGPoint(x: size, y: 0),
                       options: [])

// 顶部高光
let hi = NSColor(white: 1, alpha: 0.12)
hi.setFill()
let hiPath = NSBezierPath(ovalIn: CGRect(x: -CGFloat(size)*0.2, y: CGFloat(size)*0.55,
                                         width: CGFloat(size)*1.4, height: CGFloat(size)*0.8))
hiPath.fill()

// 文字 "元学"
let text = "元学"
let para = NSMutableParagraphStyle()
para.alignment = .center
let font = NSFont.systemFont(ofSize: CGFloat(size) * 0.4, weight: .bold)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white,
    .paragraphStyle: para
]
let attr = NSAttributedString(string: text, attributes: attrs)
let textSize = attr.size()
let textRect = CGRect(x: 0,
                      y: (CGFloat(size) - textSize.height) / 2,
                      width: CGFloat(size),
                      height: textSize.height)
attr.draw(in: textRect)

img.unlockFocus()

// 保存 PNG
guard let tiff = img.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    print("failed to render")
    exit(1)
}
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
