unit principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ComCtrls, ExtCtrls, Windows;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    ImageList1: TImageList;
    ImageList2: TImageList;
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
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ControlBar1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure Page3BeforeShow(ASender: TObject; ANewPage: TPage;
      ANewIndex: Integer);
    procedure PaintBox1Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure ScrollBox1Click(Sender: TObject);
  private
  public
    procedure ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

uses gerador_codigo_form, produto_man_form,
  log_sql_form, query_runner_form;

{$R *.lfm}

{ TMenuPrincipalForm }

procedure TMenuPrincipalForm.Button1Click(Sender: TObject);

begin

end;

procedure TMenuPrincipalForm.Button2Click(Sender: TObject);
begin

end;

procedure TMenuPrincipalForm.ControlBar1Click(Sender: TObject);
begin

end;

procedure TMenuPrincipalForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin

end;

procedure TMenuPrincipalForm.FormCreate(Sender: TObject);
begin
  // registra teclas de atalho geral da aplicação
  Application.AddOnKeyDownHandler(@ApplicationKeyDown);
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

procedure TMenuPrincipalForm.Page3BeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin

end;

procedure TMenuPrincipalForm.PaintBox1Click(Sender: TObject);
begin

end;

procedure TMenuPrincipalForm.Panel1Click(Sender: TObject);
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  //GeradorDeCodigoForm.Parent := Panel1;
  GeradorDeCodigoForm.Show;
  GeradorDeCodigoForm.Free;
end;

procedure TMenuPrincipalForm.ScrollBox1Click(Sender: TObject);
begin

end;

procedure TMenuPrincipalForm.ApplicationKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_F12 then
    if not LogSqlForm.Visible then
      LogSqlForm.ShowModal;
end;


end.

