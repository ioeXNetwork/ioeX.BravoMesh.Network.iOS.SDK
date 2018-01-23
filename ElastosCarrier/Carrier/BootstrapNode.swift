import Foundation;

@objc(ELABootstrapNode)
public class BootstrapNode: NSObject {

    private var _ipv4       : String?
    private var _ipv6       : String?
    private var _port       : String?
    private var _publicKey  : String?

    internal override init() {
        super.init()
    }

    /**
        Ipv4 address.
     */
    public internal(set) var ipv4: String?  {
        set {
            _ipv4 = newValue
        }
        get {
            return _ipv4
        }
    }

    /**
        Ipv6 address.
     */
    public internal(set) var ipv6: String?  {
        set {
            _ipv6 = newValue
        }
        get {
            return _ipv6
        }
    }

    /**
        Port.
     */
    public internal(set) var port: String?  {
        set {
            _port = newValue
        }
        get {
            return _port
        }
    }

    /**
        public address.
     */
    public internal(set) var publicKey: String?  {
        set {
            _publicKey = newValue
        }
        get {
            return _publicKey
        }
    }

    internal static func format(_ node: BootstrapNode) -> String {
        return String(format: "ipv4[%@], ipv6[%@], port[%@], publicKey[%@]",
                      String.toHardString(node.ipv4),
                      String.toHardString(node.ipv6),
                      String.toHardString(node.port),
                      String.toHardString(node.publicKey))
    }

    public override var description: String {
        return BootstrapNode.format(self)
    }
}

internal func convertBootstrapNodesToCBootstrapNodes(_ nodes: [BootstrapNode]) -> (UnsafeMutablePointer<[CBootstrapNode]>?, Int) {
    var cNodes: UnsafeMutablePointer<[CBootstrapNode]>?

    cNodes = UnsafeMutablePointer<[CBootstrapNode]>.allocate(capacity: nodes.count)
    if cNodes == nil {
        return (nil, 0)
    }

    for (index, node) in nodes.enumerated() {
        var cNode: CBootstrapNode = cNodes!.pointee[index]

        node.ipv4?.withCString { (ipv4) in
            cNode.ipv4 = UnsafePointer<Int8>(strdup(ipv4))
        }
        node.ipv6?.withCString { (ipv6) in
            cNode.ipv6 = UnsafePointer<Int8>(strdup(ipv6));
        }
        node.port?.withCString { (port) in
            cNode.port = UnsafePointer<Int8>(strdup(port));
        }
        node.publicKey?.withCString { (publicKey) in
            cNode.public_key = UnsafePointer<Int8>(strdup(publicKey));
        }
    }

    return (cNodes, nodes.count)
}

internal func cleanupCBootstrap(_ cNodes: UnsafePointer<[CBootstrapNode]>, _ count: Int) -> Void {

    for index in 0..<count {
        let cNode: CBootstrapNode = cNodes.pointee[index]

        if cNode.ipv4 != nil {
            free(UnsafeMutablePointer<Int8>(mutating: cNode.ipv4))
        }
        if cNode.ipv6 != nil {
            free(UnsafeMutablePointer<Int8>(mutating: cNode.ipv6))
        }
        if cNode.port != nil {
            free(UnsafeMutablePointer<Int8>(mutating: cNode.port))
        }
        if cNode.public_key != nil {
            free(UnsafeMutablePointer<Int8>(mutating: cNode.public_key))
        }
    }
}