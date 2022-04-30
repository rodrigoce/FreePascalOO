unit produto_model;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, model_base;

type
  TProdutoModel = class(TModelBase)
    private
      FNome: string;
    published
      property Nome: string read FNome write FNome;

  end;


implementation

uses orm;

initialization

TORMMapBuilder.Create.MapModel(TProdutoModel, 'PRODUTO')
  .MapSequenceInt32PK('ID', 'Id')
  .MapDateTime('DATA_CRIACAO', 'DataCriacao')
  .MapDateTime('DATA_ATUALIZACAO', 'DataAtualizacao')
  .MapDateTime('DATA_EXCLUSAO', 'DataExclusao')
  .MapInt32('ID_USER_CRIACAO', 'IdUserCriacao')
  .MapInt32('ID_USER_ATUALIZACAO', 'IdUserAtualizacao')
  .MapInt32('ID_USER_EXCLUSAO', 'IdUserExclusao')
  .MapString('NOME', 'Nome', 60);

end.

