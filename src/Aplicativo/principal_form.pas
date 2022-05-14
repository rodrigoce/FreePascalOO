unit principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
  funcoes;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
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
var
  produto: TProdutoEntity;
  produtoDal: TProdutoDAL;
begin
  produtoDal := TProdutoDAL.Create;
  produtoDal.ShowSQLAndParams := True;
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
begin
  ShowMessage(LowerCase(RemoveAcento('ÄÅÁÂÀÃäáâàãÉÊËÈéêëèÍÎÏÌíîïìÖÓÔÒÕöóôòõÜÚÛüúûùÇç')));
end;

procedure TMenuPrincipalForm.MenuItem2Click(Sender: TObject);
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  GeradorDeCodigoForm.ShowModal;
  GeradorDeCodigoForm.Free;
end;

procedure TMenuPrincipalForm.MenuItem4Click(Sender: TObject);
begin
  TProdutoManForm.OpenFeature;;
end;

end.

