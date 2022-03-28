CREATE TABLE Group
(
group_id INT PRIMARY KEY
);

CREATE TABLE Company
(
company_id INT PRIMARY KEY,
group_id INT NOT NULL,

FOREIGN KEY(group_id) REFERENCES Group(group_id)
);

CREATE TABLE Company_Structure
(
company_id INT NOT NULL,
super_company_id INT NOT NULL,

PRIMARY KEY(company_id, super_company_id),
FOREIGN KEY (company_id) REFERENCES Company(company_id),
FOREIGN KEY (super_company_id) REFERENCES Company(company_id)
);

CREATE TABLE Plant
(
plant_id INT PRIMARY KEY,
company_id INT NOT NULL,

FOREIGN KEY(company_id) REFERENCES Company(company_id)
);

CREATE TABLE Item
(
item_id INT PRIMARY KEY,
plant_id INT NOT NULL,

FOREIGN KEY(plant_id) REFERENCES Plant(plant_id)
);