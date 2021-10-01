------------------------------------------------------
-- Export file for user MCSSTG                      --
-- Created by Administrator on 2012-10-19, 17:00:50 --
------------------------------------------------------

spool stg_trigger_proc20121019.log

prompt
prompt Creating procedure PROC_TANK_GET_DISTANCE
prompt =========================================
prompt
create or replace procedure mcsstg.PROC_TANK_GET_DISTANCE
(
  lng1 in number,  --经度1
  lat1 in number,  --纬度1
  lng2 in number,  --经度2
  lat2 in number,  --纬度2
  res out number --返回值
) 
as

begin
  
  select acos(TRUNC(sin(lat1*3.1415926/180),30) * sin(lat2*3.1415926/180) + TRUNC(cos(lat1*3.1415926/180),30) * cos(lat2*3.1415926/180)*cos(lng2*3.1415926/180-lng1*3.1415926/180))* 6378.137 into res 
  from dual;
  
end PROC_TANK_GET_DISTANCE;
/

prompt
prompt Creating procedure PROC_TANK_GET_STOP
prompt =====================================
prompt
create or replace procedure mcsstg.PROC_TANK_GET_STOP
(
       accept_in_gsmhm in varchar2,
       accept_in_qf_state in varchar2,
       accept_in_e in varchar2,
       accept_in_n in varchar2,
       accept_in_time in date
) as

pragma autonomous_transaction;

v_ACCEPT_NUM  NUMBER;
v_ACCEPT_GSMHM  VARCHAR2(100);
v_ACCEPT_E  VARCHAR2(20);
v_ACCEPT_N  VARCHAR2(20);
v_ACCEPT_TIME  DATE;
v_ACCEPT_CZY_ID  VARCHAR2(100);
v_ACCEPT_QF_STATE  VARCHAR2(100);
v_ACCEPT_ZYK1_STATE  CHAR(1);
v_ACCEPT_XYK1_STATE	CHAR(1);
v_ACCEPT_ZYK2_STATE	CHAR(1);
v_ACCEPT_XYK2_STATE	CHAR(1);
v_ACCEPT_ZYK3_STATE	CHAR(1);
v_ACCEPT_XYK3_STATE	CHAR(1);
v_CLBJ	CHAR(1);
v_DYBJ	VARCHAR2(100);
v_DYCL	CHAR(1);
v_CREATE_TIME	DATE;

res number;
coun number;
tank_yyy_count number;


