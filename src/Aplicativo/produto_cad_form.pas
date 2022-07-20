unit produto_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, SpinEx, produto_entity, produto_bll, application_types,
  mensagem_validacao_form, prop_to_comp_map;

type

  { TProdutoCadForm }

  TProdutoCadForm = class(TForm)
    btCancel: TButton;
    btSave: TButton;
    ckDesativado: TCheckBox;
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
    Panel1: TPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure edPrecoCustoChange(Sender: TObject);
    procedure edPrecoVendaChange(Sender: TObject);
  private
    FProduto: TProdutoEntity;
    FProdutoBLL: TProdutoBLL;
    FPropToCompMap: TPropToCompMap;
    FIsInsert: Boolean;
    procedure ConfigMapPropComp;
  public
    class procedure Edit(Id: Integer);
  end;

var
  ProdutoCadForm: TProdutoCadForm;

implementation

{$R *.lfm}

{ TProdutoCadForm }

procedure TProdutoCadForm.btSaveClick(Sender: TObject);
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FProduto);

  if FIsInsert then
  begin
    opResult := FProdutoBLL.InsertProduto(FProduto)
  end
  else
    opResult := FProdutoBLL.UpdateProduto(FProduto);

  if opResult.Success then
    Close
  else
    TMensagemValidacaoForm.Open(opResult.Message, FProduto, FPropToCompMap);
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
  FPropToCompMap.MapString('Id', edId, 11, labId);
  FPropToCompMap.MapString('Codigo', edCodigo, 20, labCodigo);
  FPropToCompMap.MapString('Nome', edNome, 60, labNome);
  FPropToCompMap.MapFloat('PrecoCusto', edPrecoCusto, labPCusto);
  FPropToCompMap.MapFloat('MargemLucro', edMargemLucro, labMLucro);
  FPropToCompMap.MapFloat('PrecoVenda', edPrecoVenda, labPVenda);
  FPropToCompMap.MapBool('IsDeleted', ckDesativado);
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
    FProdutoBLL := TProdutoBLL.Create;
    FPropToCompMap := TPropToCompMap.Create;

    ConfigMapPropComp;

    if Id = 0 then
    begin
      FProduto := FProdutoBLL.NewProduto;
      FIsInsert := True;
    end
    else
    begin
      FProduto := FProdutoBLL.FindProdutoByPK(Id);
      FIsInsert := False;
    end;

    FPropToCompMap.ObjectToComp(FProduto);

    ShowModal;

    FProdutoBLL.Free;
    FPropToCompMap.Free;

    FProduto.Free;
  end;
end;

end.

