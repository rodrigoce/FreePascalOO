unit menu_principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, Menus, ComCtrls, ExtCtrls,
  StdCtrls, rxDice, rxctrls, TAGraph, TASources, TAPolygonSeries,
  TASeries, TATools, Windows, menu_principal_config, query_runner_form;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    pnWallPaper: TPanel;
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
  FMenuPrincipalConfig.Free;
end;

procedure TMenuPrincipalForm.TreeViewMenuClick(Sender: TObject);
begin
  MenuPrincipalConfig.ExecuteCallBackOf(TreeViewMenu.Selected);
end;

procedure TMenuPrincipalForm.ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key = VK_F12) and (Shift = []) then
    if not LogSqlForm.Visible then
      MenuPrincipalConfig.CallBacks.OpenLogSQL;

  if (key = VK_F12) and (ssCtrl in Shift) then
  begin
    if QueryRunnerForm = nil then
      MenuPrincipalConfig.CallBacks.QueryRunner
    else if not QueryRunnerForm.Visible then
      MenuPrincipalConfig.CallBacks.QueryRunner;
  end;
end;


end.

