---------选择2018-01-01~2018-07-31号七个与的所有数据作为基本分析的客户群
select * from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31';

---------------------基本情况-----------------
----每个月的注册情况
select  month(reg_dt) as mth,count(1) from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' group by month(reg_dt);
----人口学属性 upf_first_tags_basics
--实名
select realnm_st,count(1) as num  from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' group by realnm_st;
--实名客户的年龄分布
select age,count(1) as num  from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' and realnm_st=1 group by age;   
--实名客户的性别分布
select gender,count(1) as num  from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' and realnm_st=1 group by gender;
--实名客户的星座分布
select constell,count(1) as num  from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' and realnm_st=1 group by constell;
--实名客户的籍贯城市分布top10
select birth_city,count(1) as num  from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' and realnm_st=1 group by birth_city order by num DESC;
--实名客户的籍贯省份分布
select prv_name,count(1) as num from
    (select cdhd_usr_id,birth_city,prv_name from upf_first_tags_basics A 
    left join (select distinct city_name,prv_name from map_admin_city_lvl) B 
    on A.birth_city=B.city_name
    where A.reg_dt>='2018-01-01' and A.reg_dt<='2018-07-31' and realnm_st=1
    )T group by prv_name;
--运营商分布
select carrier,count(1) as num  from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' group by carrier;
--运营商归属地 top10
select mobile_city,count(1) as num  from upf_first_tags_basics 
    where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' group by mobile_city order by num DESC;





---------------------绑卡信息-----------------
---hv_tbl_chacc_cdhd_card_bind_inf
select count(distinct  cdhd_usr_id) as num  from 
(select A.cdhd_usr_id,B.mth from 
    (select cdhd_usr_id from upf_first_tags_basics 
        where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' and realnm_st=1
    )A 
    left join
    (select cdhd_usr_id, month(rec_crt_ts)  as mth, count(1) as num 
        from hv_tbl_chacc_cdhd_card_bind_inf where card_bind_st=0  and  
        to_date(rec_crt_ts)>='2018-01-01'  and to_date(rec_crt_ts)<='2018-07-31'
        group by cdhd_usr_id,month(rec_crt_ts) 
    )B
    on A.cdhd_usr_id=B.cdhd_usr_id
)T where mth<=1;

---实名客户的绑卡数目分布
select  card_num,count(1) as num from 
(select A.cdhd_usr_id,case when nn is not null then nn else 0 end as card_num
from 
    (select cdhd_usr_id from upf_first_tags_basics 
        where reg_dt>='2018-01-01' and reg_dt<='2018-07-31' and realnm_st=1
    )A 
    left join
    (select cdhd_usr_id,count(distinct bind_card_no) as nn 
        from hv_tbl_chacc_cdhd_card_bind_inf  where card_bind_st=0  and 
        to_date(rec_crt_ts)>='2018-01-01'  and to_date(rec_crt_ts)<='2018-07-31' group by cdhd_usr_id 
    )B
    on A.cdhd_usr_id=B.cdhd_usr_id
)T group by card_num;




