unit produto_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  produto_entity, produto_dal;

type

  { TProdutoCadForm }

  TProdutoCadForm = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    FProdutoEntity: TProdutoEntity;
    FProdutoDal: TProdutoDal;
  public
    class procedure OpenFeature;

  end;

var
  ProdutoCadForm: TProdutoCadForm;

implementation

{$R *.lfm}

{ TProdutoCadForm }

procedure TProdutoCadForm.Button1Click(Sender: TObject);
begin
  FProdutoEntity.Nome := Edit1.Text;
  FProdutoDal.Insert(FProdutoEntity);
  Close;
end;

class procedure TProdutoCadForm.OpenFeature;
begin
  Application.CreateForm(TProdutoCadForm, ProdutoCadForm);
  with ProdutoCadForm do
  begin
    FProdutoEntity := TProdutoEntity.Create;
    FProdutoDal := TProdutoDal.Create;
    ShowModal;
    FProdutoEntity.Free;
    FProdutoDal.Free;
  end;
end;

end.

