unit produto_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm, funcoes, Dialogs;

type

  { TProdutoEntity }

  TProdutoEntity = class(TEntityBase)
    private
      FNome: string;
      FNomePP: string;
      procedure SetNome(Value: string);
    public

    published
      property Nome: string read FNome write SetNome;
      property NomePP: string read FNomePP;


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
  .MapString('NOME', 'Nome', 60)
  .MapString('NOME_PP', 'NomePP', 60);

end.

