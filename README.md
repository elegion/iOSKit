Introduction
=========================

iOSKit is a Cocoa Touch UI library with **easy-to-use** custom controls, that needs no custom graphics for default usage.


Installation
=========================

Quick Start
-----------

1. Add Git submodule to your project: `git submodule add git://github.com/yariksmirnov/iOSKit.git iOSKit`
1. Add cross-project reference by dragging **iOSKit.xcodeproj** to your project
1. Open build settings editor for your project
1. Add the following **Header Search Paths** (including the quotes): `"$(SOURCE_ROOT)/iOSKit/Build"`
1. Open target settings editor for the target you want to link iOSKit into
1. Add direct dependency on the **iOSKit** aggregate target
1. Link against required frameworks:
    1. **CoreGraphics.framework**
    1. **CoreText.framework**
1. Link against iOSKit:
    1. **libiOSKit.a**
1. Import the iOSKit headers via `#import <iOSKit/iOSKit.h>`
1. Build the project to verify installation is successful.

Contributing
-------------------------

Forks, patches and other feedback are always welcome.

Credits
-------------------------

iOSKit is supported by [Yarik Smirnov](http://facebook.com/yariksmirnov) and [Mobile Team of e-Legion](http://e-legion.com)