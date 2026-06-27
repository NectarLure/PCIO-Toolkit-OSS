-- PCIO Toolkit Supabase hotfix
-- Purpose: preserve the existing function parameter name for
-- public.pcio_contains_forbidden_text(text).
--
-- Root issue:
-- PostgreSQL does not allow CREATE OR REPLACE FUNCTION to rename an existing
-- input parameter. Existing remote databases may have:
--   public.pcio_contains_forbidden_text(input text)
-- This file keeps that exact parameter name and uses $1 inside the function
-- body to avoid ambiguity.

begin;

create or replace function public.pcio_contains_forbidden_text(input text)
returns boolean
language sql
immutable
as $$
  with source as (
    select coalesce($1, '') as s
  )
  select
    s ~* '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
    or s ~ '(\+?86[- ]?)?1[3-9][0-9]{9}'
    or s ~ '(^|[^0-9])([0-9]{17}[0-9Xx]|[0-9]{15})([^0-9]|$)'
    or s ~* '(身份证号|居民身份证|护照号|银行卡号|微信号|手机号|手机号码|联系电话|电子邮箱|邮箱|id card|identity card|passport number|bank card|wechat id|mobile phone|phone number|email address)'
    or s ~* '((详细地址|家庭住址|注册地址|办公地址|street address|home address|registered address|exact address)[:： ]+.{4,})'
    or s ~* '([一-龥A-Za-z0-9（）()?&.-]{2,80}(有限公司|有限责任公司|股份有限公司|集团有限公司))'
    or s ~* '([A-Za-z0-9&.,'' -]{2,80}\s+(Inc\.|LLC|Ltd\.|Limited|Corporation|Corp\.|Company Limited))'
    or s ~* '(统一社会信用代码|social credit code)[:： ]*[0-9A-Z]{18}'
    or s ~* '(合同编号|contract number)[:： ]*[A-Za-z0-9_-]{6,}'
    or s ~* '(真实设备编号|真实产线编号|车牌号|license plate)[:： ]*[A-Za-z0-9_-]{4,}'
  from source;
$$;

revoke execute on function public.pcio_contains_forbidden_text(text)
  from public, anon, authenticated;

commit;

-- Verification queries.
select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  pg_get_function_result(p.oid) as result_type,
  l.lanname as language,
  p.provolatile as volatility,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
join pg_language l on l.oid = p.prolang
where n.nspname = 'public'
  and p.proname = 'pcio_contains_forbidden_text';

select public.pcio_contains_forbidden_text('normal text') as normal_text_forbidden;
select public.pcio_contains_forbidden_text('phone number: 13800138000') as phone_text_forbidden;
select public.pcio_contains_forbidden_text('详细地址: 测试路100号') as address_text_forbidden;

select
  dependent_ns.nspname as dependent_schema,
  dependent_proc.proname as dependent_function,
  pg_get_function_identity_arguments(dependent_proc.oid) as dependent_arguments
from pg_depend d
join pg_proc target_proc on target_proc.oid = d.refobjid
join pg_namespace target_ns on target_ns.oid = target_proc.pronamespace
join pg_proc dependent_proc on dependent_proc.oid = d.objid
join pg_namespace dependent_ns on dependent_ns.oid = dependent_proc.pronamespace
where target_ns.nspname = 'public'
  and target_proc.proname = 'pcio_contains_forbidden_text'
order by dependent_schema, dependent_function, dependent_arguments;
