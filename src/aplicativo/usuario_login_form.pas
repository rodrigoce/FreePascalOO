unit usuario_login_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Forms, Controls, Dialogs, StdCtrls, ExtCtrls,
  prop_to_comp_map, usuario_bll, application_types,
  usuario_login, mensagem_validacao_form, db_context;

type

  { TUsuarioLoginForm }

  TUsuarioLoginForm = class(TForm)
    btEntrar: TButton;
    btSair: TButton;
    edUsuario: TEdit;
    edSenha: TEdit;
    labUsuario: TLabel;
    labSenha: TLabel;
    Shape1: TShape;
    procedure btEntrarClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure edSenhaKeyPress(Sender: TObject; var Key: char);
    procedure edUsuarioKeyPress(Sender: TObject; var Key: char);
  private
    FLogou: Boolean;
    FTentativas: Integer;
    FPropToCompMap: TPropToCompMap;
    FUsuarioBLL: TUsuarioBLL;
    FUsuarioLogin: TUsuarioLogin;
    procedure ConfigMapPropComp;
    procedure SignIn;
  public
    class function Login: Boolean;
  end;

var
  UsuarioLoginForm: TUsuarioLoginForm;

implementation

{$R *.lfm}

{ TUsuarioLoginForm }

procedure TUsuarioLoginForm.btEntrarClick(Sender: TObject);
begin
  try
    btEntrar.Enabled := False;
    SignIn;
  finally
    btEntrar.Enabled := True;
  end;
end;

procedure TUsuarioLoginForm.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TUsuarioLoginForm.edSenhaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    btEntrar.Click;
    Key := #0;
  end;
end;

procedure TUsuarioLoginForm.edUsuarioKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    edSenha.SetFocus;
    Key := #0;
  end;
end;

procedure TUsuarioLoginForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEdit('UserName', edUsuario, 60, labUsuario);
  FPropToCompMap.MapEdit('Password', edSenha, 200, labSenha);

  FPropToCompMap.ObjectToComp(FUsuarioLogin);
end;

procedure TUsuarioLoginForm.SignIn;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FUsuarioLogin);
  opResult := FUsuarioBLL.TryLogin(FUsuarioLogin);
  FLogou := opResult.Success;

  if opResult.Success then
  begin
    FLogou := True;
    Close;
  end
  else
  begin
    TMensagemValidacaoForm.Open(opResult.Message, FUsuarioLogin, FPropToCompMap, False);
    Inc(FTentativas);
    if FTentativas = 3 then
      Close;
  end;
end;

class function TUsuarioLoginForm.Login: Boolean;
begin
  UsuarioLoginForm := TUsuarioLoginForm.Create(Application);
  with UsuarioLoginForm do
  begin
    FLogou := False;
    FTentativas := 0;

    FPropToCompMap := TPropToCompMap.Create;
    FUsuarioBLL := TUsuarioBLL.Create(gAppDbContext);
    FUsuarioLogin := TUsuarioLogin.Create;

    ConfigMapPropComp;

    ShowModal;
    Result := FLogou;

    FPropToCompMap.Free;
    FUsuarioBLL.Free;
    FUsuarioLogin.Free;
    Free;
  end;
end;

end.

