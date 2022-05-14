unit produto_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, BufDataset, SQLDB, dbf, Forms,
  Controls, Graphics, Dialogs, DBGrids, StdCtrls, produto_dal, produto_cad_form;

type

  { TProdutoManForm }

  TProdutoManForm = class(TForm)
    buf: TBufDataset;
    Button1: TButton;
    ds: TDataSource;
    DBGrid1: TDBGrid;
    procedure Button1Click(Sender: TObject);
  private
    FProdutoDal: TProdutoDal;
  public
    class procedure OpenFeature;
  end;

var
  ProdutoManForm: TProdutoManForm;

implementation

{$R *.lfm}

{ TProdutoManForm }

procedure TProdutoManForm.Button1Click(Sender: TObject);
begin
  TProdutoCadForm.OpenFeature;
end;

class procedure TProdutoManForm.OpenFeature;
begin
  Application.CreateForm(TProdutoManForm, ProdutoManForm);
  with ProdutoManForm do
  begin
    FProdutoDal := TProdutoDAL.Create;
    FProdutoDal.LoadPesquisaProdutos(buf);
    ProdutoManForm.ShowModal;
    FProdutoDal.Free;
    ProdutoManForm.Free;
  end;
end;

end.

