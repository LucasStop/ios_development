# ADR-0001: Decisões de Stack e Arquitetura para Evolução E-commerce

**Status:** Aceito
**Data:** 2026-06-07
**Decidido por:** Lucas Stopinski da Silva, Lucas Bruno e Silva
**Contexto:** PLANO_ECOMMERCE.md seção 3 — gate antes da primeira linha de código nova

---

## Contexto

O projeto somativo SwiftUI `VitrineLargoOrdem` será evoluído para um marketplace iOS completo (Feira do Largo da Ordem) ao longo de ~24 semanas distribuídas em 4 fases (MVP / V1 / V2 / V3). Antes de qualquer refactor ou nova feature, é necessário fechar as 14 decisões técnicas estratégicas mapeadas no plano, porque cada uma reescreve grandes pedaços do roadmap. Este ADR registra as decisões com alternativas consideradas, justificativa e implicações de longo prazo.

---

## Decisões

### 1. Backend / BaaS

**Decisão:** Supabase (Postgres + Auth + Storage + Edge Functions)

**Alternativas consideradas:**
- Firebase (Firestore + Auth + Functions)
- Backend custom em Swift Vapor
- AWS Amplify

**Justificativa:** Postgres relacional é honesto para o domínio (pedidos têm itens, usuários têm endereços — N:M legítimo). Row-Level Security cobre autorização sem código no client. Open-source elimina lock-in. Supabase Studio resolve admin sem precisar de portal web próprio na V1.

**Consequências:** Modelagem relacional obriga DTO/Mapper layer (decisão 9). Edge Functions são Deno (TypeScript), não Swift — segundo runtime no time.

---

### 2. Persistência local

**Decisão:** SwiftData (`@Model`) com versionamento explícito de schema

**Alternativas consideradas:**
- Core Data + wrapper SwiftUI
- Realm (MongoDB)
- GRDB (SQLite) + Codable

**Justificativa:** iOS 17+ já é base do projeto. Sintaxe `@Model` reduz boilerplate. SwiftData migrations ainda têm bugs em produção — mitigado encapsulando tudo atrás de `Repository` para poder trocar por Core Data sem mexer nas Views.

**Consequências:** Toda mudança de schema precisa de migration testada em CI. Modelos SwiftData não atravessam camadas (decisão 9 — DTO separados).

---

### 3. Arquitetura de estado

**Decisão:** `@Observable` (iOS 17 Observation framework) + Repository + Service, MVVM leve

**Alternativas consideradas:**
- TCA (Composable Architecture)
- ObservableObject clássico + @Published
- Coordinators barrocos

**Justificativa:** TCA é overkill para equipe de 2 devs. `@Observable` é a aposta da Apple (iOS 17+), tem performance melhor que `ObservableObject` e reduz boilerplate. Coordinators só serão introduzidos na V2 se navegação ficar profunda.

**Consequências:** Refactor leve da `VitrineViewModel` atual (de `ObservableObject` para `@Observable`). Documentação Apple ainda escassa para edge cases.

---

### 4. Cache de imagens

**Decisão:** Nuke (`LazyImage`)

**Alternativas consideradas:**
- Kingfisher
- AsyncImage puro + custom cache
- SDWebImage

**Justificativa:** Nuke tem integração SwiftUI nativa via `LazyImage`, API moderna async/await e footprint menor (~300KB). Kingfisher carrega legado UIKit. AsyncImage puro perde em grids grandes por falta de prefetching.

**Consequências:** Nova dependência via SPM. Migração do código atual de SwiftSymbols/gradientes para `LazyImage` quando trocarmos para fotos reais.

---

### 5. PSP (Payment Service Provider)

**Decisão:** Mercado Pago iOS SDK (V2+)

**Alternativas consideradas:**
- Stripe (PaymentSheet)
- Pagar.me
- Iugu
- Adyen

**Justificativa:** Pix nativo é essencial no Brasil (Stripe não suporta bem). Mercado Pago tem split payment (decisão 14), antifraude integrado, custo competitivo e onboarding amigável para pequenos comerciantes. Pagar.me tem UX SDK fraca; Adyen é overkill.

**Consequências:** SDK proprietário. Apple Pay via PassKit integrada ao Mercado Pago. Webhook server-side obrigatório (Supabase Edge Functions).

---

### 6. Autenticação

**Decisão:** Sign in with Apple + Supabase Auth (e-mail/senha como fallback)

**Alternativas consideradas:**
- Apenas Sign in with Apple
- Google/Facebook OAuth desde MVP
- Magic links (passwordless)

**Justificativa:** Sign in with Apple cumpre Guideline 4.8 da App Store (obrigatório quando há login social). E-mail/senha cobre usuários sem Apple ID e oferece portabilidade. Google/Facebook ficam para V3 se houver demanda real.

**Consequências:** Dois fluxos de auth a manter. Account linking quando V3 chegar (mesmo e-mail = mesmo user).

---

### 7. Analytics

**Decisão:** TelemetryDeck

**Alternativas consideradas:**
- Firebase Analytics
- Mixpanel
- PostHog
- Amplitude

**Justificativa:** Privacy-first, sem PII, sem cookies, sem prompt ATT obrigatório. Alinhado a LGPD. Open-source. Custo gratuito até 5k eventos/dia (suficiente para MVP/V1). Mixpanel e Firebase exigem ATT prompt.

