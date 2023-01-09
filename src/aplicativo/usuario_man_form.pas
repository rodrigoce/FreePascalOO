unit usuario_man_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, DB, BufDataset, Forms, Controls, Dialogs,
  DBGrids, StdCtrls, ExtCtrls, Menus, usuario_bll, usuario_cad_form,
  grid_configurator, prop_to_comp_map, usuario_filter, application_types,
  mensagem_validacao_form, usuario_change_pass_form, db_context,
  ComboBoxValue;

type

  { TUsuarioManForm }

  TUsuarioManForm = class(TForm)
    btEdit: TButton;
    btChangePassword: TButton;
    btNovo: TButton;
    btSearch: TButton;
    buf: TBufDataset;
    cbSituacao: TComboBoxValue;
    GridUsuarios: TDBGrid;
    ds: TDataSource;
    edNome: TEdit;
    GroupBox1: TGroupBox;
    labSituacao: TLabel;
    labNome: TLabel;
    menuLogEdicoes: TMenuItem;
    pnAcoes: TPanel;
    gridPopUp: TPopupMenu;
    procedure btChangePasswordClick(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure btEditClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: char);
    procedure GridUsuariosDblClick(Sender: TObject);
    procedure menuLogEdicoesClick(Sender: TObject);
  private
    FPropToCompMap: TPropToCompMap;
    FUsuarioBLL: TUsuarioBLL;
    FGridConfig: TGridConfigurator;
    FUsuarioFilter: TUsuarioFilter;
    procedure SearchUsuarios;
    procedure ConfigureGrid;
    procedure ConfigMapPropComp;
    procedure EditUsuario;
  public
    class procedure Open;
  end;

var
  UsuarioManForm: TUsuarioManForm;

implementation

uses entity_log_form;

{$R *.lfm}

{ TUsuarioManForm }

procedure TUsuarioManForm.btNovoClick(Sender: TObject);
begin
  TUsuarioCadForm.Edit(0);
  SearchUsuarios;
end;

procedure TUsuarioManForm.btChangePasswordClick(Sender: TObject);
begin
  if buf.RecordCount = 0 then Exit;

  TUsuarioChangePassForm.ChangePassword(buf.FieldByName('Id').Value);
end;

procedure TUsuarioManForm.btEditClick(Sender: TObject);
begin
  EditUsuario;
end;

procedure TUsuarioManForm.btSearchClick(Sender: TObject);
begin
  SearchUsuarios;
end;

procedure TUsuarioManForm.edCodigoKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btSearch.Click;
end;

procedure TUsuarioManForm.GridUsuariosDblClick(Sender: TObject);
begin
  EditUsuario;
end;

procedure TUsuarioManForm.menuLogEdicoesClick(Sender: TObject);
begin
  if buf.RecordCount = 0 then Exit;

  TEntityLogForm.Open('TUsuarioEntity' , buf.FieldByName('Id').Value);
end;

procedure TUsuarioManForm.SearchUsuarios;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FUsuarioFilter);
  opResult := FUsuarioBLL.SearchUsuarios(buf, FUsuarioFilter);

  if not opResult.Success then
    TMensagemValidacaoForm.Open(opResult.Message, FUsuarioFilter, FPropToCompMap);
end;

procedure TUsuarioManForm.ConfigureGrid;
begin
  FGridConfig.WithGrid(GridUsuarios)
    .SetDefaultProps
    .AddOrderAbility
    .AddColumn('ID', 'ID', 80)
    .AddColumn('NOME', 'Nome DO Usuário', 250)
    .AddColumn('USER_NAME', 'Nome DE Usuário', 150)
    .AddColumn('DATA_ULT_LOGIN', 'Data Ult. Login', 120)
    .SetOrderedColumn('NOME');
end;

procedure TUsuarioManForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEdit('Nome', edNome, 60, labNome);
  FPropToCompMap.MapCBValue('Situacao', cbSituacao, labSituacao);

  FUsuarioBLL.FillDefaultFilter(FUsuarioFilter);
  FPropToCompMap.ObjectToComp(FUsuarioFilter);

end;

procedure TUsuarioManForm.EditUsuario;
var
  rememberId: Integer;
begin
  if buf.RecordCount = 0 then Exit;

  rememberId := buf.FieldByName('Id').AsInteger;
  TUsuarioCadForm.Edit(buf.FieldByName('id').AsInteger);
  SearchUsuarios;
  buf.Locate('Id', rememberId, []);
end;

class procedure TUsuarioManForm.Open;
begin
  Application.CreateForm(TUsuarioManForm, UsuarioManForm);
  with UsuarioManForm do
  begin
    FPropToCompMap := TPropToCompMap.Create;
    FGridConfig := TGridConfigurator.Create;
    FUsuarioBLL := TUsuarioBLL.Create(gAppDbContext);
    FUsuarioFilter := TUsuarioFilter.Create;

    ConfigureGrid;
    ConfigMapPropComp;
    SearchUsuarios;
    UsuarioManForm.ShowModal;

    FPropToCompMap.Free;
    FGridConfig.Free;
    FUsuarioBLL.Free;
    FUsuarioFilter.Free;

    Free;
  end;
end;

end.

