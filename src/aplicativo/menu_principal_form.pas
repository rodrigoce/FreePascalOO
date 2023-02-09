unit menu_principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, Menus, ComCtrls, ExtCtrls,
  Windows, menu_principal_config, dev_tools_form,
  usuario_login_form, usuario_bll, usuario_login, application_session,
  application_types, db_context;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    pnWallPaper: TPanel;
    StatusBar1: TStatusBar;
    TreeViewMenu: TTreeView;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TreeViewMenuClick(Sender: TObject);
  private
    FMenuPrincipalConfig: TMenuPrincipalConfig;
    function TryLoginByShellParams: Boolean;
    procedure UpdateStatusBar;
  public
    procedure ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    property MenuPrincipalConfig: TMenuPrincipalConfig read FMenuPrincipalConfig write FMenuPrincipalConfig;
  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

{$R *.lfm}

{ TMenuPrincipalForm }

procedure TMenuPrincipalForm.FormCreate(Sender: TObject);

begin
  // registra teclas de atalho geral da aplicação
  Application.AddOnKeyDownHandler(@ApplicationKeyDown);
  // cria o menu principal
  MenuPrincipalConfig := TMenuPrincipalConfig.Create;
  MenuPrincipalConfig.InitRootMenus(TreeViewMenu);
end;

procedure TMenuPrincipalForm.FormShow(Sender: TObject);
var
  usuarioBLL: TUsuarioBLL;
begin
  try
    usuarioBLL := TUsuarioBLL.Create(gAppDbContext);
    usuarioBLL.EnsureExistsFirstUser;
    usuarioBLL.Free;
    if not TryLoginByShellParams then
    begin
      if not TUsuarioLoginForm.Login then
        Application.Terminate;
    end;
  except
    // qualquer erro no login termina o aplicativo.
    Application.Terminate;
  end;
  UpdateStatusBar;
end;

procedure TMenuPrincipalForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  FMenuPrincipalConfig.Free;
  TApplicationSession.EndEnvironment;
end;

procedure TMenuPrincipalForm.TreeViewMenuClick(Sender: TObject);
begin
  MenuPrincipalConfig.ExecuteCallBackOf(TreeViewMenu.Selected);
end;

function TMenuPrincipalForm.TryLoginByShellParams: Boolean;
var
  usuarioLogin: TUsuarioLogin;
  opResult: TOperationResult;
  usuarioBLL: TUsuarioBLL;
begin
  Result := False;
  if (ParamStr(1) <> '') and (ParamStr(2) <> '') then
  begin
    usuarioLogin := TUsuarioLogin.Create;
    usuarioLogin.UserName := ParamStr(1);
    usuarioLogin.Password := ParamStr(2);
    usuarioBLL := TUsuarioBLL.Create(gAppDbContext);
    opResult := usuarioBLL.TryLogin(usuarioLogin);
    if opResult.Success then
    begin
      Result := True;
    end;
    usuarioLogin.Free;
    usuarioBLL.Free;
  end;
end;

procedure TMenuPrincipalForm.UpdateStatusBar;
begin
  if TApplicationSession.LogedUser <> nil then
  begin
    StatusBar1.Panels[0].Text := TApplicationSession.LogedUser.UserName;
    StatusBar1.Panels[1].Text := TApplicationSession.LogedUser.Nome;
  end;
end;

procedure TMenuPrincipalForm.ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key = VK_F12) and (Shift = []) then
    if not DevToolsForm.Visible then
      MenuPrincipalConfig.CallBacks.QueryRunner;

  if (key = VK_F12) and (ssCtrl in Shift) then
  begin

  end;
end;


end.

