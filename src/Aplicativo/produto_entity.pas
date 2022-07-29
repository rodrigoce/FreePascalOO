unit produto_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm, application_functions, Dialogs;

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
      procedure SetNome(Value: string);
    public

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

procedure TProdutoEntity.SetNome(Value: string);
var
  a: Currency;
begin
  FNome := Value;
  FNomePP := LowerCase(RemoveAccent(Value));
end;

initialization

TORMMapBuilder.Create.MapModel(TProdutoEntity, 'PRODUTO')
  .MapInt32PKWithSequence('ID', 'Id')
  .MapDateTime('DATA_CRIACAO', 'DataCriacao', True)
  .MapDateTime('DATA_ATUALIZACAO', 'DataAtualizacao', True)
  .MapDateTime('DATA_EXCLUSAO', 'DataExclusao', True)
  .MapOptionalInt32FK('ID_USER_CRIACAO', 'IdUserCriacao')
  .MapOptionalInt32FK('ID_USER_ATUALIZACAO', 'IdUserAtualizacao')
  .MapOptionalInt32FK('ID_USER_EXCLUSAO', 'IdUserExclusao')
  .MapString('CODIGO', 'Codigo', 20)
  .MapString('NOME', 'Nome', 60)
  .MapString('NOME_PP', 'NomePP', 60)
  .MapDecimal('PRECO_CUSTO', 'PrecoCusto', 10, 2)
  .MapDecimal('MARGEM_LUCRO', 'MargemLucro', 13, 5)
  .MapDecimal('PRECO_VENDA', 'PrecoVenda', 10, 2);

end.

