import Foundation

public func trace(_ message: String? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
    let name = ((file as NSString).lastPathComponent as NSString).deletingPathExtension

    if let message = message {
        NSLog("\(name):\(line): \(function): %@", message)
    } else {
        NSLog("\(name):\(line): \(function)")
    }
}
