# Setup do Supabase — Vitrine Largo da Ordem

Guia prático para preparar o backend da V1.

## Sumário

1. [Criar o schema (5 min)](#1-criar-o-schema)
2. [Configurar autenticação (3 min)](#2-configurar-autenticação)
3. [Conferir Row-Level Security](#3-conferir-row-level-security)
4. [Variáveis de ambiente do app](#4-variáveis-de-ambiente)
5. [Comportamento offline](#5-comportamento-offline)

---

## 1. Criar o schema

1. Acesse o **SQL Editor** do seu projeto:
   <https://supabase.com/dashboard/project/snlxpgdilvjrefzurdth/sql/new>
2. Cole o conteúdo de [`01-schema.sql`](01-schema.sql) **inteiro**.
3. Clique em **Run** (ou `Cmd/Ctrl + Enter`).
4. Aguarde a mensagem **"Success. No rows returned"**.
5. Vá em **Table Editor** e confirme as 4 tabelas: `usuarios`, `enderecos`, `pedidos`, `itens_pedido`.

O script é idempotente — pode rodar quantas vezes quiser sem duplicar dados ou quebrar.

## 2. Configurar autenticação

No painel **Authentication → Providers**:

- **Email**: ativado por padrão. **Recomendado deixar ligado** "Confirm email" (mas em desenvolvimento pode desligar para testar sem precisar do email de confirmação).
- **Phone / Google / GitHub / etc.**: nenhum é necessário para o MVP. Deixar desligados.
- **Apple**: requer Apple Developer Program ($99/ano). Como não vamos pagar, fica desativado — `LoginView` do app não mostra mais o botão.

## 3. Conferir Row-Level Security

O script `01-schema.sql` já habilita RLS em todas as tabelas e cria as policies:

| Tabela | Policy |
|---|---|
| `usuarios` | Cada um vê e edita só o próprio perfil |
| `enderecos` | Cada um lê/cria/atualiza/remove só os próprios endereços |
| `pedidos` | Cada um lê/cria/atualiza/remove só os próprios pedidos |
| `itens_pedido` | Cada item segue o pedido dono |

Verifique em **Authentication → Policies** que as quatro tabelas têm RLS **enabled** e policies listadas.

## 4. Variáveis de ambiente

O app lê configuração via env vars com fallback nas constantes em `AppConfig.swift`:

| Variável | Descrição | Default |
|---|---|---|
| `SUPABASE_URL` | URL do projeto (https://<ref>.supabase.co) | URL do projeto da Vitrine já está no código |
| `SUPABASE_ANON_KEY` | Publishable key (sb_publishable_…) | Key já está no código |
| `USE_SUPABASE` | `1` para usar Supabase, `0` para usar SwiftData local | `1` (produção) |

**UITests** sempre setam `USE_SUPABASE=0` para não baterem na rede.

## 5. Comportamento offline

`SupabaseAuthService` faz **fallback automático** para `LocalAuthService` quando a rede falha:

- Cadastro/login sempre persistem no SwiftData local.
- Em paralelo, sincroniza com Supabase em `Task` background.
- Se a rede estiver fora, a UI continua respondendo normalmente.
- Quando voltar online, o próximo login bem-sucedido restabelece a sessão Supabase.

Essa estratégia é **offline-first** conforme princípio 2 do `PLANO_ECOMMERCE.md`.

## Endpoints usados pelo app

O app usa só o subset abaixo da API REST do Supabase:

- `POST /auth/v1/signup` — cadastro
- `POST /auth/v1/token?grant_type=password` — login email/senha
- `GET /rest/v1/usuarios?auth_user_id=eq.<uuid>` — perfil próprio
- `GET /rest/v1/enderecos?usuario_id=eq.<uuid>` — listar endereços
- `POST /rest/v1/enderecos` — criar endereço
- `PATCH /rest/v1/enderecos?id=eq.<uuid>` — atualizar
- `DELETE /rest/v1/enderecos?id=eq.<uuid>` — remover
- Idem para `/rest/v1/pedidos` e `/rest/v1/itens_pedido`

Quando precisarmos de Realtime ou Storage, migramos para o SDK oficial `supabase-swift`.
