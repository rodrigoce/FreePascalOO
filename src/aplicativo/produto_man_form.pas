unit produto_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DB, BufDataset, Forms, Controls, Dialogs,
  DBGrids, StdCtrls, ExtCtrls, Menus, produto_bll, produto_cad_form,
  grid_configurator, prop_to_comp_map, produto_filter, application_types,
  mensagem_validacao_form, db_context, ComboBoxValue, BBarPanel,
  LCLType;

type

  { TProdutoManForm }

  TProdutoManForm = class(TForm)
    barPanel: TBBarPanel;
    btCancel: TButton;
    btEdit: TButton;
    btNew: TButton;
    btSearch: TButton;
    btSelect: TButton;
    buf: TBufDataset;
    cbSituacao: TComboBoxValue;
    leftFlowPanel: TFlowPanel;
    GridProdutos: TDBGrid;
    ds: TDataSource;
    edCodigo: TEdit;
    edNome: TEdit;
    GroupBox1: TGroupBox;
    labCodigo: TLabel;
    labSituacao: TLabel;
    labNome: TLabel;
    menuLogEdicoes: TMenuItem;
    gridPopUp: TPopupMenu;
    procedure btCancelClick(Sender: TObject);
    procedure btNewClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure btSelectClick(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: char);
    procedure GridProdutosDblClick(Sender: TObject);
    procedure menuLogEdicoesClick(Sender: TObject);
  private
    FSelectionResult: TSelectionResult;
    FIsSelectionMode: Boolean;
    FPropToCompMap: TPropToCompMap;
    FProdutoBLL: TProdutoBLL;
    FGridConfig: TGridConfigurator;
    FProdutoFilter: TProdutoFilter;
    procedure SearchProdutos;
    procedure ConfigureGrid;
    procedure ConfigMapPropComp;
    procedure EditProduto;
    procedure SelectProduto;
    procedure ConfigureSelectionMode(IsSelectionMode: Boolean);
  public
    class function Open(IsSelectionMode: Boolean): TSelectionResult;
  end;

var
  ProdutoManForm: TProdutoManForm;

implementation

uses entity_log_form;

{$R *.lfm}

{ TProdutoManForm }

procedure TProdutoManForm.btNewClick(Sender: TObject);
begin
  TProdutoCadForm.Edit(0);
  SearchProdutos;
end;

procedure TProdutoManForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TProdutoManForm.btEditClick(Sender: TObject);
begin
  EditProduto;
end;

procedure TProdutoManForm.btSearchClick(Sender: TObject);
begin
  SearchProdutos;
end;

procedure TProdutoManForm.btSelectClick(Sender: TObject);
begin
  SelectProduto;
end;

procedure TProdutoManForm.edCodigoKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btSearch.Click;
end;

procedure TProdutoManForm.GridProdutosDblClick(Sender: TObject);
begin
  if FIsSelectionMode then
    SelectProduto
  else
    EditProduto;
end;

procedure TProdutoManForm.menuLogEdicoesClick(Sender: TObject);
begin
  if buf.RecordCount = 0 then Exit;

  TEntityLogForm.Open('TProdutoEntity' , buf.FieldByName('Id').Value);
end;

procedure TProdutoManForm.SearchProdutos;
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
  FPropToCompMap.MapEdit('Codigo', edCodigo, 20, labCodigo);
  FPropToCompMap.MapEdit('Nome', edNome, 60, labNome);
  FPropToCompMap.MapCBValue('Situacao', cbSituacao, labSituacao);

  FProdutoBLL.FillDefaultFilter(FProdutoFilter);
  FPropToCompMap.ObjectToComp(FProdutoFilter);

end;

procedure TProdutoManForm.EditProduto;
var
  rememberId: Integer;
begin
  if buf.RecordCount = 0 then Exit;

  rememberId := buf.FieldByName('Id').AsInteger;
  TProdutoCadForm.Edit(buf.FieldByName('id').AsInteger);
  SearchProdutos;
  buf.Locate('Id', rememberId, []);
end;

procedure TProdutoManForm.SelectProduto;
begin
  if buf.RecordCount = 0 then
    Application.MessageBox('Nenhum Produto está selecionado!', 'Atenção', MB_ICONASTERISK + MB_OK)
  else
  begin
    FSelectionResult.Success := True;
    FSelectionResult.Value := buf.FieldByName('Id').AsInteger;
    Close;
  end;
end;

procedure TProdutoManForm.ConfigureSelectionMode(IsSelectionMode: Boolean);
begin
  btSelect.Visible := IsSelectionMode;
  btCancel.Visible := IsSelectionMode;
end;

class function TProdutoManForm.Open(IsSelectionMode: Boolean): TSelectionResult;
begin
  Application.CreateForm(TProdutoManForm, ProdutoManForm);
  with ProdutoManForm do
  begin
    FSelectionResult.Success := False;
    FIsSelectionMode := IsSelectionMode;
    FPropToCompMap := TPropToCompMap.Create;
    FGridConfig := TGridConfigurator.Create;
    FProdutoBLL := TProdutoBLL.Create(gAppDbContext);
    FProdutoFilter := TProdutoFilter.Create;

    ConfigureGrid;
    ConfigMapPropComp;
    SearchProdutos;
    ConfigureSelectionMode(IsSelectionMode);
    ProdutoManForm.ShowModal;

    FPropToCompMap.Free;
    FGridConfig.Free;
    FProdutoBLL.Free;
    FProdutoFilter.Free;

    Result := FSelectionResult;

    Free;
  end;
end;

end.

