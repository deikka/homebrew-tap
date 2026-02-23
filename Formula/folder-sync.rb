class FolderSync < Formula
  desc "Incremental folder backup to external drives with macOS menu bar app"
  homepage "https://github.com/deikka/folder-sync"
  url "https://github.com/deikka/folder-sync/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "e9edee80753b6b9e188b56d831720f91d866e4650cb5a7a687a41cd56327a434"
  license "MIT"

  depends_on :macos

  def install
    # Compile Swift app
    system "swiftc", "-O", "-o", "BackupMenu",
           "app/main.swift", "-framework", "Cocoa"

    # Create .app bundle
    app_dir = prefix/"BackupMenu.app/Contents"
    (app_dir/"MacOS").mkpath
    (app_dir/"Resources").mkpath
    (app_dir/"MacOS").install "BackupMenu"
    (app_dir).install "app/Info.plist"

    # Install backup script
    bin.install "scripts/backup-dev-apps.sh" => "folder-sync-backup"

    # Install LaunchAgent template
    (share/"folder-sync").install "scripts/com.klab.folder-sync.plist" => "launchagent.plist"
  end

  def post_install
    # Create data directories
    (var/"folder-sync").mkpath

    # Symlink to ~/Applications for Spotlight/Launchpad/open -a
    user_apps = Pathname.new(Dir.home)/"Applications"
    user_apps.mkpath
    app_link = user_apps/"BackupMenu.app"
    app_link.unlink if app_link.symlink? || app_link.exist?
    app_link.make_symlink(opt_prefix/"BackupMenu.app")
  end

  def caveats
    <<~EOS
      Para empezar:

      1. Abrir la app (cualquiera de estas formas):
           open -a BackupMenu
           Spotlight: Cmd+Space → "BackupMenu"

      2. Configurar origen, destino y horario desde "Ajustes..." en el menu

      3. Para arranque automatico con el sistema:
           osascript -e 'tell application "System Events" to make login item at end with properties {path:"#{Dir.home}/Applications/BackupMenu.app", hidden:true}'

      4. macOS pedira permisos de acceso al volumen externo la primera vez

      Backup manual por terminal:
        folder-sync-backup          # incremental
        folder-sync-backup --full   # copia completa
    EOS
  end
end
