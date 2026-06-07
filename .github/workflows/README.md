# GitHub Actions — VitrineLargoOrdem

Workflows automatizados que rodam em todo push e PR para `main` e branches `feature/**`.

## Workflow: `ios.yml`

| Job | Runner | O que faz | Tempo médio |
|-----|--------|-----------|-------------|
| `build-and-test` | macOS 15 | Gera projeto via xcodegen, build, roda 32 testes unitários (Swift Testing) e 10 UI tests (XCUITest) | ~6 min |
| `lint` | Ubuntu | Roda SwiftLint com `.swiftlint.yml` do projeto | ~30 s |

### Falhas e artifacts

Quando UI Tests falham, o resultado (`UITestResults.xcresult`) é salvo como artifact por **7 dias** — basta abrir no Xcode para ver screenshots, logs e accessibility tree de cada falha.

### Cancelamento automático

Pushes consecutivos na mesma branch cancelam o run anterior (`concurrency: cancel-in-progress: true`), economizando minutos macOS do plano gratuito.

### Cache

O `DerivedData` é cacheado entre runs baseado em hash dos arquivos `.swift` + `project.yml`. Reduz pela metade o tempo de build em PRs incrementais.

## Como rodar localmente

```bash
# Equivalente ao job build-and-test
cd Somativa3/VitrineLargoOrdem
xcodegen generate

# Build
xcodebuild build \
  -project VitrineLargoOrdem.xcodeproj \
  -scheme VitrineLargoOrdem \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO

# Testes unitários (10s)
xcodebuild test \
  -project VitrineLargoOrdem.xcodeproj \
  -scheme VitrineLargoOrdem \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:VitrineLargoOrdemTests \
  CODE_SIGNING_ALLOWED=NO

# UI Tests (~65s)
xcodebuild test \
  -project VitrineLargoOrdem.xcodeproj \
  -scheme VitrineLargoOrdem \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:VitrineLargoOrdemUITests \
  CODE_SIGNING_ALLOWED=NO
```

## Roadmap do CI

Conforme planejado no [PLANO_ECOMMERCE.md](../../Somativa3/VitrineLargoOrdem/PLANO_ECOMMERCE.md) e ADR-0001 decisão 13:

- **Agora (MVP):** build + unit tests + UI tests + lint tolerante
- **V1:** adicionar Fastlane (match + gym + pilot) para TestFlight automático em merge para `main`
- **V2:** snapshot tests com swift-snapshot-testing, auditoria de a11y no CI, coverage report
