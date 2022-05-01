unit principal_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus;

type

  { TMenuPrincipalForm }

  TMenuPrincipalForm = class(TForm)
    Button1: TButton;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private

  public

  end;

var
  MenuPrincipalForm: TMenuPrincipalForm;

implementation

uses produto_repository, produto_model, orm, gerador_codigo_form;

{$R *.lfm}

{ TMenuPrincipalForm }

procedure TMenuPrincipalForm.Button1Click(Sender: TObject);
var
  produto: TProdutoModel;
  produtoRepo: TProdutoRepository;
begin
  produto := TProdutoModel.Create;
  produto.ID := produtoRepo.GetNextSequence;
  produto.Nome := 'Rodrigo Castro Eleotério' + IntToStr(produto.Id);

  produtoRepo := TProdutoRepository.Create;
  produtoRepo.Insert(produto);
  ShowMessage(FloatToStr(produto.DataCriacao));
  //produto := produtoRepo.FindByPK(1);
end;

procedure TMenuPrincipalForm.MenuItem2Click(Sender: TObject);
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  GeradorDeCodigoForm.ShowModal;
  GeradorDeCodigoForm.Free;
end;

end.

