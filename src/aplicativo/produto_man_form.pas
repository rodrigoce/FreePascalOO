unit produto_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DB, BufDataset, Forms, Controls, Dialogs,
  DBGrids, StdCtrls, ExtCtrls, Menus, produto_bll, produto_cad_form,
  grid_configurator, prop_to_comp_map, produto_filter, application_types,
  mensagem_validacao_form, db_context, ComboBoxValue, BBarPanel,
  LCLType, Classes, Graphics, LCLIntf;

type

  { TProdutoManForm }

  TProdutoManForm = class(TForm)
    barAcoes: TBBarPanel;
    btCancel: TButton;
    btEdit: TButton;
    btNew: TButton;
    btSearch: TButton;
    btSearch1: TButton;
    btSelect: TButton;
    buf: TBufDataset;
    cbSituacao: TComboBoxValue;
    cbSituacao1: TComboBoxValue;
    edCodigo1: TEdit;
    edNome1: TEdit;
    labCodigo1: TLabel;
    labNome1: TLabel;
    labSituacao1: TLabel;
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
    Panel1: TPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btNewClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure btSelectClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: char);
    procedure GridProdutosDblClick(Sender: TObject);
    procedure menuLogEdicoesClick(Sender: TObject);
    procedure Panel1Paint(Sender: TObject);
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

procedure TProdutoManForm.Button1Click(Sender: TObject);

begin

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

procedure TProdutoManForm.Panel1Paint(Sender: TObject);

function Darker2(MyColor:TColor; Percent:Byte):TColor;
var r,g,b:Byte;
begin
  MyColor:=ColorToRGB(MyColor);
  r:=GetRValue(MyColor);
  g:=GetGValue(MyColor);
  b:=GetBValue(MyColor);
  r:=r-muldiv(r,Percent,100);  //Percent% closer to black
  g:=g-muldiv(g,Percent,100);
  b:=b-muldiv(b,Percent,100);
  result:=RGB(r,g,b);
end;
function Lighter2(MyColor:TColor; Percent:Byte):TColor;
var r,g,b:Byte;
begin
  MyColor:=ColorToRGB(MyColor);
  r:=GetRValue(MyColor);
  g:=GetGValue(MyColor);
  b:=GetBValue(MyColor);
  r:=r+muldiv(255-r,Percent,100); //Percent% closer to white
  g:=g+muldiv(255-g,Percent,100);
  b:=b+muldiv(255-b,Percent,100);
  result:=RGB(r,g,b);
end;


var
  anotherCanvas: TControlCanvas;
  cap: string;
begin
  // para não mudar a cor do panel deixada em desing
  // crio outro canvas, senão poderia usar o canvas do controle.
  anotherCanvas := TControlCanvas.Create;
  anotherCanvas.Control := Panel1;
  anotherCanvas.Pen.Color := Darker2((Sender as TPanel).Color, 60);
  anotherCanvas.Pen.Width := 1;
  anotherCanvas.Pen.EndCap := pecSquare;
  anotherCanvas.Font.Color := Darker2((Sender as TPanel).Color, 60);
  anotherCanvas.Brush.Color := (Sender as TPanel).Color;
  anotherCanvas.Line(5, 8, 25, 8); // comprimento 20
  cap := 'Pesquisa de Produtos';
  anotherCanvas.TextOut(30, 0, cap);
  anotherCanvas.Line(anotherCanvas.TextWidth(cap) + 35, 8, 30 + anotherCanvas.TextWidth(cap) + 25, 8);
  anotherCanvas.Free;
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

