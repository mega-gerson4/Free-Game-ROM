import SwiftUI
import AppKit
import Foundation

struct GameLink: Identifiable {
    let id: Int
    let group: String
    let name: String
    let url: String

    static func load() -> [GameLink] {
        guard let path = Bundle.main.path(forResource: "catalog", ofType: "tsv"),
              let text = try? String(contentsOfFile: path, encoding: .utf8) else { return [] }
        return text.components(separatedBy: .newlines).dropFirst().enumerated().compactMap { index, row in
            let fields = row.components(separatedBy: "\t")
            guard fields.count == 3 else { return nil }
            return GameLink(id: index, group: fields[0], name: fields[1], url: fields[2])
        }
    }
}

struct CopyRecord: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let name: String
    let url: String
}

final class DataSense: ObservableObject {
    @Published var records: [CopyRecord] = []
    @Published var chosenLanguage: String = "auto"
    private let directory: URL
    private var historyFile: URL { directory.appendingPathComponent("history.json") }
    private var languageFile: URL { directory.appendingPathComponent("language.txt") }

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directory = base.appendingPathComponent("TrunGameFreeMega/DataSense", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if let data = try? Data(contentsOf: historyFile),
           let loaded = try? JSONDecoder().decode([CopyRecord].self, from: data) { records = loaded }
        if let stored = try? String(contentsOf: languageFile, encoding: .utf8),
           ["auto", "en", "pt", "es", "fr", "de", "ja"].contains(stored.trimmingCharacters(in: .whitespacesAndNewlines)) {
            chosenLanguage = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    func saveCopy(_ link: GameLink) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link.url, forType: .string)
        records.append(CopyRecord(date: Date(), name: link.name, url: link.url))
        if records.count > 300 { records.removeFirst(records.count - 300) }
        persist()
    }
    func clearHistory() { records.removeAll(); persist() }
    func saveLanguage() { try? chosenLanguage.write(to: languageFile, atomically: true, encoding: .utf8) }
    private func persist() {
        if let bytes = try? JSONEncoder().encode(records) {
            try? bytes.write(to: historyFile, options: .atomic)
        }
    }
}

struct TrunButton: View {
    let title: String
    var emphasized: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 16).frame(height: 34)
                .foregroundColor(.white)
                .background(emphasized ? Color(red: 0.91, green: 0.25, blue: 0.37) : Color(red: 0.22, green: 0.15, blue: 0.22))
                .cornerRadius(8)
        }.buttonStyle(.plain)
    }
}

struct MainView: View {
    @StateObject private var data = DataSense()
    @State private var query = ""
    @State private var group = "All"
    @State private var showHistory = false
    @State private var showCreators = false
    @State private var status = "Ready"
    private let links = GameLink.load()
    private let groups = ["All", "Nintendo", "Sony", "Microsoft", "Sega", "Capcom", "Commodore"]
    private let bg = Color(red: 0.064, green: 0.051, blue: 0.078)
    private let panel = Color(red: 0.14, green: 0.097, blue: 0.14)
    private let accent = Color(red: 0.94, green: 0.29, blue: 0.39)

