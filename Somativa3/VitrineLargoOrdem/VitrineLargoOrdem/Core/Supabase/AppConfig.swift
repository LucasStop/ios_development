import Foundation

/// Configuração central do app. Lê valores em ordem de prioridade:
/// 1. Variáveis de ambiente (úteis para CI/TestFlight).
/// 2. Constantes default abaixo (preenchidas em commit do dev).
///
/// A Supabase publishable key (sb_publishable_...) substitui a antiga
/// anon key e é segura para uso em clientes — toda a proteção fica
/// no Row-Level Security das tabelas. NUNCA armazene aqui a
/// `sb_secret_...`; ela só pode viver em Edge Functions/server-side.
enum AppConfig {

    /// URL do projeto Supabase (https://<project-ref>.supabase.co).
    static var supabaseURL: URL {
        if let raw = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           let url = URL(string: raw) {
            return url
        }
        return URL(string: defaultSupabaseURL)!
    }

    /// Publishable API key (segura para client).
    static var supabaseKey: String {
        ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
            ?? defaultSupabaseKey
    }

    /// Indica se a configuração permite tentar conectar no Supabase.
    /// Mesmo com USE_SUPABASE=1, se a URL/key vier vazia caímos para
    /// a implementação local.
    static var useSupabase: Bool {
        let flag = ProcessInfo.processInfo.environment["USE_SUPABASE"] ?? defaultUseSupabaseFlag
        let habilitado = flag == "1" || flag.lowercased() == "true"
        return habilitado
            && !defaultSupabaseURL.isEmpty
            && !defaultSupabaseKey.isEmpty
    }

    // MARK: - Configuração padrão do desenvolvedor

    /// Project URL do Supabase compartilhado da Vitrine Largo da Ordem.
    /// Pode ser sobrescrito pela env var SUPABASE_URL em CI/TestFlight.
    private static let defaultSupabaseURL: String =
        "https://snlxpgdilvjrefzurdth.supabase.co"

    /// Publishable API key — sem privilégios além das policies RLS.
    /// Pode ser sobrescrito pela env var SUPABASE_ANON_KEY.
    private static let defaultSupabaseKey: String =
        "sb_publishable_zPYBDK3G14CgQBMSXbhG3w_7vYnHPyJ"

    /// Ligado por padrão; desligue setando USE_SUPABASE=0 (UITests
    /// usam essa flag para evitar bater na rede durante testes).
    private static let defaultUseSupabaseFlag: String = "1"
}
