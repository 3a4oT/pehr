import Vapor

func healthCheck(task: RepeatedTask) {
    do {
        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        // Connect a new client to the supplied hostname.
        let client: HTTPClient = try HTTPClient.connect(hostname: "qamaster.eng.hotschedules.com",
                                                        on: worker).wait()
        // Create an HTTP request: GET /
        let httpReq = HTTPRequest(method: .HEAD, url: "/")
        // Send the HTTP request, fetching a response
        let httpRes: HTTPResponse = try client.send(httpReq).wait()
        let isAlive: Bool = (httpRes.status.code != 503) ? true : false;
        try report(status: EnvStatus(check: Date(), isAlive: isAlive), on: worker)
    } catch {
        print("task was canceled\n \(error)")
        task.cancel()
    }
}

private func report(status: EnvStatus, on worker: EventLoopGroup) throws {
    // Connect a new client to the supplied hostname.
    let client: HTTPClient = try HTTPClient.connect(scheme: .http,
                                                    hostname: "localhost",
                                                    port: 8080,
                                                    connectTimeout: TimeAmount.seconds(5),
                                                    on: worker,
                                                    onError: {(error) in print(error)}).wait()
    var reportReq = HTTPRequest(method: .POST, url: "/report/status")
    reportReq.body = try HTTPBody(data: JSONEncoder().encode(status))
    reportReq.contentType = .json
    let httpRes: HTTPResponse = try client.send(reportReq).wait()
    print("Finished reportting status with \(httpRes.status.code)")
}

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    app.next().scheduleRepeatedTask(initialDelay: TimeAmount.seconds(5),
                                    delay: TimeAmount.seconds(10),
                                    healthCheck)
}
