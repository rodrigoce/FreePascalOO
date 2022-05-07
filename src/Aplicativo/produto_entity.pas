unit produto_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base;

type
  TProdutoEntity = class(TEntityBase)
    private
      FNome: string;
    published
      property Nome: string read FNome write FNome;

  end;


implementation

uses mini_orm;

initialization

TORMMapBuilder.Create.MapModel(TProdutoEntity, 'PRODUTO')
  .MapSequenceInt32PK('ID', 'Id')
  .MapDateTime('DATA_CRIACAO', 'DataCriacao')
  .MapDateTime('DATA_ATUALIZACAO', 'DataAtualizacao')
  .MapDateTime('DATA_EXCLUSAO', 'DataExclusao')
  .MapInt32('ID_USER_CRIACAO', 'IdUserCriacao')
  .MapInt32('ID_USER_ATUALIZACAO', 'IdUserAtualizacao')
  .MapInt32('ID_USER_EXCLUSAO', 'IdUserExclusao')
  .MapString('NOME', 'Nome', 60);

end.

