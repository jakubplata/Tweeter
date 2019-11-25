# Package

version       = "0.1.0"
author        = "Jakub Plata"
description   = "A simple Twitter clone developed in Nim in Action."
license       = "MIT"
srcDir        = "src"

bin = @["tweeter"]
skipExt = @["nim"]


# Dependencies

requires "nim >= 1.0.2", "jester >= 0.0.1"
