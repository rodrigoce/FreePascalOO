unit compra_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DB, BufDataset, Forms, Controls, Dialogs,
  DBGrids, StdCtrls, ExtCtrls, Menus, EditBtn, ComCtrls,
  compra_bll, compra_cad_form, grid_configurator, prop_to_comp_map,
  compra_filter, application_types, mensagem_validacao_form, db_context,
  ComboBoxValue, BBarPanel, LCLType, Classes;

type

  { TCompraManForm }

  TCompraManForm = class(TForm)
    barAcoes: TBBarPanel;
    btCancel: TButton;
    btEdit: TButton;
    btNew: TButton;
    btSearch: TButton;
    btSelect: TButton;
    buf: TBufDataset;
    cbSituacao: TComboBoxValue;
    edDtIni: TDateEdit;
    edDtFim: TDateEdit;
    GridCompras: TDBGrid;
    ds: TDataSource;
    GroupBox1: TGroupBox;
    labDtIni: TLabel;
    labSituacao: TLabel;
    labDtFim: TLabel;
    leftFlowPanel: TFlowPanel;
    menuLogEdicoes: TMenuItem;
    gridPopUp: TPopupMenu;
    procedure btCancelClick(Sender: TObject);
    procedure btNewClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure btSelectClick(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: char);
    procedure GridComprasDblClick(Sender: TObject);
    procedure menuLogEdicoesClick(Sender: TObject);
  private
    FSelectionResult: TSelectionResult;
    FIsSelectionMode: Boolean;
    FPropToCompMap: TPropToCompMap;
    FCompraBLL: TCompraBLL;
    FGridConfig: TGridConfigurator;
    FCompraFilter: TCompraFilter;
    procedure SearchCompras;
    procedure ConfigureGrid;
    procedure ConfigMapPropComp;
    procedure EditCompra;
    procedure SelectCompra;
    procedure ConfigureSelectionMode(IsSelectionMode: Boolean);
  public
    class function Open(IsSelectionMode: Boolean): TSelectionResult;
  end;

var
  CompraManForm: TCompraManForm;

implementation

uses entity_log_form;

{$R *.lfm}

{ TCompraManForm }

procedure TCompraManForm.btNewClick(Sender: TObject);
begin
  TCompraCadForm.Edit(0);
  SearchCompras;
end;

procedure TCompraManForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TCompraManForm.btEditClick(Sender: TObject);
begin
  EditCompra;
end;

procedure TCompraManForm.btSearchClick(Sender: TObject);
begin
  SearchCompras;
end;

procedure TCompraManForm.btSelectClick(Sender: TObject);
begin
  SelectCompra;
end;

procedure TCompraManForm.edCodigoKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btSearch.Click;
end;

procedure TCompraManForm.GridComprasDblClick(Sender: TObject);
begin
  if FIsSelectionMode then
    SelectCompra
  else
    EditCompra;
end;

procedure TCompraManForm.menuLogEdicoesClick(Sender: TObject);
begin
  if buf.RecordCount = 0 then Exit;

  TEntityLogForm.Open('TCompraEntity' , buf.FieldByName('Id').Value);
end;

procedure TCompraManForm.SearchCompras;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FCompraFilter);
  opResult := FCompraBLL.SearchCompras(buf, FCompraFilter);

  if not opResult.Success then
    TMensagemValidacaoForm.Open(opResult.Message, FCompraFilter, FPropToCompMap);
end;

procedure TCompraManForm.ConfigureGrid;
begin
  FGridConfig.WithGrid(GridCompras)
    .SetDefaultProps
    .AddOrderAbility
    .AddColumn('ID', 'ID', 80)
    .AddColumn('DATA', 'Data', 120)
    .AddColumn('TOTAL_PRODUTOS', 'Total Produtos', 120, ',0.00')
    .AddColumn('TOTAL_DESCONTOS', 'Total Descontos', 120, ',0.00')
    .AddColumn('PER_DESCONTOS', '% Descontos', 120, ',0.00')
    .AddColumn('TOTAL_COMPRA', 'Total Compra', 120, ',0.00')
    .AddColumn('ID_FORNECEDOR', 'ID Fornecedor', 80)
    .AddColumn('NOME_FORNECEDOR', 'Nome Fornecedor', 200)
    .SetOrderedColumn('DATA');
end;

procedure TCompraManForm.ConfigMapPropComp;
begin

  FPropToCompMap.MapCBValue('Situacao', cbSituacao, labSituacao);
  FPropToCompMap.MapDateEdit('DataIni', edDtIni, labDtIni);
  FPropToCompMap.MapDateEdit('DataFim', edDtFim, labDtFim);

  FCompraBLL.FillDefaultFilter(FCompraFilter);
  FPropToCompMap.ObjectToComp(FCompraFilter);

end;

procedure TCompraManForm.EditCompra;
var
  rememberId: Integer;
begin
  if buf.RecordCount = 0 then Exit;

  rememberId := buf.FieldByName('Id').AsInteger;
  TCompraCadForm.Edit(buf.FieldByName('id').AsInteger);
  SearchCompras;
  buf.Locate('Id', rememberId, []);
end;

procedure TCompraManForm.SelectCompra;
begin
  if buf.RecordCount = 0 then
    Application.MessageBox('Nenhuma Compra está selecionada!', 'Atenção', MB_ICONASTERISK + MB_OK)
  else
  begin
    FSelectionResult.Success := True;
    FSelectionResult.Value := buf.FieldByName('Id').AsInteger;
    Close;
  end;
end;

procedure TCompraManForm.ConfigureSelectionMode(IsSelectionMode: Boolean);
begin
  btSelect.Visible := IsSelectionMode;
  btCancel.Visible := IsSelectionMode;
end;

class function TCompraManForm.Open(IsSelectionMode: Boolean): TSelectionResult;
begin
  Application.CreateForm(TCompraManForm, CompraManForm);
  with CompraManForm do
  begin
    FSelectionResult.Success := False;
    FIsSelectionMode := IsSelectionMode;
    FPropToCompMap := TPropToCompMap.Create;
    FGridConfig := TGridConfigurator.Create;
    FCompraBLL := TCompraBLL.Create(gAppDbContext);
    FCompraFilter := TCompraFilter.Create;

    ConfigureGrid;
    ConfigMapPropComp;
    SearchCompras;
    ConfigureSelectionMode(IsSelectionMode);
    CompraManForm.ShowModal;

    FPropToCompMap.Free;
    FGridConfig.Free;
    FCompraBLL.Free;
    FCompraFilter.Free;

    Result := FSelectionResult;

    Free;
  end;
end;

end.

