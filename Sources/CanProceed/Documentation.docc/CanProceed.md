# ``CanProceed``

A small, tested, no-frills parser of `robots.txt` files in Swift.

You first need a `String` with the contents of a robots.txt file. For example:
```
let exampleRobotsFileLocation = URL(string: "https://www.bbc.co.uk/robots.txt")!
let robotsText = try! Data(contentsOf: exampleRobotsFileLocation)
```

Create an instance of the ``CanProceed`` checker by providing it with that string:
```
let check = CanProceed.parse(robotsText)
```

You can then ask it if an agent is allowed or not allowed. You can use whatever name
your client prefers here. If the name of the agent doesn't exist in the robots.txt file
the rules will be evaluated against the `*` agent.
```
let shouldProceed = check.agent("MyAgent", canProceedTo: "/news"))

guard shouldProceed else {
    complain()
    return
}

...

check.sitemaps   // contains any sitemaps
check.crawlDelay // provides any crawl delay setting
check.sitemps    // contains any XML sitemaps
```

There are also properties and initialisers to allow more fine grained control or construction of the checker.
