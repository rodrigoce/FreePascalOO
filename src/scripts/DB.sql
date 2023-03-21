--** CRIAR O BANCO **
-- abrir o ISQL TOOL e
-- create database 'd:\rodrigo\freepascaloo\db\Aplicacao.fdb' default character set UTF8;

-- como o freepascal é UTF8, ao salvar strings, caracteres acentuados podem ter 2 ou mais bytes.
-- então por exemplo, um varchar(10) não UTF8 não cabe 10 caracteres se ele tiver acentos. 
-- isso é resolvido criando o DB UTF8.

CREATE TABLE SITUACAO_REG
(
  SITUACAO VARCHAR(4) NOT NULL,
  DESCRICAO VARCHAR(100) NOT NULL
);

alter table SITUACAO_REG add constraint SITUACAO_REG_PK primary key (SITUACAO);

INSERT INTO SITUACAO_REG (SITUACAO, DESCRICAO) VALUES ('A', 'Ativo');

INSERT INTO SITUACAO_REG (SITUACAO, DESCRICAO) VALUES ('I', 'Inativo');

INSERT INTO SITUACAO_REG (SITUACAO, DESCRICAO) VALUES ('E', 'Excluido');

create table USUARIO
(
  ID Integer not null,
  SITUACAO VarChar(4) not null,
  NRO_REVISAO Integer not null,
  NOME VarChar(60) not null,
  NOME_PP VarChar(60) not null,
  USER_NAME VarChar(30) not null,
  SENHA VarChar(200) not null,
  DATA_ULT_LOGIN Timestamp
);

alter table USUARIO add constraint USUARIO_PK primary key (ID);

alter table USUARIO add constraint SITUACAO_REG_USUARIO_FK foreign key (SITUACAO) references SITUACAO_REG (SITUACAO);

create sequence USUARIO_SEQUENCE;

create table USUARIO_LOG
(
  DATA_HORA Timestamp not null,
  OPERACAO varchar(1) not null,
  ID_USUARIO Integer,
  ID_PK Integer not null,
  NOME_COLUNA varchar(60) not null,
  VALOR_ANTERIOR varchar(500),
  VALOR_NOVO varchar(500),
  VALOR_ANTERIOR_B BLOB,
  VALOR_NOVO_B BLOB
);

alter table USUARIO_LOG add constraint USUARIO_USUARIO_LOG_FK foreign key (ID_USUARIO) references USUARIO (ID);
alter table USUARIO_LOG add constraint USUARIO_USUARIO_LOG2_FK foreign key (ID_PK) references USUARIO (ID);

create index USUARIO_LOG_IDX_DATA_HORA on USUARIO_LOG (DATA_HORA);

-------------------------------------------------

create table PRODUTO
(
  ID Integer not null,
  SITUACAO VarChar(4) not null,
  NRO_REVISAO Integer not null,
  CODIGO VarChar(20) not null,
  NOME VarChar(60) not null,
  NOME_PP VarChar(60) not null,
  PRECO_CUSTO Decimal(10, 2) not null,
  MARGEM_LUCRO Decimal(13, 5) not null,
  PRECO_VENDA Decimal(10, 2) not null
);

alter table PRODUTO add constraint PRODUTO_PK primary key (ID);

alter table PRODUTO add constraint SITUACAO_REG_PRODUTO_FK foreign key (SITUACAO) references SITUACAO_REG (SITUACAO);

create sequence PRODUTO_SEQUENCE;

create table PRODUTO_LOG
(
  DATA_HORA Timestamp not null,
  OPERACAO varchar(1) not null,
  ID_USUARIO Integer,
  ID_PK Integer not null,
  NOME_COLUNA varchar(60) not null,
  VALOR_ANTERIOR varchar(500),
  VALOR_NOVO varchar(500),
  VALOR_ANTERIOR_B BLOB,
  VALOR_NOVO_B BLOB
);

alter table PRODUTO_LOG add constraint USUARIO_PRODUTO_LOG_FK foreign key (ID_USUARIO) references USUARIO (ID);
alter table PRODUTO_LOG add constraint PRODUTO_PRODUTO_LOG2_FK foreign key (ID_PK) references PRODUTO (ID);

create index PRODUTO_LOG_IDX_DATA_HORA on PRODUTO_LOG (DATA_HORA);

--------------------------

create table FORNECEDOR
(
  ID Integer not null,
  SITUACAO VarChar(4) not null,
  NRO_REVISAO Integer not null,
  NOME VarChar(60) not null,
  NOME_PP VarChar(60) not null,
  CONTATOS VarChar(500) not null,
  CONTATOS_PP VarChar(500) not null
);

alter table FORNECEDOR add constraint FORNECEDOR_PK primary key (ID);

alter table FORNECEDOR add constraint SITUACAO_REG_FORNECEDOR_FK foreign key (SITUACAO) references SITUACAO_REG (SITUACAO);

create sequence FORNECEDOR_SEQUENCE;

create table FORNECEDOR_LOG
(
  DATA_HORA Timestamp not null,
  OPERACAO varchar(1) not null,
  ID_USUARIO Integer,
  ID_PK Integer not null,
  NOME_COLUNA varchar(60) not null,
  VALOR_ANTERIOR varchar(500),
  VALOR_NOVO varchar(500),
  VALOR_ANTERIOR_B BLOB,
  VALOR_NOVO_B BLOB
);

alter table FORNECEDOR_LOG add constraint USUARIO_FORNECEDOR_LOG_FK foreign key (ID_USUARIO) references USUARIO (ID);
alter table FORNECEDOR_LOG add constraint FORNECEDOR_FORNECEDOR_LOG2_FK foreign key (ID_PK) references FORNECEDOR (ID);

