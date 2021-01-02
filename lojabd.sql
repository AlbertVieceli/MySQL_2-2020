create database lojaesporte;
use lojaesporte;
drop database lojaesporte;


CREATE TABLE fornecedor (
  idfornecedor INTEGER NOT NULL,
  fornecedor_nome VARCHAR(25),
  cidade VARCHAR(20),
  PRIMARY KEY(idfornecedor)
);

CREATE TABLE transportadora (
  idtransportadora INTEGER NOT NULL,
  transp_nome VARCHAR(20),
  PRIMARY KEY(idtransportadora)
);

CREATE TABLE departamento (
  iddepartamento INTEGER  NOT NULL,
  setor VARCHAR(15),
  PRIMARY KEY(iddepartamento)
);

CREATE TABLE categoria (
  idcategoria INTEGER NOT NULL,
  categoria_nome VARCHAR(30),
  PRIMARY KEY(idcategoria)
);

CREATE TABLE cliente (
  cpf VARCHAR(11) NOT NULL,
  nome VARCHAR(20),
  rua VARCHAR(20) ,
  bairro VARCHAR(20) ,
  PRIMARY KEY(cpf)
);

CREATE TABLE telefone_cliente (
  telefone VARCHAR(15) NOT NULL,
  cpf VARCHAR(11) NOT NULL,
  FOREIGN KEY(cpf)
    REFERENCES cliente(cpf),
  PRIMARY KEY(telefone)
    
);

CREATE TABLE funcionarios (
  idfuncionarios INTEGER NOT NULL,
  iddepartamento INTEGER NOT NULL,
  funcio_nome VARCHAR(20),
  PRIMARY KEY(idfuncionarios),
  FOREIGN KEY(iddepartamento)
    REFERENCES departamento(iddepartamento)
);

CREATE TABLE produto (
  idproduto INTEGER NOT NULL,
  idcategoria INTEGER NOT NULL,
  idfornecedor INTEGER NOT NULL,
  preco FLOAT,
  descri TINYTEXT,
  estoque INTEGER NOT NULL,
  PRIMARY KEY(idproduto),
  FOREIGN KEY(idfornecedor)
    REFERENCES fornecedor(idfornecedor),
  FOREIGN KEY(idcategoria)
    REFERENCES categoria(idcategoria)
);

CREATE TABLE pedido (
  idpedido INTEGER NOT NULL,
  idfuncionarios INTEGER NOT NULL,
  cpf VARCHAR(11) NOT NULL,
  idtransportadora INTEGER NOT NULL,
  data_pedido DATE,
  PRIMARY KEY(idpedido),
  FOREIGN KEY(idfuncionarios)
    REFERENCES funcionarios(idfuncionarios),
  FOREIGN KEY(idtransportadora)
    REFERENCES transportadora(idtransportadora),
  FOREIGN KEY(cpf)
    REFERENCES cliente(cpf)
);

CREATE TABLE detalhes_pedido (
  idproduto INTEGER NOT NULL,
  idpedido INTEGER NOT NULL,
  quantidade INTEGER ,
  PRIMARY KEY(idproduto, idpedido),
  FOREIGN KEY(idproduto)
    REFERENCES produto(idproduto),
  FOREIGN KEY(idpedido)
    REFERENCES pedido(idpedido)
);