**Consequências:** Funis menos sofisticados que Mixpanel; aceitável para o estágio atual. Pode coexistir com PostHog para A/B testing em V3.

---

### 8. Crash reporting + logs

**Decisão:** Sentry + OSLog

**Alternativas consideradas:**
- Firebase Crashlytics
- Bugsnag
- Apenas OSLog

**Justificativa:** Sentry tem captura SwiftUI-aware (view hierarchy em crashes), breadcrumbs e erros não-fatais. Open-source friendly. OSLog para logs estruturados locais (privacidade do usuário). Crashlytics implicaria carregar Firebase só para isso.

**Consequências:** Dependência paga após volume (free tier ~5k events/mês). Setup de Source Maps para builds de release.

---

### 9. DTO ↔ Domain ↔ SwiftData

**Decisão:** Camadas separadas com `Mapper` explícito

**Alternativas consideradas:**
- Usar modelos SwiftData diretamente em toda a stack
- Codable nos `@Model` e enviar para API

**Justificativa:** Modelo de API muda independentemente do schema de DB e do modelo de domínio. Isolá-los evita refactor em cascata. Padrão clássico de Clean Architecture aplicado pragmaticamente.

**Consequências:** Boilerplate inicial maior (3 representações + mappers). Compensa a partir da V1 quando o backend evolui.

---

### 10. Navegação

**Decisão:** `NavigationStack` tipado com enum `Route` por feature

**Alternativas consideradas:**
- Coordinator centralizado
- Router único da app inteira
- NavigationLink direto sem path

**Justificativa:** `NavigationPath` permite deep linking, retorno programático e testes. Cada feature define seu enum `Route` (ex.: `CheckoutRoute.endereco`, `.pagamento`, `.confirmacao`). Suporta push notifications e universal links sem Coordinator central.

**Consequências:** Cada feature responsável pelo seu router. Refactor das navegações atuais (`NavigationLink` simples) na V1.

---

### 11. Modularização

**Decisão:** Monolito Xcode com pastas por feature; SPM packages só se ultrapassar 30k LOC

**Alternativas consideradas:**
- SPM packages desde o início (Catálogo, Checkout, Identidade)
- Monolito sem separação por feature
- Multi-target Xcode

**Justificativa:** SPM adiciona fricção para 2 devs (build times, dependências). Pastas `Features/Checkout/`, `Features/Catalogo/` antecipam split futuro sem custo agora.

**Consequências:** Disciplina manual para não atravessar fronteiras de feature. Refactor para SPM quando equipe ou LOC justificarem.

---

### 12. Testes

**Decisão:** Swift Testing (`@Test`) para unit, XCUITest para smoke

**Alternativas consideradas:**
- Apenas XCTest
- Quick + Nimble
- ViewInspector para SwiftUI

**Justificativa:** Swift Testing é a aposta da Apple (Xcode 16+), tem melhor ergonomia (parametrização, async, traits). XCUITest já está funcionando (10 testes de a11y passando) e fica como smoke regression.

**Consequências:** Migração gradual dos testes unitários novos para Swift Testing. XCUITest permanece para fluxos críticos.

---

### 13. CI/CD

**Decisão:** GitHub Actions + Fastlane (match, gym, pilot) + Xcode Cloud para TestFlight

**Alternativas consideradas:**
- Bitrise
- CircleCI
- Apenas Xcode Cloud

**Justificativa:** Actions tem runners macOS no plano gratuito (com limites aceitáveis para 2 devs). Fastlane padrão de mercado. Xcode Cloud é o caminho mais simples para TestFlight automático em merge para `main`.

**Consequências:** Custos de minutos macOS após volume. Manutenção de certificados via match (Git encriptado).

---

### 14. Modelo de negócio do marketplace

**Decisão:** MED (Mercado Eletrônico Digital) com comissão de 10-15%; split payment apenas na V2

**Alternativas consideradas:**
- Comissão única, repasse manual aos artesãos
- Plataforma white-label sem comissão
- Modelo SaaS (artesão paga mensalidade)

**Justificativa:** Comissão por venda alinha incentivos. Split via Mercado Pago repassa direto para conta do artesão (V2). MVP/V1 usam conta única com repasse manual documentado — destrava entrega sem dependência de CNPJ.

**Consequências:** Em V2, exigência de CNPJ + contrato com cada artesão. NF-e em nome do artesão (não do app). Compliance fiscal a ser tratado com contador.

---

## Implicações imediatas

1. **Próximo refactor:** reestruturar pastas para `Features/` + `DesignSystem/` + `Core/` + `App/` (mecânico, baixo risco).
2. **Antes de qualquer feature de V1:** assinar contrato com artesãos para cessão de imagens (decisão 14 + risco 2 do plano).
3. **Configurar SPM:** adicionar dependências de Nuke, Sentry, TelemetryDeck conforme cada feature precisar (lazy).
4. **CI desde já:** workflow básico `.github/workflows/ios.yml` com lint + build + UITests rodando em cada push da `feature/ecommerce`.

## Revisão

Este ADR será revisitado ao final de cada fase (MVP / V1 / V2). Decisões podem ser anuladas via novo ADR (ex.: ADR-0007 que substitui a decisão 4 — formato "Substituído por ADR-XXXX").
