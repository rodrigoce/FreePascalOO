unit fornecedor_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DB, BufDataset, Forms, Controls, Dialogs, DBGrids, StdCtrls,
  ExtCtrls, Menus, fornecedor_bll, fornecedor_cad_form, grid_configurator,
  prop_to_comp_map, fornecedor_filter, application_types,
  mensagem_validacao_form, db_context, ComboBoxValue, PanelTitle,
  LCLType, Classes;

type

  { TFornecedorManForm }

  TFornecedorManForm = class(TForm)
    pnAcoes: TPanelTitle;
    btCancel: TButton;
    btEdit: TButton;
    btNew: TButton;
    btSearch: TButton;
    btSelect: TButton;
    buf: TBufDataset;
    cbSituacao: TComboBoxValue;
    edContato: TEdit;
    edNome: TEdit;
    GridFornecedors: TDBGrid;
    ds: TDataSource;
    labContato: TLabel;
    labNome: TLabel;
    labSituacao: TLabel;
    leftFlowPanel: TFlowPanel;
    menuLogEdicoes: TMenuItem;
    gridPopUp: TPopupMenu;
    pnPesquisa: TPanelTitle;
    procedure btCancelClick(Sender: TObject);
    procedure btNewClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure btSelectClick(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: char);
    procedure GridFornecedorsDblClick(Sender: TObject);
    procedure menuLogEdicoesClick(Sender: TObject);
  private
    FSelectionResult: TSelectionResult;
    FIsSelectionMode: Boolean;
    FPropToCompMap: TPropToCompMap;
    FFornecedorBLL: TFornecedorBLL;
    FGridConfig: TGridConfigurator;
    FFornecedorFilter: TFornecedorFilter;
    procedure SearchFornecedores;
    procedure ConfigureGrid;
    procedure ConfigMapPropComp;
    procedure EditFornecedor;
    procedure SelectFornecedor;
    procedure ConfigureSelectionMode(IsSelectionMode: Boolean);
  public
    class function Open(IsSelectionMode: Boolean): TSelectionResult;
  end;

var
  FornecedorManForm: TFornecedorManForm;

implementation

uses entity_log_form;

{$R *.lfm}

{ TFornecedorManForm }

procedure TFornecedorManForm.btNewClick(Sender: TObject);
begin
  TFornecedorCadForm.Edit(0);
  SearchFornecedores;
end;

procedure TFornecedorManForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFornecedorManForm.btEditClick(Sender: TObject);
begin
  EditFornecedor;
end;

procedure TFornecedorManForm.btSearchClick(Sender: TObject);
begin
  SearchFornecedores;
end;

procedure TFornecedorManForm.btSelectClick(Sender: TObject);
begin
  SelectFornecedor;
end;

procedure TFornecedorManForm.edCodigoKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btSearch.Click;
end;

procedure TFornecedorManForm.GridFornecedorsDblClick(Sender: TObject);
begin
  if FIsSelectionMode then
    SelectFornecedor
  else
    EditFornecedor;
end;

procedure TFornecedorManForm.menuLogEdicoesClick(Sender: TObject);
begin
  if buf.RecordCount = 0 then Exit;

  TEntityLogForm.Open('TFornecedorEntity' , buf.FieldByName('Id').Value);
end;

procedure TFornecedorManForm.SearchFornecedores;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FFornecedorFilter);
  opResult := FFornecedorBLL.SearchFornecedores(buf, FFornecedorFilter);

  if not opResult.Success then
    TMensagemValidacaoForm.Open(opResult.Message, FFornecedorFilter, FPropToCompMap);
end;

procedure TFornecedorManForm.ConfigureGrid;
begin
  FGridConfig.WithGrid(GridFornecedors)
    .SetDefaultProps
    .AddOrderAbility
    .AddColumn('ID', 'ID', 80)
    .AddColumn('NOME', 'Nome', 250)
    .AddColumn('CONTATOS', 'Contatos', 450)
    .SetOrderedColumn('NOME');
end;

procedure TFornecedorManForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEdit('Nome', edNome, 60, labNome);
  FPropToCompMap.MapEdit('Contato', edContato, 60, labNome);
  FPropToCompMap.MapCBValue('Situacao', cbSituacao, labSituacao);

  FFornecedorBLL.FillDefaultFilter(FFornecedorFilter);
  FPropToCompMap.ObjectToComp(FFornecedorFilter);

end;

procedure TFornecedorManForm.EditFornecedor;
var
  rememberId: Integer;
begin
  if buf.RecordCount = 0 then Exit;

  rememberId := buf.FieldByName('Id').AsInteger;
  TFornecedorCadForm.Edit(buf.FieldByName('id').AsInteger);
  SearchFornecedores;
  buf.Locate('Id', rememberId, []);
end;

procedure TFornecedorManForm.SelectFornecedor;
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

procedure TFornecedorManForm.ConfigureSelectionMode(IsSelectionMode: Boolean);
begin
  btSelect.Visible := IsSelectionMode;
  btCancel.Visible := IsSelectionMode;
end;

class function TFornecedorManForm.Open(IsSelectionMode: Boolean
  ): TSelectionResult;
begin
  Application.CreateForm(TFornecedorManForm, FornecedorManForm);
  with FornecedorManForm do
  begin
    FSelectionResult.Success := False;
    FIsSelectionMode := IsSelectionMode;
    FPropToCompMap := TPropToCompMap.Create;
    FGridConfig := TGridConfigurator.Create;
    FFornecedorBLL := TFornecedorBLL.Create(gAppDbContext);
    FFornecedorFilter := TFornecedorFilter.Create;

    ConfigureGrid;
    ConfigMapPropComp;
    SearchFornecedores;
    ConfigureSelectionMode(IsSelectionMode);
    FornecedorManForm.ShowModal;

    FPropToCompMap.Free;
    FGridConfig.Free;
    FFornecedorBLL.Free;
    FFornecedorFilter.Free;

    Result := FSelectionResult;

    Free;
  end;
end;

end.

