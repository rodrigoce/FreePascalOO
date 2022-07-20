unit usuario_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm;

type
  TUsuarioEntity = class(TEntityBase)
    private
      FNome: string;
      FDataUltLogin: TDateTime;
    published
      property Nome: string read FNome write FNome;
      property DataUltLogin: TDateTime read FDataUltLogin write FDataUltLogin;

  end;


implementation


initialization

TORMMapBuilder.Create.MapModel(TUsuarioEntity, 'USUARIO')
  .MapSequenceInt32PK('ID', 'Id')
  .MapDateTime('DATA_CRIACAO', 'DataCriacao', True)
  .MapDateTime('DATA_ATUALIZACAO', 'DataAtualizacao', True)
  .MapDateTime('DATA_EXCLUSAO', 'DataExclusao', True)
  .MapInt32('ID_USER_CRIACAO', 'IdUserCriacao')
  .MapInt32('ID_USER_ATUALIZACAO', 'IdUserAtualizacao')
  .MapInt32('ID_USER_EXCLUSAO', 'IdUserExclusao')
  .MapString('NOME', 'Nome', 60)
  .MapDateTime('DATA_ULT_LOGIN', 'DataUltLogin', True);

end.
