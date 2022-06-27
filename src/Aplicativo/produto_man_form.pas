unit produto_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, BufDataset, SQLDB, Forms,
  Controls, Graphics, Dialogs, DBGrids, StdCtrls, ExtCtrls, Grids, produto_bll,
  produto_cad_form, grid_configurator;

type

  { TProdutoManForm }

  TProdutoManForm = class(TForm)
    btEdit: TButton;
    btNovo: TButton;
    btSearch: TButton;
    buf: TBufDataset;
    GridProdutos: TDBGrid;
    ds: TDataSource;
    edReferencia: TEdit;
    edNome: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    procedure btNovoClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
  private
    FProdutoBLL: TProdutoBLL;
    FGridConfig: TGridCofingurator;
    procedure Search;
    procedure ConfigureGrid;
  public
    class procedure Open;
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
var
  rememberId: Integer;
begin
  rememberId := buf.FieldByName('Id').AsInteger;
  TProdutoCadForm.Edit(buf.FieldByName('id').AsInteger);
  Search;
  buf.Locate('Id', rememberId, []);
end;

procedure TProdutoManForm.Search;
begin
  FProdutoBLL.SearchProdutos(buf);
end;

procedure TProdutoManForm.ConfigureGrid;
begin


  FGridConfig.WithGrid(GridProdutos)
    .SetDefaultProps
    .AddOrderAbility
    .AddColumn('ID', 'ID', 80)
    .AddColumn('REFERENCIA', 'Referencia', 80)
    .AddColumn('NOME', 'Nome', 250)
    .AddColumn('PRECO_CUSTO', 'Preço Custo', 120, ',0.00')
    .AddColumn('MARGEM_LUCRO', 'Margem Lucro', 120, ',0.00')
    .AddColumn('PRECO_VENDA', 'Preço Venda', 120, ',0.00');

end;

class procedure TProdutoManForm.Open;
begin
  Application.CreateForm(TProdutoManForm, ProdutoManForm);
  with ProdutoManForm do
  begin
    FGridConfig := TGridCofingurator.Create;
    ConfigureGrid;
    FProdutoBLL := TProdutoBLL.Create;
    Search;
    ProdutoManForm.ShowModal;
    FGridConfig.Free;
    FProdutoBLL.Free;
    ProdutoManForm.Free;
  end;
end;

end.

