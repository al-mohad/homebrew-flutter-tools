class CreateFlutterApp < Formula
    desc "🚀 A script to quickly set up a new Flutter project"
    homepage "https://github.com/al-mohad/homebrew-flutter-tools"
    url "https://github.com/al-mohad/flutter-tools/releases/download/v1.0.0/create-flutter-app-1.0.0.tar.gz"
    sha256 "b09b3bf4cdad6db0af741d08540a656ead9aed2772d9954091ec242926e43dfc"
    version "1.0.0"

    def install
      bin.install "create_flutter_app.sh"
    end

    test do
      system "#{bin}/create_flutter_app", "-h"
    end
  end
