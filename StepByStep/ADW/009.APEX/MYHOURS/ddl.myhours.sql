-- create tables
create table tasks (
    task_id                        number not null constraint tasks_task_id_pk primary key,
    task_desc                      varchar2(4000)
)
;

create table cpr (
    cpr_id                         number not null constraint cpr_cpr_id_pk primary key,
    cpr_name                       varchar2(255) not null,
    cpr_email                      varchar2(255) constraint cpr_cpr_email_unq unique not null
)
;

create table oportunities (
    op_id                          number not null constraint oportunities_op_id_pk primary key,
    op_num                         varchar2(50) constraint oportunities_op_num_unq unique not null,
    cust_name			   varchar2(100) not null,
    op_desc                        varchar2(4000) not null,
    op_cpr_id                      number constraint oportunities_op_cpr_id_fk references cpr on delete cascade
)
;

create table actividades (
    act_id                         number not null constraint actividades_act_id_pk primary key,
    act_start_date                 date,
    act_end_date                   date,
    act_num_hours                  NUMBER(2),
    act_is_oow                     varchar2(1) default on null 'N' constraint actividades_act_is_oow_cc check (act_is_oow in ('Y','N')),
    act_horas_imputadas            varchar2(1) default on null 'N' constraint actividades_horas_ok check (act_horas_imputadas in ('Y','N')),
    act_sr_id			   varchar2(20),
    act_desc			   varchar2(200),
    act_task_id                    number constraint actividades_act_task_id_fk references tasks on delete cascade,
    act_op_id                      number constraint actividades_act_op_id_fk references oportunities on delete cascade
)
;



-- triggers
create or replace trigger actividades_biu
    before insert or update 
    on actividades
    for each row
begin
    if :new.act_id is null then
        :new.act_id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end actividades_biu;
/

create or replace trigger oportunities_biu
    before insert or update 
    on oportunities
    for each row
begin
    if :new.op_id is null then
        :new.op_id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end oportunities_biu;
/

create or replace trigger cpr_biu
    before insert or update 
    on cpr
    for each row
begin
    if :new.cpr_id is null then
        :new.cpr_id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end cpr_biu;
/

create or replace trigger tasks_biu
    before insert or update 
    on tasks
    for each row
begin
    if :new.task_id is null then
        :new.task_id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
end tasks_biu;
/


-- indexes
create index actividades_i1 on actividades (act_op_id);
create index actividades_i2 on actividades (act_task_id);
create index cpr_i1 on cpr (cpr_id);
create index oportunities_i1 on oportunities (op_cpr_id);
create index tasks_i1 on tasks (task_id);
-- load data
 
-- Generated by Quick SQL Thursday September 05, 2019  11:36:53
 
/*
tasks
  task_id /pk
  task_desc

cpr
  cpr_id /pk
  cpr_name /nn
  cpr_email /nn /unique
  
oportunities
  op_id /pk
  op_num /nn /unique
  op_cpr_id /fk cpr
  
actividades
  act_id /pk
  act_start_date
  act_end_date
  act_num_hours
  act_is_oow /check Y N /default N
  act_task_id /fk tasks
  act_op_id /fk oportunities

# settings = { language: "EN", APEX: true }
*/

create or replace view v_dashboard_by_op
as
select	op.op_num as "Oportunity",
	act.act_start_date as start_date,
	act.act_end_date as end_date,
	act.act_num_hours as horas
from	oportunities op,
	actividades act
where	op.op_id = act.act_op_id;

create or replace view v_dashboard_by_cust
as
select	op.cust_name as "Cliente",
	act.act_start_date as start_date,
	act.act_end_date as end_date,
	act.act_num_hours as horas
from	oportunities op,
	actividades act
where	op.op_id = act.act_op_id;


create or replace view v_dashboard_by_cpr
as
select	cpr.cpr_name as cpr,
	act.act_start_date as start_date,
	act.act_end_date as end_date,
	act.act_num_hours as horas
from	cpr,
	oportunities op,
	actividades act
where	op.op_id = act.act_op_id
and	op.op_cpr_id = cpr.cpr_id;