begin

  if accept_in_gsmhm is not null and accept_in_qf_state='施封' then   
    select count(*) into tank_yyy_count from mcsstg.tank_gps_yyyymmdd
          where  accept_gsmhm=accept_in_gsmhm
          and accept_time > accept_in_time - 0.00361
          and accept_time < accept_in_time
          and rownum =1;
    if tank_yyy_count<>0 then          
       select 
          ACCEPT_NUM,
          ACCEPT_GSMHM,
          ACCEPT_E,
          ACCEPT_N,
          ACCEPT_TIME,
          ACCEPT_CZY_ID,
          ACCEPT_QF_STATE,
          ACCEPT_ZYK1_STATE,
          ACCEPT_XYK1_STATE,
          ACCEPT_ZYK2_STATE,
          ACCEPT_XYK2_STATE,
          ACCEPT_ZYK3_STATE,
          ACCEPT_XYK3_STATE,
          CLBJ,
          DYBJ,
          DYCL,
          CREATE_TIME
       into
          v_ACCEPT_NUM,
          v_ACCEPT_GSMHM,
          v_ACCEPT_E,
          v_ACCEPT_N,
          v_ACCEPT_TIME,
          v_ACCEPT_CZY_ID,
          v_ACCEPT_QF_STATE,
          v_ACCEPT_ZYK1_STATE,
          v_ACCEPT_XYK1_STATE,
          v_ACCEPT_ZYK2_STATE,
          v_ACCEPT_XYK2_STATE,
          v_ACCEPT_ZYK3_STATE,
          v_ACCEPT_XYK3_STATE,
          v_CLBJ,
          v_DYBJ,
          v_DYCL,
          v_CREATE_TIME    from mcsstg.tank_gps_yyyymmdd
          where  accept_gsmhm=accept_in_gsmhm
          and accept_time > accept_in_time - 0.00361
          and accept_time < accept_in_time
          and rownum =1
          order by accept_time asc;
          
          
       select count(*) into coun 
       from MCSSTG.INTER_GPS_YYYYMMDD_TANKSTOP 
       where ACCEPT_NUM=v_ACCEPT_NUM;
  
       if coun=0 then 
          PROC_TANK_GET_DISTANCE(accept_in_e,accept_in_n,v_ACCEPT_E,v_ACCEPT_N,res); 
          if  res < 0.005 and v_ACCEPT_QF_STATE='施封' then 
          insert into INTER_GPS_YYYYMMDD_TANKSTOP a
          (
          ACCEPT_NUM,
          ACCEPT_GSMHM,
          ACCEPT_E,
          ACCEPT_N,
          ACCEPT_TIME,
          ACCEPT_CZY_ID,
          ACCEPT_QF_STATE,
          ACCEPT_ZYK1_STATE,
          ACCEPT_XYK1_STATE,
          ACCEPT_ZYK2_STATE,
          ACCEPT_XYK2_STATE,
          ACCEPT_ZYK3_STATE,
          ACCEPT_XYK3_STATE,
          CLBJ,
          DYBJ,
          DYCL,
          CREATE_TIME
          )
          values( v_ACCEPT_NUM,              
                  v_ACCEPT_GSMHM,     
                  v_ACCEPT_E,          
                  v_ACCEPT_N,          
                  v_ACCEPT_TIME,               
                  v_ACCEPT_CZY_ID,    
                  v_ACCEPT_QF_STATE,  
                  v_ACCEPT_ZYK1_STATE,      
                  v_ACCEPT_XYK1_STATE,      
                  v_ACCEPT_ZYK2_STATE,      
                  v_ACCEPT_XYK2_STATE,      
                  v_ACCEPT_ZYK3_STATE,      
                  v_ACCEPT_XYK3_STATE,      
                  v_CLBJ,                   
                  v_DYBJ,             
                  v_DYCL,                   
                  v_CREATE_TIME             	       
                  ); 
          COMMIT;
          end if;     
      end if;
    end if;
  end if;
end PROC_TANK_GET_STOP;
/

prompt
prompt Creating procedure PROC_TANK_GPS_GET_CZY
prompt ========================================
prompt
create or replace procedure mcsstg.PROC_TANK_GPS_GET_CZY(
accept_in_gsmhm in varchar2, 
accept_in_time in date,  
accept_out_czy_id out varchar2  
) as

  TYPE get_czy_rows IS REF CURSOR;
  get_czy get_czy_rows;

  czy_id varchar2(100);
begin
  
  open get_czy for 
  select
  nvl(accept_czy_id,'空')
  from mcsstg.tank_gps_yyyymmdd 
  where accept_gsmhm=accept_in_gsmhm
  and accept_time > accept_in_time - 0.003
  and accept_time < accept_in_time;

  accept_out_czy_id:='空'; -- empty
  
  loop
    fetch get_czy into czy_id;
    exit when get_czy%NOTFOUND;
    if czy_id<>'空' then
      accept_out_czy_id:=czy_id;
    end if;
  end loop;
 
  close get_czy;
  
end PROC_TANK_GPS_GET_CZY;
/

prompt
prompt Creating procedure PROC_TANK_GPS_GET_STAT
prompt =========================================
prompt
create or replace procedure mcsstg.PROC_TANK_GPS_GET_STAT(
accept_in_gsmhm in varchar2,
accept_in_qf_state in varchar2,
accept_in_czy_id in varchar2,
accept_out_qf_state out varchar2,
accept_out_czy_id out varchar2
) as

gsmhm_num number;

