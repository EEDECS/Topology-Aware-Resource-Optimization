set Hours 		ordered;							#Time slots (24 hours)
set EVs 		ordered;							#Electric vehicles
set Household 	ordered;							#House holds
set Cluster		ordered;							#Set of cluster of houses
#set ChargerType;							
set EVHousehold {Household} within EVs;				#EV associated with each consumer
set ClusterHouse {Cluster}	within Household;		#Consumers in each cluster

param Demand {EVs};									#Forecasted demand of the EV 
param DemandHousehold {Household};					#Forecasted demand of the household
param SOC_Final {EVs};								#Consumer provided State of Charge (SOC)
param Charger {EVs};

param Energy_price {Hours};							#Day-Ahead energy price

param Consumer {EVs, Hours};						#Consumer preferred timing for charging

var Schedule { EVs, Hours} >= 0;					#Schedule for each EV 


# Minimize the cost of charging for all the EVs
minimize Cost :											
sum {j in EVs, k in Hours}  Schedule [j, k]*Energy_price[k];

#Consumer preferred timing
subject to Consumer_Preference {j in EVs, k in Hours}:	
Schedule[j,k] <= (if Consumer[j,k] = 1  then Demand[j] else 0);

#Meeting the EV demand
subject to Equipment_Demand {j in EVs}:					
sum {k in Hours} Schedule [j,k] >= SOC_Final[j]*Demand[j];

#EV rating constraint
subject to EV_Rating_Constraint {j in EVs,k in Hours}:	
Schedule[j,k] <= ( if  Demand [j] = 0 then 0 else ( if Charger[j]=1 then 1.92 else if Charger[j]= 2 then 6.6 else 8.52));

#Restricting the connected EVs from a single consumer in each hour
subject to Household_Capacity {h in Household, k in Hours}:	
sum {j in EVHousehold[h]} Schedule [j,k] <= 0.15*(DemandHousehold[h]) ;

#Restricting the connected EVs from a consumer cluster
subject to Cluster_Capacity {c in Cluster, k in Hours}:
sum {h in ClusterHouse[c], j in EVHousehold[h]} Schedule[j,k] <= 0.1*(sum {h in ClusterHouse[c]} DemandHousehold[h]); 