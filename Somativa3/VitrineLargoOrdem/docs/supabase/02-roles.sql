-- ============================================================================
-- Vitrine Largo da Ordem - Roles (admin / usuario)
-- ----------------------------------------------------------------------------
-- Pré-requisito: rodar PRIMEIRO o 01-schema.sql.
--
-- O QUE ESTE SCRIPT FAZ
-- - Adiciona ENUM role_usuario com valores 'usuario' (padrão) e 'admin'.
-- - Adiciona coluna `role` na tabela `usuarios` (default 'usuario').
-- - Função helper `is_admin()` para policies — retorna true se o auth.uid()
--   atual tem role 'admin'.
-- - Policies adicionais: admin enxerga e edita TODOS os usuários, endereços,
--   pedidos e itens. Usuário comum continua restrito ao próprio escopo.
-- - Função `promover_usuario(email_alvo, nova_role)` invocável apenas por
--   admins.
--
-- Idempotente — pode rodar várias vezes sem efeito colateral.
-- ============================================================================

-- =========================================================================
-- 1. ENUM e coluna role
-- =========================================================================
do $$
begin
    if not exists (select 1 from pg_type where typname = 'role_usuario') then
        create type public.role_usuario as enum ('usuario', 'admin');
    end if;
end $$;

alter table public.usuarios
    add column if not exists role public.role_usuario not null default 'usuario';

create index if not exists idx_usuarios_role on public.usuarios(role);

-- =========================================================================
-- 2. Helper para policies — é admin?
-- =========================================================================
create or replace function public.is_admin()
returns boolean as $$
begin
    return exists (
        select 1 from public.usuarios
        where auth_user_id = auth.uid()
          and role = 'admin'
    );
end;
$$ language plpgsql stable security definer;

-- =========================================================================
-- 3. Policies adicionais para admin
-- =========================================================================

-- usuarios: admin enxerga todos
drop policy if exists "Admins veem todos os perfis" on public.usuarios;
create policy "Admins veem todos os perfis"
    on public.usuarios for select
    using (public.is_admin());

drop policy if exists "Admins editam todos os perfis" on public.usuarios;
create policy "Admins editam todos os perfis"
    on public.usuarios for update
    using (public.is_admin());

-- enderecos: admin enxerga todos
drop policy if exists "Admins veem todos os enderecos" on public.enderecos;
create policy "Admins veem todos os enderecos"
    on public.enderecos for select
    using (public.is_admin());

-- pedidos: admin enxerga e edita todos
drop policy if exists "Admins veem todos os pedidos" on public.pedidos;
create policy "Admins veem todos os pedidos"
    on public.pedidos for select
    using (public.is_admin());

drop policy if exists "Admins atualizam status dos pedidos" on public.pedidos;
create policy "Admins atualizam status dos pedidos"
    on public.pedidos for update
    using (public.is_admin());

-- itens_pedido: admin enxerga todos
drop policy if exists "Admins veem todos os itens" on public.itens_pedido;
create policy "Admins veem todos os itens"
    on public.itens_pedido for select
    using (public.is_admin());

-- =========================================================================
-- 4. Função para promover/rebaixar usuário (apenas admins)
-- =========================================================================
create or replace function public.promover_usuario(
    email_alvo text,
    nova_role public.role_usuario
)
returns public.usuarios as $$
declare
    usuario_atualizado public.usuarios;
begin
    if not public.is_admin() then
        raise exception 'Apenas administradores podem alterar roles.';
    end if;

    update public.usuarios
       set role = nova_role
     where email = email_alvo
    returning * into usuario_atualizado;

    if usuario_atualizado.id is null then
        raise exception 'Usuário com e-mail % não encontrado.', email_alvo;
    end if;

    return usuario_atualizado;
end;
$$ language plpgsql security definer;

-- =========================================================================
-- 5. PRIMEIRO USUÁRIO VIRA ADMIN AUTOMATICAMENTE
--    (atualiza handle_new_user para checar se já existe alguém na tabela)
-- =========================================================================
create or replace function public.handle_new_user()
returns trigger as $$
declare
    role_inicial public.role_usuario;
begin
    -- Se ainda não existe nenhum usuário cadastrado, o novo vira admin.
    -- Útil para bootstrap em ambiente de demonstração.
    if not exists (select 1 from public.usuarios) then
        role_inicial := 'admin';
    else
        role_inicial := 'usuario';
    end if;

    insert into public.usuarios (auth_user_id, email, nome, provedor, role)
    values (
        new.id,
        new.email,
        coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)),
        coalesce(new.raw_app_meta_data->>'provider', 'email'),
        role_inicial
    )
    on conflict (auth_user_id) do nothing;

    return new;
end;
$$ language plpgsql security definer;

-- ============================================================================
-- FIM. Verificação rápida:
--   SELECT email, role FROM public.usuarios ORDER BY criado_em;
-- ============================================================================
