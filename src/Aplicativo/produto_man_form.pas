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
    btNovo: TButton;
    btEdit: TButton;
    ds: TDataSource;
    DBGrid1: TDBGrid;
    procedure btNovoClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
  private
    FProdutoDal: TProdutoDal;
    procedure Search;
  public
    class procedure OpenFeature;
  end;

var
  ProdutoManForm: TProdutoManForm;

implementation

{$R *.lfm}

{ TProdutoManForm }

procedure TProdutoManForm.btNovoClick(Sender: TObject);
begin
  TProdutoCadForm.Edit(0);
  Search;
end;

procedure TProdutoManForm.btEditClick(Sender: TObject);
begin
  TProdutoCadForm.Edit(buf.FieldByName('id').AsInteger);
  Search;
end;

procedure TProdutoManForm.Search;
begin
  FProdutoDal.LoadPesquisaProdutos(buf);
end;

class procedure TProdutoManForm.OpenFeature;
begin
  Application.CreateForm(TProdutoManForm, ProdutoManForm);
  with ProdutoManForm do
  begin
    FProdutoDal := TProdutoDAL.Create;
    Search;
    ProdutoManForm.ShowModal;
    FProdutoDal.Free;
    ProdutoManForm.Free;
  end;
end;

end.

