unit menu_principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ExtCtrls, ActnList, StdCtrls, Windows, menu_principal_config;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    Label1: TLabel;
    Notebook1: TNotebook;
    Page3: TPage;
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    TreeViewMenu: TTreeView;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure TreeViewMenuClick(Sender: TObject);
  private
    FMenuPrincipalConfig: TMenuPrincipalConfig;
  public
    procedure ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    property MenuPrincipalConfig: TMenuPrincipalConfig read FMenuPrincipalConfig write FMenuPrincipalConfig;
  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

uses log_sql_form;

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

procedure TMenuPrincipalForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  FMenuPrincipalConfig.Free;;
end;

procedure TMenuPrincipalForm.TreeViewMenuClick(Sender: TObject);
begin
  MenuPrincipalConfig.ExecuteCallBackOf(TreeViewMenu.Selected);
end;

procedure TMenuPrincipalForm.ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_F12 then
    if not LogSqlForm.Visible then
      LogSqlForm.ShowModal;
end;


end.

