unit compra_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls, Spin, ExtCtrls,
  EditBtn, DBGrids, StrUtils, compra_entity, compra_bll, application_types,
  mensagem_validacao_form, prop_to_comp_map, produto_bll, produto_entity,
  fornecedor_entity, fornecedor_bll, grid_configurator, compra_item_entity,
  fields_builder, application_functions, db_context, Variants, BufDataset, DB,
  Generics.Collections, LCLType, Menus;

type

  { TCompraCadForm }

  TCompraCadForm = class(TForm)
    btCancel: TButton;
    btSave: TButton;
    btPesquisarFornecedor: TButton;
    btPesquisarProduto: TButton;
    btLancarProduto: TButton;
    dsTemp: TDataSource;
    edID: TEdit;
    edIdFornecedor: TEdit;
    Label1: TLabel;
    labGrandTotal: TLabel;
    labID: TLabel;
    bufProdItens: TBufDataset;
    ckAtivo: TCheckBox;
    GridItensCompra: TDBGrid;
    edDataCompra: TDateEdit;
    edNomeFornecedor: TEdit;
    edCodProduto: TEdit;
    edNomeProduto: TEdit;
    edTotal: TFloatSpinEdit;
    edQtde: TFloatSpinEdit;
    edValor: TFloatSpinEdit;
    gbCabecalho: TGroupBox;
    gbProduto: TGroupBox;
    labDataCompra: TLabel;
    labIdFornecedor: TLabel;
    labCodProduto: TLabel;
    labNomeProduto: TLabel;
    labQtde: TLabel;
    labValor: TLabel;
    labTotal: TLabel;
    labNomeFornecedor: TLabel;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    itensPopMenu: TPopupMenu;
    procedure btCancelClick(Sender: TObject);
    procedure btLancarProdutoClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure edCodProdutoExit(Sender: TObject);
    procedure edIdFornecedorExit(Sender: TObject);
    procedure edQtdeChange(Sender: TObject);
    procedure edTotalChange(Sender: TObject);
    procedure edValorChange(Sender: TObject);
  private
    FCompra: TCompraEntity;
    FCompraItens: specialize TObjectList<TCompraItemEntity>;
    FCompraBLL: TCompraBLL;
    FProdutoBLL: TProdutoBLL;
    FLastProduto: TProdutoEntity;
    FLastFornecedor: TFornecedorEntity;
    FFornecedorBLL: TFornecedorBLL;
    FPropToCompMap: TPropToCompMap;
    FGridConfig: TGridConfigurator;
    procedure ConfigMapPropComp;
    procedure FindProduto;
    procedure FindFornecedor(SuppressMessage: Boolean);
    procedure ObjectToComp;
    procedure ConfigureGrid;
    procedure CopyItensToBuf;
    procedure MergeItensFromBuf;
    procedure CalcGrandTotal;
  public
    class procedure Edit(Id: Integer);
  end;

var
  CompraCadForm: TCompraCadForm;

implementation

uses dataset_calcs;

{$R *.lfm}

{ TCompraCadForm }

procedure TCompraCadForm.btSaveClick(Sender: TObject);
var
  opResult: TOperationResult;
begin
  try
    btSave.Enabled := False;
    FPropToCompMap.CompToObject(FCompra);
    MergeItensFromBuf;

    opResult := FCompraBLL.AddOrUpdateCompra(FCompra, FCompraItens);

    if opResult.Success then
      Close
    else
      TMensagemValidacaoForm.Open(opResult.Message, FCompra, FPropToCompMap);
  finally
    btSave.Enabled := True;
  end;
end;

procedure TCompraCadForm.edCodProdutoExit(Sender: TObject);
begin
  FindProduto;
end;

procedure TCompraCadForm.edIdFornecedorExit(Sender: TObject);
begin
  FindFornecedor(False);
end;

procedure TCompraCadForm.edQtdeChange(Sender: TObject);
begin
  edTotal.OnChange := nil;
  edTotal.Value := edQtde.Value * edValor.Value;
  edTotal.OnChange := @edTotalChange;
end;

