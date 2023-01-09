unit fornecedor_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DB, BufDataset, Forms, Controls, Dialogs,
  DBGrids, StdCtrls, ExtCtrls, Menus, fornecedor_bll, fornecedor_cad_form,
  grid_configurator, prop_to_comp_map, fornecedor_filter, application_types,
  mensagem_validacao_form, db_context, ComboBoxValue;

type

  { TFornecedorManForm }

  TFornecedorManForm = class(TForm)
    btEdit: TButton;
    btNovo: TButton;
    btSearch: TButton;
    buf: TBufDataset;
    cbSituacao: TComboBoxValue;
    edContato: TEdit;
    GridFornecedors: TDBGrid;
    ds: TDataSource;
    edNome: TEdit;
    GroupBox1: TGroupBox;
    labContato: TLabel;
    labSituacao: TLabel;
    labNome: TLabel;
    menuLogEdicoes: TMenuItem;
    pnAcoes: TPanel;
    gridPopUp: TPopupMenu;
    procedure btNovoClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: char);
    procedure GridFornecedorsDblClick(Sender: TObject);
    procedure menuLogEdicoesClick(Sender: TObject);
  private
    FPropToCompMap: TPropToCompMap;
    FFornecedorBLL: TFornecedorBLL;
    FGridConfig: TGridConfigurator;
    FFornecedorFilter: TFornecedorFilter;
    procedure SearchFornecedors;
    procedure ConfigureGrid;
    procedure ConfigMapPropComp;
    procedure EditFornecedor;
  public
    class procedure Open;
  end;

var
  FornecedorManForm: TFornecedorManForm;

implementation

uses entity_log_form;

{$R *.lfm}

{ TFornecedorManForm }

procedure TFornecedorManForm.btNovoClick(Sender: TObject);
begin
  TFornecedorCadForm.Edit(0);
  SearchFornecedors;
end;

procedure TFornecedorManForm.btEditClick(Sender: TObject);
begin
  EditFornecedor;
end;

procedure TFornecedorManForm.btSearchClick(Sender: TObject);
begin
  SearchFornecedors;
end;

procedure TFornecedorManForm.edCodigoKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btSearch.Click;
end;

procedure TFornecedorManForm.GridFornecedorsDblClick(Sender: TObject);
begin
  EditFornecedor;
end;

procedure TFornecedorManForm.menuLogEdicoesClick(Sender: TObject);
begin
  if buf.RecordCount = 0 then Exit;

  TEntityLogForm.Open('TFornecedorEntity' , buf.FieldByName('Id').Value);
end;

procedure TFornecedorManForm.SearchFornecedors;
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
  SearchFornecedors;
  buf.Locate('Id', rememberId, []);
end;

class procedure TFornecedorManForm.Open;
begin
  Application.CreateForm(TFornecedorManForm, FornecedorManForm);
  with FornecedorManForm do
  begin
    FPropToCompMap := TPropToCompMap.Create;
    FGridConfig := TGridConfigurator.Create;
    FFornecedorBLL := TFornecedorBLL.Create(gAppDbContext);
    FFornecedorFilter := TFornecedorFilter.Create;

    ConfigureGrid;
    ConfigMapPropComp;
    SearchFornecedors;
    FornecedorManForm.ShowModal;

    FPropToCompMap.Free;
    FGridConfig.Free;
    FFornecedorBLL.Free;
    FFornecedorFilter.Free;

    Free;
  end;
end;

end.

