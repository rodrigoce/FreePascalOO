unit principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  funcoes, query_runner_form;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
  private

  public

  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

uses produto_dal, produto_entity, mini_orm, gerador_codigo_form, produto_man_form;

{$R *.lfm}

{ TMenuPrincipalForm }

procedure TMenuPrincipalForm.Button1Click(Sender: TObject);

begin

end;

procedure TMenuPrincipalForm.Button2Click(Sender: TObject);
begin

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

