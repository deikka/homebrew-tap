class FolderSync < Formula
  desc "Incremental folder backup to external drives with macOS menu bar app"
  homepage "https://github.com/deikka/folder-sync"
  url "https://github.com/deikka/folder-sync/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "5301b2ceb95c90e707f5e01e6395a0c88080dfdbe85ca8fc9609e49b50884b44"
  license "MIT"

  depends_on :macos

  def install
    # Compile Swift app
    system "swiftc", "-O", "-o", "BackupMenu",
           "app/main.swift", "-framework", "Cocoa"

    # Generate app icon
    system "bash", "scripts/generate-icon.sh", buildpath.to_s

    # Create .app bundle
    app_dir = prefix/"BackupMenu.app/Contents"
    (app_dir/"MacOS").mkpath
    (app_dir/"Resources").mkpath
    (app_dir/"MacOS").install "BackupMenu"
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
           open -a BackupMenu
           Raycast/Spotlight: buscar "BackupMenu"

      3. Configurar origen, destino y horario desde "Ajustes..." en el menu

      4. Para arranque automatico con el sistema:
           osascript -e 'tell application "System Events" to make login item at end with properties {path:"#{Dir.home}/Applications/BackupMenu.app", hidden:true}'

      5. macOS pedira permisos de acceso al volumen externo la primera vez

      Backup manual por terminal:
        folder-sync-backup          # incremental
        folder-sync-backup --full   # copia completa
    EOS
  end
end
