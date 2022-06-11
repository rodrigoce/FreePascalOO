unit produto_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, BufDataset, SQLDB, dbf, Forms,
  Controls, Graphics, Dialogs, DBGrids, StdCtrls, ExtCtrls, Grids, produto_bll,
  produto_cad_form;

type

  { TProdutoManForm }

  TProdutoManForm = class(TForm)
    btEdit: TButton;
    btNovo: TButton;
    btSearch: TButton;
    buf: TBufDataset;
    ds: TDataSource;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    Edit2: TEdit;
    edReferencia: TEdit;
    edNome: TEdit;
    FlowPanel1: TFlowPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    procedure btNovoClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
  private
    FProdutoBLL: TProdutoBLL;
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
  FProdutoBLL.SearchProdutos(buf);
end;

class procedure TProdutoManForm.OpenFeature;
begin
  Application.CreateForm(TProdutoManForm, ProdutoManForm);
  with ProdutoManForm do
  begin
    FProdutoBLL := TProdutoBLL.Create;
    Search;
    ProdutoManForm.ShowModal;
    FProdutoBLL.Free;
    ProdutoManForm.Free;
  end;
end;

end.

