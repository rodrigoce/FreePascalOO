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
  produto.ID := 10;
  produto.Nome := 'Rodrigo Castro Eleotério';

  produtoRepo := TProdutoRepository.Create;
  produto := produtoRepo.FindByID(0);
end;

procedure TMenuPrincipalForm.MenuItem2Click(Sender: TObject);
begin
  Application.CreateForm(TGeradorDeCodigoForm, GeradorDeCodigoForm);
  GeradorDeCodigoForm.ShowModal;
  GeradorDeCodigoForm.Free;
end;

end.

