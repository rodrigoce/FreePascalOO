unit menu_principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ComCtrls, ExtCtrls, ActnList, Windows, menu_tree_item;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    Notebook1: TNotebook;
    Page2: TPage;
    Page3: TPage;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    TreeViewMenu: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure TreeViewMenuClick(Sender: TObject);
  private
    FMenuTree: TMenuTreeItem;
  public
    procedure ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    property MenuTree: TMenuTreeItem read FMenuTree write FMenuTree;
  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

uses gerador_codigo_form, produto_man_form,
  log_sql_form, query_runner_form, menu_principal_seed;

{$R *.lfm}

{ TMenuPrincipalForm }

procedure TMenuPrincipalForm.FormCreate(Sender: TObject);

begin
  // registra teclas de atalho geral da aplicação
  Application.AddOnKeyDownHandler(@ApplicationKeyDown);
  TMenuPrincipalSeed.Create.InitRootMenus(MenuTree, TreeViewMenu);
end;

procedure TMenuPrincipalForm.MenuItem2Click(Sender: TObject);
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  GeradorDeCodigoForm.ShowModal;
  GeradorDeCodigoForm.Free;
end;

procedure TMenuPrincipalForm.MenuItem4Click(Sender: TObject);
begin
  TProdutoManForm.OpenFeature;
end;

procedure TMenuPrincipalForm.MenuItem5Click(Sender: TObject);
begin
  TQueryRunnerForm.OpenFeature;
end;

procedure TMenuPrincipalForm.TreeViewMenuClick(Sender: TObject);
begin
  Showmessage(TreeViewMenu.Selected.Text);

  if TMenuTreeItem(TreeViewMenu.Selected.Data).CallBack <> nil then
    TMenuTreeItem(TreeViewMenu.Selected.Data).CallBack;
end;

procedure TMenuPrincipalForm.ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_F12 then
    if not LogSqlForm.Visible then
      LogSqlForm.ShowModal;
end;


end.

