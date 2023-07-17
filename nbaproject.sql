select *
from [portproj1.1]..nbaplayer
where player like 'Kobe%'
order by season asc

select player, season, pts/g as PointPerGame
from [portproj1.1]..nbaplayer
where player like 'LeBron%'
order by season asc

alter table nbaplayer
drop column PointPerGame

-- add one column stated as PointPerGame
alter table nbaplayer
add PointPerGame decimal(3,1);

update nbaplayer
set PointPerGame = pts/g

-- getting data from some of the popular player
select season, player, PointPerGame
from [portproj1.1]..nbaplayer
where player in ('LeBron James', 'Michael Jordan', 'Kobe Bryant', 'Stephen Curry', 'Kevin Durant')
order by player asc, season

--filter out PointPerGame as games played on that season is lower than 65 from those popular players
select age, player, PointPerGame
from [portproj1.1]..nbaplayer
where player in ('LeBron James', 'Michael Jordan', 'Kobe Bryant', 'Stephen Curry', 'Kevin Durant')
			 and g > 65
order by player asc, season


-- gather data on the amount of awards the players getting
with totalawardscte as (
select a.player, b.award, count(b.winner) as AwardsAmount
from [portproj1.1]..nbaplayer a
join [portproj1.1]..playerawards b
on a.player_id = b.player_id
and a.seas_id = b.seas_id
where b.player in ('LeBron James', 'Michael Jordan', 'Kobe Bryant', 'Stephen Curry', 'Kevin Durant')
             and b.winner =1
group by a.player, b.award
)

Select *
from totalawardscte

--create table

create table #selectedplayerawardstable
(
player nvarchar(255),
award nvarchar(255),
awardsamount int)

insert into #selectedplayerawardstable
select a.player, b.award, count(b.winner) as AwardsAmount
from [portproj1.1]..nbaplayer a
join [portproj1.1]..playerawards b
on a.player_id = b.player_id
and a.seas_id = b.seas_id
where b.player in ('LeBron James', 'Michael Jordan', 'Kobe Bryant', 'Stephen Curry', 'Kevin Durant')
             and b.winner =1
group by a.player, b.award

--total amount of awards by player
select player, sum(awardsamount) as totalawards
from #selectedplayerawardstable
group by player


select *
from #selectedplayerawardstable

-- remove duplicate as player have duplicated data if traded
with rownumcte as (
select *, 
	row_number () over (partition by  player_id, player, experience order by player_id) row_num
from [portproj1.1]..nbaplayer
)

select *
from rownumcte
where row_num > 1





--change the 'nba mvp' to 'nba season mvp'

select award,
case when award = 'nba mvp' then 'nba season mvp'
     when award = 'aba mvp' then 'aba season mvp'
	 else award
	 end
from [portproj1.1]..playerawards

update playerawards
set award = case when award = 'nba mvp' then 'nba season mvp'
                 when award = 'aba mvp' then 'aba season mvp'
		    else award
	   	    END

select distinct(award), count(award)
from [portproj1.1]..playerawards
group by award


-- total amount of points the players get throughout their career
select experience, player, sum(pts) over (partition by player order by experience) as AccumulatePoint
from [portproj1.1]..nbaplayer 
where player in ('LeBron James', 'Michael Jordan', 'Kobe Bryant', 'Stephen Curry', 'Kevin Durant')
order by player
