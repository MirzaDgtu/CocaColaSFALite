alter table COLA_SFA_Orders alter column CLIENTID varchar(50) Not Null
alter table COLA_SFA_Orders add FolioUID float Null
alter table COLA_SFA_Orders add FolioOrderUID float Null

alter table COLA_SFA_Order_Details alter column CLIENTID varchar(50) Not Null