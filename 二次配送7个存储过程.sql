----------------------------------------------------
-- Export file for user MCSODS                    --
-- Created by Administrator on 2012-8-7, 10:00:36 --
----------------------------------------------------

spool ��������7���洢����.log

prompt
prompt Creating procedure PROC_GPS_MCS_GET_ADDRESS
prompt ===========================================
prompt
create or replace procedure mcsods.PROC_GPS_MCS_GET_ADDRESS --��ȡվ��γ��
(
address_mc_in in varchar2, 
res_lng out float,  --����
res_lat out float   --γ��
) as
begin
  select to_number(address_e) into res_lng
  from mcsstg.gps_mcs_gps_address
  where trim(address_mc)= address_mc_in; --��ȡ����
  select to_number(address_n) into res_lat
  from mcsstg.gps_mcs_gps_address
  where trim(address_mc)= address_mc_in; --��ȡγ��


end PROC_GPS_MCS_GET_ADDRESS;
/

prompt
prompt Creating procedure PROC_GPS_MCS_GET_TRUCK_GPS
prompt =============================================
prompt
create or replace procedure mcsods.PROC_GPS_MCS_GET_TRUCK_GPS  --��ȡ����ǰ��γ��
(
accept_gsmhm_in in varchar2, 
res_lng out number,  --����
res_lat out number   --γ��
) as
begin
  select accept_e into res_lng from (
  select to_number(accept_e) as accept_e  
  from mcsstg.gps_mcs_gps_yyyymmdd 
  where trim(accept_gsmhm)= accept_gsmhm_in
  order by accept_time desc)
  where rownum<2 ;  --������ʱ��ľ���
  select accept_n into res_lat from (
  select to_number(accept_n) as accept_n  
  from mcsstg.gps_mcs_gps_yyyymmdd 
  where trim(accept_gsmhm)= accept_gsmhm_in
  order by accept_time desc)
  where rownum<2 ;  --������ʱ���γ��

end PROC_GPS_MCS_GET_TRUCK_GPS;
/

prompt
prompt Creating procedure PROC_GPS_MCS_GET_TRUCK_GSMHM
prompt ===============================================
prompt
create or replace procedure mcsods.PROC_GPS_MCS_GET_TRUCK_GSMHM  --���ݳ��ƺŻ�ȡgsmhm
(
truck_mc_in in varchar2,
res_truck_gsmhm out varchar2
) as
begin
  
  select trim(truck_gsmhm) into res_truck_gsmhm 
  from  mcsstg.gps_mcs_gps_truck 
  where trim(truck_mc)= truck_mc_in;
  
end PROC_GPS_MCS_GET_TRUCK_GSMHM;
/

prompt
prompt Creating procedure PROC_GPS_GET_DISTANCE
prompt ========================================
prompt
create or replace procedure mcsods.PROC_GPS_GET_DISTANCE --�������
(
  lng1 in number,  --����1
  lat1 in number,  --γ��1
  lng2 in number,  --����2
  lat2 in number,  --γ��2
  res out number --����ֵ
) 
as
begin
  select acos(sin(lat1*3.1415926/180) * sin(lat2*3.1415926/180) + cos(lat1*3.1415926/180) * cos(lat2*3.1415926/180)*cos(lng2*3.1415926/180-lng1*3.1415926/180))* 6378.137 into res 
  from dual;
  
end PROC_GPS_GET_DISTANCE;
/

prompt
prompt Creating procedure PROC_GPS_GET_TRUCADDR_DISTANCE
prompt =================================================
prompt
create or replace procedure mcsods.PROC_GPS_GET_TRUCADDR_DISTANCE --���㳵��վ֮�����
(
truck_mc_in in varchar2, 
address_in in varchar2, 
distance_out out number
) as

truck_gsmhm_out varchar2(20);
truck_lng_out number;
truck_lat_out number;
address_lng_out number;
address_lat_out number;

begin
  
  proc_gps_mcs_get_truck_gsmhm(
  truck_mc_in,
  truck_gsmhm_out
  );

  proc_gps_mcs_get_truck_gps(
  truck_gsmhm_out,
  truck_lng_out,
  truck_lat_out
  );

  proc_gps_mcs_get_address(
  address_in,
  address_lng_out,
  address_lat_out
  );
  
  proc_gps_get_distance(
  truck_lng_out,
  truck_lat_out,
  address_lng_out,
  address_lat_out,
  distance_out
  );
  
  
end PROC_GPS_GET_TRUCADDR_DISTANCE;
/

prompt
prompt Creating procedure PROC_GPS_GET_TRUCK_DISTANCE
prompt ==============================================
prompt
create or replace procedure mcsods.PROC_GPS_GET_TRUCK_DISTANCE  --�����г��켣����һ������һ������
(
accept_gsmhm_in in varchar2, 
res_distance out number
) as

truck_lng1 number;
truck_lat1 number;
truck_lng2 number;
truck_lat2 number;

TYPE cur_result_type IS REF CURSOR;
cur_res cur_result_type;

begin
  
  open cur_res for  --��ʼ���α�
  select accept_e,accept_n from (
  select to_number(accept_e) as accept_e,
  to_number(accept_n) as accept_n
  from mcsstg.gps_mcs_gps_yyyymmdd
  where trim(accept_gsmhm)= accept_gsmhm_in
  order by accept_time desc)
  where rownum<3 ; 
  
  fetch cur_res into truck_lng1,truck_lat1;
  --dbms_output.put_line('����ֵ'||truck_lng1||'#'||truck_lat1);
  fetch cur_res into truck_lng2,truck_lat2;
  --dbms_output.put_line('����ֵ'||truck_lng2||'#'||truck_lat2);
  close cur_res;  --�ر��α�
  
  proc_gps_get_distance(
  truck_lng1,
  truck_lat1,
  truck_lng2,
  truck_lat2,
  res_distance
  );


end PROC_GPS_GET_TRUCK_DISTANCE;
/

prompt
prompt Creating procedure PROC_GPS_GET_ACCEPT_TIME
prompt ===========================================
prompt
create or replace procedure mcsods.PROC_GPS_GET_ACCEPT_TIME  --ͨ�����ƺź�վ���ж��Ƿ�վ�����ص�վʱ��
( 
truck_mc_in in varchar2, 
address_in in varchar2, 
accept_time_out out date
) as

--����γ
truck_lng1 number;
truck_lat1 number;

--��������
truck_distance number;

--��վ����
address_distance number;

--gsmhm
accept_gsmhm_in varchar2(20);

begin
  
  --��ȡgsmhm
  proc_gps_mcs_get_truck_gsmhm(
  truck_mc_in,
  accept_gsmhm_in
  );

  proc_gps_get_truck_distance( 
  accept_gsmhm_in,
  truck_distance
  );

  proc_gps_get_trucaddr_distance(
  truck_mc_in,
  address_in,
  address_distance
  );

  proc_gps_mcs_get_truck_gps(
  accept_gsmhm_in,
  truck_lng1,
  truck_lat1
  );

  --�жϳ��켣С�ڵ���5�ף�����վ����С�ڵ���50��
  if truck_distance <= 0.005 and address_distance <= 0.05 then
    select accept_time into accept_time_out
    from mcsstg.gps_mcs_gps_yyyymmdd
    where accept_gsmhm = accept_gsmhm_in
    and to_number(accept_e) = truck_lng1
    and to_number(accept_n) = truck_lat1;
    --else 
     --dbms_output.put_line('����ֵ'||truck_distance);
     --dbms_output.put_line('����ֵ'||address_distance);
  end if;

end PROC_GPS_GET_ACCEPT_TIME;
/


spool off
