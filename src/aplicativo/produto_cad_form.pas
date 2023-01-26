unit produto_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Forms, Controls, Dialogs, StdCtrls, Spin,
  ExtCtrls, produto_entity, produto_bll, application_types,
  mensagem_validacao_form, prop_to_comp_map, db_context, BBarPanel;

type

  { TProdutoCadForm }

  TProdutoCadForm = class(TForm)
    barAcoes: TBBarPanel;
    btCancel: TButton;
    btSave: TButton;
    ckAtivo: TCheckBox;
    edId: TEdit;
    edNome: TEdit;
    edCodigo: TEdit;
    edPrecoCusto: TFloatSpinEdit;
    edMargemLucro: TFloatSpinEdit;
    edPrecoVenda: TFloatSpinEdit;
    labId: TLabel;
    labCodigo: TLabel;
    labNome: TLabel;
    labPCusto: TLabel;
    labMLucro: TLabel;
    labPVenda: TLabel;
    leftFlowPanel: TFlowPanel;
    rightFlowPanel: TFlowPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure edPrecoCustoChange(Sender: TObject);
    procedure edPrecoVendaChange(Sender: TObject);
  private
    FProduto: TProdutoEntity;
    FProdutoBLL: TProdutoBLL;
    FPropToCompMap: TPropToCompMap;
    procedure ConfigMapPropComp;
    procedure Save;
  public
    class procedure Edit(Id: Integer);
  end;

var
  ProdutoCadForm: TProdutoCadForm;

implementation

{$R *.lfm}

{ TProdutoCadForm }

procedure TProdutoCadForm.btSaveClick(Sender: TObject);
begin
  try
    btSave.Enabled := False;
    Save;
  finally
    btSave.Enabled := True;
  end;
end;

procedure TProdutoCadForm.edPrecoCustoChange(Sender: TObject);
begin
  edPrecoVenda.OnChange := nil;
  edPrecoVenda.Value := (edPrecoCusto.Value * edMargemLucro.Value / 100) + edPrecoCusto.Value;
  edPrecoVenda.OnChange := @edPrecoVendaChange;
end;

procedure TProdutoCadForm.edPrecoVendaChange(Sender: TObject);
begin
  edMargemLucro.OnChange := nil;

  if edPrecoCusto.Value <> 0 then
    edMargemLucro.Value := (edPrecoVenda.Value / edPrecoCusto.Value - 1) * 100;

  edMargemLucro.OnChange := @edPrecoCustoChange;
end;

procedure TProdutoCadForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEditWithNumbersOnly('Id', edId, labId);
  FPropToCompMap.MapEdit('Codigo', edCodigo, 20, labCodigo);
  FPropToCompMap.MapEdit('Nome', edNome, 60, labNome);
  FPropToCompMap.MapFloatSpinEdit('PrecoCusto', edPrecoCusto, labPCusto);
  FPropToCompMap.MapFloatSpinEdit('MargemLucro', edMargemLucro, labMLucro);
  FPropToCompMap.MapFloatSpinEdit('PrecoVenda', edPrecoVenda, labPVenda);
  FPropToCompMap.MapCharCheckbox('Situacao', ckAtivo, 'A', 'I');
end;

procedure TProdutoCadForm.Save;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FProduto);

  opResult := FProdutoBLL.AddOrUpdateProduto(FProduto);

  if opResult.Success then
    Close
  else
    TMensagemValidacaoForm.Open(opResult.Message, FProduto, FPropToCompMap);
end;

procedure TProdutoCadForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

class procedure TProdutoCadForm.Edit(Id: Integer);
begin
  Application.CreateForm(TProdutoCadForm, ProdutoCadForm);
  with ProdutoCadForm do
  begin
    FProdutoBLL := TProdutoBLL.Create(gAppDbContext);
    FPropToCompMap := TPropToCompMap.Create;

    ConfigMapPropComp;

    if Id = 0 then
    begin
      FProduto := FProdutoBLL.NewProduto;
    end
    else
    begin
      FProduto := FProdutoBLL.InnerDAL.FindByPK(Id);
    end;

    FPropToCompMap.ObjectToComp(FProduto);

    ShowModal;

    FProdutoBLL.Free;
    FPropToCompMap.Free;

    FProduto.Free;
    Free;
  end;
end;

end.

