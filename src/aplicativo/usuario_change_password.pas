unit usuario_change_password;

{$mode ObjFPC}{$H+}

interface

uses
  validatable;

type

  { TUsuarioChangePassword }

  TUsuarioChangePassword = class(TValidatable)
  private
    FConfirmarSenha: string;
    FID: Integer;
    FNome: string;
    FNovaSenha: string;
    FSenhaAtual: string;
    FUserName: string;
  published
    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property UserName: string read FUserName write FUserName;
    property SenhaAtual: string read FSenhaAtual write FSenhaAtual;
    property NovaSenha: string read FNovaSenha write FNovaSenha;
    property ConfirmarSenha: string read FConfirmarSenha write FConfirmarSenha;
  end;

implementation

{ TUsuarioChangePassword }

end.

