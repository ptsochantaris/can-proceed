<img src="https://ptsochantaris.github.io/trailer/CanProceedLogo.webp" alt="Logo" width=256 align="right">

# CanProceed

A small, tested, no-frills parser of `robots.txt` files in Swift.

Currently used in
- [Bloo](https://github.com/ptsochantaris/bloo)

Full docs [can be found here](https://swiftpackageindex.com/ptsochantaris/can-proceed/1.0.0/documentation/canproceed)

## Quick example

```
let exampleRobotsFileLocation = URL(string: "https://www.bbc.co.uk/robots.txt")!
let robotsData = try! Data(contentsOf: exampleRobotsFileLocation)
let robotsText = String(data: robotsData, encoding: .utf8)!

let check = CanProceed.parse(robotsText)

let shouldProceed = check.agent("ChatGPT-User", canProceedTo: "/news"))

guard shouldProceed else {
    complain()
    return
}

...

check.sitemaps   // contains any sitemaps
check.crawlDelay // provides any crawl delay setting
check.sitemps    // contains any XML sitemaps
```

## License
Copyright (c) 2024 Paul Tsochantaris. Licensed under the MIT License, see LICENSE for details.
