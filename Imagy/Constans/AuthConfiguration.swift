import Foundation

enum Constants {
    static let accessKey = "6FtiLyW-Rjye9Fg5nyKTH4EJvLVXJE0A95W8fq73Ubo"
    static let secretKey = "4LCEDznOGdd_Ou_BKcMvE6YnU15HvjegIOCZ5doM-0s"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let profileURLString = "https://api.unsplash.com/me"
    static let photosURL = "https://api.unsplash.com/photos"
    static let numberOfPicturesPerPage = "10"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            assertionFailure("Invalid base URL")
            return URL(string: "https://api.unsplash.com")! // Возвращаем дефолтный URL, даже если он некорректен
        }
        return url
    }()
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
}