    private var language: String {
        if data.chosenLanguage != "auto" { return data.chosenLanguage }
        let v = Locale.current.languageCode ?? "en"
        return ["en", "pt", "es", "fr", "de", "ja"].contains(v) ? v : "en"
    }
    private func tr(_ key: String) -> String {
        let text: [String: [String: String]] = [
            "en": ["all":"All games", "search":"Search consoles or links", "copy":"COPY", "open":"OPEN", "history":"HISTORY", "clear":"Clear history", "creators":"CREATORS", "copied":"Copied to clipboard", "confirm":"Are you sure?"],
            "pt": ["all":"Todos", "search":"Buscar consoles ou links", "copy":"COPIAR", "open":"ABRIR", "history":"HISTÓRICO", "clear":"Apagar histórico", "creators":"CRIADORES", "copied":"Copiado para a área de transferência", "confirm":"Tem certeza?"],
            "es": ["all":"Todos", "search":"Buscar consolas o enlaces", "copy":"COPIAR", "open":"ABRIR", "history":"HISTORIAL", "clear":"Borrar historial", "creators":"CREADORES", "copied":"Copiado al portapapeles", "confirm":"¿Estás seguro?"],
            "fr": ["all":"Tous", "search":"Rechercher des liens", "copy":"COPIER", "open":"OUVRIR", "history":"HISTORIQUE", "clear":"Effacer", "creators":"CRÉATEURS", "copied":"Lien copié", "confirm":"Confirmer ?"],
            "de": ["all":"Alle", "search":"Links suchen", "copy":"KOPIEREN", "open":"ÖFFNEN", "history":"VERLAUF", "clear":"Verlauf löschen", "creators":"ERSTELLER", "copied":"Kopiert", "confirm":"Sicher?"],
            "ja": ["all":"すべて", "search":"リンクを検索", "copy":"コピー", "open":"開く", "history":"履歴", "clear":"履歴を消去", "creators":"制作者", "copied":"コピーしました", "confirm":"削除しますか？"]
        ]
        return text[language]?[key] ?? text["en"]?[key] ?? key
    }
    private var filtered: [GameLink] {
        links.filter { link in
            (group == "All" || link.group == group) &&
            (query.isEmpty || "\(link.name) \(link.url) \(link.group)".localizedCaseInsensitiveContains(query))
        }
    }
    private var logo: NSImage? {
        guard let path = Bundle.main.path(forResource: "MEGA-Logo", ofType: "png") else { return nil }
        return NSImage(contentsOfFile: path)
    }
    private var creators: [String] {
        guard let path = Bundle.main.path(forResource: "credits", ofType: "txt"),
              let file = try? String(contentsOfFile: path, encoding: .utf8) else { return [] }
        return file.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 22) {
                if let img = logo {
                    Image(nsImage: img).resizable().scaledToFit().frame(width: 76, height: 76)
                }
                VStack(alignment: .leading, spacing: 7) {
                    Text("TRUN GAME FREE MEGA").font(.system(size: 28, weight: .heavy)).foregroundColor(.white)
                    Text("RED EDITION  /  2.2  /  NATIVE APP").font(.system(size: 11, weight: .bold)).foregroundColor(accent)
                }
                Spacer()
                TrunButton(title: tr("creators")) { showCreators = true }
            }
            .padding(.horizontal, 28).frame(height: 125).background(panel)
            Rectangle().fill(accent).frame(height: 3)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("LIBRARY").font(.system(size: 11, weight: .bold)).foregroundColor(accent).padding(.bottom, 12)
                    ForEach(groups, id: \.self) { g in
                        TrunButton(title: g == "All" ? tr("all") : g, emphasized: group == g) { group = g }
                    }
                    Spacer()
                    Text(status).font(.system(size: 10)).foregroundColor(.white.opacity(0.72)).lineLimit(3)
                }.frame(width: 190, alignment: .leading).padding(20).background(panel)
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField(tr("search"), text: $query)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14))
                        Picker("", selection: $data.chosenLanguage) {
                            Text("Auto").tag("auto"); Text("English").tag("en")
                            Text("Português").tag("pt"); Text("Español").tag("es")
                            Text("Français").tag("fr"); Text("Deutsch").tag("de")
                            Text("日本語").tag("ja")
                        }.frame(width: 130).onChange(of: data.chosenLanguage) { _ in data.saveLanguage() }
                        TrunButton(title: tr("history"), emphasized: true) { showHistory = true }
                    }
                    Text("\(filtered.count) / \(links.count) LINKS").font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6)).frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView {
                        LazyVStack(spacing: 9) {
                            ForEach(filtered) { link in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(link.group.uppercased()).foregroundColor(accent).font(.system(size: 10, weight: .bold))
                                        Text(link.name).font(.system(size: 13, weight: .medium)).foregroundColor(.white).lineLimit(2)
                                    }
                                    Spacer(minLength: 12)
                                    TrunButton(title: tr("copy"), emphasized: true) {
                                        data.saveCopy(link); status = "\(tr("copied")): \(link.name)"
                                    }
                                    TrunButton(title: tr("open")) {
                                        if let url = URL(string: link.url) { NSWorkspace.shared.open(url) }
                                    }
                                }.padding(13).background(panel).cornerRadius(10)
                            }
                        }.padding(.bottom, 20)
                    }
                }.padding(23).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(bg).frame(minWidth: 970, minHeight: 670)
        .sheet(isPresented: $showHistory) {
            VStack(alignment: .leading, spacing: 16) {
                Text("DataSense — \(tr("history"))").font(.title2).bold()
                List(data.records.reversed()) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name).font(.headline)
                        Text(item.url).font(.caption)
                        Text(item.date, style: .date).font(.caption2)
                    }
                }
                HStack {
                    Spacer()
                    TrunButton(title: tr("clear"), emphasized: true) { data.clearHistory() }
                    TrunButton(title: "CLOSE") { showHistory = false }
                }
            }.padding(25).frame(width: 620, height: 460)
        }
        .sheet(isPresented: $showCreators) {
            VStack(spacing: 14) {
                Text("CREATED BY").font(.title2).bold()
                ScrollView {
                    ForEach(creators, id: \.self) { name in Text("• \(name)").frame(maxWidth: .infinity, alignment: .leading) }
                }
                TrunButton(title: "CLOSE") { showCreators = false }
            }.padding(25).frame(width: 370, height: 470)
        }
    }
}

@main
struct TrunGameFreeMegaApp: App {
    var body: some Scene {
        WindowGroup { MainView() }
    }
}
