<img src="https://ptsochantaris.github.io/trailer/CanProceedLogo.webp" alt="Logo" width=256 align="right">

# CanProceed

A small, tested, no-frills parser of `robots.txt` files in Swift.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptsochantaris%2Fcan-proceed%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ptsochantaris/can-proceed) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptsochantaris%2Fcan-proceed%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ptsochantaris/can-proceed)

Currently used in
- [Bloo](https://github.com/ptsochantaris/bloo)

## Usage

Full docs can be found [here](https://swiftpackageindex.com/ptsochantaris/can-proceed/1.0.0/documentation/canproceed)

A quick example:
```
    let exampleRobotsFileLocation = URL(string: "https://www.bbc.co.uk/robots.txt")!
    let robotsText = try! Data(contentsOf: exampleRobotsFileLocation)

    let check = CanProceed.parse(text)

    let canProceed = check.agent("ChatGPT-User", canProceedTo: "/news"))
    
    guard canProceed else {
        complain()
        return
    }
    
    // Also, `check.sitemaps` will contain any sitemaps in the robots.txt file
    ...
}
```

## License
Copyright (c) 2024 Paul Tsochantaris. Licensed under the MIT License, see LICENSE for details.