procedure TCompraCadForm.edTotalChange(Sender: TObject);
begin
  edValor.OnChange := nil;
  edValor.Value := edTotal.Value / edQtde.Value;
  edValor.OnChange := @edValorChange;
end;

procedure TCompraCadForm.edValorChange(Sender: TObject);
begin
  edTotal.OnChange := nil;
  edTotal.Value := edQtde.Value * edValor.Value;
  edTotal.OnChange := @edTotalChange;
end;

procedure TCompraCadForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEditWithNumbersOnly('Id', edId, labId);
  FPropToCompMap.MapDateEdit('Data', edDataCompra, labDataCompra);
  FPropToCompMap.MapEditWithNumbersOnly('IdFornecedor', edIdFornecedor, labIdFornecedor);
  FPropToCompMap.MapCharCheckbox('Situacao', ckAtivo, 'E', 'A');
end;

procedure TCompraCadForm.FindProduto;
var
  produtoList: specialize TList<TProdutoEntity>;
begin
  FreeAndNil(FLastProduto);

  if IsEmptyStr(edCodProduto.Text, [' ']) then Exit;

  produtoList := FProdutoBLL.InnerDAL.FindByFilter(VarArrayOf(['Codigo', '=', edCodProduto.Text]));

  if produtoList.Count > 0 then
    FLastProduto := produtoList.ExtractIndex(0);
  produtoList.Free;

  if FLastProduto <> nil then
  begin
    edNomeProduto.Text := FLastProduto.Nome;
    edValor.Value := FLastProduto.PrecoCusto;
  end
  else
  begin
    Application.MessageBox('Produto não encontrado!', 'Atenção',
      MB_ICONASTERISK + MB_OK);
  end;
end;

procedure TCompraCadForm.FindFornecedor(SuppressMessage: Boolean);
var
  i: Integer;
begin
  FreeAndNil(FLastFornecedor);

  if not TryStrToInt(edIdFornecedor.Text, i) then
    Exit;

  FLastFornecedor := FFornecedorBLL.InnerDAL.FindByPK(StrToInt(edIdFornecedor.Text));
  if FLastFornecedor <> nil then
  begin
    edNomeFornecedor.Text := FLastFornecedor.Nome;
  end
  else
  begin
    edNomeFornecedor.Clear;

    if not SuppressMessage then
      Application.MessageBox('Fornecedor não encontrado!', 'Atenção', MB_ICONASTERISK + MB_OK);
  end;
end;

procedure TCompraCadForm.ObjectToComp;
begin
  FPropToCompMap.ObjectToComp(FCompra);
  if edIdFornecedor.Text = '0' then
    edIdFornecedor.Clear;

end;


procedure TCompraCadForm.ConfigureGrid;
var
  fb: TFieldsBuilder;
begin
  fb := TFieldsBuilder.Create(bufProdItens);
  bufProdItens.Fields.Clear;
  fb.LongIntField('IdProduto');
  fb.StringField('Codigo', 20);
  fb.StringField('Nome', 60);
  fb.FloatField('Qtde');
  fb.FloatField('Valor');
  fb.FloatField('Total');
  fb.LongIntField('Pointer');
  bufProdItens.CreateDataset;
  fb.Free;

  FGridConfig.WithGrid(GridItensCompra)
    .SetDefaultProps
    //.AddColumn('IdProduto', 'ID', 80)
    .AddColumn('Codigo', 'Código', 80)
    .AddColumn('Nome', 'Nome', 300)
    .AddColumn('Qtde', 'Qtde', 120, ',0.00')
    .AddColumn('Valor', 'Valor', 120, ',0.00')
    .AddColumn('Total', 'Total', 120, ',0.00');
end;

procedure TCompraCadForm.CopyItensToBuf;
var
  item: TCompraItemEntity;
  produto: TProdutoEntity = nil;
begin
  for item in FCompraItens do
  begin
    produto := FProdutoBLL.InnerDAL.FindByPK(item.IdProduto);
    bufProdItens.Append;
    bufProdItens.FieldByName('IdProduto').AsFloat := item.IdProduto;
    bufProdItens.FieldByName('Codigo').AsString := produto.Codigo;
    bufProdItens.FieldByName('Nome').AsString := produto.Nome;
    bufProdItens.FieldByName('Qtde').AsFloat := item.Qtde;
    bufProdItens.FieldByName('Valor').AsFloat := item.Valor;
    bufProdItens.FieldByName('Total').AsFloat := item.Total;
    bufProdItens.FieldByName('Pointer').AsInteger := PtrUInt(item);
    bufProdItens.Post;
  end;
  FreeAndNil2(produto);
