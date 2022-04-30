unit usuario_model;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, model_base;

type
  TUsuarioModel = class(TModelBase)
    private
      FNome: string;
      FDataUltLogin: TDateTime;
    published
      property Nome: string read FNome write FNome;
      property DataUltLogin: TDateTime read FDataUltLogin write FDataUltLogin;

  end;


implementation

uses orm;

initialization

TORMMapBuilder.Create.MapModel(TUsuarioModel, 'USUARIO')
  .MapSequenceInt32PK('ID', 'Id')
  .MapDateTime('DATA_CRIACAO', 'DataCriacao')
  .MapDateTime('DATA_ATUALIZACAO', 'DataAtualizacao')
  .MapDateTime('DATA_EXCLUSAO', 'DataExclusao')
  .MapInt32('ID_USER_CRIACAO', 'IdUserCriacao')
  .MapInt32('ID_USER_ATUALIZACAO', 'IdUserAtualizacao')
  .MapInt32('ID_USER_EXCLUSAO', 'IdUserExclusao')
  .MapString('NOME', 'Nome', 60)
  .MapDateTime('DATA_ULT_LOGIN', 'DataUltLogin');

end.
