unit usuario_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm, application_functions, Dialogs;

type

  { TUsuarioEntity }

  TUsuarioEntity = class(TEntityBase)
    private
      FDataUltLogin: TDateTime;
      FNome: string;
      FNomePP: string;
      FSenha: string;
      FUserName: string;
      procedure SetNome(Value: string);
    public
      class procedure Map;
    published
      property Nome: string read FNome write SetNome;
      property NomePP: string read FNomePP;
      property UserName: string read FUserName write FUserName;
      property Senha: string read FSenha write FSenha;
      property DataUltLogin: TDateTime read FDataUltLogin write FDataUltLogin;
  end;


implementation


{ TUsuarioEntity }

procedure TUsuarioEntity.SetNome(Value: string);
begin
  FNome := Value;
  FNomePP := PPConvert(Value);
end;

class procedure TUsuarioEntity.Map;
begin
  TORMMapBuilder.Create.MapModel(TUsuarioEntity, 'USUARIO')
    .MapInt32PK('ID', 'Id')
    .MapString('SITUACAO', 'Situacao', 1)
    .MapInt32('NRO_REVISAO', 'NroRevisao', False)
    .MapString('NOME', 'Nome', 60)
    .MapString('NOME_PP', 'NomePP', 60)
    .MapString('USER_NAME', 'UserName', 30)
    .MapString('SENHA', 'Senha', 200)
    .MapDateTime('DATA_ULT_LOGIN', 'DataUltLogin', True);
end;

end.