create index FORNECEDOR_LOG_IDX_DATA_HORA on FORNECEDOR_LOG (DATA_HORA);

----------

create table COMPRA
(
  ID Integer not null,
  SITUACAO VarChar(4) not null,
  NRO_REVISAO Integer not null,
  DATA Timestamp not null,
  ID_FORNECEDOR Integer not null,
  TOTAL_COMPRA Decimal(10, 2) not null,
  TOTAL_PRODUTOS Decimal(10, 2) not null,
  TOTAL_DESCONTOS Decimal(10, 2) not null,
  PER_DESCONTOS Decimal(10, 2) not null
);

alter table COMPRA add constraint COMPRA_PK primary key (ID);

alter table COMPRA add constraint SITUACAO_REG_COMPRA_FK foreign key (SITUACAO) references SITUACAO_REG (SITUACAO);

ALTER TABLE COMPRA ADD CONSTRAINT FORNECEDOR_COMPRA_FK FOREIGN KEY (ID_FORNECEDOR) REFERENCES FORNECEDOR (ID);

create sequence COMPRA_SEQUENCE;

create table COMPRA_LOG
(
  DATA_HORA Timestamp not null,
  OPERACAO varchar(1) not null,
  ID_USUARIO Integer,
  ID_PK Integer not null,
  NOME_COLUNA varchar(60) not null,
  VALOR_ANTERIOR varchar(500),
  VALOR_NOVO varchar(500),
  VALOR_ANTERIOR_B BLOB,
  VALOR_NOVO_B BLOB
);

alter table COMPRA_LOG add constraint USUARIO_COMPRA_LOG_FK foreign key (ID_USUARIO) references USUARIO (ID);
alter table COMPRA_LOG add constraint COMPRA_COMPRA_LOG2_FK foreign key (ID_PK) references COMPRA (ID);

create index COMPRA_LOG_IDX_DATA_HORA on COMPRA_LOG (DATA_HORA);

---

create table COMPRA_ITEM
(
  ID Integer not null,
  SITUACAO VarChar(4) not null,
  NRO_REVISAO Integer not null,
  ID_COMPRA Integer not null,
  ID_PRODUTO Integer not null,
  QTDE Decimal(10, 2) not null,
  VALOR Decimal(10, 2) not null,
  TOTAL Decimal(10, 2) not null
);

alter table COMPRA_ITEM add constraint COMPRA_ITEM_PK primary key (ID);

alter table COMPRA_ITEM add constraint SITUACAO_REG_COMPRA_ITEM_FK foreign key (SITUACAO) references SITUACAO_REG (SITUACAO);

ALTER TABLE COMPRA_ITEM ADD CONSTRAINT COMPRA_COMPRA_ITEM_FK FOREIGN KEY (ID_COMPRA) REFERENCES COMPRA (ID);

ALTER TABLE COMPRA_ITEM ADD CONSTRAINT PRODUTO_COMPRA_ITEM_FK FOREIGN KEY (ID_PRODUTO) REFERENCES PRODUTO (ID);

create sequence COMPRA_ITEM_SEQUENCE;

create table COMPRA_ITEM_LOG
(
  DATA_HORA Timestamp not null,
  OPERACAO varchar(1) not null,
  ID_USUARIO Integer,
  ID_PK Integer not null,
  NOME_COLUNA varchar(60) not null,
  VALOR_ANTERIOR varchar(500),
  VALOR_NOVO varchar(500),
  VALOR_ANTERIOR_B BLOB,
  VALOR_NOVO_B BLOB
);

alter table COMPRA_ITEM_LOG add constraint USUARIO_COMPRA_ITEM_LOG_FK foreign key (ID_USUARIO) references USUARIO (ID);
alter table COMPRA_ITEM_LOG add constraint COMPRA_ITEM_COMPRA_ITEM_LOG2_FK foreign key (ID_PK) references COMPRA_ITEM (ID);

create index COMPRA_ITEM_LOG_IDX_DATA_HORA on COMPRA_ITEM_LOG (DATA_HORA);

create table TEST
(
  ID Integer not null,
  SITUACAO VarChar(4) not null,
  NRO_REVISAO Integer not null,
  INT_32 Integer not null,
  INT_32_NULL_IF_ZERO Integer,
  DATE_TIME Timestamp not null,
  DATE_TIME_NULL_IF_ZERO Timestamp,
  STR VarChar(60) not null,
  STR_NULL_IF_ZERO VarChar(60),
  NUMERO_DECIMAL Decimal(18, 7) not null
);

alter table TEST add constraint TEST_PK primary key (ID);

alter table TEST add constraint SITUACAO_REG_TEST_FK foreign key (SITUACAO) references SITUACAO_REG (SITUACAO);

create sequence TEST_SEQUENCE;

create table TEST_LOG
(
  DATA_HORA Timestamp not null,
  OPERACAO varchar(1) not null,
  ID_USUARIO Integer,
  ID_PK Integer not null,
  NOME_COLUNA varchar(60) not null,
  VALOR_ANTERIOR varchar(500),
  VALOR_NOVO varchar(500),
  VALOR_ANTERIOR_B BLOB,
  VALOR_NOVO_B BLOB
);

alter table TEST_LOG add constraint USUARIO_TEST_LOG_FK foreign key (ID_USUARIO) references USUARIO (ID);
alter table TEST_LOG add constraint TEST_TEST_LOG2_FK foreign key (ID_PK) references TEST (ID);

create index TEST_LOG_IDX_DATA_HORA on TEST_LOG (DATA_HORA);

ALTER TABLE TEST ALTER COLUMN STR_NULL_IF_ZERO TO STR_NULL_IF_EMPTY;