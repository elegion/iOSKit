# CocoaPods iOSKit specification
Pod::Spec.new do |s|
  s.name     = 'iOSKit'
  s.version  = '0.1.1'
  s.license  = 'Apache'
  s.summary  = 'Cocoa Touch Library of UI controls and elements'
  s.homepage = 'http://github.com/yariksmirnov/iOSKit'
  s.author   = { 'Yarik Smirnov' => 'yarikbonch@me.com' }

  # Specify the location from where the source should be retreived.
  #
  s.source   = { :git => 'git://github.com/yariksmirnov/iOSKit.git', :tag => '0.1.1'}
  # s.source   = { :svn => 'http://EXAMPLE/iOSKit/tags/1.0.0' }
  # s.source   = { :hg  => 'http://EXAMPLE/iOSKit', :revision => '1.0.0' }

  s.description = 'iOSKit is a Cocoa Touch UI library with easy-to-use custom controls, that needs no custom graphics for default usage.'

  # If this Pod runs only on iOS or OS X, then specify that with one of
  # these, or none if it runs on both platforms.
  #
   s.platform = :ios
  # s.platform = :osx

  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #
  # Alternatively, you can use the FileList class for even more control
  # over the selected files.
  # (See http://rake.rubyforge.org/classes/Rake/FileList.html.)
  #
  s.source_files = 'Kit', 'Kit/**/*.{h,m}'

  # A list of resources included with the Pod. These are copied into the
  # target bundle with a build phase script.
  #
  # Also allows the use of the FileList class like `source_files does.
  #
  # s.resource = "icon.png"
  # s.resources = "Resources/*.png"

  # A list of paths to remove after installing the Pod without the
  # `--no-clean' option. These can be examples, docs, and any other type
  # of files that are not needed to build the Pod.
  #
  # *NOTE*: Never remove license and README files.
  #
  # Also allows the use of the FileList class like `source_files does.
  #
   s.clean_path = "Examples"
  # s.clean_paths = "Examples", "doc"

  # Specify a list of frameworks that the application needs to link
  # against for this Pod to work.
  #
  # s.framework = 'SomeFramework'
   s.frameworks = 'QuartzCore', 'CoreGraphics', 'CoreText'

  # Specify a list of libraries that the application needs to link
  # against for this Pod to work.
  #
  # s.library = 'iconv'
  # s.libraries = 'iconv', 'xml2'

  # If this Pod uses ARC, specify it like so.
  #
  # s.requires_arc = true

  # If you need to specify any other build settings, add them to the
  # xcconfig hash.
  #
  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SOURCE_ROOT)/../../Build/' }

  # Finally, specify any Pods that this Pod depends on.
  #
  #s.dependency 'DrawingKit', :podspec => 'https://raw.github.com/yariksmirnov/DrawingKit/master/Specs/0.1.0/DrawingKit.podspec'
end
