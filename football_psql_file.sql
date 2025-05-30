CREATE TABLE football_players (
    "Player" TEXT,
    "Club" TEXT,
    "Value" BIGINT,
    "Age" INTEGER,
    "Position" TEXT,
    "Nation" TEXT,
    "Contract Years" INTEGER,
    "League" TEXT,
    "Matches Played" INTEGER,
    "Total Mins" INTEGER,
    "Total Mins/90" DOUBLE PRECISION,
    "Goals" INTEGER,
    "Assists" INTEGER,
    "Yellow Cards" INTEGER,
    "Red Cards" INTEGER,
    "xG" DOUBLE PRECISION,
    "xA" DOUBLE PRECISION,
    "Pass Percentage" DOUBLE PRECISION
);

select * from football_players limit 99;

select count(*) from football_players;

select distinct("Position") from football_players;

-- Creating separate tables based on the players position
create table attack_players as 
select * from football_players where "Position"='attack';
select count(*) from attack_players; -- counting players

create table midfield_players as 
select * from football_players where "Position"='midfield';
select count(*) from midfield_players; -- counting players

create table defense_players as 
select * from football_players where "Position"='Defender';
select count(*) from defense_players; -- counting players

create table gk_players as 
select * from football_players where "Position"='Goalkeeper';
select count(*) from gk_players; -- counting players
-- There are only 10 goal keepers here

-- Top 10 most valuable players in all formats
select "Player", "Value", "Club", "Age", "Position"
from football_players
order by "Value" desc
limit 10;

-- Top 3 Most valuable attacker,midfileders, defenders and goalkeepers
select "Player", "Value", "Club", "Nation"
from attack_players
order by "Value" desc
limit 3;

select "Player", "Value", "Club", "Nation"
from midfield_players
order by "Value" desc
limit 3;

select "Player", "Value", "Club", "Nation"
from defense_players
order by "Value" desc
limit 3;

select "Player", "Value", "Club","Nation"
from gk_players
order by "Value" desc
limit 3;

-- Average market value by position
select "Position", ROUND(AVG("Value")) as avg_value
from football_players
group by "Position"
order by avg_value desc;

-- Top performing youngsters in all positions
select "Player", "Age", "Value", "Goals", "Assists"
from football_players
where "Age" < 21
order by "Value" desc
limit 10;

-- performace metrics
select "Player", "Goals", "Assists", "xG", "xA",
       ("Goals" * 2 + "Assists" * 2 + "xG" + "xA") AS performance_score,
       "Value"
from football_players
order by performance_score desc;

-- Low value player
select * from football_players
order by "Value" asc
limit 1;



-- Undervalued Talented Players
select "Player", "xG", "xA", "Value"
from football_players
where "Value" < 15000000 and "xG" > 10
order by "xG" desc;

-- Players with highest passing rate
select "Player", "Pass Percentage", "Position", "Value"
from football_players
where "Pass Percentage" is not null
order by "Pass Percentage" desc
limit 10;

-- Players with highest market value with high cards 
select "Player", "Yellow Cards", "Red Cards", "Value"
from football_players
where "Yellow Cards" > 5 or "Red Cards" > 1
order by "Value" desc;


-- Players with more minutes and their values
select "Player", "Total Mins", "Value", "Goals", "Assists"
from football_players
where "Total Mins" > 2000
order by "Value" desc;

-- League players with average market value
select "League", count(*) as players, ROUND(avg("Value")) AS avg_value
from football_players
group by "League"
order by avg_value desc;

-- Age effects on market 
SELECT "Age", ROUND(AVG("Value")) AS avg_value
FROM football_players
GROUP BY "Age"
ORDER BY "avg_value" desc;

-- Avergae values by nations
select "Nation", count(*) as num_players, ROUND(avg("Value")) as avg_value
from football_players
group by "Nation"
order by avg_value desc
limit 30;

-- club and their total investments on players
select "Club", count(*) as players, sum("Value") as total_value
from football_players
group by "Club"
order by total_value desc;

-- Age groups among players
select 
  case 
    when "Age" < 21 then 'Under 21'
    when "Age" between 21 and 25 then '21-25'
    when "Age" between 26 and 30 then '26-30'
	when "Age" between 31 and 35 then '31-35' 
    else '41+' 
  end as age_group,
  count(*) as total_players,
  ROUND(avg("Value")) as avg_market_value
from football_players
group by age_group
order by avg_market_value desc;

-- Top Scorers in different Leagues
select "League", "Player", "Goals"
from (
  select *, row_number() over(partition by "League" order by "Goals" desc) as rn
  from football_players
) t
where rn = 1;

-- Players Assumed as over valued
select "Player", "Value", "Goals", "xG"
from football_players
where "Value" > 40000000 and "Goals" < 5
order by "Value" desc;

-- Players with highest contract years
select "Player", "Club", "Contract Years", "Value"
from football_players
where "Contract Years" > 3
order by "Value" desc;

-- Player Durability among many matches
select "Player", "Matches Played", "Total Mins", "Value"
from football_players
where "Matches Played" >= 38
order by "Value" desc;

-- Ranked Players by clubs
with ranked_players as (
    select "Player", "Club", "Value",
           row_number() over (partition by "Club" order by "Value" desc) as rank_in_club
    from football_players
)
select "Player", "Club", "Value"
from ranked_players
where rank_in_club = 1;

-- compare player values with others
select "Player", "Position", "Value",
       percent_rank() over (partition by "Position" order by "Value") as value_percentile
from football_players;

-- Age Groups buckets
with age_bucketed as (
  select *,
         case 
           when "Age" < 21 then 'Under 21'
           when "Age" between 21 and 25 then '21-25'
           when "Age" between 31 and 35 then '31-35' 
    	else '41+'  
         end as age_group
  from football_players
)
select age_group, count(*) as players, ROUND(avg("Value")) as avg_value
from age_bucketed
group by age_group
order by avg_value desc;

-- Best player values by nation
with ranked as (
  select *, 
         row_number() over (partition by "Nation" order by "Value" desc) as rn
  from football_players
)
select "Player", "Nation", "Value"
from ranked
where rn = 1;

-- Top assists in leagues
select "Player", "League", "Assists",
       dense_rank() over (partition by "League" order by "Assists" desc) as assist_rank
from football_players
where "Assists" is not null;


-- Most consistent performers
select "Player", "Goals", "xG", "Assists", "xA",
       abs(("Goals" + "Assists") - ("xG" + "xA")) as performance_deviation
from football_players
order by performance_deviation asc
limit 10;

-- Finding first and last players based on their goals and position types
-- Top scorers per position
with top_scorers as (
select "Position", "Player", "Goals", "Value","Age",
row_number() over (partition by "Position" order by "Goals" desc) as rn
from football_players
),
least_scorers as (
select "Position", "Player", "Goals", "Value","Age",
row_number() over (partition by "Position" order by "Goals" asc) as rn
from football_players
)
select 'Top Scorer' as category, "Position", "Player", "Goals", "Value","Age"
from top_scorers where rn = 1

union all

select 'Least Scorer' as category, "Position", "Player", "Goals", "Value","Age"
from least_scorers where rn = 1;

--END HERE --



















