unit usuario_change_pass_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls,
  ExtCtrls, usuario_entity, usuario_bll, application_types,
  mensagem_validacao_form, prop_to_comp_map, usuario_change_password,
  db_context;

type

  { TUsuarioChangePassForm }

  TUsuarioChangePassForm = class(TForm)
    btCancel: TButton;
    btSave: TButton;
    edId: TEdit;
    edNome: TEdit;
    edConfirmarSenha: TEdit;
    edNovaSenha: TEdit;
    edUserName: TEdit;
    edSenhaAtual: TEdit;
    labId: TLabel;
    labNome: TLabel;
    labNovaSenha: TLabel;
    labConfirmarSenha: TLabel;
    labUserName: TLabel;
    labSenhaAtual: TLabel;
    Panel1: TPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure edUserNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edUserNameKeyPress(Sender: TObject; var Key: char);
  private
    FUsuario: TUsuarioEntity;
    FUsuarioChangePassword: TUsuarioChangePassword;
    FUsuarioBLL: TUsuarioBLL;
    FPropToCompMap: TPropToCompMap;
    procedure ConfigMapPropComp;
    procedure Save;
  public
    class procedure ChangePassword(Id: Integer);
  end;

var
  UsuarioChangePassForm: TUsuarioChangePassForm;

implementation

{$R *.lfm}

{ TUsuarioChangePassForm }

procedure TUsuarioChangePassForm.btSaveClick(Sender: TObject);
begin
  try
    btSave.Enabled := False;
    Save;
  finally
    btSave.Enabled := True;
  end;
end;

procedure TUsuarioChangePassForm.edUserNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUsuarioChangePassForm.edUserNameKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['a'..'z', 'A'..'Z', #8]) then
    Key := #0;
end;

procedure TUsuarioChangePassForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEdit('Id', edId, 11, labId);
  FPropToCompMap.MapEdit('Nome', edNome, 60, labNome);
  FPropToCompMap.MapEdit('UserName', edUserName, 30, labNome);
  FPropToCompMap.MapEdit('SenhaAtual', edSenhaAtual, 200, labSenhaAtual);
  FPropToCompMap.MapEdit('NovaSenha', edNovaSenha, 200, labNovaSenha);
  FPropToCompMap.MapEdit('ConfirmarSenha', edConfirmarSenha, 200, labConfirmarSenha);
end;

procedure TUsuarioChangePassForm.Save;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FUsuarioChangePassword);

  opResult := FUsuarioBLL.ChangePassword(FUsuarioChangePassword);

  if opResult.Success then
    Close
  else
    TMensagemValidacaoForm.Open(opResult.Message, FUsuarioChangePassword, FPropToCompMap, False);
end;

procedure TUsuarioChangePassForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

class procedure TUsuarioChangePassForm.ChangePassword(Id: Integer);
begin
  Application.CreateForm(TUsuarioChangePassForm, UsuarioChangePassForm);
  with UsuarioChangePassForm do
  begin
    FUsuarioBLL := TUsuarioBLL.Create(gAppDbContext);
    FPropToCompMap := TPropToCompMap.Create;

    ConfigMapPropComp;

    FUsuario := FUsuarioBLL.InnerDAL.FindByPK(Id);
    FUsuarioChangePassword := TUsuarioChangePassword.Create;
    FUsuarioChangePassword.ID := FUsuario.Id;
    FUsuarioChangePassword.Nome := FUsuario.Nome;
    FUsuarioChangePassword.UserName := FUsuario.UserName;

    FPropToCompMap.ObjectToComp(FUsuarioChangePassword);

    ShowModal;

    FUsuarioBLL.Free;
    FPropToCompMap.Free;

    FUsuario.Free;
    FUsuarioChangePassword.Free;
    Free;
  end;
end;

end.

