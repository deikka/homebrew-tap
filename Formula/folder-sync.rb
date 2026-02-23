class FolderSync < Formula
  desc "Incremental folder backup to external drives with macOS menu bar app"
  homepage "https://github.com/deikka/folder-sync"
  url "https://github.com/deikka/folder-sync/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "e8ae0944d5618f988ee24201179e9f1fe469aebeb8282645124bb4e0cc6ea134"
  license "MIT"

  depends_on :macos

  def install
    # Compile Swift app
    system "swiftc", "-O", "-o", "FolderSync",
           "app/main.swift", "-framework", "Cocoa", "-framework", "ServiceManagement"

    # Generate app icon
    system "bash", "scripts/generate-icon.sh", buildpath.to_s

    # Create .app bundle
    app_dir = prefix/"FolderSync.app/Contents"
    (app_dir/"MacOS").mkpath
    (app_dir/"Resources").mkpath
    (app_dir/"MacOS").install "FolderSync"
    (app_dir/"Resources").install "AppIcon.icns"
    (app_dir).install "app/Info.plist"

    # Install scripts
    bin.install "scripts/backup-dev-apps.sh" => "folder-sync-backup"
    bin.install "scripts/install-app.sh" => "folder-sync-install-app"

    # Install LaunchAgent template
    (share/"folder-sync").install "scripts/com.klab.folder-sync.plist" => "launchagent.plist"
  end

  def post_install
    # Create data directories
    (var/"folder-sync").mkpath
  end

  def caveats
    <<~EOS
      Para empezar:

      1. Hacer visible en Spotlight/Raycast (ejecutar una vez):
           folder-sync-install-app

      2. Abrir la app:
           open -a FolderSync
           Raycast/Spotlight: buscar "Folder Sync"

      3. Configurar origen, destino y horario desde "Ajustes..." en el menu

      4. macOS pedira permisos de acceso al volumen externo la primera vez

      Backup manual por terminal:
        folder-sync-backup          # incremental
        folder-sync-backup --full   # copia completa
    EOS
  end
end
