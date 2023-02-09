unit compra_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls, Spin, ExtCtrls,
  EditBtn, DBGrids, StrUtils, compra_entity, compra_bll, application_types,
  mensagem_validacao_form, prop_to_comp_map, produto_bll, produto_entity,
  fornecedor_entity, fornecedor_bll, grid_configurator, compra_item_entity,
  fields_builder, application_functions, db_context, entity_log_form,
  produto_man_form, images_dm, fornecedor_man_form, PanelTitle, Variants,
  BufDataset, DB, Generics.Collections, LCLType, Menus, Buttons;

type

  { TCompraCadForm }

  TCompraCadForm = class(TForm)
    barAcoes: TPanelTitle;
    btCancel: TButton;
    btPesquisarProduto: TBitBtn;
    btPesquisarFornecedor: TBitBtn;
    btLancarProduto: TButton;
    btSave: TButton;
    ckAtivo: TCheckBox;
    dsTemp: TDataSource;
    edID: TEdit;
    edIdFornecedor: TEdit;
    edTotalGeral: TEdit;
    Label1: TLabel;
    labID: TLabel;
    bufProdItens: TBufDataset;
    GridItensCompra: TDBGrid;
    edDataCompra: TDateEdit;
    edNomeFornecedor: TEdit;
    edCodProduto: TEdit;
    edNomeProduto: TEdit;
    edTotal: TFloatSpinEdit;
    edQtde: TFloatSpinEdit;
    edValor: TFloatSpinEdit;
    gbCabecalho: TPanelTitle;
    pnProduto: TPanelTitle;
    labDataCompra: TLabel;
    labIdFornecedor: TLabel;
    labCodProduto: TLabel;
    labNomeProduto: TLabel;
    labQtde: TLabel;
    labValor: TLabel;
    labTotal: TLabel;
    labNomeFornecedor: TLabel;
    leftFlowPanel: TFlowPanel;
    menuExcluirItem: TMenuItem;
    menuLogEdicoes: TMenuItem;
    itensPopMenu: TPopupMenu;
    rightFlowPanel: TFlowPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btLancarProdutoClick(Sender: TObject);
    procedure btPesquisarFornecedorClick(Sender: TObject);
    procedure btPesquisarProdutoClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure edCodProdutoExit(Sender: TObject);
    procedure edIdFornecedorExit(Sender: TObject);
    procedure edQtdeChange(Sender: TObject);
    procedure edTotalChange(Sender: TObject);
    procedure edValorChange(Sender: TObject);
    procedure menuExcluirItemClick(Sender: TObject);
    procedure menuLogEdicoesClick(Sender: TObject);
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
    procedure Save;
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
begin
  try
    btSave.Enabled := False;
    Save;
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

procedure TCompraCadForm.menuExcluirItemClick(Sender: TObject);
var
  p: Pointer;
begin
  if bufProdItens.RecordCount = 0 then Exit;

  if Application.MessageBox('Confirma a remoção do item?', 'Atenção',
    MB_ICONQUESTION + MB_YESNO) = ID_YES then
  begin

    // apenas itens salvos no banco eu mudo a situação para excluído
    if bufProdItens.FieldByName('Id').AsInteger > 0 then
    begin
      p := Pointer(bufProdItens.FieldByName('Pointer').AsInteger);
      TCompraItemEntity(p).Situacao := 'E';
    end;

    bufProdItens.Delete;
    CalcGrandTotal;
  end;
end;

procedure TCompraCadForm.menuLogEdicoesClick(Sender: TObject);
begin
  if bufProdItens.FieldByName('Id').AsInteger = 0 then
    Application.MessageBox('Esse item ainda não foi salvo!', 'Atenção', MB_ICONASTERISK + MB_OK)
  else
    TEntityLogForm.Open('TCompraItemEntity', bufProdItens.FieldByName('Id').AsInteger);
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
  fb.AddLongIntField('Id');
  fb.AddLongIntField('IdProduto');
  fb.AddStringField('Codigo', 20);
  fb.AddStringField('Nome', 60);
  fb.AddFloatField('Qtde');
  fb.AddFloatField('Valor');
  fb.AddFloatField('Total');
  fb.AddLongIntField('Pointer');
  bufProdItens.CreateDataset;
  fb.Free;

  FGridConfig.WithGrid(GridItensCompra)
    .SetDefaultProps
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
    bufProdItens.FieldByName('Id').AsFloat := item.Id;
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
  totalGeral: Double;
begin
  calc := TDatasetCalcs.Create;
  totalGeral := calc.SumColumn(bufProdItens, 'Total');
  edTotalGeral.Text := FormatFloat(',0.00', totalGeral);
  FCompra.TotalCompra := totalGeral;
  FCompra.TotalProdutos := totalGeral;
  calc.Free;
end;

procedure TCompraCadForm.Save;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FCompra);
  MergeItensFromBuf;

  opResult := FCompraBLL.AddOrUpdateCompra(FCompra, FCompraItens);

  if opResult.Success then
    Close
  else
    TMensagemValidacaoForm.Open(opResult.Message, FCompra, FPropToCompMap);
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

procedure TCompraCadForm.btPesquisarFornecedorClick(Sender: TObject);
var
  selResult: TSelectionResult;
begin
  selResult := TFornecedorManForm.Open(True);
  if selResult.Success then
  begin
    edIdFornecedor.Text := IntToStr(selResult.Value);
    edIdFornecedor.SetFocus;
    SelectNext(ActiveControl, True, True);
    SelectNext(ActiveControl, True, True);
  end;
end;

procedure TCompraCadForm.btPesquisarProdutoClick(Sender: TObject);
var
  selResult: TSelectionResult;
  produto: TProdutoEntity;
begin
  selResult := TProdutoManForm.Open(True);
  if selResult.Success then
  begin
    produto := FProdutoBll.InnerDAL.FindByPK(SelResult.Value);
    edCodProduto.Text := produto.Codigo;
    edCodProduto.SetFocus;
    produto.Free;
    SelectNext(ActiveControl, True, True);
    SelectNext(ActiveControl, True, True);
  end;
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

