
class CreateFlutterApp < Formula
    desc "A script to quickly set up a new Flutter project"
    homepage "https://github.com/almohad/homebrew-flutter-tools"
    url "https://github.com/almohad/homebrew-flutter-tools/archive/refs/tags/v1.0.0.tar.gz"
    sha256 "REPLACE_WITH_SHA256_CHECKSUM"
    version "1.0.0"

    def install
      bin.install "bin/create_flutter_app"
    end

    test do
      system "#{bin}/create_flutter_app", "-h"
    end
  end