begin
  --search gsmhm in INTER_GPS_STAT
  select count(*) into gsmhm_num from INTER_GPS_STAT where accept_gsmhm=accept_in_gsmhm;
  if gsmhm_num = 0 then --if no gsmhm then add new
    insert into INTER_GPS_STAT (
    accept_gsmhm,
    accept_qf_state,
    accept_czy_id
    ) 
    values (
    accept_in_gsmhm,
    accept_in_qf_state,
    accept_in_czy_id
    );
	end if;

  --return cap status
  select accept_qf_state,accept_czy_id into accept_out_qf_state ,accept_out_czy_id 
  from INTER_GPS_STAT 
  where accept_gsmhm=accept_in_gsmhm;
  
  if accept_in_czy_id is not null and accept_in_qf_state=accept_out_qf_state then 
     update INTER_GPS_STAT set accept_czy_id=accept_in_czy_id
     where accept_gsmhm=accept_in_gsmhm
     and accept_czy_id is null;    
  end if;
    
end PROC_TANK_GPS_GET_STAT;
/

prompt
prompt Creating procedure PROC_TANK_GPS_INSERT
prompt =======================================
prompt
create or replace procedure mcsstg.PROC_TANK_GPS_INSERT(
vl_ACCEPT_IN_NUM  IN NUMBER,              
vl_ACCEPT_IN_GSMHM IN VARCHAR2,     
vl_ACCEPT_IN_E IN VARCHAR2,          
vl_ACCEPT_IN_N IN VARCHAR2,          
vl_ACCEPT_IN_TIME IN DATE,               
vl_ACCEPT_IN_CZY_ID IN VARCHAR2,    
vl_ACCEPT_IN_QF_STATE IN VARCHAR2,  
vl_ACCEPT_IN_ZYK1_STATE IN CHAR,      
vl_ACCEPT_IN_XYK1_STATE IN CHAR,      
vl_ACCEPT_IN_ZYK2_STATE IN CHAR,      
vl_ACCEPT_IN_XYK2_STATE IN CHAR,      
vl_ACCEPT_IN_ZYK3_STATE IN CHAR,      
vl_ACCEPT_IN_XYK3_STATE IN CHAR,      
vl_IN_CLBJ IN CHAR,                   
vl_IN_DYBJ IN VARCHAR2,             
vl_IN_DYCL IN CHAR,                   
vl_IN_CREATE_TIME IN DATE               	
) as
begin
          insert into INTER_GPS_YYYYMMDD
          (
          ACCEPT_NUM,
          ACCEPT_GSMHM,
          ACCEPT_E,
          ACCEPT_N,
          ACCEPT_TIME,
          ACCEPT_CZY_ID,
          ACCEPT_QF_STATE,
          ACCEPT_ZYK1_STATE,
          ACCEPT_XYK1_STATE,
          ACCEPT_ZYK2_STATE,
          ACCEPT_XYK2_STATE,
          ACCEPT_ZYK3_STATE,
          ACCEPT_XYK3_STATE,
          CLBJ,
          DYBJ,
          DYCL,
          CREATE_TIME
          )
          values( vl_ACCEPT_IN_NUM,              
                  vl_ACCEPT_IN_GSMHM,     
                  vl_ACCEPT_IN_E,          
                  vl_ACCEPT_IN_N,          
                  vl_ACCEPT_IN_TIME,               
                  vl_ACCEPT_IN_CZY_ID,    
                  vl_ACCEPT_IN_QF_STATE,  
                  vl_ACCEPT_IN_ZYK1_STATE,      
                  vl_ACCEPT_IN_XYK1_STATE,      
                  vl_ACCEPT_IN_ZYK2_STATE,      
                  vl_ACCEPT_IN_XYK2_STATE,      
                  vl_ACCEPT_IN_ZYK3_STATE,      
                  vl_ACCEPT_IN_XYK3_STATE,      
                  vl_IN_CLBJ,                   
                  vl_IN_DYBJ,             
                  vl_IN_DYCL,                   
                  vl_IN_CREATE_TIME             	       
                  );    
                  
           update INTER_GPS_STAT set ACCEPT_QF_STATE=vl_ACCEPT_IN_QF_STATE,ACCEPT_CZY_ID=vl_ACCEPT_IN_CZY_ID
           where accept_gsmhm=vl_ACCEPT_IN_GSMHM;    
                 
                  