---------------------神策数据-----------------
---登录基本信息
--每个月的登录人数（不包括注册当天，计算占比）
select mth,count(distinct cdhd_usr_id) as num from
    (select A.cdhd_usr_id,B.mth from 
        (select cdhd_usr_id,reg_dt from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
        left join 
        (select cdhd_usr_id,month(part_day) as mth,part_day  from hv_tbl_events_stat 
            where part_day>='2018-01-01' and part_day<='2018-07-31'
        )B on A.cdhd_usr_id=B.cdhd_usr_id 
        where B.part_day>A.reg_dt
    )T group by mth;

----设备
--手机型号(2017.7.31日，最近一次使用的设备)
select phone_type,count(1) as num from
(select A.cdhd_usr_id,B.p__manufacturer as phone_type from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
    left join 
    (select cdhd_usr_id,p__manufacturer from hv_tbl_events_stat_all where  part_day='2018-07-31') B 
    on A.cdhd_usr_id=B.cdhd_usr_id
)T group by phone_type;

----登录
--登录的天数分布
select num_days,count(1) as num from 
    (select A.cdhd_usr_id,case when num is not null then num else 0 end as num_days from 
        (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
        left join 
        (select cdhd_usr_id,count(1) as num from 
            (select cdhd_usr_id from hv_tbl_events_stat 
                where part_day>='2018-01-01' and part_day<='2018-07-31'
            )a1 group by cdhd_usr_id
        )B
        on A.cdhd_usr_id=B.cdhd_usr_id
    )T group by num_days;
--登录频次（平均每天登录的次数）
select num_cnt,count(1) as num from 
(select A.cdhd_usr_id,round(num,1) as num_cnt from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
    left join
    (select cdhd_usr_id,avg(cnt_start) as num from hv_tbl_events_stat 
        where part_day>='2018-01-01' and part_day<='2018-07-31' group by cdhd_usr_id
    )B on A.cdhd_usr_id=B.cdhd_usr_id
)T group by num_cnt;
--登录的省份(2017.7.31日，最近一次登录地址)
select  prv_name,count(1) as num from
(select A.cdhd_usr_id,B.p__city as city,
    case when C.prv_name is not null then C.prv_name else 
        (case when p__city is not null then '其他' end) end as prv_name
from
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
    left join 
    (select cdhd_usr_id,p__city from hv_tbl_events_stat_all where  part_day='2018-07-31') B 
    on A.cdhd_usr_id=B.cdhd_usr_id
    left join (select distinct city_name,prv_name from map_admin_city_lvl) C 
    on B.p__city=regexp_replace(C.city_name,'市','')
) T group by prv_name;
--登录的城市(2017.7.31日，最近一次登录地址) top10
select  city,count(1) as num from
(select A.cdhd_usr_id,B.p__city as city from
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
    left join 
    (select cdhd_usr_id,p__city from hv_tbl_events_stat_all where  part_day='2018-07-31') B 
    on A.cdhd_usr_id=B.cdhd_usr_id
) T group by city order by num DESC;
--登录活跃的时间点
select ts,count(1) as num from 
(select explode(B.act_period)  as ts from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
    left join 
    (select cdhd_usr_id,act_period from hv_tbl_events_stat 
        where part_day>='2018-01-01' and part_day<='2018-07-31'
    ) B 
    on A.cdhd_usr_id=B.cdhd_usr_id
)T group by ts ;

--点击的主要功能
select fun,count(1) as num from 
(select explode(B.function_array)  as fun from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
    left join 
    (select cdhd_usr_id,function_array from hv_tbl_events_stat 
        where part_day>='2018-01-01' and part_day<='2018-07-31'
    ) B 
    on A.cdhd_usr_id=B.cdhd_usr_id
)T group by fun  order by  num DESC;
--主要成功操作
select suc,count(1) as num from 
(select explode(B.succ_array)  as suc from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A 
    left join 
    (select cdhd_usr_id,succ_array from hv_tbl_events_stat 
        where part_day>='2018-01-01' and part_day<='2018-07-31'
    ) B 
    on A.cdhd_usr_id=B.cdhd_usr_id
)T group by suc   order by num DESC ;





---------------------交易数据-----------------
--只保留qr,ac,及手机闪付渠道的交易数据
--proc_st='00'交易成功

--每个月的交易分布（累计人数的占比）目前好像只有5-7月数据
select mth,count(distinct cdhd_usr_id) as num  from 
(select A.cdhd_usr_id,B.part_dt, month(B.part_dt) as mth from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
    left join 
    (select  cdhd_usr_id,part_dt  from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
        (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
    )B on A.cdhd_usr_id=B.cdhd_usr_id 
)T group by mth;
--交易的天数分布
select num_day,count(1) as num  from 
(select A.cdhd_usr_id,B.num_day from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
    left join 
    (select  cdhd_usr_id,count(distinct part_dt) as num_day from tds.hv_allmerge 
        where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
        (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
        group by cdhd_usr_id
    )B on A.cdhd_usr_id=B.cdhd_usr_id 
)T group by num_day;

--交易频数
select num_dt,count(1) as num  from 
(select A.cdhd_usr_id,B.num_dt from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
    left join 
    (select  cdhd_usr_id,count(1) as num_dt from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
        (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
        group by cdhd_usr_id
    )B on A.cdhd_usr_id=B.cdhd_usr_id 
)T group by num_dt;

--交易频率（平均每天交易次数）
select num_dtt,count(1) as num  from 
(select A.cdhd_usr_id,round(B.num_dtt,1) as num_dtt  from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
    left join 
    (select cdhd_usr_id,avg(num) as num_dtt from 
        (select  cdhd_usr_id,part_dt, count(1) as num from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
            (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
            group by cdhd_usr_id,part_dt
        )b1 group by cdhd_usr_id
    )B on A.cdhd_usr_id=B.cdhd_usr_id 
)T group by num_dtt;

--交易时点分布
select hr,count(1) as num_hr  from 
(select A.cdhd_usr_id,hr  from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
    left join 
    (select  cdhd_usr_id,hour(rec_crt_ts)  as hr from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
        (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
    )B on A.cdhd_usr_id=B.cdhd_usr_id 
)T group by hr;

--交易的类型
select C.pay_way_cd_cn,num  from 
(select pay_way_cd,count(1) as num  from 
    (select A.cdhd_usr_id,B.pay_way_cd from 
        (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
        left join 
        (select  cdhd_usr_id,pay_way_cd from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
            (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
        )B on A.cdhd_usr_id=B.cdhd_usr_id 
    )T group by pay_way_cd
)TT left join tds.hv_pay_way_cd C 
on TT.pay_way_cd=C.pay_way_cd;

--交易的场景
select C.buss_cd_cn,num  from 
(select buss_cd,count(1) as num  from 
    (select A.cdhd_usr_id,B.buss_cd from 
        (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
        left join 
        (select  cdhd_usr_id,buss_cd from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
            (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
        )B on A.cdhd_usr_id=B.cdhd_usr_id 
    )T group by buss_cd
)TT left join tds.hv_buss_cd C 
on TT.buss_cd=C.buss_cd;

--交易成功的金额分布
select pay_trans_at,count(1) as num  from 
(select A.cdhd_usr_id,B.pay_trans_at from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
    left join 
    (select  cdhd_usr_id,
            case when pay_trans_at<0 then '<0' 
                 when pay_trans_at=0 then '0'
                 when pay_trans_at>0 and pay_trans_at<=100 then '(0,1]'
                 when pay_trans_at>100 and pay_trans_at<=1000 then '(1,10]'
                 when pay_trans_at>1000 and pay_trans_at<=5000 then '(10,50]'
                 when pay_trans_at>5000 and pay_trans_at<=10000 then '(50,100]'
                 when pay_trans_at>10000 and pay_trans_at<=20000 then '(100,200]'
                 when pay_trans_at>20000 and pay_trans_at<=50000 then '(200,500]'
                 when pay_trans_at>50000 and pay_trans_at<=100000 then '(500,1000]'
                 when pay_trans_at>100000 and pay_trans_at<=500000 then '(1000,5000]'
                 when pay_trans_at>500000 and pay_trans_at<=1000000 then '(5000,10000]'
                 when pay_trans_at>1000000 and pay_trans_at<=5000000 then '(10000,50000]'
                 when pay_trans_at>5000000 and pay_trans_at<=10000000 then '(50000,100000]'
                 when pay_trans_at>10000000 then '>100000' 
            end as pay_trans_at
        from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
        (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
        and proc_st='00'
    )B on A.cdhd_usr_id=B.cdhd_usr_id
)T group by pay_trans_at;

---交易成功的优惠金额使用
select pay_discount_at,count(1) as num  from 
(select A.cdhd_usr_id,B.pay_discount_at from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-01-01' and reg_dt<='2018-07-31')A
    left join 
    (select  cdhd_usr_id,
            case when pay_discount_at<0 then '<0' 
                 when pay_discount_at=0 then '0'
                 when pay_discount_at>0 and pay_discount_at<=100 then '(0,1]'
                 when pay_discount_at>100 and pay_discount_at<=1000 then '(1,10]'
                 when pay_discount_at>1000 and pay_discount_at<=2000 then '(10,20]'
                 when pay_discount_at>2000 and pay_discount_at<=3000 then '(20,30]'
                 when pay_discount_at>3000 and pay_discount_at<=4000 then '(30,40]'
                 when pay_discount_at>4000 and pay_discount_at<=5000 then '(40,50]'
                 when pay_discount_at>5000 and pay_discount_at<=10000 then '(50,100]'
                 when pay_discount_at>10000 and pay_discount_at<=20000 then '(100,200]'
                 when pay_discount_at>20000 and pay_discount_at<=30000 then '(200,300]'
                 when pay_discount_at>30000 and pay_discount_at<=40000 then '(300,400]'
                 when pay_discount_at>40000 and pay_discount_at<=50000 then '(400,500]'
                 when pay_discount_at>50000 and pay_discount_at<=100000 then '(500,1000]'
                 when pay_discount_at>100000 then '>1000'
            end as pay_discount_at
        from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
        (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
        and proc_st='00'
    )B on A.cdhd_usr_id=B.cdhd_usr_id 
)T group by pay_discount_at;

--第一笔交易成功的类型(5-7月)
select pay_way_cd_cn,count(1) as num  from 
(select A.cdhd_usr_id,B.pay_way_cd,C.pay_way_cd_cn from 
    (select cdhd_usr_id from upf_first_tags_basics where reg_dt>='2018-05-01' and reg_dt<='2018-07-31')A
    left join 
    (select cdhd_usr_id,pay_way_cd from 
        (select  cdhd_usr_id,pay_way_cd,row_number() over(partition by cdhd_usr_id order by rec_crt_ts ASC ) as rn 
            from tds.hv_allmerge where part_dt>='2018-05-01' and part_dt<='2018-07-31' and cdhd_usr_id is not null and 
                (qr_trans_idx  is not null or ac_trans_idx is not null or pay_way_cd='004001' or pay_way_cd='004002' or pay_way_cd='004') 
                and proc_st='00'
        )b1  where rn=1
    )B on A.cdhd_usr_id=B.cdhd_usr_id
    left join tds.hv_pay_way_cd C
    on B.pay_way_cd=C.pay_way_cd
)T group by pay_way_cd_cn;



-----------------------------------------------------------------
---注册与未注册客户的比值
select  part_dt,sum(case when cdhd_usr_id is null then 1 else 0 end )/count(1)  as per from tds.hv_allmerge 
    where part_dt>='2018-07-01' and part_dt<='2018-07-31' and proc_st='00' 
    group  by part_dt;


--------------未注册客户-------------------------------------------
---成功交易的卡号数目
select  part_dt,count(distinct card_no) as num   from tds.hv_allmerge 
    where part_dt>='2018-07-01' and part_dt<='2018-07-31'  and cdhd_usr_id is  null  and proc_st='00' group  by part_dt;
--日均五千万左右，取一日的数据进行分析（2018-07-01)

--最近一次的成功交易分公司
select ins_cn_nm,count(1) as num from 
(select A.card_no,B.cup_branch_ins_id_cd,C.ins_cn_nm from 
    (select  distinct card_no  from tds.hv_allmerge where part_dt='2018-07-01' and cdhd_usr_id is null and proc_st='00')A 
    left join 
    (select card_no,cup_branch_ins_id_cd from 
        (select  card_no,cup_branch_ins_id_cd,row_number() over(partition by card_no order by rec_crt_ts DESC) as rn   
            from tds.hv_allmerge where part_dt>='2018-07-01' and  part_dt<='2018-07-31' and cdhd_usr_id is  null
            and proc_st='00'
        )b1 where rn=1
    )B on A.card_no=B.card_no
    left join HV_TBL_CHMGM_INS_INF C 
    on  B.cup_branch_ins_id_cd=C.ins_id_cd
)T group by ins_cn_nm;

--最近一个月的成功交易的次数
select pay_num,count(1) as num from 
(select A.card_no,B.pay_num from 
    (select  distinct card_no  from tds.hv_allmerge where part_dt='2018-07-01' and cdhd_usr_id is null and proc_st='00')A 
    left join 
    (select  card_no,count(1) as pay_num 
            from tds.hv_allmerge where part_dt>='2018-07-01' and  part_dt<='2018-07-31' and cdhd_usr_id is  null
            and proc_st='00' group by card_no
    )B on A.card_no=B.card_no
)T group by pay_num;

---交易成功金额的分布
select pay_trans_at,count(1) as num  from 
(select A.card_no,B.pay_trans_at from 
    (select  distinct card_no  from tds.hv_allmerge where part_dt='2018-07-01' and cdhd_usr_id is null and proc_st='00')A 
    left join 
    (select  card_no,
            case when pay_trans_at<0 then '<0' 
                 when pay_trans_at=0 then '0'
                 when pay_trans_at>0 and pay_trans_at<=100 then '(0,1]'
                 when pay_trans_at>100 and pay_trans_at<=1000 then '(1,10]'
                 when pay_trans_at>1000 and pay_trans_at<=5000 then '(10,50]'
                 when pay_trans_at>5000 and pay_trans_at<=10000 then '(50,100]'
                 when pay_trans_at>10000 and pay_trans_at<=20000 then '(100,200]'
                 when pay_trans_at>20000 and pay_trans_at<=50000 then '(200,500]'
                 when pay_trans_at>50000 and pay_trans_at<=100000 then '(500,1000]'
                 when pay_trans_at>100000 and pay_trans_at<=500000 then '(1000,5000]'
                 when pay_trans_at>500000 and pay_trans_at<=1000000 then '(5000,10000]'
                 when pay_trans_at>1000000 and pay_trans_at<=5000000 then '(10000,50000]'
                 when pay_trans_at>5000000 and pay_trans_at<=10000000 then '(50000,100000]'
                 when pay_trans_at>10000000 then '>100000' 
            end as pay_trans_at
        from tds.hv_allmerge where part_dt>='2018-07-01' and  part_dt<='2018-07-31' and cdhd_usr_id is  null
            and proc_st='00'
    )B on A.card_no=B.card_no
)T group by pay_trans_at;