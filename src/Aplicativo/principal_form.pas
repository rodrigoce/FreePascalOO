unit principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private

  public

  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

uses produto_dal, produto_entity, mini_orm, gerador_codigo_form;

{$R *.lfm}

{ TMenuPrincipalForm }

procedure TMenuPrincipalForm.Button1Click(Sender: TObject);
var
  produto: TProdutoEntity;
  produtoDal: TProdutoDAL;
begin
  produtoDal := TProdutoDAL.Create;
  produto := TProdutoEntity.Create;
  produto.ID := produtoDal.GetNextSequence;
  produto.Nome := 'Rodrigo Castro Eleotério' + IntToStr(produto.Id);
  ShowMessage(produto.AsString);
  produtoDal.Insert(produto);
  produto.DataAtualizacao := Now;
  produtoDal.Update(produto);
  produto := produtoDal.FindByPK(produto.Id);
  ShowMessage(produto.AsString);
end;

procedure TMenuPrincipalForm.Button2Click(Sender: TObject);
var
  a: string;
begin
  a := 'oi1';
  ShowMessage(a);
end;

procedure TMenuPrincipalForm.MenuItem2Click(Sender: TObject);
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  GeradorDeCodigoForm.ShowModal;
  GeradorDeCodigoForm.Free;
end;

end.