end PROC_TANK_GPS_INSERT;
/

prompt
prompt Creating procedure PROC_TANK_TRAFFICE_GET_CZYGW
prompt ===============================================
prompt
create or replace procedure mcsstg.PROC_TANK_TRAFFICE_GET_CZYGW
(
       accept_in_czy_id in varchar2,
       czy_out_gw out varchar2  
) as

begin
  --根据czy号,返回czy对应操作 加油站施封 油库半解封 加油站解封 油库施封
  select czy_gw into czy_out_gw
  from mcsstg.tank_gps_czy where czy_id=accept_in_czy_id;
  
end PROC_TANK_TRAFFICE_GET_CZYGW;
/

prompt
prompt Creating procedure PROC_TANK_TRAFFIC_GET_EN
prompt ===========================================
prompt
create or replace procedure mcsstg.PROC_TANK_TRAFFIC_GET_EN
(
       accept_in_e in varchar2,
       accept_in_n in varchar2,
       station_out_code out varchar2  --输出加油站或油库编码
) as
  
  truck_e varchar2(20);
  truck_n varchar2(20);
  sapdm varchar2(20);
  distance_res number;

  TYPE get_station_code_rows IS REF CURSOR;
  get_station_code get_station_code_rows;

begin
  --初始化游标,取得表中所有加油站或油库代码,以及坐标
  open get_station_code for
  select sap_dm,address_e,address_n 
  from mcsstg.tank_gps_address;
  
  loop
    fetch get_station_code into sapdm,truck_e,truck_n;
    exit when get_station_code%NOTFOUND;
    --计算挨个计算距离
    PROC_TANK_GET_DISTANCE(accept_in_e,accept_in_n,truck_e,truck_n,distance_res);
    if distance_res < 0.015 then --若在15米范围内,则返回当前加油站或油库编码
      station_out_code:=sapdm;
    end if;
  end loop;    
  
  close get_station_code;
  
end PROC_TANK_TRAFFIC_GET_EN;
/

prompt
prompt Creating procedure PROC_TANK_TRAFFICE_GET_CZYNULL
prompt =================================================
prompt
create or replace procedure mcsstg.PROC_TANK_TRAFFICE_GET_CZYNULL
(
       accept_in_e in varchar2,
       accept_in_n in varchar2,
       accept_in_qf_state in varchar2,
       czy_out_name out varchar2
) as
  
  sapdm varchar2(20);
  coun number;
begin
  
  --获取当前加油站或油库编码
  PROC_TANK_TRAFFIC_GET_EN(accept_in_e,accept_in_n,sapdm);
  --判断编码属于油库还是加油站,为0则为加油站
  select count(*) into coun from mcsstg.tank_gps_address
  where address_mc like '%油库%' and sap_dm=sapdm;
  
  if coun<>0 and accept_in_qf_state='解封' then
    czy_out_name:='油库半解封';
  elsif coun<>0 and accept_in_qf_state='施封' then
    czy_out_name:='油库施封';
  elsif coun=0 and accept_in_qf_state='解封' then
    czy_out_name:='加油站解封';  
  elsif coun=0 and accept_in_qf_state='施封' then
    czy_out_name:='加油站施封';  
  end if;
  
end PROC_TANK_TRAFFICE_GET_CZYNULL;
/

prompt
prompt Creating procedure PROC_TANK_TRAFFICE_UPDATE
prompt ============================================
prompt
create or replace procedure mcsstg.PROC_TANK_TRAFFICE_UPDATE
(
       accept_in_gsmhm in varchar2,
       accept_in_time in date,
       accept_in_e in varchar2,
       accept_in_n in varchar2,
       will_update_column in varchar2  --输入czy_gw状态
) as

  qchm varchar2(200);
  dm varchar2(20);
  time_stop date;
  
