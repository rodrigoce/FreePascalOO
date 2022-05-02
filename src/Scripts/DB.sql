--** CRIAR O BANCO **
-- abrir o ISQL TOOL e
-- create database 'd:\rodrigo\freepascaloo\db\Aplicacao.fdb';

create table PRODUTO
(
  ID Integer not null,
  DATA_CRIACAO Timestamp,
  DATA_ATUALIZACAO Timestamp,
  DATA_EXCLUSAO Timestamp,
  ID_USER_CRIACAO Integer,
  ID_USER_ATUALIZACAO Integer,
  ID_USER_EXCLUSAO Integer,
  NOME VarChar(60)
);

alter table  PRODUTO add constraint PRODUTO_PK primary key (ID);

 create sequence SEQUENCE_PRODUTO;
