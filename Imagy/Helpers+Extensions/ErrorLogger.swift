extension Error {
    func log(serviceName: String, error: Error, additionalInfo: String? = nil) {
        var message = "[\(serviceName)]: \(error)"
        
        if let additionalInfo = additionalInfo {
            message += " - \(additionalInfo)"
        }
        
        print(message)
    }
}