begin
  --根据accept_in_gsmhm获得车号
  select truck_mc into qchm from mcsstg.tank_gps_truck
  where truck_gsmhm=accept_in_gsmhm and rownum=1;
  --取得当前加油站或油库编码
  PROC_TANK_TRAFFIC_GET_EN(accept_in_e,accept_in_n,dm);
  --取得停车表中最早的一条停车时间,若需要可在inter_gps_yyyymmdd_tankstop中加标志位判断非重车停车
  select accept_time into time_stop from mcsstg.inter_gps_yyyymmdd_tankstop
  where accept_gsmhm=accept_in_gsmhm and rownum=1 order by accept_time asc;
  
  if will_update_column='油库半解封' then
     update mcsods.fct_traffic_monitor_test set payoil_stime=accept_in_time
     where vehicle_code=qchm
     and stime = to_date(to_char(accept_in_time -1,'yyyy-mm-dd') ,'yyyy-mm-dd');

     
  elsif will_update_column='油库施封' then 
     update mcsods.fct_traffic_monitor_test set outdepot_time=accept_in_time
     where vehicle_code=qchm
     and stime = to_date(to_char(accept_in_time -1,'yyyy-mm-dd') ,'yyyy-mm-dd');

           
  elsif will_update_column='加油站解封' then
     update mcsods.fct_traffic_monitor_test set arrival_time=time_stop
     where vehicle_code=qchm
     and station_code=dm --需要同时判断配送目标加油站
     and stime = to_date(to_char(accept_in_time -1,'yyyy-mm-dd') ,'yyyy-mm-dd');
     
     
  elsif will_update_column='加油站施封' then
     update mcsods.fct_traffic_monitor_test set leave_time=accept_in_time
     where vehicle_code=qchm
     and station_code=dm  --需要同时判断配送目标加油站
     and stime = to_date(to_char(accept_in_time -1,'yyyy-mm-dd') ,'yyyy-mm-dd');

     
  end if;        
     
end PROC_TANK_TRAFFICE_UPDATE;
/

prompt
prompt Creating procedure TEST_TRIGGER
prompt ===============================
prompt
create or replace procedure mcsstg.TEST_TRIGGER as
  --
  truck_stat varchar2(100);  --铅封状态
  truck_czy_id varchar2(100);  --czy_ID
  
  --
  vl_ACCEPT_NUM NUMBER;              
  vl_ACCEPT_GSMHM VARCHAR2(100);     
  vl_ACCEPT_E VARCHAR2(20);          
  vl_ACCEPT_N VARCHAR2(20);          
  vl_ACCEPT_TIME DATE;               
  vl_ACCEPT_CZY_ID VARCHAR2(100);    
  vl_ACCEPT_QF_STATE VARCHAR2(100);  
  vl_ACCEPT_ZYK1_STATE CHAR(1);      
  vl_ACCEPT_XYK1_STATE CHAR(1);      
  vl_ACCEPT_ZYK2_STATE CHAR(1);      
  vl_ACCEPT_XYK2_STATE CHAR(1);      
  vl_ACCEPT_ZYK3_STATE CHAR(1);      
  vl_ACCEPT_XYK3_STATE CHAR(1);      
  vl_CLBJ CHAR(1);                   
  vl_DYBJ VARCHAR2(100);             
  vl_DYCL CHAR(1);                   
  vl_CREATE_TIME DATE;                 
  
  --
  TYPE get_truck_rows IS REF CURSOR;
  get_truck get_truck_rows;
  
