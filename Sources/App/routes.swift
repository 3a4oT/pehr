import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let landingController = LandingController()
    let slackAuthController = SlackAuthController()
    let reportController = ReportController()
    
    router.get("", use: landingController.index)
    router.group("report") { subRouter in
        subRouter.get("/", use: reportController.index)
        subRouter.post("/status", use: reportController.report)
    }
    router.group("slack") { (subRouter) in
        subRouter.get("/oauth/authorize", use: slackAuthController.oauthAuthorize)
    }
}
