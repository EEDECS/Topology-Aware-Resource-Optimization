set Equipments ordered;
set Hours ordered;

param Demand {Equipments};
param Rating {Equipments};
param Flexibility {Equipments};

param Energy_price {Hours};
param Consumer {Equipments, Hours};

var Schedule {Equipments, Hours} >= 0;

minimize Cost :
sum {i in Equipments, j in Hours}  Schedule [i, j] * Energy_price[j];


subject to Equipment_Demand {i in Equipments}:
sum {j in Hours} Consumer[i,j]*Schedule [i,j] >= Demand[i];


subject to Production_Capacity {j in Hours}:
sum {i in Equipments} Schedule[i,j] <= 0.1*(sum {i in Equipments} Demand[i]);

subject to Equipment_Capacity {i in Equipments, j in Hours}:
Schedule[i,j] <= Rating[i];

subject to Equipment_Flexibility {i in Equipments, j in Hours}:
Schedule[i,j] >= (if Flexibility[i] = 0 then Consumer[i,j]*Rating[i] else 0);