begin
    open get_truck for 
    select * from mcsstg.tank_gps_yyyymmdd 
    where to_char(accept_time,'yyyymmdd')='20121015'
    and accept_gsmhm='010538003'
    order by accept_time;
    
    LOOP
    fetch get_truck into vl_ACCEPT_NUM,vl_ACCEPT_GSMHM,vl_ACCEPT_E,vl_ACCEPT_N,vl_ACCEPT_TIME,vl_ACCEPT_CZY_ID,vl_ACCEPT_QF_STATE,vl_ACCEPT_ZYK1_STATE,vl_ACCEPT_XYK1_STATE,vl_ACCEPT_ZYK2_STATE,vl_ACCEPT_XYK2_STATE,vl_ACCEPT_ZYK3_STATE,vl_ACCEPT_XYK3_STATE,vl_CLBJ,vl_DYBJ,vl_DYCL,vl_CREATE_TIME;
    exit when get_truck%NOTFOUND;    
    
    truck_stat:='';
    truck_czy_id:='';
    
    if vl_ACCEPT_QF_STATE='异常' then
      null;
      --return;
    end if;
    --获取铅封状态变化,赋值truck_stat
    PROC_TANK_GPS_GET_STAT(vl_ACCEPT_GSMHM,vl_ACCEPT_QF_STATE,truck_stat);
    
    --获取czy值,为空则返回'0'
    PROC_TANK_GPS_GET_CZY(vl_ACCEPT_GSMHM,vl_ACCEPT_TIME,truck_czy_id);

    --判断状态是否有变化
    if vl_ACCEPT_QF_STATE=truck_stat  then  --若无状态变化,则返回
      null;
      --return;
    end if;
    if truck_czy_id='空' and vl_ACCEPT_QF_STATE<>truck_stat  then
    PROC_TANK_GPS_INSERT(vl_ACCEPT_NUM,       
                  vl_ACCEPT_GSMHM,     
                  vl_ACCEPT_E,         
                  vl_ACCEPT_N,         
                  vl_ACCEPT_TIME,      
                  '',    
                  vl_ACCEPT_QF_STATE,  
                  vl_ACCEPT_ZYK1_STATE,
                  vl_ACCEPT_XYK1_STATE,
                  vl_ACCEPT_ZYK2_STATE,
                  vl_ACCEPT_XYK2_STATE,
                  vl_ACCEPT_ZYK3_STATE,
                  vl_ACCEPT_XYK3_STATE,
                  vl_CLBJ,             
                  vl_DYBJ,             
                  vl_DYCL,             
                  vl_CREATE_TIME);
          elsif truck_czy_id<>'空' and vl_ACCEPT_QF_STATE<>truck_stat then  
            PROC_TANK_GPS_INSERT(vl_ACCEPT_NUM,       
                  vl_ACCEPT_GSMHM,     
                  vl_ACCEPT_E,         
                  vl_ACCEPT_N,         
                  vl_ACCEPT_TIME,      
                  truck_czy_id,    
                  vl_ACCEPT_QF_STATE,  
                  vl_ACCEPT_ZYK1_STATE,
                  vl_ACCEPT_XYK1_STATE,
                  vl_ACCEPT_ZYK2_STATE,
                  vl_ACCEPT_XYK2_STATE,
                  vl_ACCEPT_ZYK3_STATE,
                  vl_ACCEPT_XYK3_STATE,
                  vl_CLBJ,             
                  vl_DYBJ,             
                  vl_DYCL,             
                  vl_CREATE_TIME); 
      end if;
    END LOOP;
    close get_truck;
    
    
end TEST_TRIGGER;
/

prompt
prompt Creating trigger TRI_TANK_GPS_GET_STAT
prompt ======================================
prompt
create or replace trigger MCSSTG.TRI_TANK_GPS_GET_STAT
after insert on mcsstg.tank_gps_yyyymmdd  
referencing new as new_value
for each row
  
declare

    truck_stat varchar2(100);  
    truck_czy_id varchar2(100); 