end;

procedure TCompraCadForm.MergeItensFromBuf;
  procedure MergeItem(item: TCompraItemEntity);
  begin
    item.IdProduto:= bufProdItens.FieldByName('IdProduto').AsInteger;
    item.Qtde := bufProdItens.FieldByName('Qtde').AsFloat;
    item.Valor := bufProdItens.FieldByName('Valor').AsFloat;
    item.Total := bufProdItens.FieldByName('Total').AsFloat;
  end;

var
  itemAux: TCompraItemEntity;
  p: Pointer;
begin
  bufProdItens.DisableControls;
  bufProdItens.First;
  while not bufProdItens.EOF do
  begin
    if bufProdItens.FieldByName('Pointer').AsString = '' then
    begin
      itemAux := FCompraBLL.NewCompraItem;
      MergeItem(itemAux);
      FCompraItens.Add(itemAux);
    end
    else
    begin
      p := Pointer(bufProdItens.FieldByName('Pointer').AsInteger);
      itemAux := TCompraItemEntity(p);
      MergeItem(itemAux);
    end;
    bufProdItens.Next;
  end;
end;

procedure TCompraCadForm.CalcGrandTotal;
var
  calc: TDatasetCalcs;
begin
  calc := TDatasetCalcs.Create;
  labGrandTotal.Caption := FloatToStr(calc.SumColumn(bufProdItens, 'Total'));
end;

procedure TCompraCadForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TCompraCadForm.btLancarProdutoClick(Sender: TObject);
begin
  if FLastProduto = nil then
  begin
    Application.MessageBox('O Produto informado é Inválido!', 'Atenção', MB_ICONASTERISK + MB_OK);
    Exit;
  end;

  bufProdItens.Append;
  bufProdItens.FieldByName('IdProduto').AsInteger := FLastProduto.Id;
  bufProdItens.FieldByName('Codigo').AsString := FLastProduto.Codigo;
  bufProdItens.FieldByName('Nome').AsString := FLastProduto.Nome;
  bufProdItens.FieldByName('Qtde').AsFloat := edQtde.Value;
  bufProdItens.FieldByName('Valor').AsFloat := edValor.Value;
  bufProdItens.FieldByName('Total').AsFloat := edTotal.Value;
  bufProdItens.Post;

  CalcGrandTotal;

  edQtde.Value := 1;
  edCodProduto.Clear;
  edNomeProduto.Clear;
  FreeAndNil(FLastProduto);
  edCodProduto.SetFocus;
end;

class procedure TCompraCadForm.Edit(Id: Integer);
begin
  Application.CreateForm(TCompraCadForm, CompraCadForm);
  with CompraCadForm do
  begin
    FCompraBLL := TCompraBLL.Create(gAppDbContext);
    FProdutoBLL := TProdutoBLL.Create(gAppDbContext);
    FFornecedorBLL := TFornecedorBLL.Create(gAppDbContext);
    FPropToCompMap := TPropToCompMap.Create;
    FGridConfig := TGridConfigurator.Create;
    FLastProduto := nil;
    FLastFornecedor := nil;

    ConfigMapPropComp;
    ConfigureGrid;

    FCompraBLL.LoadCompra(Id, FCompra, FCompraItens);

    ObjectToComp;
    CopyItensToBuf;
    FindFornecedor(True);
    CalcGrandTotal;

    ShowModal;

    FCompraBLL.Free;
    FProdutoBLL.Free;
    FFornecedorBLL.Free;
    FPropToCompMap.Free;
    FGridConfig.Free;
    if Assigned(FLastProduto) then;
      FLastProduto.Free;
    if Assigned(FLastFornecedor) then
      FLastFornecedor.Free;
    FCompra.Free;
    FCompraItens.Free;

    Free;
  end;
end;

end.

