unit usuario_login;

{$mode ObjFPC}{$H+}

interface

uses
  validatable;

type

  { TUsuarioLogin }

  TUsuarioLogin = class(TValidatable)
  private
    FPassword: string;
    FUserName: string;
  published
    property UserName: string read FUserName write FUserName;
    property Password: string read FPassword write FPassword;
  end;

implementation

end.

