insert into cliente 
values ('11122233344', 'João', 'rua corsa,44', 'Guararema'),
('22233344455', 'Maria', 'rua osasco,245', 'Madureira'),
('33344455566','Liminha', 'rua KGB,98', 'Atomica'),
('44455566677','Stig Man', 'rua Top Gear,1951', 'Londrina');

-- select * from cliente;

insert into telefone_cliente
values('555666', '11122233344'),
('999000', '22233344455'),
('190017', '33344455566');

insert into departamento 
values (22, 'atendente'),
(33, 'caixa'),
(66, 'gerencia');


insert into funcionarios
values(13,22,'José'),
(30,33, 'Marquinhos'),
(20,66, 'Marta'),
(17, 22, 'Rogéria');

/*select f.funcio_nome, f.iddepartamento, d.setor 
from funcionarios f, departamento d 
where d.iddepartamento = f.iddepartamento 
and setor = 'atendente' ;*/

insert into categoria
values(12,'bola de basquete'),
(66, 'camisa time'),
(124, 'peso 14kg');

insert into fornecedor
values(56,'NAIQUE', 'Itu'),
(68,'ADIBAS', 'Videira'),
(88,'shella', 'Curitiba');

insert into transportadora
values(171, 'sebex'),
(666, 'febex');

-- select*from produto;

insert into produto
values(30,124,68,110.10, 'peso 14kg emborrachado azul',10),
(35,12,56,55, 'bola de basquete de nivel semiprofissional azul e preta',25),
(40,66,56,89.90, 'camisa do flamengo clássica',10),
(45,66,68,37, 'camisa do Corinthians clássica',15);


insert into pedido
values(21,13,'33344455566',171,'2020-05-16'),
(41,13,'11122233344',171,'2020-04-02'),
(24,17,'22233344455',666,'2020-05-10'),
(42,13,'11122233344',171,'2020-04-06');


insert into detalhes_pedido
values(40,21,8),
(30,24,10),
(35,41,20),
(45,42,5),
(45,21,10);

-- triggers
DELIMITER $$
create trigger venda after insert
on detalhes_pedido
for each row
begin
	update produto set estoque = estoque - new.quantidade
    where produto.idproduto = new.idproduto;
end$$

create trigger venda_delete after delete
on detalhes_pedido
for each row
begin
	update produto set estoque = estoque + old.quantidade
    where produto.idproduto = old.idproduto;
end$$

create trigger upd_estoque after update
on detalhes_pedido
for each row
begin
	IF OLD.quantidade > new.quantidade THEN
    update produto set estoque = estoque + (old.quantidade - new.quantidade)
    where produto.idproduto = old.idproduto;
    
    else IF OLD.quantidade < new.quantidade THEN
    update produto set estoque = estoque - (new.quantidade - old.quantidade)
    where produto.idproduto = old.idproduto;
		
END IF;
END IF;
end$$

DELIMITER ;

select * from detalhes_pedido;
select * from pedido;
select * from produto;
insert into detalhes_pedido values (45,24,10);

update detalhes_pedido set quantidade = 12 where idproduto= 45 and idpedido=24;
update detalhes_pedido set quantidade = 8 where idproduto= 45 and idpedido=24;

delete from detalhes_pedido where idproduto = 45 and idpedido = 24;

-- caso de ruim nos triggers
drop trigger venda_delete;
drop trigger venda;
drop trigger upd_estoque;

-- FUNCTION
-- verifica cada compra e calcula o seu valor total
create function prod_quant (preco float(10,2), quant int)
returns int
return preco * quant;
-- chamando a function dentro de um select
select ped.idpedido, d.idproduto, d.quantidade, prod_quant(p.preco,d.quantidade) as 'Valor Total'
from produto p right outer join detalhes_pedido d
on p.idproduto = d.idproduto left join pedido ped
on ped.idpedido = d.idpedido;
-- verificação
select * from detalhes_pedido;
select * from pedido;
-- drop da função
drop function prod_quant;

-- PROCEDURES
DELIMITER $$
-- Mostra quem comprou tal produto
create procedure info_compras (idproduto int)
BEGIN
	select p.idpedido, pr.idproduto, pr.preco,dp.quantidade, p.data_pedido, c.nome
	from cliente c inner join pedido p 
	on c.cpf = p.cpf inner join detalhes_pedido dp
	on p.idpedido = dp.idpedido inner join produto pr
	on dp.idproduto = pr.idproduto
	where pr.idproduto = idproduto;
END$$

-- Mostra as infos dos clientes que fizeram pedido
create procedure cliente_info (idpedido int)
BEGIN
	select p.idpedido, c.nome, c.cpf ,c.rua, c.bairro, tc.telefone
	from pedido p inner join cliente c
	on p.cpf = c.cpf left join telefone_cliente tc
	on c.cpf = tc.cpf
	where p.idpedido=idpedido;
END$$

DELIMITER ;


call info_compras(45);
call cliente_info(24);
-- drop da procedure
drop procedure info_compras;
drop procedure cliente_info;

-- VIEWS
-- seleciona todos os produtos que são mais baratos que a media do valor dos produtos
create or replace view prod_media_val(PRODUTO,CATEGORIA,FORNECEDOR,PREÇO,DESCRIÇÃO,ESTOQUE) as
select * from produto where
preco <= (select avg(preco) from produto);

-- chamando a view
select * from prod_media_val;
-- drop da view
drop view prod_media_val;

-- SELECTS COMPLEXOS

-- Seleciona as informações de cada pedidos de cada cliente, calcula o total e ordena por ordem alfabetica o nome dos clientes
-- inclusive aqueles que não efetuaram nenhuma compra.
select c.nome, tc.telefone, p.idpedido, pro.descri, pro.idproduto, pro.preco, 
round(dp.quantidade*pro.preco,2) as Total, IF(dp.quantidade>=10, concat("quantidade igual a:", dp.quantidade), "menos de 10 produtos")
from cliente c left join telefone_cliente tc
on c.cpf=tc.cpf left join pedido p
on c.cpf=p.cpf left join detalhes_pedido dp
on p.idpedido=dp.idpedido left join produto pro
on dp.idproduto=pro.idproduto order by c.nome asc ;

-- Seleciona a categoria do produto e as informações do fornecedor 
select c.categoria_nome, p.idproduto, p.descri,p.preco, f.fornecedor_nome, f.cidade 
from categoria c right join produto p
on c.idcategoria = p.idcategoria right join fornecedor f
on p.idfornecedor=f.idfornecedor;

-- Seleciona os funcionarios, pedido e transportadora falando se é atendente ou de outra área
select d.iddepartamento,(CASE WHEN p.idfuncionarios=f.idfuncionarios THEN "Atendente" ELSE "Outro setor" END) as area , f.funcio_nome,p.idpedido,p.data_pedido,t.transp_nome
from funcionarios f left join departamento d 
on f.iddepartamento = d.iddepartamento left join pedido p
on p.idfuncionarios = f.idfuncionarios left join transportadora t
on t.idtransportadora = p.idtransportadora;

-- Seleciona o nome, pedido e transportadora do maior id pedido
select c.nome, p.idpedido, t.transp_nome
from cliente c inner join pedido p
on c.cpf = p.cpf inner join transportadora t
on p.idtransportadora = t.idtransportadora
where p.idpedido = (select max(dp.idpedido) 
from detalhes_pedido dp inner join produto pro 
on dp.idproduto = pro.idproduto inner join fornecedor f
on pro.idfornecedor=f.idfornecedor);