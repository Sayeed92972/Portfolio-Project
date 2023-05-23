--1.How many olympics games have been held?
select count(distinct games) 
from olympics_history;

--2.List down all Olympics games held so far.
select distinct games
from olympics_history;

--3.Mention the total no of nations who participated in each olympics game?
select games, count(distinct noc) as Total_no_of_Participated_Nations
from olympics_history
group by games;

--4.Which year saw the highest and lowest no of countries participating in olympics?
with all_countries as 
			(select games, nr.region
			from olympics_history as oh
			join olympics_history_noc_regions as nr on oh.noc=nr.noc
			group by games, nr.region),
	tot_countries as 
			(select games, count(1) as total_countries
			from all_countries
			group by games)
	select distinct
	concat(first_value(games) over(order by total_countries),' - ',
		   first_value(total_countries) over(order by total_countries))as Lowest_countries,
	concat(first_value(games) over(order by total_countries desc),' - ',
		  first_value(total_countries) over(order by total_countries desc)) as Highest_countries
	from tot_countries
	
--5.Which nation has participated in all of the olympic games?
with tot_countries as
		(select count(distinct games) as total_games
		from olympics_history),
	Countries as
		(select games, nr.region as country
		from olympics_history as oh
		join olympics_history_noc_regions as nr on oh.noc=nr.noc
		group by games,nr.region),
	Countries_participated as
		(select country, count(1) as total_participated_games
		from Countries
		group by country)
	select country,total_participated_games
	from countries_participated
	join tot_countries 
		on tot_countries.total_games=countries_participated.total_participated_games;

--6.Identify the sport which was played in all summer olympics.
with t1 as
		(select count(distinct games) as total_summer_games
		from olympics_history
		where season = 'Summer'),
	t2 as
		(select distinct sport, games
		from olympics_history
		where season = 'Summer'
		order by games),
	t3 as
		(select sport, count(games) as no_of_games
		from t2
		group by sport)
select *
from t3
join t1 on t1.total_summer_games = t3.no_of_games;


--7.Which Sports were just played only once in the olympics?
with t1 as
	(select distinct games, sport
	 from olympics_history),
	 t2 as
	 (select sport, count(1) as No_of_games
	 from t1
	 group by sport
	 )
	 select t2.*, t1.games
	 from t2
	 join t1 on t2.sport=t1.sport
	 where t2.no_of_games = 1
	 order by t1.sport;
	 
--8.Fetch the total no of sports played in each olympic games.
select distinct games, count(distinct sport) as Total_sports
from olympics_history
group by games
order by Total_sports desc;

--9.Fetch details of the oldest athletes to win a gold medal.
select name, sex, age, team, games, city, sport, event, medal
from olympics_history
where medal = 'Gold' and max(age);

--10.Find the Ratio of male and female athletes participated in all olympic games.
select 'Male Count' as metric,
		count(case when sex = 'M' then 1 end) as male_count,
		round((count(case when sex = 'M' then 1 end)::numeric/count(*))*100,2) as ratio
from olympics_history
union
select 'Female Count' as metric,
		count(case when sex = 'F' then 1 end) as female_count,
		round((count(case when sex = 'F' then 1 end)::numeric/count(*))*100,2) as ratio
from olympics_history;

--11.Fetch the top 5 athletes who have won the most gold medals.
select name, count(medal) as total_gold_medal
from olympics_history
where medal = 'Gold'
group by name, medal
order by count(medal) desc
limit 5;

--12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select name, count(medal) as total_gold_medal
from olympics_history
where medal = 'Silver'
group by name, medal
order by count(medal) desc
limit 5;

select name, count(medal) as total_gold_medal
from olympics_history
where medal = 'Bronze'
group by name, medal
order by count(medal) desc
limit 5;

--13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
select noc, count(medal) as total_medal
from olympics_history
group by noc
order by count(medal) desc
limit 5;

--14.List down total gold, silver and broze medals won by each country.
select noc,
	count(case when medal='Gold'then 1 end) as Total_gold_medal,
	count(case when medal='Silver'then 1 end) as Total_silver_medal,
	count(case when medal='Bronze'then 1 end) as Total_bronze_medal
from olympics_history
group by noc

--15.List down total gold, silver and broze medals won by each country corresponding to each olympic games.
select noc,
       games,
       count(*) filter (where medal = 'Gold') as Total_gold_medal,
       count(*) filter (where medal = 'Silver') as Total_silver_medal,
       count(*) filter (where medal = 'Bronze') as Total_bronze_medal
from olympics_history
group by noc, games;

--16.Identify which country won the most gold, most silver and most bronze medals in each olympic games.
select games,
    max(case when medal='Gold'then noc end) as Most_gold_medal,
	max(case when medal='Silver'then noc end) as Most_silver_medal,
	max(case when medal='Bronze'then noc end) as Most_bronze_medal
from olympics_history
group by games;

--17.Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
select games,
    max(case when rank='1' then noc end) as country_with_most_gold,
	max(case when rank='2' then noc end) as country_with_most_silver,
	max(case when rank='3' then noc end) as country_with_most_bronze,
	max(noc) as country_with_most_medals
from (
    select games,
           noc,
           rank() over (partition by games, medal order by count(*) desc) as rank
    from olympics_history
    group by games, noc, medal
) as ranks
where rank <= 3
group by games;

--18.Which countries have never won gold medal but have won silver/bronze medals?
select noc
from olympics_history
group by noc
having count(distinct case when medal = 'Gold' then games end)=0
and count(distinct case when medal in ('Silver','Bronze') then games end) = count(distinct games);

--19.In which Sport/event, India has won highest medals.
SELECT event
FROM (
    SELECT event, COUNT(*) AS medal_count
    FROM olympics_history
    WHERE noc = 'IND'
    GROUP BY event
    ORDER BY COUNT(*) DESC
    LIMIT 1
) AS subquery;

SELECT sport
FROM (
    SELECT sport, COUNT(*) AS medal_count
    FROM olympics_history
    WHERE noc = 'IND'
    GROUP BY sport
    ORDER BY COUNT(*) DESC
    LIMIT 1
) AS subquery;

--20.Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
select games, count(medal)
from olympics_history
where sport='Hockey'
and noc='IND'
group by games












