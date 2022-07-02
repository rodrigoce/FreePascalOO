unit produto_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, BufDataset, SQLDB, Forms, Controls, Graphics, Dialogs,
  DBGrids, StdCtrls, ExtCtrls, produto_bll, produto_cad_form, grid_configurator,
  prop_to_comp_map, produto_filter, application_types, mensagem_validacao_form;

type

  { TProdutoManForm }

  TProdutoManForm = class(TForm)
    btEdit: TButton;
    btNovo: TButton;
    btSearch: TButton;
    buf: TBufDataset;
    GridProdutos: TDBGrid;
    ds: TDataSource;
    edCodigo: TEdit;
    edNome: TEdit;
    GroupBox1: TGroupBox;
    labCodigo: TLabel;
    labNome: TLabel;
    pnAcoes: TPanel;
    procedure btNovoClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
  private
    FPropToCompMap: TPropToCompMap;
    FProdutoBLL: TProdutoBLL;
    FGridConfig: TGridCofingurator;
    FProdutoFilter: TProdutoFilter;
    procedure Search;
    procedure ConfigureGrid;
    procedure ConfigMapPropComp;
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

procedure TProdutoManForm.btSearchClick(Sender: TObject);
begin
  Search;
end;

procedure TProdutoManForm.Search;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FProdutoFilter);
  opResult := FProdutoBLL.SearchProdutos(buf, FProdutoFilter);

  if not opResult.Success then
    TMensagemValidacaoForm.Open(opResult.Message, FProdutoFilter, FPropToCompMap);
end;

procedure TProdutoManForm.ConfigureGrid;
begin
  FGridConfig.WithGrid(GridProdutos)
    .SetDefaultProps
    .AddOrderAbility
    .AddColumn('ID', 'ID', 80)
    .AddColumn('CODIGO', 'Código', 80)
    .AddColumn('NOME', 'Nome', 250)
    .AddColumn('PRECO_CUSTO', 'Preço Custo', 120, ',0.00')
    .AddColumn('MARGEM_LUCRO', 'Margem Lucro', 120, ',0.00')
    .AddColumn('PRECO_VENDA', 'Preço Venda', 120, ',0.00')
    .SetOrderedColumn('NOME');
end;

procedure TProdutoManForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapString('Codigo', edCodigo, 20, labCodigo);
  FPropToCompMap.MapString('Nome', edNome, 60, labNome);
end;

class procedure TProdutoManForm.Open;
begin
  Application.CreateForm(TProdutoManForm, ProdutoManForm);
  with ProdutoManForm do
  begin
    FPropToCompMap := TPropToCompMap.Create;
    FGridConfig := TGridCofingurator.Create;
    FProdutoBLL := TProdutoBLL.Create;
    FProdutoFilter := TProdutoFilter.Create;

    ConfigureGrid;
    ConfigMapPropComp;
    Search;
    ProdutoManForm.ShowModal;

    FPropToCompMap.Free;
    FGridConfig.Free;
    FProdutoBLL.Free;
    FProdutoFilter.Free;

    ProdutoManForm.Free;
  end;
end;

end.

