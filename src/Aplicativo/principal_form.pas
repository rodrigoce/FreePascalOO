unit principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  ComCtrls, funcoes, query_runner_form;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    MainMenu1: TMainMenu;
    memoLogTConnection: TMemo;
    memoLogDalBase: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
  private

  public

  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

uses produto_dal, produto_entity, mini_orm, gerador_codigo_form, produto_man_form,
  conexao_dm;

{$R *.lfm}

{ TMenuPrincipalForm }

procedure TMenuPrincipalForm.Button1Click(Sender: TObject);

begin

end;

procedure TMenuPrincipalForm.Button2Click(Sender: TObject);
begin

end;

procedure TMenuPrincipalForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  // para não dar erro ao fechar o form principal
  TProdutoDAL.MemoLogSQLCommands := nil;
  ConexaoDM.MemoLogTConnection := nil;
end;

procedure TMenuPrincipalForm.FormCreate(Sender: TObject);
begin
  // ligando na verdade para qq DAL, não usei TDALBase porque uma classe
  // genérica precisa se chamada de sua especialização
  TProdutoDAL.MemoLogSQLCommands := memoLogDalBase;
  ConexaoDM.MemoLogTConnection := memoLogTConnection;
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

end.

