-- ============================================================================
-- Vitrine Largo da Ordem - schema inicial Supabase
-- ----------------------------------------------------------------------------
-- COMO USAR
-- 1. Abrir o SQL Editor: https://supabase.com/dashboard/project/snlxpgdilvjrefzurdth/sql/new
-- 2. Colar este arquivo TODO de uma vez
-- 3. Apertar "Run" (ou Cmd/Ctrl+Enter)
-- 4. Aguardar "Success. No rows returned" e ver a aba Table Editor populada
--
-- Tudo aqui é idempotente: pode rodar várias vezes que não duplica nada.
-- ============================================================================

-- =========================================================================
-- 1. Extensões necessárias
-- =========================================================================
create extension if not exists "uuid-ossp";

-- =========================================================================
-- 2. Perfis de usuário (espelha auth.users com dados de domínio)
-- =========================================================================
create table if not exists public.usuarios (
    id uuid primary key default uuid_generate_v4(),
    auth_user_id uuid unique references auth.users(id) on delete cascade,
    email text not null,
    nome text not null,
    provedor text not null default 'email',     -- 'email' | 'apple' | 'convidado'
    criado_em timestamptz not null default now(),
    atualizado_em timestamptz not null default now()
);

comment on table public.usuarios is 'Perfil de domínio do usuário. Vinculado a auth.users via auth_user_id.';

-- =========================================================================
-- 3. Endereços
-- =========================================================================
create table if not exists public.enderecos (
    id uuid primary key default uuid_generate_v4(),
    usuario_id uuid not null references public.usuarios(id) on delete cascade,
    apelido text not null,
    cep text not null,
    logradouro text not null,
    numero text not null,
    complemento text not null default '',
    bairro text not null,
    cidade text not null,
    uf text not null check (char_length(uf) = 2),
    eh_padrao boolean not null default false,
    criado_em timestamptz not null default now()
);

create index if not exists idx_enderecos_usuario on public.enderecos(usuario_id);

-- =========================================================================
-- 4. Pedidos + itens
-- =========================================================================
create type public.status_pedido as enum (
    'recebido', 'em_producao', 'despachado', 'entregue', 'cancelado'
);

create type public.forma_pagamento as enum (
    'pix', 'cartao_credito', 'cartao_debito', 'boleto'
);

create table if not exists public.pedidos (
    id uuid primary key default uuid_generate_v4(),
    usuario_id uuid not null references public.usuarios(id) on delete cascade,
    numero text not null unique,
    status public.status_pedido not null default 'recebido',
    forma_pagamento public.forma_pagamento not null,
    subtotal numeric(10, 2) not null,
    frete numeric(10, 2) not null,
    total numeric(10, 2) not null,
    endereco_linha1 text not null,
    endereco_linha2 text not null,
    criado_em timestamptz not null default now(),
    atualizado_em timestamptz not null default now()
);

create index if not exists idx_pedidos_usuario on public.pedidos(usuario_id);
create index if not exists idx_pedidos_status on public.pedidos(status);

create table if not exists public.itens_pedido (
    id uuid primary key default uuid_generate_v4(),
    pedido_id uuid not null references public.pedidos(id) on delete cascade,
    produto_id uuid not null,
    nome text not null,
    imagem_nome text not null,
    preco_unitario numeric(10, 2) not null,
    quantidade integer not null check (quantidade > 0)
);

create index if not exists idx_itens_pedido on public.itens_pedido(pedido_id);

-- =========================================================================
-- 5. Função para manter atualizado_em sempre fresco
-- =========================================================================
create or replace function public.atualizar_timestamp()
returns trigger as $$
begin
    new.atualizado_em = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_usuarios_atualizado on public.usuarios;
create trigger trg_usuarios_atualizado
    before update on public.usuarios
    for each row execute function public.atualizar_timestamp();

drop trigger if exists trg_pedidos_atualizado on public.pedidos;
create trigger trg_pedidos_atualizado
    before update on public.pedidos
    for each row execute function public.atualizar_timestamp();

-- =========================================================================
-- 6. Trigger: cria usuário público quando alguém se cadastra via Auth
-- =========================================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.usuarios (auth_user_id, email, nome, provedor)
    values (
        new.id,
        new.email,
        coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)),
        coalesce(new.raw_app_meta_data->>'provider', 'email')
    )
    on conflict (auth_user_id) do nothing;
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- =========================================================================
-- 7. Row-Level Security (RLS) — cada usuário só vê o que é dele
-- =========================================================================
alter table public.usuarios     enable row level security;
alter table public.enderecos    enable row level security;
alter table public.pedidos      enable row level security;
alter table public.itens_pedido enable row level security;

-- Policies para usuarios
drop policy if exists "Usuários veem o próprio perfil" on public.usuarios;
create policy "Usuários veem o próprio perfil"
    on public.usuarios for select
    using (auth_user_id = auth.uid());

drop policy if exists "Usuários atualizam o próprio perfil" on public.usuarios;
create policy "Usuários atualizam o próprio perfil"
    on public.usuarios for update
    using (auth_user_id = auth.uid());

-- Policies para endereços
drop policy if exists "Endereços só do dono" on public.enderecos;
create policy "Endereços só do dono"
    on public.enderecos for all
    using (
        usuario_id in (select id from public.usuarios where auth_user_id = auth.uid())
    )
    with check (
        usuario_id in (select id from public.usuarios where auth_user_id = auth.uid())
    );

-- Policies para pedidos
drop policy if exists "Pedidos só do dono" on public.pedidos;
create policy "Pedidos só do dono"
    on public.pedidos for all
    using (
        usuario_id in (select id from public.usuarios where auth_user_id = auth.uid())
    )
    with check (
        usuario_id in (select id from public.usuarios where auth_user_id = auth.uid())
    );

drop policy if exists "Itens só do dono" on public.itens_pedido;
create policy "Itens só do dono"
    on public.itens_pedido for all
    using (
        pedido_id in (
            select id from public.pedidos
            where usuario_id in (select id from public.usuarios where auth_user_id = auth.uid())
        )
    );

-- ============================================================================
-- FIM. Resultado esperado: 4 tabelas + 2 ENUMs + 3 triggers + RLS habilitado.
-- ============================================================================
