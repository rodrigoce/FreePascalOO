unit produto_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm, application_functions, Dialogs;

type

  { TProdutoEntity }

  TProdutoEntity = class(TEntityBase)
    private
      FReferencia: string;
      FNome: string;
      FNomePP: string;
      FPrecoCusto: Double;
      FMargemLucro: Double;
      FPrecoVenda: Double;
      procedure SetNome(Value: string);
    public

    published
      property Referencia: string read FReferencia write FReferencia;
      property Nome: string read FNome write SetNome;
      property NomePP: string read FNomePP;
      property PrecoCusto: Double read FPrecoCusto write FPrecoCusto;
      property MargemLucro: Double read FMargemLucro write FMargemLucro;
      property PrecoVenda: Double read FPrecoVenda write FPrecoVenda;


  end;


implementation


{ TProdutoEntity }

procedure TProdutoEntity.SetNome(Value: string);
begin
  FNome := Value;
  FNomePP := LowerCase(RemoveAcento(Value));
end;

initialization

TORMMapBuilder.Create.MapModel(TProdutoEntity, 'PRODUTO')
  .MapSequenceInt32PK('ID', 'Id')
  .MapDateTime('DATA_CRIACAO', 'DataCriacao')
  .MapDateTime('DATA_ATUALIZACAO', 'DataAtualizacao')
  .MapDateTime('DATA_EXCLUSAO', 'DataExclusao')
  .MapInt32('ID_USER_CRIACAO', 'IdUserCriacao')
  .MapInt32('ID_USER_ATUALIZACAO', 'IdUserAtualizacao')
  .MapInt32('ID_USER_EXCLUSAO', 'IdUserExclusao')
  .MapString('REFERENCIA', 'Referencia', 20)
  .MapString('NOME', 'Nome', 60)
  .MapString('NOME_PP', 'NomePP', 60)
  .MapDecimal('PRECO_CUSTO', 'PrecoCusto', 10, 2)
  .MapDecimal('MARGEM_LUCRO', 'MargemLucro', 10, 6)
  .MapDecimal('PRECO_VENDA', 'PrecoVenda', 10, 2);

end.

