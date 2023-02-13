unit produto_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm, application_functions;

type

  { TProdutoEntity }

  TProdutoEntity = class(TEntityBase)
    private
      FCodigo: string;
      FNome: string;
      FNomePP: string;
      FPrecoCusto: Double;
      FMargemLucro: Double;
      FPrecoVenda: Double;
      procedure SetNome(AValue: string);
    public
      class procedure Map;
    published
      property Codigo: string read FCodigo write FCodigo;
      property Nome: string read FNome write SetNome;
      property NomePP: string read FNomePP;
      property PrecoCusto: Double read FPrecoCusto write FPrecoCusto;
      property MargemLucro: Double read FMargemLucro write FMargemLucro;
      property PrecoVenda: Double read FPrecoVenda write FPrecoVenda;
  end;


implementation


{ TProdutoEntity }

procedure TProdutoEntity.SetNome(AValue: string);
begin
  FNome := AValue;
  FNomePP := PPConvert(AValue);
end;

class procedure TProdutoEntity.Map;
begin
  TORMMapBuilder.Create.MapModel(TProdutoEntity, 'PRODUTO')
    .MapInt32PK('ID', 'Id')
    .MapString('SITUACAO', 'Situacao', 4, False)
    .MapInt32('NRO_REVISAO', 'NroRevisao', False)
    .MapString('CODIGO', 'Codigo', 20, False)
    .MapString('NOME', 'Nome', 60, False)
    .MapString('NOME_PP', 'NomePP', 60, False)
    .MapDecimal('PRECO_CUSTO', 'PrecoCusto', 10, 2)
    .MapDecimal('MARGEM_LUCRO', 'MargemLucro', 13, 5)
    .MapDecimal('PRECO_VENDA', 'PrecoVenda', 10, 2);
end;

end.