begin

    if :new_value.accept_qf_state='异常' then
      return;
    end if;
    
    PROC_TANK_GET_STOP(:new_value.accept_gsmhm,:new_value.accept_qf_state,:new_value.accept_e,:new_value.accept_n,:new_value.accept_time);
    
    PROC_TANK_GPS_GET_STAT(:new_value.accept_gsmhm,:new_value.accept_qf_state,:new_value.ACCEPT_CZY_ID,truck_stat,truck_czy_id);    
    
    if :new_value.accept_qf_state=truck_stat then
      return;
    end if;        
    
    if truck_czy_id is null and :new_value.ACCEPT_QF_STATE<>truck_stat then
        PROC_TANK_GPS_INSERT(:new_value.ACCEPT_NUM,       
            :new_value.ACCEPT_GSMHM,     
            :new_value.ACCEPT_E,         
            :new_value.ACCEPT_N,         
            :new_value.ACCEPT_TIME,      
            :new_value.ACCEPT_CZY_ID,    
            :new_value.ACCEPT_QF_STATE,  
            :new_value.ACCEPT_ZYK1_STATE,
            :new_value.ACCEPT_XYK1_STATE,
            :new_value.ACCEPT_ZYK2_STATE,
            :new_value.ACCEPT_XYK2_STATE,
            :new_value.ACCEPT_ZYK3_STATE,
            :new_value.ACCEPT_XYK3_STATE,
            :new_value.CLBJ,             
            :new_value.DYBJ,             
            :new_value.DYCL,             
            :new_value.CREATE_TIME);  
     elsif truck_czy_id is not null and :new_value.ACCEPT_CZY_ID is null and :new_value.ACCEPT_QF_STATE<>truck_stat then
        PROC_TANK_GPS_INSERT(:new_value.ACCEPT_NUM,       
            :new_value.ACCEPT_GSMHM,     
            :new_value.ACCEPT_E,         
            :new_value.ACCEPT_N,         
            :new_value.ACCEPT_TIME,      
            truck_czy_id,    
            :new_value.ACCEPT_QF_STATE,  
            :new_value.ACCEPT_ZYK1_STATE,
            :new_value.ACCEPT_XYK1_STATE,
            :new_value.ACCEPT_ZYK2_STATE,
            :new_value.ACCEPT_XYK2_STATE,
            :new_value.ACCEPT_ZYK3_STATE,
            :new_value.ACCEPT_XYK3_STATE,
            :new_value.CLBJ,             
            :new_value.DYBJ,             
            :new_value.DYCL,             
            :new_value.CREATE_TIME); 
      elsif truck_czy_id is not null and :new_value.ACCEPT_CZY_ID is not null and :new_value.ACCEPT_QF_STATE<>truck_stat then
        PROC_TANK_GPS_INSERT(:new_value.ACCEPT_NUM,       
            :new_value.ACCEPT_GSMHM,     
            :new_value.ACCEPT_E,         
            :new_value.ACCEPT_N,         
            :new_value.ACCEPT_TIME,      
            :new_value.ACCEPT_CZY_ID,    
            :new_value.ACCEPT_QF_STATE,  
            :new_value.ACCEPT_ZYK1_STATE,
            :new_value.ACCEPT_XYK1_STATE,
            :new_value.ACCEPT_ZYK2_STATE,
            :new_value.ACCEPT_XYK2_STATE,
            :new_value.ACCEPT_ZYK3_STATE,
            :new_value.ACCEPT_XYK3_STATE,
            :new_value.CLBJ,             
            :new_value.DYBJ,             
            :new_value.DYCL,             
            :new_value.CREATE_TIME);
      end if;           

end TRI_TANK_GPS_GET_STAT;
/

prompt
prompt Creating trigger TRI_TANK_GPS_UPDATE_TRAFFIC
prompt ============================================
prompt
create or replace trigger MCSSTG.TRI_TANK_GPS_UPDATE_TRAFFIC
  after insert on mcsstg.inter_gps_yyyymmdd 
  referencing new as new_v 
  for each row
declare

  czy_getid varchar2(400);
  
begin
  if :new_v.accept_gsmhm is not null then

  if :new_v.ACCEPT_CZY_ID is not null then
    PROC_TANK_TRAFFICE_GET_CZYGW(:new_v.ACCEPT_CZY_ID,czy_getid);
    PROC_TANK_TRAFFICE_UPDATE(:new_v.accept_gsmhm,:new_v.accept_time,:new_v.accept_e,:new_v.accept_n,czy_getid);
  elsif :new_v.ACCEPT_CZY_ID is null then
    PROC_TANK_TRAFFICE_GET_CZYNULL(:new_v.accept_e,:new_v.accept_n,:new_v.accept_qf_state,czy_getid);
    PROC_TANK_TRAFFICE_UPDATE(:new_v.accept_gsmhm,:new_v.accept_time,:new_v.accept_e,:new_v.accept_n,czy_getid);
  end if;
  
  end if;
end TRI_TANK_GPS_UPDATE_TRAFFIC;
/


spool off
